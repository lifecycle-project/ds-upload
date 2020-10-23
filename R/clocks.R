#' Generate clocks for uploading to Opal
#'
#' @param methylation_data_input_path path to the methylation data
#' @param header_data_input_path path to the data that binds it to child_id's
#' 
#' @importFrom methylclock DNAmAge
#' @importFrom readr read_csv
#' 
#' @examples
#'  \dontrun{
#' du.clocks(
#'   methylation_data_input_path = ~/path-to-file/methylation_data_for_all_children.csv,
#'   header_data_input_path = "~/path-to-file/children_header_data"
#' )
#' }
#' 
#' @export
du.clocks <- function(methylation_data_input_path, header_data_input_path) {
  methylationData <- read_csv(methylation_data_input_path)
  
  output <- DNAmAge(methylationData)
  
  output$child_id <- seq.int(nrow(output))
  
  return(output)
} 