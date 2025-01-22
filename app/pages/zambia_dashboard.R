library(ggplot2)
library(htmltools)
library(terra)
library(leaflet)
library(tidyr)
library(dplyr)

source("/srv/shiny-server/scripts/utils.R")

# UI function for Sensor Deployment
zambiaDashboardUI <- function(id) {
  ns <- NS(id)

  tagList(

    div(class = "project-section max-w-4xl mx-auto px-6 py-4",
        h2(class = "text-3xl font-bold text-gray-800 mb-4", "Description of the NDVI Timeseries"),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "The interactive NDVI timeseries plot provides insights into the vegetation trends for the Zambia region over the year. NDVI (Normalized Difference Vegetation Index) values range between 0 and 1, where higher values indicate healthier vegetation."),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "The orange line represents the weighted average NDVI from 2019 to 2023, capturing seasonal variations in vegetation. Points on the line correspond to the mean NDVI for each month, while the shaded area represents the 95% confidence interval, providing an indication of variability across years."),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "This plot highlights the temporal dynamics of vegetation, showing a peak in early months, a decline during the middle of the year, and a recovery toward the end. Such patterns are critical for understanding ecosystem health and planning conservation efforts.")
    ),

    htmlOutput(ns("plotly_html"))

    # page continues below ...
  )
}
# Server function for Sensor Deployment
zambiaDashboardServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  
    # include interactive timeseries
    output$plotly_html <- renderUI({
      tags$iframe(
        src = "figures/zambia_ts_ndvi_plot.html",
        width = "100%",
        height = "800px",
        frameborder = 0
      )
    })


  })
}

