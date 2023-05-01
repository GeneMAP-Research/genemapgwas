if [ ! -e "michigan_imputation_server_api_token.txt" ]; then
   echo "API token file 'michigan_imputation_server_api_token.txt' not found!";
   exit 1;
else
   TOKEN=$(cat michigan_imputation_server_api_token.txt);
fi

if [ $# -lt 1 ]; then
   echo -e "\nget_mis_job_status.sh [job id]\n"
else
   jobid=$1

   mkdir -p ${jobid}-results
   cd ${jobid}-results
   curl \
      -H "X-Auth-Token: $TOKEN" https://imputationserver.sph.umich.edu/api/v2/jobs/${jobid} | \
      jq . \
      > ${jobid}_status.json

   # get quality control report (first output paramter)
   echo -e "\nDownloading quality control report..."
   sleep 1
   report_id=$(jq '.outputParams[0].id' ${jobid}_status.json | sed 's|"||g')
   report_hash=$(jq '.outputParams[0].hash' ${jobid}_status.json | sed 's|"||g')
   curl -sL https://imputationserver.sph.umich.edu/get/${report_id}/${report_hash} | bash

   # get quality control statistics (second output paramter)
   echo "Downloading quality control statistics..."
   sleep 1
   qcstats_id=$(jq '.outputParams[1].id' ${jobid}_status.json | sed 's|"||g')
   qcstats_hash=$(jq '.outputParams[1].hash' ${jobid}_status.json | sed 's|"||g')
   curl -sL https://imputationserver.sph.umich.edu/get/${qcstats_id}/${qcstats_hash} | bash

   # get imputation results (third output paramter)
   echo "Downloading imputation results..."
   sleep 1
   imputationresults_id=$(jq '.outputParams[2].id' ${jobid}_status.json | sed 's|"||g')
   imputationresults_hash=$(jq '.outputParams[2].hash' ${jobid}_status.json | sed 's|"||g')
   curl -sL https://imputationserver.sph.umich.edu/get/${imputationresults_id}/${imputationresults_hash} | bash	# uncomment to download results

   # get log files (fourth output paramter)
   echo "Downloading log files..."
   sleep 1
   logs_id=$(jq '.outputParams[3].id' ${jobid}_status.json | sed 's|"||g')
   logs_hash=$(jq '.outputParams[3].hash' ${jobid}_status.json | sed 's|"||g')
   curl -sL https://imputationserver.sph.umich.edu/get/${logs_id}/${logs_hash} | bash

   cd -

   echo "Done! All files Downloaded to '${jobid}-results'\n"
fi
