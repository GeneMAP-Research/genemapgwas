def get_ref() {
    if( params.fasta_ref == "" ) {
        warning: println "\nWARNING: You have not provided a FASTA reference. \n\
        You will not be able to process GTC to VCF!\n"
    } 
    else {
        retrun channel.fromPath(params.ref)
    }
}

def check_bam_alignment() {
    if( params.bam_alignment == "" ) {
        error: println "ERROR: Please provide a value for 'bam_alignment' in the 'configs/params.config' file"
    }
}

def get_manisfest_bpm() {
    if( params.manifest_bpm == "" ) {
        error: println "ERROR: Please provide a value for 'manifest_bpm' in the 'configs/params.config' file"
    }
    else {
        return channel.fromPath(params.manifest_bpm)
    }
}

def get_manisfest_csv() {
    if( params.manifest_csv == "" ) {
        error: println "ERROR: Please provide a value for 'manifest_csv' in the 'configs/params.config' file"
    }
    else {
        return channel.fromPath(params.manifest_csv) 
    }
}

def get_cluster_file() {
    if ( params.cluster_file == "" ) {
        error: println "ERROR: Please provide a value for 'cluster_file' in the 'configs/params.config' file"
    }
    else {
        return channel.fromPath(params.cluster_file)
    }
}

def get_intensities() {
    if( params.idat_dir == "" ) {
        error: println "\nERROR: Oops! forgot to provide a value for 'idat_dir' in the 'configs/params.config' file?\n"
    }
    else {
        return channel
            .fromPath(params.idat_dir + './*', type: 'dir')
            .map { idat -> 
                if( idat.isDirectory() ) {
                    idat
                }
                else {
                    error: println "\nERROR: gencall works on folders containing intensity files. \n\
                    This workflow works on the parent folder containing the intensity sub-folders. \n\
                    Please provide the parent folder instead.\n"
                }
            }
    }
}



/**********************************************
def get_vcf() {
    return channel.fromPath(params.input_vcf)
}

def get_chain_file() {
    return channel.fromPath(params.chain_file)
}
***********************************************/


process get_gtc() {
    tag "processing ${intensity}"
    label 'idat_to_gtc'
    label 'gencall'
    publishDir \
        path: "${params.output_dir}/gtcs", \
        mode: 'copy'
    input:
        tuple \
            path(manifest), \
            path(cluster), \
            path(intensity)
    output:
        path "*.gtc"
    script:
        template "run_gencall.sh"
}

process get_gtc_list() {
    tag "retrieving list of gtc files ..."
    publishDir \
        path: "${params.output_dir}/gtcs",
        mode: 'copy'
    input:
        path gtc_list
    output:
        path "*.txt"
    script:
        """
        ls *.gtc > gtc_list.txt
        """
}

process convert_gtc_to_vcf() {
    tag "processing GTC2VCF"
    label 'gencall'
    label 'gtc_to_vcf'
    publishDir \
        path: "${params.output_dir}/vcf", \
        mode: 'copy'
    output:
        tuple \
            path("${params.output_prefix}.vcf.gz"), \
            path("${params.output_prefix}.vcf.gz.tbi"), \
            path("${params.output_prefix}_genotype_stats.tsv")
    script:
        template "convert_gtc2vcf.sh"
}

process convert_gtc_to_vcf_hg38() {
    tag "processing GTC2VCF"
    label 'gencall'
    label 'gtc_to_vcf'
    publishDir \
        path: "${params.output_dir}/vcf", \
        mode: 'copy'
    output:
        tuple \
            path("${params.output_prefix}.vcf.gz"), \
            path("${params.output_prefix}.vcf.gz.tbi"), \
            path("${params.output_prefix}_genotype_stats.tsv")
    script:
        template "convert_gtc2vcf_hg38.sh"
}


