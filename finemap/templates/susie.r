#!/usr/bin/Rscript

library(susieR)
data(N3finemapping)
attach(N3finemapping)
write.table(as.data.frame(X), "x.txt")
R <- cor(X)
write.table(as.data.frame(R), "corelation_matrix_of_X.txt")
b <- true_coef[,1]
png("test_susie.png")
plot(b, pch=20, ylab='effect size')
dev.off()
