#!/usr/bin/env sh

#--- genemapgwas workflow wrapper ---#

function usage() {
   echo -e "Usage: genemapgwas <command> <profile> [options] ...\n"
   echo """
           This is a wrapper for the genemapgwas workflow

           commands:
           ---------
           idat2vcf: convert illumina IDAT to VCF
                 qc: perform gwas quality control
              assoc: run association tests


           profiles: <executor>,<container>,<reference>
           ---------
          executors: local, slurm
         containers: singularity, aptainer, docker
          reference: hg19, hg38


           examples:
           ---------
         genemapgwas idat2vcf slurm,singularity,hg38 [options]
         genemapgwas qc local,singularity,hg19 --bfile BEDFILE --out MYOUT --outdir MYPATH --pheno_file MYPHENO
   """
}

function checkprofile() {

   #profile was passed as only argument 
   #so it takes position $1 here

   if [[ "$1" == "" ]]; then
      echo "ERROR: please specify a profile to use!"
      1>&2; exit 1;
   elif [[ $1 == -* ]]; then
      echo "ERROR: please specify a valid profile!"
      1>&2; exit 1;
   else
      local profile="$1"
   fi
}

function idatusage() {
   echo -e "\nUsage: genemapgwas idat2vcf <profile> [options] ..."
   echo """
           options:
           --------
           -i,--idat_dir	<file>		: directory containing subfolders with idat files [required].
						  see 'https://genemap-research.github.io/docs/workflows/gwas/idat-to-vcf/'
						  for a detailed description.
           -b,--bpm_manifest	<file>		: bead pool manifest file. It must match the version of the array [required].
           -c,--csv_manifest	<file>		: manifest file same as above in CSV format [required].
           -C,--cluster_file	<file>		: cluster file. It must match the version of the array [required].
           -f,--fasta		<file>		: reference fasta file.
           -B,--bam_alignment	<file>		: if processing in a different genome build than the one the array is in,
						  then provide a bam alignment file for the new genome build.
						  see 'https://github.com/freeseek/gtc2vcf#using-an-alternative-genome-reference'
						  for more information.
           -o,--out		<prefix>	: output prefix [default: myout].
           -d,--outdir		<path>		: path to save output files [required].
           -t,--threads		<int>		: number of computer cpus to use [default: 8].
           -h,--help				: print this help message.

   """
}

function qcusage() {
   echo -e "\nUsage: genemapgwas qc <profile> [options] ..."
   echo """
           options:
           --------
           -b,--bfile 		[prefix]	: plink binary (.bed + .bim + .fam) file prefix [required].
           -o,--out		<prefix>	: output prefix [default: myout].
           -d,--outdir		<path>		: path to save output files [required].
           -p,--pheno_file 	<file>		: phenotype file with header ... [optional].
           -t,--threads		<int>		: number threads [default: 1].
           -l,--hetlower	<float>		: lower heterozygosity value below which individuals are removed (optional) [default: mean-3SD].
           -u,--hetupper        <float>         : upper heterozygosity value above which individuals are removed (optional) [default: mean+3SD].
           -m,--maf		<float>		: minor allele frequency threshold [default: 0.05].
           -h,--help                            : print this help message.
   """
}

function setglobalparams() {
#- create the project nextflow config file
echo """includeConfig \"\${projectDir}/nextflow.config\"
includeConfig \"\${projectDir}/configs/profile-selector.config\"
"""
}

function testconfig() { #params passed as arguments

# $indir $bpm $csv $cluster $fasta $bam $out $outdir $thrds
echo """`setglobalparams`
includeConfig \"\${projectDir}/configs/test.config\"
}
""" >> test.config
}

