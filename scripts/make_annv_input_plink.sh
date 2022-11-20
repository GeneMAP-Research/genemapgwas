#!/usr/bin/env bash

#CHROM	POS	ID	REF	ALT	A1	TEST	OBS_CT	BETA	SE	L95	U95	T_STAT	P	ERRCODE

if [ $# -lt 1 ]; then
    echo "Usage: make_annv_input_plink.sh [plink-unadjusted-result]"
else
    emm=$1
    echo '##fileformat=VCFv4.2' > ${emm}.vcf
    echo '##Data="PLINK top significant and suggestive hits (p-value < 5e-05)"' >> ${emm}.vcf
    echo '##INFO=<ID=TEST,Number=.,Type=String,Description="Test model used (ADD = additive; DOM = dominant; HET = heterozygote etc)">' >> ${emm}.vcf
    echo '##INFO=<ID=BETA,Number=.,Type=String,Description="Effect size estimate by PLINK">' >> ${emm}.vcf
    echo '##INFO=<ID=SE,Number=.,Type=String,Description="Stabdard error of effect size estimates by PLINK">' >> ${emm}.vcf
    echo '##INFO=<ID=P,Number=.,Type=String,Description="P-value of association test by PLINK (unadjusted)">' >> ${emm}.vcf
    echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO' >> ${emm}.vcf

    cat $emm | \
        awk '$14 <= 5e-04' | \
        awk '{print "chr"$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"".""\t"".""\t""TEST="$7";""BETA="$9";""SE="$10";""P="$14}' | \
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
