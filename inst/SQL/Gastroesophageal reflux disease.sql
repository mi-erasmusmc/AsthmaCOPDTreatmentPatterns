SELECT @covariateId AS covariate_id,
       {@aggregated} ? {
       cohort_definition_id,
        COUNT(DISTINCT target.@rowIdField) AS sum_value
       } : {
         target.@rowIdField  AS row_id,
         1 AS covariate_value
       }
FROM @cohortTable target
INNER JOIN @cdmDatabaseSchema.condition_occurrence covariate
ON covariate.person_id = target.@rowIdField 
WHERE covariate.condition_concept_id IN (318800,765110,4046097,4076267,4144111,4159148,4159156,36687117,36712768,36712969,36713492,36713493,42535063)
    AND covariate.condition_start_date <= target.cohort_start_date
    {@cohortId != -1} ? {AND cohort_definition_id IN (@cohortId)}
{@aggregated} ? {GROUP BY cohort_definition_id}