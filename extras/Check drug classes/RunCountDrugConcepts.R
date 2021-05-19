
# 1) Count all concepts 

# -- MANUAL IMPORT 'asthma_drugs.csv'
# -- MANUAL IMPORT 'medgroup_dosefrom.csv'
# -- UPDATE medgroup_doseform SET dose_form = NULL WHERE dose_form = ''; -- convert to NULL values

# sql <- loadRenderTranslateSql(sql = "CountDrugConcepts.sql",
#                              dbms = connectionDetails$dbms,
#                              oracleTempSchema = oracleTempSchema,
#                              cdmDatabaseSchema = cdmDatabaseSchemaList[1],
#                              resultsSchema=cohortSchema)
# DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)


# 2) Import predefined list in database
all_drug_concepts <- readr::read_csv("extras/all_drug_concepts.csv", stringsAsFactors = FALSE)

DatabaseConnector::insertTable(connection = connection,
                               tableName = paste0(cohortSchema,".all_drug_concepts"),
                                 data = all_drug_concepts,
                                 dropTableIfExists = TRUE,
                               createTable = TRUE,
                               tempTable = FALSE)

sql <- loadRenderTranslateSql(sql = "CountPredefinedDrugConcepts.sql",
                              dbms = connectionDetails$dbms,
                              oracleTempSchema = oracleTempSchema,
                              cdmDatabaseSchema = cdmDatabaseSchemaList[1],
                              resultsSchema=cohortSchema)
DatabaseConnector::executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)

# Return and save result
sql <- loadRenderTranslateSql(sql = "SELECT * FROM @resultsSchema.@tableName",
                              dbms = connectionDetails$dbms,
                              oracleTempSchema = oracleTempSchema,
                              resultsSchema=cohortSchema,
                              tableName="drug_concepts_present")
concepts_present <- DatabaseConnector::querySql(connection, sql)

write.csv(concepts_present, paste0("drug_concepts_present_db.csv"), row.names = FALSE)

