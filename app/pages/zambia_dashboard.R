library(ggplot2)
library(terra)
library(leaflet)
library(tidyr)
library(dplyr)

source("../../scripts/utils.R")

# Configuration List
config <- list(
  country_name = "Zambia",
  data_type = "NDVI",
  resolution = "250m",  # Update as needed
  data_path = "../../data/2023-11_2024-10_NDVI_By_Life Connected/",
  aoi_path = "../../data/aoi/",
  latest_date = "2024-10-01"
)

# setup configuration file paths
ndvi_files <- get_filenames(
    filepath = config$data_path,
    data_type = config$data_type,
    file_extension = ".tif",
    country_name = config$country_name
)

aoi_files <- get_filenames(
    filepath = config$aoi_path,
    data_type = "AoI",
    file_extension = ".geojson",
    country_name = config$country_name
)

date_list <- extract_dates(file_list = ndvi_files)

ndvi_files <- order_by_date(
    file_list = ndvi_files,
    dates = date_list,
    decreasing = FALSE
)

# load raster & mask data
ndvi_rast <- terra::rast(paste0(config$data_path, ndvi_files))
aoi_vec <- sf::st_read(paste0(config$aoi_path, aoi_files))

# Common transformations: project a raster
# see https://epsg.io/ for projection systems
ndvi_proj <- terra::project(ndvi_rast, "EPSG:4326") 
aoi_proj <- sf::st_transform(aoi_vec, "EPSG:4326") 

## Mask the raster, to remove background values (if any).
ndvi_msk <- terra::mask(ndvi_proj, aoi_proj)
names(ndvi_msk) <- c(date_list)
time(ndvi_msk) <- as.Date(paste0(date_list, "-01"))


# UI function for Sensor Deployment
zambiaDashboardUI <- function(id) {
  ns <- NS(id)

  tagList(
    h2("Zambia Dahsboard"),
    p("Dashboard for the Zambia Region"),
    p("Interactive Plot"),
    plotOutput(ns("raster_output"), height="600px")
  )

}
# Server function for Sensor Deployment
zambiaDashboardServer <- function(id) {
  moduleServer(id, function(input, output, session) {
  
    output$raster_output <- renderPlot({
      brgr.colors <- colorRampPalette(c("brown4", "darkgoldenrod1", "chartreuse4")) # define colormap, red brown to green
      terra::plot(ndvi_msk[[time(ndvi_msk) == config$latest_date]], col=brgr.colors(10), range =c(-1, 1))
    })


  })
}

