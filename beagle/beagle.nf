#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

workflow {
    println "\nBEAGLE ASSOCIATION\n"
    bed = getPlinkFileset()
    geno = convertPlinkToBeagleFileset(bed).flatten()
    cov = getCovariates(bed)
    cov.combine(geno)
       .set { add_cov_input }
    beagle_input = addCovariatesToBeagleFileset(add_cov_input)
    beagleAssoc(beagle_input).view()
}

def getPlinkFileset() {
    return channel.fromFilePairs( params.bfile + ".{bed,bim,fam}", size: 3 )
}

def getBeagleFileset() {
    return channel.fromPath( params.inputDir + '*.dat' )
}

process convertPlinkToBeagleFileset() {
    tag "processing ${bedName}"
    label 'plink'
    label 'plink_mem'
    input:
        tuple \
            val(bedName), \
            path(bedFileset)
    output:
        publishDir path: "${params.outputDir}/data/", mode: 'copy'
        path "*.dat"
    script:
        """
        plink \
            --bfile ${bedName} \
            --keep-allele-order \
            --maf ${params.maf} \
            --geno ${params.geno} \
            --hwe ${params.hwe} \
            --out ${params.out} \
            --threads ${task.cpus} \
            --recode beagle \
            --not-chr Y,MT
        """
}

process getCovariates() {
    tag "processing ${bedName}"
    label 'r_base'
    label 'plink_mem'
    input:
        tuple \
            val(bedName), \
            path(bedFileset)
    output:
        publishDir path: "${params.outputDir}/data/", mode: 'copy'
        path "*.cov"
    script:
        template 'get_phased_data.r'
}

process addCovariatesToBeagleFileset() {
    tag "processing ${geno}"
    label 'small_mem'
    input:
        tuple \
            path(covar), \
            path(geno)
    output:
        publishDir path: "${params.outputDir}/data/", mode: 'copy'
        path "${geno.baseName}_cov.dat"
    script:
        """
        cat ${covar} ${geno} | sed '1d' > ${geno.baseName}_cov.dat
        """
}

process beagleAssoc() {
    tag "processing ${geno}"
    label 'beagle_mem'
    input:
        path geno
    output:
        publishDir path: "${params.outputDir}", mode: 'copy'
        path "${params.out}*"
    script:
        """
        java \
            -Xmx${task.memory.toGiga()}g \
            -jar \
        ${projectDir}/bin/beagle.jar \
            data=${geno} \
            trait=${params.phenoName} \
            test=adro \
            out=${params.out} \
            nperms=${params.nperms}
        """
//        template 'run_beagle.sh'

}

