#!/usr/bin/env bash

if [ $# != 10 ]; then
   echo "Usage: run_saige.sh [plink-binary-prefix] [saige-pheno-file] [pheno-name] [pheno-type <binary/quantitative>] [covar-list <e.g. SEX,AGE>] [categorical cov <e.g. SEX>] [pheno-file-sample-id-name] [output-prefix] [ gene/variant set analysis? <true/false>] [threads]"
else
   bed=$1; phe=$2; phn=$3; pht=$4; cov="$5"; catcov=$6; fid=$7; out=$8; genset=$9; threads=${10}
   singularity run \
      /vast/awonkam1/containers/sickleinafrica-wzhou88-saige-1.3.6.img \
      step1_fitNULLGLMM.R \
      --plinkFile=${bed} \
      --phenoFile=${phe} \
      --invNormalize=FALSE \
      --phenoCol=${phn} \
      --sampleIDColinphenoFile=${fid} \
      --traitType=${pht} \
      --covarColList=${cov} \
      --qCovarColList=${catcov} \
      --sexCol=SEX \
      --MaleCode=1 \
      --FemaleCode=2 \
      --numRandomMarkerforVarianceRatio=30 \
      --relatednessCutoff=0 \
      --outputPrefix=${out} \
      --IsOverwriteVarianceRatioFile=TRUE \
      --minMAFforGRM=0.05 \
      --maxMissingRateforGRM=0.05 \
      --nThreads=${threads} \
      --memoryChunk=5 \
      --LOCO=FALSE \
      $(if [[ "$genset" == "true" ]]; then echo '--isCateVarianceRatio=TRUE'; fi)

fi
