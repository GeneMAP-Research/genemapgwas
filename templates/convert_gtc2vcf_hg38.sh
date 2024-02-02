#!/usr/bin/env bash

bcftools \
  +gtc2vcf \
  --bpm ${params.manifest_bpm} \
  --csv ${params.manifest_csv} \
  --egt ${params.cluster_file} \
  --gtcs ${gtc_list} \
  --adjust-clusters \
  --use-gtc-sample-names \
  --sam-flank ${params.bam_alignment_file} \
  --genome-build GRCh38 \
  --fasta-ref ${params.fasta_ref} \
  --extra "${params.output_prefix}_genotype_stats.tsv" | \
 bcftools \
  sort \
  -T ./bcftools-sort.XXXXXX | \
 bcftools \
  norm \
  --threads ${task.cpus} \
  --no-version \
  -Oz \
  -c x \
  -f ${params.fasta_ref} | \
  tee "${params.output_prefix}.vcf.gz" | \
 bcftools \
  index \
  --threads ${task.cpus} \
  -ft \
  --output "${params.output_prefix}.vcf.gz.tbi"
