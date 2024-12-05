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
