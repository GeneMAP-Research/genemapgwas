#!/usr/bin/env bash

awk '{print \$1,\$2,\$6}' ${tfam} \
    > ${bedName}.phe

emmax-intel64 \
    -v \
    -d 10 \
    -t ${bedName} \
    -p ${bedName}.phe \
    -k ${kinship} \
    -c ${covar} \
    -o ${bedName}

gzip -f ${bedName}.ps

