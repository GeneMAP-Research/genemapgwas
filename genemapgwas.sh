#!/usr/bin/env bash

#--- genemapgwas workflow wrapper ---#

function usage() {
   echo -e "Usage: genemapgwas <command> <profile> [options] ...\n"
   echo """
           This is a wrapper for the genemapgwas workflow

           commands:
           ---------
               test: run test to see if workflow installed correctly
           idat2vcf: convert illumina IDAT to VCF
                 qc: perform gwas quality control
        plink-assoc: run association tests using PLINK2
        saige-assoc: run association tests using SAIGE
        emmax-assoc: run association tests using EMMAX


           profiles: <executor>,<container>,<reference>
           ---------
          executors: local, slurm
         containers: singularity, aptainer, docker
          reference: hg19, hg38


           examples:
           ---------
         genemapgwas idat2vcf slurm,singularity,hg38 [options]
         genemapgwas qc local,singularity,hg19 --bfile BEDFILE --out MYOUT --output_dir MYPATH --pheno_file MYPHENO
   """
}

################################################### CHECK PARAMS #######################################################
function check_profile() {
   #profile was passed as only argument
   #so it takes position $1 here
   if [[ "$1" == "" ]]; then
      echo "ERROR: please specify a profile to use!";
      usage;
      exit 1;
   elif [[ $1 == -* ]]; then
      echo "ERROR: please specify a valid profile!";
      usage;
      exit 1;
   else
      local profile="$1"
   fi
}

function check_required_params() {
   for params_vals in $@; do
      #get each param and its value as an array
      param_val=( $(echo ${params_vals} | sed 's/,/ /g') )

      #slice the array to its consituent params and values
      param=${param_val[0]}
      val=${param_val[1]}

      #now check each param and its value
      if [[ $val == -* ]] || [[ $val == NULL ]]; then
         echo "ERROR: Invalid paramter value for option '--${param}'";
         exit 1;
      fi
   done
}

function check_optional_params() {
   for params_vals in $@; do
      #get each param and its value as an array
      param_val=( $(echo ${params_vals} | sed 's/,/ /g') )

      #slice the array to its consituent params and values
      param=${param_val[0]}
      val=${param_val[1]}

      #now check each param and its value
      if [[ $val == -* ]]; then
         echo "ERROR: Invalid paramter value for option '--${param}'";
         exit 1;
      fi
   done
}

function check_output_dir() {
   output_dir=$1
   if [[ $output_dir == -* ]]  || [[ $output_dir == NULL ]]; then
      if [ -d ${input_dir} ]; then
         output_dir="${input_dir}/../"
      fi
      if [[ $output_dir == NULL* ]]; then
         echo "ERROR: Invalid paramter value for option '--output_dir'"
         exit 1;
      fi
   fi
}

function check_resources() {
   threads=$1
   njobs=$2
   if [[ $threads == -* ]]; then
      echo "ERROR: Invalid paramter value for option '--threads'"
      exit 1;
   fi
   if [[ $njobs == -* ]]; then
      echo "ERROR: Invalid paramter value for option '--njobs'"
      exit 2;
   fi
}

function set_global_params() {
#- create the project nextflow config file
echo """includeConfig \"\${projectDir}/nextflow.config\"
includeConfig \"\${projectDir}/configs/profile-selector.config\"
includeConfig \"\${projectDir}/configs/resource-selector.config\"
"""
}


########################################################### USAGE #######################################################
function idat_usage() {
   echo -e "\nUsage: genemapgwas idat2vcf <profile> [options] ..."
   echo """
           options:
           --------
           --idat_dir            : directory containing subfolders with idat files [required].
                                   see 'https://genemap-research.github.io/docs/workflows/gwas/idat-to-vcf/'
                                   for a detailed description.
           --bpm_manifest        : bead pool manifest file. It must match the version of the array [required].
           --csv_manifest        : manifest file same as above in CSV format [required].
           --cluster_file        : cluster file. It must match the version of the array [required].
           --fasta               : reference fasta file.
           --bam_alignment       : if processing in a different genome build than the one the array is in,
                                   then provide a bam alignment file for the new genome build.
                                   see 'https://github.com/freeseek/gtc2vcf#using-an-alternative-genome-reference'
                                   for more information.
           --out                 : output prefix [default: myout].
           --output_dir          : path to save output files [required].
           --threads             : number of computer cpus to use [default: 8].
           --help                : print this help message.

   """
}

