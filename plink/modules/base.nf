def getPlinkBinaryFileset() {
        return channel.fromFilePairs( params.bedDir + params.bedPrefix + ".{bed,bim,fam}", size: 3 )
}

def getChromosomes() {
    return channel.of(1..22, 'X')
}

def getAutosomes() {
    return channel.of(1..22)
}

def getGenFile() {
    return channel.fromPath( params.genDir + params.genFile )
}

def getSampleFile() {
    return channel.fromPath( params.genDir + params.sampleFile )
}

process adjustAssociationTestPvalues() {
    tag "processing ${params.bedPrefix}"
    label 'process_plink_assoc'
    label 'r_base'
    cache 'lenient'
    input:
        //tuple val(chrom), val(file_base), path(plinkAssoc)
        path plinkAssoc
    output:
        publishDir path: "${params.outputDir}", mode: 'copy'
        path "${plinkAssoc}.adjusted.txt"
    script:
        template 'adjustPlinkAssociationTestPvalues.sh'
}


