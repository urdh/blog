---
title: The Swedish election, in graphs
layout: post
linkchat: The Swedish election is over, and I [found some data to play with](<self>).
---

Leading up to the Swedish election a few weeks ago, the usual storm of polls was used in a (for me, at least) new way. A Github repository [consolidating data from major polling institutes][MansMeg-SwedishPolls] was published and used to power a [prediction of the election results][bottenada] using a [bayesian model based on the poll data][MansMeg-Ada]. The same data was used to power a [poll of polls][pollofpolls].

[MansMeg-SwedishPolls]: https://github.com/MansMeg/SwedishPolls
[MansMeg-Ada]: https://github.com/MansMeg/Ada
[bottenada]: https://bottenada.se
[pollofpolls]: https://pollofpolls.se

I like playing with data, and the availability of these swedish opinion polls, as well as [data from election manifestos][Manifesto] and [the Swedish Parliament itself][riksdagen] inspired me to play a bit with the data.

[Manifesto]: https://manifesto-project.wzb.eu
[riksdagen]: https://data.riksdagen.se

## A poll of polls

The first thing that came to mind when playing with the opinion poll data was to illustrate long-term trends in the political landscape using a poll of polls. Although a poll of polls using the data [already existed][pollofpolls], it only provided estimates from the previous election and onwards. Since data from at least 2003 was available (with lower-quality data going back to 1998), I thought it would be interesting to extend the poll of polls to cover the entire period — a period which by chance coincides with the tenure of Reinfeldt as chairman of the Moderate party which won the 2006 and 2010 elections[^reinfeldt].

[^reinfeldt]: There's a lot of interesting things to say about his tenure, but perhaps the most interesting is the way the Moderate party successfully changed their image and disabled their opponents in order to win two successive elections on platforms supported by a minority of the electorate. There's more on this in "Reinfeldteffekten" by Aron Etzler, which I recommend reading if you're interested in Swedish politics.

Although I have taken some courses in statistics and related fields, I by no means claim to be an expert and therefore the method I use to generate a poll of polls may be incorrect in many ways. However, the result does look vaguely accurate, and I feel that it provides an overview of the long-term changes of the political landscape in Sweden.

![Poll of polls in Sweden, 2003–2014][polls-img]

The method is not too complicated, and the R code used to generate the graph is [available on Github][gh-polls]. In essence, each poll in the data set is [expanded to cover the entire measurement period][polls-expand] (i.e. a new measurement corresponding to the final poll result is added for each day in the measurement period). Then, a [weighted poll result is calculated][polls-weight] for each day using the sample size of each poll as a weight[^dubious-1]. Finally, the graph shows an [84-day rolling average][polls-plot] of these derived polling results (it also shows the actual polls as well as actual election results).

[^dubious-1]: I suspect this is a slightly incorrect method. In an ideal world, you'd weigh based on losses in the sample, and "reputation" of the polling institute, but this simple method gives good enough results.

[gh-polls]: https://github.com/urdh/r-things/tree/master/polls
[polls-expand]: https://github.com/urdh/r-things/blob/86d6a8781b332a5ae31caf8ff4efc052d696ab9c/polls/polls.r#L44-47
[polls-weight]: https://github.com/urdh/r-things/blob/86d6a8781b332a5ae31caf8ff4efc052d696ab9c/polls/polls.r#L49-51
[polls-plot]: https://github.com/urdh/r-things/blob/86d6a8781b332a5ae31caf8ff4efc052d696ab9c/polls/polls.r#L99-109
[polls-img]: /assets/the-swedish-election-in-graphs/polls.png

## Long-term policy changes

Next, I wondered how the political climate has changed in an even longer perspective, specifically how party platforms and policies have changed in the las couple of decades. Luckily, the [Manifesto Project][Manifesto] has collected and analysed election platforms of all major parties in a number of elections and countries going back through the 1900s. For Sweden, data is available from elections 1944–2010.

This data requires less preprocessing (although Lowe et.al. 2011[^lowe] provides a couple of aggregate and alternative variables I've used), so [the R code][gh-manifesto] is a bit less tricky. It also provides many variables to look at, but I found the (logarithmic) RILE score, environmental policy, free market and Keynesian policy graphs most interesting (the others don't really highlight any surprises).

There's probably extensive academic research available on this, so I'm not going to go into any deeper analysis (if I did, I'd probably get it wrong). I will make some superficial observations regarding the four interesting graphs, however.

![Logarithmic RILE score of Swedish parties, 1944–2010][logrile-img]

The logarithmic RILE score highlights one interesting long-term change: Swedish politics have in fact (judging by the election platforms) consolidated toward the center.

![Environmental policy score of Swedish parties, 1944–2010][environment-img]

Perhaps the most interesting thing here is that the Social Democrats and the Greens are polar opposites on this issue judging by their 2010 election platforms. This is interesting because they ran as a coalition in 2010 and are the likely candidates for forming a government after the 2014 elections. Needless to say, the environment is a big issue for the Greens.

![Free market policy score of Swedish parties, 1944–2010][freemarket-img]

Free market policies used to be something only the right promoted in Sweden, but as this graph shows the Social Democrats slowly became more positive during the 1990s. Possibly notable is the shift toward free market policies for all parties in the 2010 election, which correlates with the first term of the Reinfeldt government, which introduced many free market reforms.

![Keynesian policy score of Swedish parties, 1944–2010][keynesian-img]

Conversely, Keynesian policies used to be associated with the left (or rather, the right used to be opposed). In the 80s and 90s almost all parties were opposed to Keynesian policies, but from 2002 onward there seems to be progressively less resistance from all parties except the Moderates.

Generally, all gaphs quite clearly show differences within the two major coalitions (some differences are significant and in issues which are major issues for some parties), which is interesting.

[^lowe]: Lowe, W., Benoit, K., Mikhaylov, S. and Laver, M. 2011. [*”Scaling Policy Preferences from Coded Political Texts.”*][lowe] Legislative Studies Quarterly 36 (1): 123–155.

[lowe]: https://doi.org/10.1111/j.1939-9162.2010.00006.x

[logrile-img]: /assets/the-swedish-election-in-graphs/logrile.png
[environment-img]: /assets/the-swedish-election-in-graphs/environment.png
[freemarket-img]: /assets/the-swedish-election-in-graphs/freemarket.png
[keynesian-img]: /assets/the-swedish-election-in-graphs/keynesian.png
[gh-manifesto]: https://github.com/urdh/r-things/tree/master/manifesto

## Decisions in the Swedish Parliament

The last piece of data I wanted to look at was the voting patterns in the Swedish Parliament. The Swedish Parliament has an [open API][riksdagen] which you can use to query documents, members of parliament and much more.

Specifically, the API allows you to list all votes of the parliament as well as how each member of parliament voted. Using this data, I created a script that for every vote of the 2013/14 session exctracted the majority vote of each party and assigned the party to the respective vote (yes, no or abstaining). [The script][gist-vote] then assembles a HTML table [such as this one][gist-html] showing all votes.

From this table, you can estimate how often the opposition acts in unity, how often the Sweden Democrats vote against the government (not very often) and on what issues the opposition agree/disagree with the government or each other.

Playing with data is fun, and there's probably much more you could do with both Manifesto data and the parliament API, but this is it for now.

[gist-vote]: https://gist.github.com/urdh/5d61d4d66b257c96718b
[gist-html]: https://bit.ly/voteringar1314
