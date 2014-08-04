---
title: Extending biblatex-chicago
layout: post
linkchat: Adding [custom entry types to biblatex-chicago](<self>) turned out to be a simple hack.
---

Universities often have requirements on the citation style used in reports, theses and the like; and Chalmers is [no exception][referensguide].
While most of the requirements made by Chalmers are well approximated by the [biblatex-chicago][chicago] package (specifically its author-date style), some entry types are just not defined. One of those entry types is `@legislation`.


Luckily, the format [is simple][referensguide-lag] and you can easily replicate the behaviour using the generic `@misc` entry type:

~~~ bibtex
@misc{PUL,
    author = {{ "{{" }}SFS 1998:204}},
    title = {Personuppgiftslag},
    organization = {Justitiedepartementet},
    location = {Stockholm}
}
~~~

Of course, this is nonintuitive and looks strange (the law number is clearly not an author, and the intention of the entry would be clearer if the `@legislation` was used), and one has to pay attention when mis-using the author field like this to avoid re-ordering of words in the non-name.

A better entry might look like this:

~~~ bibtex
@legislation{PUL,
    number = {SFS 1998:204},
    title = {Personuppgiftslag},
    organization = {Justitiedepartementet},
    location = {Stockholm}
}
~~~

This is clearly a legislation reference, and the law number is intuitively specified as a number.
But how do we make biblatex understand this entry type?
The biblatex-chicago styles don't define the `@legislation` type, so using this type as-is will generate errors.
Simple: we use the source mapping feature of biblatex.

What we want to do is to map the `@legislation` type to something similar to the first example, since that example generates the output we want.
As such, we must map the entry type to `@misc` and the `number` field to the `author` field.
This is not difficult:

~~~ latex
\DeclareSourcemap{
    \maps{
        \map{
            \step[typesource=legislation, typetarget=misc, final]
            \step[fieldsource=number, match=\regexp{(.*)}]
            \step[fieldset=author, fieldvalue=\regexp{{ "{{" }}$1}}]
        }
    }
}
~~~

Here, we apply a source map with three steps to all input sources.
The first step maps our new `@legislation` type to `@misc`.
The `final` keyword ensures that if the current entry doesn't match this rule (_i.e._ it isn't a `@legislation` entry), the following rules won't be applied.
The second step reads the value of the `number` field and applies a regular expression, which in this case will capture the entire field in the `$1` regexp variable.
The third step writes this value to the `author` field, wrapping an extra layer of braces around it (thus stopping biblatex from parsing it as a regular name).

Using this mapping, we get the desired output for bibliography _and_ citations:

> Citing as text, _i.e._ SFS 1998:204, or in parentheses (SFS 1998:204, p. 14) works as expected.
> The bibliography entry has the expected format:
>
> SFS 1998:204. _Personuppgiftslag_. Stockholm, Justitiedepartementet.

Source mapping in biblatex is very powerful and not too difficult.
For simple things like this, source mapping is an alternative to explicitly extending or hacking the bibliography style itself.
Interested readers should look at the section on “Dynamic Modification of Data” in [the biblatex manual][biblatex], pages 143–151.

[referensguide]: http://guides.lib.chalmers.se/referensguide
[chicago]: http://mirrors.ctan.org/macros/latex/contrib/biblatex-contrib/biblatex-chicago/doc/biblatex-chicago.pdf
[referensguide-lag]: http://guides.lib.chalmers.se/content.php?pid=208254&sid=2199243
[biblatex]: http://mirrors.ctan.org/macros/latex/contrib/biblatex/doc/biblatex.pdf
