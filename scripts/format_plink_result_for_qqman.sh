#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: format_plink_result_for_qqman.sh [plink unadjusted assoc result] (you may provide any number)"
else
   #for i in $@; do cat $i | grep -v -e NA -e CHROM | cut -f1-3,14 | sed '1 i CHR\tBP\tSNP\tP' | gzip -c > ${i/.PHENO1.glm.linear*/.assoc.txt.gz}; done
   for i in $@; do cat $i | csvcut -t -c "#CHROM,POS,ID,P" | csvformat -T | sed '1 d' | awk '$4 <= 1e-03' | sed '1 i CHR\tBP\tSNP\tP' | gzip -c > ${i/.PHENO1.glm.linear*/.assoc.for.qqman.txt.gz}; done
fi
