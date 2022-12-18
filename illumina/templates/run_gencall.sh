#!/usr/bin/env bash

iaap-cli \
   gencall \
   ${manifest} \
   ${cluster} \
   . \
   --idat-folder ${intensity} \
   --output-gtc \
   --gender-estimate-call-rate-threshold 0.95 \
   --gender-estimate-x-het-rate-threshold 0.2 \
   --num-threads ${task.cpus}
