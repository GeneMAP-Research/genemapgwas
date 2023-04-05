#!/usr/bin/env bash

#CHROM	POS	ID	REF	ALT	A1	TEST	OBS_CT	BETA	SE	L95	U95	T_STAT	P	ERRCODE

#CHROM	POS	ID	REF	ALT	A1	AX	A1_CT	A1_FREQ	TEST	OBS_CT	BETA	SE	L95	U95	T_STAT	P	ERRCODE

# "A1="$6      AX      A1_CT   A1_FREQ TEST    OBS_CT  BETA    SE      L95     U95     T_STAT  P       ERRCODE

if [ $# -lt 1 ]; then
    echo "Usage: make_annv_input_plink.sh [plink-unadjusted-result]"
else
    emm=$1
    echo '##fileformat=VCFv4.2' > ${emm}.vcf
    echo '##Data="PLINK top significant and suggestive hits (p-value < 5e-05)"' >> ${emm}.vcf
    echo '##INFO=<ID=A1,Number=.,Type=String,Description="Effect/tested allele">' >> ${emm}.vcf
    echo '##INFO=<ID=AX,Number=.,Type=String,Description="Other allele">' >> ${emm}.vcf
    echo '##INFO=<ID=AC,Number=.,Type=Float,Description="A1 count">' >> ${emm}.vcf
    echo '##INFO=<ID=AF,Number=.,Type=Float,Description="A1 frequency">' >> ${emm}.vcf
    echo '##INFO=<ID=TEST,Number=.,Type=String,Description="Test model used (ADD = additive; DOM = dominant; HET = heterozygote etc)">' >> ${emm}.vcf
    echo '##INFO=<ID=N,Number=.,Type=Float,Description="Sample size">' >> ${emm}.vcf
    echo '##INFO=<ID=BETA,Number=.,Type=String,Description="Effect size estimate by PLINK">' >> ${emm}.vcf
    echo '##INFO=<ID=SE,Number=.,Type=String,Description="Stabdard error of effect size estimates by PLINK">' >> ${emm}.vcf
    echo '##INFO=<ID=L95,Number=.,Type=String,Description="Stabdard error lower 95% confidence interval bound">' >> ${emm}.vcf
    echo '##INFO=<ID=U95,Number=.,Type=String,Description="Stabdard error upper 95% confidence interval bound">' >> ${emm}.vcf
    echo '##INFO=<ID=TSTAT,Number=.,Type=String,Description="Test statistic">' >> ${emm}.vcf
    echo '##INFO=<ID=P,Number=.,Type=String,Description="P-value of association test by PLINK (unadjusted)">' >> ${emm}.vcf
    echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO' >> ${emm}.vcf

    cat $emm | \
        awk '$17 <= 5e-04' | \
        awk '{print "chr"$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"".""\t"".""\t""A1="$6";""AX="$7";""AC="$8";""AF="$9";""TEST="$10";""N="$11";""BETA="$12";""SE="$13";""L95="$14";""U95="$15";""TSTAT="$16";""P="$17}' | \
        sed 's/chr//2' | \
        sed 's/chr23/chrX/1' | \
        sed 's/chr24/chrY/1' | \
        sed 's/chr25/chrMT/1' \
        >> ${emm}.vcf
    bgzip -f ${emm}.vcf
    bcftools index -ft ${emm}.vcf.gz
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
