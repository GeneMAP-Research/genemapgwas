def getGlmmBfileset() {
    return channel.fromFilePairs( params.glmm_bfile + "*.{bed,bim,fam}", size: 3 )
                  checkIfEmpty { error: println "\nERROR: Please check that all relevant files are present in the input directory!\n" }
}

def getLdBfileset() {
    return channel.fromFilePairs( params.ld_bfile + "*.{bed,bim,fam}", size: 3 )
                  checkIfEmpty { error: println "\nERROR: Please check that all relevant files are present in the input directory!\n" }
}

def getSpaBfileset() {
    return channel.fromFilePairs( params.spa_bfile + ".{bed,bim,fam}", size: 3 )
                  checkIfEmpty { error: println "\nERROR: Please check that all relevant files are present in the input directory!\n" }
}

def getVcf() {
    if(params.imputation_panel.toUpperCase() == "TOPMED") {
        return channel
            .fromFilePairs( params.vcf_dir + "*.{vcf.gz,vcf.gz.csi}", size: 2 )
            .map { vcf_base_name, vcf_file_set -> tuple(vcf_file_set.first().simpleName, vcf_file_set.first(), vcf_file_set.last()) }
    } 
    else {
        return channel
            .fromFilePairs( params.vcf_dir + "*.{vcf.gz,vcf.gz.csi}", size: 2 )
            .map { vcf_base_name, vcf_file_set -> tuple(vcf_file_set.first().simpleName.replaceAll(/chr/,""), vcf_file_set.first(), vcf_file_set.last()) }
    }
}

def getVarianceRatioFile() {
    return channel.fromPath( params.varianceRatioFile )
}

/*
def getNullGlmm() {
    return channel.fromPath( params.nullGlmm )
}


def getCovar() {
    return channel.fromPath( params.input_dir + params.covar )
}
*/

process generateSparseGrm() {
    tag "processing ${bedName}"
    label 'saige'
    label 'mediumMemory'
    input:
        tuple \
            val(bedName), \
            path(bedFileset)
    output:
        publishDir path: "${params.output_dir}"
        tuple \
            val(bedName), \
            path("saige.casecontrol.grm_relatednessCutoff_0.125_2000_randomMarkersUsed.sparseGRM.mtx"), \
            path("saige.casecontrol.grm_relatednessCutoff_0.125_2000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt")
    script:
        """
        createSparseGRM.R \
            --plinkFile=${bedName} \
            --nThreads=${task.cpus} \
            --outputPrefix=${params.out}
        """
}

process getNullGlmm() {
    tag "processing ${bedName}"
    label 'saige'
    label 'mediumMemory'
    input:
        tuple \
            val(bedName), \
            path(bedFileset)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        tuple \
            path("${params.out}.rda"), \
            path("${params.out}.varianceRatio.txt")
    script:
        """
        step1_fitNULLGLMM.R \
            --plinkFile=${bedName} \
            --phenoFile=${params.pheno_file} \
            --invNormalize=FALSE \
            --phenoCol=${params.pheno_name} \
            --covarColList=${params.covar} \
            --traitType=${params.trait_type} \
            --sexCol=SEX \
            --numRandomMarkerforVarianceRatio=100 \
            --relatednessCutoff=0.125 \
            --sampleIDColinphenoFile=${params.sampleID_column_name} \
            --outputPrefix=${params.out} \
            --IsOverwriteVarianceRatioFile=TRUE \
            --nThreads=24 \
            \$(if [[ "${params.genset}" == "true" ]]; then echo '--LOCO=TRUE --isCateVarianceRatio=TRUE'; else echo '--LOCO=FALSE'; fi)
        """
}

process getVcfIndex() {
    tag "processing ${vcf.baseName}"
    label 'smallMemory'
    label 'bcftools'
    input:
        tuple \
            val(chrom), \
            path(vcf)
    output:
        tuple \
            val(chrom), \
            path(vcf), \
            path("${vcf}.csi")
    script:
        """
        bcftools \
            index \
            --threads ${task.cpus} \
            -fc \
            ${vcf}
        """
}

