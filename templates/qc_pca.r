#!/usr/bin/env Rscript

f <- Sys.readlink("${evec}")
f <- "${evec}"
print(f)
evec <- read.table(f, h=T)
png("${evec.baseName}_pca.png", width=4, height=4, units="in", res=300, pointsize=9)
plot(evec[,c(3)], evec[,c(4)], pch=21, bg="lightblue", xlab="PC1", ylab="PC2")
dev.off()

