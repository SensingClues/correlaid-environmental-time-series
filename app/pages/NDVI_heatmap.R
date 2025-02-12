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

# UI function for NDVI Heatmap Dashboard
ndviHeatmapUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Title and description
    div(class = "project-section max-w-4xl mx-auto px-6 py-4",
        h2(class = "text-3xl font-bold text-gray-800 mb-4", "NDVI Heatmap Dashboard"),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "Generate and explore the Normalized Difference Vegetation Index (NDVI) value distribution over an area of interest. The map visualization shows the changes in vegetation for a specific month, across several years."),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "To generate the figure, please select a country, month, and year.")
    ),
    
    # Controls for user input
    div(class = "controls max-w-4xl mx-auto px-6 py-4",
        h2(class = "text-3xl font-bold text-gray-800 mb-4", "Monthly NDVI Maps"),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "NDVI values for the selected month, throughout the years."),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "White pixels (missing values) are due to cloud coverage."),
        selectInput(ns("country"), "Select Country:", 
                    choices = c("Zambia", "Spain", "Bulgaria", "Kenya")),  # Add more countries as needed
        selectInput(ns("month"), "Select Month:", choices = month.name),
        numericInput(ns("year"), "Enter Year:", value = 2024, min = 2020, max = 2024),
        selectInput(ns("resolution"), "Select spatial resolution (m):", 
                    choices = c(1000, 100)),
        actionButton(ns("generate_static_plot"), "Generate Figure")
    ),
    
    # Plot image (or error message)
    uiOutput(ns("map_output_container")),

    # Controls for user input
    div(class = "controls-delta max-w-4xl mx-auto px-6 py-4",
        h2(class = "text-3xl font-bold text-gray-800 mb-4", "Delta NDVI Map"),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "NDVI heatmap for the selected month, over street view."),
        p(class = "text-lg text-gray-700 leading-relaxed text-justify mb-2", 
          "The visualization shows the increase/decrease of vegetation for the selected region."),
        actionButton(ns("generate_streetview_plot"), "Generate Figure")
    ),
    
    # Plot street view image (or error message)
    uiOutput(ns("streetmap_output_container"))
  )
}

# Server function for NDVI Timeseries Dashboard
ndviHeatmapServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Render containers initially (we'll update them dynamically)
    output$map_output_container <- renderUI({
      # Placeholder content
      imageOutput(ns("map_output"), width = "100%", height = "auto")
    })
    
    output$streetmap_output_container <- renderUI({
      # Placeholder content
      htmlOutput(ns("streetmap_output"), width = "100%", height = "auto")
    })

    # Observe the Generate Figure button for the static plot
    observeEvent(input$generate_static_plot, {
      
      # Get user inputs
      country_name <- input$country
      map_month <- match(input$month, month.name)
      map_year <- input$year
      resolution <- input$resolution

      # Define script and figure paths
      figure_filename <- paste0("figure_NDVImaps_", country_name, "_", map_month, "_", map_year, "_", resolution, "m", ".png")
      figure_path <- file.path(figures_dir, figure_filename)

      # Use tryCatch to handle missing data or any errors
      tryCatch({

        # If figure not stored yet, try to generate it
        if (!file.exists(figure_path)) {
          
          # Ensure the figures directory exists
          if (!dir.exists(figures_dir)) {
            dir.create(figures_dir, recursive = TRUE)
          }
          
          # Create NDVI per Month plot
          generate_2Dmap(
            country_name = country_name,
            resolution   = resolution,
            map_year     = map_year,
            map_month    = map_month,
            figures_dir  = figures_dir,
            data_dir     = data_dir,
            return_plot  = FALSE,
            plot_delta   = FALSE,
            figure_filename = figure_filename
          )
        }
        
        # Render the generated (or existing) image
        output$map_output <- renderImage({
          list(
            src   = figure_path,
            width = "100%",
            alt   = "NDVI 2D map"
          )
        }, deleteFile = FALSE)

      }, error = function(e) {
        
        # In case of error (likely missing data files), display a helpful message in the UI
        output$map_output_container <- renderUI({
          div(
            style = "color: red;",
            strong("Error: "),
            "An error occurred while generating or reading the NDVI data. ",
            "This may be due to missing files or incorrect file paths. ",
            "Please verify that the necessary data files exist in '", data_dir, "'.",
            br(), br(),
            paste("Details:", e$message)
          )
        })
        
        # You could also log the error or print it to console
        message("Error generating static NDVI map: ", e$message)
      })
    })

    # Observe the Generate Figure button for the street view plot
    observeEvent(input$generate_streetview_plot, {

      # Get user inputs
      country_name <- input$country
      map_month <- match(input$month, month.name)
      map_year <- input$year
      resolution <- input$resolution

      # Define script and figure paths
      figure_filename <- paste0("figure_deltaNDVImaps_", country_name, "_", map_month, "_", map_year, "_", resolution, "m", ".html")
      figure_path <- file.path(figures_dir, figure_filename)

      # Use tryCatch to handle missing data or any errors
      tryCatch({

        # If figure not stored yet, try to generate it
        if (!file.exists(figure_path)) {
          
          # Ensure the figures directory exists
          if (!dir.exists(figures_dir)) {
            dir.create(figures_dir, recursive = TRUE)
          }

          # Create NDVI per Month plot (delta view)
          generate_2Dmap(
            country_name  = country_name,
            resolution    = resolution,
            map_year      = map_year,
            map_month     = map_month,
            figures_dir   = figures_dir,
            data_dir      = data_dir,
            return_plot   = FALSE,
            plot_delta    = TRUE,
            figure_filename = figure_filename
          )
        }
        
        # Render the generated (or existing) HTML
        output$streetmap_output <- renderUI({
          tags$iframe(
            src = paste0("figures/", figure_filename),
            width = "100%",
            height = "500px",
            frameborder = 0
          )
        })

      }, error = function(e) {

        # In case of error (likely missing data files), display a helpful message in the UI
        output$streetmap_output_container <- renderUI({
          div(
            style = "color: red;",
            strong("Error: "),
            "An error occurred while generating or reading the delta NDVI data. ",
            "This may be due to missing files or incorrect file paths. ",
            "Please verify that the necessary data files exist in '", data_dir, "'.",
            br(), br(),
            paste("Details:", e$message)
          )
        })
        
        # You could also log the error or print it to console
        message("Error generating delta NDVI map: ", e$message)
      })
    })
  })
}

