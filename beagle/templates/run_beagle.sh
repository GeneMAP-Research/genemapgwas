#!/usr/bin/env bash

beagle3="java -Xmx${task.memory.toGiga()}g -jar \${HOME}/bin/beagle.jar"

\$beagle3 data=${geno} trait=${params.phenoName} test=adro out=${params.out} nperms=${params.nperms}

