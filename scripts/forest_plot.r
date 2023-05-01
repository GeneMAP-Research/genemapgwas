#!/usr/bin/env Rscript

args <- commandArgs(TRUE)

if (length(args) < 3) {
   message("\nUsage: forest_plot.r [input] [output prefix] [plot title]\n")
   message("\tinput is a text file with three columns; study beta se\n")
   quit(save="no")
} else {
    input <- args[1]
    png_plt_name <- paste0(args[2], ".png")
    svg_plt_name <- paste0(args[2], ".svg")
    plot_title <- args[3]

    data <- read.table(input, h=T)
    colnames(data) <- tolower(names(data))
    if( "pvalue" %in% names(data) ) {
        data$pval <- format( data$pvalue, scientific = TRUE )
    }

    blank.plot <- function( xlim = c( 0, 1 ), ylim = c( 0, 1 ), xlab = "", ylab = "" ) {
      # this function plots a blank canvas
      plot(
        0, 0,
        col = 'white', # draw points white
        bty = 'n',     # no border
        xaxt = 'n',    # no x axis
        yaxt = 'n',    # no y axis
        xlab = xlab,   # no x axis label
        ylab = ylab,   # no x axis label
        xlim = xlim,
        ylim = ylim
      )
    }
   
    draw.forest.plot <- function(
      betas,
      ses,
      names
    ) {
      # y axis locations for the lines.
      # We assume the meta-analysis will go on the last line, so we separate it slightly by putting it at 1/2
      #y = c( length(betas):2, 0.5 ) #uncomment this line to separate the meta-analysis slightly by putting it at 1/2
      y = c( length(betas):1 )

    
      # learn a good x axis range by going out 3 standard errors from each estimate:
      xlim = c( min( betas - 3 * ses ), max( betas + 3 * ses ))
      # Also let's make sure to include zero in our range
      xlim[1] = min( xlim[1], 0 )
      xlim[2] = max( xlim[2], 0 )
    
      # expand the range slightly
      xcentre = mean(xlim)
      xlim[1] = xcentre + (xlim[1] - xcentre) * 1.1
      xlim[2] = xcentre + (xlim[2] - xcentre) * 1.1
    
      # Give ourselves a big left margin for the row labels
      par( mar = c( 4.1, 6.1, 2.1, 2.1 ))
      blank.plot(
        xlim = xlim,
        ylim = c( range(y) + c( -0.5, 0.5 )),
        xlab = "Effect size and 95% CI"
      )

      # add grid lines
      grid( lwd = 0.5 )
    
      # Draw the intervals first so they don't draw over the points
      segments(
        x0 = betas - 1.96 * ses, x1 = betas + 1.96 * ses,
        y0 = y, y1 = y,
        col = 'grey'
      )
    
      # Now plot the estimates
      points(
        x = betas,
        y = y,
        col = 'black',
        pch = 19,
	cex = 1 + abs(betas)*2
      )
    
      # ... and add labels.  We put them 10% further left than the leftmost point
      # and we right-align them
      text.x = xcentre + (xlim[1] - xcentre) * 1.1
      text(
        x = text.x,
        y = y,
        labels = names,
        adj = 0.8, # right-adjust
        xpd = NA # this means "Allow text outside the plot area"
      )
  

      labels.betas = sprintf(
          "%.2f (%.2f - %.2f)",
          betas,
          betas - 1.96 * ses,
          betas + 1.96 * ses
      )

      # ... add beta and se estimates to the plot
      text( 
	x = betas + 0.05,
	y = y - 0.25,
	labels = labels.betas,
	adj = 1,
	xpd = NA,
	col = "brown",
	cex = 0.7
      )
      
      labels.pvals = paste0("P = " , format( data$pvalue, scientific = TRUE, digits = 3 ))

      # ... add p-values to the plot
      text(
        x = betas + 0.05,
        y = y - 0.45,
        labels = labels.pvals,
        adj = 1,
        xpd = NA,
	col = "dodgerblue4",
        cex = 0.7
      )

      mtext(
	text = plot_title,
	side = 3,
	line = 0.8
      )

      # Add an x axis
      axis( 1 )
    
      # add a solid line at 0
      vline = xcentre
      abline( v = 0, col = rgb( 0, 0, 0, 0.2 ), lwd = 2 )
    }
    
    #png(png_plt_name, height = 16, width = 16, units = "cm", res = 300, pointsize = 10)
    svg(svg_plt_name, height = 8, width = 12, pointsize = 18)
    
    #png("13_29080292_C_T.png")
    forest.plot <- function( data ) {
        betas = data$beta
        ses = data$se
        names = data$study
        draw.forest.plot( betas, ses, names )
    }
      
    forest.plot( data )
    dev.off()
}
