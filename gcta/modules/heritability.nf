def get_bed_prefix() {
    return channel.fromFilePairs( params.base_dir + params.bfile + '.{bed,bim,fam}', size: 3 )
}

def get_chromosome() {
    return channel.of(1..22, 'X')
}

def get_qcovar() {
    return channel.fromPath(params.qcovar)
}

def get_catcovar() {
    return channel.fromPath(params.catcovar)
}

process get_pheno_file() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'smallMemory'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}.pheno")
    script:
        """
        awk '{print \$1,\$2,\$6}' \
            ${bed_name}.fam > \
            ${bed_name}.pheno
        """
}

process split_bfile_by_chr() {
    tag "processing chromosome ${chrom}"
    cache 'lenient'
    label 'smallMemory'
    label 'plink2'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set), \
            val(chrom)
    output:
        tuple \
            val("${bed_name}_chr${chrom}"), \
            path("${bed_name}_chr${chrom}.{bed,bim,fam}")
    script:
        """
        plink2 \
            --bfile ${bed_name} \
            --make-bed \
            --mac 3 \
            --geno 0.05 \
            --chr ${chrom} \
            --out ${bed_name}_chr${chrom} \
            --thread-num ${task.cpus}

        if [ ${chrom} == "X" ]; then 
            sed -i 's/X/23/1' "${bed_name}_chr${chrom}.bim";
        fi
        """
}

process get_ld_scores() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_ld'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
    output:
        tuple \
            val(bed_name), \
            path("${bed_name}.score.ld")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --ld-score-region ${params.ld_score_region} \
            --ld-rsq-cutoff ${params.ld_rsq_cutoff} \
            --out ${bed_name} \
            --thread-num ${task.cpus}
        """
}

process segment_snps_by_ld_score() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'mediumMemory'
    label 'r_base'
    input:
        tuple \
            val(bed_name), \
            path(ld_score)
    output:
        tuple \
            val(bed_name), \
            path("${bed_name}_ld_snp_group1.txt"), \
            path("${bed_name}_ld_snp_group2.txt"), \
            path("${bed_name}_ld_snp_group3.txt"), \
            path("${bed_name}_ld_snp_group4.txt")
    script:
        template "segment_ld_score.r"
}

process get_grm() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(ld_score), \
            path(bfile_set)
    output:
        tuple \
            val(bed_name), \
            path("${ld_score.baseName}.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-gz \
            --extract ${ld_score} \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out ${ld_score.baseName} \
            --thread-num ${task.cpus}
        """
}

process get_grm_first_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(ld_score), \
            path(bfile_set)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${ld_score.baseName}_maf_group1.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-gz \
            --maf 0.2 \
            --extract ${ld_score} \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${ld_score.baseName}_maf_group1" \
            --thread-num ${task.cpus}
        """
}

process get_grm_second_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(ld_score), \
            path(bfile_set)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${ld_score.baseName}_maf_group2.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-gz \
            --maf 0.05 \
            --max-maf 0.2 \
            --extract ${ld_score} \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${ld_score.baseName}_maf_group2" \
            --thread-num ${task.cpus}
        """
}

