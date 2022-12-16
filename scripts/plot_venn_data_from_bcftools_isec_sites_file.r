#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args) < 3) {
   message("\nUsage: plot_venn_data_from_bcftools_isec_sites_file.r [venn data] [print mode <raw/percent>] [output prefix]\n")
   quit(save="no")
} else {
   
   
   if(!require(VennDiagram)) {install.packages("VennDiagram")}
   if(!require(sos)) {install.packages("sos")}
   if(!require(RColorBrewer)) {install.packages("RColorBrewer")}
   
   myCol <- brewer.pal(5, "Pastel2")
   myCol_b <- brewer.pal(6, "Pastel2")
   
   f <- args[1]

   prntmd <- args[2]
   if(prntmd == "raw") { 
      plt.cex <- 0.5 
   } else { 
      plt.cex <- c(1.2, 1.2, 1.2, 1.2, 1.2, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8,
                  0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.8, 0.8, 0.8, 0.8, 1.2)
   }

   out <- paste0(args[3], "_hg19_imputation_panels_venn.svg")
   
   sites <- read.table(f, h=T, quote="")
   
   
   sites$panel <- as.factor(sites$panel)
   
   
   # -- get counts
   allintersects <- (sites$snpcount[sites$panel == "custom_h3a_sanger_caapa_kgp"])
   
   allcustom <- (sum(grepFn(pattern="custom", x=sites, column="panel")$snpcount)) 
   allh3a <- (sum(grepFn(pattern="h3a", x=sites, column="panel")$snpcount))
   allsanger <- (sum(grepFn(pattern="sanger", x=sites, column="panel")$snpcount))
   allcaapa <- (sum(grepFn(pattern="caapa", x=sites, column="panel")$snpcount))
   allkgp <- (sum(grepFn(pattern="kgp", x=sites, column="panel")$snpcount))
   
   allcustomh3a <- (sum(grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
   allcustomsanger <- (sum(grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
   allcustomcaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
   allcustomkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
   allh3asanger <- (sum(grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel")$snpcount))
   allh3acaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel")$snpcount))
   allh3akgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel")$snpcount))
   allsangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=sites, column="panel"), column="panel")$snpcount))
   allsangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=sites, column="panel"), column="panel")$snpcount))
   allcaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=sites, column="panel"), column="panel")$snpcount))
   
   allcustomh3asanger <- (sum(grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allcustomh3acaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allcustomh3akgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allcustomsangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allcustomsangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allcustomcaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allh3asangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allh3asangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allh3acaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   allsangercaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
   
   allcustomh3asangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
   allcustomh3asangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
   allcustomh3acaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
   allcustomsangercaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
   allh3asangercaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
   
   #png("hg19_imputation_panels_venn.png", height = 840, width = 840, units = "px", res = NA, pointsize = 24)
   svg(out, height=14, width=14, pointsize = 24)
   par(mfrow=c(2,1))
   venn.plot <- draw.quintuple.venn(
                  allcustom, 
                  allh3a, 
                  allsanger, 
                  allcaapa,
                  allkgp,
                  allcustomh3a,
                  allcustomsanger,
                  allcustomcaapa,
                  allcustomkgp,
                  allh3asanger,
                  allh3acaapa,
                  allh3akgp,
                  allsangercaapa,
                  allsangerkgp,
                  allcaapakgp,
                  allcustomh3asanger,
                  allcustomh3acaapa,
                  allcustomh3akgp,
                  allcustomsangercaapa,
                  allcustomsangerkgp,
                  allcustomcaapakgp,
                  allh3asangercaapa,
                  allh3asangerkgp,
                  allh3acaapakgp,
                  allsangercaapakgp,
                  allcustomh3asangercaapa,
                  allcustomh3asangerkgp,
                  allcustomh3acaapakgp,
                  allcustomsangercaapakgp,
                  allh3asangercaapakgp,
                  allintersects,
                  category = c("CUSTOM", "H3A", "SANGER", "CAAPA", "KGP"),
                  fill = c("dodgerblue", "goldenrod1", "darkorange1", "seagreen3", "orchid3"),
                  cat.col = c("dodgerblue", "goldenrod1", "darkorange1", "seagreen3", "orchid3"),
                  cat.cex = 0.9,
                  margin = 0.05,
                  print.mode = prntmd,
                  sigdigs = 2,
                  cex = plt.cex,
                  ind = TRUE
               );
   
   grid.draw(venn.plot);
   dev.off()
}

#                  cex = c(1.2, 1.2, 1.2, 1.2, 1.2, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8,
#                  0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.8, 0.8, 0.8, 0.8, 1.2),

