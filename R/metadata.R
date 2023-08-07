#'
#' Sets the data type of a single column
#'
#' @param column the column to convert
#' @param metadata the metadata as produced by [du.retrieve.full.dict]
#' @param column_name the name of the column to convert
#'
#' @importFrom stats setNames
#' @importFrom dplyr filter
#'
#' @noRd
du.set.datatype <- function(column, metadata, column_name) {
  name <- NULL
  colmeta <- dplyr::filter(metadata, name == column_name)
  if (nrow(colmeta) == 0) {
    # TODO: what to do when no metadata is found?
    return(column)
  }
  cats <- colmeta$cats[[1]]
  if (nrow(cats) > 0) {
    # TODO: what to do with cats$missing?
    column <- factor(column, levels = cats$value)
    attr(column, "labels") <-
      stats::setNames(as.character(cats$value), cats$label)
  }
  else if (colmeta$valueType == "decimal") {
    column <- as.numeric(column)
  }
  else if (colmeta$valueType == "integer") {
    column <- as.integer(column)
  }
  else if (colmeta$valueType == "text") {
    column <- as.character(column)
  }
  else if (colmeta$valueType == "boolean") {
    column <- as.logical(column)
  }
  attr(column, "label") <- colmeta$label
  return(column)
}

#' Adds metadata to data frame, converting the column types
#'
#' @param x the data frame to add metadata to
#' @param metadata the metadata to add to the data frame
#'
#' @importFrom dplyr mutate across cur_column
#'
#' @noRd
du.add.metadata <- function(x, metadata) {
  dplyr::mutate(x, dplyr::across(
    names(x),
    ~ du.set.datatype(
      .x,
      metadata,
      dplyr::cur_column()
    )
  ))
}
