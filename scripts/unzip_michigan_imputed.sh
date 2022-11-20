#!/usr/bin/env bash

for i in {1..22} X; do unzip -o -P $(cat passwd.txt) chr_${i}.zip; done
