#!/usr/bin/env bash

plink2 --bfile hbf.data-aligned-strand-fixed --export vcf-4.2 bgz id-paste='iid' --real-ref-alleles --out hbf.data-aligned-strand-fixed --fa /mnt/lustre/groups/1000genomes/annotation/REF_VC/hg19/ucsc.hg19.fasta --ref-from-fa force --max-alleles 2 --min-alleles 2 --snps-only just-acgt --exclude dupvars.dupvar
