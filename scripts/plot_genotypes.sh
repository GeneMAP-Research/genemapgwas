#!/usr/bin/env bash

if [ $# -lt 5 ]; then
    echo ""
    echo "Wrapper for 'get_snp_genotypes.sh' and 'get_boxplot_of_snp_genotypes.r'"
    echo ""
    echo "Usage: plot_genotypes.sh [vcf-file] [variants-file <chr:pos snpid genename>] [sample-file <one per line>] [pheno-file] [pheno-name]"
    echo ""
else
    vcf_file=$1; variants_file=$2; sample_file=$3; pheno=$4; phenoname=$5
    #vcf_dir='/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/imputed/union/'
    sample_dir='/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/genotypesPlots/'
    script_dir="${HOME}/projects/gwas/scripts/"
    #nlines=$(wc -l sggestive_variants_with_large_effect_sizes.txt | awk '{print $1}')
    
    counter=1
    while read -r line; do
        chrpos=$(echo $line | awk '{print $1}')
        rsid=$(echo $line | awk '{print $2}')
        out=$(echo $line | awk '{print $3}')
    
        if [ "$rsid" == "." ]; then rsid=$(echo $line | awk '{print $1}'); fi
    
        echo "[`date`] (processing --> $chrpos; RSID --> $rsid)"
    
        ${script_dir}get_snp_genotypes.sh \
            $chrpos \
            ${vcf_file} \
            ${sample_file} \
            ${out}_${rsid}_genotypes
    
        ${script_dir}get_boxplot_of_snp_genotypes.r \
            ${out}_${rsid}_genotypes.txt \
            ${pheno} \
            ${phenoname} \
            "${rsid}"
    
    ((counter++))
    done < ${variants_file}  
    echo "done!"
fi
