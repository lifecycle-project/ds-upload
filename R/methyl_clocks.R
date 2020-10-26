#' Generate clocks for uploading to Opal
#'
#' @param methyl_data_input_path path to the methylation data
#' @param child_metadata_input_path path to the data that binds it to child_id's
#' @param age_when_measured age of the child when the measurement took place
#' 
#' @importFrom readr read_csv write_csv
#' 
#' @examples
#'  \dontrun{
#' du.methyl.clocks(
#'   methyl_data_input_path = ~/path-to-file/methylation_data_for_all_children.csv,
#'   child_meta_data_input_path = "~/path-to-file/children_header_data.csv",
#'   age_when_measured = 44
#' )
#' }
#' 
#' @export
du.methyl.clocks <- function(methyl_data_input_path, child_metadata_input_path, age_when_measured) {
  requireNamespace("methylclock")
  
  methyl_data <- read_csv(methyl_data_input_path)
  child_metadata <- read_csv(child_metadata_input_path)
  
  output <- methylclock::DNAmAge(methylationData)
  
  output$id <- NULL
  
  output <- cbind(row_id = seq.int(nrow(output)), output)
  output <- cbind(age_years = age_when_measured, output)
  output <- cbind(child_id = child_metadata, output)
  
  ##du.reshape.methyl.clocks(TRUE, "1_0", dict_name, data, TRUE)
  
  write_csv(output, paste0(getwd(), "/", "methylation_data", ".csv"), na = "")
  
  return(output)
} 