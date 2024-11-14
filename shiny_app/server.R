library(shiny)
library(plotly)

source("pages/sensor_deployment.R")

# Define server logic for displaying dynamic content
shinyServer(function(input, output, session) {

  # Define content to display when "Sensor Deployment" is clicked
  observeEvent(input$sensor_deployment, {
    output$pageContent <- renderUI({
      sensorDeploymentUI("sensorDeployment")  # Call UI function for Sensor Deployment
    })
    sensorDeploymentServer("sensorDeployment")  # Call Server function for Sensor Deployment
  })
  
  # Define content to display when "Camera Traps" is clicked
  observeEvent(input$camera_traps, {
    output$pageContent <- renderUI({
      tagList(
        h2("Camera Traps"),
        p("Camera traps are used to monitor and record wildlife activity remotely."),
        p("This section provides information on setting up and using camera traps effectively in conservation projects.")
      )
    })
  })

  # Define content to display when "Drone Surveys" is clicked
  observeEvent(input$drone_surveys, {
    output$pageContent <- renderUI({
      tagList(
        h2("Drone Surveys"),
        p("Drone surveys are an essential tool for large-area monitoring and mapping."),
        p("Learn more about the applications of drones in habitat mapping and species tracking.")
      )
    })
  })

  # Define content to display when "Environmental Monitoring" is clicked
  observeEvent(input$environmental_monitoring, {
    output$pageContent <- renderUI({
      tagList(
        h2("Environmental Monitoring"),
        p("Environmental monitoring focuses on measuring ecosystem health and identifying potential threats."),
        p("Explore various techniques and tools used in environmental monitoring for conservation.")
      )
    })
  })

  # Define content to display when "Biodiversity Tracking" is clicked
  observeEvent(input$biodiversity_tracking, {
    output$pageContent <- renderUI({
      tagList(
        h2("Biodiversity Tracking"),
        p("Biodiversity tracking helps in understanding species distribution and population trends."),
        p("Find out how tracking biodiversity contributes to conservation efforts.")
      )
    })
  })

  # You can add more `observeEvent` blocks for other links (like those under "Analysis" or "Resources") as needed.

})

