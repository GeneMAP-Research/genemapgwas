#!/usr/bin/env bash

plink2 \
  --adjust \
  --bfile ${bedPrefix} \
  --ci 0.95 \
  --covar ${params.plinkCovarFile} \
  --covar-name ${params.plinkCovarName} \
  --glm sex hide-covar genotypic \
  --quantile-normalize \
  --out ${params.outputPrefix}.geno \
  --threads ${task.cpus}

cat ${params.outputPrefix}.geno.PHENO1.glm.linear | \
    grep -v -e NA -e CHROM | \
    cut -f1-5,9-12,14 | \
    sed '1 i CHR\tPOS\tID\tREF\tALT\tBETA\tSE\tL95\tU95\tP' | \
    gzip -c > "${params.outputPrefix}.geno.PHENO1.glm.linear.txt.gz"

# karyoploteR input: for manhattan plots in R
sed '1d' ${params.outputPrefix}.geno.PHENO1.glm.linear | \
    awk '{print "chr"$1,$2,$3,$14}' | \
    sed '1 i chr pos rsid pval' | \
    gzip -c > "${params.outputPrefix}.geno.karyoploter.txt.gz"

gzip ${params.outputPrefix}.geno.PHENO1.glm.linear.adjusted
