#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    getVcf;
    getChainFile;
    liftBuildToHg38;
} from "${projectDir}/modules/gtcalls.nf"

workflow {
    println "\nLIFT OVER TO BUILD 38 [GRCh38]\n"
    vcf = getVcf().view()
    chain = getChainFile().view()
    vcf.combine(chain)
       .set { lift_over_input }
    liftBuildToHg38(lift_over_input).view()
}
