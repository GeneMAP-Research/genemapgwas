#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: get_imputed_good_variants.sh [imputation-panel]"
else
    imp_panel=$1
    if [[ "${imp_panel}" != "caapa" ]] || [[ "${imp_panel}" != "h3a" ]]; then
       zcat chr{1..22}.info.gz chrX.info.gz | \
           awk '$6>=0.90 && $7>=0.6' | \
           cut -f1-8 | gzip -c > \
           cm_${imp_panel}_avgcall90_rsq60_variants.txt.gz
    else
       zcat chr{1..22}.info.gz | \
           awk '$6>=0.90 && $7>=0.6' | \
           cut -f1-8 | gzip -c > \
           cm_${imp_panel}_avgcall90_rsq60_variants.txt.gz
    fi
fi 
