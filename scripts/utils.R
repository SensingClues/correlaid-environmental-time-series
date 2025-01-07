#' General Purpose Utility Functions
#'
#' This file contains utility functions for common tasks such as listing files in a directory.
#' Each function is documented with a clear description, arguments, return values, and examples.

#' List Files in a Folder
#'
#' This function retrieves a list of all files in a specified folder. It includes the option
#' to return either the complete file paths or just the file names.
#'
#' @param folder_path A string specifying the folder path to list files from.
#' @param include_full_path Logical. If `TRUE`, returns complete file paths. Defaults to `TRUE`.
#' @return A character vector containing the file names or full file paths, depending on the 
#' value of `include_full_path`.
#' @details The function validates the existence of the folder before attempting to list files. 
#' It uses the base R `list.files()` function for retrieval.
#' @examples
#' # Example 1: List all files with full paths
#' list_files_in_folder("path/to/your/folder", TRUE)
#'
#' # Example 2: List all files with only file names
#' list_files_in_folder("path/to/your/folder", FALSE)
#'
#' # Example 3: Print the results
#' files <- list_files_in_folder("path/to/your/folder", TRUE)
#' print(files)
#' @export
list_files_in_folder <- function(folder_path, include_full_path = TRUE) {
  # Validate that the folder exists
  if (!dir.exists(folder_path)) {
    stop("The specified folder does not exist. Please check the folder path.")
  }
  
  # Retrieve the list of files
  files <- list.files(
    path = folder_path,       # Path to the folder
    full.names = include_full_path # Option to include full file paths
  )
  
  return(files)
}

## get list of NDVI or AoI filenames for specific country
get_filenames <- function(filepath = NULL, data_type = "NDVI",
                          file_extension = ".tif", country_name = NULL) {

  if (data_type == "NDVI") {
    out_files <- get_ndvi_filenames(data_path = filepath,
                                    file_extension = file_extension)
  }

  if (data_type == "AoI") {
    out_files <- get_aoi_filenames(aoi_path = filepath,
                                   file_extension = file_extension,
                                   country_name = country_name)
  }

  cat("\nLoading", data_type, "data for", country_name, "\n", sep = " ")
  return(out_files)
}

## get list of NDVI filenames in folder
get_ndvi_filenames <- function(data_path = NULL, file_extension = ".tif") {

  ndvi_files <- list.files(data_path,
    pattern = paste0("NDVI", ".*", file_extension, "$")
  )

  return(ndvi_files)
}

## get list of aoi filenames in folder
get_aoi_filenames <- function(aoi_path = NULL, file_extension = ".geojson",
                              country_name = NULL) {

  aoi_files <- list.files(aoi_path,
    pattern = paste0("AoI", ".*", country_name, ".*", file_extension, "$")
  )

  return(aoi_files)
}

## given a list of filenames, extract date as YYYY-MM 
## and return list of date strings
extract_dates <- function(file_list = NULL) {

  dates <- gsub("(\\d{4}-\\d{2})_.*", "\\1", file_list)

  cat("\nFound data for", length(dates),
      "months, from", min(dates), "to", max(dates), "\n", sep = " ")

  return(dates)
}

## order file list by date
order_by_date <- function(file_list = NULL, dates = NULL, decreasing = FALSE) {

  file_list <- file_list[order(as.Date(paste0(dates, "-01")),
                               decreasing = decreasing)]

  return(file_list)
}
