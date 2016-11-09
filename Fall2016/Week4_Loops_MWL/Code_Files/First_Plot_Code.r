### AN EXAMPLE FOR LOOP FOR REPETITIVE PLOTTING ###

library(readxl)
library(doBy)

###
summed.station <- summaryBy(RIDERS_PER_WEEKDAY ~ STATION + month, data = mydata, FUN = function(x) { c(m = mean(x), sd = sd(x), s = sum(x), len=length(x)) } )
#summaryBy is part of the doBy library, see ?summaryBy for more information. This takes the data, and applies a series of functions to the riders_per_weekday variable grouped by STATION + month.

lab<-c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
#Labels for the plots. 

pdf("WMATA_total_month.pdf", height=13,width=18)
#Open a PDF files for printing. 

par(mfrow=c(7,13), mar=c(0,0,3,1),oma = c(5,4.5,.5,0))
#par statement defines the number of columns and rows that sub-plots can fill, the plot margins (mar) and outside margins (oma).

x=0
#set the counter equal to zero. This counter is used to keep track of which plot we are doing, and based on that number should we put axis data etc. on that plot. 

for ( i in levels(factor(summed.station$STATION)) ) {
  #simple for loop. For all the levels in STATION, do something. I had to use the 'levels''factor' call because of the type of data from the import. 
  
  x <- x+1
  #increment the counter. 
  
  cat(paste("..", i, ".."))
  #print the station that the script is working on. This is a sanity check. The "cat(paste())" notation allows for nicer printing to the screen. 
  
  summed_single <- summed.station[ which(summed.station$STATION==i), ]
  #to plot just the data relavent to the station 'i' a subset of the data is required. This takes that subset. 
  
  plot(summed_single$month, summed_single$RIDERS_PER_WEEKDAY.m, xlab="", ylab="", ylim=c(0, 34250), xaxt="n", yaxt="n", pch=16, col="Blue")
  #a simple plot statement, with the x/y labels turned off, and the x/y axes turned off. pch sets the symbol to solid circles and col is the color of the points. 
  
  axis(side = 1, at=c(1,2,3,4,5,6,7,8,9,10,11,12), labels = if (x >= 79) lab else FALSE, cex.axis=0.8, mgp=c(3, .5, 0))
  axis(side = 2, labels = (x == 1 || x == 14 || x == 27 || x == 40 || x == 53 || x == 66 || x == 79 ), cex.axis=0.8, las=2)
  #these two statements are involved in the printing of the x/y axes. If the counter 'x' is greater or equal than 79, add the X axis to the plot. 
  #If the counter 'x' is equal to 1,14,27,40...etc., add the Y axis to the plot. 
  
  if (x >= 79) {
    mtext(i, side=1, line=1.5, cex=0.6)
  } else {
    mtext(i, side=1, line=.5, cex=0.6)
  }
  #bit is responsible for putting the station name as a label on each sub-plot. If the counter 'x' is greater or equal to 79 [the bottom row of plots] the station name gets moved down to accomidate the X axis label.
}
title(xlab = "Month", ylab = "Mean Monthly Ridership (2010-2016)", outer = TRUE, line = 3.1, cex.lab=1.5)
#these are the main titles for the overall plot. 
dev.off()
#print everything to the PDF and close the 'display' 
