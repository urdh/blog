---
title: "Automatic validation: CI on static blogs"
layout: post
linkchat: I introduced a method for [automatically validating static blogs](<self>) using Travis CI.
---

Continuous integration, and in particular the related methods of automated testing and continuous deployment, is something many projects on [Github][gh] utilize. For most projects, automated testing is performed using unit tests verifying that the software behaves correctly. But not only software is hosted on Github --- with the excellent [Github Pages][gh-pages] service, many blogs and static webpages are being hosted on Github.

But is it possible to extend the notion of automated testing to static pages hosted on Github? If we make the assumption that what has to be "tested" in a static webpage is the validity of the content served to the visitors, it's very possible to use the same tools used by other project on Github to perform "automated testing" (in effect, automated validation). Of course, such a system will only ensure the validity of machine-readable markup (and could in theory also be used to combat link rot and related issues), and doesn't guarantee the "correctness" of actual content.

This post will explore a setup for automated validation of a [Jekyll][jekyll] blog as hosted by Github. A key corollary of the method used is that the automated testing service, in this case [Travis CI][travis], may be used for much more than just automated testing. Here, we use the service to validate HTML, XML and CSS content but using similar scripts in combination with callbacks and other services you could theoretically compress content, ping search engines, combat link rot or even [deploy your webpage to other services][travis-to-heroku].

## Writing the "test suite"

The setup described here is based on a ruby script. The script, [`validate.rb`][validate.rb], iterates through the compiled Jekyll site using both online and offline validation services to validate files it finds as needed. This is done primarily using the [`nokogiri`][nokogiri] gem, which validates XML files locally, and the [`html5_validator`][html5_validator] and [`w3c_validators`][w3c_validators] gems, which provide interfaces to the [Validator.nu HTML5 validator][validator.nu] and the W3C [CSS validator][w3c-css] (and [feed validator][w3c-feed] for atom feeds).

Disregaring the molding of `nokogiri` and `html5_validator` to the `w3c_validators` API (lines 14--63), there's not much to the script. The general idea is to identify each file using its extension, and applying the correct validator. Any validation failures will cause the script to exit with a non-zero status, indicating a failed "build".

## Setting up Travis

Configuring Travis CI is not difficult, either. [The configuration][.travis.yml] is almost entirely using the defaults for Ruby projects on Travis. First, a Ruby version matching [the one used on Github Pages][gh-versions] is selected (which, at the moment of writing, is 2.1.1). Since all dependencies of the validation script are handled using [Bundler][bundler], which is used as a default by Travis, there is no need for any special `install` commands.
Therefore, the next step is the actual test script.

For a "build" to succeed, we need Jekyll to be able to actually build the page as well as the validation script being able to validate the output. Therefore, two `script` entries are used; one to run `jekyll build` and one to run `./validate.rb`. If both scripts exit without error, we have a fully validated static site!

As an added bonus, the Travis configuration used here also pings Google with an updated `sitemap.xml` on every successful build. Any similar `after_success` command could be used to ping other search engines or services, notifying them of new content on e.g. Jekyll blogs.

[travis]: https://travis-ci.org
[gh]: https://github.com
[gh-pages]: https://pages.github.com
[bundler]: http://bundler.io
[jekyll]: http://jekyllrb.com
[validator.nu]: http://validator.nu
[w3c-css]: http://jigsaw.w3.org/css-validator/
[w3c-feed]: http://validator.w3.org/feed/
[nokogiri]: http://nokogiri.org
[html5_validator]: https://github.com/damian/html5_validator
[w3c_validators]: https://github.com/alexdunae/w3c_validators

[travis-to-heroku]: https://coderwall.com/p/st0hcq
[gh-versions]: https://pages.github.com/versions/

[validate.rb]: https://github.com/urdh/blog/blob/cf73a78f40a5cbcec127b185894415354c082001/validate.rb
[.travis.yml]: https://github.com/urdh/blog/blob/1c3442c775ae4c9e3fd3778e57080089daa9ff67/.travis.yml
