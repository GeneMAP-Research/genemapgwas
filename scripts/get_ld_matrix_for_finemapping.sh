#!/usr/bin/env bash

if [ $# -lt 4 ];
then
   echo "Usage: format_saige_results_for_finemapping.sh [saige result formmated for finemapping] [chrom] [output prefix] [ref (e.g. custom/hg19, kgp/hg38)]"
else
   #metal_dir="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/output/"

   assoc=$1
   chrom=$2
   out=$3
   ref=$4
   #ref_dir="/mnt/lustre/groups/CBBI1243/KEVIN/imputationReference/${build}/kgp/"
   ref_dir="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/finemap/reference/${ref}/"

   plink \
     --bfile ${ref_dir}chr${chrom} \
     --extract ${assoc} \
     --write-snplist \
     --biallelic-only \
     --out ${out}_for_finemappng \
     --r square gz
   
   #  --keep-allele-order \
   
   
   grep \
     -f ${out}_for_finemappng.snplist \
     ${assoc} | \
     sed '1 i snp beta se p pbh' \
     > ${out}_for_finemappng.txt

fi