process saigeSPAtest() {
    tag "processing ${bedName}"
    label 'saige'
    label 'saige_assoc'
    input:
        tuple \
            val(bedName), \
            path(bedFileset), \
            path(nullGlmm), \
            path(varatio)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path "${params.baseName}.assoc.gz"
    script:
        """
        step2_SPAtests.R \
           --bedFile=${bedName}.bed \
           --bimFile=${bedName}.bim \
           --famFile=${bedName}.fam \
           --GMMATmodelFile=${nullGlmm} \
           --varianceRatioFile=${varatio} \
           --minMAC=${params.mac} \
           --SAIGEOutputFile="${params.baseName}.assoc" \
           --minInfo=${params.minInfo} \
           --is_imputed_data=${params.is_imputed_data} \
           --minMAF=${params.maf} \
           --is_overwrite_output=TRUE \
            \$(if [[ "${params.genset}" == "true" ]]; then echo '--LOCO=TRUE --isCateVarianceRatio=TRUE'; else echo '--LOCO=FALSE'; fi)

        #gzip -f "${params.out}.assoc"

        #${projectDir}/scripts/fdr.r "${params.out}_${params.out}.assoc.gz" p.value ${task.cpus}

        #zcat "${params.out}_${params.condition_marker}.assoc.gz.adjusted.txt.gz" | awk '(\$13 < 1e-07 || \$15 < 0.06)' | sort -g -k15 | awk '{print \$3}' | head -1

        """

}

process saigeConditionalSPAtest() {
    tag "processing ${bedName}"
    label 'saige'
    label 'saige_assoc'
    input:
        tuple \
            val(bedName), \
            path(bedFileset), \
            path(nullGlmm), \
            path(varatio)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path "${params.out}_${params.condition_marker}.assoc.gz"
    script:
        """
        step2_SPAtests.R \
           --bedFile=${bedName}.bed \
           --bimFile=${bedName}.bim \
           --famFile=${bedName}.fam \
           --GMMATmodelFile=${nullGlmm} \
           --varianceRatioFile=${varatio} \
           --minMAC=${params.mac} \
           --condition ${params.condition_marker} \
           --SAIGEOutputFile="${params.out}_${params.condition_marker}.assoc" \
           --minInfo=${params.minInfo} \
           --is_imputed_data=${params.is_imputed_data} \
           --minMAF=${params.maf} \
           --is_overwrite_output=TRUE \
            \$(if [[ "${params.genset}" == "true" ]]; then echo '--LOCO=TRUE --isCateVarianceRatio=TRUE'; else echo '--LOCO=FALSE'; fi)

        #gzip -f "${params.out}_${params.condition_marker}.assoc"

        #${launchDir}/scripts/fdr "${params.out}_${params.condition_marker}.assoc.gz" p.value ${task.cpus}

        #zcat "${params.out}_${params.condition_marker}.assoc.gz.adjusted.txt.gz" | awk '(\$13 < 1e-07 || \$15 < 0.06)' | sort -g -k15 | awk '{print \$3}' | head -1

        """

}

process saigeSPAtestVcf() {
    tag "processing ${chrom}"
    label 'saige'
    label 'saige_assoc_vcf'
    input:
        tuple \
            val(chrom), \
            path(vcf), \
            path(vcfIndex)
    output:
        tuple \
            val(chrom), \
            path(vcf), \
            path(vcfIndex), \
            path("chr${chrom}_${params.imputation_panel}.assoc.gz")
    script:
        """
        step2_SPAtests.R \
          --vcfFile=${vcf} \
          --vcfFileIndex=${vcfIndex} \
          --vcfField=${params.vcf_field} \
          --chrom=${chrom} \
          --GMMATmodelFile=${params.nullGlmm} \
          --varianceRatioFile=${params.varianceRatioFile} \
          --minMAC=${params.mac} \
          --SAIGEOutputFile=chr${chrom}_${params.imputation_panel}.assoc \
          --minInfo=${params.minInfo} \
          --is_imputed_data=${params.is_imputed_data} \
          --minMAF=${params.maf} \
          --LOCO=${params.loco} \
          --is_overwrite_output=TRUE \
          --sampleFile=${params.keep}

        gzip -f "chr${chrom}_${params.imputation_panel}.assoc"
        """
}

