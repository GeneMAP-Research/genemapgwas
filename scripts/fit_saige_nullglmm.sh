#!/usr/bin/env bash

if [ $# != 9 ]; then
   echo "Usage: run_saige.sh [plink-binary-prefix] [saige-pheno-file] [pheno-name] [pheno-type <binary/quantitative>] [covar-list <e.g. SEX,AGE>] [categorical cov <e.g. SEX>] [pheno-file-sample-id-name] [output-prefix] [ gene/variant set analysis? <true/false>]"
else
   bed=$1; phe=$2; phn=$3; pht=$4; cov="$5"; catcov=$6; fid=$7; out=$8; genset=$9
   singularity run \
      /mnt/lustre/groups/CBBI1243/KEVIN/containers/saige.sif \
      step1_fitNULLGLMM.R \
      --plinkFile=${bed} \
      --phenoFile=${phe} \
      --invNormalize=FALSE \
      --phenoCol=${phn} \
      --covarColList=${cov} \
      --qCovarColList=${catcov} \
      --traitType=${pht} \
      --sexCol=SEX \
      --numRandomMarkerforVarianceRatio=100 \
      --relatednessCutoff=0.05 \
      --sampleIDColinphenoFile=${fid} \
      --outputPrefix=${out} \
      --IsOverwriteVarianceRatioFile=TRUE \
      --nThreads=24 \
      $(if [[ "$genset" == "true" ]]; then echo '--LOCO=TRUE --isCateVarianceRatio=TRUE'; else echo '--LOCO=FALSE'; fi)

fi
