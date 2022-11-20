#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: format_plink_result_for_metal.sh [plink unadjusted assoc result] (you may provide any number)"
else
   for i in $@; do grep -v NA $i | cut -f1-3,4,6,8-10,14 | sed '1d' | sed '1 i CHR\tBP\tSNP\tAllele1\tAllele2\tN\tBETA\tSE\tP' | sed 's/_/:/g' > ${i}_metal.txt; done
fi
