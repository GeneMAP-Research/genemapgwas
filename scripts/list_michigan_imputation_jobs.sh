if [ ! -e "michigan_imputation_server_api_token.txt" ]; then
   echo "API token file 'michigan_imputation_server_api_token.txt' not found!";
   exit 1;
else
   TOKEN=$(cat michigan_imputation_server_api_token.txt);
fi

curl \
   -H "X-Auth-Token: $TOKEN" https://imputationserver.sph.umich.edu/api/v2/jobs | \
   jq . \
   > michigan_imputation_server_jobs.json

   job_status=$(cat michigan_imputation_server_jobs.json | jq '.success')

   if [[ "${job_status}" == "false" ]]; then
      echo ""
      echo "Something went wrong and we couldn't locate any jobs!"
      echo "Are you sure you are currently running jobs?"
      echo ""
   else
      echo ""
      echo "Job IDs sorted by date and time with most recent at the top"
      echo ""
      cat michigan_imputation_server_jobs.json | \
         jq '.data[].id'
   fi
