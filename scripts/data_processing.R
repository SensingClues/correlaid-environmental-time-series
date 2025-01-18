# Load necessary libraries
load_libraries <- function() {
  suppressMessages({
    library(ggplot2)
    library(terra)
    library(leaflet)
    library(tidyr)
    library(sf)
    library(geojsonio)
    library(dplyr)
    library(gridExtra)
    library(osmdata)
    library(prettymapr)
    library(ggspatial)  # For adding OSM basemaps
  })
}

# Set paths and load data
set_paths_and_load_data <- function(country_name, resolution, data_type) {
  data_path_historic <- paste0("../data/", country_name, "/historic/", resolution, "m_resolution/")
  data_path_current <- paste0("../data/", country_name, "/current/", resolution, "m_resolution/")
  aoi_path <- "../data/aoi/"
  
  ndvi_files_historic <- get_filenames(filepath = data_path_historic, data_type = data_type, file_extension = ".tif", country_name = country_name)
  ndvi_files_current <- get_filenames(filepath = data_path_current, data_type = data_type, file_extension = ".tif", country_name = country_name)
  aoi_files <- get_filenames(filepath = aoi_path, data_type = "AoI", file_extension = ".geojson", country_name = country_name)
  
  return(list(
    data_path_historic = data_path_historic,
    data_path_current = data_path_current,
    aoi_path = aoi_path,
    ndvi_files_historic = ndvi_files_historic,
    ndvi_files_current = ndvi_files_current,
    aoi_files = aoi_files
  ))
}

# Extract and order dates
extract_and_order_dates <- function(ndvi_files) {
  dates <- extract_dates(file_list = ndvi_files)
  ndvi_files <- order_by_date(file_list = ndvi_files, dates = dates, decreasing = FALSE)
  return(list(ndvi_files = ndvi_files, dates = dates))
}

# Load, transform, and mask data
load_transform_and_mask_data <- function(data_path, ndvi_files, dates, aoi_path, aoi_files, crs) {
  ndvi_rast <- terra::rast(paste0(data_path, ndvi_files))
  aoi_vec <- sf::st_read(paste0(aoi_path, aoi_files))
  
  ndvi_proj <- terra::project(ndvi_rast, crs)
  aoi_proj <- sf::st_transform(aoi_vec, crs)
  
  ndvi_msk <- terra::mask(ndvi_proj, aoi_proj)

  # change layer names for plotting
  names(ndvi_msk) <- c(dates)
  
  return(list(ndvi_proj = ndvi_proj, ndvi_msk = ndvi_msk, aoi_proj = aoi_proj))
}

# Sanity check data
sanity_check_data <- function(ndvi_proj, ndvi_msk) {
  cat("Class of ndvi_proj: ", class(ndvi_proj), "\n")
  cat("Class of ndvi_msk: ", class(ndvi_msk), "\n")

  par(mfrow=c(1,2))
  terra::plot(ndvi_proj[[1]], main = "Projected NDVI")
  terra::plot(ndvi_msk[[1]], main = "Masked NDVI")
}

# Compute and plot NDVI maps
compute_and_plot_ndvi_maps <- function(ndvi_msk, dates) {
  terra::time(ndvi_msk) <- as.Date(paste0(dates, "-01"))
  ndvi_msk_mean <- terra::tapp(ndvi_msk, "months", fun=function(x) mean(x, na.rm = TRUE))
  ndvi_msk_stdev <- terra::tapp(ndvi_msk, "months", fun=function(x) sd(x, na.rm = TRUE))
  
  month_names <- month.name[c(terra::time(ndvi_msk_mean))]
  names(ndvi_msk_mean) <- c(month_names)
  names(ndvi_msk_stdev) <- c(month_names)
  
  brgr.colors <- colorRampPalette(c("bisque1", "darkgoldenrod1", "chartreuse4"))
  terra::plot(ndvi_msk_mean, col=brgr.colors(10), range =c(-1, 1), main = "NDVI Mean Map")
  
  hot.colors <- colorRampPalette(c("darkgrey", "brown1", "darkgoldenrod1", "yellow"))
  terra::plot(ndvi_msk_stdev, col=hot.colors(10), range = c(0, .4), main = "NDVI Standard Deviation Map")
}

