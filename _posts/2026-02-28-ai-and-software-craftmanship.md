---
title: AI & Software Craftsmanship
layout: post
linkchat: The disruption of software development by AI *feels* inevitable, but [is it sustainable](<self>)?
---

The topic of AI disruption has been cropping up a lot lately, and I've been thinking about the fairly rapid and uncritical introduction of tools like Anthropic's Claude in the software industry in what you might ungenerously describe as *luddite*[^decels] terms. I am by no means the only one worrying about this seemingly inevitable disruption, and Adam Neely's video essay *[Suno, AI Music, and the Bad Future][neely]* in particular resonated with me. Although it primarily discusses the effects on AI on the *music* industry, much of it is still relevant to software development as seen though the *Software Craftsmanship* lens---both groups (presumably) enjoy their work, enjoy sharing and honing their craft, and arguably both professions are (more or less) creative endeavors.

[^decels]: ...or "decels", to reference a derogatory term from the neo-[futurist] "techno-optimist" movement popular among Silicon Valley venture captial.

[neely]: https://www.youtube.com/watch?v=U8dcFhF0Dlk
[futurist]: https://en.wikipedia.org/wiki/Futurism#1920s_and_1930s

## Who are we replacing?

A pessimist view of the effects of AI on the software industry seems to be that most (or all) actual *developers* will eventually be replaced by AI, leaving only vibe-coding project managers and perhaps a few senior developers [prompting OpenClaw instances][antfarm] and having those instances [get miffed when their merge requests are rejected][mj-rathbun].

The slightly less depressing (and much more likely) option in my opinion is a gradual shift away from teams consisting of junior and senior developers to teams consisting of senior developers and their AI agents. What would the consequences of this be?

[antfarm]: https://www.antfarm.cool/
[mj-rathbun]: https://theshamblog.com/an-ai-agent-published-a-hit-piece-on-me/

### Junior developers

