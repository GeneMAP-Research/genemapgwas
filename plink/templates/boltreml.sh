#!/usr/bin/env bash

if [ $# -lt 3 ]; then
    echo "Usage: boltreml.sh <bfile-prefixe> <covar-file> <output-prefix>"
else
    bfile=$1; covar=$2; outprefix=$3
    bolt="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/BOLT-LMM_v2.3.6/bolt"
    table="/mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/BOLT-LMM_v2.3.6/tables/"
    ${bolt} \
        --bfile="${bfile}" \
        --phenoUseFam \
        --covarFile=${covar} \
        --covarMaxLevels=50 \
        --LDscoresUseChip \
        --maxModelSnps=30000000 \
        --qCovarCol=PC{1:30} \
        --qCovarCol=AGE \
        --covarCol=SEX \
        --geneticMapFile=${table}genetic_map_hg19_withX.txt.gz \
        --reml \
        --modelSnps=prune.prune.in \
        --numThreads=24 \
        --statsFile="${outprefix}.stats.gz" \
        --verboseStats
fi
