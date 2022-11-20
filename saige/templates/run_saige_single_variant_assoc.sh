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
fi
