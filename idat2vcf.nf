#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
nextflow.enable.moduleBinaries = true

include {
  get_manisfest_bpm;
  get_manisfest_csv;
  get_cluster_file;
  get_intensities;
  convert_idat_to_gtc;
  get_gtc_list;
  convert_gtc_to_vcf_hg19;
  convert_gtc_to_vcf_hg38;
} from "${projectDir}/modules/gtcalls.mdl"


workflow {

  println "\nILLUMINA GENOTYPE CALLING\n"

  manifest_bpm = get_manisfest_bpm()
  cluster = get_cluster_file()
  intensity = get_intensities()
  manifest_bpm
    .combine(cluster)
    .combine(intensity)
    .set { gtcall_input }

  gtc_list = convert_idat_to_gtc(gtcall_input).collect()
  gtc_file_list = get_gtc_list(gtc_list)

  if(params.build_ver == 'hg38') {
    convert_gtc_to_vcf_hg38(gtc_file_list)
  }
  else {
    convert_gtc_to_vcf_hg19(gtc_file_list)
  }

}
