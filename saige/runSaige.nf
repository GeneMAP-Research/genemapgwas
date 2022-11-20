#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    getGlmmBfileset;
    getLdBfileset;
    getSpaBfileset;
    getVcf;
    getVcfIndex;
    getNullGlmm;
    generateSparseGrm;
    getVarianceRatioFile;
    saigeSPAtest;
    saigeConditionalSPAtest;
    adjustSaigePvalues;
    saigeSPAtestVcf;
    saigeConditionalSPAtestVcf;
    concatenateSaigeResults;
    formatSaigeResultForPlotting;
    formatSaigeResultForAnnotation;
    getSaigeResultVcf;
    plotSaigeResults;
} from "${projectDir}/modules/saige.nf"

workflow {
    println "\nSAIGE WORKFLOW\n"


/*
*    //ldbfile = getLdBfileset().view()
*    //grm = generateSparseGrm(ldbfile).view()
*
*    if(params.condition == false) {
*        bfile = getGlmmBfileset()
*        nullglmm = getNullGlmm(bfile)
*        spabfile = getSpaBfileset()
*        spabfile.combine(nullglmm).view().set { spa_test_input }
*        saigeSPAtest(spa_test_input).view()
*    }
*    else {
*        bfile = getGlmmBfileset()
*        nullglmm = getNullGlmm(bfile)
*        spabfile = getSpaBfileset()
*        spabfile.combine(nullglmm).view().set { spa_test_input }
*        saigeSPAConditionalTest(spa_test_input).view()
*    }
***********************************************************************/

    if(params.file_type.toUpperCase() == "VCF" & params.conditional_test == false) {
       getVcf()
           .set { saige_assoc_input }

       saigeResult = saigeSPAtestVcf(saige_assoc_input)
       adjustedSaigeResult = adjustSaigePvalues(saigeResult)
       //assoc_result = concatenateSaigeResults(adjustedSaigeResult)
    } 
    else if(params.file_type.toUpperCase() == "VCF" & params.conditional_test == true) {

       getVcf()
           .map { chr, vcf, index -> tuple("${chr}", vcf, index) }
           .set { vcf_fileset }
       channel
           .of(params.chrom)
           .map { chr -> tuple("${chr}") }
           .set { chrom }
       chrom
           .join(vcf_fileset).view().set { saige_assoc_input }

       saigeResult = saigeConditionalSPAtestVcf(saige_assoc_input).collect().view()
       adjustedSaigeResult = adjustSaigePvalues(saigeResult)
       //assoc_result = concatenateSaigeResults(adjustedSaigeResult)
    } 
    else if(params.file_type.toUpperCase() == "BED") {

        if(params.condition == false) {
            bfile = getGlmmBfileset()
            nullglmm = getNullGlmm(bfile)
            spabfile = getSpaBfileset()
            spabfile.combine(nullglmm).view().set { spa_test_input }
            saigeSPAtest(spa_test_input).view()
        }
        else {
            bfile = getGlmmBfileset()
            nullglmm = getNullGlmm(bfile)
            spabfile = getSpaBfileset()
            spabfile.combine(nullglmm).view().set { spa_test_input }
            saigeSPAConditionalTest(spa_test_input).view()
        }

    } else { error: println "\nERROR: Please specify a file type '--file_type <BED|VCF>'\n" }

//    formatted_for_plotx = formatSaigeResultForPlotting(assoc_result).view()
//    formatted_for_ann = formatSaigeResultForAnnotation(assoc_result).view()
//    plotSaigeResults(formatted_for_plotx).view()
//    getSaigeResultVcf(formatted_for_ann).view()

}
