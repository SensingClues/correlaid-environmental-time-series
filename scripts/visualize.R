# Data Visualization Functions
#
#
# This file contains functions to build useful plots

# Function to plot NDVI distribution
plot_ndvi_timeseries <- function(train_data = NULL, test_data = NULL,
                                 country_name = NULL, resolution = NULL,
                                 plot_width = 15, plot_height = 8,
                                 ylim_range = c(0.15, 0.75),
                                 label_test = "NDVI 2024",
                                 label_train = "NDVI 2019-2023",
                                 save_path = NULL, filename = "NDVI_timeseries.png") {
  # Set plot size
  options(repr.plot.width = plot_width, repr.plot.height = plot_height)

  # Create the plot
  ts_plot <- ggplot(NULL, aes(x = Month, y = mean_val, group = 1)) +
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
    geom_text(x = 10, y = ylim_range[2] - 0.05, label = label_test, size = 8,
              color = "#9662b3", hjust = 0) + # add text to label plot
    geom_text(x = 10, y = ylim_range[2] - 0.1, label = label_train, size = 8,
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