#!/usr/bin/env bash

#  if [ $# != 3 ]; then
#     echo "Usage: vcf2pgen.sh [vcf-directory] [build <b37/b38>] [outname]"
#  else
#  
#     covar_file="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/pca.for.grm.cov"
#     fam_file="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/high_quality_snps_for_nullglmm.fam"
#  
#     vcf_dir=$1; build=$2; out=$3
#  
#     cd ${vcf_dir}
#  
#     for vcf in ./*.vcf.gz;
#     do
#        plink2 \
#           --make-pgen psam-cols=fid,parents,sex,pheno1 \
#           --vcf ${vcf} \
#           --out ${vcf/.vcf.gz/} \
#           --maf 0.005 \
#           --hwe 1e-06 \
#           --mind 0.10 \
#           --exclude-if-info INFO < 0.8 \
#           --geno 0.05 \
#           --pheno ${fam_file} \
#           --pheno-col-nums 6 \
#           --update-sex ${fam_file} col-num=5 \
#           --split-par ${build} \
#           --double-id
#        echo ${vcf/.vcf.gz/} >> pmerge.list
#     done
#     plink2 \
#        --pmerge-list pmerge.list \
#        --out ${out}
#  fi

if [ $# != 5 ]; then
   echo "Usage: vcf2pgen.sh [panel-name] [vcf-directory] [imputeinfo-name] [imputeinfo-threshold] [output-dir]"
else

   covar_file="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/pca.for.grm.cov"
   fam_file="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/high_quality_snps_for_nullglmm.fam"

   panel=$1; vcf_dir=$2; info_name=$3; info_thresh=$4; out_dir=$5

   cd ${vcf_dir}
   if [ -e pmerge.list ]; then rm pmerge.list; fi
   for vcf in ./*.vcf.gz;
   do
      plink2 \
         --export vcf-4.2 bgz id-paste='iid' \
         --out ${out_dir}/${vcf/.vcf.gz/} \
         --adjust \
         --geno 0.05 \
         --hwe 1e-6 \
         --maf 0.005 \
         --vcf ${vcf} \
         --snps-only just-acgt \
         --max-alleles 2 \
         --double-id \
         --exclude-if-info "${info_name} < ${info_thresh}";
   done
fi

