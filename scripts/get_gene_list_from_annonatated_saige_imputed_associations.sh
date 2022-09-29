#!/usr/bin/env bash

#AF=0.117291;R2=1;N=827;BETA=0.132578;SE=0.0359241;P=0.000223807
# \t%INFO/AF\t%INFO/R2\t%INFO/N

if [ $# -lt 1 ]; then
    echo "Usage: get_annotated_emmax_result.sh [annovar-annotated-saige-result-vcf-file]"
    echo "NB: The annotated VCF must be bgzipped and indexed."
else
    ann=$1
    #bcftools \
    #    query -f '%CHROM\t%POS\t%CHROM:%POS\t%INFO/avsnp150\t%REF\t%ALT\t%BETA\t%SE\t%P\t%Gene.refGene\t%Gene.knownGene\n' $ann | \
    #    sed 's/chr//2' | \
    #    sed 's/\\x3b/-/g' | \
    #    sed '1 i CHR\tBP\tCHR:POS\tSNP\tREF\tALT\tBETA\tSE\tP\trefGene\tknownGene' > ${ann/.hg*_multianno*.vcf.gz/.emmax.txt}
    #    #sort -g -k9 > ${ann/.hg*_multianno*.vcf.gz/.emmax.txt}
    #sed 's/\t/,/g' ${ann/.hg*_multianno*.vcf.gz/.emmax.txt}  > ${ann/.hg*_multianno*.vcf.gz/.emmax.csv}

    bcftools \
        query \
        -f '%CHROM\t%POS\t%CHROM:%POS\t%ID\t%REF/%ALT\t%INFO/AF\t%INFO/R2\t%INFO/N\t%INFO/BETA\t%INFO/SE\t%INFO/P\t%INFO/Gene.refGene\t%INFO/Gene.knownGene\n' \
        ${ann} | \
        sed 's/chr//2' | \
        sed '1 i CHR\tBP\tCHR:POS\tSNPID\tREF/ALT\tAF\tImputationInfo\tSAMPLESIZE\tBETA\tSE\tP\trefGene\tknownGene' | \
        sed 's|\\x3b|-|g' | \
        tee ${ann}.tsv | \
        sed 's/\t/,/g' \
        > ${ann}.csv
fi
