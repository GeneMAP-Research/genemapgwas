#!/usr/bin/env bash

createSparseGRM.R \
   --plinkFile=${ld_bfile} \
   --nThreads=${task.cpus} \
   --outputPrefix=${out}
