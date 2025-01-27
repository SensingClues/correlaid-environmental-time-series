library(shiny)
library(ggplot2)
library(terra)
library(leaflet)
library(tidyr)
library(dplyr)
library(plotly)
library(htmlwidgets)

# Dynamically detect the directory of the app.R file
app_dir <- normalizePath(getwd()) # Works in deployed apps or locally

# Define paths relative to app.R
scripts_dir <- file.path(dirname(app_dir), "shiny-server/scripts")
figures_dir <- file.path(dirname(app_dir), "shiny-server/www/figures")
data_dir <- file.path(dirname(app_dir), "shiny-server/www/data")

source(file.path(scripts_dir, "utils.R"), local = TRUE)
source(file.path(scripts_dir, "visualize.R"), local = TRUE)
source(file.path(scripts_dir, "generate_plots.R"), local = TRUE)

# UI function for NDVI Timeseries Dashboard
ndviTimeseriesUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Title and description
    div(class = "project-section max-w-4xl mx-auto px-6 py-4",
        h2(class = "text-3xl font-bold text-gray-800 mb-4", "NDVI Timeseries Dashboard"),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "Generate and explore NDVI (Normalized Difference Vegetation Index) timeseries visualizations for different countries and time periods. Select a country, month, and year to generate a custom figure."),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "The visualization shows the temporal dynamics of vegetation for the selected region, including trends and seasonal variations.")
    ),
    
    # Controls for user input
    div(class = "controls max-w-4xl mx-auto px-6 py-4",
        selectInput(ns("country"), "Select Country:", 
                    choices = c("Zambia", "Spain", "Bulgaria", "Kenya")),  # Add more countries as needed
        selectInput(ns("month"), "Select Month:", choices = month.name),
        numericInput(ns("year"), "Enter Year:", value = 2024, min = 2020, max = 2024),
        selectInput(ns("resolution"), "Select spatial resolution (m):", 
                    choices = c(1000, 100, 10)),
        actionButton(ns("generate_plot"), "Generate Figure")
    ),
    
    # plot image
    imageOutput(ns("plot_output"))

  )
}

# Server function for NDVI Timeseries Dashboard
ndviTimeseriesServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Observe the Generate Figure button
    observeEvent(input$generate_plot, {

      # Get user inputs
      country_name <- input$country
      end_month <- match(input$month, month.name)
      end_year <- input$year
      resolution <- input$resolution

      # Define script and figure paths
      #script_path <- file.path(scripts_dir, "plot_timeseries.R")  # Path to the script
      figure_filename <- paste0("figure_NDVItimeseries_", country_name, "_", end_month, "_", end_year, "_", resolution, "m", ".png")
      figure_path <- file.path(figures_dir, figure_filename)
      
      # If figure not stored yet
      if (!file.exists(figure_path)) {

        # Ensure the figures directory exists
        if (!dir.exists(figures_dir)) {
          dir.create(figures_dir, recursive = TRUE)
        }

        # Create timeseries plot
        generate_timeseries(country_name = country_name, resolution = resolution,
                            end_year = end_year, end_month = end_month,
                            figures_dir = figures_dir, data_dir = data_dir,
                            return_plot = FALSE, figure_filename = figure_filename
                            )
      }

      # Render
      output$plot_output <- renderImage({
        list(src = figure_path,
         width = "100%",
         alt = "NDVI timeseries")
        
      }, deleteFile = FALSE)
    })
  })
}