function qc_usage() {
   echo -e "\nUsage: genemapgwas qc <profile> [options] ..."
   echo """
           options:
           --------
           --bfile           : plink binary (.bed + .bim + .fam) file prefix [required].
           --out             : output prefix [default: myout].
           --output_dir      : path to save output files [required].
           --pheno_file      : phenotype file with header ... [optional].
           --hetlower        : lower heterozygosity value below which individuals are removed (optional) [default: mean-3SD].
           --hetupper        : upper heterozygosity value above which individuals are removed (optional) [default: mean+3SD].
           --maf             : minor allele frequency threshold [default: 0.05].
           --geno            : variant missing call frequency threshold [default: 0.05]
	   --mind            : sample missing call frequency threshold [default: 0.10]
           --threads         : (optional) number of computer cpus to use  [default: 1].
           --njobs           : (optional) number of jobs to submit at once [default: 10]  [default: 5].
           --help            : print this help message.
   """
}


function plink_assoc_usage() {
   echo -e "\nUsage: genemapgwas qc <profile> [options] ..."
   echo """
           options:
           --------
           --bfile           : plink binary (.bed + .bim + .fam) file prefix [required].
           --bfile_dir       : directory cpntaining plink binary filesets (.bed + .bim + .fam) [required].
           --out             : output prefix [default: myout].
           --output_dir      : path to save output files [required].
           --pheno_file      : phenotype file with header ... [optional].
           --covar           : covariates file with header ... .
           --covar_name      : covariate names to read from covariate file ... .
           --maf             : minor allele frequency threshold [default: 0.05].
           --geno            : variant missing call frequency threshold [default: 0.05]
           --mind            : sample missing call frequency threshold [default: 0.10]
           --hwe             : Hardy-Weinberg equilibrium test p-value threshold [default: 1e-6]
           --threads         : (optional) number of computer cpus to use  [default: 1].
           --njobs           : (optional) number of jobs to submit at once [default: 10]  [default: 5].
           --help            : print this help message.
   """
}


function set_global_params() {
#- create the project nextflow config file
echo """includeConfig \"\${projectDir}/nextflow.config\"
includeConfig \"\${projectDir}/configs/profile-selector.config\"
"""
}

function test_config() { #params passed as arguments

#check and remove test config file if it exists
[ -e test.config ] && rm test.config

# $indir $bpm $csv $cluster $fasta $bam $out $output_dir $thrds
echo """
includeConfig \"\${projectDir}/configs/test.config\"
includeConfig \"\${projectDir}/configs/profile-selector.config\"
""" >> test.config
}

function idat_config() { #params passed as arguments

#check and remove config file if it exists
[ -e ${7}-idat2vcf.config ] && rm ${7}-idat2vcf.config

# $indir $bpm $csv $cluster $fasta $bam $out $output_dir $thrds
echo """`set_global_params`

params { // data-related parameters
  idat_dir          = '$1'
  manifest_bpm      = '$2'
  manifest_csv      = '$3'
  cluster_file      = '$4'
  fasta_ref         = '$5'
  bam_alignment     = '$6'
  output_prefix     = '$7'
  output_dir        = '$8'
  threads           = $9
}
""" >> ${7}-idat2vcf.config
}

function qc_config() { #params passed as arguments

#check and remove config file if it exists
[ -e ${3}-qc.config ] && rm ${3}-qc.config

#qc_config $bfile $pheno_file $out $output_dir $hetlower $hetupper $maf $geno $mind $threads $njobs
echo """
params {
  //==================================
  //genemapgwas qc workflow parameters
  //==================================
   bfile            = '${1}'
   pheno_file       = '${2}'
   out              = '${3}'
   output_dir       = '${4}'
   hetlower         = '${5}'
   hetupper         = '${6}'
   maf              = ${7}
   geno             = ${8}
   mind             = ${9}
   threads          = ${10}
   njobs            = ${11}

  /*****************************************************************************************
  -bfile:
    (required) plink binary (.bed + .bim + .fam) file prefix.
  -out:
    (optional) output prefix [default: myout].
  -output_dir:
    (required) path to save output files.
  -pheno_file:
    (optional) phenotype file with header.
  -hetlower:
    (optional) lower heterozygosity value below which individuals are removed [default: mean-3SD].
  -hetupper:
    (optional) upper heterozygosity value above which individuals are removed [default: mean+3SD].
  -maf:
    (optional) minor allele frequency threshold [default: 0.05].
  -geno:
    (optional) variant missing call frequency threshold [default: 0.05]
  -mind:
    (optional) sample missing call frequency threshold [default: 0.10]
  -threads:
    (optional) number of computer cpus to use  [default: 11]
  -njobs:
      (optional) number of jobs to submit at once [default: 10]
  *******************************************************************************************/
}

`set_global_params`
""" >> ${3}-qc.config
}

