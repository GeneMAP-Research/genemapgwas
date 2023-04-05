#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args)<4) {
   print("usage: ./imput_accuracy.r [AF binsize] [imputation metric file] [output prefix] [threads]", quote=F)
   print("Metric file format: Four columns; chr maf r2 panel", quote=F)
   quit(save="no")
} else {

     list.of.packages <- c("data.table", "RColorBrewer")
     new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
     if(length(new.packages)) {
           install.packages(new.packages, repos="https://cloud.r-project.org", ask=F)
     }
     require(RColorBrewer)
     require(data.table)
     #require(gplots) #uncomment to plot heatmap.2

     binsize <- as.numeric(args[1])
     metricfile <- args[2]
     outprefix <- args[3]
     threads <- as.numeric(args[4])
     outpng <- paste0(outprefix, "_imputation_accuracy.png")
     outsvg <- paste0(outprefix, "_imputation_accuracy.svg")

     f <- fread(metricfile, h=T, data.table=F, nThread=threads)
     print(head(f))
     panels <- levels(unique(as.factor(f$panel)))
     #max.maf <- round(max(f$maf)+0.05, 1)
     max.maf <- max(f$maf)
     min.maf <- min(f$maf)
     print(max.maf)
     print(min.maf)
     bin <- seq(from=0.00, to=max.maf, by=binsize)


     #panels <- c("CUSTOM", "H3A", "AGR", "CAAPA", "TGP", "TOPMed"),
     colors <- c("dodgerblue", "lightblue", "darkolivegreen", "darkorange1", "seagreen3", "orchid3")
     colors <- sample(colors, length(panels), replace=F)
     colors <- c("lightblue", "orchid3", "seagreen3", "darkolivegreen")
     #colors <- RColorBrewer::brewer.pal(length(panels), "Dark2")
     panel_colors <- as.data.frame(panels, colors)
     panel_colors$col <- rownames(panel_colors)
     colnames(panel_colors) <- c("panel","col")

     mean.chrom.metric.res <- data.frame()

     #png(outpng, width=20, height=19, units="cm", res=300, points=12)
     svg(outsvg, width=8, height=8, pointsize=16)
     plot(1, xlim=c(min.maf, max.maf), ylim=c(0.75, 1), xlab=paste0("MAF bin: binsize = ", binsize), ylab="Mean imputation accuracy", type="l", lty=3)
     for(panel in 1:length(panels)) {
	 panel_metrics <- f[f$panel==panels[panel],]
	 chrom <- levels(unique(as.factor(panel_metrics$chr)))
         number_of_chr <- length(chrom)
         print(paste0("Panel: ", panels[panel]), quote=F)
         print(paste0("Number of chromosomes: ", number_of_chr), quote=F)
     

	 # prepare place holders for metric results
         panel.res <- as.data.frame(c(bin))
         colnames(panel.res) <- c("mafbin")
         mean.chrom.metric <- as.data.frame(c(panels[panel]))
         colnames(mean.chrom.metric) <- c("panel")

         for (chr in 1:length(chrom)) {
           frqbins <- as.data.frame(bin)
           vc <- c(0)
           per_chrom_metric <- panel_metrics[panel_metrics$chr==chrom[chr],]

           for(bindex in 1:(length(bin)-1)) {
               vc[bindex+1] <- (sum(per_chrom_metric$r2[per_chrom_metric$maf >= bin[bindex] & per_chrom_metric$maf < bin[(bindex+1)]])/length(per_chrom_metric$r2[per_chrom_metric$maf >= bin[bindex] & per_chrom_metric$maf < bin[(bindex+1)]]))
           }
           frqbins[,chrom[chr]] <- vc
           frqbins_column_names <- c("maf")
           frqbins_column_names[2] <- paste0("chr", chrom[chr])
           colnames(frqbins) <- frqbins_column_names
           print(paste0("Plotting chr", chrom[chr], " ..."), quote=F)
           lines(frqbins$maf, frqbins[,paste0("chr", chrom[chr])], lty=2, lwd=2, col=panel_colors$col[panel_colors$panel==panels[panel]])
           panel.res <- cbind(panel.res, frqbins[2])
	   mean.chrom.metric.combined <- as.data.frame(mean(per_chrom_metric$r2, na.rm = T))
	   colnames(mean.chrom.metric.combined) <- paste0("chr", chrom[chr])
           mean.chrom.metric <- data.frame(mean.chrom.metric, mean.chrom.metric.combined)
         }
	 write.table(panel.res, paste0(panels[panel],"_r2_mafbins.txt"), col.names=T, row.names=F, sep=" ", quote=F)

	 mean.chrom.metric.res <- rbind(mean.chrom.metric.res, mean.chrom.metric)

     }
     legend("bottomright", legend=panel_colors$panel, col=panel_colors$col, pch="---", bty='n', cex = 1.2, lty=2, lwd=3)
     dev.off()

     write.table(mean.chrom.metric.res, "mean_per_chrom_r2.txt", col.names=T, row.names=F, sep=" ", quote=F)





     svg("mean_per_chrom_r2.svg", height=7.5, width=8, pointsize=16)
     par(lab=c(22,10,1), cex.axis=0.6)
     plot(x=1, y=1, xlim=c(1, length(names(mean.chrom.metric.res))-1), ylim=c(0.65, 1), type="n", xlab="", ylab="")
     for(panel in panel_colors$panel) {
	 d <- mean.chrom.metric.res[mean.chrom.metric.res$panel==panel,]
         rownames(d) <- d[,1]
	 d[,1] <- NULL
         d <- as.data.frame(t(d))
	 chr_names <- rownames(d)
	 d$chr <- as.numeric(sub("chr", "", rownames(d)))
         points(d[,2], d[,1], type="o", pch=21, bg=panel_colors$col[panel_colors$panel==panel])
     }
     legend("bottom", legend=panel_colors$panel, pt.bg=panel_colors$col, pch=21, bty='n', ncol=3, lty=1, cex=1.2)
     mtext(text="Chromosome", side=1, line=2.5, cex=0.9)
     mtext(text="Mean imputation accuracy", side=2, line=2.5, cex=0.9)

     print(panel_colors)
     #-- Alternate visualization of per chr mean r2 (heatmap)
     #rownames(mean.chrom.metric.res) <- mean.chrom.metric.res[,1]
     #mean.chrom.metric.res.mat <- as.matrix(mean.chrom.metric.res[,-c(1)])
     #distance = dist(mean.chrom.metric.res.mat, method = "manhattan")
     #cluster = hclust(distance, method = "ward.D")
     #svg("mean_per_chrom_r2.svg")
     #heatmap.2(mean.chrom.metric.res.mat, density.info="none", trace="none", key.title=NA, Rowv=as.dendrogram(cluster),  Colv=as.dendrogram(cluster))

     dev.off()
}
warnings()
