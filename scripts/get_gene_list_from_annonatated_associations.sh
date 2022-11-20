#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: get_annotated_emmax_result.sh [annotated-annovar-vcf-file]"
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
        -f '%CHROM\t%POS\t%CHROM:%POS\t%ID\t%REF/%ALT\t%INFO/BETA\t%INFO/SE\t%INFO/P\t%INFO/Gene.refGene\t%INFO/Gene.knownGene\n' \
        ${ann} | \
        sed 's/chr//2' | \
        sed '1 i CHR\tBP\tCHR:POS\tSNPID\tREF/ALT\tBETA\tSE\tP\trefGene\tknownGene' | \
        sed 's|\\x3b|-|g' | \
        tee ${ann}.tsv | \
        sed 's/\t/,/g' \
        > ${ann}.csv
fi
