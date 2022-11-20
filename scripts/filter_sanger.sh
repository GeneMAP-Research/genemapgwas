#!/usr/bin/env bash

if [ $# != 3 ]; then
    echo "Usage: filter_sanger.sh [imputation accuracy] [output prefix] [sanger directory]"
else
    info="$1"; outp="$2"; ref="/mnt/lustre/groups/1000genomes/annotation/REF_VC/human_g1k_v37.fasta"; sanger_dir="$3"

    [ -e "merge.list" ] && rm merge.list

    for i in {1..22} X; do bcftools query -f '%CHROM:%POS:%REF:%ALT %INFO/INFO\n' ${sanger_dir}vcfs/${i}.vcf.gz > ${sanger_dir}vcfs/chr${i}.imputeinfo.txt; done

    for i in {1..22} X; do awk -v info="$info" '$2>=info' ${sanger_dir}vcfs/chr${i}.imputeinfo.txt | sed '1d' > chr${i}.keep.good.snps.txt; done

    for i in {1..22} X; do 
         if [ -e "${sanger_dir}vcfs/${i}.vcf.gz" ]; then 
            plink2 --vcf ${sanger_dir}vcfs/${i}.vcf.gz --make-bed --set-all-var-ids '@:#:$r:$a' --double-id --threads 24 --out chr${i}.temp; echo chr$i >> merge.list; 
         fi; 
    done

    for i in {1..22} X; do plink2 --bfile chr${i}.temp --make-bed --extract chr${i}.keep.good.snps.txt --threads 24 --out chr${i}; done

    plink --merge-list merge.list --make-bed --threads 24 --out ${outp}

    plink2 --bfile ${outp} --export vcf-4.2 bgz id-paste='iid' --threads 24 --out ${outp}-vcf

#    bcftools norm --threads 24 -c x -m + -d all ${outp}-vcf.vcf.gz -f ${ref} | \
#       bcftools +fixref -- -f ${ref} -m top | \
#       bcftools norm --threads 24 -m + -c x -d all -f ${ref} | \
       bcftools view --threads 24 -v snps,indels -m2 -M2 -Oz -o ${outp}-biallelic.vcf.gz ${outp}-vcf.vcf.gz
fi
