
#' This is the main function which runs all different parts of the treatment pathways analysis.
#' 
#' @param connection           Connection to database server.
#' @param connectionDetails    An object of type \code{connectionDetails} as created using the
#'                             \code{\link[DatabaseConnector]{createConnectionDetails}} function in the
#'                             DatabaseConnector package.
#' @param cdmDatabaseSchema    Schema name where your patient-level data resides.
#'                             Note that for SQL Server, this should include both the database and
#'                             schema name, for example 'cdm_data.dbo'.
#' @param cohortDatabaseSchema Schema name where intermediate data can be stored. You will need to have
#'                             write priviliges in this schema. Note that for SQL Server, this should
#'                             include both the database and schema name, for example 'cdm_data.dbo'.
#' @param cohortTable          The name of the table that will be created in the work database schema.
#'                             This table will hold the target and event cohorts used in this
#'                             study.
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/).
#' @param databaseName         Name of the database that will appear in the results.
#' @param runCreateCohorts     Setting to run part of the analysis where cohorts are created.
#' @param runCohortCharacterization   Setting to run part of the analysis where characterization of target cohorts is done.      
#' @param runConstructPathways Setting to run part of the analysis where treatment pathways are constructed.
#' @param runGenerateResults        Setting to run part of the analysis where final result files and plots are generated.
#' @param study_settings       Object that contains all study settings inputted by the user.
#' @export

executeTreatmentPatterns <- function(connection = NULL,
                                     connectionDetails = NULL,
                                     cdmDatabaseSchema,
                                     cohortDatabaseSchema = cdmDatabaseSchema,
                                     cohortTable = "cohort",
                                     outputFolder,
                                     databaseName = "Unknown",
                                     runCreateCohorts = TRUE,
                                     runCohortCharacterization = FALSE,
                                     runConstructPathways = TRUE,
                                     runGenerateResults = TRUE,
                                     study_settings) {
  # Input checks
  if (!file.exists(outputFolder))
    dir.create(outputFolder, recursive = TRUE)
  
  connection <- DatabaseConnector::connect(connectionDetails)
  
  ParallelLogger::clearLoggers()
  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
  ParallelLogger::logInfo(print(paste0("Running package version ", packageVersion("AsthmaCOPDTreatmentPatterns"))))
  
  # Target/event cohorts of interest are extracted from the database (defined using ATLAS or custom concept sets created in SQL inserted into cohort template) 
  if (runCreateCohorts) {
    ParallelLogger::logInfo(print("runCreateCohorts"))
    
    # For all different target populations
    settings <- colnames(study_settings)[grepl("analysis", colnames(study_settings))]
    minCellCount <- max(as.integer(study_settings[study_settings$param == "minCellCount",settings])) # Minimum number of subjects in the target cohort for a given eent in order to be counted in the pathway
    
    createCohorts(connection = connection,
                  connectionDetails = connectionDetails,
                  cdmDatabaseSchema = cdmDatabaseSchema,
                  cohortDatabaseSchema = cohortDatabaseSchema,
                  cohortTable = cohortTable,
                  outputFolder = outputFolder,
                  loadCohorts = FALSE,
                  generateCohorts = TRUE,
                  detailedCount = TRUE,
                  minCellCount = minCellCount,
                  flowChart = TRUE)
  }
  
  # Characterization of study/target population
  if (runCohortCharacterization) {
    ParallelLogger::logInfo(print("runCohortCharacterization TRUE"))
    
    if (!file.exists(paste0(outputFolder, "/characterization")))
      dir.create(paste0(outputFolder, "/characterization"), recursive = TRUE)
    
    # For all different target populations
    settings <- colnames(study_settings)[grepl("analysis", colnames(study_settings))]
    targetCohortIds <- unique(as.numeric(study_settings[study_settings$param == "targetCohortId",settings]))
    minCellCount <- max(as.integer(study_settings[study_settings$param == "minCellCount",settings])) # Minimum number of subjects in the target cohort for a given eent in order to be counted in the pathway
    
    cohortCharacterization(connection = connection,
                           connectionDetails = connectionDetails,
                           cdmDatabaseSchema = cdmDatabaseSchema,
                           cohortDatabaseSchema = cohortDatabaseSchema,
                           cohortTable = cohortTable,
                           outputFolder = outputFolder,
                           databaseId = databaseName,
                           targetCohortIds = targetCohortIds,
                           minCellCount = minCellCount)
  }
  
  # Treatment pathways are constructed
  if (runConstructPathways) {
    ParallelLogger::logInfo(print("runConstructPathways TRUE"))
    
    # Get cohorts from database and save as csv
    sql <- loadRenderTranslateSql(sql = "SELECT * FROM @resultsSchema.@cohortTable",
                                  dbms = connectionDetails$dbms,
                                  resultsSchema=cohortDatabaseSchema,
                                  cohortTable=cohortTable)
    all_data <- as.data.table(DatabaseConnector::querySql(connection, sql))
    colnames(all_data) <- c("cohort_id", "person_id", "start_date", "end_date")   
    
    constructPathways(all_data = all_data,
                      study_settings = study_settings,
                      databaseName = databaseName,
                      studyName = studyName,
                      outputFolder = outputFolder)
  }
  
  DatabaseConnector::disconnect(connection)
  
  # Output is generated
  if (runGenerateResults) {
    ParallelLogger::logInfo(print("runGenerateResults TRUE"))
    
    generateResults(study_settings = study_settings,
                    databaseName = databaseName,
                    studyName = studyName,
                    outputFolder = outputFolder)
    
    # Zip output folder
    zipName <- file.path(getwd(), paste0(databaseName, ".zip"))
    OhdsiSharing::compressFolder(file.path(outputFolder), zipName)
    
  }
  
  invisible(NULL)
}