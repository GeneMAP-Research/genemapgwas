#!/usr/bin/env bash
#SBATCH --account humgen
#SBATCH --partition sadacc-long
#SBATCH --nodes 1
#SBATCH --ntasks 44

csv_manifest_file="/scratch/GeneMAP/genemap/resources/gwas/manifests/H3Africa_2019_20037295_B1.csv"
ref="/scratch/eshkev001/db/hg38/hg38.fa"
bam_alignment_file="/scratch/GeneMAP/genemap/resources/gwas/manifests/H3Africa_2019_20037295_B1_hg38.bam"

# lift manifest from hg19 to hg38
singularity run /scratch/eshkev001/containers/sickleinafrica-gencall-latest.img \
bcftools +gtc2vcf \
  -c $csv_manifest_file \
  --fasta-flank \
  --threads $SLURM_NTASKS | \
singularity run /scratch/eshkev001/containers/bwa_bgzip_latest.img \
bwa mem -M $ref -t $SLURM_NTASKS - | \
singularity run /scratch/eshkev001/containers/samtools_1.11.img \
 samtools view -bS -@ $SLURM_NTASKS \
  -o $bam_alignment_file

