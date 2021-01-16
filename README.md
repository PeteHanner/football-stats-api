# [College Football Statistics API](https://petehanner.github.io/football-stats/)

## Intro

I started this project during the COVID-19 pandemic, inspired in no small part by the college football season that has happened during that time. I've always subscribed to the adage that "you can only play the teams on your schedule." Usually, this applies in the context of non-P5 teams being penalized harshly and systematically for their conference membership. Teams like UCF, Houston, or Western Michigan have in various recent seasons wrecked shop against virtually every opponent on their schedule, yet been denied well-deserved rankings or playoff spots because those opponents weren't wearing SEC or B1G patches on the front of their jerseys. They've excelled by every possible metric within their control, only to be punished for factors entirely out of their control.

In 2020, however, these forces ascended to an entirely new dimension. With games having drastically different counts between teams, being flexed to new dates or cancelled, and largely limited to in-conference play, how were we supposed to evaluate team quality? I found myself returning to that phrase, "you can only play the teams on your schedule." What would it look like if we tried to judge teams based _only_ on how they performed against their schedule, compared to how other teams fared against the same opponents? This is my attempt to find out.

This project uses the public [College Football Data API](https://api.collegefootballdata.com/api/docs/?url=/api-docs.json) to pull just a couple of data points from each game: how many points did each team score, and how many times did they each possess the ball? From there, I calculate a series of adjusted stats (outlined below), ultimately arriving at a single normalized score for each team.

A couple disclaimers:
+ First, these definitely aren't the most advanced statistics in the world. There are _far_ smarter people than me out there doing _far_ more sophisticated modeling on the CFB world. I just wanted to see what I could come up with on my own.
+ Second, I do NOT necessarily think this is the actual best way to evaluate teams. I set out on this project to answer the question "if we used this standard, who would be the best teams according to this standard?", not "who are the best teams period?". I do still believe non-brand name teams get cheated more often than not, but there is something to be said for the eye test and intangibles.

The current season can be queried with a GET request to https://pete-hanner-football-stats-api.herokuapp.com/seasons/2020. Other seasons are not currently available so I could stay within free Heroku DB limits.

[See the project live here](https://petehanner.github.io/football-stats/)

## The Stats

### First-Order Game Stats

#### Points per Offensive Possession (POP)

+ Your points ÷ Your possessions
+ On average, How many points did you get every time you had the ball in this game?

#### Points per Defensive Possession (PDP)

+ Opponent points ÷ Opponent possessions
+ On average, how many points did you give up every time your opponent had the ball in this game?


### First-Order Season Stats

#### Average Points per Offensive Possession (APOP)

+ Sum of all your POP stats ÷ Your total games played
+ On average, how many points do you gain whenever you have the ball?

#### Average Points per Defensive Possession (APDP)

+ Sum of all your PDP stats ÷ Your total games played
+ On average, how many points do you give up whenever your opponents have the ball?

#### Average Points per Possession Differential (APDP)

+ APOP - APDP
+ On average, how many points do you gain per possession vs. give up per opponent possession?


### Second-Order Game Stats

#### Offensive Performance Ratio (OPR)

+ 100(Your POP ÷ Your opponent's APDP) - 100
+ As a percentage, how did your offense perform in this game compared to all offenses that have faced this opponent?
+ Positive values are % overperforming mutual opponent average, negative values are underperforming.

#### Defensive Performance Ratio (DPR)

+ 100(Your opponent's APOP ÷ Your PDP) - 100
+ As a percentage, how did your defense perform in this game compared to all defenses that have faced this opponent?
+ Positive values are % overperforming mutual opponent average, negative values are underperforming.


### Second-Order Season Stats

#### Average Offensive Performance Ratio (AOPR)

+ Sum of all your OPR stats ÷ Your total games played
+ As a percentage, how does your offense usually perform compared to all offenses that have faced your opponents?

#### Average Defensive Performance Ratio (ADPR)

+ Sum of all your DPR stats ÷ Your total games played
+ As a percentage, how does your defense usually perform compared to all defenses that have faced your opponents?

#### Cumulative Performance Ratio (CPR)

+ The final statistic
+ Sum of AOPR and ADPR ÷ 2
+ As a percentage, how does your team usually perform compared to all teams that have faced your opponents?
