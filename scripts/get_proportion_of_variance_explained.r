#!/usr/bin/env Rscript

###############################################################
##
## Calculating proportion of variance explained (pve) per SNP
##
##

args <- commandArgs(TRUE)

if(length(args) < 4) {
   message("\nUsage: get_proportion_of_variance_explianed.r [input] [outprefix] [samplesize <true/N>] [threads]\n")
   message("\tinput must contain the following columns with header names as in brackets [case-insensitive]:")
   message("\teffect size (beta), standard error (se), minor allele frequency (maf), sample size (n)\n")
   message("\tsamplesize: enter 'true' if sample size column is present in input file. Otherwise, enter a fixed sample size number (N)\n")
   quit(save = "no")
} else {

   require(data.table)
  
   #--- get parameter values
   f <- args[1]
   out <- paste0(
	     args[2], 
	     "_with_pve.txt.gz"
          )
   samplesize <- args[3]
   threads <- as.numeric(args[4])

   #--- function to compute pve
   get.pve <- function(
      beta = effect_size, 
      se = standard_error_of_effect_size, 
      maf = minor_allele_freq, 
      n = sample_size
   ) {
#      if(samplesize == 'true') { 
#         next 
#      } else { 
#         n <- as.numeric(samplesize)
#         print(n, quote=F)
#      }
      numerator <- (2*(beta^2))*(maf*(1-maf))
      denomenator <- numerator + (se^2)*(2*n)*maf*(1-maf)
      pve <- numerator/denomenator
      return(pve) 
   }
   
   #--- load data
   load.data <- function(inputdata=f) {
      df <- fread(
               inputdata,
               h = T,
               fill = T,
               nThread = threads
            )

      for(response in samplesize) {
         if(response == 'true') {
            next
         } else {
            df$n <- as.numeric(samplesize)
         }
      }
      #--- ensure column names are in uppercase
      colnames(df) <- toupper(colnames(df))
      return(df)
   }

   #--- compute pve for each SNP and store in a new column called pve
   compute.pve <- function(data=df) {
      for(snp in 1:nrow(data)) {
         data$pve[snp] <- get.pve(
                           beta = data$BETA[snp], 
                           se = data$SE[snp], 
                           maf = data$MAF[snp], 
                           n = data$N[snp]
                       )
      }
      return(data)
   }
   #--- save results to new file
   save.result <- function(result=data) {
      fwrite(
         result, 
         out, 
         nThread = threads, 
         col.names = T, 
         row.names = F, 
         sep = " ", 
         quote = F
      )
   }


   df <- load.data(f)
   pve.res <- compute.pve(df)
   save.result(pve.res)
}


