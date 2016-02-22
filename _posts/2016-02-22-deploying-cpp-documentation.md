---
title: Deploying C++ documentation
layout: post
linkchat: "[Deploying documentation for C++ projects](<self>) is a fun thing to do."
---

The Github ecosystem is full of exciting projects designed to make pushing [well-tested], [well-crafted], [well-documented] and [frequently deployed] projects with ease (and [badges]). But there's a blind spot: trying to do these things with a project not written in whatever language is most popular this month is a bit of a challenge. Just setting up continuous builds for a project written in modern C++[^modern] requires effort.

[well-tested]: https://coveralls.io
[well-crafted]: https://codeclimate.com
[well-documented]: https://readthedocs.com
[frequently deployed]: https://travis-ci.org
[badges]: https://hields.io

[^modern]: E.g. anything more recent than C++03.

Add to this the difficulty of building beautiful documentation from such languages and the issues quickly add up.

## Building the documentation

Many modern languages come with simple and sensible standards or conventions for writing documentation, and tools that turn them into readable, noise-free documentation[^doc-examples]. When it comes to C++, we're pretty much stuck with [Doxygen] if we want a maintained project for generating documentation (and Doxygen isn't exactly human-readable or lightweight). There are [attempts][cldoc] at [doing better][doxygen-md], but generally writing documentation for C++ is both difficult and ugly.

[Doxygen]: http://www.stack.nl/~dimitri/doxygen/
[cldoc]: https://github.com/jessevdk/cldoc
[doxygen-md]: https://www.stack.nl/~dimitri/doxygen/manual/markdown.html

[^doc-examples]: For instance, Go has [godoc], Rust has [doc comments][rustdoc], and Python has [docstrings]. They all use simple, human-readable conventions and can generate lightweight documentation in HTML format.

[godoc]: http://blog.golang.org/godoc-documenting-go-code
[rustdoc]: https://doc.rust-lang.org/book/comments.html
[docstrings]: https://www.python.org/dev/peps/pep-0257/

Making the best of what's there, my most recent attempt at generating a somewhat modern and readable documentation for one of my C++ projects utilizes a combination of Doxygen and [Sphinx][^sphinx-note], with [breathe] to link the two[^cppformat-fn]. This gives enough flexibility when it comes to the output, and the entire documentation can be written in a writer-friendly format such as reStructuredText (or in this case Common Markdown, with the help of [recommonmark]).

[Sphinx]: http://www.sphinx-doc.org
[breathe]: https://github.com/michaeljones/breathe
[recommonmark]: https://github.com/rtfd/recommonmark

[^cppformat-fn]: This is pretty much the same thing [cppformat] does.
[^sphinx-note]: It is true that Sphinx has a C++ domain, but it can't generate the documentation from the C++ source which I think is less than ideal.

[cppformat]: https://github.com/cppformat/cppformat

The basic workflow goes like this:

1. Build XML documentation from the commented C++ source using doxygen, to obtain the automatically generated API reference part of the documentation.
2. Run Sphinx on the rest of the documentation (usage guides, examples, and other essential parts of the documentation), using breathe to include the API reference where appropriate.
3. Deploy the resulting documentation somewhere.

Unfortunately the first step disqualifies services such as [Read the Docs], since it requires Doxygen. This means we have to manually manage these steps. Automating the process is actually a straight-forward task, and bundling is with some setup code introducing a virtual environment to run Sphinx in makes the entire build process portable (which is essential to enable automatic generation and deployment as part of a general CI cycle).

[Read the Docs]: https://readthedocs.com

In this particular instance, I have [a somewhat over-engineered Python script][build-docs.py] which I [call from CMake][CMakeLists.txt]. It sets up a virtual environment containing the necessary Python modules, hides the Doxygen configuration required to generate the Doxygen XML output, and feeds this output appropriately to Sphinx. The result is generated HTML documentation in the build path, ready for deployment.

[build-docs.py]: https://github.com/urdh/libeu4/blob/5f91e78/support/build-docs.py#L105-L193
[CMakeLists.txt]: https://github.com/urdh/libeu4/blob/5f91e78/docs/CMakeLists.txt#L6-L14

## Deploying the documentation

While services such as Read the Docs automatically build your documentation by listening to GitHub hooks and checking out your source, this setup requires a bit more intervention. Hopefully, your project is using some kind of CI setup such as [Travis CI]. By adding an additional job to the build matrix of your CI builds, or simply appending a deployment step to one of the existing jobs, deploying your documentation can be fairly simple.

[Travis CI]: https://travis-ci.org

The general idea is to build the documentation and push this directly to the `gh-pages` branch of the project you're building. This can be done using [two dozen lines of shell script][deploy-docs.sh] and [a deployment step in your `.travis.yml`][travis.yml][^travis-note]:

~~~ sh
#!/usr/bin/env bash
# Make sure we have a github token
[[ -n "${GITHUB_DOCS_TOKEN}" ]] || exit 0

# Clone the repo, fake a user
echo Cloning repository...
GENDOCS=$(mktemp -d /tmp/generated-docs-XXXXX)
git clone --quiet "https://${GITHUB_DOCS_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" -b gh-pages ${GENDOCS} > /dev/null 2>&1 || exit $LINENO
git -C ${GENDOCS} config user.name "Travis CI"
git -C ${GENDOCS} config user.email "travis@example.com"
git -C ${GENDOCS} rm . -r

# Build the docs, straight into the cloned repo
echo Building documentation...
BUILD=$(mktemp -d /tmp/build-docs-XXXXX)
# This is where you'd run Doxygen and Sphinx to generate the HTML documentation into ${BUILD}
rsync -ru ${BUILD}/ ${GENDOCS}/

# Push the changes to gh-pages
echo Committing new documentation...
git -C ${GENDOCS} add .
git -C ${GENDOCS} commit -m "Automatic documentation deployment (${TRAVIS_COMMIT})" || exit 0
git -C ${GENDOCS} push --quiet origin gh-pages > /dev/null 2>&1 || exit $LINENO
~~~

~~~ yaml
deploy:
  - provider: script
    script: deploy-docs.sh
    on:
      repo: your/repository
      condition: '-n ${DOCUMENTATION}' # or some other condition
      branch: master
~~~

In essence, the script checks out the latest `gh-pages` commit, replaces the contents with a newly built copy of the documentation and tries to push the changes. If nothing has changed, it will silently fail (which is fine).

[deploy-docs.sh]: https://github.com/urdh/libeu4/blob/5f91e78/support/deploy-docs.sh
[travis.yml]: https://github.com/urdh/libeu4/blob/5f91e78/.travis.yml#L110-L116

[^travis-note]: You need to set up a personal access token for the build job as well. Don't forget to store it in a secure environment variable.

This way, you can serve your documentation through Github Pages while still automatically generating it.

## Future work?

In general, the state of documentation generation for C++ feels poor. As mentioned, there are attempts at better tools ([cldoc] uses Clang to parse modern C++ properly and reads comments annotated in Common Markdown), but unfortunately they tend to generate the standard frame-like dull reference instead of integrating in a way that encourages well-written and thorough documentation.

I have yet to find a well-maintained and flexible documentation generator for C++. But who knows, maybe there is one out there?
