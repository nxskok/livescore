
<!-- README.md is generated from README.Rmd. Please edit that file -->

# livescore

Following world soccer games, live.

## Setup

In R Studio, open 0-xscores2.R. Click on Jobs (in R Studio 1.2), and
Start Local Job. This runs this script in the background; it connects to
xscores every 2 minutes or so and downloads the latest scores. Give it a
couple of minutes to get going.

## To check scores

Open xscores-sep.Rmd. Run this entire notebook (ctrl-shift-R). This will
display the complete score history of all the games whose status has
changed since the last time you ran this (that is, game started, game
ended, game reached halftime, goal scored; also gone into extra
time/penalties if applicable). Games are sorted by league abbreviation
(eg. A for Italian Serie A, EPL for English Premier).
