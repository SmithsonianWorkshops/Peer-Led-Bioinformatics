#! /usr/bin/Rscript

library(data.table)
library(ggplot2)
library(Lahman)

# easy, "smart" loading of data files
# don't need to specify delimiter, column classes, etc - fread will work it out  
YOUR_DAT = fread("FILE_PATH")

# put Lahman table into data.table form
bat = as.data.table(Batting)

# With the table from Lahman, there is a LOT of data
Batting

# With data.table, large files will automatically show top & bottom 5 lines (not all)
bat

# Subsetting data
bat20 = bat[yearID >= 1920]

# Select column(s)
batSub = bat[, list(playerID, yearID)]
batSub

# Select on multiple conditions
batSub = bat[yearID >= 1920 & teamID == "CIN"]

# Or, can chain subset conditions / commands
batSub = bat[yearID >= 1920][teamID == "CIN" | teamID == "BOS"][,list(playerID,yearID,teamID)]

# Sort the data by team
bat[order(teamID)]

# Sort the data by games AND team
bat[order(G,yearID)]

# Sum hits and at-bats by league and year
batSum = bat[, .(N = .N, at_bats = sum(AB), hits = sum(H)), by = .(yearID, lgID)]

# Calculate league-wide batting average
batSum$lgAve = batSum$hits/batSum$at_bats

# Let's plot! League average versus year
ggplot(batSum, aes(x = yearID, y = lgAve)) + geom_point()

# Color-code leagues for easier viewing
ggplot(batSum, aes(x = yearID, y = lgAve, color = lgID)) + geom_point()

# Gap in American League - this is because Designated Hitter rule was in force between 1973-1995 (interleague play)
# SO, there are NAs because pitchers have no at-bats
# Won't calculate sums / etc with NAs

# Let's fix it! Exclude them!
# We can operate on a prior table - no need to separately add an extra column, we can calculate off initial summary table
batSum = bat[AB != "NA", .(N = .N, at_bats = sum(AB), hits = sum(H)), by = .(yearID, lgID)][,.(yearID = yearID, lgID = lgID, lgAve = hits/at_bats), by = .(yearID, lgID)]

# Let's connect the dots
ggplot(batSum, aes(x = yearID, y = lgAve, color = lgID)) + geom_path()

# Let's zoom in on more modern baseball, with just the two current leagues
ggplot(batSum, aes(x = yearID, y = lgAve, color = lgID)) + geom_path() + xlim(1901,2015)

## Dip in 1960s was when the pitching mound was lowered (1969)
## Gap b/n leagues in 1930s (pre-war), partly due to Joe DiMaggio & Ted Williams in the AL

# Let's look at differences between leagues in a single year, by player
# Exclude players who weren't at bat very often
yearComp = bat[(yearID == 1941 & AB > 400), .(N = .N, playerAve = H/AB), by = .(playerID, lgID)]

# Make a whisker plot
ggplot(yearComp, aes(x = lgID, y = playerAve)) + geom_boxplot()

## Holy crap! Ted Williams is a monster outlier. "The greatest hitter who ever lived." - Ted Williams

# Can overlay one plot type on another, if the mapping is compatible
# Let's put points on the boxplots
ggplot(yearComp, aes(x = lgID, y = playerAve)) + geom_boxplot() + geom_point()

# Kind of hard to see with overlap - let's jitter them a little from side to side
ggplot(yearComp, aes(x = lgID, y = playerAve)) + geom_boxplot() + geom_jitter()

# That's a LOT of scatter. Let's restrict it a bit
ggplot(yearComp, aes(x = lgID, y = playerAve)) + geom_boxplot() + geom_jitter(width=0.3)

# Wait - were there TWO Ted Williamses? No - seeing outlier from boxplot PLUS scatter point
# Let's color the overlain points to make this clearer
ggplot(yearComp, aes(x = lgID, y = playerAve)) + geom_boxplot() + geom_jitter(width=0.3, color = "red")

# Let's look at the distribution with a histogram
ggplot(yearComp, aes(x = playerAve)) + geom_histogram()

# What about league differences? Let's make this a stacked, color-coded histogram
ggplot(yearComp, aes(x = playerAve, fill = lgID)) + geom_histogram()

# Don't like that background?
ggplot(yearComp, aes(x = playerAve, fill = lgID)) + geom_histogram() + theme_bw()

# Now let's customize our labels
ggplot(yearComp, aes(x = playerAve, fill = lgID)) + geom_histogram() + theme_bw() + xlab("Batting average") + ylab("Number of players")

# This is getting messy. Let's save the base graph and embellish it.
plot = ggplot(yearComp, aes(x = playerAve, fill = lgID)) + geom_histogram()
fplot = plot + theme_bw() + xlab("Batting average") + ylab("Number of players")

# Take out the legend
fplot + theme(legend.position = 'none')

# Make it more granular
fplot + stat_bin(binwidth = 0.02)

# Let's go back to our yearly data set to play with formatting some more
# First, let's restrict it to just AL & NL
batSel = batSum[lgID == "AL" | lgID == "NL"]

# Now, let's enter data and make it slightly prettier
plot = ggplot(batSel, aes(x = yearID, y = lgAve, color = lgID)) + theme_bw() + xlab("Year") + ylab("League-wide batting average")

# Show points
plot + geom_point()

# Add a smoothing curve (loess by default but several options are available)
plot + geom_point() + geom_smooth()

# Let's tighten up that loess
plot + geom_point() + geom_smooth(span = .1)

# Kind of hard to see - let's separate out the data (facet)
plot + geom_point() + geom_smooth(span = .1) + facet_wrap(~lgID)

# How about vertical facets?
plot + geom_point() + geom_smooth(span = .1) + facet_wrap(~lgID, ncol = 1) + theme(legend.position = 'none')

# Let's rename the facets for easy reading
# Here's an option if you don't want to change your underlying data
lgNames = c("AL" = "American League", "NL" = "National League")
plot + geom_point() + geom_smooth(span = .1) + facet_wrap(~lgID, ncol = 1, labeller = as_labeller(lgNames)) + theme(legend.position = 'none')
