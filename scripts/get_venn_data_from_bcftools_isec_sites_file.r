#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if(length(args) < 2) {
   message("\nUsage: get_venn_data_from_bcftools_isec_sites_file.r [sites file] [output prefix]\n")
   quit(save="no")
} else {

   require(data.table)
  
   f <- args[1]
   out <- paste0(args[2], "_venndata.txt")

   sites <- fread(f, nThread=10, h=T, quote='')
   venn.data <- as.data.frame(table(as.factor(sites$info)))
   colnames(venn.data) <- c("panels", "snpcount")
   write.table(venn.data, "venn.data.tmp.txt", col.name=T, row.names=F, quote=F, sep=" ")
   
   venn.data <- read.table("venn.data.tmp.txt", h=T, col.names=c("info", "snpcount"), quote="")
   
   venn.data$panel <- ifelse(venn.data$info == '"10000"', "custom", 
                         ifelse(venn.data$info == '"01000"', "h3a", 
                         ifelse(venn.data$info == '"00100"', "sanger", 
                         ifelse(venn.data$info == '"00010"', "caapa", 
                         ifelse(venn.data$info == '"00001"', "kgp", 
                         ifelse(venn.data$info == '"11000"', "custom_h3a", 
                         ifelse(venn.data$info == '"10100"', "custom_sanger", 
                         ifelse(venn.data$info == '"10010"', "custom_caapa", 
                         ifelse(venn.data$info == '"10001"', "custom_kgp", 
                         ifelse(venn.data$info == '"01100"', "h3a_sanger", 
                         ifelse(venn.data$info == '"01010"', "h3a_caapa", 
                         ifelse(venn.data$info == '"01001"', "h3a_kgp", 
                         ifelse(venn.data$info == '"00110"', "sanger_caapa", 
                         ifelse(venn.data$info == '"00101"', "sanger_kgp", 
                         ifelse(venn.data$info == '"00011"', "caapa_kgp", 
                         ifelse(venn.data$info == '"11100"', "custom_h3a_sanger", 
                         ifelse(venn.data$info == '"11010"', "custom_h3a_caapa", 
                         ifelse(venn.data$info == '"11001"', "custom_h3a_kgp", 
                         ifelse(venn.data$info == '"10110"', "custom_sanger_caapa", 
                         ifelse(venn.data$info == '"00111"', "sanger_caapa_kgp", 
                         ifelse(venn.data$info == '"01011"', "h3a_caapa_kgp", 
                         ifelse(venn.data$info == '"01101"', "h3a_sanger_kgp", 
                         ifelse(venn.data$info == '"01110"', "h3a_sanger_caapa", 
                         ifelse(venn.data$info == '"01111"', "h3a_sanger_caapa_kgp", 
                         ifelse(venn.data$info == '"10011"', "custom_caapa_kgp", 
                         ifelse(venn.data$info == '"10101"', "custom_sanger_kgp", 
                         ifelse(venn.data$info == '"10111"', "custom_sanger_caapa_kgp", 
                         ifelse(venn.data$info == '"11011"', "custom_h3a_caapa_kgp", 
                         ifelse(venn.data$info == '"11101"', "custom_h3a_sanger_kgp", 
                         ifelse(venn.data$info == '"11110"', "custom_h3a_sanger_caapa", 
                         ifelse(venn.data$info == '"11111"', "custom_h3a_sanger_caapa_kgp", "NA"
                  )))))))))))))))))))))))))))))))
   
   venn.data$panel <- as.factor(venn.data$panel)
   try(system("rm venn.data.tmp.txt"))
   write.table(venn.data, out, col.name=T, row.names=F, quote=F, sep="\t")
}
