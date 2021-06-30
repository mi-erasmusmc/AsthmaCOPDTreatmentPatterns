# ------------------------------------------------------------------------
# Study settings
# ------------------------------------------------------------------------

## Analysis settings
debugSqlFile <- "treatment_patterns.dsql"
cohortTable <- "treatment_patterns_cohorts"

runCreateCohorts <- TRUE
runCohortCharacterization <- TRUE # functionality only available for OMOP_CDM
runConstructPathways <- TRUE
runGenerateResults <- TRUE

## Load settings
study_settings <- data.frame(readr::read_csv("inst/Settings/study_settings.csv", col_types = readr::cols()))
study_settings <- study_settings[,c("param", "analysis1", "analysis2", "analysis3", "analysis4", "analysis5", "analysis6", "analysis7", "analysis8", "analysis9", "analysis10", "analysis11", "analysis12", "analysis13", "analysis14")]

# ------------------------------------------------------------------------
# Enter all database credentials, ELSE enter database name
# ------------------------------------------------------------------------

user <- 'todo'
password <- 'todo'
cdmDatabaseSchemaList <- 'todo'
cohortSchema <- 'todo'
oracleTempSchema <- NULL
databaseList <- 'todo' # name of the data source

dbms <- 'todo'
server <- 'todo'
port <- 'todo'

# Sys.setenv(DATABASECONNECTOR_JAR_FOLDER = 'todo')

outputFolder <- paste0(getwd(),"/shiny/output")
cohortLocation <- NULL

# Optional: specify where the temporary files will be created:
# options(andromedatempdir = "...")

# Connect to the server
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                port = port)

connection <- DatabaseConnector::connect(dbms = dbms,connectionDetails = connectionDetails)


# ------------------------------------------------------------------------
# Run the study
# ------------------------------------------------------------------------

for (sourceId in 1:length(cdmDatabaseSchemaList)) {
  
  cdmDatabaseSchema <- cdmDatabaseSchemaList[sourceId]
  cohortDatabaseSchema <- cohortSchema
  databaseName <- databaseList[sourceId]

  print(paste("Executing against", databaseName))
  
  outputFolderDB <- paste0(outputFolder, "/", databaseName)
  
  time0 <- Sys.time()
  executeTreatmentPatterns(
    connection = connection,
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = paste0(cohortTable, "_", databaseName),
    outputFolder = outputFolderDB,
    databaseName = databaseName,
    runCreateCohorts = runCreateCohorts,
    runCohortCharacterization = runCohortCharacterization,
    runConstructPathways = runConstructPathways,
    runGenerateResults = runGenerateResults,
    study_settings = study_settings
  )
  time5 <- Sys.time()
  ParallelLogger::logInfo(paste0("Time needed to execute study for this database ", difftime(time5, time0, units = "mins")))
}


