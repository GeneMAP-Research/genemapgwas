#!/usr/bin/env bash

if [ $# -lt 5 ];
then
   echo "Usage: format_saige_results_for_finemapping.sh [saige result (gzipped)] [chrom] [pos] [finemap size (e.g. 50000)] [output prefix] [ref (e.g. custom/hg19, kgp/hg38)]"
else
   #metal_dir="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/output/"

   assoc=$1
   chrom=$2
   pos=$3
   size=$4
   out=$5
   ref=$6
   #ref_dir="/mnt/lustre/groups/CBBI1243/KEVIN/imputationReference/${build}/kgp/"
   ref_dir="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/finemap/reference/${ref}/"

   half_size=$(( $size/2 ))
   lower=$(( $pos - $half_size ))
   upper=$(( $pos + $half_size ))
   
   zgrep -v '?' ${assoc} | \
     awk \
     -v chr="${chrom}" '$1 == chr {print $1,$2,$9,$10,$13,$15}' | \
     sed '1d' | \
     awk \
       -v chr=$chrom \
       -v l=$lower \
       -v u=$upper \
       '($1 == chr) && ($2 >= l && $2 <= u) {print $1":"$2":SNP",$3,$4,$5,$6}' | \
     sed '1 i snp beta se p pbh' \
     > ${out}_for_finemappng.temp.txt
   
   
   #plink2 \
   #   --extract ${out}_for_finemappng.temp.txt \
   #   --vcf ${ref_dir}chr${chrom}.1kg.phase3.v5a.vcf.gz \
   #   --set-all-var-ids '@:#:SNP' \
   #   --out ${out}_for_finemappng \
   #   --write-snplist

   plink \
     --bfile ${ref_dir}chr${chrom} \
     --extract ${out}_for_finemappng.temp.txt \
     --write-snplist \
     --biallelic-only \
     --out ${out}_for_finemappng \
     --r square gz
   
   #  --keep-allele-order \
   
   
   grep \
     -f ${out}_for_finemappng.snplist \
     ${out}_for_finemappng.temp.txt | \
     sed '1 i snp beta se p pbh' \
     > ${out}_for_finemappng.txt

fi
