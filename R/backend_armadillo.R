#' Login to the Armadillo backend
#'
#' @param login_data contains the server credentials to authenticate in Armadillo
#'
#'
#' @return jwt token to login to Armadillo
#'
#' @noRd
du.armadillo.login <- function(login_data) {
  requireNamespace("MolgenisArmadillo")
  token <- MolgenisArmadillo::armadillo.login(login_data$server)
  return(token)
}

#' Create projects in Armadillo
#'
#' @param project the target project where the data should be put into
#'
#' @importFrom MolgenisArmadillo armadillo.create_project armadillo.list_projects
#'
#' @noRd
du.armadillo.create.project <- function(project) {
  requireNamespace("MolgenisArmadillo")
  projects <- armadillo.list_projects()

  if (project %in% projects) {
    message(paste0("* Project : ", project, " already exists"))
  } else {
    armadillo.create_project(project)
  }
}

#' Import data into Armadillo
#'
#' @param data data to upload
#' @param dict_version data model version
#' @param dict_kind data model version
#' @param data_version data model version
#' @param table_type data model version
#'
#' @importFrom MolgenisArmadillo armadillo.upload_table
#' @importFrom stringr str_split str_replace_all
#' @importFrom utils tail
#'
#' @noRd
du.armadillo.import <- function(project, data, dict_version, dict_kind, data_version, table_type) {
  requireNamespace("MolgenisArmadillo")
  
  if (!is.null(data)) {
    project_elements <- str_split(project, "_")

    if('-' %in% project_elements) {
      armadillo_project <- str_replace_all(sapply(project_elements, "[[", 2), "-", "")
    } else {
      armadillo_project <- project
    }
    
    armadillo_folder <- paste0(dict_version, "_", dict_kind, "_", data_version)

    message(paste0("* Start importing: ", armadillo_folder, " into project: ", armadillo_project))
    armadillo.upload_table(project = armadillo_project, folder = armadillo_folder, table = data, name = table_type)
    message(paste0("* Import finished successfully"))
  }
  else {
    message(paste0("  No data available for: ", table_type))
  }
}
