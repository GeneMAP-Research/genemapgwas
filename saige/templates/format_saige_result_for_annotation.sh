#!/usr/bin/env bash

awk '{print \$3"\\t"\$9"\\t"\$10"\\t"\$13"\\t"\$1"\\t"\$2"\\t"\$5"\\t"\$4}' ${saigeResult} | \
    gzip -c > "${saigeResult}.annvar.txt.gz"
