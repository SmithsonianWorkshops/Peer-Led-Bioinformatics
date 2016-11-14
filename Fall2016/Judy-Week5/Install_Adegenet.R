############################
# Adegenet Installation    #
# Caroline Judy            #
# Peer Led Bioinformatics  #
############################


# Installing Adegenet
# This is a short script for installing adegenet and loading it along with the other important packages.

# check to make sure you have a recent version of R.
	R.version.string
	
# install adegenet, with dependencies
	install.packages("adegenet", dep=TRUE)

# load packages
	library("adegenet")
	library("ape")
	library("pegas")
	library("seqinr")
	library("ggplot2")
	
# package description - should be 2.0.1
	packageDescription("adegenet", fields = "Version")

# Congrats! You are ready to begin using adegenet.



