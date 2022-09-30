#!/usr/bin/env bash

gzip -f sites.txt
zcat sites.txt.gz | awk '{print $1,$2,$3,$4,"\""$5"\""}' | sed '1 i chrom pos ref alt info' | gzip -c > sites.2.txt.gz
