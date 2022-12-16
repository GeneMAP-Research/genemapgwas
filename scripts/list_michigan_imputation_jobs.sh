TOKEN=$(cat michigan_imputation_server_api_token.txt)

curl \
   -H "X-Auth-Token: $TOKEN" https://imputationserver.sph.umich.edu/api/v2/jobs | \
   jq . \
   > michigan_imputation_server_jobs.json

echo ""
echo "Job IDs sorted by date and time with most recent at the top"
echo ""
cat michigan_imputation_server_jobs.json | \
   jq '.data[].id'