# Inspect NDVI values distribution
inspect_ndvi_distribution <- function(ndvi_msk, dates, country_name) {
  ndvi_df <- as.data.frame(x = ndvi_msk, row.names = NULL, xy = FALSE)
  colnames(ndvi_df) <- c(dates)
  
  ndvi_longdf <- ndvi_df %>%
    pivot_longer(cols = everything(), names_to = "YearMonth", values_to = "NDVI") %>%
    na.omit()
  
  ndvi_longdf$dates <- as.Date(paste0(ndvi_longdf$YearMonth, "-01"))
  ndvi_longdf <- transform(ndvi_longdf, month = format(dates, "%m"), year = format(dates, "%Y"))
  
  # Extract unique years for the title
  years_included <- unique(ndvi_longdf$year)
  years_range <- paste(min(years_included), max(years_included), sep = "-")
  
  # Calculate dynamic ylim values based on NDVI data
  ndvi_min <- min(ndvi_longdf$NDVI, na.rm = TRUE)
  ndvi_max <- max(ndvi_longdf$NDVI, na.rm = TRUE)
  
  # Create the boxplot
  p1 <- ggplot(ndvi_longdf, aes(x = month, y = NDVI, fill = month)) +
    geom_boxplot(na.rm = TRUE) +
    theme_minimal(base_size = 15) +
    theme(
      plot.background = element_rect(fill = "white"),
      panel.background = element_rect(fill = "white"),
      axis.title = element_text(size = 18),
      axis.text = element_text(size = 14),
      plot.title = element_text(size = 20, face = "bold"),
      legend.position = "none"
    ) +
    labs(title = paste0(country_name, " NDVI per Month (", years_range, ")"), x = "Month", y = "NDVI") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ylim(ndvi_min, ndvi_max) +
    scale_fill_manual(values = hcl.colors(12, palette = "Earth"))
  
  # Create the summary plot
  ndvi_summary <- ndvi_longdf %>%
    group_by(month) %>%
    summarize(
      mean_val = mean(NDVI),
      lower_ci = mean(NDVI) - 1.96 * sd(NDVI) / sqrt(length(NDVI)),
      upper_ci = mean(NDVI) + 1.96 * sd(NDVI) / sqrt(length(NDVI))
    )
  
  # Ensure the 'month' column is treated as a factor with levels in the correct order
  ndvi_summary$month <- factor(ndvi_summary$month, levels = sprintf("%02d", 1:12))
  
  p2 <- ggplot(ndvi_summary, aes(x = month, y = mean_val, group = 1)) +
    geom_point(size = 4) +
    geom_line() +
    geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci), alpha = 0.2, fill = "blue") +
    theme_minimal(base_size = 15) +
    theme(
      plot.background = element_rect(fill = "white"),
      panel.background = element_rect(fill = "white"),
      axis.title = element_text(size = 18),
      axis.text = element_text(size = 14),
      plot.title = element_text(size = 20, face = "bold"),
      legend.position = "none"
    ) +
    labs(
      title = paste0(country_name, " Mean NDVI per Month (", years_range, ")"),
      x = "Month", 
      y = "Mean NDVI"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ylim(ndvi_min, ndvi_max)
  
  return(list(p1 = p1, p2 = p2))
}

# Function to combine historic and current NDVI data
combine_ndvi_data <- function(historic_data, current_data, historic_dates, current_dates) {
  # Convert historic data to long format
  historic_df <- as.data.frame(x = historic_data, row.names = NULL, xy = FALSE)
  colnames(historic_df) <- c(historic_dates)
  historic_longdf <- historic_df %>%
    pivot_longer(cols = everything(), names_to = "YearMonth", values_to = "NDVI") %>%
    na.omit()
  historic_longdf$dates <- as.Date(paste0(historic_longdf$YearMonth, "-01"))
  historic_longdf <- transform(historic_longdf, month = format(dates, "%m"), year = format(dates, "%Y"))
  historic_longdf$DataType <- paste("Historic (", paste(min(historic_longdf$year), max(historic_longdf$year), sep = "-"), ")", sep = "")
  
  # Convert current data to long format
  current_df <- as.data.frame(x = current_data, row.names = NULL, xy = FALSE)
  colnames(current_df) <- c(current_dates)
  current_longdf <- current_df %>%
    pivot_longer(cols = everything(), names_to = "YearMonth", values_to = "NDVI") %>%
    na.omit()
  current_longdf$dates <- as.Date(paste0(current_longdf$YearMonth, "-01"))
  current_longdf <- transform(current_longdf, month = format(dates, "%m"), year = format(dates, "%Y"))
  current_longdf$DataType <- paste("Current (", paste(min(current_longdf$year), max(current_longdf$year), sep = "-"), ")", sep = "")
  
  # Combine historic and current data
  combined_longdf <- rbind(historic_longdf, current_longdf)
  
  return(combined_longdf)
}

