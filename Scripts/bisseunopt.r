##For non-split BiSSE
##Load dependencies
library(diversitree)
library(ape)
#For this analysis, we use a data file that's been made a little smaller than the 8000-taxon data set. Load it.
data <- read.csv('./Data/PyronParityData.csv', row.names=1)
# Initialize vectors. These will be used for formatting output.
output_vector <- data.frame()
ovip_root_vector <- data.frame()
vivip_root_vector <- data.frame()

#File currently set up to accept input from Make, or if trees in working directory
a<- list.files(path='./Trees/MLE/Dated/', pattern="test.*.dated", full.names=TRUE)
#Main function to fit model to each tree in BS sample
model_fit <- function(tree_list){
for (x in tree_list){
#For each tree in our vector of trees, read it in and distill down the tree to the shared tips between it and the data set
	phy <- read.tree(x)
  	phy <- multi2di(phy, random = TRUE)
	pruned.tree<-drop.tip(phy, c(setdiff(phy$tip.label, row.names(data))))
	sorteddata <- data[phy$tip.label, ]
	no_na <- na.omit(sorteddata)
	names(no_na) <- pruned.tree$tip.label
	#Make the BiSSE function
    func <- make.bisse(pruned.tree,no_na)
    func1 <- make.bisse(pruned.tree,no_na, sampling.f = .44)
    func2 <- make.bisse(pruned.tree,no_na, sampling.f = c(.44, .67))
	sp<-starting.point.bisse(pruned.tree)
	# Find MLE and use it to do ancestral state reconstruction 
	fit_bisse <- find.mle(func, sp)
	fit_bisse1 <- find.mle(func1, sp)
	fit_bisse2 <- find.mle(func1, sp)
	#Add root states to a vector of states  
	st <- asr.marginal(func, coef(fit_bisse))
	st1 <- asr.marginal(func, coef(fit_bisse1))
	st2 <- asr.marginal(func, coef(fit_bisse2))
	ovip_root_vector <- rbind(ovip_root_vector, c('Oviparity - Complete Sampling', st[,2][1]))
	vivip_root_vector <- rbind(ovip_root_vector, c('Viviparity - Complete Sampling', st[,2][2]))
	output_vector <- rbind(output_vector, c('Complete Sampling', fit_bisse$par[1:6], fit_bisse$lnLik))
	ovip_root_vector <- rbind(ovip_root_vector, c('Oviparity - One-Term Sampling', st1[,2][1]))
	vivip_root_vector <- rbind(ovip_root_vector, c('Viviparity - Complete Sampling', st1[,2][2]))
	output_vector <- rbind(output_vector, c('One-Term Sampling', fit_bisse1$par[1:6], fit_bisse1$lnLik))
	ovip_root_vector <- rbind(ovip_root_vector, c('Oviparity - Two-Term Sampling', st2[,2][1]))
	vivip_root_vector <- rbind(ovip_root_vector, c('Viviparity - Two-Term Sampling', st2[,2][2]))
	output_vector <- rbind(output_vector, c('Two-Term Sampling', fit_bisse2$par[1:6], fit_bisse2$lnLik))
	print (output_vector)
	#Plot tree
#	plot(pruned.tree, show.tip.label=F)
##	fit_plot <- nodelabels(pie=t(st), piecol=1:2, cex=.5)
	pruned.tree$node.label <- st[1,]	
	new_name <- paste('annotated', basename(x), sep = '_')
	write.tree(pruned.tree, file = new_name, append = FALSE, digits = 10, tree.names = FALSE)
	pruned.tree$node.label <- st1[1,]	
	new_name <- paste('annotated_1', basename(x), sep = '_')
	write.tree(pruned.tree, file = new_name, append = FALSE, digits = 10, tree.names = FALSE)
	pruned.tree$node.label <- st2[1,]	
	new_name <- paste('annotated_2', basename(x), sep = '_')
	write.tree(pruned.tree, file = new_name, append = FALSE, digits = 10, tree.names = FALSE)
	#Output various parameters: the model and ancestral states 
}


	write.csv(output_vector, file = "unoptimized_model_params.csv", col.names = FALSE, sep = ",")
	write.csv(ovip_root_vector, file = "unoptimized_ovip_support.csv", col.names = FALSE, sep = ",")
	write.csv(vivip_root_vector, file = "unoptimized_vivip_support.csv", col.names = FALSE, sep = ",")
}

#Call the function if you want
model_fit(a)

