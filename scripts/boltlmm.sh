#!/usr/bin/env bash

if [ $# != 6 ]; then
    echo "Usage: boltlmm.sh <bfile-prefixe> <covar-file> <to-covar [int]> <modelsnp-list> <output-prefix> <build [19/38]>"
else
    bfile=$1; covar=$2; cov=$3; ldSnp=$4; outprefix=$5; build=$6
    bolt="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/BOLT-LMM_v2.3.6/bolt"
    table="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/BOLT-LMM_v2.3.6/tables/"
    $bolt \
        --bfile="${bfile}" \
        --phenoUseFam \
        --covarFile=${covar} \
        --covarMaxLevels=50 \
        --LDscoresUseChip \
        --maxModelSnps=30000000 \
        --qCovarCol=PC{1:"$cov"} \
        --qCovarCol=AGE \
        --covarCol=SEX \
        --geneticMapFile=${table}genetic_map_hg${build}_withX.txt.gz \
        --lmmForceNonInf \
        --modelSnps=${ldSnp} \
        --numThreads=24 \
        --statsFile="${outprefix}.txt.gz" \
        --verboseStats
fi

# --qCovarCol=PC{1:"$cov"} \
