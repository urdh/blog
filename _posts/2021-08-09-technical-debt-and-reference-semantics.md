---
title: Technical debt & reference semantics
layout: post
linkchat: "A neat trick turned out to have [unexpected pitfalls](<self>)."
---

## Background

Imagine a utility library of sorts, geared at providing basic standard library-like functionality for a product designed to run in performance-sensitive applications on resource-constrained embedded systems with various functional safety constraints. Additionally, there is a wish to minimize compile times, meaning headers in both library and application code ideally should contain only declarations as far as possible, avoiding some of the caveats of a header-only approach.

Now, consider implementing a generic vector-like class in this library, satisfying the following requirements:

1. It _must not_ use any dynamic allocations. This is non-negotiable due to the target applications running in safety-critical systems, where such allocations are typically banned outright. Essentially, this means that the vector needs to have a fixed capacity.
2. It should be possible to "erase" the fixed capacity when passing the vector to a function; a function should not have to know the capacity at compile-time.
3. To reduce the amount of header-only and template code, it should be possible to pass the vector by reference to a function which will modify the size of the vector, without having to make that function a template.
4. Avoiding dynamic dispatch as far as possible. The perception is that using dynamic dispatch would have an unacceptable performance impact.

When confronted with implementing a vector that does not use dynamic allocations, someone familiar with the C++ standard library may suggest implementing something like the proposed `std::fixed_capacity_vector` from [p0843](https://wg21.link/p0843), or perhaps an allocator-based approach similar to Hinnant's [`short_alloc`](https://howardhinnant.github.io/stack_alloc.html). Unfortunately, this falls short of the third requirement outlined above; the standard library approach relies heavily on iterators and will require functions that add or remove elements to be implemented either as template functions, or as working on very specific instantiations of iterator adaptors such as `std::back_insert_iterator`.

Another approach that could be considered is one based on dynamic dispatch. This is common in other languages and the implementation would be fairly straight-forward, even when supplying the value type using a template parameter. This also neatly decouples allocation from the interface, which means you could theoretically have implementations based on dynamic allocation for things like debug builds or non-safety-critical applications. Unfortunately, this obviously does not fulfill the final requirement.

The requirements combined _are_ possible to fulfill, with an approach that uses inheritance without dynamic dispatch. Unfortunately, as discussed later on, this construct is fraught with issues that are not immediately obvious.

## A base with reference semantics

The solution we're going to discuss in this article is, as mentioned above, based on inheritance without dynamic dispatch. It relies on a base with reference-like semantics, implementing what is essentially a mutable view, with storage being provided by the inheriting class:

```c++
template <typename T>
class vector
{
public:
  vector()
    : m_size(0), m_capacity(0), m_items(nullptr)
  {
  }

  // operator[], push_back, etc...

protected:
  vector(size_t capacity, T* items)
    : m_size(0), m_capacity(capacity), m_items(items)
  {
  }

private:
  size_t m_size;
  size_t m_capacity;
  T* m_items;
};

template <typename T, size_t N>
class allocated_vector : public vector<T>
{
public:
  allocated_vector()
    : vector<T>(N, &m_data[0])
  {
  }

private:
  T m_data[N];
};
```

This is, superficially, a pretty neat approach. Like the dynamic dispatch alternative, it reasonably separates the allocation from the actual interface, and it allows consumers of the type to inspect and modify the underlying data without relying on the specifics of the allocation. A function that needs to modify a vector can do so without having to know the capacity of this vector at compile time; simply accepting a `vector<T>&` is sufficient.

This approach has been used with relative success for several years in a project I've been working with, and for the most part it has been frictionless. We've got several types like this, interacting in various ways, representing a range of basic concepts such as matrices, buffers, vectors, and maps. Unfortunately, it has a few issues that make it bug-prone, mostly caused by the reference-like nature of the base class.

## What could possibly go wrong?

### Reference semantics

The reference semantics of the proposed `vectors` are fairly tricky to work with. Users are not always attentive, and it's easy to see how a `vector` may outlive its `allocated_vector` due to slicing. Additionally, the behavior of copy construction and copy assignment is not obvious; should they re-bind the underlying data (behaving like a pointer), or replace the contents (behaving like `std::vector`)? The behavior of the defaulted special functions is pointer-like, which could be *very* surprising (consider an expression like `vec = vector<T>()`), but once this minor detail has permeated the codebase it is very delicate to move away from.

Because the reference semantics are surprising and difficult to reason about (much like the vague ownership of raw pointers), this behavior has led to multiple bugs caused by operating on the wrong data, dereferencing null pointers, and similar lifetime issues.

### Const correctness

The proposed approach additionally suffers from poor const correctness. The fact that the base `vector` is copyable completely circumvents the const correctness of any function operating on a `const vector<T>&`, since the function in question can make a copy through which it is free to modify all aspects of the vector. While it is possible to mitigate this partially by instead passing a `const vector<const T>&`, this is verbose and only protects the _contents_ of the vector, leaving the _size_ of the vector still vulnerable to the issue.

This, in turn, means that you cannot trust any particular function to be truthful regarding whether it will modify your vector or not. Worse still, in order to avoid types like `vector<const T>` (so that functions working with vectors can work with purely read-only data), there's a factory function for creating a `vector<T>` from a `const T[N]`; this spells disaster if anyone drops the `const` qualifier. The factory function does return a `const vector<T>`, but anyone can drop that `const`.

This is further exacerbated by the fact that a function can _save_ a non-const copy of a vector it received through a reference-to-const parameter, making it difficult to use automated tools to enforce const-correctness of function arguments in cases where this (arguably dangerous, due to the reference nature) operation is performed.

## Can we fix it?

The issues described above seem pretty significant, but there are ways to mitigate them. For an existing codebase, the changes will be disruptive and likely difficult to verify if the code is poorly tested, but in the long term they will take care of _some_ of the problems.

The most glaring issue of the setup is the reference semantics of the base. This causes not only doubts regarding ownership and lifetime, but is also the root cause of most of the const correctness issues. Replacing this behavior with value semantics by implementing a sensible copy assignment operator would solve _most_ of the issues. The move constructor and move assignment operator would do the correct thing if defaulted, but the copy constructor has to be deleted:

```c++
template <typename T>
class vector
{
public:
  vector(vector&&) = default;
  vector(const vector&) = delete;

  vector& operator=(vector&&) = default;
  vector& operator=(const vector& other)
  {
    assert(other.m_size <= m_capacity);
    std::copy_n(other.m_items, other.m_size, m_items);
    m_size = other.m_size;
  }

  // ...

private:
  // ...
};
```

This is very odd behavior for a class to have, but it does guard against most potential pitfalls. Coupled with a converting constructor in `allocated_vector`, it could work out fine:

```c++
template <typename T, size_t N>
class allocated_vector : public vector<T>
{
public:
  allocated_vector(const vector<T>& other)
    : allocated_vector()
  {
    vector<T>::operator=(other);
  }

  // ...

private:
  // ...
};
```

This does disallow a previously allowed use case, though. In some cases (mostly cases where the underlying data had static lifetime), a copy of a `vector<T>` could be stored for later use. Since this behavior is no longer possible, _by design_, any code doing this would have to be re-written. Perhaps it could be modified to instead store a pointer to the underlying `allocated_vector`, or perhaps it needs to make a copy of the actual data.

These changes don't fix _all_ problems though. The const correctness issue still remains in the unfortunate case where a `vector<T>` is possible to construct from a plain `const T[N]`. There is simply no good way to fix this that does not involve a `vector<const T>`, or introducing some sort of separate `std::span`-like type that decouples the mutability of the _container_ from the mutability of _its contents_. The `vector<const T>` approach is difficult to get right, so a span-based approach is preferable - but at that point, you're losing much of the appeal of the inheritance approach. Either way, allowing a `vector<T>` to be constructed from `const T[N]` at all is a mistake.

## Are there alternatives?

In hindsight, I would not recommend using a base with reference semantics. The behavior is fragile, and although it can be fixed the fact that the design differs so significantly from the standard library means it has sort of a lock-in effect that tends to promote a slew of not-invented-here copies of `<algorithm>` and raw loops in abundance.

The dynamic dispatch approach may look tempting in a less performance critical setting. Depending on design, it may even be possible to implement with acceptable performance for most applications, if care is taken to minimize the number of virtual calls in cases like iteration. However, it would still suffer from the same lock-in effect.

Personally, I would rather relax the header-only requirement and work with other methods to reduce potential build time issues. The obvious solution, then, is `std::fixed_capacity_vector`. This could be combined with `std::span` for cases where a function wants to inspect the contents of such a vector without adding or removing elements; functions modifying the actual container would instead have to use iterators or similar standard C++ constructs.
