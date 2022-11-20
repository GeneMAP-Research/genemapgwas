#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

workflow {
    println "\nEXTRACT REQUIRED SAMPLES FROM IMPUTED VCF FILES TO MAKE NEW VCFs\n"
    vcf = get_vcf()
    vcf_fileset = getVcfIndex(vcf)
    new_vcf = getNewVcf(vcf_fileset)
    fixVcf(new_vcf).view()
}

def get_vcf() {
    return channel.fromPath( params.vcf_dir + "*.vcf.gz" )
                  .map { vcf -> tuple(vcf.simpleName.replaceAll(/chr/,''), vcf) }
}

process getVcfIndex() {
    tag "BCFTOOLS INDEX: ${input_vcf}"
    label 'bcftools'
    label 'mediumMemory'
    input:
        tuple \
            val(chrom), \
            path(input_vcf)
    output:
        tuple \
            val(chrom), \
            path("${input_vcf}"), \
            path("${input_vcf}.tbi")
    script:
        """
        bcftools \
            index \
            -ft \
            --threads ${task.cpus} \
            ${input_vcf}
        """
}

process getNewVcf() {
    tag "processing ${vcf.baseName}"
    label 'smallMemory'
    label 'bcftools'
    input:
        tuple \
            val(chrom), \
            path(vcf), \
            path(vcf_index)
    output:
        tuple \
            val(chrom), \
            path("chr${chrom}.${params.out_prefix}.tmp.vcf.gz"), \
            path(vcf_index)
    script:
        """
        bcftools \
            view \
            --force-samples \
            -S ${params.sample_list} \
            -v snps,indels \
            -m2 -M2 \
            -i "INFO/${params.r2_name} >= ${params.r2}" \
            --min-af ${params.maf} \
            --max-af ${params.max_af} \
            -Oz \
            -o chr${chrom}.${params.out_prefix}.tmp.vcf.gz \
            --threads ${task.cpus} \
            ${vcf}
        """
}

process fixVcf() {
    tag "BCFTOOLS INDEX: ${input_vcf}"
    label 'bcftools'
    label 'mediumMemory'
    input:
        tuple \
            val(chrom), \
            path(input_vcf), \
            path(vcf_index)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        tuple \
            val(chrom), \
            path("chr${chrom}.${params.out_prefix}.dose.vcf.gz"), \
            path("chr${chrom}.${params.out_prefix}.dose.vcf.gz.tbi")
    script:
        """
        bcftools \
            norm \
            -m +both \
            --threads ${task.cpus} \
            -Oz \
            ${input_vcf} | \
        bcftools \
            view \
            --threads ${task.cpus} \
            -v snps,indels \
            -m 2 \
            -M 2 \
            -O z | \
            tee chr${chrom}.${params.out_prefix}.dose.vcf.gz | \
        bcftools \
            index \
            -ft \
            --threads ${task.cpus} \
            -o chr${chrom}.${params.out_prefix}.dose.vcf.gz.tbi
            
        """
}

