#!/usr/bin/env bash

if [ $# != 3 ]; then
   echo "Usage: format_metal_result_for_locuszoom.sh [metal result formatted for qqman (gzipped)] [chromosome <e.g. chr2>] [output_dir]"
else
   locusin=$1; chrom=$2; out_dir=$3
   zcat ${locusin} | \
   sed '1d' | \
   awk '{print "chr"$1":"$2"\t"$4}' | \
   grep "$chrom:" | \
   sed '1 i MarkerName\tP-value' | \
   gzip -c > ${out_dir}/$(basename ${locusin/.gz/}_${chrom}.lcz.txt.gz)
fi
