
### 1. use CreateCustomConceptSet.sql first to create drug_classes_sql.csv
custom_definitions <- readr::read_csv("extras/Definition drug classes/drug_classes_sql.csv", col_types = readr::cols())
custom_definitions <- custom_definitions[-grep("all", custom_definitions$cohortName),]

### 2. remove some concepts from concept sets
# load in concepts to remove (selected by manual inspection of all concepts with missing dose forms AND searching for terms such as "rectal" / "topical" / "otic" / "nasal" / "medicated pad" / "tape" in concept names AND incorrect dosage for ICS/Systemic glucocorticoids)
removed_concepts <- readr::read_csv("extras/Definition drug classes/removed_concepts.csv")

# load in concepts to remove from monotherapy group and add to combi group because search in concept names " / " indicated concepts contain multiple ingredients (despite num_ingredient <= 1) 
combi_concepts <- readr::read_csv("extras/Definition drug classes/combi_concepts.csv")

for (m in unique(c(removed_concepts$med_group, combi_concepts$med_group))) { # 
  print(m)
  # concepts to remove entirely
  concept_set_m_remove <- as.numeric(removed_concepts$concept_id[removed_concepts$med_group == m])
  
  # concepts to remove from monotherapy
  concept_set_m_remove_mono <- as.numeric(combi_concepts$concept_id[combi_concepts$med_group == m])
  
  # current concept set for monotherapy:
  concept_set_m <- custom_definitions[custom_definitions$cohortName == paste0(m, " mono"),"conceptSet"]
  concept_set_m <- substr(concept_set_m, 2, nchar(concept_set_m)-1)
  concept_set_m <- as.numeric(unlist(strsplit(concept_set_m, ",")))
  
  concept_set_m <- setdiff(concept_set_m, concept_set_m_remove_mono) # remove these concepts
  concept_set_m <- setdiff(concept_set_m, concept_set_m_remove) # remove thesse concepts
  
  count_m <- length(concept_set_m)
  concept_set_m <- paste0("{", paste0(concept_set_m, collapse = ","), "}")
  
  custom_definitions$count[custom_definitions$cohortName == paste0(m, " mono")] <- count_m
  custom_definitions$conceptSet[custom_definitions$cohortName == paste0(m, " mono")] <- concept_set_m
  
  # if also present as combination therapy:
  if (paste0(m, " combi") %in% custom_definitions$cohortName) {
    
    concept_set_m_combi <- custom_definitions[custom_definitions$cohortName == paste0(m, " combi"),"conceptSet"]
    concept_set_m_combi <- substr(concept_set_m_combi, 2, nchar(concept_set_m_combi)-1)
    concept_set_m_combi <- as.numeric(unlist(strsplit(concept_set_m_combi, ",")))
    
    concept_set_m_combi <- union(concept_set_m_combi, concept_set_m_remove_mono) # add these concepts
    concept_set_m_combi <- setdiff(concept_set_m_combi, concept_set_m_remove) # remove these concepts
    
    count_m_combi <- length(concept_set_m_combi)
    concept_set_m_combi <- paste0("{", paste0(concept_set_m_combi, collapse = ","), "}")
    
    custom_definitions$count[custom_definitions$cohortName == paste0(m, " combi")] <- count_m_combi
    custom_definitions$conceptSet[custom_definitions$cohortName == paste0(m, " combi")] <- concept_set_m_combi
  }
}

### 3. create fixed combinations
# load in current concept sets for combinations
concept_set_LAMA <- custom_definitions[custom_definitions$cohortName == "LAMA combi","conceptSet"]
concept_set_LAMA <- substr(concept_set_LAMA, 2, nchar(concept_set_LAMA)-1)
concept_set_LAMA <- as.numeric(unlist(strsplit(concept_set_LAMA, ",")))

concept_set_LABA <- custom_definitions[custom_definitions$cohortName == "LABA combi","conceptSet"]
concept_set_LABA <- substr(concept_set_LABA, 2, nchar(concept_set_LABA)-1)
concept_set_LABA <- as.numeric(unlist(strsplit(concept_set_LABA, ",")))

concept_set_ICS <- custom_definitions[custom_definitions$cohortName == "ICS combi","conceptSet"]
concept_set_ICS <- substr(concept_set_ICS, 2, nchar(concept_set_ICS)-1)
concept_set_ICS <- as.numeric(unlist(strsplit(concept_set_ICS, ",")))