function plink_assoc_config() { #params passed as arguments

#check and remove config file if it exists
[ -e ${4}-plink-assoc.config ] && rm ${4}-plink-assoc.config

#plink_assoc_config $bfile $output_dir $pheno_file $out $covar $covar_name $maf $geno $mind $hwe $threads $njobs
echo """
params {
  //==================================
  //genemapgwas qc workflow parameters
  //==================================
   bfile            = '${1}'
   bfile_dir        = '${2}'
   output_dir       = '${3}'
   pheno_file       = '${4}'
   out              = '${5}'
   covar            = '${6}'
   covar_name       = '${7}'
   maf              = ${8}
   geno             = ${9}
   mind             = ${10}
   hwe              = ${11}
   threads          = ${12}
   njobs            = ${13}

  /*****************************************************************************************
  -bfile:
    (required) plink binary (.bed + .bim + .fam) file prefix.
  -bfile_dir: 
    (required) directory cpntaining plink binary filesets (.bed + .bim + .fam) [required].
  -out:
    (optional) output prefix [default: myout].
  -output_dir:
    (required) path to save output files.
  -pheno_file:
    (optional) phenotype file with header.
  -covar: 
    (optional) covariates file with header.
  -covar_name: 
    (optional) covariate names to read from covariate file ... .
  -maf:
    (optional) minor allele frequency threshold [default: 0.05].
  -geno:
    (optional) variant missing call frequency threshold [default: 0.05]
  -mind:
    (optional) sample missing call frequency threshold [default: 0.10]
  -hwe: 
    (optional) Hardy-Weinberg equilibrium test p-value threshold [default: 1e-6]
  -threads:
    (optional) number of computer cpus to use  [default: 11]
  -njobs:
      (optional) number of jobs to submit at once [default: 10]
  *******************************************************************************************/
}

`set_global_params`
""" >> ${4}-plink-assoc.config
}

function piconfig() {
echo """
params {
    sample_list = ''
    vcf_dir = ''
    output_dir = ''
    out_prefix = ''
    maf =
    max_af =
    r2 =
    r2_name =
}

`setglobalparams`
""" >>
}

