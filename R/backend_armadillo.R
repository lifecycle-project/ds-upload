#' Login to the Armadillo backend
#'
#' @param login_data contains the server credentials to authenticate in Armadillo
#'
#' @importFrom MolgenisArmadillo armadillo.get_token armadillo.assume_role_with_web_identity
#'
#' @return jwt token to login to Armadillo
#'
#' @noRd
du.armadillo.login <- function(login_data) {
  requireNamespace("MolgenisArmadillo")
  token <- armadillo.get_token(server = as.character(login_data$server))
  armadillo.assume_role_with_web_identity(
    token = token,
    server = as.character(login_data$storage)
  )
  return(token)
}

#' List projects
#'
#' @importFrom MolgenisArmadillo armadillo.list_projects armadillo.assume_role_with_web_identity
#'
#' @noRd
du.armadillo.list.projects <- function() {
  requireNamespace("MolgenisArmadillo")
  armadillo.assume_role_with_web_identity(
    token = as.character(ds_upload.globals$login_data$token),
    server = as.character(ds_upload.globals$login_data$storage)
  )
  projects <- armadillo.list_projects()
  return(projects)
}

#' List tables
#'
#' @param project project to limit the scope
#'
#' @importFrom MolgenisArmadillo armadillo.list_tables armadillo.assume_role_with_web_identity
#'
#' @noRd
du.armadillo.list.tables <- function(project) {
  requireNamespace("MolgenisArmadillo")
  armadillo.assume_role_with_web_identity(
    token = as.character(ds_upload.globals$login_data$token),
    server = as.character(ds_upload.globals$login_data$storage)
  )
  tables <- armadillo.list_tables(project)
  return(tables)
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

    armadillo_project <- str_replace_all(sapply(project_elements, "[[", 2), "-", "")

    if (dict_kind == du.enum.dict.kind()$BETA) {
      armadillo_project <- str_replace_all(sapply(project_elements, tail, 1), "-", "")
      armadillo_folder <- du.enum.dict.kind()$BETA
    } else {
      armadillo_folder <- paste0(dict_version, "_", dict_kind, "_", data_version)
    }

    message(paste0("* Start importing: ", armadillo_folder, " into project: ", armadillo_project))
    armadillo.upload_table(project = armadillo_project, folder = armadillo_folder, table = data, name = table_type)
    message(paste0("* Import finished successfully"))
  }
  else {
    message(paste0("  No data available for: ", table_type))
  }
}
