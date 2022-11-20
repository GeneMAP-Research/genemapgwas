#!/usr/bin/env bash

echo '##fileformat=VCFv4.2' > ${bedName}.vcf
echo '##Data="EMMAX top significant and suggestive hits (p-value < 5e-05)"' >> ${bedName}.vcf
echo '##INFO=<ID=BETA,Number=.,Type=String,Description="Effect size estimate by EMMAX">' >> ${bedName}.vcf
echo '##INFO=<ID=SE,Number=.,Type=String,Description="Stabdard error of effect size estimates by EMMAX">' >> ${bedName}.vcf
echo '##INFO=<ID=P,Number=.,Type=String,Description="P-value of association test by EMMAX (unadjusted)">' >> ${bedName}.vcf
echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO' >> ${bedName}.vcf

zcat ${emmaxResult} | \
    awk '\$4 <= 5e-04' | \
    awk '{print "chr"\$5"\t"\$6"\t"\$1"\t"\$8"\t"\$7"\t"".""\t"".""\t""BETA="\$2";""SE="\$3";""P="\$4}' | \
    sed 's/chr//2' | \
    sed 's/chr23/chrX/1' | \
    sed 's/chr24/chrY/1' | \
    sed 's/chr25/chrMT/1' \
    >> ${bedName}.vcf

bgzip -f ${bedName}.vcf