The current capabilities of AI models is perhaps closest to that of a "junior" engineer, with the notable exception that they [don't learn][no-learning], at least not in the way an actual junior developer would---they don't carry memory across tasks unless you specifically tell them to, they don't know what the purpose of the code they're working on is or how it fits into a bigger picture, and they don't improve with mentorship.

What they *can* do, which is similar to junior developers, is to solve well-defined problems somewhat independently and generate code which is often useful and elegant enough. Specifically, they can do this at a much higher rate than actual junior developers, which provides an obvious short-term cost-cutting target---why hire new junior developers who will decrease velocity in the short term, when you can just get your existing developers a Claude license and increase their output *today*?

Even worse, AI models allow existing juniors to skip the learning process entirely---this is already becoming an issue in higher education and it's obvious through extrapolation that this is likely already happening in the software development industry as well. When you outsource too much of your work as a junior to an AI model, you not only deprive *yourself* of the opportunity to grow into a senior engineer[^role-models], you also deprive the *team* of the opportunity to spread knowledge, build consensus, and explore ideas by having your senior colleagues explain architectural choices, asking critical questions and questioning specifications.

This leaves us in a situation where we're removing the bottom rungs of the ladder to becoming a senior developer, by hiring fewer juniors and handing the ones we have a [self-harming tool][death-trap] (and encouraging them to use it, in the name of productivity).

[^role-models]: Through mentorship and role models; more on this later.

[no-learning]: https://blog.mmckenna.me/stop-calling-ai-a-junior-engineer
[death-trap]: https://www.reddit.com/r/ExperiencedDevs/comments/1po21hq/ai_is_a_death_trap_for_many_junior_devs_how_do_i/

### Senior developers

The promise of increased *perceived* productivity, already in part backed up by research finding that AI tends to [increase both the scope and intensity of work][workload] for engineers who use it, again provides an obvious cost-cutting target. I'll discuss long-term consequences of this on output quality later, but the effect on the senior engineers themselves will likely be increased stress due to gradually increasing expectations of productivity.

More so, when you have LLM agents at your disposal 24/7, then why aren't you using them to "work" at all hours of the day? Research has already found that AI tends to [increase both the scope and intensity of work][workload]---with this innovation, we can *all* be workaholics with [high anxiety][high-anxiety] who spend all our leisure time thinking about work.

Studies in other fields have also shown that use of AI assistants [might make you worse at your job][deskilling], which is especially unsurprising in a field in where you are (or used to be) constantly learning and improving through active engagement with your colleagues and others in your profession. This all points to a future with fewer senior engineers, who are more stressed out and worse at their jobs---and that's not a bright future for anyone in the industry.

[deskilling]: https://doi.org/10.48550/arXiv.2506.08872
[high-anxiety]: https://bsky.app/profile/richaber.bsky.social/post/3mew2xcicc22r
[workload]: https://newsroom.haas.berkeley.edu/ai-promised-to-free-up-workers-time-uc-berkeley-haas-researchers-found-the-opposite/

## *What* are we replacing?

The promise of early generative AI was to replace the rote, boring parts of software development, essentially functioning as a very fancy auto-complete. This is not without its issues (quality is not a given, as we'll discuss later), but it's arguably a useful use case which could allow you to focus more on the bigger picture[^craftsman].

Recently the pitch is closer to a C-suite fever dream: replace entire teams of developers with AI agents by assigning them to be developers, architects, QA engineers, and managers, outsourcing every aspect of software development. Just tell it to [build a compiler][claude-compiler], and it'll do it ([sort of][primeagen-compiler]). Personally, I think replacing most of what I find enjoyable in software development (architecture, understanding a system, and indeed the detail-oriented small stuff) sounds dystopian, but I also think the replacement---or indeed *having* a replacement---*isn't very good*. Doing these things routinely is what makes you a better developer.

[^craftsman]: Though to a software craftsman, the details may be just as important as the big picture, and you might not want to outsource either of them to generative AI.

[claude-compiler]: https://www.anthropic.com/engineering/building-c-compiler
[primeagen-compiler]: https://www.youtube.com/watch?v=6QryFk4RYaM

### Quality vs. Quantity

It's clear that current models still hallucinate [and implement well-known bugs][output-quality], and there's no reason to think this will improve over time (especially not given they are trained on imperfect input). The advantage of LLM:s in software development will therefore never be higher quality[^slop], at least not when comparing output to that of senior developers, but a higher *quantity* of code. This doesn't necessarily even translate to higher productivity; if the output is of low enough quality, an increase in "velocity" might even *decrease* productivity over time.

Consider what this might mean for an organization which is already short-staffed or at risk of being so, especially on senior engineers. Deploying LLM:s may at first seem to increase productivity by allowing more features to be shipped by fewer (or less experienced) developers, but over time this will inevitably increase technical debt while also de-skilling the senior engineers, who presumably will be less able to keep up with reviewing and understanding the evolving codebase. When actual development is outsourced to an LLM, it is also less likely that any junior developers involved will gain the in-depth understanding of a codebase which only hands-on experience and feedback loops with senior developers can provide[^assuming-high-quality].

The end result will be a codebase which is more complex, seniors who know less and less about the system, and a development process which gets more and more locked into the LLM workflow---until a context window limit is hit[^context-windows]---and at that point the system may also be too complex for the developers themselves to get useful work done.

[^assuming-high-quality]: And this is with the generous assumption that the LLM-generated code will be of sufficiently high quality; otherwise, the immediate effect will be a massive increase in defects and an increased workload which arguably will mostly affect the senior developers.
[^context-windows]: Eventually you're going to reach hardware limits. [Careful use might mitigate this][context-window-limit], but that requires system knowledge to determine which slices of context to feed to the model.
[^slop]: This not only applies to writing code, but also to [bug reporting and analysis][haxx-slop], and likely also [translates to other professions][acoup-slop].

[output-quality]: https://bsky.app/profile/baldurbjarnason.com/post/3meyehkudzhhi
[context-window-limit]: https://blog.nimblepros.com/blogs/context-windows-wont-grow-forever/
[haxx-slop]: https://daniel.haxx.se/blog/2025/07/14/death-by-a-thousand-slops/
[acoup-slop]: https://bsky.app/profile/bretdevereaux.bsky.social/post/3mf4eq27hbc2m

### Software craftsmanship

In his video essay Adam Neely presents four values, contrasting with the values of *Suno* the AI music generator: service (to a community), patience, craft, and beauty. The first three of these (especially the third) are themes also presented in [*The Software Craftsman*][software-craftsman] to various degree:

* A software craftsman values exchanging ideas with other developers, discussing ideas and spreading knowledge through the community of fellow software craftsmen.
* Patience is perhaps discussed more in terms of *professionalism* in the book, in terms of not letting quality suffer at the hands of speed and having the patience to do things right.
* *Craft* is, of course, a central theme in software craftsmanship; dedicating yourself to mastering the trade of software development.

Much like Neely's values contrasting with those of Suno, the values of software craftsmanship contrast with the implied values of "vibe coding"---code, impatience, and ignorance[^ignorance].

Neely also discusses the importance of *role models*, having someone to aspire to and lean on to make decisions and hold ourselves to a higher standard---*being* a role model is discussed extensively through *The Software Craftsman*, and in my opinion this is a core responsibility of senior engineers (mentoring junior developers). As discussed earlier, mentoring is not something an AI model does very well, and I would argue that without the *values* of software craftsmanship (or rather, *with* the values of vibe coding), juniors will not have any role models or mentors to rely on and software craftsmanship will perish.

[^ignorance]: This sounds harsh, but the implication that there's no need to learn a new programming language or understand the systems you're working on (because the AI model will do that for you) really strikes me as valuing ignorance.

[software-craftsman]: https://www.goodreads.com/book/show/23215733-software-craftsman-the

## Epilogue

So are we heading into a world where anyone can build anything, democratizing software and making software development truly a commodity, or are we just killing the trade and replacing dedicated craftsmen with overgrown Markov chains for the benefit of the owning class? Only time will tell.

I think the short-term effects will be an increase in "productivity" followed by a hang-over of burnout and technical debt, unless organizations are careful. For those of us who subscribe to the ideas of software craftsmanship, I think sticking to its core values will be beneficial in the long term, both for the software we work on and our stress levels. I wouldn't be surprised if at some point there will be high demand for experienced people to clean up vibe-coded [big balls of mud][mud], just as there has been demand to clean up big balls of mud from outsourcing (and other provenance) in the past.

[mud]: https://blog.codinghorror.com/the-big-ball-of-mud-and-other-architectural-disasters/

### Is  there *any* utility?

Careful use of AI models could still provide some utility; nuanced approaches can be found if you ignore some of the most enthusiastic all-in AI evangelists. One such use case is as an off-loading tool for [uninteresting or less important problems][primeagen-side-quests], or perhaps to triage and do initial analysis on flaky automated tests---things which truly allow you to spend less time on repetitive or boring issues allowing you to spend more time crafting good software where it matters. Another similar use case is to allow non-developers to generate code for applications where the software is truly just a *tool*, and not the product---things like analysis scripts for researchers or automation.

Hopefully this is the future we will gravitate towards when the hype subsides a bit.

[primeagen-side-quests]: https://www.youtube.com/watch?v=gRi82PiiaOs&t=290s
