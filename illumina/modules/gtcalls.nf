def getRef() {
    retrun channel.fromPath(params.ref)
}

def getManisfestBpm() {
    return channel.fromPath(params.manifest_bpm)
}

def getManisfestCsv() {
    return channel.fromPath(params.manifest_csv)
}

def getClusterFile() {
    return channel.fromPath(params.cluster_file)
}

def getIntensities() {
    return channel.fromPath(params.idat_dir + './*', type: 'dir')
}

def getVcf() {
    return channel.fromPath(params.input_vcf)
}

def getChainFile() {
    return channel.fromPath(params.chain_file)
}

process getGtc() {
    tag "processing ${intensity}"
    label 'idat_to_gtc'
    label 'gencall'
    input:
        tuple \
            path(manifest), \
            path(cluster), \
            path(intensity)
    output:
        publishDir path: "${params.output_dir}/gtcs", mode: 'copy'
        path "*.gtc"
    script:
        template "run_gencall.sh"
}

process convertGtc2vcf() {
    tag "processing GTC2VCF"
    label 'gencall'
    label 'gtc_to_vcf'
    output:
        publishDir path: "${params.output_dir}/vcf", mode: 'copy'
        tuple \
            path("${params.output_prefix}.vcf.gz"), \
            path("${params.output_prefix}.vcf.gz.tbi"), \
            path("${params.output_prefix}_genotype_stats.tsv")
    script:
        template "convert_gtc2vcf.sh"
}

process convertGtc2vcfHg38() {
    tag "processing GTC2VCF"
    label 'gencall'
    label 'gtc_to_vcf'
    output:
        publishDir path: "${params.output_dir}/vcf", mode: 'copy'
        tuple \
            path("${params.output_prefix}.vcf.gz"), \
            path("${params.output_prefix}.vcf.gz.tbi"), \
            path("${params.output_prefix}_genotype_stats.tsv")
    script:
        template "convert_gtc2vcf_hg38.sh"
}

process liftBuildToHg38() {
    tag "Lifting over ${vcf} to GRCh38"
    label 'gatk'
    label 'lift_over'
    input:
        tuple \
            path(vcf), \
            path(chain_file)
    output:
        publishDir path: "${params.output_dir}/vcf", mode: 'copy'
        tuple \
            path("${params.output_prefix}_lifted_over.vcf.gz"), \
            path("${params.output_prefix}_rejected_variants.vcf.gz")
    script:
        """
        gatk \
            --java-options "-Xmx${task.memory.toGiga()}g -XX:ParallelGCThreads=${task.cpus}" \
            LiftoverVcf \
            --MAX_RECORDS_IN_RAM 100000 \
            -I ${vcf} \
            -O "${params.output_prefix}_lifted_over.vcf.gz" \
            -C ${chain_file} \
            --REJECT "${params.output_prefix}_rejected_variants.vcf.gz" \
            -R ${params.target_ref} \
            --CREATE_INDEX true
        """
}
