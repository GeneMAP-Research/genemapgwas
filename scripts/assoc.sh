#!/usr/bin/env bash

#add
for chr in {1..22}; do plink2 --bfile hbf.data --chr ${chr} --glm sex hide-covar --covar hbf.data-unrelated.cov --covar-name PC1-PC10,AGE --ci 0.95 --adjust --out chr${chr}-add; done

for chr in {1..22}; do awk '$7=="ADD" {print $1,$2,$3,$4"/"$5,$7,$9,$10,$11,$12,$14}' chr${chr}-add.PHENO1.glm.linear | grep -v NA; done  > add.assoc

sort -g -k10 add.assoc | sed '1 i CHR BP SNP REF/ALT TEST BETA SE L95 U95 P' | bgzip -c > add.assoc.result.gz

#dom
for chr in {1..22}; do plink2 --bfile hbf.data --chr ${chr} --glm sex hide-covar dominant --covar hbf.data-unrelated.cov --covar-name PC1-PC10,AGE --ci 0.95 --adjust --out chr${chr}-dom; done

for chr in {1..22}; do awk '$7=="DOM" {print $1,$2,$3,$4"/"$5,$7,$9,$10,$11,$12,$14}' chr${chr}-dom.PHENO1.glm.linear | grep -v NA; done  > dom.assoc

sort -g -k10 dom.assoc | sed '1 i CHR BP SNP REF/ALT TEST BETA SE L95 U95 P' | bgzip -c > dom.assoc.result.gz

#rec
for chr in {1..22}; do plink2 --bfile hbf.data --chr ${chr} --glm sex hide-covar recessive --covar hbf.data-unrelated.cov --covar-name PC1-PC10,AGE --ci 0.95 --adjust --out chr${chr}-rec; done

for chr in {1..22}; do awk '$7=="REC" {print $1,$2,$3,$4"/"$5,$7,$9,$10,$11,$12,$14}' chr${chr}-rec.PHENO1.glm.linear | grep -v NA; done  > rec.assoc

sort -g -k10 rec.assoc | sed '1 i CHR BP SNP REF/ALT TEST BETA SE L95 U95 P' | bgzip -c > rec.assoc.result.gz

#hethom
for chr in {1..22}; do plink2 --bfile hbf.data --chr ${chr} --glm sex hide-covar hethom --covar hbf.data-unrelated.cov --covar-name PC1-PC10,AGE --ci 0.95 --adjust --out chr${chr}-hethom; done

for chr in {1..22}; do grep -wv NA chr${chr}-hethom.PHENO1.glm.linear | awk '{print $1,$2,$3,$4"/"$5,$7,$9,$10,$11,$12,$14}' | grep -v CHROM; done  > hethom.assoc

sort -g -k10 hethom.assoc | sed '1 i CHR BP SNP REF/ALT TEST BETA SE L95 U95 P' | bgzip -c > hethom.assoc.result.gz

rm chr* add.assoc dom.assoc rec.assoc hethom.assoc

zcat *.assoc.result.gz | grep -v CHR | sort -g -k10 | sed '1 i CHR BP SNP REF/ALT TEST BETA SE L95 U95 P' | bgzip -c > assoc.result.gz

