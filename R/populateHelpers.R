#' Create the project with data dictionary version in between
#'
#' @param project prpject resource in Opal
#' @param database_name the database name of the Opal instance (default = opal_data)
#'
#' @importFrom dplyr between
#' @importFrom opalr opal.post
#'
lc.dict.project.create <- local(function(project, database_name) {
  canonical_project_name <- strsplit(project, "_")
  dict_kind <- canonical_project_name[[1]][3]
  dict_version <-
    paste(canonical_project_name[[1]][4],
          "_",
          canonical_project_name[[1]][5],
          sep = "")
  message('------------------------------------------------------')
  message(paste('  Start creating project: [ ', project, ' ]', sep = ''))
  projects <- opal.projects(lifecycle.globals$opal)
  if (!(project %in% projects$name)) {
    json <-
      sprintf(
        '{"database":"%s","description":"%s","name":"%s","title":"%s"}',
        database_name,
        paste(
          'Project for [ ',
          dict_kind ,
          ' ] variables and data dictionary version: [ ',
          dict_version,
          ' ]',
          sep = ''
        ),
        project,
        project
      )
    opal.post(lifecycle.globals$opal,
              'projects',
              body = json,
              contentType = 'application/x-protobuf+json')
  } else {
    message(paste('* Project: [ ', project, ' ] already exists', sep = ''))
  }
})

