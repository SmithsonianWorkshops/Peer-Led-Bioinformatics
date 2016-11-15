############################
# Adegenet Intro           #
# Caroline Judy            #
# Peer Led Bioinformatics  #
############################

# Let's get started! 

rm(list = ls(all = TRUE))

# load packages
	library("adegenet")
	library("ape")
	library("pegas")
	library("seqinr")
	library("ggplot2")
# generally just ignore masked alerts, of which there are several.



#########################################################
# TUTORIAL 1 (familiarizing oneself with genind objects)#
#########################################################

# Instructions: Call "nancycats". This is a canned dataset associated with the Adegenet package.

# Questions
#1. Is nancycats a genind or genpop object?
#2. What type of genetic data is it? Use $ or @ to open the appropriate slot.
#3. How many individuals are there? Use the appropriate accessor.
#4. What is the percentage of missing data? Use the summary command.
#5. Make a barplot of the alleles per locus. Hint: try using a slot to make this easy.

###########
# Answers #
###########

#1.
data(nancycats) 
is.genind(nancycats) #should say "TRUE"

#2.
nancycats@type #should say "codom" for codominant
#3.
Nind(nancycats) #should be 237
#4.
summary(nancycats) #should be 3.34%
#5.
barplot(nancycats@loc.n.all, ylab="Number of alleles", main="Number of alleles per locus")
or
barplot(nancycats$loc.n.all, ylab="Number of alleles", main="Number of alleles per locus") # note that $ or @ can be used to access a slot.

#########################################################
# Tutorial 2 (perform a PCA on dataset microbov)        #
#########################################################

# Instructions: Work through lines 55 through XX to perform a PCA on the canned dataset "microbov"

# call the dataset 'microbov'
	data(microbov)

# count the number of missing data
	sum(is.na(microbov$tab))

# check the percent missing data if you want:
	summary(microbov)

# take a look at the data
	microbov@tab[1:5, 1:5]

#use 'scaleGen' to replace missing data (NAs) with mean allele frequencies. Center to zero. No scaling necessary. Note - you 	could also use 'na.replace' and then left the cetering and scaling to dudi.pca.

x <- scaleGen(microbov, NA.method="mean")
	class(x)
	dim(x)
	
# now look at the data again, and note that data have been transformed.
	x[1:5, 1:5]

# perform the PCA. note the scannf command controls how many retained axes there are. note the centering and scaling options 	are turned off since we already did that with scaleGen. 
	pca1 <- dudi.pca(x, cent=FALSE, scale=FALSE, scannf=TRUE) #select 3

# now use the following code to make a pretty scree plot that is easier to read:
	barplot(pca1$eig[1:50], main="PCA eigenvalues", col=heat.colors(50)) 


# make a scatter plot of the plane showing variation on PC1 and PC2. Use pop labels instead of individual labels:
	s.class(pca1$li, pop(microbov))
	title("PCA of microbov dataset/naxes 1-2")
	add.scatter.eig(pca1$eig[1:20],3,1,2)

# make a scatter plot of the plane showing variation on the third axis, PC3. Use color.
	colorplot(pca1$li[c(1,3)], pca1$li, transp=TRUE, cex=3,xlab="PC 1", ylab="PC 3")
	title("PCA of microbov dataset/naxes 1-3")
	abline(v=0, h=0,col="grey", lty=2)

#Questions
#1. What does the color represent in the final graph? 
#2. How can you change the final plot to display PC1 and PC2 instead of PC1 and PC3?

###########
# Answers #
###########

#1. genetic distance 
#2. 
colorplot(pca1$li[c(1,2)], pca1$li, transp=TRUE, cex=3,xlab="PC 1", ylab="PC 2")
title("PCA of microbov dataset/naxes 1-2")
abline(v=0, h=0,col="grey", lty=2)





