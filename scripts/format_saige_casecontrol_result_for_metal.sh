#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: format_saige_casecontrol_result_for_metal.sh [saige-casecontrol-result]"
else
    assoc=$1
    awk '$15=="true" {print $3,$4,$5,$9,$10,$13,$18+$19}' ${assoc} | sed '1 i SNP A1 A2 BETA SE P NMISS' | sed 's/ /\t/g' > ${assoc}.metal
fi
