#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

workflow {
    println "\nSUSiE FINE-MAPPING\n"

    getsumstats()view().set { sum_stat }
    getcormatrix().view().set { ld_mat }
    sum_stat.combine(ld_mat).set { finemap_input }

    //testprocess()

    finemap(finemap_input).view()
}

def getsumstats() {
    return channel.fromPath(params.sum_stats)
}

def getcormatrix() {
    return channel.fromPath(params.ld_matrix)
}

process testprocess {
    tag "susie test script"
    label 'susie'
    label 'tinyMemory'
    output:
        path "*.png"
        path "*.txt"
    script:
        template 'susie.r'
}

/*
process finemapFromBeta {
    tag "susie test script"
    label 'susie'
    label 'mediumMemory'
    input:
        tuple \
            path(sum_stat), \
            path(ld_mat)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        tuple \
            path("*.pdf"), \
            path("*.txt")
    script:
        template 'finemap.r'
}
*/

process finemap {
    tag "processing ${sum_stat.baseName}"
    label 'susie'
    label 'mediumMemory'
    input:
        tuple \
            path(sum_stat), \
            path(ld_mat)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        tuple \
            path("*.pdf"), \
            path("*.txt")
    script:
        template 'finemap.r'
}
