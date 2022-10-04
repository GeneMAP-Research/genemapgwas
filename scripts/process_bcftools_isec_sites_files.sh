#!/usr/bin/env bash

[ -e "sites.txt" ] && gzip -f sites.txt
[ -e "sites.txt.gz" ] && zcat sites.txt.gz | awk '{print $1,$2,$3,$4,"\""$5"\""}' | sed '1 i chrom pos ref alt info' | gzip -c > sites.2.txt.gz
