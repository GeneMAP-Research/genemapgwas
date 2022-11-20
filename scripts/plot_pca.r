#!/usr/bin/env Rscript

## ---------------------------
##
## Script name: Plot PCA
##
## Purpose of script:
##
## Author: Kevin Esoh
##
## Date Created: 2020-12-04
##
## Copyright (c) Kevin Esoh, 2020
## Email: eshkev001@myuct.ac.za
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------

###############################################################
## Function name: plot.pca()
##
## Usage: plot.pca(pop_file = , 
## 		   evec_file = , 
## 		   highlight_pop = , 
## 		   outprfx) 
## 
## pop_file = metadata file containin population for each
##	      sample. It should contain no header and must 
## 	      contain three columns of the format
## 	      FID PopName1 PopName2
##
## evec_file = file containing principal components (PCs). It 
## 	       can be any number of PCs and must have a header
##	       Column one must be named FID and contains 
##	       individual IDs. Columns 2 to column N must be
## 	       PCs and must be named PC1 PC2 PC3 ... PCN
##
## highlight_pop = The population code to highlight, e.g. YRI
## 		   It may be in either PopName1 or PopName2
## 		   It may not be provided
##
## outprfx = Prefix of the output file name
##
## Example = plot.pca(pop_file="1kgp.pop", 
## 		      evec_file="myfile.evec", 
## 		      highlight_pop="LWK", 
## 		      outprfx="myout")
##
###############################################################

