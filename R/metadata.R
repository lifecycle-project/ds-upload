#' 
#' Sets the data type of a single column
#' 
#' @param column the column to convert
#' @param valueType the value type to convert to, can be decimal, integer, text
#' @param label the column label to add as attribute
#' @param cats category data frame with columns
#' 
#' @importFrom stats setNames
#' 
#' @noRd
du.set.datatype <- function(column, valueType, label, cats) {
  if (nrow(cats) > 0) {
    # TODO: what to do with cats$missing?
    column <- factor(column, levels = cats$value)
    attr(column, "labels") <- stats::setNames(as.character(cats$value), cats$label)
  }
  else if (valueType == "decimal") {
    column <- as.numeric(column)
  }
  else if (valueType == "integer") {
    column <- as.integer(column)
  }
  else if (valueType == "text") {
    column <- as.character(column)
  }
  attr(column, "label") <- label
  return(column)
}

#' Adds metadata to data frame, converting the column types
#'
#' @param x the data frame to add metadata to
#' @param metadata the metadata to add to the data frame
#' 
#' @importFrom dplyr mutate_at
#'
#' @noRd
du.add.metadata <- function(x, metadata) {
  # TODO: how to do this columnwise across the whole table?
  for (i in 1:nrow(metadata)) {
    try(
      x <- dplyr::mutate_at(
        x, c(metadata$name[[i]]),
        ~ du.set.datatype(
          .,
          metadata$valueType[[i]],
          metadata$label[[i]],
          metadata$cats[[i]]
        )
      ),
      silent = TRUE
    )
  }
  x
}
