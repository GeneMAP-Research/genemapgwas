process boltLmmAssociation() {
    tag "processing ${bedPrefix}"
    label 'bigMemory'
    label 'bolt'
    cache 'lenient'
    echo true
    input:
          tuple \
              val(bedPrefix), \
              path(plinkBinaryFileSet)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          tuple \
              val(bedPrefix), \
              path("${params.outputPrefix}.boltassoc.txt.gz")
    script:
        template 'boltlmm.sh'
}

process snptestFrequentistAdditiveAssociation() {
    tag "processing ${bedPrefix}"
    label 'bigMemory'
    label 'snptest'
    cache 'lenient'
    echo true
    input:
          tuple \
              path(genFile), \
              path(sampleFile)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          tuple \
              val(bedPrefix), \
              path("${params.outputPrefix}.snptestassoc.add.txt.gz")
    script:
        template 'snptestFrequentistAdditive.sh'
}

process snptestFrequentistDominantAssociation() {
    tag "processing ${bedPrefix}"
    label 'bigMemory'
    label 'snptest'
    cache 'lenient'
    echo true
    input:
          tuple \
              path(genFile), \
              path(sampleFile)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          tuple \
              val(bedPrefix), \
              path("${params.outputPrefix}.snptestassoc.dom.txt.gz")
    script:
        template 'snptestFrequentistDominant.sh'
}

process snptestFrequentistRecessiveAssociation() {
    tag "processing ${bedPrefix}"
    label 'bigMemory'
    label 'snptest'
    cache 'lenient'
    echo true
    input:
          tuple \
              path(genFile), \
              path(sampleFile)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          tuple \
              val(bedPrefix), \
              path("${params.outputPrefix}.snptestassoc.rec.txt.gz")
    script:
        template 'snptestFrequentistRecessive.sh'
}

process snptestFrequentistGeneralAssociation() {
    tag "processing ${bedPrefix}"
    label 'bigMemory'
    label 'snptest'
    cache 'lenient'
    echo true
    input:
          tuple \
              path(genFile), \
              path(sampleFile)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          tuple \
              val(bedPrefix), \
              path("${params.outputPrefix}.snptestassoc.gen.txt.gz")
    script:
        template 'snptestFrequentistGeneral.sh'
}

process snptestFrequentistHeterozygoteAssociation() {
    tag "processing ${bedPrefix}"
    label 'bigMemory'
    label 'snptest'
    cache 'lenient'
    echo true
    input:
          tuple \
              path(genFile), \
              path(sampleFile)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          tuple \
              val(bedPrefix), \
              path("${params.outputPrefix}.snptestassoc.het.txt.gz")
    script:
        template 'snptestFrequentistHeterozygote.sh'
}

process plinkAdditiveAssociation() {
    tag "processing ${bedPrefix}"
    label 'plink_assoc'
    label 'plink2'
    cache 'lenient'
    input:
          tuple \
              val(bedPrefix), \
              path(plinkBinaryFileSet)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          path "${params.outputPrefix}.add.PHENO1.glm.linear.txt.gz"
          path "${params.outputPrefix}.add.PHENO1.glm.linear.adjusted.gz"
          path "${params.outputPrefix}.add.log"
    script:
        template 'plinkAdditiveAssociationTest.sh'
}

process plinkDominantAssociation() {
    tag "processing ${bedPrefix}"
    label 'plink_assoc'
    label 'plink2'
    cache 'lenient'
    input:
          tuple \
              val(bedPrefix), \
              path(plinkBinaryFileSet)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          path "${params.outputPrefix}.dom.PHENO1.glm.linear.txt.gz"
          path "${params.outputPrefix}.dom.PHENO1.glm.linear.adjusted.gz"
          path "${params.outputPrefix}.dom.log"
    script:
        template 'plinkDominantAssociationTest.sh'
}

process plinkRecessiveAssociation() {
    tag "processing ${bedPrefix}"
    label 'plink_assoc'
    label 'plink2'
    cache 'lenient'
    input:
          tuple \
              val(bedPrefix), \
              path(plinkBinaryFileSet)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          path "${params.outputPrefix}.rec.PHENO1.glm.linear.txt.gz"
          path "${params.outputPrefix}.rec.PHENO1.glm.linear.adjusted.gz"
          path "${params.outputPrefix}.rec.log"
    script:
        template 'plinkRecessiveAssociationTest.sh'
}

process plinkGenotypicAssociation() {
    tag "processing ${bedPrefix}"
    label 'plink_assoc'
    label 'plink2'
    cache 'lenient'
    input:
          tuple \
              val(bedPrefix), \
              path(plinkBinaryFileSet)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          path "${params.outputPrefix}.geno.PHENO1.glm.linear.txt.gz"
          path "${params.outputPrefix}.geno.PHENO1.glm.linear.adjusted.gz"
          path "${params.outputPrefix}.geno.log"
    script:
        template 'plinkGenotypicAssociationTest.sh'
}

process plinkHethomAssociation() {
    tag "processing ${bedPrefix}"
    label 'plink_assoc'
    label 'plink2'
    cache 'lenient'
    input:
          tuple \
              val(bedPrefix), \
              path(plinkBinaryFileSet)
    output:
          publishDir path: "${params.outputDir}", mode: 'copy'
          path "${params.outputPrefix}.hethom.PHENO1.glm.linear.txt.gz"
          path "${params.outputPrefix}.hethom.PHENO1.glm.linear.adjusted.gz"
          path "${params.outputPrefix}.hethom.log"
    script:
        template 'plinkHethomAssociationTest.sh'
}

process sortPlinkAssociationResults() {
    tag "processing ${assoc_result}"
    input:
        path assoc_result
    output:
        publishDir path: "${params.outputDir}", mode: 'copy'
        path "${assoc_result}.txt.gz"
    script:
        template 'sortPlinkAssociationResults.sh'
}