plot.pca <- function(pop_file = file_with_pop_codes, 
                     evec_file = file_with_principal_comps,
		     highlight_pop = NULL,
                     outprfx = out_png_prefix, ...)
{
  fall <- paste0(outprfx,".pca.pdf")
  fpop <- paste0(outprfx, ".", highlight_pop, ".pca.pdf")

  #-- load required libraries
  #list.of.packages <- c("ggplot2", "Rcpp", "colorspace", "RColorBrewer")
  list.of.packages <- c("RColorBrewer")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) 
	  install.packages(new.packages)
  require(RColorBrewer) 
  #-- load data files
  w <-read.table(pop_file, h=F, col.names = c("FID","ETH","POP"))
  g <-read.table(evec_file, h=T)
  #w <- w[-c(2:3)] # exclude IID and SEX columns
  wg <- merge(g, w, by="FID", sort = F)
  write.table(wg, paste0(outprfx, "pca.txt"), col.names=T, row.names=F, quote=F)

  u.eth <- unique(levels(wg$ETH)) # get uniq country names as eth
  u.pop <- unique(levels(wg$POP)) # get uniq continent names as pop
  n.eth <- length(u.eth)          # count the number of countries
  n.pop <- length(u.pop)          # count the number of continents
  
  col2 <- RColorBrewer::brewer.pal(if( (n.pop==1 & n.eth==1) | (n.pop==2 & n.eth==2) ){3}
				   else if(n.pop>8){8}
				   else if(n.pop<8 & n.pop>1){n.pop}
				   else if(n.eth>8){8}
				   else if(n.eth<8 & n.eth>1){n.eth},
				   "Set1") # define color for each country

  #col2 <- RColorBrewer::brewer.pal(if(n.pop>8){8}else{n.pop}, "Set1") # define color for each continent
  
  #u.eth.col <- as.data.frame(u.eth, col1) # make table of country and their colors
  #u.col <- as.data.frame(u.pop, col2) # make table of continent and their colors
 
  if(n.pop==1 & n.eth==1){
	col1 <- rep(col2[1], n.eth)
	u.col <- as.data.frame(u.eth, col1)
        u.col$col <- rownames(u.col)
        pop_names <- levels(u.col$u.eth)[!levels(u.col$u.eth) %in% highlight_pop]
        legend_names <- c(pop_names, highlight_pop)
        legend_pch <- c(rep(20, length(u.col$u.eth[u.col$u.eth!=highlight_pop])), 3)
        legend_col <- c(u.col[u.col$u.eth!=highlight_pop,]$col,"black")
  }
  if( (n.pop==2 & n.eth<3) | (n.pop<3 & n.eth==2) ){
        col1 <- rep(col2[2], n.eth)
        u.col <- as.data.frame(u.eth, col1)
        u.col$col <- rownames(u.col)
        pop_names <- levels(u.col$u.eth)[!levels(u.col$u.eth) %in% highlight_pop]
        legend_names <- c(pop_names, highlight_pop)
        legend_pch <- c(rep(20, length(u.col$u.eth[u.col$u.eth!=highlight_pop])), 3)
        legend_col <- c(u.col[u.col$u.eth!=highlight_pop,]$col,"black")
  }
  else if(n.pop!=1 & n.eth==1){
	u.col <- as.data.frame(u.pop, col2)
        u.col$col <- rownames(u.col)
        pop_names <- levels(u.col$u.pop)[!levels(u.col$u.pop) %in% highlight_pop]
        legend_names <- c(pop_names, highlight_pop)
        legend_pch <- c(rep(20, length(u.col$u.pop[u.col$u.pop!=highlight_pop])), 3)
        legend_col <- c(u.col[u.col$u.pop!=highlight_pop,]$col,"black")
  }
  else if(n.pop==1 & n.eth!=1){
	u.col <- as.data.frame(u.eth, col2)
        u.col$col <- rownames(u.col)
        pop_names <- levels(u.col$u.eth)[!levels(u.col$u.eth) %in% highlight_pop]
        legend_names <- c(pop_names, highlight_pop)
        legend_pch <- c(rep(20, length(u.col$u.eth[u.col$u.eth!=highlight_pop])), 3)
	legend_col <- c(u.col[u.col$u.eth!=highlight_pop,]$col,"black")
  }
  else if(n.pop!=1 & n.eth!=1){
        u.col <- as.data.frame(u.pop, col2)
        u.col$col <- rownames(u.col)
        pop_names <- levels(u.col$u.pop)[!levels(u.col$u.pop) %in% highlight_pop]
        legend_names <- c(pop_names, highlight_pop)
        legend_pch <- c(rep(20, length(u.col$u.pop[u.col$u.pop!=highlight_pop])), 3)
        legend_col <- c(u.col[u.col$u.pop!=highlight_pop,]$col,"black")
  }

  #-- make column of colors
  #u.eth.col$col <- rownames(u.eth.col)
  u.col$col <- rownames(u.col)
  #write.table(u.col, "test.u.col.txt", col.names=T, row.names=F, quote=F, sep=" ")
  
  pdf(file = fall, pointsize = 14, colormodel = "cmyk")

  #layout()
  plot(wg$PC1, wg$PC2, xlab = NA, ylab = NA, type = "n", bty = "l", cex.axis=0.8)
  mtext("PC1", side = 1, cex = 0.8, line = 2)
  mtext("PC2", side = 2, cex = 0.8, line = 2)

  if (!is.null(highlight_pop) &
     class(highlight_pop) != "NULL" &
     class(highlight_pop) != "logical" &
     length(highlight_pop) != 0)
  {
     highlight_pop <- levels(as.factor(highlight_pop) )
     wg2 <- wg[wg$ETH != highlight_pop,]
     wg2 <- wg2[wg2$POP != highlight_pop,]
  } else { wg2 <- wg }

  #d <- data.frame()
  
  #-- Plot by continent/ethnicity
  if(n.pop!=1 & n.eth!=1){
	  for (pop in u.col$u.pop) {
		d <- wg2[wg2$POP==pop,]
  		points(d$PC1, d$PC2, bg = u.col$col[u.col$u.pop==pop], pch = 21, col ="black", cex = 0.6)
	  }
  }
  else if(n.pop==1 & n.eth!=1){
          for (pop in u.col$u.eth) {
                d <- wg2[wg2$ETH==pop,]
                points(d$PC1, d$PC2, bg = u.col$col[u.col$u.eth==pop], pch = 21, col = "black", cex = 0.6)
	  }
  }
  else if(n.pop!=1 & n.eth==1){
          for (pop in u.col$u.pop) {
                d <- wg2[wg2$POP==pop,]
                points(d$PC1, d$PC2, bg = u.col$col[u.col$u.pop==pop], pch = 21, col = "black", cex = 0.6)
	  }
  }
  else if(n.pop==1 & n.eth==1){
          for (pop in u.col$u.eth) {
                d <- wg2[wg2$ETH==pop,]
                points(d$PC1, d$PC2, bg = u.col$col[u.col$u.eth==pop], pch = 21, col = "black", cex = 0.6)
	  }
  }


  #-- get pop to highlight
  if (!is.null(highlight_pop) & 
      class(highlight_pop) != "NULL" & 
      class(highlight_pop) != "logical" & 
      length(highlight_pop) != 0) 
  {
      if (highlight_pop %in% wg$ETH) {
	 d <- wg[wg$ETH == highlight_pop,]
	 points(d$PC1, d$PC2, col = "black", pch = "+") 
      } else if (highlight_pop %in% wg$POP) {
         d <- wg[wg$POP == highlight_pop,]
         points(d$PC1, d$PC2, col = "black", pch = "+")
      } else { 
	      print(paste0(highlight_pop, " Could not be found in ", pop_file), quote=F)
	      print("Please check that the population is spelled correctly...", quote=F)
	      quit(save="no")
      }
  }

  legend("bottom", 
         legend = legend_names, 
         col = legend_col, 
         bty = "n", 
         pch = legend_pch,
         ncol = 2, 
         horiz = F,
         cex = 0.8)
  dev.off()

  # Single plot for highlited population
  if (!is.null(highlight_pop) &
      class(highlight_pop) != "NULL" &
      class(highlight_pop) != "logical" &
      length(highlight_pop) != 0)
  {
      if (highlight_pop %in% wg$ETH) {
	 pdf(file = fpop, pointsize = 14, colormodel = "cmyk")
            d <- wg[wg$ETH == highlight_pop,]
            plot(d$PC1, d$PC2, col = "black", pch = 20, xlab=NA, ylab=NA, cex.axis=0.7)
            mtext("PC1", side = 1, line = 2, cex = 0.8)
            mtext("PC2", side = 2, line = 2, cex = 0.8)
         dev.off()
      } else if (highlight_pop %in% wg$POP) {
	 pdf(file = fpop, pointsize = 14, colormodel = "cmyk")
            d <- wg[wg$POP == highlight_pop,]
            plot(d$PC1, d$PC2, col = "black", pch = 20, xlab=NA, ylab=NA, cex.axis=0.7)
            mtext("PC1", side = 1, line = 2, cex = 0.8)
            mtext("PC2", side = 2, line = 2, cex = 0.8)
         dev.off()
      }
  }

}

#plot.pca()