concept_set_SAMA <- custom_definitions[custom_definitions$cohortName == "SAMA combi","conceptSet"]
concept_set_SAMA <- substr(concept_set_SAMA, 2, nchar(concept_set_SAMA)-1)
concept_set_SAMA <- as.numeric(unlist(strsplit(concept_set_SAMA, ",")))

concept_set_SABA <- custom_definitions[custom_definitions$cohortName == "SABA combi","conceptSet"]
concept_set_SABA <- substr(concept_set_SABA, 2, nchar(concept_set_SABA)-1)
concept_set_SABA <- as.numeric(unlist(strsplit(concept_set_SABA, ",")))

# create fixed combinations
LABA_LAMA_ICS <- intersect(concept_set_LABA,intersect(concept_set_LAMA,concept_set_ICS))
LABA_ICS <- setdiff(intersect(concept_set_LABA,concept_set_ICS), LABA_LAMA_ICS)
LABA_LAMA <- setdiff(intersect(concept_set_LABA,concept_set_LAMA), LABA_LAMA_ICS)
SABA_SAMA <- intersect(concept_set_SABA,concept_set_SAMA)

# count concepts
count_LABA_LAMA_ICS <- length(LABA_LAMA_ICS)
count_LABA_ICS <- length(LABA_ICS)
count_LABA_LAMA <- length(LABA_LAMA)
count_SABA_SAMA <- length(SABA_SAMA)

# transform concept sets to string
LABA_LAMA_ICS <- paste0("{", paste0(LABA_LAMA_ICS, collapse = ","), "}")
LABA_ICS <- paste0("{", paste0(LABA_ICS, collapse = ","), "}")
LABA_LAMA <- paste0("{", paste0(LABA_LAMA, collapse = ","), "}")
SABA_SAMA <- paste0("{", paste0(SABA_SAMA, collapse = ","), "}")

# add these new concept sets
custom_definitions <- rbind(custom_definitions,
                            c("LABA&LAMA&ICS", count_LABA_LAMA_ICS, LABA_LAMA_ICS),
                            c("LABA&ICS", count_LABA_ICS, LABA_ICS),
                            c("LABA&LAMA", count_LABA_LAMA, LABA_LAMA),
                            c("SABA&SAMA", count_SABA_SAMA, SABA_SAMA))

custom_definitions <- custom_definitions[-grep("combi", custom_definitions$cohortName),]
custom_definitions$cohortName <- sub(" mono", "", custom_definitions$cohortName)

# overwrite old file
write.csv(custom_definitions, "inst/settings/eventcohorts_custom.csv", row.names = FALSE )


### 4. check resulting definitions
checks <- matrix(NA, length(custom_definitions$cohortName), length(custom_definitions$cohortName))

rownames(checks) <- custom_definitions$cohortName
colnames(checks) <- custom_definitions$cohortName

for (i in 1:length(custom_definitions$cohortName)) {
  for (j in i:length(custom_definitions$cohortName)) {
    
    if (i == j) {
      # Check if all concepts within concept set are unique (no double concepts)
      name_i <- custom_definitions$cohortName[i]
      concept_set <- custom_definitions[custom_definitions$cohortName == name_i,"conceptSet"]
      concept_set <- substr(concept_set, 2, nchar(concept_set)-1)
      concept_set <- as.numeric(unlist(strsplit(concept_set, ",")))
      
      # Return number of double concepts
      checks[i,j] <- length(concept_set) - unique(length(concept_set))
      
    } else {
      # Check if there exists overlap between concept sets
      name_i <- custom_definitions$cohortName[i]
      concept_set_i <- custom_definitions[custom_definitions$cohortName == name_i,"conceptSet"]
      concept_set_i <- substr(concept_set_i, 2, nchar(concept_set_i)-1)
      concept_set_i <- as.numeric(unlist(strsplit(concept_set_i, ",")))
      
      name_j <- custom_definitions$cohortName[j]
      concept_set_j <- custom_definitions[custom_definitions$cohortName == name_j,"conceptSet"]
      concept_set_j <- substr(concept_set_j, 2, nchar(concept_set_j)-1)
      concept_set_j <- as.numeric(unlist(strsplit(concept_set_j, ",")))
      
      # Return number of overlapping concepts
      checks[i,j] <- length(intersect(concept_set_i,concept_set_j))
      
      if (length(intersect(concept_set_i,concept_set_j)) > 0) {
        print(paste0(name_i, " ", name_j, " ", paste0(intersect(concept_set_i,concept_set_j), collapse = ",")))
      }
    }  
  }
}


