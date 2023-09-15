#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {

	get_gtc;
	convert_gtc_to_vcf;
	convert_gtc_to_vcf_hg38;
} from "${projectDir}/modules/gtcalls.nf"

workflow {
	println "\nILLUMINA GENOTYPE CALLING\n"



	if(params.build_ver == 'hg19') {
		convert_gtc_to_vcf()
	}
	else {
		convert_gtc_to_vcf_hg38()
	}
}
