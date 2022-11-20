#!/usr/bin/env Rscript

adm <- read.table("cm_phased_pruned.3.Q.txt", h=F, col.names=c("FID","PO","P1","P2"))
rownames(adm) <- adm$FID
adm.dist <- dist(adm[,-c(1)])
adm.hclust <- hclust(adm.dist, method="ward.D2")
cluster3 <- factor(cutree(adm.hclust, 3))
cluster3.df <- as.data.frame(cluster3)
cluster3.df$sample <- rownames(cluster3.df)
colnames(cluster3.df) <- c("cluster","sample")
write.table(cluster3.df, "hclusters.txt", col.names=T, row.names=F, quote=F, sep=" ")

plot(adm.hclust)
rect.hclust(adm.hclust, k=3)
rect.hclust(adm.hclust, k=3, which = c(1, 3))
rect.hclust(adm.hclust, k=3, which = c(1, 3), border = 3:4)
