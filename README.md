# AsthmaCOPDTreatmentPatterns Package

## Description
This R package contains the resources for performing the treatment pathway analysis of the study assessing respiratory drug use in patients with asthma and/or COPD, as described in detail in the protocol as registered at ENCePP website under registration number EUPAS41726 (http://www.encepp.eu/encepp/viewResource.htm?id=41727).

*Background*:
Today, many guidelines are available that provide clinical recommendations on asthma or COPD care with as ultimate goal to improve outcomes of patients. There is a lack of knowledge how patients newly diagnosed with asthma or COPD are treated in real-world. We give insight in treatment patterns of newly diagnosed patients across countries to help understand and address current research gaps in clinical care by utilizing the powerful analytical tools developed by the Observational Health Data Sciences and Informatics (OHDSI) community. 

*Methods*: 
This study will describe the treatment pathways of patients diagnosed with asthma, COPD or Asthma-COPD Overlap (ACO). For each of the cohorts, a sunburst diagram (and more) is produced to describe the proportion of the respiratory drugs for each treatment sequence observed in the target population. 

## Installation/Study Execution
If you like to execute this study package against an OMOP-CDM database follow these instructions:

1. Follow the instructions [here](https://ohdsi.github.io/Hades/rSetup.html) for configuring your R environment, including RTools and Java.

2. Download the latest release of the R package, open and build in RStudio. Alternatively: in RStudio, use the following command to download and install the most recent version of AsthmaCOPDTreatmentPatterns:

  ```r
  install.packages("remotes")
  remotes::install_github("mi-erasmusmc/AsthmaCOPDTreatmentPatterns")
  ```

Optional: Load the renv project environment to ensure that you have all required R packages.
- To run study package in environment with internet: run renv::restore() in the console.
- To run study package in environment without internet: first open the R package using RStudio on a computer with internet (note: this should have the same operating system and R version). Specify the folder where your packages are stored by setting the RENV_PATHS_CACHE location (run Sys.setenv("RENV_PATHS_CACHE"=paste0(getwd(),"/renv/cache"))). Then run renv::restore() in the console. Manually move the study package to the environment without internet (this now includes all required R packages), activate the current project with renv::activate() and again run Sys.setenv("RENV_PATHS_CACHE"=paste0(getwd(),"/renv/cache")) followed by renv::restore() in the console. 

3. In extras -> CodeToRun.R: specify connection details. 
4. To execute the study run code in CodeToRun.R. 
5. The results are located in '~/shiny/output'.
6. Run the Shiny App for an interactive visualization of the results.
7. Share the results in the automatically generated zip folder.

## Shiny Application
Results explorer: https://aniekmarkus.shinyapps.io/AsthmaCOPDTreatmentPatterns/.



