#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
nextflow.enable.moduleBinaries = true

workflow {
  println "\nDATA-KGP MERGE\n"

  getChromosome()
    .set { chrom }

  getThousandGenomesReference()
    .map { chr, ref_vcf, ref_index -> tuple("${chr}", ref_vcf, ref_index) }
    .set { kgp }

  getVcf()
    .set { vcf }

  chrom
    .combine( vcf )
    .set { chrom_vcf }

  splitVcfByChrom( chrom_vcf )
    .set { per_chrom_vcf }

  indexVcf(per_chrom_vcf)
    .map { chr, vcf, index -> tuple("${chr}", vcf, index) }
    .set { per_chrom_vcf_index }

  per_chrom_vcf_index
    .join( kgp, by: 0 )
    .set { vcf_kgp }

  getStudyReferenceVcfIntersect(vcf_kgp)
    .set { vcf_intersect }
  
  mergeStudyReferenceVcf(vcf_intersect)
    .collect()
    .set { merged_vcf }

  concatenateVcf(merged_vcf)   
    .set { multi_chrom_merged_vcf }

  getStudyPopFile()
    .set { study_pop_file }

  getStudyKgpPopFile(study_pop_file)
    .combine(multi_chrom_merged_vcf)
    .set { pcs_input }

  computePcs(pcs_input)
    .set { popfile_and_pcs }

  /* getStudyKgpPopFile(study_pop_file)
    .combine(pcs).view()
    .map { pop, pcs -> tuple(pop, pcs) }
    .set { popfile_and_pcs } */

  plotPca(popfile_and_pcs).view()
}


def getChromosome() {
  if( params.autosome == true ) {
    return channel.of( 1..22 )
  }
  else {
    return channel.of( 1..22, 'X' )
  }
}

def getVcf() {
  return channel.fromPath( params.vcf )
}

def getThousandGenomesReference() {
  return \
    channel
      .fromFilePairs( params.ref_dir + "chr*1kg.phase3.v5a.vcf.{gz,gz.tbi}", size: 2 )
        .ifEmpty { error: println "\nAn error occurred! Please check that the reference file and its index '.tbi' exist...\n" }
        .map { 
           chr, ref_file -> 
            tuple( chr.replaceFirst(/chr/,""), ref_file.first(), ref_file.last())
        }
}

def getStudyPopFile() {
  return channel.fromPath( params.pop_file )
}


process splitVcfByChrom() {
    tag "processing chr${chrom}"
    label 'plink2'
    label 'split_vcf'
    cache 'lenient'
    input:
        tuple \
            val(chrom), \
            path(input_vcf)
    output:
        tuple \
            val(chrom), \
            path("chr${chrom}.vcf.gz")
    script:
        """
        plink2 \
            --vcf ${input_vcf} \
            --maf 0.0001 \
            --geno 0.10 \
            --hwe 1e-06 \
            --chr ${chrom} \
            --vcf-half-call missing \
            --export vcf-4.2 bgz id-paste='iid' \
            --threads ${task.cpus} \
            --aec \
            --out "chr${chrom}"
        """
}

process indexVcf() {
  tag "processing ${input_vcf}"
  label 'bcftools'
  cache 'lenient'
  input:
    tuple \
      val(chrom), \
      path(input_vcf)
  output:
    tuple \
      val(chrom), \
      path("chr${chrom}.vcf.gz"), \
      path("chr${chrom}.vcf.gz.tbi")
  script:
    """
    bcftools \
      index \
      -ft \
      --threads ${task.cpus} \
      ${input_vcf}
    """
}

process getStudyReferenceVcfIntersect() {
  tag "processing ${vcf}"
  label 'bcftools'
  label 'intersect'
  cache 'lenient'
  input:
    tuple \
      val(chrom), \
      path(vcf), \
      path(vcf_index), \
      path(ref_vcf), \
      path(ref_index)
  output:
    tuple \
      val(chrom), \
      path("0000.vcf.gz"), \
      path("0000.vcf.gz.tbi"), \
      path("0001.vcf.gz"), \
      path("0001.vcf.gz.tbi")
  script:
    """
    bcftools \
      isec \
      -n=2 \
      --threads ${task.cpus} \
      -p . \
      -Oz \
      ${vcf} \
      ${ref_vcf}
    """ 
}

process mergeStudyReferenceVcf() {
  tag "processing ${chrom}"
  label 'bcftools'
  label 'intersect'
  cache 'lenient'
  input:
    tuple \
      val(chrom), \
      path(vcf), \
      path(vcf_index), \
      path(ref_vcf), \
      path(ref_index)
  output:
    tuple \
      path("chr${chrom}_study_ref_merged.vcf.gz"), \
      path("chr${chrom}_study_ref_merged.vcf.gz.tbi")
  script:
    """
    bcftools \
      merge \
      --threads ${task.cpus} \
      -Oz \
      ${vcf} \
      ${ref_vcf} | \
    bcftools \
      norm \
      -m+ \
      --threads ${task.cpus} | \
    bcftools \
      view \
      -v snps \
      -m 2 \
      -M 2 \
      --threads ${task.cpus} \
      -Oz | \
    tee chr${chrom}_study_ref_merged.vcf.gz | \
    bcftools \
      index \
      -ft \
      --threads ${task.cpus} \
      -o chr${chrom}_study_ref_merged.vcf.gz.tbi
    """
}

