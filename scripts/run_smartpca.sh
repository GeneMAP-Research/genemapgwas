#!/bin/bash

if [[ $# == 6 ]]; then

    #------- Set parameter variables
    base="$1"
    k="$2"
    m="$3"
    t="$4"
    s="$5"
    th="$6"
    
    #------- Create parameter files
    echo """
    genotypename: ${base}.eigenstratgeno
    snpname: ${base}.snp
    indivname: ${base}.ind
    evecoutname: ${base}.pca.evec
    evaloutname: ${base}.eval
    altnormstyle: NO
    numoutevec: ${k}
    numoutlieriter: ${m}
    numoutlierevec: ${t}
    outliersigmathresh: ${s}
    qtmode: 0
    xregionname: high-ld-regions.b37
    #lsqproject: YES
    outlieroutname: ${base}.outlier
    familynames: NO
    #snpweightoutname: ${base}-snpwt
    #deletesnpoutname: ${base}-eth-badsnps
    numthreads: ${th}
    #ldregress: 200
    #phylipoutname: ${base}.phy
    """ > ${base}.pca.par
    
    #echo """
    #genotypename:  ${base}.eigenstratgeno
    #snpname:       ${base}.snp
    #indivname:     ${base}.ind
    #pcaname:       ${base}.pca
    #outputname:    ${base}.chisq
    #numpc:         ${k}
    #qtmode:        NO
    #""" > ${base}.chisq.par
    
    
    #------- Run the jobs
    echo "smartpca -p ${base}.pca.par >${base}-pca.log"
    echo `smartpca -p ${base}.pca.par >${base}-pca.log`
    c=$(( $k+1 ))
    sed '1d' ${base}.pca.evec | awk -v a=${c} '{for(x=1; x<=a; x++) printf "%s ", $x;printf "\n"}' > ${base}.pca.txt 
    #echo "smarteigenstrat -p ${base}.chisq.par >${base}.chisq.log"
    #echo `smarteigenstrat -p ${base}.chisq.par >${base}.chisq.log`
    #
    #echo "gc.perl $base.chisq $base.chisq.GC"
    #echo `gc.perl $base.chisq $base.chisq.GC`

else 
    echo """
	Usage: ./run_eingenstrat.sh <input_prefix> <k_param> <m_param> <t_param> <s_param> <threads>
    """
fi
