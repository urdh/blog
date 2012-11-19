---
title: A Github publishing model
layout: post
linkchat: I explored the possibility of a [Github-based publishing model](<self>).
---

[Github][gh], as you may know, is an excellent tool for sharing and collaboration when it comes to code. Based on an excellent DVCS combined with a useful API and an easily used online interface it promotes and simplifies collaboration on open projects.

Given the [Github pages][gh-p] service, is this something we can utilize for publishing? Using the provided [Jekyll][jekyll]-based service for blogging has [been][mojombo] [explored][m8ck] [thoroughly][jekyll-sites], and there are even examples of [collaboration][gitready-pulls] in the form of submitted translations.

The Github user interface and API could be taken further, though. Concepts such as editing and reviewing submissions are easily implemented by using the existing Github UI, but this doesn't seem to be anything that has caught on. There are few [examples][wtfjs], and although the subject has been [touched upon][gh-pub] there doesn't seem to be any serious work done.

So, how would this publishing model work, anyway?

[gh]: http://github.com
[gh-p]: http://pages.github.com
[jekyll]: http://jekyllrb.com
[mojombo]: http://tom.preston-werner.com
[m8ck]: http://m8ck.us.to
[jekyll-sites]: https://github.com/mojombo/jekyll/wiki/Sites
[gitready-pulls]: https://github.com/gitready/gitready/pulls?direction=desc&page=1&sort=created&state=closed
[wtfjs]: http://wtfjs.com
[gh-pub]: http://schamberlain.github.com/scott/2012/02/13/a-github-publishing-model/

## The setup

Setting up a reviewed online publication on Github is not difficult. There are only a few concepts that have to be adapted to the Github workflow, and those fall into place  easily.

Assuming the publication can be published using Jekyll (*i.e.* articles are written in a Jekyll-readable format and published as HTML), setting up a publication is a simple matter of creating a [Github organization][gh-org] and a corresponding repository. Documenting the actual setting-up of this Jekyll base is not the purpose of this article, and is left as an exercise for the reader (using Jekyll isn't technically required either, but simplifies things significantly).

We now have the concept of a publication, and along with is the concept of articles. But how do we implement reviewing, submissions and editors? We use the tools given to us by Github, of course!

### Editors

Editors (and indeed reviewers) are easily implemented as members of the Github organization. Organizations can have teams with different permission (*e.g.* an editor-in-chief or executive team may have *pull*, *push* and *administrative* permissions while an editorial team only has *pull* and *push* permissions), and any team with permission to *push* to the repository can act as editors.

### Submission

Submitting new articles for review or publication would be done through pull requests. The writer would fork the repository, add a new post, commit it and open a pull request. The pull request can then be reviewed by the editor(s) before publication or rejection.

### Reviewing

Reviewing submissions, as explained above, consists of reviewing the posts added in a pull request and accepting (merging) or rejecting that pull request. Discussion regarding the review can be held publically in the pull request comments or privately on another arena (mailing list or similar). Since pull requests can be updated by pushing to the same branch, writers can react to comments given by the editors and improve the articles accordingly.

[gh-org]: https://github.com/blog/674-introducing-organizations

## Negative consequences

No system is ever perfect, and this publishing model is not without its flaws. For instance, the fairly technical nature of Jekyll, Git and Github makes the process difficult for non-technical writers. In practice, the technical difficulties can be avoided by combining these into a more easily understood UI. Writing [Markdown][md] can be replaced (if necessary) with web-based Markdown-generating editors (and combined with conversion tools in order to accept *e.g.* [LaTeX][latex] submissions). Submissions, given that the user has a Github account, can be replaced with automatic forking, pushing and pull request creation using the [Github API][gh-api] wrapped in a simpler UI.

Another consequence of using Github is the inherently open-source nature of the publication. If anyone should be allowed to fork the project (and by extension, submit articles) the repository must be public. This means that anyone can duplicate code and/or text used in the publication. To mitigate this, private repositories can be used. Private repositories [also have public pages][priv-pub], but they have the drawback that forking (and therefore, submitting articles) is limited to organization members. Since organization teams can be restricted to only *pulling*, a model where a "Writers" team sumbits articles through pull requests is possible, but this would incur additional overhead for both writers (having to request membership in this team) and administrators (having to handle these requests). Nonetheless, it is a viable option.

[md]: http://daringfireball.net/projects/markdown/
[latex]: http://www.latex-project.org
[gh-api]: http://developer.github.com/v3/
[priv-pub]: http://stackoverflow.com/a/10929350/147845

## Conclusion

With a bit of work, Github can be used to architect a publishing model. For non-technical or restrictive publications, there may be a larger starting cost (especially if Jekyll isn't used), but none of these circumstances are definitive obstacles. Since a similar model has been attempted on a smaller scale with a technical audience ([wtfjs][wtfjs]), extending this model to a larger publication seems reasonable.