#!/usr/bin/env bash

if [ $# != 2 ]; then
    echo "Usage: filter_michtop_imputed.sh [imputation accuracy] [output prefix]"
else
    info="$1"; outp="$2"; ref="/mnt/lustre/groups/CBBI1243/KEVIN/db/hg38.no.chr.fa.gz"
#    [ -e "merge.list" ] && rm merge.list
#    for i in {1..22} X; do
#      if [ -e "vcfs/chr${i}.info.gz" ]; then
#        zgrep -v -wi imputed vcfs/chr${i}.info.gz | sed '1d' | awk '{print $1}' > vcfs/chr${i}.keep.snps.txt; 
#        zgrep -wi imputed vcfs/chr${i}.info.gz | awk -v info="$info" '$7>=info' | awk '$6>=0.90' | awk '{print $1}' >> vcfs/chr${i}.keep.snps.txt;
#        echo chr$i >> merge.list
#      fi 
#    done
#    
#    for i in {1..22} X; do plink2 --vcf vcfs/chr${i}.dose.vcf.gz --double-id --make-bed --extract vcfs/chr${i}.keep.snps.txt --maf 0.01 --threads 24 --out chr${i}; done
#
#    for i in {1..22} X; do echo chr${i}; done > merge.list
# 
#    plink --merge-list merge.list --make-bed --threads 24 --out ${outp}
#
#    plink2 --bfile ${outp} --export vcf-4.2 bgz id-paste='iid' --threads 24 --out ${outp}-vcf

    bcftools norm --threads 24 -c x -m + -d all ${outp}-vcf.vcf.gz -f ${ref} | \
       bcftools +fixref -- -f ${ref} -d -m top | \
       bcftools norm --threads 24 -m + -c x -d all -f ${ref} | \
       bcftools view --threads 24 -v snps,indels -m2 -M2 -Oz -o ${outp}-biallelic.vcf.gz
fi
