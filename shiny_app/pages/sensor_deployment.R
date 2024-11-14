# UI function for Sensor Deployment
sensorDeploymentUI <- function(id) {
  ns <- NS(id)  # Create a namespace for modularization
  tagList(
    h2("Sensor Deployment"),
    p("This page provides an overview of sensor deployment strategies and locations."),
    p("Below is an interactive plot showing hypothetical data on animal sightings based on their distance from the road."),
    plotlyOutput(ns("sensorPlot"))
  )
}

# Server function for Sensor Deployment
sensorDeploymentServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$sensorPlot <- renderPlotly({
      # Example data using mtcars dataset for demonstration
      plot_data <- mtcars
      plot_data$car <- rownames(mtcars)
      
      # Create a plotly scatter plot
      plot_ly(plot_data, x = ~wt, y = ~mpg, type = 'scatter', mode = 'markers',
              marker = list(size = 10, color = 'rgba(51, 204, 204, 0.7)',
                            line = list(color = 'rgba(51, 204, 204, 1.0)', width = 2)),
              text = ~paste("Car:", car, "<br>Weight:", wt, "<br>MPG:", mpg)) %>%
        layout(title = "Animal Sightings vs. Distance to Road",
               xaxis = list(title = "Distance to Road (in miles)"),
               yaxis = list(title = "Animal Sightings"))
    })
  })
}

