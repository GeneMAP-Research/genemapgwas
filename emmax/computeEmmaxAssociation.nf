#!/usr/bin/env nextflow

nextflow.enable.dsl = 2



include {
    getbedFileset;
    getTfile;
    getKinship;
    performAssociationTest;
    formatEmmaxResult;
    adjustEmmaxPvalue;
    getTopHitsVcf;
    plotAssocResult;
} from "${projectDir}/modules/emmaxAssoc.nf"



workflow {
    println "\nEMMAX ASSOCIATION TEST\n"
    bed = getbedFileset()
    tfile = getTfile(bed)
    assoc_input = getKinship(tfile)
    emmax_assoc = performAssociationTest(assoc_input)
    emmax_assoc
        .join(bed)
        .set { format_input }
    emmax_result_formated = formatEmmaxResult(format_input)
    getTopHitsVcf(emmax_result_formated)
    adjustEmmaxPvalue(emmax_result_formated)
    plotAssocResult(emmax_result_formated).view()
}

