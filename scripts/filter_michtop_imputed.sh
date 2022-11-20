#!/usr/bin/env bash

if [ $# != 3 ]; then
    echo "Usage: filter_michtop_imputed.sh [imputation accuracy] [output prefix] [vcf_dir]"
else
    info="$1"; outp="$2"; vcf_dir=$3; ref="/mnt/lustre/groups/CBBI1243/KEVIN/db/hg38.no.chr.fa.gz"
    [ -e "merge.list" ] && rm merge.list
    for i in {1..22} X; do
      if [ -e "${vcf_dir}/chr${i}.info.gz" ]; then
        zgrep -v -wi imputed ${vcf_dir}/chr${i}.info.gz | sed '1d' | awk '{print $1}' > ${vcf_dir}/chr${i}_keep_info${info}_snps.txt; 
        zgrep -wi imputed ${vcf_dir}/chr${i}.info.gz | awk -v info="$info" '$7>=info' | awk '$6>=0.90' | awk '{print $1}' >> ${vcf_dir}/chr${i}_keep_info${info}_snps.txt;
        #plink2 --vcf ${vcf_dir}/chr${i}.dose.vcf.gz --double-id --make-bed --extract ${vcf_dir}/chr${i}_keep_info${info}_snps.txt --threads 24 --out chr${i}
        echo chr$i >> merge.list
      fi 
    done
    
    #plink --merge-list merge.list --make-bed --threads 24 --out ${outp}

    #plink2 --bfile ${outp} --export vcf-4.2 bgz id-paste='iid' --threads 24 --out ${outp}-vcf

#    bcftools norm --threads 24 -c x -m + -d all ${outp}-vcf.vcf.gz -f ${ref} | \
#       bcftools +fixref -- -f ${ref} -d -m top | \
#       bcftools norm --threads 24 -m + -c x -d all -f ${ref} | \
       #bcftools view --threads 24 -v snps,indels -m2 -M2 -Oz -o ${outp}-biallelic.vcf.gz ${outp}-vcf.vcf.gz
fi

