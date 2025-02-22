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
        selectInput(ns("country"), "Select Country:", selected="Zambia",
                    choices = c("Zambia", "Spain", "Bulgaria", "Kenya")),
        selectInput(ns("month"), "Select Month:", selected="January", choices = month.name),
        numericInput(ns("year"), "Enter Year:", value = 2025, min = 2020, max = 2025),
        selectInput(ns("resolution"), "Select spatial resolution (m):", 
                    selected=100, choices = c(1000, 100)),
        actionButton(ns("generate_static_plot"), "Generate Figure")
    ),
    
    # Output container
    uiOutput(ns("map_output_container")),
    
    div(class = "controls-delta max-w-4xl mx-auto px-6 py-4",
        actionButton(ns("generate_streetview_plot"), "Generate Delta NDVI Figure")
    ),
    
    uiOutput(ns("streetmap_output_container"))
  )
}

# Server function for NDVI Heatmap Dashboard
ndviHeatmapServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$map_output_container <- renderUI({
      imageOutput(ns("map_output"), width = "100%", height = "auto")
    })
    
    output$streetmap_output_container <- renderUI({
      htmlOutput(ns("streetmap_output"), width = "100%", height = "auto")
    })

    observeEvent(input$generate_static_plot, {
      country_name <- input$country
      map_month <- match(input$month, month.name)
      map_year <- input$year
      resolution <- input$resolution
      figure_filename <- paste0("figure_NDVImaps_", country_name, "_", map_month, "_", map_year, "_", resolution, "m.png")
      figure_path <- file.path(figures_dir, figure_filename)

      tryCatch({
        if (!file.exists(figure_path)) {
          if (!dir.exists(figures_dir)) {
            dir.create(figures_dir, recursive = TRUE)
          }
          generate_2Dmap(country_name, resolution, map_year, map_month, figures_dir, data_dir, FALSE, FALSE, figure_filename)
        }
        output$map_output <- renderImage({
          list(src = figure_path, width = "100%", alt = "NDVI 2D map")
        }, deleteFile = FALSE)
      }, error = function(e) {
        output$map_output_container <- renderUI({
          div(style = "color: red;", strong("Error: "), "An error occurred while generating the NDVI data. Check that the necessary data files exist.", br(), br(), paste("Details:", e$message))
        })
        message("Error generating static NDVI map: ", e$message)
      })
    })

    observeEvent(input$generate_streetview_plot, {
      country_name <- input$country
      map_month <- match(input$month, month.name)
      map_year <- input$year
      resolution <- input$resolution
      figure_filename <- paste0("figure_deltaNDVImaps_", country_name, "_", map_month, "_", map_year, "_", resolution, "m.html")
      figure_path <- file.path(figures_dir, figure_filename)

      tryCatch({
        if (!file.exists(figure_path)) {
          if (!dir.exists(figures_dir)) {
            dir.create(figures_dir, recursive = TRUE)
          }
          generate_2Dmap(country_name, resolution, map_year, map_month, figures_dir, data_dir, TRUE, FALSE, figure_filename)
        }
        output$streetmap_output <- renderUI({
          tags$iframe(src = paste0("figures/", figure_filename), width = "100%", height = "500px", frameborder = 0)
        })
      }, error = function(e) {
        output$streetmap_output_container <- renderUI({
          div(style = "color: red;", strong("Error: "), "An error occurred while generating the delta NDVI data. Check that the necessary data files exist.", br(), br(), paste("Details:", e$message))
        })
        message("Error generating delta NDVI map: ", e$message)
      })
    })
  })
}

