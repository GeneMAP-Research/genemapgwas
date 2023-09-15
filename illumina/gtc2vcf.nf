#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
	get_ref;
	get_manisfest_bpm;
	get_manisfest_csv;
	get_cluster_file;
	get_intensities;
	get_gtc;
	convert_gtc_to_vcf;
	convert_gtc_to_vcf_hg38;
} from "${projectDir}/modules/gtcalls.nf"

workflow {
	println "\nILLUMINA GENOTYPE CALLING\n"

	manifest_bpm = get_manisfest_bpm()
	manifest_csv = get_manisfest_csv()
	cluster = get_cluster_file()
	gtcs = get_gtc()
	manifest_bpm
	    .combine(cluster)
	    .combine(intensity)
	    .set { gtc_input }

	if(params.build_ver == 'hg19') {
		convert_gtc_to_vcf()
	}
	else {
		convert_gtc_to_vcf_hg38()
	}
}
