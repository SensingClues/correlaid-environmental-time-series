# Data Visualization Functions
#
#
# This file contains functions to build useful plots

# Function to plot NDVI distribution
plot_ndvi_timeseries <- function(train_data = NULL, test_data = NULL,
                                 country_name = NULL, resolution = NULL,
                                 plot_width = 15, plot_height = 8,
                                 ylim_range = c(0.15, 0.75),
                                 test_start_date = NULL, test_end_date = NULL,
                                 label_test = "NDVI 2024",
                                 label_train = "NDVI 2019-2023",
                                 save_path = NULL,
                                 filename = "NDVI_timeseries.png") {

  # Add Month Name to dataframes
  test_data$Month_Name <- month.name[as.numeric(test_data$Month)]
  train_data$Month_Name <- month.name[as.numeric(train_data$Month)]

  # Make month name vector, to customize order of x axis 
  month_vector <- format(seq(test_start_date, test_end_date, by="month"), "%B")

  # Set plot size
  options(repr.plot.width = plot_width, repr.plot.height = plot_height)

  # Create the plot
  ts_plot <- ggplot(NULL, aes(x = factor(Month_Name, level=month_vector),
                              y = mean_val, group = 1)) +
    geom_point(data = train_data, size = 5,
               fill = "#2781cf") + # point-average train data
    geom_line(data = train_data) +
    geom_ribbon(data = train_data, aes(ymin = lower_ci, ymax = upper_ci),
                alpha = 0.2, fill = "#2781cf") + # Shaded CI ribbon
    geom_point(data = test_data, size = 5, shape = 23,
               fill = "#9662b3") + # point-average test data
    theme_minimal() +
    labs(
      title = paste0(country_name, " NDVI (", resolution, "m res)"),
      x = "Month",
      y = "Mean NDVI"
    ) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 15),
      axis.text.y = element_text(size = 15), 
      axis.title.x = element_text(size = 20, margin = margin(15, 0, 0, 0)),
      axis.title.y = element_text(size = 20, margin = margin(0, 15, 0, 0)),
      plot.title = element_text(size = 20, hjust = 0.5)
    ) +
    ylim(ylim_range) +
    geom_text(x = 10, y = ylim_range[2] - 0.05, label = label_test, size = 6,
              color = "#9662b3", hjust = 0) + # add text to label plot
    geom_text(x = 10, y = ylim_range[2] - 0.1, label = label_train, size = 6,
              color = "#2781cf", hjust = 0) # add text to label plot

  # Save plot if save_path is provided
  if (!is.null(save_path)) {
    # Ensure the save directory exists
    if (!dir.exists(save_path)) {
      dir.create(save_path, recursive = TRUE)
    }

    # Save the plot to the specified location
    ggsave(filename = file.path(save_path, filename),plot = ts_plot,
           width = plot_width, height = plot_height, units = "in")
  }

  # Return the plot
  return(ts_plot)
}

# Function to plot 2D maps for a specific month over several years
plot_ndvi_maps <- function(data = NULL, month_to_plot = "01",
                           plot_width = 15, plot_height = 8,
                           zlim_range = c(-0.7, 0.7), ncol = 6,
                           save_path = NULL, filename = "NDVI_maps.png") {
  # Set plot size
  options(repr.plot.width = plot_width, repr.plot.height = plot_height)

  # Define a color map from brown to green
  brgr_colors <- colorRampPalette(c("chocolate4", "darkgoldenrod1",
                                    "darkgray", "yellowgreen", "forestgreen"))

  # Filter the data for the specified month
  data_filtered <- data[data$Month == month_to_plot, ]

  # Generate the plot
  map_plot <- ggplot(data_filtered, aes(x = x, y = y, fill = NDVI)) +
    geom_raster() +
    scale_fill_gradientn(colors = brgr_colors(10), limits = zlim_range,
                         oob = scales::squish) +
    facet_wrap(~ YearMonth, ncol = ncol) +
    labs(
      title = paste0("NDVI Over Years - ",
                     month.name[as.numeric(month_to_plot)]),
      fill = "NDVI",
      x = "Longitude",
      y = "Latitude"
    ) +
    theme_minimal() +
    theme(
      aspect.ratio = 2.5, # Keep a consistent aspect ratio
      panel.spacing = unit(1, "lines"), # Space between panels
      strip.text = element_text(size = 12), # Adjust facet labels
      axis.text.x = element_text(hjust = 1, size = 15), 
      axis.text.y = element_text(size = 15), 
      axis.title.x = element_text(size = 20, margin = margin(15, 0, 0, 0)),
      axis.title.y = element_text(size = 20, margin = margin(0, 15, 0, 0)),
      plot.title = element_text(size = 20, hjust = 0.5)
    )

  # Save the plot if save_path is provided
  if (!is.null(save_path)) {
    # Ensure the save directory exists
    if (!dir.exists(save_path)) {
      dir.create(save_path, recursive = TRUE)
    }

    # Save the plot to the specified location
    ggsave(filename = file.path(save_path, filename),
           plot = map_plot, width = plot_width,
           height = plot_height, units = "in")
  }

  # Return the plot
  return(map_plot)
}

# Function to plot delta NDVI in a 2D map
plot_delta_ndvi_map <- function(data = NULL, month_to_plot = "01",
                                plot_width = 15, plot_height = 8,
                                zlim_range = c(-.25, .25),
                                save_path = NULL,
                                filename = "deltaNDVI_maps.png") {
  # Set plot size
  options(repr.plot.width = plot_width, repr.plot.height = plot_height)

  # Define a color map from brown to green
  brgr_colors <- colorRampPalette(c("darkred", "firebrick1",
                                    "darkgray", "yellowgreen", "darkgreen"))

  # Filter the data for the specified month
  data_filtered <- data[data$Month == month_to_plot, ]

  # Generate the plot
  map_plot <- ggplot(data_filtered, aes(x = x, y = y, fill = delta_ndvi)) +
    geom_raster() +
    scale_fill_gradientn(colors = brgr_colors(10), limits = zlim_range,
                         oob = scales::squish) +
    labs(
      title = paste0("Delta NDVI - ",
                     month.name[as.numeric(month_to_plot)]),
      fill = "Delta NDVI",
      x = "Longitude",
      y = "Latitude"
    ) +
    theme_minimal() +
    theme(
      aspect.ratio = 2.5, # Keep a consistent aspect ratio
      panel.spacing = unit(1, "lines"), # Space between panels
      strip.text = element_text(size = 12), # Adjust facet labels
      axis.text.x = element_text(hjust = 1, size = 15), 
      axis.text.y = element_text(size = 15), 
      axis.title.x = element_text(size = 20, margin = margin(15, 0, 0, 0)),
      axis.title.y = element_text(size = 20, margin = margin(0, 15, 0, 0)),
      plot.title = element_text(size = 20, hjust = 0.5)
    )

  # Save the plot if save_path is provided
  if (!is.null(save_path)) {
    # Ensure the save directory exists
    if (!dir.exists(save_path)) {
      dir.create(save_path, recursive = TRUE)
    }

    # Save the plot to the specified location
    ggsave(filename = file.path(save_path, filename),
           plot = map_plot, width = plot_width,
           height = plot_height, units = "in")
  }

  # Return the plot
  return(map_plot)
}
