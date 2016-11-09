### AN EXAMPLE OF NESTED FOR LOOPS FOR REPETITIVE PLOTTING ###

library(readxl)
library(doBy)


mydata <- read_excel("example_files/Avg-Weekday-Rail-Ridership-by-Month-by-Station-2010-to-20161.xlsx")
mydata$year <- substr(mydata$DATEMONTHINT, 1, 4)
mydata$month <- substr(mydata$DATEMONTHINT, 5, 7)
mydata <- mydata[order(mydata$year),] 
## Import the data. Then get the year/month taking substrings (substr) from a concatnated string, and finally sort on year. 

years <- levels(factor(mydata$year))
#Get the years contained in the data. The 'levels''factor' notation is required because of the type of data following the import. 

lab<-c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
#labels for the plots. 

for (j in years) {
  #simple for loop. for each year 'j' do something with that year. 
  
  newdata <- mydata[ which(mydata$year==j), ]
  #this is the 'something' we are doing with the year. The data is being subset to contain just year 'j'
  summed.station <- summaryBy(RIDERS_PER_WEEKDAY ~ STATION + month, data = newdata, FUN = function(x) { c(m = mean(x), sd = sd(x), s = sum(x), len=length(x)) } )
  #summaryBy is part of the doBy library, see ?summaryBy for more information. This takes the subsetted data, and applies a series of functions to the riders_per_weekday variable grouped by STATION + month.
  
  cat(paste("..", j, "..\n"))
  #print the year that the script is working on and then a newline [\n]. This is a sanity check. The "cat(paste())" notation allows for nicer printing to the screen. 
  
  pdf(paste(j,".pdf", sep=""), height=13,width=18)
  #open a PDF file, using the year 'j' as the name of the PDF. The paste() statement allows you to combine a variable with text. 
  
  par(mfrow=c(7,13), mar=c(0,0,3,1),oma = c(5,4.5,.5,0))
  #par statement defines the number of columns and rows that sub-plots can fill, the plot margins (mar) and outside margins (oma).
  
  x=0
  #set the counter equal to zero. This counter is used to keep track of which plot we are doing, and based on that number should we put axis data etc. on that plot. 
  
  for ( i in levels(factor(summed.station$STATION)) ) {
    #this is the nested for loop. For each station in the summarized data from above (i.e., main data subset by year then summarized), do something. 
    
    x <- x+1
    #increment the counter.
    
    cat(paste("..", i, ".."))
    #print the station that the script is working on. This is a sanity check. The "cat(paste())" notation allows for nicer printing to the screen. 
    
    summed_single <- summed.station[ which(summed.station$STATION==i), ]
    #to plot just the data relavent to the station 'i' a subset of the data is required. This takes that subset.
    
    if (is.data.frame(summed_single) && nrow(summed_single)==0) {
      plot(1, type="n", axes=T, xlab="", ylab="", ylim=c(0, 36000), xlim=c(1,12), xaxt="n", yaxt="n")
    } else {
      plot(summed_single$month, summed_single$RIDERS_PER_WEEKDAY.m, xlab="", ylab="", ylim=c(0, 36000), xlim=c(1,12), xaxt="n", yaxt="n")
    }
    #the if/else statement is required here because several stations did not exist in all years of the dataset. 
    #If those stations don't exist, the number of rows in the dataset would equal zero
    #nrow(summed_single)==0 checks this, and if that is true, and the data is a data.frame, an empty plot is printed. 
    #However, if summed_single has data [else], it will plot the data using a simple plot statement, with the x/y labels turned off, and the x/y axes turned off. pch sets the symbol to solid circles and col is the color of the points.
    
    axis(side = 1, at=c(1,2,3,4,5,6,7,8,9,10,11,12), labels = if (x >= 79) lab else FALSE, cex.axis=0.8)
    axis(side = 2, labels = (x == 1 || x == 14 || x == 27 || x == 40 || x == 53 || x == 66 || x == 79 ), cex.axis=0.8, las=2)
    #these two statements are involved in the printing of the x/y axes. If the counter 'x' is greater or equal than 79, add the X axis to the plot. 
    #If the counter 'x' is equal to 1,14,27,40...etc., add the Y axis to the plot. 
    
    if (x >= 79) {
      mtext(i, side=1, line=2, cex=0.6)
    } else {
      mtext(i, side=1, line=.5, cex=0.6)
    }
    #bit is responsible for putting the station name as a label on each sub-plot. If the counter 'x' is greater or equal to 79 [the bottom row of plots] the station name gets moved down to accomidate the X axis label.
  }
  title(xlab = "Month", ylab = paste("Monthly Ridership in ",j,sep=""), outer = TRUE, line = 3.1, cex.lab=1.5)
  #these are the main titles for the overall plot. 
  dev.off()
  #print everything to the PDF and close the 'display' 
  cat(paste("\n"))
  #newline for nice printing to the screen.
}
