#!/usr/bin/env bash

if [ $# -lt 5 ]; then
    echo "Usage: boltreml.sh <bfile-prefixe> <covar-file> <to-covar [int]> <model-snplist> <build [19/38]>"
else
    bfile=$1; covar=$2; cov=$3; ldSnp=$4; build=$5
    bolt="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/BOLT-LMM_v2.3.6/bolt"
    table="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/BOLT-LMM_v2.3.6/tables/"
    ${bolt} \
        --bfile="${bfile}" \
        --phenoUseFam \
        --covarFile=${covar} \
        --covarMaxLevels=50 \
        --LDscoresUseChip \
        --qCovarCol=PC{1:"$cov"} \
        --maxModelSnps=30000000 \
        --qCovarCol=AGE \
        --covarCol=SEX \
        --geneticMapFile=${table}genetic_map_hg${build}_withX.txt.gz \
        --reml \
        --modelSnps=${ldSnp} \
        --numThreads=24 \
        --verboseStats
fi

#         --qCovarCol=PC{1:"$cov"} \

