#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: make_ann_vcf.sh [formated-emmax-result]"
else
    emm=$1
    echo '##fileformat=VCFv4.2' > ${emm}.vcf
    echo '##Data="EMMAX top significant and suggestive hits (p-value < 5e-05)"' >> ${emm}.vcf
    echo '##INFO=<ID=BETA,Number=.,Type=String,Description="Effect size estimate by EMMAX">' >> ${emm}.vcf
    echo '##INFO=<ID=SE,Number=.,Type=String,Description="Stabdard error of effect size estimates by EMMAX">' >> ${emm}.vcf
    echo '##INFO=<ID=P,Number=.,Type=String,Description="P-value of association test by EMMAX (unadjusted)">' >> ${emm}.vcf
    echo -e '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO' >> ${emm}.vcf

    zcat $emm | \
        awk '$4 <= 5e-04' | \
        awk '{print "chr"$5"\t"$6"\t"$1"\t"$8"\t"$7"\t"".""\t"".""\t""BETA="$2";""SE="$3";""P="$4}' | \
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
