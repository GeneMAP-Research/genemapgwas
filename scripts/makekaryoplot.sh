#!/usr/bin/env bash

# karyoploteR input: for manhattan plots in R

if [ $# -lt 1 ]; then
    echo "Usage: makekaryoplot.sh [plink unadjusted assoc result] (you may provide any number)"
else
  for i in $@; do
    sed '1d' $i | \
      awk '{print "chr"$1,$2,$3,$14}' | \
      sed '1 i chr pos rsid pval' | \
      gzip -c > ${i/.*/}.karyoploter.txt.gz
  done
fi
