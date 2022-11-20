#!/usr/bin/env bash

if [ $# != 2 ]; then
   echo "Usage: prep_snptest_cov.sh [sample file] [covar file]"
else
   sample=$1; cov=$2
   paste ${sample} ${cov} | sed 's/\t/ /g' > ${sample/.sample/.cov.sample}
fi
