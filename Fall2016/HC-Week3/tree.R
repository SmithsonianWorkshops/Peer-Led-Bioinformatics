
install.packages("picante")
require(ape)
require(picante)
require(geiger)
#require(phytools)
detach("package:phytools", unload=TRUE)

setwd("C:/Users/hc/Desktop/R_workshop")
load("tree.Rdata")
save.image("tree.Rdata")

#import tree and data
tree<-read.nexus("ssutree.tre")
class(tree)
is.rooted(tree)

labels<-read.delim("labels.txt")

tree.multi<-read.nexus("multi.tre")
plot(tree.multi,cex=0.5)
#import many trees


#check to make use data and tips match
name.check(tree,labels,data.names=labels$samples)

plot.phylo(tree, cex=0.5)

plot.phylo(tree,use.edge.length=T,show.tip.label=F,show.node.label = F)
tiplabels(cex=0.5,frame="none")

#increasingly large clades
plot(ladderize(tree, right=T),use.edge.length=T, show.tip.label=F)

tree<-root(tree,31,resolve.root=T)

plot((tree), use.edge.length=T, show.tip.label=F)
nodelabels(cex=0.5,frame="none", col="red")
tiplabels(cex=0.75,frame="none")
#OR
tiplabels(tree$tip.label, cex=0.5,frame="none",adj=c(-0.1))

#rotate
tree<-rotate(tree,121)




#drop tip
tree$tip.label[29]
tree2<-drop.tip(tree, "JN872238_Nosema_sp._Bombus_pyrosoma")

plot((tree2), use.edge.length=T, show.tip.label=F)
tiplabels(tree2$tip.label, cex=0.5,frame="none",adj=c(-0.1))

#extract clade
tree3<-extract.clade(tree,121 )

plot((tree3), use.edge.length=T, show.tip.label=F)
tiplabels(tree3$tip.label, cex=0.5,frame="none",adj=c(-0.1))

#unrooting
tree<-unroot(tree)
is.rooted(tree)

#import another data file
indels<-read.delim("indels.txt", header=T, stringsAsFactors = F)

#merge 2 data files if not sorted the same way
labels.indels<-merge(labels,indels,by.x="samples",by.y="names")

#match data to tree tips
match<-match.phylo.data(tree,labels.indels)

rownames(labels.indels)<-labels.indels[,1]

sapply(match,class)

match<-match$data
match$non.bombus<-as.numeric(as.character(match$non.bombus))
match$bombus.count<-as.numeric(as.character(match$bombus.count))
match$TC<-as.numeric(as.character(match$TC))

#make classes out of percent bombus
B.class<-NA
PB<-match$bombus.count/match$TC
B.class[PB==1]<-"dark blue"
B.class[PB==0]<-"red"
B.class[PB==0.5]<-"green"
B.class

Support<-NA
Support[tree$node.label>0.5]<-"*"

#main tree: blue tip = found in bombus hosts, red = found in non-bombus hosts
plot(ladderize(tree),show.tip.label=F,root.edge=T,no.margin=F,cex=0.45,show.node.label=F)
tiplabels(pch=16,cex=(log10(match$TC)+0.5),col=B.class,frame="none")
nodelabels(Support,adj=c(1,0.5),frame="none",cex=1)
add.scale.bar(0.1,115,cex=0.5)



#plot indels
par(mfrow =c(1,1))
plot(tree,show.tip.label=F,root.edge=T,no.margin=F,cex=0.45,show.node.label=F,edge.width=2)
i63_73<-character(length(match$row.names))
i63_73[match$X63to73==1]<-"blue" #missing
i63_73[match$X63to73==0]<-"red" #insert
i63_73[match$X67to73==1]<-"purple" # 4bp insert instead of full
i63_73[match$X73to76==1]<-"green" #10bp insert
tiplabels(pch=16,col=i63_73)
title("Indel:63-73;
      blue=del;red=full insert;purple=4bp insert;green=10bp insert")



##Import alignments ###

fasta<-list.files(path=".",pattern="*.fasta")
k<-list(0)
F<-1
for (F in 1:length(fasta)){
  k[[F]]<-assign((paste(fasta[[F]])),read.dna(fasta[[F]],format="fasta"))
  #names(k)[F]<-paste(fasta[F])
}

F<-1
dist<-dist.dna(k[[F]],model="K80",as.matrix=T) #ape function
dist[upper.tri(dist,diag=T)]<-NA
tree5<-bionj(dist)


plot(tree5)



nodelabels(frame="none")
tree5<-root(tree5,node=58,resolve.root=T)




#Painting branches with quantitative traits
library(phytools)


tree.map<-make.simmap(tree,match$X130to130,model="ER")
plotSimmap((tree.map),lwd=2,fsize=0.6,colors=setNames(palette()[1:4],sort(unique(match$X130to130))))
#       1        a        c        t 
"black"    "red" "green3"   "blue" 

tree.maps<-make.simmap(tree,match$X130to130,model="ER",nsim=50)
mapsum<-describe.simmap(tree.maps,plot=FALSE)

plot(mapsum,cex=c(0.3,0.3),fsize=0.6)
add.simmap.legend(colors=setNames(palette()[1:4],sort(unique(match$X130to130))),
                  prompt=FALSE,x=8,y=50)






##Painting branches
tree4<-pbtree(n=15); tree4$tip.label<-1:15
plot(tree4,font=1)
nodelabels(bg="white",cex=0.5)

tree4<-paintSubTree(tree4,node=27,state="2",stem=T)
cols<-c("blue","red","green"); names(cols)<-c(1,2,3)
plotSimmap(tree4,cols,lwd=3,pts=F)



