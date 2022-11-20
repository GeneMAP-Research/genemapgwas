#!/usr/bin/env bash

if [ $# != 2 ]; then
   echo "Usage: format_saige_result_for_locuszoom.sh [saige-result (gzipped)] [chromosome <e.g. chr2>]"
else
   locusin=$1; chrom=$2
   zcat ${locusin} | \
   sed '1d' | \
   awk '{print "chr"$1":"$2"\t"$13}' | \
   grep ${chrom} | \
   sed '1 i MarkerName\tP-value' | \
   gzip -c > $(basename ${locusin/.gz/}_${chrom}.txt.gz)
fi
