#!/usr/bin/env bash

snptest_v2.5.6 \
  -data ${genFile} ${sampleFile} \
  -frequentist 2 \
  -method ${params.method} \
  -pheno ${params.phenoName} \
  -cov_names ${params.snpTestCovarName} \
  -o "${params.outputPrefix}.snptest.dom.txt.gz"

zgrep -v "^#" "${params.outputPrefix}.snptest.dom.txt.gz" | \
  cut -f1-2,4-6,19,21,23-24 | \
  gzip -c > "${params.outputPrefix}.snptestassoc.dom.txt.gz"
