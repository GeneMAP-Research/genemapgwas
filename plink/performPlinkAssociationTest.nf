#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    getPlinkBinaryFileset;
} from "${projectDir}/modules/base.nf"

include {
    plinkAdditiveAssociation;
    plinkDominantAssociation;
    plinkRecessiveAssociation;
    plinkGenotypicAssociation;
    plinkHethomAssociation;
} from "${projectDir}/modules/associationTests.nf"

workflow {
    println "\nAssociaiton workflow starts here...\n"
    plinkBinaryFileSet = getPlinkBinaryFileset()
    (plinkAssoc_add, plinkAssoc_add_adj, log_file) = plinkAdditiveAssociation(plinkBinaryFileSet)
    (plinkAssoc_dom, plinkAssoc_dom_adj, log_file) = plinkDominantAssociation(plinkBinaryFileSet)
    (plinkAssoc_rec, plinkAssoc_rec_adj, log_file) = plinkRecessiveAssociation(plinkBinaryFileSet)
    (plinkAssoc_geno, plinkAssoc_geno_adj, log_file) = plinkGenotypicAssociation(plinkBinaryFileSet)
    (plinkAssoc_hethom, plinkAssoc_hethom_adj, log_file) = plinkHethomAssociation(plinkBinaryFileSet)
}

