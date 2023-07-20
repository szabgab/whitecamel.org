# The source of [whitecamel.org](https://whitecamel.org/)

## Static site generation:

The site is served using GitHub pages.

The `docs/` folder contains static files that are copied by the GitHub action and then the `script/static.pl` generates the html pages.
`docs/CNAME` contains the domain name.

Locally one could just run `script/static.pl` to generated the html files in the `docs` folder.

`t/`  has a test script with some minimalistic test cases to see if the static site generator works

Using the [Skeleton responsive boilerplate](http://getskeleton.com/)

## TODO:

* Write down the history of the award and what the process is deciding who gets it.
  The awards were originally given out by Perl Mongers, Inc but passed
  on to TPF around 2002 when PM merged with them.

* Collect URLs, rss feeds from the winners

* Collect countries of residence (when the award was received) ?

* Update the text on the individual pages (they should somehow
  include information that shows what did the person do before receiving the
  award and what are newer things). That might preserv the historical
  information.
  Also some of the texts might need to be changed to past tense as people
  have moved on from various positions or activities.

* Links to the Perl Mongers, YAPCs ?

* A photo of the person (make it easier to recognise them at events, make the profile more personal)
  use Gravatar.

* A bio/profile of the person, what they do.  Not all the white camel nominations/award texts tell the whole story,
  so it could be cool to have 4 - 6 paragraphs from the person about what they do in/for the Perl community

* A story of how that person got into Perl in the first place,
  and perhaps links to conferences they attend or their local Perl Mongers group.

* A calendar of forthcoming speaking engagements.

* Interview with the award winner.


## Description

/index.html
  The pictures of the latest awardees with the text below each

/awardees.html
List of all the awardees with links to their individual pages
Maybe the list should be grouped by year and not abc


Links to pages for each year: ????
   /2010/
   /2009/
   ...
Each year has the list of the awardees with pictures.

## Contributors

* [Irakliy Sunguryan](https://github.com/OpossumPetya)  (design)

