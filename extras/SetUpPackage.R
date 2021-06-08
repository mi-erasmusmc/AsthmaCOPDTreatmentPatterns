#------------------------------------------------------------------
# INITIAL PROJECT SETUP ---------------------------------------
#------------------------------------------------------------------
# This initial setup will ensure that you have all required
# R packages installed for use with the AsthmaCOPDTreatmentPatterns
# package. If you are running this in an environment where 
# there is no access to the Internet please see the sections
# below marked "offline setup step".
#------------------------------------------------------------------
#------------------------------------------------------------------
install.packages("renv")

#------------------------------------------------------------------
# OPTIONAL: If you want to change where renv stores the 
# R packages you can specify the RENV_PATHS_ROOT. Please
# refer to https://rstudio.github.io/renv/articles/renv.html#cache
# for more details.
#------------------------------------------------------------------
# Sys.setenv("RENV_PATHS_ROOT"="...")

#------------------------------------------------------------------
# OFFLINE SETUP STEP: If you want to have the entire contents of
# the renv R packages local to your project so that you may copy
# it to another computer, please uncomment the line below and
# specify the RENV_PATHS_CACHE location which should be your project
# folder.
#------------------------------------------------------------------
Sys.setenv("RENV_PATHS_CACHE"=paste0(getwd(),"/renv/cache"))

# Build the local library:
renv::init()

# When not in RStudio, you'll need to restart R now
library(AsthmaCOPDTreatmentPatterns)

# -------------------------------------------------------------
# END Initial Project Setup
# -------------------------------------------------------------