process get_grm_third_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(ld_score), \
            path(bfile_set)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${ld_score.baseName}_maf_group3.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-gz \
            --maf 0.005 \
            --max-maf 0.05 \
            --extract ${ld_score} \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${ld_score.baseName}_maf_group3" \
            --thread-num ${task.cpus}
        """
}

/*
*  process get_grm_fourth_maf_bin() {
*      tag "processing ${bed_name}"
*      cache 'lenient'
*      label 'gcta_grm'
*      input:
*          tuple \
*              val(bed_name), \
*              path(ld_score), \
*              path(bfile_set)
*      output:
*          publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
*          tuple \
*              val(bed_name), \
*              path("${ld_score.baseName}_maf_group4.{grm.gz,grm.id}")
*      script:
*          """
*          gcta64 \
*              --bfile ${bed_name} \
*              --make-grm-gz \
*              --maf 0.1 \
*              --max-maf 0.2 \
*              --extract ${ld_score} \
*              --qcovar ${params.qcovar} \
*              --covar ${params.catcovar} \
*              --out "${ld_score.baseName}_maf_group4" \
*              --thread-num ${task.cpus}
*          """
*  }
*  
*  process get_grm_fifth_maf_bin() {
*      tag "processing ${bed_name}" 
*      cache 'lenient'
*      label 'gcta_grm' 
*      input:
*          tuple \
*              val(bed_name), \
*              path(ld_score), \
*              path(bfile_set) 
*      output:
*          publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
*          tuple \
*              val(bed_name), \
*              path("${ld_score.baseName}_maf_group5.{grm.gz,grm.id}")
*      script:
*          """
*          gcta64 \
*              --bfile ${bed_name} \
*              --make-grm-gz \
*              --maf 0.2 \
*              --max-maf 0.3 \
*              --extract ${ld_score} \
*              --qcovar ${params.qcovar} \
*              --covar ${params.catcovar} \
*              --out "${ld_score.baseName}_maf_group5" \
*              --thread-num ${task.cpus}
*          """
*  }
*  
*  process get_grm_sixth_maf_bin() {
*      tag "processing ${bed_name}" 
*      cache 'lenient'
*      label 'gcta_grm' 
*      input:
*          tuple \
*              val(bed_name), \
*              path(ld_score), \
*              path(bfile_set) 
*      output:
*          publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
*          tuple \
*              val(bed_name), \
*              path("${ld_score.baseName}_maf_group6.{grm.gz,grm.id}")
*      script:
*          """
*          gcta64 \
*              --bfile ${bed_name} \
*              --make-grm-gz \
*              --maf 0.3 \
*              --max-maf 0.4 \
*              --extract ${ld_score} \
*              --qcovar ${params.qcovar} \
*              --covar ${params.catcovar} \
*              --out "${ld_score.baseName}_maf_group6" \
*              --thread-num ${task.cpus}
*          """
*  }
*  
*  process get_grm_seventh_maf_bin() {
*      tag "processing ${bed_name}" 
*      cache 'lenient'
*      label 'gcta_grm' 
*      input:
*          tuple \
*              val(bed_name), \
*              path(ld_score), \
*              path(bfile_set) 
*      output:
*          publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
*          tuple \
*              val(bed_name), \
*              path("${ld_score.baseName}_maf_group7.{grm.gz,grm.id}")
*      script:
*          """
*          gcta64 \
*              --bfile ${bed_name} \
*              --make-grm-gz \
*              --maf 0.4 \
*              --max-maf 0.5 \
*              --extract ${ld_score} \
*              --qcovar ${params.qcovar} \
*              --covar ${params.catcovar} \
*              --out "${ld_score.baseName}_maf_group7" \
*              --thread-num ${task.cpus}
*          """
*  }
*/
  
process unify_grms() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(grms)
    output:
        publishDir path: "${params.output_dir}/grm_per_chrom/", mode: 'copy'
        path "${bed_name}.{grm.gz,grm.id}"
    script:
        """
        ls *.grm.gz | \
            sort -V | \
            sed 's/.grm.gz//g' \
            > "${bed_name}_multigrms.txt"

        gcta64 \
            --mgrm-gz "${bed_name}_multigrms.txt" \
            --make-grm-gz \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}" \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_chrom/", mode: 'copy'
        path "${bed_name}.{grm.gz,grm.id}"
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out ${bed_name} \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm_first_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}_maf_group1.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --maf 0.2 \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}_maf_group1" \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm_second_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}_maf_group2.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --maf 0.05 \
            --max-maf 0.2 \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}_maf_group2" \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm_third_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}_maf_group3.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --maf 0.005 \
            --max-maf 0.05 \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}_maf_group3" \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm_fourth_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}_maf_group4.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --maf 0.1 \
            --max-maf 0.2 \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}_maf_group4" \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm_fifth_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}_maf_group5.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --maf 0.2 \
            --max-maf 0.3 \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}_maf_group5" \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm_sixth_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}_maf_group6.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --maf 0.3 \
            --max-maf 0.4 \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}_maf_group6" \
            --thread-num ${task.cpus}
        """
}

process get_xchr_grm_seventh_maf_bin() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
            //val(chrom)
    output:
        publishDir path: "${params.output_dir}/grm_per_maf_bin/", mode: 'copy'
        tuple \
            val(bed_name), \
            path("${bed_name}_maf_group7.{grm.gz,grm.id}")
    script:
        """
        gcta64 \
            --bfile ${bed_name} \
            --make-grm-xchr-gz \
            --maf 0.4 \
            --max-maf 0.5 \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out "${bed_name}_maf_group7" \
            --thread-num ${task.cpus}
        """
}

process unify_xchr_grms() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_grm'
    input:
        tuple \
            val(bed_name), \
            path(bfile_set)
    output:
        publishDir path: "${params.output_dir}/grm_per_chrom/", mode: 'copy'
        path "${bed_name}.{grm.gz,grm.id}"
    script:
        """
        ls *.grm.gz | \
            sort -V | \
            sed 's/.grm.gz//g' \
            > "${bed_name}_multigrms.txt"

        gcta64 \
            --mgrm-gz "${bed_name}_multigrms.txt" \
            --make-grm-xchr-gz \
            --qcovar ${params.qcovar} \
            --covar ${params.catcovar} \
            --out ${bed_name} \
            --thread-num ${task.cpus}
        """
}

process estimate_heritabiltiy() {
    tag "processing ${bed_name}"
    cache 'lenient'
    label 'gcta_ld'
    input:
        tuple \
            val(bed_name), \
            path(pheno), \
            path(catcov), \
            path(qcov)
        path grm_file_set
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        tuple \
            val(bed_name), \
            path("*")
    script:
        """
        ls *.grm.gz | \
            sort -V | \
            sed 's/.grm.gz//g' \
            > multi_GRMs.txt

        gcta64 \
            --reml \
            --pheno ${pheno} \
            --mgrm-gz multi_GRMs.txt \
            --qcovar ${qcov} \
            --covar ${catcov} \
            --reml-no-constrain \
            --out ${bed_name} \
            --thread-num ${task.cpus}
        """
}
