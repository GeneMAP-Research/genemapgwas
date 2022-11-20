#!/usr/bin/env bash

if [ $# -lt 3 ]; then
    echo ""
    echo "Usage: get_snp_genotypes.sh [chr:pos] [vcf-file] [samples-to-process] [output-prefix]"
    echo ""
    echo "NB: samples-to-process must contain a single column of sample IDs, one per line"
    echo ""
else
    chr_pos=$1; vcf=$2; samples=$3; outp=$4
    ref=$(bcftools view -r $chr_pos $vcf | bcftools query -f '%REF')
    alt=$(bcftools view -r $chr_pos $vcf | bcftools query -f '%ALT')
    
    bcftools \
        view \
        --threads 24 \
        -S $samples \
        -r $chr_pos \
        $vcf | \
        bcftools \
        query \
        -f '[%SAMPLE\t%GT\n]' | \
        sed 's|0[/|]0|'11'|g' | \
        sed 's|0[/|]1|'12'|g' | \
        sed 's|1[/|]0|'12'|g' | \
        sed 's|1[/|]1|'22'|g' | \
        awk '{print $1,$2,$2}' | \
        sed 's|11$|'$ref$ref'|g' | \
        sed 's|12$|'$ref$alt'|g' | \
        sed 's|22$|'$alt$alt'|g' | \
        sed '1 i FID Genotype RefAlt' \
        > ${outp}.txt
fi
