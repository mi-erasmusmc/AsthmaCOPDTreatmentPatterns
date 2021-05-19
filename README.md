# AsthmaCOPDTreatmentPatterns Package

## Description
This R package contains the resources for performing the treatment pathway analysis of the study assessing respiratory drug use in patients with asthma and/or COPD, as described in detail in the protocol as registered at ENCePP website under registration number (todo: to be added).

*Background*:
Today, many guidelines are available that provide clinical recommendations on asthma or COPD care with as ultimate goal to improve outcomes of patients. There is a lack of knowledge how patients newly diagnosed with asthma or COPD are treated in real-world. We give insight in treatment patterns of newly diagnosed patients across countries to help understand and address current research gaps in clinical care by utilizing the powerful analytical tools developed by the Observational Health Data Sciences and Informatics (OHDSI) community. 

*Methods*: 
This study will describe the treatment pathways of patients diagnosed with asthma, COPD or ACO. For each of the cohorts, a sunburst diagram (and more) is produced to describe the proportion of the respiratory drugs for each treatment sequence observed in the target population. 

## Installation/Execution
If you like to execute this study package against an OMOP-CDM follow these instructions:

1. Download and open the R package using RStudio. 
2. Build the package (packages required are listed in DESCRIPTION file).
3. In extras -> CodeToRun.R: specify connection details. 
4. To execute the study run code in CodeToRun.R. 
5. The results are located in '~/shiny/output'.
6. Run the Shiny App for an interactive visualization of the results.
7. Share the results in the automatically generated zip folder.