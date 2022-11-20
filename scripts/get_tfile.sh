#!/usr/bin/env bash

if [ $# -lt 2 ]; then
   echo "Usage: get_emmax_input.sh [bfile-prefix] [output-prefix]"
else
   bfile="$1"; out="$2"
   plink --bfile ${bfile} --recode 12 transpose --threads 24 --keep-allele-order --maf 0.01 --geno 0.05 --output-missing-genotype 0 --hwe 1e-50 --out ${out}
fi
 
