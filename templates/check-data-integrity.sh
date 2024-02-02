#!/usr/bin/env bash

md5deep -r manifest > manifest-checksum.md5
md5deep -r intensities > intensities-checksum.md5 
md5sum -c manifest-checksum.md5 
md5sum -c intensities-checksum.md5 
