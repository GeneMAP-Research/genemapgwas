#!/usr/bin/env bash

awk '{print \$1,\$2,\$3,\$13}' ${saigeResult} | \
    sed '1d' | \
    sed '1 i CHR BP SNP P' | \
    sed 's/chr//1' | \
    sed 's/X/23/1' | \
    sed 's/Y/24/1' | \
    sed 's/MT/25/1' | \
    gzip -c \
    > ${saigeResult}.qqman.txt.gz
