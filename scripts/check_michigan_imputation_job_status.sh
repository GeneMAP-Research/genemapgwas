TOKEN=$(cat michigan_imputation_server_api_token.txt)

if [ $# -lt 1 ]; then
   echo -e "\nget_mis_job_status.sh [job id]\n"
else
   jobid=$1
   curl \
      -H "X-Auth-Token: $TOKEN" https://imputationserver.sph.umich.edu/api/v2/jobs/${jobid} | \
      jq . \
      > ${jobid}_details.json

   jobstate=$(cat ${jobid}_details.json | jq '.state')

   if [ ${jobstate} -eq 5 ]; then 
      echo -e "\nJob ${jobid} failed!";
      echo -e "\nCheck the messages below for possible reasons\n"
      cat ${jobid}_details.json | jq '.steps' | grep "message"
      echo ""
   else
      echo -e "\nJob ${jobid} completed successfully!";
   fi
fi
