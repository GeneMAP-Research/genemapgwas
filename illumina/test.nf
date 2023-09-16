#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

workflow {
  println "IDAT to VCF: TEST"
  println ""
  println "       IDAT DIR = ${params.idat_dir}"
  println "   BPM MANIFEST = ${params.manifest_bpm}"
  println "   CSV MANIFEST = ${params.manifest_csv}"
  println "   CLUSTER FILE = ${params.cluster_file}"
  println "  BUILD VERSION = ${params.build_ver}"

  if(params.build_ver == 'hg19') {
    println "    REFERENCE = ${params.fasta_ref}"
  }
  else {
    println "    REFERENCE = ${params.fasta_ref}"
    println "BAM ALIGNMENT = ${params.bam_alignment}"
  }

  println "  OUTPUT PREFIX = ${params.output_prefix}"
  println "     OUTPUT DIR = ${params.output_dir}"
  println "ACCOUNT/PROJECT = ${params.account}"
  println "QUEUE/PARTITION = ${params.partition}"
  println " CONTAINERS DIR = ${params.containers_dir}"
  println ""
  
  //call_genotypes()
  plink()
  //display_text()
	
}



workflow.onComplete { 
  println "Workflow completed at: ${workflow.complete}"
  println "     Execution status: ${ workflow.success ? 'OK' : 'failed'}"
}

workflow.onError{
  println "workflow execution stopped with the following message: ${workflow.errorMessage}"
}

process call_genotypes() {
  tag "processing ... ${params.idat_dir}"
  label 'gencall'
  publishDir path: "${params.output_dir}/test"
  //debug true
  echo true
  
  script:
    """		
    iaap-cli \
      gencall \
      --help
    """
}

process plink() {

  // directives
  tag "processing ... ${params.idat_dir}"
  label 'plink2'
  label 'idat_to_gtc'
  publishDir path: "${params.output_dir}/output"
  //debug true
  echo true
  
  script:
    """
    plink2 \
    --help \
    --file
    """
}

process display_text() {
  echo true
  script:
    """
    echo text
    """
}
