TOKEN=$(cat michigan_imputation_server_api_token.txt)

if [ $# -lt 1 ]; then
   echo -e "\nget_mis_job_status.sh [job id]\n"
else
   jobid=$1
   curl \
      -H "X-Auth-Token: $TOKEN" https://imputationserver.sph.umich.edu/api/v2/jobs/${jobid} | \
      jq \
      > ${jobid}_details.json

   if [[ $(jq '.complete' ${jobid}_status.json) == true ]]; then 
      echo -e "\nJob ${jobid} completed successfully!";
   else 
      echo -e "\nJob ${jobid} failed! che";            
   fi
fi
