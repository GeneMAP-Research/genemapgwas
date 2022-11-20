#!/usr/bin/env bash

if [ $# -lt 5 ]; then
   echo "Usage: lookup_associations.sh [input] [chrom] [position] [lookup-size (e.g. 50000)] [output-prefix]"
else

   data=$1
   chrom=$2
   pos=$3
   size=$(( $4/2 ))
   out=$5

   zcat ${data} | \
      head -1 > ${out}_lookup.txt

   zcat ${data} | \
   awk \
      -v chr="$chrom" \
      -v bp="$pos" \
      -v lsize="$size" \
      '( $1 == chr ) && ( $2 >= bp-lsize && $2 <= bp+lsize )' \
      >> ${out}_lookup.txt
fi
