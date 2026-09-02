library(dplyr)
library(shiny)
library(plotly)

# This function uses power.t.test to calculate power for the two nested effects (p1, p2) and the interaction (p3), plus imaginary power without HARKing (p4) and with HARKing (p5)

power_sep <- function(pars1,pars2) {
  res <- c(0,0,0)
  p1 <- power.t.test(pars1[3],pars1[1],pars1[2],type="paired",strict=TRUE)$power # Nested effect 1
  p2 <- power.t.test(pars2[3],pars2[1],pars2[2],type="paired",strict=TRUE)$power # Nested effect 2
  p3 <- power.t.test(pars1[3],pars1[1]-pars2[1],pars2[2],type="paired",strict=TRUE)$power # Interaction
  # Power can't be below 0.05
  p1 <- max(p1,0.05)
  p2 <- max(p2,0.05)
  p3 <- max(p3,0.05)
  # Illusory power calculations
  res[4] <- p1*(1-p2) # No HARKing
  res[5] <- p1*(1-p2)+p2*(1-p1) # HARKing
  # Power.t.test outputs 0 for cases that should be NA
  if (pars1[1]==0) {p1 <- NA}
  if (pars2[1]==0) {p2 <- NA}
  if (pars1[1]-pars2[1]==0) {p3 <- NA}
  res[1] <- p1
  res[2] <- p2
  res[3] <- p3
  return(res)
}

# This function uses power_sep to calculate p1 ... p5 for different values of sigma

tsims <- function(delta1,delta2,n,sigmas){
  all <- data.frame(NULL)
  for (sigma in sigmas) {
    all <- rbind(all,c(delta1,delta2,delta1-delta2,sigma,n,power_sep(c(delta1,sigma,n),c(delta2,sigma,n))))
  }
  return(all)
}

# Generating the plots

shinyServer <- function(input, output) {

  # Shared simulation across sigma range for the current slider/checkbox state.
  # Computed once here and reused by all four histograms below, instead of each
  # output re-running the same tsims() call independently.
  sims <- reactive({
    all <- tsims(input$delta1, input$delta2, input$n, seq(input$sigmas[1], input$sigmas[2], 0.5))[, c(4, 6:10)]
    names(all) <- c("sigma", "p1", "p2", "p3", "p4", "p5")
    all
  })

  # Nested effect 1

  output$hist1 <- renderPlot({
    all <- sims()
    hist(all$p1,xlim=c(0,1),breaks=seq(0,1,0.02),col=rgb(0.1,0.8,1,0.5),xlab="Power",main=paste("P1: Power to detect nested effect 1 (A-B, ",input$delta1," ms)",sep=""),yaxt='n',ylab=NA,border="white")
  })

  # Nested effect 2

  output$hist2 <- renderPlot({
    all <- sims()
    hist(all$p2,xlim=c(0,1),breaks=seq(0,1,0.02),col=rgb(0.9,0,1,0.5),xlab="Power",main=paste("P2: Power to detect nested effect 2 (C-D, ",input$delta2," ms)",sep=""),yaxt='n',ylab=NA,border="white")
  })

  # Interaction

  output$hist3 <- renderPlot({
    all <- sims()
    hist(all$p3,xlim=c(0,1),breaks=seq(0,1,0.02),col=rgb(0.2,0.5,0.8,0.5),xlab="Power",main=paste("P4: Actual power to detect interaction (",input$delta1-input$delta2," ms)",sep=""),yaxt='n',ylab=NA,border="white")
  })

  # Imaginary interaction

  output$hist4 <- renderPlot({
    all <- sims()

    # Calculation depends on whether HARKing is active

    if (input$hark) {

      hist(all$p5,xlim=c(0,1),breaks=seq(0,1,0.02),col=rgb(1,0,0.2,0.5),xlab="Illusory 'power'",main="P3: 'Power' for imaginary interaction",yaxt='n',ylab=NA,border="white")

    } else {

      hist(all$p4,xlim=c(0,1),breaks=seq(0,1,0.02),col=rgb(1,0,0.2,0.5),xlab="Illusory 'power'",main="P3: 'Power' for imaginary interaction",yaxt='n',ylab=NA,border="white")

      }

  })
  
  output$threedplot <- renderPlotly({
  P1 <- c(NULL)
  P2 <- c(NULL)
  P3 <- c(NULL)
  for (p1n in seq(0.05,1,0.05)) {
    for (p2n in seq(0.05,1,0.05)) {
      P1 <- c(P1,p1n)
      P2 <- c(P2,p2n)
      P3 <- c(P3,p1n*(1-p2n)+p2n*(1-p1n))
    }
  }
  p <- data.frame(P1,P2,P3)
  
  
  plot_ly(p, x = ~P1, y = ~P2, z = ~P3,
          marker = list(color = ~P3, colorscale = "Viridis",size=3),opacity=0.5)
  })
  
}