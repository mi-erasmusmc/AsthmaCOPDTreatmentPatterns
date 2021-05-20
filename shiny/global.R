library(shiny)
library(shinydashboard)
library(shinymanager)
library(reshape2)
library(ggplot2)
library(data.table)
library(DT)

# Set working directory (shiny folder)
local <- paste0(getwd(), "/")
addResourcePath("workingdirectory", getwd())

# Fixing the labels
all_years <- list("Entire study period" = "all", 
                  "Index year 2010" = "2010",
                  "Index year 2011" = "2011",
                  "Index year 2012" = "2012",
                  "Index year 2013" =  "2013",
                  "Index year 2014" = "2014", 
                  "Index year 2015" = "2015",
                  "Index year 2016" = "2016",
                  "Index year 2017" = "2017")

all_populations <- list("Asthma > 18"= "asthma",
                        "COPD > 40" = "copd",
                        "ACO > 40" = "aco",
                        "Asthma 6-17" = "asthma6plus",
                        "Asthma < 5" = "asthma6min")

included_databases <- list.dirs(paste0(local, "output/"), recursive = FALSE, full.names = FALSE) 
names(included_databases) <- included_databases
included_databases <- as.list(included_databases)

# included_databases <- list("IPCI" = "IPCI",
                           # "CPRD" = "CPRD",
                           # "CCAE" = "ccae",
                           # "MDCD" = "mdcd",
                           # "MDCR" = "mdcr"
                           # "AUSOM" = "AUSOM",
                           # "EHIF" = "database")

layers <- list("First-line treatment" = 1,
               "Second-line treatment" = 2,
               "Third-line treatment" = 3,
               "Fourth-line treatment" = 4,
               "Fifth-line treatment" = 5)

labels_stepupdown <- list("stopped" = "Stopped",
                          "step_up" = "Step up",
                          "undefined" =  "Undefined",
                          "step_down" = "Step down",
                          "switching" = "Switching",
                          "acute_exacerbation" = "Acute exacerbation",
                          "end_of_acute_exacerbation" = "End of acute exacerbation",
                          "non_conform" = "Non conform",
                          "off_label" = "Off label")
# Set colors
colors <- list("stopped" = "#EBDEF0", # purple
               "step_up" = "#FADBD8", # red
               "undefined" = "#E5E8E8", # grey
               "step_down" = "#D5F5E3", # green
               "switching" = "#FCF3CF", # yellow
               "acute_exacerbation" = "#FAE5D3", # orange
               "end_of_acute_exacerbation" = "#D6EAF8", # blue
               "non_conform" = "#E5E8E8", 
               "off_label" = "#f0e4ec") 

# Order characterization (alphabetic with some exceptions)
orderRows <- c("Number of persons", "Male" , "Age", "Charlson comorbidity index score",  "Anxiety", "Atopic disorders",
               "Allergic rhinitis", "Cerebrovascular disease",  "Chronic rhinosinusitis" , "Depressive disorder", "Diabetes mellitus", "Gastroesophageal reflux disease" ,  
                "Heartfailure", "Hypertensive disorder", "Ischemic heart disease" , "Lower respiratory tract infections",
                 "Nasal polyposis", "Obesity")   

# Order drug classes
orderClasses <- c("ICS", "LABA", "LABA&ICS", "LABA&LAMA", "LABA&LAMA&ICS", "LAMA", "LTRA", "SABA", "SABA&SAMA", "SAMA", "Systemic glucocorticoids (acute)", "Systemic glucocorticoids (therapy)", "Xanthines", "Anti IgE", "Anti IL4R", "Anti IL5(R)", "Systemic B2 agonist", "PDE4", "Other", "Monotherapy", "Fixed combinations","All combinations", "Total treated")

# Load in all results from output folder
characterization <- list()
stepupdown <- list()
summary_counts <- list()
summary_drugclasses <- list()
summary_drugclasses_year <- list()
duration <- list()

suppressWarnings({
for (d in included_databases) {
  
  # Load characterization for entire database
  characterization[[d]]  <- read.csv(paste0(local, "output/", d, "/characterization/characterization.csv"))
  
  # Load remaining file per study population
  stepupdown_d <- list()
  summary_counts_d <- list()
  summary_drugclasses_d <- list()
  summary_drugclasses_year_d <- list()
  duration_d <- list()
  
  # For database find study populations
  available_populations <- list.dirs(path = paste0(local, "output/", d), full.names = FALSE, recursive = FALSE)
  
  for (p in available_populations[available_populations != "characterization"]) {
    # Load step up/down file for available study populations
    try(stepupdown_d[[p]][["generalized"]] <- read.csv(paste0(local, "output/", d, "/", p, "/",d , "_", p, "_augmentswitch_generalized.csv")), silent = TRUE)
    try(stepupdown_d[[p]][["guidelines"]] <- read.csv(paste0(local, "output/", d, "/", p, "/",d , "_", p, "_augmentswitch_guidelines.csv")), silent = TRUE)
    
    # Load summary counts
    try({file <- read.csv(paste0(local, "output/", d, "/", p, "/",d , "_", p, "_summary_cnt.csv"))
    transformed_file <- data.table(year = character(), number_target = integer(), number_pathways = integer())
    transformed_file <- rbind(transformed_file, list("all", file$N[file$index_year == "Number of persons in target cohort NA"], file$N[file$index_year == "Total number of pathways (after minCellCount)"]))
    
    for (y in all_years[-c(1)]) {
      try(transformed_file <- rbind(transformed_file, list(y, file$N[file$index_year == paste0("Number of persons in target cohort ", y)], file$N[file$index_year == paste0("Number of pathways (after minCellCount) in ", y)])), silent = TRUE)
    }
    
    transformed_file$perc <- round(transformed_file$number_pathways * 100.0 / transformed_file$number_target,1)
    summary_counts_d[[p]] <- transformed_file}, silent = TRUE)
    
    # Load summary classes file for available study populations
    try(summary_drugclasses_d[[p]] <- read.csv(paste0(local, "output/", d, "/", p, "/",d , "_", p, "_percentage_groups_treated_noyear.csv")), silent = TRUE)
    try(summary_drugclasses_year_d[[p]] <- read.csv(paste0(local, "output/", d, "/", p, "/",d , "_", p, "_percentage_groups_treated_withyear.csv")), silent = TRUE)
    
    # Load duration file for available study populations
    try(duration_d[[p]] <- read.csv(paste0(local, "output/", d, "/", p, "/",d , "_", p, "_duration.csv")), silent = TRUE)
  }

  stepupdown[[d]] <- stepupdown_d
  summary_counts[[d]] <- summary_counts_d
  summary_drugclasses[[d]] <- summary_drugclasses_d
  summary_drugclasses_year[[d]] <- summary_drugclasses_year_d
  duration[[d]] <- duration_d
  }
})

writeLines("Data Loaded")

