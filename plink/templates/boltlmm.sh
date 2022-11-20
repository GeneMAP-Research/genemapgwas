#!/usr/bin/env bash

bolt \
    --bfile="${bedPrefix}" \
    --phenoUseFam \
    --covarFile=${params.boltCovarFile} \
    --covarMaxLevels=50 \
    --LDscoresUseChip \
    --maxModelSnps=30000000 \
    --qCovarCol=PC{1:20} \
    --qCovarCol=AGE \
    --covarCol=SEX \
    --geneticMapFile=${params.geneticMap} \
    --lmmForceNonInf \
    --modelSnps=${params.boltModelSnps} \
    --numThreads=${task.cpus} \
    --statsFile="${params.outputPrefix}.boltassoc.txt.gz" \
    --verboseStats
