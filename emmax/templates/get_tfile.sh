#!/usr/bin/env bash

plink \
    --bfile ${bedName} \
    --indep-pairwise 50 10 0.2 \
    --out ${bedName}_prune \
    --maf 0.01 \
    --geno 0.05 \
    --hwe 1e-6

plink \
    --bfile ${bedName} \
    --recode 12 transpose \
    --threads 24 \
    --keep-allele-order \
    --maf 0.01 \
    --geno 0.05 \
    --extract ${bedName}_prune.prune.in \
    --output-missing-genotype 0 \
    --hwe 1e-6 \
    --out ${bedName}_kinship

plink \
    --bfile ${bedName} \
    --recode 12 transpose \
    --threads ${task.cpus} \
    --keep-allele-order \
    --maf ${params.maf} \
    --geno ${params.geno} \
    --output-missing-genotype 0 \
    --hwe ${params.hwe} \
    --out ${bedName}

