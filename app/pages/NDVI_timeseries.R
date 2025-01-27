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

source(file.path(scripts_dir, "utils.R"))
source(file.path(scripts_dir, "visualize.R"))

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
      
      # If html figure not stored yet
      if (!file.exists(figure_path)) {

        # Ensure the figures directory exists
        if (!dir.exists(figures_dir)) {
          dir.create(figures_dir, recursive = TRUE)
        }

        ### Set paths and define additional parameters
        data_type <- "NDVI"
        # Input NVDI basemaps stored in country folder. 
        data_path <- file.path(data_dir, paste0(data_type, "/", country_name, "/", resolution, "m_resolution/"))
        # Area of Interest (AoI) files in AoI folder
        aoi_path <- file.path(data_dir, "AoI/")

        ## define end and start date for test data
        end_date <- as.Date(paste(end_year, end_month, 1, sep="-"))
        start_date <- seq(end_date, length = 2, by = "-11 months")[2]

        ### Get list of relevant filenames
        ## Create lists with relevant filenames.
        # NDVI filenames
        ndvi_files <- get_filenames(filepath = data_path, data_type = data_type, 
                                    file_extension = ".tif", country_name = country_name)

        # AoI filenames
        aoi_files <- get_filenames(filepath = aoi_path, data_type = "AoI", 
                                file_extension = ".geojson", country_name = country_name)

        ### Subselect filenames according to date
        # get NDVI filenames dataframe (includes date info)
        files_df <- get_filename_df(ndvi_files = ndvi_files)

        # Given date selected, split file into test data and train data
        # test filenames
        test_files_df <- filter(files_df, between(dates, start_date, end_date))
        # get train filenames
        # (train interval: prior to test interval start)
        train_files_df <- files_df[(files_df$dates< start_date),]

        ### Load raster and vector objects - Aoi, train data and test data
        # load input Area of Interest (AoI) to later mask data
        aoi_proj <- get_aoi_vector(aoi_files = aoi_files, aoi_path = aoi_path,
                                projection = "EPSG:4326")

        test_ndvi_msk <- get_ndvi_raster(ndvi_files = test_files_df$filenames, data_path = data_path,
                                    projection = "EPSG:4326", dates = test_files_df$dates,
                                    aoi_proj = aoi_proj)

        train_ndvi_msk <- get_ndvi_raster(ndvi_files = train_files_df$filenames, data_path = data_path,
                                    projection = "EPSG:4326", dates = train_files_df$dates,
                                    aoi_proj = aoi_proj)

        ### Calculate mean NDVI for each month
        # Extract raster layers for each date
        # and store in dataframe
        test_ndvi_df <- get_ndvi_df(ndvi_rast = test_ndvi_msk, dates = test_files_df$dates) 
        train_ndvi_df <- get_ndvi_df(ndvi_rast = train_ndvi_msk, dates = train_files_df$dates) 

        ## Compute mean, SD, and confidence intervals
        # test data
        test_ndvi_summary <- get_summary_ndvi_df(ndvi_df = test_ndvi_df)
        # train data
        train_ndvi_summary <- get_summary_ndvi_df(ndvi_df = train_ndvi_df)

        ### Inspect distribution of NDVI values throughout the year.
        ## Make plot
        ndvi_ts_plot <- plot_ndvi_timeseries(train_data = train_ndvi_summary, 
                                                test_data = test_ndvi_summary,
                                                country_name = country_name, 
                                                resolution = resolution,
                                                plot_width = 15, 
                                                plot_height = 8,
                                                ylim_range = c(0.15, 0.75),
                                                test_start_date = start_date,
                                                test_end_date = end_date,
                                                label_test = paste0("NDVI ", paste(format(c(start_date, end_date), "%b %Y"),collapse=" - ") ),
                                                label_train = paste0("NDVI < ", format(start_date, "%b %Y") ),
                                                save_path = figures_dir,
                                                filename = figure_filename
                                                )
      }

    #   # Run the external script to generate the figure
    #   if (file.exists(script_path)) {
    #     source(script_path, local = TRUE)  # The script should generate the HTML and save it to figure_path
    #   } else {
    #     stop(paste("The script", script_path, "does not exist."))
    #   }

      # Render
      output$plot_output <- renderImage({
        list(src = figure_path,
         width = "100%",
         alt = "NDVI timeseries")
        
      }, deleteFile = FALSE)
    })
  })
}
