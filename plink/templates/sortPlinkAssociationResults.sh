#!/usr/bin/env bash

sort -k1,1g -k2,2g ${assoc_result} | gzip -c > "${assoc_result}.txt.gz"
