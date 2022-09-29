#!/usr/bin/env bash

#HR	POS	MarkerID	Allele1	Allele2	AC_Allele2	AF_Allele2	imputationInfo	BETA	SE	Tstat	var	p.value	N

if [ $# -lt 1 ]; then
    echo "Usage: make_ann_vcf.sh [saige-result]"
else
    emm=$1
    echo '##fileformat=VCFv4.2' > ${emm}.annvar.vcf
    echo '##Data="SAIGE association results top significant and suggestive hits (p-value < 5e-04)"' >> ${emm}.annvar.vcf
    echo '##INFO=<ID=AF,Number=.,Type=String,Description="Allele frequency of Allele2">' >> ${emm}.annvar.vcf
    echo '##INFO=<ID=R2,Number=.,Type=String,Description="Impute info (R^2)">' >> ${emm}.annvar.vcf
    echo '##INFO=<ID=N,Number=.,Type=String,Description="Sample Size">' >> ${emm}.annvar.vcf
    echo '##INFO=<ID=BETA,Number=.,Type=String,Description="Effect size estimate">' >> ${emm}.annvar.vcf
    echo '##INFO=<ID=SE,Number=.,Type=String,Description="Standard error of efefct size estimate">' >> ${emm}.annvar.vcf
    echo '##INFO=<ID=P,Number=.,Type=String,Description="P-value of association test (unadjusted)">' >> ${emm}.annvar.vcf
    echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO' >> ${emm}.annvar.vcf

    zcat $emm | \
        awk '$13 <= 5e-04' | \
        awk '{print "chr"$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"".""\t"".""\t""AF="$7";""R2="$8";"";""N="$14";""BETA="$9";""SE="$10";""P="$13}' | \
        sed 's/chr//2' | \
        sed 's/chr23/chrX/1' | \
        sed 's/chr24/chrY/1' | \
        sed 's/chr25/chrMT/1' | 
        sort -V -k1 -k2 \
        >> ${emm}.annvar.vcf
    bgzip -f ${emm}.annvar.vcf
    bcftools index -ft ${emm}.annvar.vcf.gz
    bcftools sort ${emm}.annvar.vcf.gz -Oz -o ${emm}.annvar.vcf.gz
fi