if [ $# -lt 1 ]; then
   usage; 1>&2; exit 1;
else
   case $1 in
      test)
         #pass profile as argument
         #check_profile $2;
         profile='local,singularity,hg19'
         test_config
      ;;
      idat2vcf)
         #pass profile as argument
         check_profile $2;
         profile=$2;
         shift;
         if [ $# -lt 2 ]; then
            idat_usage; 1>&2;
            exit 1;
         fi

         prog=`getopt -a --long "help,bpm_manifest:,csv_manifest:,cluster_file:,fasta:,bam_alignment:,out:,output_dir:,threads:" -n "${0##*/}" -- "$@"`;
         
         # defaults
         indir=NULL
         bpm=NULL
         csv=NULL
         cluster=NULL
         fasta=NULL
         bam=NULL
         out=myout
         output_dir="$(pwd)/output/"
         thrds=8
         
         eval set -- "$prog"

         while true; do
            case $1 in
               --idat_dir) indir="$2"; shift 2;;
               --bpm_manifest) bpm="$2"; shift 2;;
               --csv_manifest) csv="$2"; shift 2;;
               --cluster_file) cluster="$2"; shift 2;;
               --fasta) fasta="$2"; shift 2;;
               --bam_alignment) bam="$2"; shift 2;;
               --out) out="$2"; shift 2;;
               --output_dir) output_dir="$2"; shift 2;;
               --threads) thrds="$2"; shift 2;;
               --help) shift; idat_usage; 1>&2; exit 1;;
               --) shift; break;;
               *) shift; idat_usage; 1>&2; exit 1;;
            esac
         done

         #- check required options
         if [[ $indir == -* ]] || [[ $indir == NULL ]]; then
            echo "You have not specified an idat directory!";
            idat_usage 1>&2;
            exit 1;
         else
         idat_config $indir $bpm $csv $cluster $fasta $bam $out $output_dir $thrds;
         #echo `nextflow -c ${out}-idat2vcf.config run idat2vcf.nf -profile $profile -w ${output_dir}/work/`
         fi

      ;;
      qc)
         #pass profile as argument
         check_profile $2;
         profile=$2;
         shift;
         if [ $# -lt 2 ]; then
            qc_usage; 1>&2;
            exit 1;
         fi        

         prog=`getopt -a --long "help,bfile:,out:,output_dir:,pheno_file:,threads:,hetlower:,hetupper:,maf:,geno:,mind:,njobs:" -n "${0##*/}" -- "$@"`;

         #- defaults         
         bfile=NULL
         pheno_file=NULL
         out=myout
         output_dir=NULL
         hetlower=NULL
         hetupper=NULL
	 geno=0.05
	 mind=0.10
         threads=1
	 njobs=5
         maf=0.05
          
         eval set -- "$prog"
         
         while true; do
            case $1 in
               --bfile) bfile="$2"; shift 2;;
               --out) out="$2"; shift 2;;
               --output_dir) output_dir="$2"; shift 2;;
               --pheno_file) pheno_file="$2"; shift 2;;
               --threads) threads="$2"; shift 2;;
               --hetlower) hetlower="$2"; shift 2;;
               --hetupper) hetupper="$2"; shift 2;;
               --maf) maf="$2"; shift 2;;
               --geno) geno="$2"; shift 2;;
	       --mind) mind="$2"; shift 2;;
	       --njobs) njobs="$2"; shift 2;;
               --help) shift; qc_usage; 1>&2; exit 1;;
               --) shift; break;;
               *) shift; qc_usage; 1>&2; exit 1;;
            esac
            continue; shift;
         done

         check_required_params \
	     bfile,$bfile \
	     output_dir,$output_dir && \
         check_optional_params \
             out,$out \
	     pheno_file,$pheno_file \
	     hetlower,$hetlower \
	     hetupper,$hetupper \
	     maf,$maf \
	     geno,$geno \
	     mind,$mind \
	     threads,$threads \
	     njobs,$njobs && \
         qc_config \
	     $bfile \
	     $pheno_file \
	     $out \
	     $output_dir \
	     $hetlower \
	     $hetupper \
	     $maf \
	     $geno \
	     $mind \
	     $threads \
	     $njobs
         #echo `nextflow -c ${out}-qc.config run qualitycontrol.nf -profile $profile -w ${output_dir}/work/`
      ;;
      plink-assoc)
         #pass profile as argument
         check_profile $2;
         profile=$2;
         shift;
         if [ $# -lt 2 ]; then
            plink_assoc_usage; 1>&2;
            exit 1;
         fi        

         prog=`getopt -a --long "help,bfile:,bfile_dir:,out:,output_dir:,pheno_file:,threads:,covar:,covar_name:,maf:,geno:,mind:,hwe:,njobs:" -n "${0##*/}" -- "$@"`;

         #- defaults         
	 bfile=NULL            #required
	 bfile_dir=NULL        #required
         pheno_file=NULL       #optional
         out=myout             #optional
         output_dir=NULL       #required
         covar=NULL            #optional
         covar_name=NULL       #optional
         maf=0.05              #optional
	 geno=0.05             #optional
	 mind=0.10             #optional
	 hwe=1e-6              #optional
         threads=1             #optional
	 njobs=5               #optional
          
         eval set -- "$prog"
         
         while true; do
            case $1 in
               --bfile) bfile="$2"; shift 2;;
               --bfile_dir) bfile_dir="$2"; shift 2;;
               --out) out="$2"; shift 2;;
               --output_dir) output_dir="$2"; shift 2;;
               --pheno_file) pheno_file="$2"; shift 2;;
               --covar) covar="$2"; shift 2;;
               --covar_name) covar_name="$2"; shift 2;;
               --maf) maf="$2"; shift 2;;
               --geno) geno="$2"; shift 2;;
	       --mind) mind="$2"; shift 2;;
               --hwe) hwe="$2"; shift 2;;
               --threads) threads="$2"; shift 2;;
	       --njobs) njobs="$2"; shift 2;;
               --help) shift; qc_usage; 1>&2; exit 1;;
               --) shift; break;;
               *) shift; qc_usage; 1>&2; exit 1;;
            esac
            continue; shift;
         done

         check_required_params \
	     bfile,$bfile \
	     output_dir,$output_dir && \
         check_optional_params \
             out,$out \
	     pheno_file,$pheno_file \
	     covar,$covar \
	     covar_name,$covar_name \
	     maf,$maf \
	     geno,$geno \
	     mind,$mind \
             hwe,$hwe \
	     threads,$threads \
	     njobs,$njobs && \
         plink_assoc_config \
	     $bfile \
	     $output_dir \
	     $pheno_file \
	     $out \
	     $covar \
	     $covar_name \
	     $maf \
	     $geno \
	     $mind \
	     $hwe \
	     $threads \
	     $njobs
         #echo `nextflow -c ${out}-qc.config run qualitycontrol.nf -profile $profile -w ${output_dir}/work/`
      ;;      
      *) echo -e $usage
   esac

   #echo -e "\nRunning ${comd}...\n"


fi


