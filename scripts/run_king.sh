#!/usr/bin/env bash

if [ $# != 2 ]; then 
   echo "Usage: run_king.sh [bed_file_prefix] [degree (2,3,4, etc)]"
else
   bed=$1; degree=$2
   king -b ${bed}.bed --ibdseg --rplot --degree $degree --prefix ${bed}
   #grep -w -e "Dup/MZ" -e Dup -e MZ -e FS -e 2nd ${bed}.seg | cut -f1-2 | sed '1d' | sort | uniq > ${bed}_duplicate_and_upto_2nd_degree_relatedness_ids.txt
fi
