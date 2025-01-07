#!/usr/bin/env bash
#SBATCH --account humgen
#SBATCH --partition sadacc-short
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --time 06:00:00

module load software/nextflow-23.04.3

cd /home/eshkev001/workflows/gwas/pca/

nextflow run merge_data_with_kgp.nf -w /scratch/eshkev001/nfworkdirs/camscd-gwas-work/ -resume
