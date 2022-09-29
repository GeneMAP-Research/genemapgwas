#!/usr/bin/env bash

if [ $# != 1 ]; then
   echo "Usage: format_saige_qt_result_for_metal.sh [saige quantitative trait result]"
else
   assoc=$1
   zcat \
      ${assoc} | \
      awk '{print $1,$2,$1":"$2":""SNP",$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' | \
      sed '1d' | \
      sed '1 i CHR POS SNP Allele1 Allele2 AC_Allele2 Allele2_freq imputationInfo BETA SE Tstat var P N' | \
      gzip -c > ${assoc}.for.metal.gz
fi
