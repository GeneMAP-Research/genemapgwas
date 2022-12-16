TOKEN=$(cat michigan_imputation_server_api_token.txt)

if [ $# -lt 5 ]; then
   echo """
   Usage: submit_to_michigan_imputation_server.sh [vcf directory] [refpanel] [build] [population] [r2Filter <0 - 0.3>]
   
   	  vcf directory must contain only the VCF files to be processed

	  reference panels:       hrc-r1.1 | 1000g-phase-3-v5 | gasp-v2 | genome-asia-panel | 1000g-phase-1 | cappa | hapmap-2

          reference build:        hg19 | hg38

	  population:             eur | afr | asn | amr | sas | eas | AA | mixed | all

	  r2Filter:               0 | 0.001 | 0.1 | 0.2 | 0.3
   """
   
else

   mkdir -p misjobs

   vcfdir=$1
   refpanel=$2
   refbuild=$3
   pop=$4
   filter=$5

   # get random string to append to job name
   jobid=$(echo $RANDOM | md5sum | head -c 30)

echo """curl https://imputationserver.sph.umich.edu/api/v2/jobs/submit/minimac4 \\
  -H \"X-Auth-Token: $TOKEN\" \\
  -F \"refpanel=${refpanel}\" \\
  -F \"build=${refbuild}\" \\
  -F \"population=${pop}\" \\\
""" > misjobs/${jobid}.sh

for vcf in $(ls ${vcfdir}/* | sort -V); do
  echo "  -F \"files=@${vcf}\" \\";
done >> misjobs/${jobid}.sh

echo """  -F \"r2Filter=${filter}\"
""" >> misjobs/${jobid}.sh

chmod 755 misjobs/${jobid}.sh

   echo -e "\nJob created with ID: ${jobid}\n\nSubmit the job using ./misjobs/${jobid}.sh\n"


fi



#curl https://imputationserver.sph.umich.edu/api/v2/jobs/submit/minimac4 \
#  -H "X-Auth-Token: $TOKEN" \
#  -F "files=@${vcf}" \
#  -F "refpanel=1000g-phase-3-v5" \
#  -F "population=afr"
