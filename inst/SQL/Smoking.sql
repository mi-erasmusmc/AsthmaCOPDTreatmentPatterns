SELECT @covariateId AS covariate_id,
       {@aggregated} ? {
       cohort_definition_id,
        COUNT(DISTINCT person_id) AS sum_value
       } : {
         target.@rowIdField  AS row_id,
         1 AS covariate_value
       }
FROM @cohortTable target
INNER JOIN @cdmDatabaseSchema.observation covariate
ON covariate.person_id = target.subject_id
WHERE covariate.observation_concept_id = 40766362 AND value_as_concept_id IN (4034855, 4132507)
    AND covariate.observation_date <= target.cohort_start_date
    {@cohortId != -1} ? {AND cohort_definition_id IN (@cohortId)}
{@aggregated} ? {GROUP BY cohort_definition_id}