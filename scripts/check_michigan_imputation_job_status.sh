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
   curl \
      -H "X-Auth-Token: $TOKEN" https://imputationserver.sph.umich.edu/api/v2/jobs/${jobid} | \
      jq . \
      > ${jobid}_details.json

   queueposition=$(cat ${jobid}_details.json | jq '.positionInQueue')
   jobstate=$(cat ${jobid}_details.json | jq '.state')


   if [[ ! "${queueposition}" = "0" ]]; then
      echo "Job ${jobid} is in queue at position ${queueposition}"
   fi

   if [ ${jobstate} -eq 5 ]; then 
      echo -e "\nJob ${jobid} failed!";
      echo -e "\nCheck the messages below for possible reasons\n"
      cat ${jobid}_details.json | jq '.steps' | grep "message"
      echo ""
   else
      echo -e "\nJob ${jobid} completed successfully!";
   fi
fi

#for i in $(seq 1 ${nsteps}); do i=$((i - 1)); cat job-20221129-024056-232_details.json | jq ".steps[${i}].name, .steps[$i].logMessages[].message"; echo ""; done | sed 's|\\n|\n|g' | sed 's|"||g' | sed 's|<br>|\n|g' | sed 's|<b>|\n|g' | sed 's|</b>||g' | less
