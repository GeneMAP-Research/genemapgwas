#!/usr/bin/env bash

if [ $# -lt 1 ]; then
   echo "Usage: format_saige_result_for_qqman.sh [saige-result(s)]"
else
   for saige in $@; do
       zcat $saige | \
         awk '{print $1,$2,$3,$13}' | \
         sed '1d' | \
         sed '1 i CHR BP SNP P' | \
         gzip -c \
         > ${saige}.qqman.txt.gz
   done
fi
