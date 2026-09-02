library(shiny)
library(bslib)
library(plotly)

# Define UI
shinyUI(fluidPage(
  theme = bs_theme(version = 5),

  tags$head(
    tags$style(HTML("
      .app-notes { font-size: 0.85em; color: #555555; font-family: Georgia, 'Times New Roman', serif; }
    "))
  ),

  # Title
  fluidRow(column(1),column(10,h3("Illusory versus actual power to detect an interaction in a 2x2 design"),

          hr(),

          # Explanatory copy lives in explanation.md so it can be edited/proofread
          # without touching app logic, and reviewed as a plain-text diff.
          includeMarkdown("explanation.md"),

          hr(),

          # Notes on the calculation, likewise pulled out of the UI code.
          div(class = "app-notes", includeMarkdown("calculation-notes.md"))

          ),column(1)),

  fluidRow(

  column(1),

  column(align="center",width=6,

    fluidRow(br(),br()),

    fluidRow(h6("(Click 'play' buttons below each slider to animate)"),br()),

    fluidRow(

    sliderInput("delta1",
                "True difference between conditions A and B (ms):",
                min = 0,
                max = 80,
                value = 30,
                step = 5,
                animate=TRUE),

    sliderInput("delta2",
                "True difference between conditions C and D (ms):",
                min = 0,
                max = 80,
                value = 25,
                step = 5,
                animate=TRUE),

    sliderInput("n",
                "Number of subjects:",
                min = 10,
                max = 100,
                value = 40,
                step=10,
                animate=TRUE),

    sliderInput("sigmas",
                "Standard deviation (ms):",
                min = 10,
                max = 200,
                value = c(70,90),
                step=10,
                animate=TRUE),checkboxInput("hark", "HARK?", value = FALSE)

  )),

  # Histograms for P1 through P4

  column(align="center",width=4,
  fluidRow(plotOutput("hist1",height="170")),
  fluidRow(plotOutput("hist2",height="170")),
  fluidRow(align="center",plotOutput("hist4",height="170")),
  fluidRow(align="center",plotOutput("hist3",height="170"))),

  column(1)

  ),

  hr(),hr(),

  # Interactive Plotly object

  column(align="center",width=12,fluidRow(column(1),column(10,align="center",h4("Relationship between power for nested effects and 'fake interaction' power"),h5("(Drag plot to rotate)"),plotlyOutput("threedplot",inline=TRUE)),column(1)))
  
  )
)