process saigeConditionalSPAtestVcf() {
    tag "processing ${chrom}"
    label 'saige'
    label 'saige_assoc_vcf'
    input:
        tuple \
            val(chrom), \
            path(vcf), \
            path(vcfIndex)
    output:
        tuple \
            val(chrom), \
            path(vcf), \
            path(vcfIndex), \
            path("*.assoc.adjusted.txt.gz")
    script:
        """
        marker=\$(echo ${params.condition_marker} | sed 's|[:/]|_|g')

        step2_SPAtests.R \
          --vcfFile=${vcf} \
          --vcfFileIndex=${vcfIndex} \
          --vcfField=${params.vcf_field} \
          --chrom=${chrom} \
          --GMMATmodelFile=${params.nullGlmm} \
          --varianceRatioFile=${params.varianceRatioFile} \
          --minMAC=${params.mac} \
          --SAIGEOutputFile=chr${chrom}_${params.imputation_panel}_\${marker}.assoc \
          --minInfo=${params.minInfo} \
          --is_imputed_data=${params.is_imputed_data} \
          --minMAF=${params.maf} \
          --condition=${params.condition_marker} \
          --LOCO=${params.loco} \
          --is_overwrite_output=TRUE \
          --sampleFile=${params.keep}

        gzip -f "chr${chrom}_${params.imputation_panel}_\${marker}.assoc"
        """
}

process concatenateSaigeResults() {
    tag "Writing results to ${params.output_prefix}"
    label 'smallMemory'
    input:
        path saigeResults
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path "${params.output_prefix}.saige.assoc.gz"
    script:
        """
        ls *.saige.assoc | \
            sort -V \
            > assoc_result.list
        grep -w \
            "CHR" \$(head -1 assoc_result.list) \
            > ${params.output_prefix}.saige.assoc
        for i in \$(cat assoc_result.list); do
            grep -wv "CHR" \${i}
        done | uniq >> ${params.output_prefix}.saige.assoc

        gzip -f ${params.output_prefix}.saige.assoc

        ${projectDir}/scripts/fdr.r ${params.output_prefix}.saige.assoc.gz p.value ${task.cpus}

        signal=\$(zcat ${params.output_prefix}.saige.assoc.gz.adjusted.txt.gz | awk '(\$13 < 1e-07 || \$15 < 0.06)' | sort -g -k15 | awk '{print \$3}' | head -1)

        if [ -n \$signal ]; then
       

        """
}

process adjustSaigePvalues() {
    tag "processing ${chrom}"
    label 'r_base'
    label 'saige_assoc_vcf'
    input:
        tuple \
            val(chrom), \
            path(vcf), \
            path(vcfIndex), \
            path(saige_result)
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path("${saige_result}.adjusted.txt.gz")
    script:
        template 'fdr.r'
}

//          --sparseGRMFile=${params.sparseGrmFile} \
//          --sparseGRMSampleIDFile=${params.sparseGrmSampleFile} \

process formatSaigeResultForPlotting() {
    tag "processing ${saigeResult}"
    label 'smallMemory'
    input:
        path saigeResult
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path "${saigeResult}.qqman.txt.gz"
    script:
        template 'format_saige_result_for_qqman.sh'
}

process formatSaigeResultForAnnotation() {
    tag "processing ${saigeResult}"
    label 'smallMemory'
    input:
        path saigeResult
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path "${saigeResult}.annvar.txt.gz"
    script:
        template 'format_saige_result_for_annotation.sh'
}

process getSaigeResultVcf() {
    tag "processing ${saigeResult}"
    label 'smallMemory'
    label 'bcftools'
    input:
        path saigeResult
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path "${saigeResult}.vcf.gz"
    script:
        template 'make_annv_input.sh'
}

process plotSaigeResults() {
    tag "processing ${assocResult}"
    label 'mediumMemory'
    label 'r_base'
    input:
        path assocResult
    output:
        publishDir path: "${params.output_dir}", mode: 'copy'
        path "${assocResult.baseName}.{assoc,qq}.png"
    script:
        template 'plot_assoc.r'
}

