#!/usr/bin/env Rscript

require(VennDiagram)
require(sos)
library(RColorBrewer)

myCol <- brewer.pal(5, "Pastel2")
myCol_b <- brewer.pal(6, "Pastel2")



sites <- read.table("venn.data.txt", h=T, quote="")

#sites$panel <- ifelse(sites$info == '"10000"', "custom", ifelse(sites$info == '"01000"', "h3a", ifelse(sites$info == '"00100"', "sanger", ifelse(sites$info == '"00010"', "caapa", ifelse(sites$info == '"00001"', "kgp", ifelse(sites$info == '"11000"', "custom_h3a", ifelse(sites$info == '"10100"', "custom_sanger", ifelse(sites$info == '"10010"', "custom_caapa", ifelse(sites$info == '"10001"', "custom_kgp", ifelse(sites$info == '"01100"', "h3a_sanger", ifelse(sites$info == '"01010"', "h3a_caapa", ifelse(sites$info == '"01001"', "h3a_kgp", ifelse(sites$info == '"00110"', "sanger_caapa", ifelse(sites$info == '"00101"', "sanger_kgp", ifelse(sites$info == '"00011"', "caapa_kgp", ifelse(sites$info == '"11100"', "custom_h3a_sanger", ifelse(sites$info == '"11010"', "custom_h3a_caapa", ifelse(sites$info == '"11001"', "custom_h3a_kgp", ifelse(sites$info == '"10110"', "custom_sanger_caapa", ifelse(sites$info == '"00111"', "sanger_caapa_kgp", ifelse(sites$info == '"01011"', "h3a_caapa_kgp", ifelse(sites$info == '"01101"', "h3a_sanger_kgp", ifelse(sites$info == '"01110"', "h3a_sanger_caapa", ifelse(sites$info == '"01111"', "h3a_sanger_caapa_kgp", ifelse(sites$info == '"10011"', "custom_caapa_kgp", ifelse(sites$info == '"10101"', "custom_sanger_kgp", ifelse(sites$info == '"10111"', "custom_sanger_caapa_kgp", ifelse(sites$info == '"11011"', "custom_h3a_caapa_kgp", ifelse(sites$info == '"11101"', "custom_h3a_sanger_kgp", ifelse(sites$info == '"11110"', "custom_h3a_sanger_caapa", ifelse(sites$info == '"11111"', "custom_h3a_sanger_caapa_kgp", "NA")))))))))))))))))))))))))))))))

sites$panel <- as.factor(sites$panel)


# -- get counts
allintersects <- (sites$snpcount[sites$panel == "custom_h3a_sanger_caapa_kgp"])

allcustom <- (sum(grepFn(pattern="custom", x=sites, column="panel")$snpcount)) 
allh3a <- (sum(grepFn(pattern="h3a", x=sites, column="panel")$snpcount))
allsanger <- (sum(grepFn(pattern="sanger", x=sites, column="panel")$snpcount))
allcaapa <- (sum(grepFn(pattern="caapa", x=sites, column="panel")$snpcount))
allkgp <- (sum(grepFn(pattern="kgp", x=sites, column="panel")$snpcount))

allcustomh3a <- (sum(grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
allcustomsanger <- (sum(grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
allcustomcaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
allcustomkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel")$snpcount))
allh3asanger <- (sum(grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel")$snpcount))
allh3acaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel")$snpcount))
allh3akgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel")$snpcount))
allsangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=sites, column="panel"), column="panel")$snpcount))
allsangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=sites, column="panel"), column="panel")$snpcount))
allcaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=sites, column="panel"), column="panel")$snpcount))

allcustomh3asanger <- (sum(grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allcustomh3acaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allcustomh3akgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allcustomsangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allcustomsangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allcustomcaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allh3asangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allh3asangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allh3acaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel")$snpcount))
allsangercaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=sites, column="panel"), column="panel"), column="panel")$snpcount))

allcustomh3asangercaapa <- (sum(grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
allcustomh3asangerkgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
allcustomh3acaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="h3a", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
allcustomsangercaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="custom", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))
allh3asangercaapakgp <- (sum(grepFn(pattern="kgp", x=grepFn(pattern="caapa", x=grepFn(pattern="sanger", x=grepFn(pattern="h3a", x=sites, column="panel"), column="panel"), column="panel"), column="panel")$snpcount))

