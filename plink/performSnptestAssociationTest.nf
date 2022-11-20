#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    getPlinkBinaryFileset;
    getChromosomes;
    getAutosomes;
    getGenFile;
    getSampleFile;
    adjustAssociationTestPvalues as adjustAssociationTestPvalues_add;
    adjustAssociationTestPvalues as adjustAssociationTestPvalues_dom;
    adjustAssociationTestPvalues as adjustAssociationTestPvalues_rec;
    adjustAssociationTestPvalues as adjustAssociationTestPvalues_geno;
    adjustAssociationTestPvalues as adjustAssociationTestPvalues_hethom;
} from "${projectDir}/modules/base.nf"

include {
    snptestFrequentistAdditiveAssociation;
    snptestFrequentistDominantAssociation;
    snptestFrequentistRecessiveAssociation;
    snptestFrequentistHeterozygoteAssociation;
    snptestFrequentistGeneralAssociation; 
} from "${projectDir}/modules/associationTests.nf"

workflow {
    println "\nAssociaiton workflow starts here...\n"
    genFile = getGenFile().view()
    sampleFile = getSampleFile().view()
    snptestAssoc_add = snptestFrequentistAdditiveAssociation(geneFile, sampleFile)
    //adjusted_results_add = adjustAssociationTestPvalues_add(plinkAssoc_add).view()

}

