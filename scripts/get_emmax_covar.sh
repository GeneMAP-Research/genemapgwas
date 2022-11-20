#!/usr/bin/env bash

if [ $# -lt 2 ]; then
    echo "Usage: get_emmax_covar.sh [covar-file] [tfam-file]"
else
   covar="$1"; tfam="$2"
   cat ${covar} | cut -f1-22,34 -d' ' | sed '1d' | awk '{print $1,$2,"1",$0}' | cut -f1-3,6- -d' ' > temp.cov
   awk '{print $5}' $tfam > temp.sex
   paste temp.cov temp.sex | sed 's/\t/ /g' > ${tfam/.tfam/.cov}
fi
