def getbedFileset() {
    return channel.fromFilePairs( params.input_dir + "*.{bed,bim,fam,cov}", size: 4 )
                  .ifEmpty { error "\nERROR: Could not locate a file!\n" }
                  .map { bedName, bedFileset -> tuple(bedName, bedFileset) }
}

def getCovar() {
    return channel.fromPath( params.covar )
}

process getTfile() {
    tag "processing ${bedName}"
    label 'plink'
    label 'plink_mem'
    input:
         tuple \
             val(bedName), \
             path(bedFileset)
    output:
        publishDir path: "${params.output_dir}/intermediate_files/"
        tuple \
            val(bedName), \
            path("${bedName}_kinship.tped"), \
            path("${bedName}_kinship.tfam"), \
            path("${bedName}.tped"), \
            path("${bedName}.tfam"), \
            path("${bedName}.cov")
    script:
        """
        plink \
            --bfile ${bedName} \
            --indep-pairwise 50 10 0.2 \
            --out ${bedName}_prune \
            --maf 0.01 \
            --geno 0.05 \
            --hwe 1e-6
        
        plink \
            --bfile ${bedName} \
            --recode 12 transpose \
            --threads 24 \
            --keep-allele-order \
            --maf 0.01 \
            --geno 0.05 \
            --extract ${bedName}_prune.prune.in \
            --output-missing-genotype 0 \
            --hwe 1e-6 \
            --out ${bedName}_kinship
        
        plink \
            --bfile ${bedName} \
            --recode 12 transpose \
            --threads ${task.cpus} \
            --keep-allele-order \
            --maf ${params.maf} \
            --geno ${params.geno} \
            --output-missing-genotype 0 \
            --hwe ${params.hwe} \
            --out ${bedName}
        """
}

process getKinship() {
    tag "processing ${bedName}"
    label 'emmax'
    label 'emmax_kin'
    input:
        tuple \
            val(bedName), \
            path(kinPed), \
            path(kinFam), \
            path(tped), \
            path(tfam), \
            path(covar)
    output:
        publishDir path: "${params.output_dir}/intermediate_files/"
        tuple \
            val(bedName), \
            path("${bedName}_kinship.aBN.kinf"), \
            path("${tped}"), \
            path("${tfam}"), \
            path("${covar}")
    script:
        """
        emmax-kin-intel64 \
            ${bedName}_kinship \
            -d 10 \
            -v
        """
}

process performAssociationTest() {
    tag "processing ${bedName}"
    label 'emmax'
    label 'emmax_mem'
    input:
        tuple \
            val(bedName), \
            path(kinship), \
            path(tped), \
            path(tfam), \
            path(covar)
    output:
        publishDir path: "${params.output_dir}/unadusted/", mode: 'copy'
        tuple \
            val(bedName), \
            path("${bedName}.ps.gz"), \
            path("${bedName}.reml")
    script:
        """
        awk '{print \$1,\$2,\$6}' ${tfam} \
            > ${bedName}.phe
        
        emmax-intel64 \
            -v \
            -d 10 \
            -t ${bedName} \
            -p ${bedName}.phe \
            -k ${kinship} \
            -c ${covar} \
            -o ${bedName}

        gzip -f ${bedName}.ps
        """
}

process formatEmmaxResult() {
    tag "processing ${bedName}"
    label 'r_base'
    label 'smallMemory'
    input:
         tuple \
             val(bedName), \
             path(emmaxResult), \
             path(heritability), \
             path(bedFileset)
    output:
        publishDir path: "${params.output_dir}/formated/", mode: 'copy'
        tuple \
            val(bedName), \
            path("${bedName}.fmt.ps.gz")
    script:
        template 'format_emmax_result.r'
}

process adjustEmmaxPvalue() {
    tag "processing ${bedName}"
    label 'r_base'
    label 'smallMemory'
    input:
         tuple \
             val(bedName), \
             path(emmaxResult)
    output:
        publishDir path: "${params.output_dir}/adjusted/", mode: 'copy'
        path "${bedName}.fmt.adj.ps.gz"
    script:
        template 'adjust_pvalue.r'
}

process getTopHitsVcf() {
    tag "processing ${bedName}"
    label 'smallMemory'
    input:
         tuple \
             val(bedName), \
             path(emmaxResult)
    output:
        publishDir path: "${params.output_dir}/vcf/", mode: 'copy'
        path "${bedName}.vcf.gz"
    script:
        template "make_annv_input.sh"
}

process plotAssocResult() {
    tag "processing ${bedName}"
    label 'r_base'
    label 'mediumMemory'
    input:
         tuple \
             val(bedName), \
             path(emmaxResult)
    output:
        publishDir path: "${params.output_dir}/media/", mode: 'copy'
        path "*.png"
    script:
        template "plot_assoc.r"
}

