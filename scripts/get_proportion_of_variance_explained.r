#!/usr/bin/env Rscript

###############################################################
##
## Calculating proportion of variance explained (pve) per SNP
##
##

args <- commandArgs(TRUE)

if(length(args) < 3) {
   message("\nUsage: get_proportion_of_variance_explianed.r [input] [outprefix] [threads]\n")
   message("\tinput must contain the following columns with header names as in brackets [case-insensitive]:")
   message("\teffect size (beta), standard error (se), minor allele frequency (maf), sample size (n)\n")
   quit(save = "no")
} else {

   require(data.table)
  
   #--- get parameter values
   f <- args[1]
   out <- paste0(
	     args[2], 
	     "_with_pve.txt.gz"
          )
   threads <- as.numeric(args[3])

   #--- function to compute pve
   get.pve <- function(
      beta = effect_size, 
      se = standard_error_of_effect_size, 
      maf = minor_allele_freq, 
      n = sample_size
   ) { 
      numerator <- ((2*(beta)^2)*maf)*(1-maf)
      denomenator <- numerator + (se^2)*(2*n)*maf*(1-maf)
      pve <- numerator/denomenator
      return(pve) 
   }
   
   #--- load data
   df <- fread(
            f,
            h = T,
            nThread = threads
         )

   #--- ensure column names are in uppercase
   colnames(df) <- toupper(colnames(df))

   #--- compute pve for each SNP and store in a new column called pve
   for(snp in 1:nrow(df)) {
      df$pve[snp] <- get.pve(
                        beta = df$BETA[snp], 
                        se = df$SE[snp], 
                        maf = df$MAF[snp], 
                        n = df$N[snp]
                    )
   }
   
   #--- save results to new file
   fwrite(
      df, 
      out, 
      nThread = threads, 
      col.names = T, 
      row.names = F, 
      sep = " ", 
      quote = F
   )
   
}
