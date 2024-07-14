#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
//nextflow.enable.moduleBinaries = true

include {
    jobCompletionMessage;
    getBed;
    checkDuplicateSampleIds;
    removeDuplicateVars;
    getKingFormatFile;
    checkDuplicateAndRelatedIndivs;
    checkDiscordantSex;
    computeSampleMissingnesStats;
    checkSamplesMissingess;
    removePoorQualitySamples;
    checkPoorQualityVariants;
    checkPalindromes;
    removePoorQualityVariants;
    performPca;
    plotPca;
} from "${projectDir}/modules/qc.mdl"

workflow {
    println "\nGeneMAP GWAS QC WORKFLOW\n"

    getBed()
        .set { bed }
    checkDuplicateSampleIds(bed)
        .set { unique_samples }
    removeDuplicateVars(bed, unique_samples)
        .set { bfile }
    getKingFormatFile(bfile)
        .set { king_bed }
    checkDuplicateAndRelatedIndivs(king_bed)
        .set { king_out }
    checkDiscordantSex(bfile, king_out)
        .set { bed_related_removed }
    computeSampleMissingnesStats(bed_related_removed)
        .set { missingness }
    checkSamplesMissingess(missingness)
        .set { fail_missingness }
    removePoorQualitySamples(bed_related_removed, fail_missingness)
        .set { bed_pass_sample_qc }
    checkPoorQualityVariants(bed_pass_sample_qc)
        .set { bed_temp }
    checkPalindromes(bed_temp)
        .set { bed_palindromes }
    removePoorQualityVariants(bed_palindromes)
        .set { bed_pass_qc }
    performPca(bed_pass_qc)
        .set { evec_eval }
    plotPca(evec_eval)
}

workflow.onComplete {
    msg = jobCompletionMessage()
    if(params.email == 'NULL') {
        println msg
    } 
    else {
        println msg
        sendMail(
            from: 'eshkev001@myuct.ac.za',
            to: params.email,
            subject: 'genemapgwas qc execution status',
            body: msg
        )
    }
}