# Function to plot combined NDVI data
plot_combined_ndvi <- function(combined_data, country_name) {
  # Extract unique years for the title
  years_included <- unique(combined_data$year)
  years_range <- paste(min(years_included), max(years_included), sep = "-")
  
  # Calculate dynamic ylim values based on NDVI data
  ndvi_min <- min(combined_data$NDVI, na.rm = TRUE)
  ndvi_max <- max(combined_data$NDVI, na.rm = TRUE)
  
  # Create the boxplot
  p1 <- ggplot(combined_data, aes(x = month, y = NDVI, fill = DataType)) +
    geom_boxplot(na.rm = TRUE) +
    theme_minimal(base_size = 15) +
    theme(
      plot.background = element_rect(fill = "white"),
      panel.background = element_rect(fill = "white"),
      axis.title = element_text(size = 18),
      axis.text = element_text(size = 14),
      plot.title = element_text(size = 20, face = "bold"),
      legend.position = "bottom"
    ) +
    labs(title = paste0(country_name, " NDVI per Month (", years_range, ")"), x = "Month", y = "NDVI") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ylim(ndvi_min, ndvi_max) +
    scale_fill_manual(values = c("blue", "red"))
  
  # Create the summary plot
  ndvi_summary <- combined_data %>%
    group_by(month, DataType) %>%
    summarize(
      mean_val = mean(NDVI),
      lower_ci = mean(NDVI) - 1.96 * sd(NDVI) / sqrt(length(NDVI)),
      upper_ci = mean(NDVI) + 1.96 * sd(NDVI) / sqrt(length(NDVI))
    )
  
  # Ensure the 'month' column is treated as a factor with levels in the correct order
  ndvi_summary$month <- factor(ndvi_summary$month, levels = sprintf("%02d", 1:12))
  
  p2 <- ggplot(ndvi_summary, aes(x = month, y = mean_val, group = DataType, color = DataType)) +
    geom_point(size = 4) +
    geom_line() +
    geom_ribbon(aes(ymin = lower_ci, ymax = upper_ci, fill = DataType), alpha = 0.2) +
    theme_minimal(base_size = 15) +
    theme(
      plot.background = element_rect(fill = "white"),
      panel.background = element_rect(fill = "white"),
      axis.title = element_text(size = 18),
      axis.text = element_text(size = 14),
      plot.title = element_text(size = 20, face = "bold"),
      legend.position = "bottom"
    ) +
    labs(
      title = paste0(country_name, " Mean NDVI per Month (", years_range, ")"),
      x = "Month", 
      y = "Mean NDVI"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ylim(ndvi_min, ndvi_max) +
    scale_color_manual(values = c("blue", "red")) +
    scale_fill_manual(values = c("blue", "red"))
  
  return(list(p1 = p1, p2 = p2))
}

# Function to plot AOI on a basemap
plot_aoi_on_basemap <- function(aoi, country_name) {
  
  # Create the AOI plot
  aoi_plot <- ggplot() +
    geom_sf(data = aoi, fill = 'blue', color = 'black', alpha = 0.5) +
    theme_minimal(base_size = 15) +
    labs(title = paste0(country_name, " Area of Interest (AOI)"), x = "Longitude", y = "Latitude") +
    theme(
      plot.background = element_rect(fill = "white"),
      panel.background = element_rect(fill = "white"),
      axis.title = element_text(size = 18),
      axis.text = element_text(size = 14),
      plot.title = element_text(size = 20, face = "bold")
    )
  
  return(aoi_plot)
}

# Function to arrange and display combined mean analysis and AOI basemap plot
plot_combined_analysis_and_aoi <- function(combined_analysis_plots, aoi_plot) {
  grid.arrange(combined_analysis_plots$p2, aoi_plot, ncol = 2)
}