#!/usr/bin/env bash

bcftools \
   +gtc2vcf \
   --bpm ${params.manifest_bpm} \
   --csv ${params.manifest_csv} \
   --egt ${params.cluster_file} \
   --gtcs ${params.gtc_list} \
   --fasta-ref ${params.ref_fasta} \
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
   -f ${params.ref_fasta} | \
   tee "${params.output_prefix}.vcf.gz" | \
 bcftools \
   index \
   --threads ${task.cpus} \
   -ft \
   --output "${params.output_prefix}.vcf.gz.tbi"
