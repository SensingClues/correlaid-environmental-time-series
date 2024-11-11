# ui.R

library(shiny)

# Define the UI for the app
shinyUI(
  fluidPage(
    titlePanel("Simple Shiny App"),
    
    sidebarLayout(
      sidebarPanel(
        sliderInput("obs", 
                    "Number of observations:", 
                    min = 1, 
                    max = 1000, 
                    value = 500)
      ),
      
      mainPanel(
        plotOutput("distPlot")
      )
    )
  )
)

