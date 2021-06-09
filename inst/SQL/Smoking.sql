SELECT @covariateId AS covariate_id,
       {@aggregated} ? {
       cohort_definition_id,
        COUNT(DISTINCT target.@rowIdField) AS sum_value
       } : {
         target.@rowIdField  AS row_id,
         1 AS covariate_value
       }
FROM @cohortTable target
LEFT JOIN @cdmDatabaseSchema.observation covariate1
ON covariate1.person_id = target.@rowIdField 
LEFT JOIN @cdmDatabaseSchema.condition_occurrence covariate2
ON covariate2.person_id = target.@rowIdField
WHERE ((((covariate1.observation_concept_id = 40766362 AND covariate1.value_as_concept_id IN (4034855, 4132507)) -- smoking status + current/past
    OR covariate1.observation_concept_id IN (762498,762499,762500,762501,764103,764104,3193708,4005823,4041511,4042037,4043053,4043056,4044775,4044776,4044777,4044778,4052029,4052030,4052465,4052947,4052949,4058136,4058138,4092281,4141782,4141783,4141784,4141787,4144273,4145798,4148415,4148416,4204653,4207221,4209006,4209585,4218917,4232375,4237385,4246415,4276526,4298794,4310250,35610339,35610340,35610343,35610345,35610347,35610349,37017610,37395605,40766945,42536346,44802113,46270534)) -- current smoker (40766945) / ex-smoker (4310250) / tobacco user (4005823) / excluding chews tobacco + all descendants
    AND covariate1.observation_date <= target.cohort_start_date)
    OR (covariate2.condition_concept_id IN (437264,764469,765451,4099811,4103417,4103418,37109023) -- tobacco dependence syndrome (437264) / excluding chews tobacco + all descendants
    AND covariate2.condition_start_date <= target.cohort_start_date))
    {@cohortId != -1} ? {AND cohort_definition_id IN (@cohortId)}
{@aggregated} ? {GROUP BY cohort_definition_id}
