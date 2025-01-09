library(shiny)
library(plotly)

source("pages/sensor_deployment.R")
source("pages/project_overview.R")
source("pages/zambia_dashboard.R")

# Define server logic for displaying dynamic content
shinyServer(function(input, output, session) {

  # Define content to display when "Sensor Deployment" is clicked
  observeEvent(input$project_overview, {
    output$pageContent <- renderUI({
      projectOverviewUI("projectOverview")  # Call UI function for Sensor Deployment
    })
    projectOverviewServer("projectOverview")  # Call Server function for Sensor Deployment
  })

  # Define content to display when "Sensor Deployment" is clicked
  observeEvent(input$zambia_dashboard, {
    output$pageContent <- renderUI({
      zambiaDashboardUI("zambiaDashboard") 
    })
    zambiaDashboardServer("zambiaDashboard")
  })
 

})

