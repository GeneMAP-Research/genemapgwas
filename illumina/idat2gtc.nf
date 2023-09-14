#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    get_manisfest_bpm;
    get_manisfest_csv;
    get_cluster_file;
    get_intensities;
    get_gtc;
} from "${projectDir}/modules/gtcalls.nf"


workflow {
    println "\nILLUMINA GENOTYPE CALLING\n"
    manifest_bpm = get_manisfest_bpm()
    cluster = get_cluster_file()
    intensity = get_intensities()
    manifest_bpm
        .combine(cluster)
        .combine(intensity)
        .set { gtcall_input }
    gtc_list = get_gtc(gtcall_input).collect().flatten().view()
}
