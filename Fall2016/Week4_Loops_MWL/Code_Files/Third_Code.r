library(hexbin)
library(data.table)
library(doBy)
library(lattice)
library(gridExtra)
#load appropriate libraries. 

temp_data <- function(file) {
  temp_dataset <- read.table(file, header=F, sep="\t")
  #Imports the data
  temp_dataset <- temp_dataset[ which(temp_dataset$V1!='genome'), ]
  #remove anything in the file where 'genome' is in column V1
  temp_dataset$loc = as.character(lapply(strsplit(as.character(temp_dataset$V1), split="_"), "[", -2))
  #split each line using '_' as the split variable. assign the second part of the split to loc (locus)
  temp_dataset$taxon = as.character(lapply(strsplit(as.character(temp_dataset$V1), split="_"), "[", -1))
  #split each line using '_' as the split variable. assign the second part of the split to taxon
  temp_dataset$pos = temp_dataset$V2
  #set V2 to column pos (position)
  temp_dataset$exactloc = as.character(lapply(strsplit(as.character(temp_dataset$loc), split="uce"), "[", 2))
  #split loc (locus) on 'uce' to get the exact locus name and assign that to exactloc
  dt <- data.table(temp_dataset)
  #turn the temp_dataset into a data.table
  setkey(dt, "exactloc")
  #set exactloc as a sorting key
  X <- dt[, list(MED=max(pos)), by=key(dt)]
  #using the exactloc key, loop over the data.table dt and find the maxiumum value of position. 
  temp_dataset <- dt[X, list(taxon, V1, pos, V3, loc, trPos=floor(V2-(MED/2)))]
  #using the max length define the distance from the midpoint (-/+) for each locus position and assign that to trpos
  return(temp_dataset)
  #return the dataset
}
#The above is a function that opens each file sent to it and cleans up the data a bit.

make_dataset <- function(working_dir) {
  #a function to generate the dataset. 
  setwd(working_dir)
  files <- list.files(pattern = 'smds.per.base.coverage')
  #set working directory and get files.

  for (file in files){
  #simple for loop traversing all files the loop picked up earlier. 
    if (exists("dataset")){
      #if the dataset already exists, this will start the append process. 
      Sys.sleep(0.1)
      print(file)
      flush.console() 
      #provides a way to see what files are being worked on.
      
      temp_dataset <- temp_data(file)
      #run the function setup above on the file.
   
      dataset<-rbind(dataset, temp_dataset)
      #join the new data to the old dataset. 
      
      rm(temp_dataset)
      #as a precaution, remove the temp_dataset from memory. 
  
    } else {
      #if dataset does not exist, we need to make it. 
      Sys.sleep(0.1)
      print(file)
      flush.console()
      #provides a way to see what files are being worked on.
      
      dataset <- temp_data(file)
      #this runs the function on the file and generates 'dataset' 
    }
  }
new_data <- dataset
rm(dataset)
#this is a precaution against if you run the function twice. It will remove 'dataset' so that if the loop is run again, a new dataset will be made. 
return(new_data)
}
#The above is a function loops over files in the directory provided to the function.

new_data <- make_dataset("/directory/path/to/your/files")
#make the dataset using the functions 'make_dataset' and 'temp_data'. 
#to get this statement to work properly, you will need to execute the code for the functions into active memory (similar to loading a pacakge)

#########
# now that you have data, the statements below summarize those data in various ways. 

summary_all_loci <- summaryBy(V3 ~ trPos+loc, data = new_data, FUN = function(x) { c(m = mean(x)) } )

summary_avg_loci <- summaryBy(V3 ~ trPos, data = new_data, FUN = function(x) { c(m = mean(x), n = length(x)) } )

summary_avg <- summaryBy(V3.m ~ loc, data = summary_all_loci, FUN = function(x) { c(m = mean(x), n = length(x), min=min(x), max=max(x)) } )

summary_avg <- summaryBy(V3 ~ taxon, data = new_data, FUN = function(x) { c(m = mean(x), n = length(x), min=min(x), max=max(x)) } )



##Hexbin plots for the coverages (might need to be tweaked).
plot1 <- xyplot(summary_avg_loci$V3.m~summary_avg_loci$trPos, xlim=c(-600,600), ylim=c(-10,200), xlab='Position From Center', ylab='Average Depth (x)', aspect=1, main="All Loci")
plot2 <- xyplot(summary_avg_loci$V3.n~summary_avg_loci$trPos, xlim=c(-600,600), ylim=c(-10,500), xlab='Position From Center', ylab='', aspect=1)
plot3 <- hexbinplot(summary_all_loci$V3.m ~ summary_all_loci$trPos, style = "nested.lattice", xbins=75, xlab='Position From Center', ylab='Depth (x)', ylim=c(0,500), xlim=c(-550,550), legend.width=1, aspect=1, colorkey=F, colorcut=seq(0, 1, length = 21))
### THE BINS HAVE HUGE NUMBERS BECUASE THEY ARE CAPTURING MANY POINTS IN THEM. It is the number of lines + the size of the bin...so you capture more then 1 line/locus per point(grouping). IF YOU PLOT EVERYTHING TOGETHER, WITHOUT BINNING YOU GET INDIVIDUAL LINES. 

grid.arrange(plot1, plot2, plot3, ncol=2)

grid.arrange(plot1, plot3, ncol=2)

