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
                     outprfx = out_png_prefix)
{
  fall_pdf <- paste0(outprfx,".pca.pdf")
  fall_png <- paste0(outprfx,".pca.png")
  fpop <- paste0(outprfx, ".", highlight_pop, ".pca.pdf")

  #-- load required libraries
  require(RColorBrewer) 
  #require(gtools) # check odd even

  #-- load data files
  w <-read.table(pop_file, h=F, col.names = c("FID","ETH","POP"))
  g <-read.table(evec_file, h=T)
  #w <- w[-c(2:3)] # exclude IID and SEX columns
  wg <- merge(g, w, by="FID", sort = F)
  write.table(wg, paste0(outprfx, "pca.txt"), col.names=T, row.names=F, quote=F)

  u.eth <- as.character(unique(levels(as.factor(wg\$ETH)))) # get uniq country names as eth
  u.pop <- as.character(unique(levels(as.factor(wg\$POP)))) # get uniq continent names as pop
  n.eth <- length(u.eth)          # count the number of countries
  n.pop <- length(u.pop)          # count the number of continents
 
  col2 <- RColorBrewer::brewer.pal(
            if( n.pop<3 && n.eth<3 ) {3}
            else if( n.eth<12 && n.pop<12 ) {
              if( n.eth > n.pop ) {
                n.eth
              } else { 
                n.pop 
              }
            }
            else {12},
            "Set3"
          )

#  col2 <- as.character(rev(col2[2:(length(col2)+1),]))
#  print(col2)
#  print(u.eth)
#  print(u.pop)
#  print(data.frame(u.pop, col2))
 
  if( n.pop==1 && n.eth==1){
	col1 <- rep(col2[5], n.eth)	# get one color and replicate it by the number of ethnicities
	u.col <- as.data.frame(u.eth, col1)
        print(u.col)
  }

  if( (n.pop==2 && n.eth<3) || (n.pop<3 && n.eth==2) ) {
        col1 <- rep(col2[3:4], n.eth)
        u.col <- as.data.frame(u.eth, col1)
        print(u.col)
  }
  else if(n.pop!=1 && n.eth==1){
	u.col <- as.data.frame(u.pop, col2)
        print(u.col)
  }
  else if(n.pop==1 && n.eth!=1){
	u.col <- as.data.frame(u.eth, col2)
        print(u.col)
  }
  else if(n.pop!=1 && n.eth!=1){
        u.col <- data.frame(u.pop, col2)
        print(u.col)
  }

  #-- make column of colors
  u.col\$col <- rownames(u.col)


  # testing new coloring scheme
  col2 <- RColorBrewer::brewer.pal(12, "Set3")
  u.col.eth <- sample(col2, size=length(u.eth), replace=T) # get colors for ethnicity plotting
  col.eth <- data.frame(u.eth, u.col.eth)
  colnames(col.eth) <- c("eth", "col")

  u.col.pop <- sample(col2, size=length(u.pop), replace=F) # get colors for ancestry plotting
  col.pop <- data.frame(u.pop, u.col.pop)
  colnames(col.pop) <- c("pop", "col")


  # plot and color by ethnicity
  pdf(file = fall_pdf, pointsize = 14, colormodel = "cmyk")
  #png(fall_png, height = 10, width = 8, units = "cm", res = 300, pointsize = 10)

  # Splitting the device into two row-wise panels, and start plotting from the top panel
  layout(
    matrix(data=c(2,1), 
    nrow=2, 
    ncol=1, 
    byrow=T)
  )

  par(
    fig=c(0, 1, 0.15, 1), 
    mar=c(3,4,1,1)
  )

  # Adding a grid box to the top plot panel
  plot.new()
  grid(
    nx=6, 
    ny=6, 
    lwd=1
  )

  par(
    mar=c(3,4,1,1), 
    new=T, 
    las=1
  )

  plot(
    wg\$PC1, 
    wg\$PC2, 
    xlab = NA, 
    ylab = NA, 
    type = "n", 
    bty = "l", 
    cex.axis=0.8
  )

  mtext("PC1", side = 1, cex = 0.8, line = 2)
  mtext("PC2", side = 2, cex = 0.8, line = 2)

  #-- Plot by continent/ethnicity
  if(n.pop!=1 && n.eth!=1){
	  for (pop in u.col\$u.pop) {
		d <- wg[wg\$POP==pop,]
  		points(d\$PC1, d\$PC2, bg = u.col\$col[u.col\$u.pop==pop], pch = 21, col ="black", cex = 0.8)
	  }
  }
  else if(n.pop==1 && n.eth!=1){
          for (pop in u.col\$u.eth) {
                d <- wg[wg\$ETH==pop,]
                points(d\$PC1, d\$PC2, bg = u.col\$col[u.col\$u.eth==pop], pch = 21, col = "black", cex = 0.8)
	  }
  }
  else if(n.pop!=1 && n.eth==1){
          for (pop in u.col\$u.pop) {
                d <- wg[wg\$POP==pop,]
                points(d\$PC1, d\$PC2, bg = u.col\$col[u.col\$u.pop==pop], pch = 21, col = "black", cex = 0.8)
	  }
  }
  else if(n.pop==1 && n.eth==1){
          for (pop in u.col\$u.eth) {
                d <- wg[wg\$ETH==pop,]
                points(d\$PC1, d\$PC2, bg = u.col\$col[u.col\$u.eth==pop], pch = 21, col = "black", cex = 0.8)
	  }
  }


  #-- get pop to highlight
  if (!is.null(highlight_pop) && 
      class(highlight_pop) != "NULL" && 
      class(highlight_pop) != "logical" && 
      length(highlight_pop) != 0) 
  {
      if (highlight_pop %in% wg\$ETH) {
	 d <- wg[wg\$ETH == highlight_pop,]
	 points(d\$PC1, d\$PC2, bg = "azure4", pch = 21, cex = 0.8) 
      } else if (highlight_pop %in% wg\$POP) {
         d <- wg[wg\$POP == highlight_pop,]
         points(d\$PC1, d\$PC2, bg = "azure4", pch = 21, cex = 0.8)
      } else { 
	      print(paste0(highlight_pop, " Could not be found in ", pop_file), quote=F)
	      print("Please check that the population is spelled correctly...", quote=F)
	      quit(save="no")
      }
  }


  # Adding legend in lower panel outside of the plot
  par(fig=c(0, 1, 0, 0.15), mar=c(2,2,1,2), new=T)
  plot.new()

  if(n.pop==1 && n.eth==1){
     legend("center",
         legend = c(levels(as.factor(u.col\$u.eth)),highlight_pop),
         col = c(u.col\$col,"azure4"),
         bty = "n",
         pch = 20,
         ncol = 6,
         horiz = F,
         cex = 0.8)
  }
  if( (n.pop==2 && n.eth<3) || (n.pop<3 && n.eth==2) ){
     legend("center",
         legend = c(levels(as.factor(u.col\$u.eth)),highlight_pop),
         col = c(u.col\$col,"azure4"),
         bty = "n",
         pch = 20,
         ncol = 6,
         horiz = F,
         cex = 0.8)
  }
  else if(n.pop!=1 && n.eth==1){
     legend("center",
         legend = c(levels(as.factor(u.col\$u.pop)),highlight_pop),
         col = c(u.col\$col,"azure4"),
         bty = "n",
         pch = 20,
         ncol = 6,
         horiz = F,
         cex = 0.8)
  }
  else if(n.pop==1 && n.eth!=1){
     legend("center",
         legend = c(levels(as.factor(u.col\$u.eth)),highlight_pop),
         col = c(u.col\$col,"azure4"),
         bty = "n",
         pch = 20,
         ncol = 6,
         horiz = F,
         cex = 0.8)
  }
  else if(n.pop!=1 && n.eth!=1){
     legend("center",
         legend = c(levels(as.factor(u.col\$u.pop)),highlight_pop),
         col = c(u.col\$col,"azure4"),
         bty = "n",
         pch = 20,
         ncol = 6,
         horiz = F,
         cex = 0.8)
  }

  dev.off()

  # Single plot for highlited population
  if (!is.null(highlight_pop) &&
      class(highlight_pop) != "NULL" &&
      class(highlight_pop) != "logical" &&
      length(highlight_pop) != 0)
  {
      if (highlight_pop %in% wg\$ETH) {
	 pdf(file = fpop, pointsize = 14, colormodel = "cmyk")
            d <- wg[wg\$ETH == highlight_pop,]
            plot(d\$PC1, d\$PC2, col = "azure4", pch = 20, xlab=NA, ylab=NA, cex.axis=0.7)
            mtext("PC1", side = 1, line = 2, cex = 0.8)
            mtext("PC2", side = 2, line = 2, cex = 0.8)
         dev.off()
      } else if (highlight_pop %in% wg\$POP) {
	 pdf(file = fpop, pointsize = 14, colormodel = "cmyk")
            d <- wg[wg\$POP == highlight_pop,]
            plot(d\$PC1, d\$PC2, col = "azure4", pch = 20, xlab=NA, ylab=NA, cex.axis=0.7)
            mtext("PC1", side = 1, line = 2, cex = 0.8)
            mtext("PC2", side = 2, line = 2, cex = 0.8)
         dev.off()
      }
  }

}

plot.pca(
  pop_file = "${popfile}", 
  evec_file = "${pcs}", 
  highlight_pop = ifelse("${params.highlight_pop}" != "", "${params.highlight_pop}", NULL), 
  outprfx = "${params.output_prefix}"
)

#plot.pca()
