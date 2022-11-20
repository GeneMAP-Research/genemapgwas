#!/usr/bin/env bash

cat duplicate.samples.txt fail-het.qc probable.sample.mislabling.ids.txt | awk '{print $1,$2}' | sort | uniq > fail-ind-qc.txt
