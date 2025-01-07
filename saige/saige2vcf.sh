#!/usr/bin/env bash

# CHR	POS	MarkerID	Allele1	Allele2	AC_Allele2	AF_Allele2	imputationInfo	BETA	SE	Tstat	var	p.value	N

if [ $# -lt 1 ]; then
    echo "Usage: saige2vcf.sh [saige-result]"
else
    emm=$1
    echo '##fileformat=VCFv4.2' > ${emm}.vcf
    echo '##Data="SAIGE associaiton results"' >> ${emm}.vcf
    echo '##INFO=<ID=A1,Number=.,Type=String,Description="Allele1">' >> ${emm}.vcf
    echo '##INFO=<ID=A2,Number=.,Type=String,Description="Allele2">' >> ${emm}.vcf
    echo '##INFO=<ID=A2C,Number=.,Type=String,Description="Allele2 count">' >> ${emm}.vcf
    echo '##INFO=<ID=A2F,Number=.,Type=String,Description="Allele2 frequency">' >> ${emm}.vcf
    echo '##INFO=<ID=R2,Number=.,Type=String,Description="Imputation info (for imputed data), Missing rate for non-imputed data">' >> ${emm}.vcf
    echo '##INFO=<ID=BETA,Number=.,Type=String,Description="Effect size estimate">' >> ${emm}.vcf
    echo '##INFO=<ID=SE,Number=.,Type=String,Description="Stabdard error of effect size estimate">' >> ${emm}.vcf
    echo '##INFO=<ID=Tstat,Number=.,Type=String,Description="T statistic">' >> ${emm}.vcf
    echo '##INFO=<ID=var,Number=.,Type=String,Description="Variance">' >> ${emm}.vcf
    echo '##INFO=<ID=P,Number=.,Type=String,Description="P-value of association test by EMMAX (unadjusted)">' >> ${emm}.vcf
    echo '##INFO=<ID=N,Number=.,Type=String,Description="Sample size">' >> ${emm}.vcf
    echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO' >> ${emm}.vcf


# "A1"=$4";""A2"=$5";""A2C"=$6";""A2F"=$7";""R2"=$8";""BETA"=$9";""SE"=$10";""Tstat"=$11";""var"=$12";""P"=$13";""N"=$14

    zcat $emm | \
        sed '1d' | \
        sort -V -k1 -k2 | \
        awk '{print "chr"$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"".""\t"".""\t""A1="$4";""A2="$5";""A2C="$6";""A2F="$7";""R2="$8";""BETA="$9";""SE="$10";""Tstat="$11";""var="$12";""P="$13";""N="$14}' | \
        sed 's/chr23/chrX/1' | \
        sed 's/chr24/chrY/1' | \
        sed 's/chr25/chrMT/1' | \
        sed 's/chr//2' \
        >> ${emm}.vcf
    bgzip -f ${emm}.vcf
    bcftools index -ft ${emm}.vcf.gz --threads 24
    bcftools sort ${emm}.vcf.gz -Oz -o ${emm}.vcf.gz

#    awk '\$4 <= 5e-05' "${inputDir}/emmax/${params.tpedPrefix}.ps" | \
#        awk '{print "chr"\$1,\$2,\$3,\$4}' | \
#        sed 's/:/\\t/g' | \
#        sed 's/_/\\t/g' | \
#        awk '{print \$1"\\t"\$2"\\t"".""\\t"\$3"\\t"\$4"\\t"\$5"\\t"\$6"\\t"\$7}' | \
#        sed 's/chr//2' \
#        >> ${emm/.ps*/.vcf}
#    gzip -f ${emm/.ps*/.vcf}
fi
