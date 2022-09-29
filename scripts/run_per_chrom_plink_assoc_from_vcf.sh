#!/usr/bin/env bash

if [ $# != 4 ]; then
   echo "Usage: run_per_chrom_plink_assoc_from_vcf.sh [panel-name] [vcf-directory] [imputeinfo-name] [imputeinfo-threshold]"
else

   covar_file="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/pca.for.grm.cov"
   fam_file="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/high_quality_snps_for_nullglmm.fam"

   panel=$1; vcf_dir=$2; info_name=$3; info_thresh=$4

   cd ${vcf_dir}

   for file in ./*.vcf.gz; 
   do
      plink2 \
         --adjust \
         --covar ${covar_file} \
         --covar-name PC1-PC10,AGE \
         --geno 0.05 \
         --hwe 1e-6 \
         --keep ${covar_file} \
         --maf 0.01 \
         --vcf ${file} \
         --double-id \
         --pheno ${fam_file} \
         --pheno-col-nums 6 \
         --glm sex hide-covar 'cols=chrom,pos,ref,alt,a1freq,a1count,ax,test,nobs,orbeta,se,ci,tz,p,err' \
         --ci 0.95 \
         --out ${file/.vcf.gz/.add.norm} \
         --exclude-if-info "${info_name} < ${info_thresh}";
   done
fi