#' Import the data dictionaries into Opal
#'
#' @param project project in which the data is imported
#' @param dict_version dictionary version (concerning core or outcome)
#' @param dict_kind dictionary kind (core or outcome)
#' @param data_version version of the data (specific to the cohort)
#'
#' @importFrom readxl read_xlsx
#'
lc.dict.import <-
  local(function(project,
                 dict_version,
                 dict_kind,
                 data_version) {
    message('------------------------------------------------------')
    message('  Start importing dictionaries')
    
    dict_source_table_non_rep <-
      paste(dict_version, '_', dict_kind, '_non_rep.xlsx', sep = '')
    dict_source_table_monthly_rep <-
      paste(dict_version, '_', dict_kind, '_monthly_rep.xlsx', sep = '')
    dict_source_table_yearly_rep <-
      paste(dict_version, '_', dict_kind, '_yearly_rep.xlsx', sep = '')
    
    dict_source_table_weekly_rep <-
      paste(dict_version, '_', dict_kind, '_weekly_rep.xlsx', sep = '')
    dict_source_table_trimester_rep <-
      paste(dict_version, '_', dict_kind, '_trimester_rep.xlsx', sep = '')
    
    dict_table_non_rep <-
      paste(dict_version,
            '_',
            dict_kind,
            '_',
            data_version,
            '_non_rep',
            sep = '')
    dict_table_monthly_rep <-
      paste(dict_version,
            '_',
            dict_kind,
            '_',
            data_version,
            '_monthly_rep',
            sep = '')
    dict_table_yearly_rep <-
      paste(dict_version,
            '_',
            dict_kind,
            '_',
            data_version,
            '_yearly_rep',
            sep = '')
    
    # for dict_kind == outcome
    dict_table_weekly_rep <-
      paste(dict_version,
            '_',
            dict_kind,
            '_',
            data_version,
            '_weekly_rep',
            sep = '')
    # for dict_kind == core
    dict_table_trimester_rep <-
      paste(dict_version,
            '_',
            dict_kind,
            '_',
            data_version,
            '_trimester_rep',
            sep = '')
    
    json_non_rep <-
      sprintf('{"entityType":"Participant","name":"%s"}',
              dict_table_non_rep)
    json_monthly_rep <-
      sprintf('{"entityType":"Participant","name":"%s"}',
              dict_table_monthly_rep)
    json_yearly_rep <-
      sprintf('{"entityType":"Participant","name":"%s"}',
              dict_table_yearly_rep)
    
    # for dict_kind == outcome
    json_weekly_rep <-
      sprintf('{"entityType":"Participant","name":"%s"}',
              dict_table_weekly_rep)
    # for dict_kind == core
    json_trimester_rep <-
      sprintf('{"entityType":"Participant","name":"%s"}',
              dict_table_trimester_rep)
    
    tables <- opal.tables(lifecycle.globals$opal, project)
    
    if (!(dict_table_non_rep %in% tables$name)) {
      message(paste('* Create table: [ ', dict_table_non_rep, ' ]', sep = ''))
      opal.post(
        lifecycle.globals$opal,
        'datasource',
        project,
        'tables',
        body = json_non_rep,
        contentType = 'application/x-protobuf+json'
      )
    } else {
      message(paste('* Table: [ ', dict_table_non_rep, ' ] already exists', sep = ''))
    }
    if (!(dict_table_monthly_rep %in% tables$name)) {
      message(paste('* Create table: [ ', dict_table_monthly_rep, ' ]', sep = ''))
      opal.post(
        lifecycle.globals$opal,
        'datasource',
        project,
        'tables',
        body = json_monthly_rep,
        contentType = 'application/x-protobuf+json'
      )
    } else {
      message(paste(
        '* Table: [ ',
        dict_table_monthly_rep,
        ' ] already exists',
        sep = ''
      ))
    }
    if (!(dict_table_yearly_rep %in% tables$name)) {
      message(paste('* Create table: [ ', dict_table_yearly_rep, ' ]', sep = ''))
      opal.post(
        lifecycle.globals$opal,
        'datasource',
        project,
        'tables',
        body = json_yearly_rep,
        contentType = 'application/x-protobuf+json'
      )
    } else {
      message(paste('* Table: [ ', dict_table_yearly_rep, ' ] already exists', sep = ''))
    }
    if (dict_kind == "outcome") {
      if (!(dict_table_weekly_rep %in% tables$name)) {
        message(paste('* Create table: [ ', dict_table_weekly_rep, ' ]', sep = ''))
        opal.post(
          lifecycle.globals$opal,
          'datasource',
          project,
          'tables',
          body = json_weekly_rep,
          contentType = 'application/x-protobuf+json'
        )
      } else {
        message(
          paste(
            '* No table: [ ',
            dict_table_weekly_rep,
            ' ] available for version: [ ',
            dict_version,
            ' ]',
            sep = ''
          )
        )
      }
    }
    
    if (!(dict_table_trimester_rep %in% tables$name) &&
        dict_kind == 'core' && dict_version != '1_0') {
      message(paste('* Create table: [ ', dict_table_trimester_rep, ' ]', sep = ''))
      opal.post(
        lifecycle.globals$opal,
        'datasource',
        project,
        'tables',
        body = json_trimester_rep,
        contentType = 'application/x-protobuf+json'
      )
    } else {
      if (dict_version != '1_0') {
        message(paste(
          '* Table: [ ',
          dict_table_trimester_rep,
          ' ] already exists',
          sep = ''
        ))
      } else {
        message(
          paste(
            '* No table: [ ',
            dict_table_trimester_rep,
            ' ] available for version: [ ',
            dict_version,
            ' ]',
            sep = ''
          )
        )
      }
    }
    
    variables_non_rep <-
      read_xlsx(
        path = paste(getwd(), '/', dict_source_table_non_rep, sep = ''),
        sheet = 1
      )
    variables_yearly_rep <-
      read_xlsx(
        path = paste(getwd(), '/', dict_source_table_yearly_rep, sep = ''),
        sheet = 1
      )
    variables_monthly_rep <-
      read_xlsx(
        path = paste(getwd(), '/', dict_source_table_monthly_rep, sep = ''),
        sheet = 1
      )
    
    categories_non_rep <-
      read_xlsx(
        path = paste(getwd(), '/', dict_source_table_non_rep, sep = ''),
        sheet = 2
      )
    categories_monthly_rep <-
      read_xlsx(
        path = paste(getwd(), '/', dict_source_table_monthly_rep, sep = ''),
        sheet = 2
      )
    categories_yearly_rep <-
      read_xlsx(
        path = paste(getwd(), '/', dict_source_table_yearly_rep, sep = ''),
        sheet = 2
      )
    
    lc.populate.match.categories(
      project,
      dict_table_non_rep,
      variables_non_rep,
      categories_non_rep,
      dict_source_table_non_rep
    )
    lc.populate.match.categories(
      project,
      dict_table_monthly_rep,
      variables_monthly_rep,
      categories_monthly_rep,
      dict_source_table_monthly_rep
    )
    lc.populate.match.categories(
      project,
      dict_table_yearly_rep,
      variables_yearly_rep,
      categories_yearly_rep,
      dict_source_table_yearly_rep
    )
    
    if (dict_kind == "outcome") {
      variables_weekly_rep <-
        read_xlsx(
          path = paste(getwd(), '/', dict_source_table_weekly_rep, sep = ''),
          sheet = 1
        )
      categories_weekly_rep <-
        read_xlsx(
          path = paste(getwd(), '/', dict_source_table_weekly_rep, sep = ''),
          sheet = 2
        )
      lc.populate.match.categories(
        project,
        dict_table_weekly_rep,
        variables_weekly_rep,
        categories_weekly_rep,
        dict_source_table_weekly_rep
      )
    }
    
    if (dict_kind == 'core' && dict_version != '1_0') {
      variables_trimester_rep <-
        read_xlsx(
          path = paste(getwd(), '/', dict_source_table_trimester_rep, sep = ''),
          sheet = 1
        )
      categories_trimester_rep <-
        read_xlsx(
          path = paste(getwd(), '/', dict_source_table_trimester_rep, sep = ''),
          sheet = 2
        )
      lc.populate.match.categories(
        project,
        dict_table_trimester_rep,
        variables_trimester_rep,
        categories_trimester_rep,
        dict_source_table_trimester_rep
      )
    }
    
    message('  All dictionaries are populated correctly')
  })

