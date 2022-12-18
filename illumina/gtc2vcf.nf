#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    getRef;
    getManisfestBpm;
    getManisfestCsv;
    getClusterFile;
    convertGtc2vcf;
    convertGtc2vcfHg38;
} from "${projectDir}/modules/gtcalls.nf"

workflow {
    println "\nILLUMINA GENOTYPE CALLING\n"
    //manifest_bpm = getManisfestBpm()
    //manifest_csv = getManisfestCsv()
    //cluster = getClusterFile()
    //gtcs = getGtcs()
    //manifest_bpm
    //    .combine(cluster)
    //    .combine(intensity)
    //    .set { gtc_input }

    //convertGtc2vcf()
    convertGtc2vcfHg38()
}
