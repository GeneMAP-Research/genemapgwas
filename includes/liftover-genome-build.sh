#!/usr/bin/env bash


singularity \
  exec /vast/awonkam1/containers/sickleinafrica-crossmap-latest.img \
  CrossMap \
    vcf \
      --chromid a \
      --no-comp-alleles \
      --compress \
      /vast/awonkam1/resources/extras/hg18ToHg19.over.chain \
      /scratch4/awonkam1/kesoh/projects/gwas/sitt/cdc/qc/sittcdc-pass-qc.vcf.gz \
      /vast/awonkam1/resources/hg19/refgenome/hs37d5.fa \
      sittcdc-pass-qc-hg19-crossmap.vcf

./genemapgwas/bin/liftOver  \
  sitt-clean-cdc-hg18.bed \
  /vast/awonkam1/resources/extras/hg18ToHg19.over.chain \
  sitt-clean-cdc-hg19-mapped.bed \
  sitt-clean-cdc-hg19-unmapped.bed
