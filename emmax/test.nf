#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

workflow {
    println "\nTEST INPUT TYPE\n"
    getbedFileset().view()
}

workflow.onComplete {
    println "\nPipeline completed at: $workflow.complete"
    println "Execution status: ${ workflow.success ? 'OK' : 'failed' }\n"
}

workflow.onError {
    println "\nOops... Pipeline execution stopped with the following message: ${workflow.errorMessage}\n"
}

def getbedFileset() {
    return channel.fromFilePairs( params.input_dir + "*.{bed,bim,fam,cov}", size: 4 )
                  .ifEmpty { error "\nERROR: Could not locate a file!\n" }
                  .map { bedName, bedFileset -> tuple(bedName, bedFileset) }
}

process testPro() {
    echo true
    input:
        tuple \
            val(bamName), \
            path(bamFileset)
    output:
        publishDir path: "${params.outputDir}/testOutput/"
        path "test.txt"
    script:
        (bamFile, bamIndex) = bamFileset
        """
        echo ${bamFile}
        echo ${bamIndex}
        echo "Bam name: ${bamName}" > test.txt
        """
}