# -- get proportions
#    totalsnps <- sum(sites$snpcount)
#    allintersects <- as.numeric(formatC(as.numeric(allintersects/totalsnps), digits=3, format="f"))
#    
#    print(allintersects)
#    
#    allcustom <- as.numeric(formatC(as.numeric(allcustom/totalsnps), digits=3, format="f"))
#    allh3a <- as.numeric(formatC(as.numeric(allh3a/totalsnps), digits=3, format="f"))
#    allsanger <- as.numeric(formatC(as.numeric(allsanger/totalsnps), digits=3, format="f"))
#    allcaapa <- as.numeric(formatC(as.numeric(allcaapa/totalsnps), digits=3, format="f"))
#    allkgp <- as.numeric(formatC(as.numeric(allkgp/totalsnps), digits=3, format="f"))
#    
#    allcustomh3a <- as.numeric(formatC(as.numeric(allcustomh3a/totalsnps), digits=3, format="f"))
#    allcustomsanger <- as.numeric(formatC(as.numeric(allcustomsanger/totalsnps), digits=3, format="f"))
#    allcustomcaapa <- as.numeric(formatC(as.numeric(allcustomcaapa/totalsnps), digits=3, format="f"))
#    allcustomkgp <- as.numeric(formatC(as.numeric(allcustomkgp/totalsnps), digits=3, format="f"))
#    allh3asanger <- as.numeric(formatC(as.numeric(allh3asanger/totalsnps), digits=3, format="f"))
#    allh3acaapa <- as.numeric(formatC(as.numeric(allh3acaapa/totalsnps), digits=3, format="f"))
#    allh3akgp <- as.numeric(formatC(as.numeric(allh3akgp/totalsnps), digits=3, format="f"))
#    allsangercaapa <- as.numeric(formatC(as.numeric(allsangercaapa/totalsnps), digits=3, format="f"))
#    allsangerkgp <- as.numeric(formatC(as.numeric(allsangerkgp/totalsnps), digits=3, format="f"))
#    allcaapakgp <- as.numeric(formatC(as.numeric(allcaapakgp/totalsnps), digits=3, format="f"))
#    
#    allcustomh3asanger <- as.numeric(formatC(as.numeric(allcustomh3asanger/totalsnps), digits=3, format="f"))
#    allcustomh3acaapa <- as.numeric(formatC(as.numeric(allcustomh3acaapa/totalsnps), digits=3, format="f"))
#    allcustomh3akgp <- as.numeric(formatC(as.numeric(allcustomh3akgp/totalsnps), digits=3, format="f"))
#    allcustomsangercaapa <- as.numeric(formatC(as.numeric(allcustomsangercaapa/totalsnps), digits=3, format="f"))
#    allcustomsangerkgp <- as.numeric(formatC(as.numeric(allcustomsangerkgp/totalsnps), digits=3, format="f"))
#    allcustomcaapakgp <- as.numeric(formatC(as.numeric(allcustomcaapakgp/totalsnps), digits=3, format="f"))
#    allh3asangercaapa <- as.numeric(formatC(as.numeric(allh3asangercaapa/totalsnps), digits=3, format="f"))
#    allh3asangerkgp <- as.numeric(formatC(as.numeric(allh3asangerkgp/totalsnps), digits=3, format="f"))
#    allh3acaapakgp <- as.numeric(formatC(as.numeric(allh3acaapakgp/totalsnps), digits=3, format="f"))
#    allsangercaapakgp <- as.numeric(formatC(as.numeric(allsangercaapakgp/totalsnps), digits=3, format="f"))
#    
#    allcustomh3asangercaapa <- as.numeric(formatC(as.numeric(allcustomh3asangercaapa/totalsnps), digits=3, format="f"))
#    allcustomh3asangerkgp <- as.numeric(formatC(as.numeric(allcustomh3asangerkgp/totalsnps), digits=3, format="f"))
#    allcustomh3acaapakgp <- as.numeric(formatC(as.numeric(allcustomh3acaapakgp/totalsnps), digits=3, format="f"))
#    allcustomsangercaapakgp <- as.numeric(formatC(as.numeric(allcustomsangercaapakgp/totalsnps), digits=3, format="f"))
#    allh3asangercaapakgp <- as.numeric(formatC(as.numeric(allh3asangercaapakgp/totalsnps), digits=3, format="f"))

