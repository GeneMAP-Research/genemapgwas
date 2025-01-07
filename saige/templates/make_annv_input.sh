#!/usr/bin/env bash

echo '##fileformat=VCFv4.2' > ${saigeResult}.vcf
echo '##Data="EMMAX top significant and suggestive hits (p-value < 1e-05)"' >> ${saigeResult}.vcf
echo '##INFO=<ID=BETA,Number=.,Type=String,Description="Effect size estimate by EMMAX">' >> ${saigeResult}.vcf
echo '##INFO=<ID=SE,Number=.,Type=String,Description="Stabdard error of effect size estimates by EMMAX">' >> ${saigeResult}.vcf
echo '##INFO=<ID=P,Number=.,Type=String,Description="P-value of association test by EMMAX (unadjusted)">' >> ${saigeResult}.vcf
echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO' >> ${saigeResult}.vcf

zcat ${saigeResult} | \
    awk '\$4 <= 5e-04' | \
    awk '{print "chr"\$5"\\t"\$6"\\t"\$1"\\t"\$8"\\t"\$7"\\t"".""\\t"".""\\t""BETA="\$2";""SE="\$3";""P="\$4}' | \
    sed 's/chr//2' | \
    sed 's/chr23/chrX/1' | \
    sed 's/chr24/chrY/1' | \
    sed 's/chr25/chrMT/1' \
    >> ${saigeResult}.vcf

bgzip -f ${saigeResult}.vcf
bcftools index -ft ${saigeResult}.vcf.gz
bcftools sort ${saigeResult}.vcf.gz
