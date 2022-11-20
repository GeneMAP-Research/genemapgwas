#!/usr/bin/env bash

cat ${plinkAssoc} | \
    grep -v -e NA -e CHROM | \
    cut -f1-5,9-12,14 | \
    sed '1 i CHR\tPOS\tID\tREF\tALT\tBETA\tSE\tL95\tU95\tP' | \
    gzip -c > "${plinkAssoc}.txt.gz"

Rscript ${projectDir}/includes/adjustAssociationTestPvalues.r "${plinkAssoc}.txt.gz" ${task.cpus}

gzip "${plinkAssoc}.adjusted.txt"
