#!/bin/bash

if [ $# != 2 ]; then
   echo "Usage: get_eig_params.sh [plink_ped_prefix] [phase_mode <YES|NO>]"
else
base=$1; phase_mode=$2

# ==> par.PED.PACKEDPED <==
echo -e """genotypename:    ${base}.ped
snpname:         ${base}.map # or example.map, either works
indivname:       ${base}.ped # or example.ped, either works
outputformat:    PACKEDPED
genotypeoutname: ${base}.bed
snpoutname:      ${base}.pedsnp
hashcheck:	 YES
indivoutname:    ${base}.pedind
xregionname:	 /mnt/lustre/groups/CBBI1243/KEVIN/imputationReference/high-ld-regions.b37
#pordercheck:	 YES
#strandcheck:	 YES
phasedmode:	 ${phase_mode}
familynames:     NO
numthreads:	 24""" > par.PED.PACKEDPED

# ==> par.PACKEDPED.PACKEDANCESTRYMAP <==
echo -e """genotypename:    ${base}.bed
snpname:         ${base}.pedsnp # or example.map, either works
indivname:       ${base}.pedind # or example.ped, either works
outputformat:    PACKEDANCESTRYMAP
genotypeoutname: ${base}.packedancestrymapgeno
snpoutname:      ${base}.snp
indivoutname:    ${base}.ind
familynames:     NO
phasedmode:      ${phase_mode}
numthreads:      24""" > par.PACKEDPED.PACKEDANCESTRYMAP

# ==> par.PACKEDANCESTRYMAP.ANCESTRYMAP <==
echo -e """genotypename:    ${base}.packedancestrymapgeno
snpname:         ${base}.snp
indivname:       ${base}.ind
outputformat:    ANCESTRYMAP
genotypeoutname: ${base}.ancestrymapgeno
snpoutname:      ${base}.snp
indivoutname:    ${base}.ind
phasedmode:      ${phase_mode}
numthreads:      24""" > par.PACKEDANCESTRYMAP.ANCESTRYMAP

# ==> par.ANCESTRYMAP.EIGENSTRAT <==
echo -e """genotypename:    ${base}.ancestrymapgeno
snpname:         ${base}.snp
indivname:       ${base}.ind
outputformat:    EIGENSTRAT
genotypeoutname: ${base}.eigenstratgeno
snpoutname:      ${base}.snp
indivoutname:    ${base}.ind
phasedmode:      ${phase_mode}
numthreads:      24""" > par.ANCESTRYMAP.EIGENSTRAT

# ==> par.EIGENSTRAT.PED <==
echo -e """genotypename:    ${base}.eigenstratgeno
snpname:         ${base}.snp
indivname:       ${base}.ind
outputformat:    PED
genotypeoutname: ${base}.ped
snpoutname:      ${base}.pedsnp
indivoutname:    ${base}.pedind
phasedmode:      ${phase_mode}
numthreads:      24""" > par.EIGENSTRAT.PED
fi


