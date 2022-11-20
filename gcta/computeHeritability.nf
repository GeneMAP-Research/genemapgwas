#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include {
    get_bed_prefix;
    get_chromosome;
    get_catcovar;
    get_qcovar;
    split_bfile_by_chr;
    split_bfile_by_chr as split_xchr;
    get_ld_scores;
    segment_snps_by_ld_score;
    get_pheno_file;
    get_grm;
    get_xchr_grm;
    get_xchr_grm_first_maf_bin;
    get_xchr_grm_second_maf_bin;
    get_xchr_grm_third_maf_bin;
    //get_xchr_grm_fourth_maf_bin;
    //get_xchr_grm_fifth_maf_bin;
    //get_xchr_grm_sixth_maf_bin;
    //get_xchr_grm_seventh_maf_bin;
    get_grm_first_maf_bin;
    get_grm_second_maf_bin;
    get_grm_third_maf_bin;
    //get_grm_fourth_maf_bin;
    //get_grm_fifth_maf_bin;
    //get_grm_sixth_maf_bin;
    //get_grm_seventh_maf_bin;
    unify_grms;
    unify_xchr_grms;
    estimate_heritabiltiy;
} from "${projectDir}/modules/heritability.nf"

workflow {
    println "\nGCTA HERITABILITY ESTIMATION\n"

    bfile = get_bed_prefix()
    pheno_file = get_pheno_file(bfile)
    catcov = get_catcovar()
    qcov = get_qcovar()

    if(params.per_chr == "true") {
        get_chromosome()
            .filter(String)
            .set { chrom_x }
        bfile
            .combine(chrom_x)
            .set { split_xchr_input }
        xchr_split = split_xchr(split_xchr_input)

        //xchr_grm = get_xchr_grm(xchr_split)

        xchr_split_maf_bin_a = get_xchr_grm_first_maf_bin(xchr_split)
        xchr_split_maf_bin_b = get_xchr_grm_second_maf_bin(xchr_split)
        xchr_split_maf_bin_c = get_xchr_grm_third_maf_bin(xchr_split)
        //xchr_split_maf_bin_d = get_xchr_grm_fourth_maf_bin(xchr_split)
        //xchr_split_maf_bin_e = get_xchr_grm_fifth_maf_bin(xchr_split)
        //xchr_split_maf_bin_f = get_xchr_grm_sixth_maf_bin(xchr_split)
        //xchr_split_maf_bin_g = get_xchr_grm_seventh_maf_bin(xchr_split)
        xchr_split_maf_bin_a
            .mix(xchr_split_maf_bin_b)
            .mix(xchr_split_maf_bin_c)
            //.mix(xchr_split_maf_bin_d)
            //.mix(xchr_split_maf_bin_e)
            //.mix(xchr_split_maf_bin_f)
            //.mix(xchr_split_maf_bin_g)
            .groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }
            .set { unify_xchr_input }

        xchr_grm = unify_xchr_grms(unify_xchr_input)

        get_chromosome()
            .filter(Number)
            .set { chrom }
        bfile
            .combine(chrom)
            .set { split_bfile_input }
        split_bfile_by_chr(split_bfile_input)
            .set { ld_input }
    } else { 
        println "\nper_chr = 'false'\n"
        bfile
            .set{ ld_input }
    }

    ld_score = get_ld_scores(ld_input)

    segment_snps_by_ld_score(ld_score)
        .flatMap { 
            bed_name, 
            ld_segment1, 
            ld_segment2, 
            ld_segment3, 
            ld_segment4 -> 
            tuple([bed_name, ld_segment1], 
                  [bed_name, ld_segment2], 
                  [bed_name, ld_segment3], 
                  [bed_name, ld_segment4]) 
        }
        .set { ld_segment_files }

    grm_input = ld_segment_files.combine(ld_input, by: 0)
  
    //get_grm(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms }
    //unified_grms = unify_grms(grms).flatten().collect()

    get_grm_first_maf_bin(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms_split_maf_bin_a }
    get_grm_second_maf_bin(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms_split_maf_bin_b }
    get_grm_third_maf_bin(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms_split_maf_bin_c }
    //get_grm_fourth_maf_bin(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms_split_maf_bin_d }
    //get_grm_fifth_maf_bin(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms_split_maf_bin_e }
    //get_grm_sixth_maf_bin(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms_split_maf_bin_f }
    //get_grm_seventh_maf_bin(grm_input).groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }.set { grms_split_maf_bin_g }

    grms_split_maf_bin_a
        .mix(grms_split_maf_bin_b)
        .mix(grms_split_maf_bin_c)
        //.mix(grms_split_maf_bin_d)
        //.mix(grms_split_maf_bin_e)
        //.mix(grms_split_maf_bin_f)
        //.mix(grms_split_maf_bin_g)
        .groupTuple(by: 0).map { bed_name, grm_tuple -> tuple(bed_name, grm_tuple.flatten().collect()) }
        .set { grms }

    unified_grms = unify_grms(grms).flatten().collect()

    all_grms = unified_grms.combine(xchr_grm).flatten().collect()

    pheno_file
        .combine(catcov)
        .combine(qcov)
        .flatten()
        .collect()
        .set { pheno_cov }

    estimate_heritabiltiy(pheno_cov, all_grms)
}

workflow.onComplete { println "Done! Results saved to [${params.output_dir}]" }