#' Match the categories with the variables to be import them
#' Import the variables
#'
#' @param project project resource in Opal
#' @param table dictionary to upload to Opal
#' @param variables dictionary variables to upload
#' @param categories dictionary categories to upload
#' @param source_file source file for the dictionaries
#'
#' @importFrom opalr opal.post
#' @importFrom dplyr select %>% nest_join rename
#'
lc.populate.match.categories <-
  local(function(project,
                 table,
                 variables,
                 categories,
                 source_file) {
    # workaround to avoid global variable warnings, check: https://stackoverflow.com/questions/9439256/how-can-i-handle-r-cmd-check-no-visible-binding-for-global-variable-notes-when
    label <- name <- NULL
    
    variables$entityType <- 'Participant'
    variables$isRepeatable <- FALSE
    variables$attributes <-
      data.frame(
        namespace = '',
        name = 'label',
        locale = '',
        value = variables$label
      )
    variables <- select(variables,-c(label))
    
    if (nrow(categories) > 0) {
      message(paste('* Matched categories for table: [ ', table, ' ]', sep = ''))
      categories <- transform(categories, name = as.character(name))
      categories$attributes <-
        data.frame(
          namespace = '',
          name = 'label',
          locale = '',
          value = categories$label
        )
      categories <- select(categories,-c(label))
      variables <-
        variables %>% nest_join(categories, by = c('name' = 'variable'))
    }
    
    message(paste('* Import variables into: [ ', table, ' ]', sep = ''))
    opal.post(
      lifecycle.globals$opal,
      'datasource',
      project,
      'table',
      table,
      'variables',
      body = toJSON(variables),
      contentType = 'application/x-protobuf+json'
    )
    message(paste('* Remove the table: [', source_file, ']', sep = ''))
  })
