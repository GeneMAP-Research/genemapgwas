#!/usr/bin/env bash

cat ../phased/chr{1..22}-aligned.log ../phased/chrX-aligned.log | awk '$10=="OPPOSITE_STRAND"' | cut -f4 |  sed 's/T/Q/1' | sed 's/G/R/1' | sed 's/A/T/1' | sed 's/C/G/1' | sed 's/Q/A/1' | sed 's/R/C/1' > ../phased/all-opposite-strand-ref-fixed.txt

cat ../phased/chr{1..22}-aligned.log ../phased/chrX-aligned.log | awk '$10=="OPPOSITE_STRAND"' | cut -f1-3,5 |  sed 's/T/Q/1' | sed 's/G/R/1' | sed 's/A/T/1' | sed 's/C/G/1' | sed 's/Q/A/1' | sed 's/R/C/1' > ../phased/all-opposite-strand-alt-fixed.txt

paste ../phased/all-opposite-strand-alt-fixed.txt ../phased/all-opposite-strand-ref-fixed.txt > ../phased/all-opposite-strand-fixed.txt

awk '{print $1"\t"$3"\t""0""\t"$2"\t"$4"\t"$5}' ../phased/all-opposite-strand-fixed.txt | sed 's/X/23/1' > strand-fixed.bim

cut -f2 strand-fixed.bim > strand-fixed.rsids

cat strand-fixed.rsids AW2018.clean.pheno-updated-no-MTY.at-cg.snps > strand-fixed.exclude.rsids  

plink --bfile phasing-prep --exclude strand-fixed.exclude.rsids --make-bed --out fix-strand-temp1

cat strand-fixed.bim fix-strand-temp1.bim > fix-strand-temp2.bim

#module add chpc/BIOMODULES 
#module load R/4.1.0 

Rscript -e 'bim <- read.table("fix-strand-temp2.bim", h=F); orderd_bim <- bim[order(bim$V1, bim$V4),]; write.table(orderd_bim, "strand-fixed-merged.bim", col.names=F, row.names=F, sep="\t", quote=F)'

#cp strand-fixed-merged.bim 2019-2018-GWAS-duplicate-rarevariants-removed.bim

#plink2 --bfile hbf.data-aligned-strand-fixed --glm sex --ci 0.95 --adjust --out test
