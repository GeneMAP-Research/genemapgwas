#!/usr/bin/env bash

if [ $# != 4 ]; then
   echo "Usage: run_saige_single_variant_assoc.sh [plink-binary-prefix] [grm-file] [covariance-ratio-file] [output-prefix]"
else
   bed=$1; grm=$2; cov=$3; out=$4
#   singularity run \
#      /mnt/lustre/groups/CBBI1243/KEVIN/containers/saige.sif \
#      step1_fitNULLGLMM.R \
#      --plinkFile=${bed} \
#      --phenoFile=${phe} \
#      --phenoCol=${phn} \
#      --covarColList=${cov} \
#      --traitType=${pht} \
#      --sampleIDColinphenoFile=${fid} \
#      --nThreads=24 \
#      --outputPrefix=${out} \
#      --LOCO=TRUE \
#      --IsOverwriteVarianceRatioFile=TRUE

singularity run \
   /mnt/lustre/groups/CBBI1243/KEVIN/containers/saige.sif \
   step2_SPAtests.R \
   --bedFile=${bed}.bed \
   --bimFile=${bed}.bim \
   --famFile=${bed}.fam \
   --GMMATmodelFile=${grm} \
   --varianceRatioFile=${cov} \
   --SAIGEOutputFile=${out} \
   --LOCO=FALSE

#singularity run \
#      /mnt/lustre/groups/CBBI1243/KEVIN/containers/saige.sif \
#      step2_SPAtests.R \
#      --vcfFile=/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/imputed/sanger/vcfs/22.vcf.gz \
#      --vcfFileIndex=/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/imputed/sanger/vcfs/22.vcf.gz.csi \
#      --vcfField=DS \
#      --SAIGEOutputFile=/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/imputed/sanger/test_saige \
#      --chrom=22 \
#      --minMAF=0 \
#      --minMAC=20 \
#      --LOCO=TRUE \
#      --varianceRatioFile=/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/saige.grm.varianceRatio.txt \
#      --GMMATmodelFile=/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/mergedBatches/unimputed/saige/qt/saige.grm.rda \
#      --is_imputed_data=TRUE \
#      --minInfo=0.3

fi
