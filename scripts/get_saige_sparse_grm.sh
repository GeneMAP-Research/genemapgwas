#!/usr/bin/env bash

if [ $# != 1 ]; then
   echo "Usage: get_saige_sparse_grm.sh [ld-pruned-plink-binary-prefix]"
else
   bed=$1;
   singularity run \
       /mnt/lustre/groups/CBBI1243/KEVIN/containers/saige.sif \
       createSparseGRM.R \
       --plinkFile=${bed} \
       --nThreads=24 \
       --outputPrefix=${bed}
fi
