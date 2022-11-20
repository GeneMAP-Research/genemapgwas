#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    getPlinkBinaryFileset;
    getChromosomes;
} from "${projectDir}/modules/base.nf"

include {
    boltLmmAssociation;
} from "${projectDir}/modules/associationTests.nf"

workflow {
    println "\nAssociaiton workflow starts here...\n"
    plinkBinaryFileSet = getPlinkBinaryFileset()
    boltAssoc = boltLmmAssociation(plinkBinaryFileSet).view()
}

