#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    getRef;
    getManisfestBpm;
    getManisfestCsv;
    getClusterFile;
    getIntensities;
    getGtc;
} from "${projectDir}/modules/gtcalls.nf"

workflow {
    println "\nILLUMINA GENOTYPE CALLING\n"
    manifest_bpm = getManisfestBpm()
    cluster = getClusterFile()
    intensity = getIntensities()
    manifest_bpm
        .combine(cluster)
        .combine(intensity)
        .set { gtcall_input }
    gtc_list = getGtc(gtcall_input).collect().flatten().view()
}
