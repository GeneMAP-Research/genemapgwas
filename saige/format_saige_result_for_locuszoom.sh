#!/usr/bin/env bash

if [ $# != 3 ]; then
   echo "Usage: format_saige_result_for_locuszoom.sh [saige-result (gzipped)] [chromosome <e.g. chr2>] [output dir]"
else
   locusin=$1; chrom=$2; out_dir=$3
   zcat ${locusin} | \
   sed '1d' | \
   awk '{print "chr"$1":"$2"\t"$13}' | \
   grep "${chrom}:" | \
   sed '1 i MarkerName\tP-value' | \
   gzip -c > ${out_dir}/$(basename ${locusin/.gz/}_${chrom}.lcz.txt.gz)
fi
