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

# Source helper scripts
source("utils.R")
source("visualize.R")
source("generate_plots.R")

figures_dir <- file.path("www/figures")
data_dir <- file.path("www/data")

# UI function for NDVI Timeseries Dashboard
ndviTimeseriesUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Title and description
    div(class = "project-section max-w-4xl mx-auto px-6 py-4",
        h2(class = "text-3xl font-bold text-gray-800 mb-4", "NDVI Timeseries Dashboard"),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "Generate and explore the Normalized Difference Vegetation Index (NDVI) values, averaged over an area of interest. The timeseries visualization shows the temporal dynamics of vegetation for the selected region for a 12-month period, including trends and seasonal variations."),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "To generate the figure, please select a country, month, and year.")
    ),
    
    # Controls for user input
    div(class = "controls max-w-4xl mx-auto px-6 py-4",
        selectInput(ns("country"), "Select Country:", 
                    choices = c("Zambia", "Spain", "Bulgaria", "Kenya")),  # Add more countries as needed
        selectInput(ns("month"), "Select Month:", choices = month.name),
        numericInput(ns("year"), "Enter Year:", value = 2024, min = 2020, max = 2024),
        selectInput(ns("resolution"), "Select spatial resolution (m):", 
                    choices = c(1000, 100)),
        actionButton(ns("generate_plot"), "Generate Figure")
    ),
    
    # Output container (we'll fill this dynamically with either an image or an error message)
    uiOutput(ns("plot_container"))
  )
}

# Server function for NDVI Timeseries Dashboard
ndviTimeseriesServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Render a container for the plot or error message
    output$plot_container <- renderUI({
      # Default UI is just an image placeholder
      imageOutput(ns("plot_output"), width = "100%", height = "auto")
    })

    # Observe the Generate Figure button
    observeEvent(input$generate_plot, {

      # Get user inputs
      country_name <- input$country
      end_month <- match(input$month, month.name)
      end_year <- input$year
      resolution <- input$resolution

      # Define script and figure paths
      figure_filename <- paste0("figure_NDVItimeseries_", country_name, "_", 
                                end_month, "_", end_year, "_", resolution, "m", ".png")
      figure_path <- file.path(figures_dir, figure_filename)
      
      # Wrap data generation in tryCatch to handle missing files/errors
      tryCatch({

        # If figure not stored yet, attempt to generate it
        if (!file.exists(figure_path)) {
          
          # Ensure the figures directory exists
          if (!dir.exists(figures_dir)) {
            dir.create(figures_dir, recursive = TRUE)
          }

          # Create timeseries plot
          generate_timeseries(
            country_name   = country_name,
            resolution     = resolution,
            end_year       = end_year,
            end_month      = end_month,
            figures_dir    = figures_dir,
            data_dir       = data_dir,
            return_plot    = FALSE,
            figure_filename= figure_filename
          )
        }

        # If no error so far, render the image
        output$plot_output <- renderImage({
          list(
            src   = figure_path,
            width = "100%",
            alt   = "NDVI timeseries"
          )
        }, deleteFile = FALSE)

      }, error = function(e) {
        
        # If an error occurs (commonly missing data), replace the default UI with a message
        output$plot_container <- renderUI({
          div(
            style = "color: red; margin-top: 20px;",
            strong("Error: "),
            "An error occurred while generating or reading the NDVI timeseries data. ",
            "This may be due to missing files or incorrect file paths. ",
            "Please verify that the necessary data files exist in '", data_dir, "'.", "working directory", app_dir
            br(), br(),
            paste("Details:", e$message),
            br(),
            paste("Country Name:", country_name),
            br(),
            paste("Resolution:", resolution),
            br(),
            paste("End Year:", end_year),
            br(),
            paste("End Month:", end_month),
            br(),
            paste("Figures Directory:", figures_dir),
            br(),
            paste("Data Directory:", data_dir)
          )
        })
        
        # Optionally, also log the error to the console for debugging
        message("Error generating NDVI timeseries: ", e$message)
      })
    })
  })
}