function idatconfig() { #params passed as arguments

#check and remove config file if it exists
[ -e ${7}-idat2vcf.config ] && rm ${7}-idat2vcf.config

# $indir $bpm $csv $cluster $fasta $bam $out $outdir $thrds
echo """`setglobalparams`

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

function qcconfig() { #params passed as arguments

#check and remove config file if it exists
[ -e ${3}-qc.config ] && rm ${3}-qc.config

# $bed $phe $out $outdir $hetl $hetu $thrds
echo """`setglobalparams`

params {
   bfile            = '${1}'
   pheno_file       = '${2}'
   out              = '${3}'
   output_dir       = '${4}'
   hetlower         = '${5}'
   hetupper         = '${6}'
   threads          = ${7}
}
""" >> ${3}-qc.config
}


if [ $# -lt 1 ]; then
   usage; 1>&2; exit 1;
else
   case $1 in
      idat2vcf)
         #pass profile as argument
         checkprofile $2;
         profile=$2;
         shift;
         if [ $# -lt 2 ]; then
            idatusage; 1>&2;
            exit 1;
         fi

         prog=`getopt -a -o "hi:b:c:C:f:B:o:d:t:" --long "help,bpm_manifest:,csv_manifest:,cluster_file:,fasta:,bam_alignment:,out:,outdir:,threads:" -- "$@"`;
         
         # defaults
         indir=NULL
         bpm=NULL
         csv=NULL
         cluster=NULL
         fasta=NULL
         bam=NULL
         out=myout
         outdir="$(pwd)/output/"
         thrds=8
         
         eval set -- "$prog"

         while true; do
            case $1 in
               -i|--idat_dir) indir="$2"; shift 2;;
               -b|--bpm_manifest) bpm="$2"; shift 2;;
               -c|--csv_manifest) csv="$2"; shift 2;;
               -C|--cluster_file) cluster="$2"; shift 2;;
               -f|--fasta) fasta="$2"; shift 2;;
               -B|--bam_alignment) bam="$2"; shift 2;;
               -o|--out) out="$2"; shift 2;;
               -d|--outdir) outdir="$2"; shift 2;;
               -t|--threads) thrds="$2"; shift 2;;
               -h|--help) shift; idatusage; 1>&2; exit 1;;
               --) shift; break;;
               *) shift; idatusage; 1>&2; exit 1;;
            esac
         done

         #- check required options
         if [[ $indir == -* ]] || [[ $indir == NULL ]]; then
            echo "You have not specified an idat directory!";
            idatusage 1>&2;
            exit 1;
         else
         #setglobalparams;
         idatconfig $indir $bpm $csv $cluster $fasta $bam $out $outdir $thrds;
         #echo `nextflow -c ${out}-idat2vcf.config run idat2vcf.nf -profile $profile -w ${outdir}/work/`
         fi

      ;;
      qc)
         #pass profile as argument
         checkprofile $2;
         profile=$2;
         shift;
         if [ $# -lt 2 ]; then
            qcusage; 1>&2;
            exit 1;
         fi        

         prog=`getopt -a -o "hb:o:d:p:t:l:u:m:" --long "help,bfile:,out:,outdir:,pheno_file:,threads:,hetlower:,hetupper:,maf:" -- "$@"`;

         #- defaults         
         bed=NULL
         phe=NULL
         out=myout
         outdir=NULL
         hetl=NULL
         hetu=NULL
         thrds=1
         maf=0.05
          
         eval set -- "$prog"
         
         while true; do
            case $1 in
               -b|--bfile) bed="$2"; shift 2;;
               -o|--out) out="$2"; shift 2;;
               -d|--outdir) outdir="$2"; shift 2;;
               -p|--pheno_file) phe="$2"; shift 2;;
               -t|--threads) thrds="$2"; shift 2;;
               -l|--hetlower) hetl="$2"; shift 2;;
               -u|--hetupper) hetu="$2"; shift 2;;
               -m|--maf) maf="$2"; shift 2;;
               -h|--help) shift; qcusage; 1>&2; exit 1;;
               --) shift; break;;
               *) shift; qcusage; 1>&2; exit 1;;
            esac
            continue; shift;
         done

         #- check required options
         if [[ $bed == -* ]] || [[ $bed == NULL ]]; then
            echo "You have not specified an input file!";
            qcusage 1>&2;
            exit 1;
         else
         #setglobalparams;
         qcconfig $bed $phe $out $outdir $hetl $hetu $thrds;
         #echo `nextflow -c ${out}-qc.config run qualitycontrol.nf -profile $profile -w ${outdir}/work/`
         fi
      ;;
      assoc) echo "assoc"; shift ;;
      *) echo -e $usg
   esac

   #echo -e "\nRunning ${comd}...\n"


fi