process concatenateVcf() {
  tag "Concatenating per chromosome VCFs"
  label 'bcftools'
  label 'intersect'
  cache 'lenient'
  publishDir \
    path: "${params.output_dir}", \
    mode: 'copy'
  input:
      path(merged_vcfs)
  output:
    tuple \
      path("study_ref_merged.vcf.gz"), \
      path("study_ref_merged.vcf.gz.tbi")
  script:
    """
    bcftools \
      concat \
      -a \
      --threads ${task.cpus} \
      -d all \
      -Oz \
      chr{1..22}_study_ref_merged.vcf.gz | \
    tee study_ref_merged.vcf.gz | \
    bcftools \
      index \
      -ft \
      --threads ${task.cpus} \
      -o study_ref_merged.vcf.gz.tbi
    """
}

process getStudyKgpPopFile() {
  tag "Creating pop file for plotting"
  cache 'lenient'
  input:
    path(popfile)
  output:
    path("pop_file.txt")
  script:
  if(params.pop_group != 'NULL')
    """
    cat \
      ${popfile} \
      ${params.kgp_pop} \
      > pop.txt

    pop=\$(echo ${params.pop_group} | tr [:lower:] [:upper:])

    if [[ \${pop} == "AFR" ]]; then
      grep \
        -w \${pop} \
        pop.txt | \
      grep \
        -v \
        -e "ASW" \
        -e "ACB" \
        > pop_file.txt
    else      
      grep \
        -w \${pop} \
        pop.txt \
        > pop_file.txt
    fi
    """
  else
    """
    cat ${popfile} ${params.kgp_pop} > pop.txt
    for pop in AFR AMR EUR SAS EAS; do
      grep -w \${pop} pop.txt;
    done > pop_file.txt
    """
}



process removeDuplicateSamples() {
    tag "checking related and duplicate individuals..."
    //publishDir \
    //    path: "${params.output_dir}/qc/relatedness/",
    //    mode: 'copy'
    label 'king'
    input:
        tuple \
            path(vcf), \
            path(index)
    output:
        tuple \
            path("${params.out}_fail-relatedness-qc.txt"), \
            path("${params.out}_king.seg"), \
            path("${params.out}_king_ibd1vsibd2.ps")
    script:
        """
        king \
            -b ${bed} \
            --ibdseg \
            --degree 4 \
            --rplot \
            --prefix ${params.out}_king

        awk '(\$8 == "Dup/MZ") || (\$8 == "FS") || (\$8 == "PO") || (\$8 == "2nd") {print \$1,\$2}' ${params.out}_king.seg | \
        sort | \
        uniq > ${params.out}_fail-relatedness-qc.txt
        """
}


process computePcs() {
 tag "processing ${vcf}"
 label 'plink'
 label 'split_vcf'
 cache 'lenient'
 input:
   tuple \
     path(popfile), \
     path(vcf), \
     path(index)
 output:
   tuple \
     path(popfile), \
     path("${params.output_prefix}.pca.txt")
 script:
   """
   awk '{print \$1,\$1,\$2,\$3}' ${popfile} > popfile.plink.txt

   test_ascertainmnet="${params.ascertain_pop}"

   if [[ "\${test_ascertainmnet}" == "NULL" ]] || [[ "\${test_ascertainmnet}" == "" ]]; then
      ascertainment_pop="popfile.plink.txt"
   else
      grep -wi ${params.ascertain_pop} popfile.plink.txt > ascertainment_pop.txt
      ascertainment_pop="ascertainment_pop.txt"
   fi

   # the KING cutoff removes duplicates/monozygotic twins
   # 0.354 - Dup/MZ
   # [0.177, 0.354] - 1st degree
   # [0.0884, 0.177] - 2nd degree
   # [0.0442, 0.0884] - 3rd degree
   # see https://www.kingrelatedness.com/manual.shtml

   plink2 \
     --vcf ${vcf} \
     --maf 0.01 \
     --geno 0.05 \
     --keep popfile.plink.txt \
     --vcf-half-call missing \
     --double-id \
     --snps-only just-acgt \
     --max-alleles 2 \
     --min-alleles 2 \
     --threads ${task.cpus} \
     --aec \
     --chr 1-22 \
     --make-bed \
     --out temp1

   plink \
     --bfile temp1 \
     --hwe 1e-06 \
     --threads ${task.cpus} \
     --make-bed \
     --out temp2

   plink2 \
     --bfile temp2 \
     --king-cutoff 0.185 \
     --threads ${task.cpus} \
     --make-bed \
     --out temp

   plink2 \
     --bfile temp \
     --maf 0.01 \
     --geno 0.02 \
     --hwe 1e-06 \
     --keep \${ascertainment_pop} \
     --indep-pairwise 50 10 0.2 \
     --threads ${task.cpus} \
     --out pruned

   plink2 \
     --bfile temp \
     --extract pruned.prune.in \
     --pca 5 \
     --out ${params.output_prefix}

   sed 's|#FID|FID|1' ${params.output_prefix}.eigenvec > ${params.output_prefix}.pca.txt
   """
}

process plotPca() {
  tag "Plotting PCA"
  label 'rbase'
  cache 'lenient'
  publishDir \
    path: "${params.output_dir}", \
    mode: 'copy'
  input:
    tuple \
      path(popfile), \
      path(pcs)
  output:
      path("*")
   script:
     template 'plot_pca.2.r'
}


