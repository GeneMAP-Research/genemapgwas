#!/usr/bin/env bash

resp="$1"
emk="$(which emmax-kin-intel64)"
emx="$(which emmax-intel64)"

if [[ $resp == "1" && $# != 3 ]]; then

    echo """
        Usage: ./run_emmax.sh 1 <tfile-prefix> <kinship-matrix>
    """

elif [[ $resp == 1 && $# == 3 ]]; then

    base="$2"; kin=$3
    						# Make emmax input tped and tfam
#    plink \
#    	--bfile ${base} \
#    	--recode 12 transpose \
#	--autosome \
#    	--output-missing-genotype 0 \
#    	--out ${base}


    #${emk} -v -d 10 ${base}			# Generate kinship matrix

    awk '{print $1,$2,$6}' ${base}.tfam > ${base}.phe	# Generate pheno file

    ${emx} -v -d 10 -t ${base} -p ${base}.phe -k ${kin} -o ${base}


elif [[ $resp == "2" && $# != 3 ]]; then

    echo """
        Usage: ./run_emmax.sh 2 <tfile-prefix> <kinship-matrix>

	Please make sure your covariates file has the same prefix as tped file and ends with .cov
    """

elif [[ $resp == 2 && $# == 3 ]]; then

    base="$2"; kin=$3
                                                # Make emmax input tped and tfam
#    plink \
#        --bfile ${base} \
#        --recode12 transpose \
#	 --autosome \
#	 --maf 0.01 \
#        --output-missing-genotype 0 \
#        --out ${base}
#
    #${emk} -v -d 10 ${base}	                # Generate kinship matrix

    awk '{print $1,$2,$6}' ${base}.tfam > ${base}.phe   # Generate pheno file

    ${emx} -v -d 10 -t ${base} -p ${base}.phe -k ${kin} -c ${base}.cov -o ${base}

elif [[ $resp != [13] ]]; then
    echo """
	Usage: ./run_emmax.sh [1|2] <tfile-prefix> <kinship-matrix>

	Enter 1 or 2 then prefix of bfile to convert to tped and tfam
	1: Association without covariates
	2: Association with covariates
    """

fi

