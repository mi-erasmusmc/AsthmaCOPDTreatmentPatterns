# Help functions
addInfo <- function(item, infoId) {
  infoTag <- tags$small(
    class = "badge pull-right action-button",
    style = "padding: 1px 6px 2px 6px; background-color: steelblue;",
    type = "button",
    id = infoId,
    "i"
  )
  item$children[[1]]$children <-
    append(item$children[[1]]$children, list(infoTag))
  return(item)
}

# Shiny ui function
ui <- dashboardPage(
  dashboardHeader(title = "Pathways Results",
                  tags$li(div(img(src = 'logo.png',
                                  title = "OHDSI PLP", height = "40px", width = "40px"),
                              style = "padding-top:0px; padding-bottom:0px;"),
                          class = "dropdown")
                  ),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      
      # Tabs (some with additional information)
      menuItem("About", tabName = "about"),
      menuItem("Databases", tabName = "databases"),
      menuItem("Characterization", tabName = "characterization"),
      addInfo(menuItem("Sunburst plots", tabName = "pathways"), "treatmentPathwaysInfo"),
      addInfo(menuItem("Sankey diagram", tabName = "sankeydiagram"), "sankeyDiagramInfo"),
      menuItem("Treated patients", tabName = "summarypathway"),
      menuItem("Duration eras", tabName = "duration"),
      addInfo(menuItem("Step up/down", tabName = "stepupdown"), "stepupdownInfo"),
      
      # Input parameters
      conditionalPanel(
        condition = "input.tabs=='characterization'",
        radioButtons("viewer1", label = "Viewer", choices = c("Compare databases", "Compare study populations"), selected = "Compare databases")
      ),
      conditionalPanel(
        condition = "input.tabs=='characterization'",
        htmlOutput("dynamic_input1")),
      conditionalPanel(
        condition = "input.tabs=='pathways'",
        radioButtons("viewer2", label = "Viewer", choices = c("Compare databases", "Compare study populations", "Compare over time"), selected = "Compare databases")
      ),
      conditionalPanel(
        condition = "input.tabs=='pathways'",
        htmlOutput("dynamic_input2")),
      
      conditionalPanel(
        condition = "input.tabs=='sankeydiagram' || input.tabs=='summarypathway' || input.tabs=='duration'",
        selectInput("dataset34", label = "Database", choices = included_databases, selected = "IPCI")
      ),
      conditionalPanel(
        condition = "input.tabs=='sankeydiagram' ||input.tabs=='summarypathway' || input.tabs=='duration' || input.tabs=='stepupdown'",
        selectInput("population345", label = "Study population", choices = all_populations, selected = "asthma")
      ),
      conditionalPanel(
        condition = "input.tabs=='pathways' || input.tabs=='sankeydiagram'",
        selectInput("analysis2", label = "Analysis", choices = c("Main analysis", "Sensitivity inhalation only", "Sensitivity duration", "Sensitivity treatments prior"), selected = "Main analysis")
      ),
      conditionalPanel(
        condition = "input.tabs=='summarypathway'",
        selectInput("year3", label = "Year", choices = all_years, selected = "all")),
      conditionalPanel(
        condition = "input.tabs=='summarypathway'",
        radioButtons("layer3", label = "Treatment layer", choices = layers, selected = 1)),
      conditionalPanel(
        condition = "input.tabs=='stepupdown'",
        checkboxGroupInput("dataset5", label = "Database", choices = included_databases, selected = "IPCI")
      ),
      conditionalPanel(
        condition = "input.tabs=='stepupdown'",
        radioButtons("transition5", label = "Transition after treatment layer", choices = layers[1:4], selected = 1)
      ),
      conditionalPanel(
        condition = "input.tabs=='stepupdown'",
        radioButtons("rules", label = "Transition after treatment layer", choices = list("Guidelines" = "guidelines", "Broad definition" = "generalized"), selected = "generalized")
      )
    )
  ),
  dashboardBody(
    
    tags$body(tags$div(id="ppitest", style="width:1in;visible:hidden;padding:0px")),
    tags$script('$(document).on("shiny:connected", function(e) {
                                    var w = window.innerWidth;
                                    var h = window.innerHeight;
                                    var d =  document.getElementById("ppitest").offsetWidth;
                                    var obj = {width: w, height: h, dpi: d};
                                    Shiny.onInputChange("pltChange", obj);
                                });
                                $(window).resize(function(e) {
                                    var w = $(this).width();
                                    var h = $(this).height();
                                    var d =  document.getElementById("ppitest").offsetWidth;
                                    var obj = {width: w, height: h, dpi: d};
                                    Shiny.onInputChange("pltChange", obj);
                                });
                            '),
    
    tabItems(
      tabItem(
        tabName = "about",
        br(),
        p(
          "This web-based application provides an interactive platform to explore the results of the AsthmaCOPDTreatmentPatterns R Package. 
          This R package contains the resources for performing the treatment pathway analysis of the study assessing respiratory drug use in patients with asthma and/or COPD, as described in detail in the protocol as registered at ENCePP website under registration number EUPAS41726."
        ),
        HTML("<li>R study package: <a href=\"https://github.com/mi-erasmusmc/AsthmaCOPDTreatmentPatterns\">GitHub</a></li>"),
        HTML("<li>The study is registered: <a href=\"http://www.encepp.eu/encepp/viewResource.htm?id=41727\">EU PASS Register</a></li>"),
        h3("Background"),
        p("Today, many guidelines are available that provide clinical recommendations on asthma or COPD care with as ultimate goal to improve outcomes of patients. There is a lack of knowledge how patients newly diagnosed with asthma or COPD are treated in real-world. We give insight in treatment patterns of newly diagnosed patients across countries to help understand and address current research gaps in clinical care by utilizing the powerful analytical tools developed by the Observational Health Data Sciences and Informatics (OHDSI) community."),
        h3("Methods"),
        p("This study will describe the treatment pathways of patients diagnosed with asthma, COPD or Asthma-COPD Overlap (ACO). For each of the cohorts, a sunburst diagram (and more) is produced to describe the proportion of the respiratory drugs for each treatment sequence observed in the target population."),
        h3("Development Status"),
        p("The results presented in this application are not final yet and should be treated as such (no definite conclusions can be drawn based upon this and the results should not be distributed further).")
      ),
      
      tabItem(
        tabName = "databases",
        includeHTML("./html/databasesInfo.html")
      ),
      
      tabItem(tabName = "characterization",
              box(width = 12,
                  textOutput("tableCharacterizationTitle"),
                  dataTableOutput("tableCharacterization")
              )
      ),
      
      tabItem(tabName = "pathways",
              column(width = 9, 
                     box(
                       title = "Treatment Pathways", width = 30, status = "primary",
                       htmlOutput("sunburstplots"))),
              column(width = 3, tags$img(src = paste0("workingdirectory/sunburst/legend.png"), height = 400))
      ),
      
      tabItem(tabName = "sankeydiagram",
              column(width = 12, 
                     box(
                       title = "Treatment Pathways", width = 30, status = "primary",
                       htmlOutput("sankeydiagram")))
      ),
      
      tabItem(tabName = "summarypathway",
              box(width = 6,
                  textOutput("tableSummaryPathwayTitle"),
                  dataTableOutput("tableSummaryPathway")
              ),
              box(width = 6,
                  textOutput("figureSummaryPathwayTitleYears"),
                  plotOutput("figureSummaryPathwayYears", height = "450px"),
                  textOutput("figureSummaryPathwayTitleLayers"),
                  plotOutput("figureSummaryPathwayLayers", height = "450px"),
              )
      ),
      
      tabItem(tabName = "duration",
              tabsetPanel(
                id = "resultDurationPanel",
                tabPanel(
                  "Tables",
                  br(),
                  textOutput("tableDurationTitle"),
                  br(),
                  dataTableOutput("tableDuration")
                ),
                tabPanel(
                  "Figures",
                  br(),
                  textOutput("heatmapDurationTitle"),
                  br(),
                  plotOutput("heatmapDuration", height = "500px")
                )
              )
      ),
      
      tabItem(tabName = "stepupdown",
              box(width = 12,
                  uiOutput("stepupdownpie")
              )
      )
    )
  )
)
