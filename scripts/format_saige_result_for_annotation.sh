#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo "Usage: format_saige_result.sh [formated-saige-result]"
else
    assoc=$1
    awk '{print $3"\t"$9"\t"$10"\t"$13"\t"$1"\t"$2"\t"$5"\t"$4}' $assoc | bgzip -c > $(basename ${assoc/.gz/.fmt.gz}.gz)
fi
