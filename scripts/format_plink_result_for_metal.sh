#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: format_plink_result_for_metal.sh [plink unadjusted assoc result] (you may provide any number)"
else
   #for i in $@; do grep -v NA $i | cut -f1-3,4,6,8-10,14 | sed '1d' | sed '1 i CHR\tBP\tSNP\tAllele1\tAllele2\tN\tBETA\tSE\tP' | sed 's/_/:/g' > ${i}_metal.txt; done
   for i in $@; do grep -v "NA" $i | csvcut -t -c "#CHROM,POS,ID,A1,AX,A1_FREQ,OBS_CT,BETA,SE,T_STAT,P" | csvformat -T | sed 's/#//g' | gzip -c > ${i/.PHENO1.glm.linear/.for.metal.txt.gz}; done
fi
