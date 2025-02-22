library(shiny)
library(plotly)

source("pages/sensor_deployment.R")
source("pages/project_overview.R")
source("pages/data_collection.R")
source("pages/zambia_dashboard.R")
source("pages/NDVI_timeseries.R")
source("pages/NDVI_heatmap.R")
source("pages/LandCover_explorer.R")

# Define server logic for displaying dynamic content
shinyServer(function(input, output, session) {

  # Define content to display when "Project Overview" is clicked
  observeEvent(input$project_overview, {
    output$pageContent <- renderUI({
      projectOverviewUI("projectOverview")  # Call UI function for Sensor Deployment
    })
    projectOverviewServer("projectOverview")  # Call Server function for Sensor Deployment
  })

  # Define content to display when "Data Collection" is clicked
  observeEvent(input$data_collection, {
    output$pageContent <- renderUI({
      dataOverviewUI("dataCollection") 
    })
    dataOverviewServer("dataCollection")
  })

  # Define content to display when "Sensor Deployment" is clicked
  observeEvent(input$zambia_dashboard, {
    output$pageContent <- renderUI({
      zambiaDashboardUI("zambiaDashboard") 
    })
    zambiaDashboardServer("zambiaDashboard")
  })

  # Define content to display when "NDVI Timeseries" is clicked
  observeEvent(input$NDVI_timeseries, {
    output$pageContent <- renderUI({
      ndviTimeseriesUI("ndviTimeseries") 
    })
    ndviTimeseriesServer("ndviTimeseries")
  })

  # Define content to display when "NDVI Heatmap" is clicked
  observeEvent(input$NDVI_heatmap, {
    output$pageContent <- renderUI({
      ndviHeatmapUI("ndviHeatmap") 
    })
    ndviHeatmapServer("ndviHeatmap")
  })

  # Define content to display when "Land Cover Explorer" is clicked
  observeEvent(input$landCover_explorer, {
    output$pageContent <- renderUI({
      landCoverUI("landCover") 
    })
    landCoverServer("landCover")
  })
 

})

