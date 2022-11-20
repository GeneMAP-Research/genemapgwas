#!/usr/bin/env bash

if [ $# != 2 ]; then
    echo "Usage: make_gemme_covar.sh [emmax covar file] [output prefix]"
else
    cov=$1; outp=$2
    cut -f4- -d' ' $cov | awk '{print "1",$0}' > ${outp}.gemma.cov
fi
