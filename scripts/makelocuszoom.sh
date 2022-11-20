#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: makelocuszoom.sh [plink unadjusted assoc result] (you may provide any number)"
else
   for i in $@; do cat $i | grep -v -e NA -e CHROM | cut -f1-5,9-10,14 | sed '1 i CHR\tPOS\tID\tREF\tALT\tBETA\tSE\tP' | gzip -c > ${i/.PHENO1.glm.linear/.locuszoom.txt.gz}; done
fi
