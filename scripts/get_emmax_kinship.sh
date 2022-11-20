#!/usr/bin/env bash

resp="$1"
emk="$(which emmax-kin-intel64)"
emx="$(which emmax-intel64)"

if [ $# != 1 ]; then
    echo """
        Usage: get_emmax_kinship.sh <tfile-prefix>
    """
else
    base=$1
    ${emk} -v -d 10 ${base}	                # Generate kinship matrix
fi

