#!/usr/bin/env bash

cut -f1,4,6 /mnt/lustre/groups/CBBI1243/KEVIN/gwasdata/cam_tz_merge/meta_analysis/output/cm_tz_topmed_metaanalysis1.tbl | sed 's|:|\t|2' | awk '{print "chr"$1"\t"$3"\t"$4}' | sed '1d' | sed '1 i MarkerName\tWeight\tP-value' > cm_tz_topmed_metaanalysis1.lcz.txt
