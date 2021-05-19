SELECT @covariateId AS covariate_id,
       {@aggregated} ? {
       cohort_definition_id,
        COUNT(DISTINCT person_id) AS sum_value
       } : {
         target.@rowIdField  AS row_id,
         1 AS covariate_value
       }
FROM @cohortTable target
INNER JOIN @cdmDatabaseSchema.condition_occurrence covariate
ON covariate.person_id = target.subject_id
WHERE covariate.condition_concept_id IN (132932,134661,134668,139841,257012,259848,761761,761762,765276,4048184,4048185,4051475,4051486,4051487,4051488,4110027,4110489,4110490,4112365,4112367,4112497,4112498,4112529,4145495,4173466,4179673,4181738,4230641,4247588,4288156,4316066,4316067,4322228)
    AND covariate.condition_start_date <= target.cohort_start_date
    {@cohortId != -1} ? {AND cohort_definition_id IN (@cohortId)}
{@aggregated} ? {GROUP BY cohort_definition_id}