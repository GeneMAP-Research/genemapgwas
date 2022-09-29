#!/usr/bin/env bash

if [ $# -lt 1 ]; then
   echo "Usage: get_imputation_metrics.sh [imputation-panel]"
else
   panel=$1
   for i in $(ls *.vcf.gz | sort -V); 
   do
      chr_number=$(echo ${i} | sed 's/chr//g' | sed 's/.vcf.gz//g')
      bcftools \
         query \
         -f '%INFO/RefPanelAF %INFO/INFO\n' ${i} | \
      awk -v chr="${chr_number}" '$2>= 0.75 {print chr,$0}'; 
   done | \
   sed 's/\t/ /g' | \
   sed '1 i chr maf r2' | \
   gzip -f -c > ${panel}_imputation_metrics.txt.gz
fi