#png("hg19_imputation_panels_venn.png", height = 840, width = 840, units = "px", res = NA, pointsize = 24)
svg("hg19_imputation_panels_venn.svg", height=14, width=14, pointsize = 24)
par(mfrow=c(2,1))
venn.plot <- draw.quintuple.venn(
               allcustom, 
               allh3a, 
               allsanger, 
               allcaapa,
               allkgp,
               allcustomh3a,
               allcustomsanger,
               allcustomcaapa,
               allcustomkgp,
               allh3asanger,
               allh3acaapa,
               allh3akgp,
               allsangercaapa,
               allsangerkgp,
               allcaapakgp,
               allcustomh3asanger,
               allcustomh3acaapa,
               allcustomh3akgp,
               allcustomsangercaapa,
               allcustomsangerkgp,
               allcustomcaapakgp,
               allh3asangercaapa,
               allh3asangerkgp,
               allh3acaapakgp,
               allsangercaapakgp,
               allcustomh3asangercaapa,
               allcustomh3asangerkgp,
               allcustomh3acaapakgp,
               allcustomsangercaapakgp,
               allh3asangercaapakgp,
               allintersects,
               category = c("CUSTOM", "H3A", "SANGER", "CAAPA", "KGP"),
               fill = c("dodgerblue", "goldenrod1", "darkorange1", "seagreen3", "orchid3"),
               cat.col = c("dodgerblue", "goldenrod1", "darkorange1", "seagreen3", "orchid3"),
               cat.cex = 0.9,
               margin = 0.05,
               print.mode = "percent",
               sigdigs = 2,
               cex = c(1.2, 1.2, 1.2, 1.2, 1.2, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 
               0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.55, 0.8, 0.8, 0.8, 0.8, 0.8, 1.2),
               ind = TRUE
            );

grid.draw(venn.plot);
dev.off()

#               sites$snpcount[sites$panel == "custom_h3a"],
#               sites$snpcount[sites$panel == "custom_sanger"],
#               sites$snpcount[sites$panel == "custom_caapa"],
#               sites$snpcount[sites$panel == "custom_kgp"],
#               sites$snpcount[sites$panel == "h3a_sanger"],
#               sites$snpcount[sites$panel == "h3a_caapa"],
#               sites$snpcount[sites$panel == "h3a_kgp"],
#               sites$snpcount[sites$panel == "sanger_caapa"],
#               sites$snpcount[sites$panel == "sanger_kgp"],
#               sites$snpcount[sites$panel == "caapa_kgp"],
#               sites$snpcount[sites$panel == "custom_h3a_sanger"],
#               sites$snpcount[sites$panel == "custom_h3a_caapa"],
#               sites$snpcount[sites$panel == "custom_h3a_kgp"],
#               sites$snpcount[sites$panel == "custom_sanger_caapa"],
#               sites$snpcount[sites$panel == "custom_sanger_kgp"],
#               sites$snpcount[sites$panel == "custom_caapa_kgp"],
#               sites$snpcount[sites$panel == "h3a_sanger_caapa"],
#               sites$snpcount[sites$panel == "h3a_sanger_kgp"],
#               sites$snpcount[sites$panel == "h3a_caapa_kgp"],
#               sites$snpcount[sites$panel == "sanger_caapa_kgp"],
#               sites$snpcount[sites$panel == "custom_h3a_sanger_caapa"],
#               sites$snpcount[sites$panel == "custom_h3a_sanger_kgp"],
#               sites$snpcount[sites$panel == "custom_h3a_caapa_kgp"],
#               sites$snpcount[sites$panel == "custom_sanger_caapa_kgp"],
#               sites$snpcount[sites$panel == "h3a_sanger_caapa_kgp"],
#               sites$snpcount[sites$panel == "custom_h3a_sanger_caapa_kgp"],

