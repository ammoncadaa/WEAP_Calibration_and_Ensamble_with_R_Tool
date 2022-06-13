#'/////////////////////////////////////////////////////////////////////////////
#' 
#' check updates https://github.com/ammoncadaa/WEAP_Calibration_and_Ensamble_with_R_Tool
#' 
#' FILE: "WEAP_Calibration_and_Ensemble_with_R_Tool v.3.0##
#' AUTHOR: Developed by Angelica Moncada (SEI-LAC Water Group member) ##
#' CREATED: 2020
#' MODIFIED: 2022
#' STATUS: working
#' PURPOSE: Explore calibration results of a WEAP model
#' COMMENTS: R version 4.1.1 ## click `Run App` to view the app in the viewer pane
#' 
#' 
#' Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool.
#' 
#' Make sure you have installed the package -RDCOMClient- and it is working properly
#' one option to install -RDCOMClient- run:  install.packages("RDCOMClient", repos = "http://www.omegahat.net/R")
#' Other option: In case that you have any problem installing the RDCOMClient package, you can add the folder of 
#' the package that is within the -RDCOMClient.zip- file. Extract the folder, then copy and paste it within your 
#' library folder. In general, the library can be found at -Documents\R\win-library\4.0-.
#' 
#' In addition, check that you have Rtools: https://cran.r-project.org/bin/windows/Rtools/rtools40v2-x86_64.exe
#' 
#'/////////////////////////////////////////////////////////////////////////////
#

rm(list=ls()) 
cat("\014") 
WD=setwd(dirname(rstudioapi::getSourceEditorContext()$path))
memory.limit(size = NA)

#devtools::install_github("omegahat/RDCOMClient")

if(!require("lintr")) install.packages("lintr"); library("lintr")
if(!require("shiny")) install.packages("shiny"); library("shiny")
if(!require("shinydashboard")) install.packages("shinydashboard"); library("shinydashboard")
if(!require("shinyFiles")) install.packages("shinyFiles"); library("shinyFiles")
if(!require("lubridate")) install.packages("lubridate"); library("lubridate")
if(!require("shinyWidgets")) install.packages("shinyWidgets"); library("shinyWidgets")
if(!require("glue")) install.packages("glue"); library("glue")
if(!require("bindrcpp")) install.packages("bindrcpp"); library("bindrcpp")
if(!require("plotly")) install.packages("plotly"); library("plotly")
if(!require("prodlim")) install.packages("prodlim"); library("prodlim")
if(!require("hydroGOF")) install.packages("hydroGOF"); library("hydroGOF")
if(!require("RDCOMClient")) install.packages("RDCOMClient"); library("RDCOMClient")
if(!require("DT")) install.packages("DT"); library("DT")
if(!require("deSolve")) install.packages("deSolve"); library("deSolve")
if(!require("shinyjs")) install.packages("shinyjs"); library("shinyjs")
if(!require("dplyr")) install.packages("dplyr"); library("dplyr")
if(!require("reshape2")) install.packages("reshape2"); library("reshape2")
if(!require("ggplot2")) install.packages("ggplot2"); library("ggplot2")
if(!require("hydroTSM")) install.packages("hydroTSM"); library("hydroTSM")
if(!require("tidyr")) install.packages("tidyr"); library("tidyr")


GraphOptions=c(   "bar",
                  "box",
                  "contour",
                  "histogram",
                  "histogram2d",
                  "histogram2dcontour",
                  "mesh3d",
                  "pointcloud",
                  "scatter",
                  "scatter3d",
                  "violin",
                  "waterfall",
                  "contour",
                  "heatmap")

shinyApp(

  ui = dashboardPage(
    
    skin = "green",
    dashboardHeader(title = "WEAP Tool v3.0"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("1. Home", tabName = "Home", icon = icon("home")),   
        menuItem("2. Initial Estimations", tabName = "Initial_Estimations", icon = icon("calculator")),
        menuItem("3. Ensemble runs", tabName = "Calibration_Ensemble", icon = icon("laptop")),
        menuItem("4. Navigating by Parameters", tabName = "Navigating_Results", icon = icon("chart-area")),
        menuItem("5. Navigating by Run", tabName = "Navigating_Results1", icon = icon("chart-area")),
        menuItem("5. GOF filters", tabName = "GOF_filter", icon = icon("sort-amount-up")),
        menuItem("6. User Graphs", tabName = "Graphs", icon = icon("chart-bar"))
      )),
    
    dashboardBody(
      tabItems(
        tabItem("Home", 
                ######################################   
                fluidPage(
                  wellPanel(style = "background: white",
                  titlePanel(h1("WEAP Ensemble & Calibration Tool with R", style = "color:green", align = "center")),
                  h3(em(strong(br(code("Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool."))))),
                  hr(),
                  wellPanel(style = "background: white",
                            HTML('<center><img src="https://www.weap21.org/img/logocard2.png", height="200"></center>'),
                            hr(),
                            h4(br("To run the tool, you will need to have the following programs installed: R, RStudio, and WEAP."),
                            em(strong(br(code("Make sure you have installed the package -RDCOMClient- and it is working properly.")))),
                            br("You will see six tabs on the left:"),
                            tags$ol(
                              tags$li("Home. Introduction to the tool. Setting the folder where the results will be saved."),
                              tags$li("Initial Estimations. Initial conductivity estimation and the ratio (percentage) of the Observed Streamflow to Precipitation"), 
                              tags$li("Ensemble runs. Setting up the ensemble. The WEAP model is run and results are saved"), 
                              tags$li("Navigating by Parameters. The calibration ensemble results can be explored by selecting set of parameters"), 
                              tags$li("Navigating by Run. The calibration ensemble results can be explored by selecting the run number"), 
                              tags$li("GOF filter. The calibration ensemble results can be filtered by setting Goodness Of Fit (GOF) thresholds"), 
                              tags$li("User Graphs. The user can set graphs by uploading a file")
                            )
                            ),
                            hr(),
                            wellPanel(style = "background: white",
                              h3("1. Set the name of the WEAP model on which the analyzes will be executed", style = "color:green"),
                              h5("WEAP will open and close to verify that the model exists.", style = "color:green"),
                              fluidRow(
                                column(4,
                                       textInput("warea", label=NULL, value = "Enter the Model Name")
                                ),
                                column(8,
                                       verbatimTextOutput("modelfolderout")
                                )
                              ),
                              actionButton("actionWA", label = " Load WEAP Model",icon("play"), 
                                           style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                              h4(htmlOutput("textWD_results")),
                              hr(),
                              h3(strong(htmlOutput("textWD_results1"))),
                              uiOutput("Isy"),
                              uiOutput("Iey"),
                              h4(htmlOutput("textts")),
                              uiOutput("Its"),
                              h3(strong(htmlOutput("textWD_results2"))),
                              uiOutput("Isce"),
                              ),
                            hr(),
                            h4(p(br("The WEAP Calibration and Ensemble with R tool serves to provide model builders with an 
                            automatic tool to assist in calibrating a WEAP model."), 
                                 br("It uses an ensemble-based approach to automatically produce a complete set of WEAP results from Water-Balance variables."),
                                 br("The model builder can then interact with these results, which include modeled vs. observed streamflow and catchment
                        inflows and outflows, in a set of dynamic graphics and Goodness-Of-Fit (GOF) to identify the optimal set of parameter values. The tool 
                        is designed to be customizable to each WEAP model. Its primary function is to inform calibration."),
                                 hr(),
                                 em(strong(br(code("Version 1.0 (2018)")))),
                                 em(br("Developed by Manon von Kaenel (SEI-US Water Group member). The tool was made for exploring 
                                        calibration ensemble results of one gauge with only one upstream catchment in a 
                            monthly model. This version included three tabs 1) Home, 2) Learning, with the -Estimating Soil 
                            Parameters- section, and 3) Advance Calibration, with three sections: Run WEAP Ensemble, Navigate 
                            Results, and Select Parameters by Performance.")),
                                 em(br("The approach of this tool is similar to the -WEAP Model inspector Version 1.0 (2016)- tool developed in Microsoft Excel by using VBA by Hector Angarita and Vishal Mehta.")),
                                 em(strong(br(code("Version 2.0 (2020)")))),
                                 em(br("Developed by Angelica Moncada (SEI-LAC Water Group member). The version 1.0 was updated for exploring calibrating ensemble results of multiple gauges with one or 
                                        more upstream catchments on a model with any time step. The tool extracted all the water balance variables automatically and allowed the extraction of additional variables. Some additional graphs were added and a new 
                                        section was included for customizing and exploring graphs by using the results of the tool or
                            any file with time series data. This version was built under the R version 4.0.2")),
                                 em(strong(br(code("Version 3.0 (2022)")))),
                                 em(br("Developed by Angelica Moncada (SEI-LAC Water Group member). Version 2.0 was updated to extract all the water balance variables automatically by using a script as an event 
                                       directly in WEAP. Most of the input files of version 2.0 are now generated automatically. The function to extract additional variables was deactivated because extracting WEAP 
                                       results through R is not efficient. A button to save summary graphs was added. This version was built under the R version 4.1.1")),
                                 br("Contact: angelica.moncada@sei.org; angelicammoncada@hotmail.com; angelicammoncada@gmail.com"),
                                 hr(),
                                 em(strong(br(code("This program is free software: you can redistribute it and/or modify
                          it under the terms of the GNU General Public License as published by
                          the Free Software Foundation, either version 3 of the License, or
                          (at your option) any later version.
                          
                          This program is distributed in the hope that it will be useful,
                          but WITHOUT ANY WARRANTY; without even the implied warranty of
                          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                          GNU General Public License for more details.
                          
                          You should have received a copy of the GNU General Public License
                          along with this program.  If not, see <http://www.gnu.org/licenses/>.")))),
                           )
                            ))
                  

                ))),
        ######################################   
        tabItem("Initial_Estimations", 
                ######################################   
                fluidPage(
                  wellPanel(style = "background: white",
                  titlePanel(h1("Initial estimations (ks, kd, Ratio Precipitation to streamflow, water balance)", style = "color:green", align = "center")),
                  h3(em(strong(br(code("Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool."))))),
                  hr(),
                  wellPanel(style = "background: white",
                    h4(
                      p("Copy and paste the script - WEAP_CalibrationToolwithR.vbs -within the WEAP model folder. Then, go to Advanced/Scripting/Edit Events. Finally, specify the script - WEAP_CalibrationToolwithR.vbs - as after WEAP's calculations within the Event Scripts screen.
                                 You will see in the After Calculation box: Call( WEAP_CalibrationToolwithR.vbs ). Click on OK.", style = "color:red", align = "center"),
                      #hr(),
                      p("AFTER the calculations, you can find the resuts within the -SEI tool Results- folder. There are two files that indicate where the analysis was performed.
                      "),
                      p(strong("WEAPKeyGaugesCatchments.csv")),
                      p("This file contains the list of each streamflow gauge and its upstream catchments.
                      "),
                      #hr(),
                      p(strong("WEAPKeyGaugeBranches.csv")),
                      p("This file contains the list of the observed and modeled streamflow branch of each of the streamflow gauges. 
                      ")
                    ),
                  ),
                  hr(),
                  wellPanel(style = "background: white",
                            h2("1.  Run WEAP.", style = "color:green"),
                            hr(),
                            actionButton("actionA", label = " Run WEAP current model",icon("play"), 
                                         style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                            hr(),
                            h5("When you click on -Run WEAP current model-, the calculations will begin and a progress bar at the bottom right corner of the tool interface will tell you the progress percentage of the calculations. You will also see that the result files appear within the working directoy."),
                            hr(),
                            h5(strong(htmlOutput("textRunEnsembleA"))),
                            h5(strong(htmlOutput("textRunEnsembleA1"))),
                            
                  ),
                  hr(),
                  wellPanel(style = "background: white",
                            h3("Save summary graphs. Results will be a subset considering the set dates.", style = "color:green"),
                            fluidRow(
                              column(3,
                                     selectInput("titlesgi", "Titles of graphs",c("English", "Spanish"),selected = "English")
                              ),
                              column(4,
                                     uiOutput("daterangegraphi")
                              ),
                              column(4,
                                     actionButton("graphsi", label = "Save summary graphs (sim vs obs).",icon("play"),
                                                  style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                              )
                            ),
                            h5(strong(htmlOutput("textRunEnsemblegraphi")))),
                  hr(),
                  wellPanel(style = "background: white",
                            h3("Select Gauge and dates to perform the analysis and show graphs", style = "color:green"),
                    fluidRow(
                      column(4,
                             uiOutput("StreamflowA"),
                      ),
                      column(4,
                             uiOutput("daterangei"),
                      )
                    ),
                   hr(),
                  wellPanel(style = "background: white",
                            tags$style(HTML("
.tabbable > .nav > li > a                  {background-color: #c1dbc8;  color:#46484a}
.tabbable > .nav > li[class=active]    > a {background-color: #00A65A; color:white}
")),
                            tabsetPanel(type="tabs",
                                        tabPanel("Conductivity",
                                                 wellPanel(style = "background: white",
                                                           h3("Conductivity (ks,kd)", style = "color:green"),
                                                           fluidRow(
                                                     column(4,
                                                            wellPanel(style = "background: white",
                                                                      h2("1.  User-defined values for estimating the initial conductivity", style = "color:green"),
                                                                      hr(),
                                                                      h5("Default values are already set. Update these to reflect the reality of your particular basin."),
                                                                      numericInput('srpercent','How much of the streamflow is direct surface runoff (excluding base flow)? (DSR, %)',value=20),
                                                                      numericInput('z1','Enter in an estimate of the soil moisture content in the top bucket (z1, %)',value=30),
                                                                      numericInput('z2','Enter in an estimate of the soil moisture content in the bottom bucket (z2, %)',value=30),
                                                                      hr(),
                                                                      actionButton("actionCond", label = " Calculate conductivity",icon("play"), 
                                                                                   style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                                                                      h5(strong(htmlOutput("textRunEnsembleAConduc"))),
                                                                      hr(),
                                                                      h4("The tool can be used to estimate the root zone conductivity and deep conductivity values for a basin based on the characteristics of observed streamflow and its upstream area, and the ratio of observed streamflow to precipitation."), 
                                                                      h4("The R code will automatically estimate the ratio of observed streamflow to precipitation, and the the root zone conductivity and deep conductivity, and report back values and graphs. Note that these conductivity values are estimations, not absolute measurements, so calibration is still necessary to refine these values."),
                                                                      h4("The variables calculated and used to estimate ks and kd are:"),
                                                                      h5("-	Base Flow (m3) = Lowest average observed flow volume. Represents the base flow runoff in the observed streamflow"),
                                                                      h5("-	Outflow (m3) = Highest average observed flow volume - Base Flow. Represents the non-base flow runoff"),
                                                                      h5("-	Interflow (m3) = Highest average observed flow volume - Surface Runoff. Represents the volume of runoff in your catchment that is considered interflow."),
                                                                      h5("-	Surface Runoff (m3) = Outflow * User-defined Percent. Represents the outflow that is considered direct surface runoff. The user defines the proportion of surface runoff to outflow; a typical value is 20%."),
                                                                      h5("-	Depth of interflow (mm) = Interflow / Area of Catchment."),
                                                                      h5("-	Depth of base flow (mm) = Base Flow / Area of Catchment."),
                                                                      h5("-	Ks, root zone conductivity (mm/timeStep) = Depth of interflow / Z1^2. Z1 is an estimate of the soil moisture content in the top bucket of the WEAP 2-bucket soil moisture model, and is entered in as a user-defined percent." ),
                                                                      h5("-	Ks, deep zone conductivity (mm/timeStep) = Depth of base flow / Z2^2. Z2 is an estimate of the soil moisture content in the bottom bucket of the WEAP 2-bucket soil moisture model, and is entered in as a user-defined percent."),
                                                                      hr(),
                                                                      h4("The R code will automatically estimate the root zone conductivity and deep conductivity using the calculations and method discussed at the start of this section, and report back the two values and graphs. Note that these values are estimations, not absolute measurements, so calibration is still necessary to refine these values. "),
                                                                      
                                                            ),
                                                     ),
                                                     column(8,
                                                            wellPanel(style = "background: white",
                                                                      h2("2. Explore results", style = "color:green"),
                                                                      hr(),
                                                                      
                                                                      h3("Conductivity", style = "color:green"),
                                                                      h5(strong(htmlOutput("textRunEnsembleAConduc1"))),
                                                                      wellPanel(style = "background: white",
                                                                                
                                                                                div(style = 'overflow-x: scroll',DT::dataTableOutput("kestimate",width = "100%")),
                                                                      ),
                                                                      wellPanel(style = "background: white",
                                                                                plotlyOutput("kestimateGraphks")),
                                                                      wellPanel(style = "background: white",
                                                                                plotlyOutput("kestimateGraphkd"))
                                                                      
                                                            )
                                                     )
                                                   )
                                                 )
                                                 ),
                                        tabPanel("P/Q",
                                                 h3("Ratio of Observed Streamflow to Precipitation (you can filter by streamflow gauge)", style = "color:green"),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("Q_Pboxplot")),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("Q_Panual"))
                                                 
                                                 ),
                                        tabPanel("Streamflow",
                                                 h3("Simulated vs observed (you can filter by streamflow gauge and dates)", style = "color:green"),
                                                 wellPanel(style = "background: white",
                                                           wellPanel(style = "background: white",
                                                                     div(style = 'overflow-x: scroll',DT::dataTableOutput("metricsi",width = "100%")),
                                                           ),
                                                           plotlyOutput("Qi")),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("Qmonthlyi")),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("fdci"))),
                                        tabPanel("Water Balance",
                                                 h3("Water Balance (you can filter by streamflow gauge and dates)", style = "color:green"),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("WBi")),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("WBmonthlyi")),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("WBmonthlyBi")),
                                                 wellPanel(style = "background: white",
                                                           div(style = 'overflow-x: scroll',DT::dataTableOutput("WBtablei",width = "100%")),

                                                 ),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("WBSMi")),
                                                 wellPanel(style = "background: white",
                                                           plotlyOutput("WBSEi"))
                                        )
                                        ))),
                  

                  hr(),

                ))),
        ######################################   
        tabItem("Calibration_Ensemble", 
                ######################################   
                fluidPage(
                  wellPanel(style = "background: white",
                            titlePanel(h1("Setting up your WEAP Runs", style = "color:green", align = "center")),
                            h3(em(strong(br(code("Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool."))))),
                  wellPanel(style = "background: white",
                            h4(
                              p("IF YOU HAVE NOT DONE IT. Copy and paste the script - WEAP_CalibrationToolwithR.vbs -within the WEAP model folder. Then, go to Advanced/Scripting/Edit Events. Finally, specify the script - WEAP_CalibrationToolwithR.vbs - as after WEAP's calculations within the Event Scripts screen.
                                 You will see in the After Calculation box: Call( WEAP_CalibrationToolwithR.vbs ). Click on OK.", style = "color:red", align = "center"),
                              hr(),
                              p("AFTER the calculations, you can find the resuts within the -SEI tool Results- folder. There are two files that indicate where the analysis was performed:
                      "),
                              p(strong("WEAPKeyGaugesCatchments.csv")),
                              p("This file contains the list of each streamflow gauge and its upstream catchments.
                      "),
                              #hr(),
                              p(strong("WEAPKeyGaugeBranches.csv")),
                              p("This file contains the list of the observed and modeled streamflow branch of each of the streamflow gauges. 
                      ")
                            ),
                            hr(),
                            h4("Follow the instructions in each of the numbered items within this tab. Be careful of uploading input files with the proper structure (column names), values (format) and WEAP expressions.", style = "color:red"),
                            h4("You have TWO options:", style = "color:red"),
                            h4(tags$ul(
                              tags$li("Run the WEAP model and explore calibration and water balance results. In this case, DO NOT upload any WEAP ensemble file, leave blank."),
                              tags$li("If you want to run WEAP multiple times while changing parameters, you will need one of 
                                the files: WEAPKeyEnsemble.csv or KeyModelInputs.csv. The name of the files does not need to be the same. However, column names of each file must be the same.
                                      This file lists the variables in the WEAP model that you want to adjust as part of the calibration exercise. These variables 
                      could correspond to the soil parameter variables for a catchment, a key assumption controlling a particular parameter, or any 
                      other variable relevant to the calibration process (for example, a buffer coefficient to determine reservoir operating rules).
                      The range of the potential values is crucial for the calibration process. As a model builder, it is important to think critically about the physical 
                      realities of the basin that is being modelled and attempt to correlate that to the soil parameters used in the algorithms. 
                      Remember that, based on the number of combinations of sets of parameter values you have dictated WEAP to test out, the ensemble 
                      may include hundreds or thousands of runs. This means that both WEAP and R will be in use during the totality of the ensemble run; 
                      this may last hours or days. So, plan ahead to invest the time to run the ensemble and later interpret the results.")
                              ), style = "color:red"),
                            fluidRow(
                              column(6,
                                     h5("     a-	WEAPKeyEnsemble.csv", style = "color:red"),
                                     h5("In this file, you identify the minimum and maximum value for each of the variables that you want to test, 
                               and the number of variations of values within that range you will test. The total runs will be the product of 
                               all the variations values. The algorithm will evenly distribute the variations within the range of potential values.
                               If you upload the -WEAPKeyEnsemble.csv-, the file -KeyModelInputs.csv- will be created and it will contain the list of all 
                               combinations of the supplied Keys within the thresholds and considering the number of Variations.", style = "color:red"),
                                     ),
                              column(6,
                                     h5("     b-	KeyModelInputs.csv", style = "color:red"),
                                     h5("In this file, you identify the list the combination of the variables that you want to test. Each row must be 
                               identified with a numeric ID (Nrun Column). It is not necessary ID starts in 1. The file can contain as many rows as you 
                               want, but you need to have in mind the calculation time. If you upload a the -KeyModelInputs.csv-, it will be use directly.", style = "color:red")
                                     )
                            ),
                            h4(br("Templates of the input files can be downloaded from:"),
                            tags$div(class = "submit",
                                     tags$a(href = "https://github.com/ammoncadaa/WEAP_Calibration_and_Ensamble_with_R_Tool", 
                                            "Download template files", 
                                            target="_blank")
                            )),
                            
                  ),
                  hr(),
                  wellPanel(style = "background: white",
                    h2("1.  WEAP Ensemble file (Optional, Read Intructions).", style = "color:green"),
                    hr(),
                    h5("Choose to create an ensemble file from a list of WEAP key branches and its min, max and variations values organized by rows (WEAPKeyEnsemble.csv) or uploading the ensemble file which contains the list of runs whith the WEAP key branches organized by columns (KeyModelInputs.csv)."),
                    column(6,
                           h3(strong("Choose file to upload, WEAPKeyEnsemble.csv", style = "color:green")),
                           h5("Columns: Keys, Min, Max, Variations"), 
                           h5("the file -KeyModelInputs.csv- will be automatically created within the working directory. This file contains all the combinations of values of the key parameters that the WEAP ensemble will test. Each row contains a separate set of values that represent one run of the ensemble."),
                           fileInput('WEAPKeyEnsemble', '',
                                     accept = c(
                                       'text/csv',
                                       'text/comma-separated-values',
                                       'text/tab-separated-values',
                                       'text/plain',
                                       '.csv',
                                       '.tsv')            
                           )),
                    column(6,
                           h3(strong("Choose file to upload, KeyModelInputs.csv", style = "color:green")),
                           h5("Columns: Nrun, WEAP Key branches organized by columns"),
                           h5("A copy of the file -KeyModelInputs.csv- will be saved within the working directory. Do not delete this file!. This file contains all the combinations of values of the key parameters that the WEAP ensemble will test. Each row contains a separate set of values that represent one run of the ensemble."),
                           fileInput('WEAPKeyEnsembleInputs', '',
                                     accept = c(
                                       'text/csv',
                                       'text/comma-separated-values',
                                       'text/tab-separated-values',
                                       'text/plain',
                                       '.csv',
                                       '.tsv')            
                           )),
                    hr(),
                    h5("When the file is imported, it will appear here below:"),
                    hr(),
                    wellPanel(style = "background: white",
                              div(style = 'overflow-x: scroll',DT::dataTableOutput("tableWEAPKeyEnsemble",width = "100%")),
                     
                    )
                    ),
                  hr(),
                  wellPanel(style = "background: white",
                            h2("2. Run analysis.", style = "color:green"),
                            hr(),
                            actionButton("action", label = " Run Ensemble",icon("play"), 
                                         style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                            hr(),
                            h5("When you click on -Run WEAP-, the ensemble will begin and a progress bar at the bottom right corner of the tool interface will tell you the progress percentage of the ensemble. You will also see new files start to appear within the working directoy, containing the results for each model run."),
                            h5("After starting ensemble run, wait for all the runs to be done and the WEAP application to save before continuing."),
                            h5("You will know that the ensemble is finished when the progress bar disappears, and when you see the WEAP model stop running. At this point, you can go to the -4. Navigating Results- tab or -5. GOF filters- for exploring and filter the calibration results or to the -6.User Graphs- tab to graph variables from any *.csv file."),
                            hr(),
                            h5(strong(htmlOutput("textRunEnsemble")))
                  )
                )
        )),
        ######################################   
        tabItem("Navigating_Results", 
                ######################################   
                useShinyjs(),
                wellPanel(style = "background: white",
                          titlePanel(h1("Navigate Water balance results by combination of set of parameters", style = "color:green", align = "center")),
                          h3(em(strong(br(code("Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool."))))),
                  hr(),
                  wellPanel(style = "background: white",
                            h4(
                              p("This section was made to interact with and visualize the results of the ensemble runs or the last WEAP run, in order to understand how the modeled 
                      hydrograph changes with changes in values of key parameters, and how that matches with observed streamflow and the water balance of the basin."),
                              p("When the calibration ensemble has finished a series of sliders will be shown on the left panel; these sliders 
                         correspond to each of your key parameters of the -WEAPKeyEnsemble.csv- or -KeyModelInputs.csv- file. You can click 
                         on and drag these sliders to select a different set of key parameter values"),
                              p("The table of values at the top shows the Goodness Of Fit (GOF) metrics quantifying the performance of your calibration. GOF are shown for the 
                    entire period, and validation (70% of the data) and calibration (30% of the data) period."),
                              p(strong("The GOF metrics reported are:")),
                              tags$ul(
                                tags$li("Mean Error (ME)"),
                                tags$li("Mean Absolute Error (MAE)"),
                                tags$li("Normalized Root Mean Square Error ( -100% <= nrms <= 100% ) (NRMSE)"), 
                                tags$li("Percent Bias (PBIAS)"),
                                tags$li("Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )"),
                                tags$li("Modified Nash-Sutcliffe Efficiency ( -Inf <= mNSE <= 1 )"),
                                tags$li("Index of Agreement ( 0 <= d <= 1 )"),
                                tags$li("Modified Index of Agreement ( 0 <= md <= 1 )"),
                                tags$li("Coefficient of Determination ( 0 <= R2 <= 1 )"),
                                tags$li("R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )"),
                                tags$li("Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )"),
                                tags$li("Volumetric efficiency between sim and obs ( -Inf <= VE <= 1).")
                              ),
                              p("In addition, If you are interested in calculating the GOF metrics for a particular subset of years, you can select the date range for which to 
                    calculate the metrics in the -2. Select value of parameters- panel."),
                              p("In the second panel, you are able to visualize results from the model run."),
                              p(strong("Streamflow tab plots:")),
                              tags$ul(
                                   tags$li("Time series, Observed streamflow at the selected gauge station vs. modeled streamflow, which has been output 
                                   from the WEAP model and saved into your working directory"),
                                   tags$li("Multiannual monthly average, observed vs. modeled streamflow"), 
                                   tags$li("Flow duration curves")
                                 ),
                              p(strong("Water Balance tab plots:")),
                              tags$ol(
                                tags$li("Time series, precipitation (black line), evapotranspiration (green), surface runoff (light blue), interflow (blue), and base flow (dark blue)"),
                                tags$li("Multiannual monthly average, precipitation (black line), evapotranspiration (green), surface runoff (light blue), interflow (blue), and base flow (dark blue)"), 
                                tags$li("Multiannual monthly average, Water Balance Percentages"),
                                tags$li("Multiannual monthly average, Water Balance table"),
                                tags$li("Time series, soil moisture"),
                                tags$li("Multiannual monthly average, soil moisture"),
                              ),
                      p("This set of visualizations give you information about the key components of the water balance 
                      in your basins for each model run"),
                      p("Including this information in your calibration process is useful to verify the validity of different sets of key parameters: 
                      does the evapotranspiration produced by this set of key parameter values make sense for your model region? And does the ratio of surface runoff 
                      to base flow match your expectation? The plots show the time series for each of the components and the multiannual monthly average values of precipitation, evapotranspiration, and total streamflow."),
                      
                      p("All the plots are interactive, so you can zoom into the plot and/or compare any two data points when you place your mouse over the plot. 
                    Note that you may have to scroll to see all the plots"), 
                              p("You can interact with the plots and with the sliders to see how your basin responds to key parameter changes, 
                      notice how the GOF values change, and how the hydrographs of the modeled streamflow shifts.")),

                            hr(),
                            h4(strong("Follow each of the numbered items within this tab.")
                            )),
                  hr(),
                  wellPanel(style = "background: white",
                    h3("Save summary graphs. Results will be a subset considering the set dates.", style = "color:green"),
                    fluidRow(
                      column(3,
                             selectInput("titlesg", "Titles of graphs",c("English", "Spanish"),selected = "English")
                             ),
                      column(4,
                             uiOutput("daterangegraph")
                      ),
                      column(4,
                             actionButton("graphs", label = " Save summary graphs (sim vs obs).",icon("play"), 
                                          style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                             )
                    ),
                    h5(strong(htmlOutput("textRunEnsemblegraph"))),
                                        
                  ),
                  hr(),
                  wellPanel(style = "background: white",
                    h3("1. Select Gauge", style = "color:green"),
                    uiOutput("Streamflow"),
                    #verbatimTextOutput("keys"),
                    hr(),
                    wellPanel(style = "background: white",
                      
                      div(style = 'overflow-x: scroll',DT::dataTableOutput("metricsp",width = "100%")),
                    ),
                    wellPanel(style = "background: white",
                              div(style = 'overflow-x: scroll',DT::dataTableOutput("metrics",width = "100%")),
                    )
                    
                  ),
                  hr(),
                  wellPanel(style = "background: white",
                  fluidRow(
                    column(3,
                           wellPanel(style = "background: white",
                                     h3("2. Select value of parameters", style = "color:green"),
                                     hr(),
                                     uiOutput("daterange"),
                                     hr(),
                                     h5(strong(htmlOutput("runID"))),
                                     hr(),
                                     uiOutput("sliders")
                           )),
                    column(9,
                           
                           wellPanel(style = "background: white",
                             tags$style(HTML("
.tabbable > .nav > li > a                  {background-color: #c1dbc8;  color:#46484a}
.tabbable > .nav > li[class=active]    > a {background-color: #00A65A; color:white}
")),
                             tabsetPanel(type="tabs",
                                         tabPanel("Streamflow",
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("Q")),
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("Qmonthly")),
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("fdc"))),
                                         tabPanel("Water Balance",
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("WB")),
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("WBmonthly")),
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("WBmonthlyB")),
                                                  wellPanel(style = "background: white",
                                                            div(style = 'overflow-x: scroll',DT::dataTableOutput("WBtable",width = "100%")),
                                                            
                                                  ),
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("WBSM")),
                                                  wellPanel(style = "background: white",
                                                            plotlyOutput("WBSE"))
                                                )))
                    )))
                )),
        ######################################   
        tabItem("Navigating_Results1", 
                ######################################   
                useShinyjs(),
                wellPanel(style = "background: white",
                          titlePanel(h1("Navigate Water balance results by run number", style = "color:green", align = "center")),
                          h3(em(strong(br(code("Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool."))))),
                          hr(),
                          wellPanel(style = "background: white",
                                    h4(
                                      p("This section was made to interact with and visualize the results of the ensemble runs or the last WEAP run, in order to understand how the modeled 
                      hydrograph changes with changes in values of key parameters, and how that matches with observed streamflow and the water balance of the basin."),
                                      p("When the calibration ensemble has finished you will see a list of runs; the run numbers 
                         correspond to each of your key parameters of the -WEAPKeyEnsemble.csv- or -KeyModelInputs.csv- file. You can selec ONE run number."),
                                      p("The table of values at the top shows the Goodness Of Fit (GOF) metrics quantifying the performance of your calibration. GOF are shown for the 
                    entire period, and validation (70% of the data) and calibration (30% of the data) period."),
                                      p(strong("The GOF metrics reported are:")),
                                      tags$ul(
                                        tags$li("Mean Error (ME)"),
                                        tags$li("Mean Absolute Error (MAE)"),
                                        tags$li("Normalized Root Mean Square Error ( -100% <= nrms <= 100% ) (NRMSE)"), 
                                        tags$li("Percent Bias (PBIAS)"),
                                        tags$li("Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )"),
                                        tags$li("Modified Nash-Sutcliffe Efficiency ( -Inf <= mNSE <= 1 )"),
                                        tags$li("Index of Agreement ( 0 <= d <= 1 )"),
                                        tags$li("Modified Index of Agreement ( 0 <= md <= 1 )"),
                                        tags$li("Coefficient of Determination ( 0 <= R2 <= 1 )"),
                                        tags$li("R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )"),
                                        tags$li("Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )"),
                                        tags$li("Volumetric efficiency between sim and obs ( -Inf <= VE <= 1).")
                                      ),
                                      p("In addition, If you are interested in calculating the GOF metrics for a particular subset of years, you can select the date range for which to 
                    calculate the metrics in the -2. Select value of parameters- panel."),
                                      p("In the second panel, you are able to visualize results from the model run."),
                                      p(strong("Streamflow tab plots:")),
                                      tags$ul(
                                        tags$li("Time series, Observed streamflow at the selected gauge station vs. modeled streamflow, which has been output 
                                   from the WEAP model and saved into your working directory"),
                                        tags$li("Multiannual monthly average, observed vs. modeled streamflow"), 
                                        tags$li("Flow duration curves")
                                      ),
                                      p(strong("Water Balance tab plots:")),
                                      tags$ol(
                                        tags$li("Time series, precipitation (black line), evapotranspiration (green), surface runoff (light blue), interflow (blue), and base flow (dark blue)"),
                                        tags$li("Multiannual monthly average, precipitation (black line), evapotranspiration (green), surface runoff (light blue), interflow (blue), and base flow (dark blue)"), 
                                        tags$li("Multiannual monthly average, Water Balance Percentages"),
                                        tags$li("Multiannual monthly average, Water Balance table"),
                                        tags$li("Time series, soil moisture"),
                                        tags$li("Multiannual monthly average, soil moisture"),
                                      ),
                                      p("This set of visualizations give you information about the key components of the water balance 
                      in your basins for each model run"),
                                      p("Including this information in your calibration process is useful to verify the validity of different sets of key parameters: 
                      does the evapotranspiration produced by this set of key parameter values make sense for your model region? And does the ratio of surface runoff 
                      to base flow match your expectation? The plots show the time series for each of the components and the multiannual monthly average values of precipitation, evapotranspiration, and total streamflow."),
                                      
                                      p("All the plots are interactive, so you can zoom into the plot and/or compare any two data points when you place your mouse over the plot. 
                    Note that you may have to scroll to see all the plots"), 
                                      p("You can interact with the plots and with the sliders to see how your basin responds to key parameter changes, 
                      notice how the GOF values change, and how the hydrographs of the modeled streamflow shifts.")),
                                    
                                    hr(),
                                    h4(strong("Follow each of the numbered items within this tab.")
                                    )),
                          hr(),
                          wellPanel(style = "background: white",
                                    h3("Save summary graphs. Results will be a subset considering the set dates.", style = "color:green"),
                                    fluidRow(
                                      column(3,
                                             selectInput("titlesg1", "Titles of graphs",c("English", "Spanish"),selected = "English")
                                      ),
                                      column(4,
                                             uiOutput("daterangegraph1")
                                      ),
                                      column(4,
                                             actionButton("graphs1", label = " Save summary graphs (sim vs obs).",icon("play"), 
                                                          style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                                      )
                                    ),
                                    h5(strong(htmlOutput("textRunEnsemblegraph1"))),
                                    
                          ),
                          hr(),
                          wellPanel(style = "background: white",
                                    h3("1. Select Gauge, run, and dates", style = "color:green"),
                                    fluidRow(
                                      column(3,
                                             uiOutput("Streamflow1"),
                                             ),
                                      column(6,
                                             uiOutput("daterange1"),
                                      ),
                                      column(3,
                                             uiOutput("sliders1"),
                                      )
                                    ),
                                    #verbatimTextOutput("keys"),
                                    hr(),
                                    wellPanel(style = "background: white",
                                      
                                      div(style = 'overflow-x: scroll',DT::dataTableOutput("metricsp1",width = "100%")),
                                    ),
                                    wellPanel(style = "background: white",
                                              div(style = 'overflow-x: scroll',DT::dataTableOutput("metrics1",width = "100%")),
                                             
                                    )
                                    
                          ),
                          hr(),
                          wellPanel(style = "background: white",
                                    tags$style(HTML("
.tabbable > .nav > li > a                  {background-color: #c1dbc8;  color:#46484a}
.tabbable > .nav > li[class=active]    > a {background-color: #00A65A; color:white}
")),
                                    tabsetPanel(type="tabs",
                                                tabPanel("Streamflow",
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("Q1")),
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("Qmonthly1")),
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("fdc1"))),
                                                tabPanel("Water Balance",
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("WB1")),
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("WBmonthly1")),
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("WBmonthlyB1")),
                                                         wellPanel(
                                                           div(style = 'overflow-x: scroll',DT::dataTableOutput("WBtable1",width = "100%")),
                                                           
                                                         ),
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("WBSM1")),
                                                         wellPanel(style = "background: white",
                                                                   plotlyOutput("WBSE1"))
                                                ))
                                    )
                )),
        ######################################  
        tabItem("GOF_filter", 
                ######################################   
                useShinyjs(),
                wellPanel(style = "background: white",
                          fluidPage(
                  titlePanel(h1("Select paramaters based on performance metrics", style = "color:green", align = "center")),
                  h3(em(strong(br(code("Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool."))))),
                  wellPanel(style = "background: white",
                            h4(
                              p("This is another way to interact with the results of your model ensemble. 
                       Rather than selecting the values of key parameters using sliders and seeing the effect on calibration 
                       performance and water balance components as in the previous tab, this tab offers you the chance to filter 
                       model results by their calibration performance. You can identify -acceptable- ranges for the GOF metrics values 
                       based on literature and/or experience and see which set of values of your key parameters produce an acceptable calibration."),
                              p("First you must calculate the GOF metrics for all ensemble runs by clicking on the button -Calculate- in the tab -1. Calculate performance 
                     metrics. The metrics will be calculated within the indicated date range. Once the calculation is finished a csv file named -SummaryGOF- will be saved within 
                     the working directory. If you want to look through the complete set of GOF metrics for all the model runs, you can also do so outside the R tool."),
                              p("In the panel -2. Set thresholds for the performance metrics. These user-defined thresholds define an -acceptable- 
                       calibration. Each time that you set a diferent time period and press on the -calculte- button a new file is created."),
                              p("the panel -3. See filtered performance metrics- shows the set of GOF indices that satisfy the user-defined thresholds. 
                       You can also interact with the table and order the results by values and identified which model runs fall within an acceptable calibration range"),
                             
                            ),
                            
                            )
                  ),
                  hr(),
                  wellPanel(style = "background: white",
                    fluidRow(
                      column(5,
                             h3("1. Calculate performance metrics within the indicated date range", style = "color:green"),
                             uiOutput("GOFdaterange"),
                             actionButton("GOFmetrics", label = " Calculate",icon("play"), 
                                          style="color: #fff; background-color: #00A65A; border-color: #00A65A; width:100%;white-space:normal;font-size:.9vw;"),
                            h5("When you click on -Calculate-, the calclations will begin and a progress bar at the bottom right corner of the tool interface will tell you the progress percentage of the calculations."),
                            hr(),
                            h5(strong(htmlOutput("GOFtextRunactmetrics")))),
                            
                      column(7,
                             h3("2. Enter thresholds for performance metrics", style = "color:green"),
                             fluidRow(
                               column(12,
                                      column(4,numericInput("nse", label = "Minimum Nash-Sutcliffe Efficiency NSE", value = -1000000)),
                                      column(4,numericInput("mnse", label = "Minimum Modified Nash-Sutcliffe Efficiency  mNSE", value = -1000000)),
                                      column(4,numericInput("bias",label="Bias (absolute value %)", value = 1000000))
                               ),
                               column(12,
                                      column(4,numericInput("d", label = "Minimum Index of Agreement d", value = -1000000)),
                                      column(4,numericInput("md", label = "Minimum Modified Index of Agreement md", value = -1000000)),
                                      column(4,numericInput("r2",label="Coefficient of Determination R2", value = -1000000))
                               )
                             )))),
                  hr(),
                  h3("3. Filtered performance metrics", style = "color:green"),
                  wellPanel(style = "background: white",
                    fluidRow(
                      column(6,
                             plotlyOutput("GOF_1")),
                      column(6,
                             plotlyOutput("GOF_2"))
                    )),
                  hr(),
                  wellPanel(style = "background: white",
                    fluidRow(
                      column(6,
                             plotlyOutput("GOF_3")),
                      column(6,
                             plotlyOutput("GOF_4"))
                    )),
                  hr(),
                  wellPanel(style = "background: white",
                    fluidRow(
                      column(6,
                             plotlyOutput("GOF_5")),
                      column(6,
                             plotlyOutput("GOF_6"))
                    )),
                  hr(),
                  wellPanel(style = "background: white",
                    fluidRow(
                      column(6,
                             plotlyOutput("GOF_7")),
                      column(6,
                             plotlyOutput("GOF_8"))
                    )),
                  hr(),
                  wellPanel(style = "background: white",
                    fluidRow(
                      column(6,
                             plotlyOutput("GOF_9")),
                      column(6,
                             plotlyOutput("GOF_10"))
                    )),
                  hr(),
                  wellPanel(style = "background: white",
                    fluidRow(
                      column(6,
                             plotlyOutput("GOF_11")),
                      column(6,
                             plotlyOutput("GOF_12"))
                    )),
                  hr(),
                  wellPanel(style = "background: white",
                    
                    div(style = 'overflow-x: scroll',DT::dataTableOutput("GOFmetricsruns",width = "100%")),
                  )
                  # hr(),
                  # h3("4. All performance metrics", style = "color:green"),
                  # wellPanel(
                  #   DT::dataTableOutput("GOFmetricsrunsALL"),style = "overflow-x: scroll;" 
                  # ),
                )),
        ######################################   
        tabItem("Graphs", 
                ######################################   
                useShinyjs(),
                wellPanel(style = "background: white",
                          fluidPage(
                  titlePanel(h1("Select the file which contains the variables to plot", style = "color:green", align = "center")),
                  h3(em(strong(br(code("Instructions within each tab. READ CAREFULLY. You DO NOT need to run the model before using the tool."))))),
                  wellPanel(style = "background: white",
                            h4("You can set graphs by uploading a file within the working directory"),
                            h4("* If the file contains a column with dates, the column must be named as -Dates-. Format must be yyyy-mm-dd"),
                            h4("* If the file contains a column with streamflow gauge stations, the column must be named as -Gauge-"),
                            h4("* If the file contains a column with catchments, the column must be named as -Catchment-"),
                            hr(),
                            h4(strong("Follow each of the numbered items within this tab."))
                  ),
                  hr(),
                  wellPanel(style = "background: white",
                    h2("1. Set the working directory where the files are", style = "color:green"),
                    h5("Copy and paste the full path:"),
                    textInput("WD_resultsGraphs", "", "", width="80%"),
                    h5(strong(htmlOutput("textWD_resultsGraphs"))),
                    hr(),
                    h2("2. Choose de *.csv file.", style = "color:green"),
                    h5("The list of the *.csv files within the working directory are listed below:"),
                    uiOutput("UploadedFileCsv"),
                    hr(),
                    h5("When the file is imported, it will appear here below:"),
                    wellPanel(style = "background: white",
                              div(style = 'overflow-x: scroll',DT::dataTableOutput("tableUploadedFile",width = "100%")),
                              
                    ),
                    hr(),
                    h2("3. Choose de type of graph", style = "color:green"),
                    h5("Type of mode only works when Type is scatter"),
                    fluidRow(
                      column(3,
                             selectInput("Type", "Type of graph:",GraphOptions)),
                      column(3,
                             selectInput("TypeMode", "Type of mode:",c("markers","lines","markers+lines")))
                    ),
                    hr(),
                    h2("4. Choose de information to be plotted", style = "color:green"),
                    h5("Z axis only works on -contour, heatmap, mesh3d, scatter3d- graphs"),
                              fluidRow(
                                column(4,
                                       uiOutput("Xaxis"),
                                       uiOutput("Yaxis"),
                                       uiOutput("Zaxis")),
                                column(4,
                                       uiOutput("Catchments"),
                                       uiOutput("Gauges"))
                                
                              ),
                    verbatimTextOutput("col"),
                    h2("5. Explore the graph", style = "color:green"),
                    wellPanel(style = "background: white",
                      plotlyOutput("plotfile")
                    ),
                    hr(),
                    h5("The plotted data is:"),
                    hr(),
                    wellPanel(style = "background: white",
                      
                      div(style = 'overflow-x: scroll',DT::dataTableOutput("tableplotfile",width = "100%")),
                    )
                    
                    
                  )
                  
                )))
        
      ))
  ),
  ######################################   
  
  server = function(input, output) { 
    
    VAL = reactiveValues(Model=0, Model1=0, Model2=0,Model3=0)  #model #conductivity  #ensamble #keys
    
    ###################################### 
    observeEvent(input$actionWA,{
      
      withProgress(message = 'Loading the selected WEAP model',
                   detail = 'This may take a while...', value = 0, {
                     
                     incProgress(1/2)
      WEAP = COMCreate("WEAP.WEAPApplication")
      Sys.sleep(3)
      Warea=input$warea
      
      modelfolder=paste0(WEAP$AreasDirectory(),Warea)
      
         #(dir.exists("C:\\Users\\angel\\OneDrive\\Documentos\\WEAP Areas\\Modelo Tupiza V1.8"))
        if (dir.exists(modelfolder) && Warea!="") {
          Model=1
          VAL$Model=Model
          WEAP[["ActiveArea"]] <- Warea
          sy=WEAP[["BaseYear"]]
          ey=WEAP[["EndYear"]]
          ts=WEAP[["NumTimeSteps"]]
          
          setwd(WD)
          Carpeta_Out=as.character(paste0("Results ",Warea))
          dir.create(Carpeta_Out,showWarnings=F)
          dir_outg = paste(c(WD,"\\",Carpeta_Out),collapse="")
          setwd(dir_outg)
          VAL$dir_outg=dir_outg
          
          output$textWD_results <-renderText({
            outTxt = ""
            text=paste0("The results will be saved in: ",getwd())
            formatedFont = sprintf('<font color="%s">%s</font>',"red",text)
            outTxt = paste0(outTxt, formatedFont)
            outTxt
          })
          
          output$textWD_results1 <-renderText({
            outTxt = ""
            text="Parameters imported from the current model. It could be changed if needed."
            formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
            outTxt = paste0(outTxt, formatedFont)
            outTxt
          })
          
          output$textWD_results2 <-renderText({
            outTxt = ""
            text="Set ONE scenario to import the results. It is recommended that the model has just one active scenario."
            formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
            outTxt = paste0(outTxt, formatedFont)
            outTxt
          })
          
          output$textts <-renderText({
            outTxt = ""
            text="*Make sure that the -Add Leap Day?-option (General/Years and Time Steps) is deactivated in WEAP."
            formatedFont = sprintf('<font color="%s">%s</font>',"red",text)
            outTxt = paste0(outTxt, formatedFont)
            outTxt
          })
          
          output$Isy <- renderUI({
            textInput("start",label="Start Year:",value = sy)
          })
          
          output$Iey <- renderUI({
            textInput("end",label="End Year:",value =ey)
          })
          
          output$Its <- renderUI({
            textInput("ts",label="TimeStep per year:",value =ts)
          })
        
          output$Isce <- renderUI({
            textInput("Scen",label="Scenario:",value ="Reference")
          })
          
          if (file.exists(paste0("0_ResultsGauges.csv")) && Model==1) {
            
            file=read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
            file$Dates=ymd(file$Dates)
            starty <- min(file$Dates)
            endy <- max(file$Dates)
            gauges=sort(unique(file$Gauge))
            VAL$gauges1=gauges
            
            output$StreamflowA <- renderUI({
              selectInput("StreamflowSelectA", "Streamflow Gauge",gauges,selected = gauges[1])
           })
            
            output$daterangei <- renderUI({
                dateRangeInput("datesi",label="Select date range to filter streamflow and water balance",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
            })
            
            output$daterangegraphi <- renderUI({
              
                dateRangeInput("datesgraphi",label="Select date range to calculate performance metrics and save graphs",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
             
            })
            
            VAL$Model1=1
            
            srpercent=as.numeric(input$srpercent)
            z1=as.numeric(input$z1)
            z2=as.numeric(input$z2)
            try({
              if (file.exists(paste0("0_ResultsGauges.csv")) && Model==1) {
                
                obs <- read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
                cols=c("Year",
                       "Time step",
                       "Gauge",
                       "Observed",
                       "Area",
                       "Dates")
                obs=obs[,cols]
                
                table <- data.frame(matrix(NA,ncol=3, nrow=length(unique(obs$Gauge))))
                colnames(table)=c("Gauge","Ks, top bucket","Kd, bottom bucket")
                
                
                for (i in 1:length(unique(obs$Gauge))){
                  
                  table[i,1]=unique(obs$Gauge)[i]
                  
                  flows=obs[obs$Gauge==unique(obs$Gauge)[i],]
                  flows$Dates <- ymd(flows$Dates)
                  
                  high <- max(flows$Observed,na.rm=T) 
                  low <- min(flows$Observed,na.rm=T) 
                  if (low==0){
                    low <- unique(sort(na.exclude(flows$Observed)))[2] 
                  }
                  
                  outflow <- high-low 
                  sr <- outflow*(as.numeric(srpercent)/100)
                  interflow <- outflow-sr 
                  
                  interflowd <- interflow/unique(flows$Area)*1000 
                  ks <- interflowd/(as.numeric(z1)/100)^2 
                  
                  bfdepth <- low/unique(flows$Area)*1000 
                  kd <- bfdepth/(as.numeric(z2)/100)^2 
                  
                  table[i,2] <- round(ks,2) 
                  table[i,3] <- round(kd,2) 
                  
                }
                
                write.csv(table[order(table$Gauge),],paste0("0_Resultsk_Summary","-DSR",srpercent,"-Z1",z1,"-Z2",z2,".csv"),row.names=F) 
                
                list=list.files(getwd(),pattern = "0_Resultsk_Summary-DSR")
                list
                list1=list
                list1=gsub(".csv","",list1,fixed = TRUE)
                list1=gsub("0_Resultsk_Summary-","",list1,fixed = TRUE)
                
                file1=NULL
                for (i in 1:length(list)){
                  
                  file <- read.csv(paste0("",list[i]), stringsAsFactors=F, check.names=F)
                  file$Parameters=list1[i]
                  file1=rbind(file1,file)
                }
                
                file1=file1[order(file1$Gauge),]
                write.csv(file1,paste0("0_Resultsk_SummaryALL.csv"),row.names=F) 
                
                output$textRunEnsembleAConduc <- renderText({ 
                  
                  outTxt = ""
                  text=paste0("Initial Conductivity was calculated for "," DSR: ",srpercent," Z1: ",z1," Z2: ",z2, ". Check the Results folder: ", VAL$dir_outg) 
                  formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                  outTxt = paste0(outTxt, formatedFont)
                  
                  outTxt
                  
                })
                
                output$textRunEnsembleAConduc1 <- renderText({ 
                  
                  outTxt = ""
                  text=paste0("Conductivity:"," DSR: ",srpercent," Z1: ",z1," Z2: ",z2) 
                  formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                  outTxt = paste0(outTxt, formatedFont)
                  
                  outTxt
                  
                })
                
                output$kestimate <- DT::renderDataTable({
                  table=table[order(table$Gauge),]
                  DT::datatable(table, rownames= FALSE)
                  
                })
                
                file <- table
                file$Gauge=as.factor(file$Gauge)
                colnames(file)=c("Gauge", "ks", "Kd")
                
                output$kestimateGraphks <- renderPlotly({
                  
                  text=paste0("ks, top bucket conductivity "," DSR:",srpercent,"% Z1:",z1,"% Z2:",z2,"%")
                  #text=""
                  p1 <-plot_ly(file, x=~Gauge, y=~ks, type="bar",color = ~Gauge) %>%
                    layout(title =text ,
                           xaxis = list(title=""),
                           yaxis = list(title= "ks (mm)"))
                  p1
                  
                })
                
                output$kestimateGraphkd <- renderPlotly({
                  
                  text=paste0("kd, bottom bucket conductivity "," DSR:",srpercent,"% Z1:",z1,"% Z2:",z2,"%")
                  #text=""
                  p1 <-plot_ly(file, x=~Gauge, y=~ks, type="bar",color = ~Gauge) %>%
                    layout(title =text ,
                           xaxis = list(title=""),
                           yaxis = list(title= "ks (mm)"))
                  p1
                  
                  
                })
              }
            }) 
          
          }
          
          if (file.exists(paste0("KeyModelInputs.csv"))){
            VAL$Model3=1
            
          }
          
          if (length(list.files(pattern ="ResultsWB-")>0)){
            VAL$Model2=1
            
            listResults=list.files(pattern ="ResultsWB-")
            listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
            listResults=gsub(".csv","",listResults,fixed = TRUE)
            listResults=unique(as.numeric(listResults))
            file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
            file$Dates=ymd(file$Dates)
            starty <- min(file$Dates)
            endy <- max(file$Dates)
            gauges=sort(c(unique(file$Gauge)))
            
            output$Streamflow <- renderUI({
                selectInput("StreamflowSelect", "Streamflow Gauge",gauges,gauges[1])
            })
            output$daterange <- renderUI({
                dateRangeInput("dates",label="Select date range to filter streamflow and water balance",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
            })
            
            output$daterangegraph <- renderUI({
                dateRangeInput("datesgraph",label="Select date range to calculate performance metrics and save graphs",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
            })
            output$daterangegraph1 <- renderUI({
                dateRangeInput("datesgraph1",label="Select date range to calculate performance metrics and save graphs",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
            })
            
            output$Streamflow1 <- renderUI({
                selectInput("StreamflowSelect1", "Streamflow Gauge",gauges,gauges[1])
            }) 
            output$daterange1 <- renderUI({
                dateRangeInput("dates1",label="Select date range to filter streamflow and water balance",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
             })
            
            output$GOFdaterange <- renderUI({
                 dateRangeInput("datest",label="Select date range to calculate performance metrics",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
            })
            
            output$sliders <- renderUI({ 
              if (file.exists(paste0("KeyModelInputs.csv")) && VAL$Model3==1){
                
                KeyEnsemble <-read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
                keys <- KeyEnsemble 
                
                pvars <- colnames(keys)[2:length(colnames(keys))]
                pvars1 <- gsub(":Annual Activity Level","",pvars,fixed = TRUE)
                selected <- as.character(keys[1,2:ncol(keys)])
                choices=NULL
                for (i in 2:ncol(keys)){
                  choices[i-1]=list(as.character(sort(unique(keys[,i]))))
                }
                
                lapply(seq(pvars), function(i) {
                  sliderTextInput(inputId = paste0("key", i),
                                  label = pvars1[i],
                                  animate=TRUE,
                                  grid = TRUE,
                                  choices=unlist(choices[i]),
                                  selected =selected[i]
                  )
                })
              } else {
                sliderTextInput(inputId = "SliderWB",
                                label = "No parameter combination is available, No Ensemble run",
                                animate=TRUE,
                                grid = TRUE,
                                choices="NA",
                                selected ="NA")
              }
            })
            
            output$sliders1 <- renderUI({ 
              if (file.exists(paste0("KeyModelInputs.csv")) && VAL$Model3==1){
                
                KeyEnsemble <-read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
                
                selectInput(
                  "SliderWB1",
                  "Run Number",
                  KeyEnsemble$Nrun,
                  selected = KeyEnsemble$Nrun[1]
                )
                
                
              } else {
                
                selectInput(
                  "SliderWB1",
                  "Run Number",
                  "1",
                  selected = "1"
                )
                
              }
            })
            
            }
          
          output$modelfolderout <- renderPrint({
          paste0("Selected WEAP model: ", modelfolder)
            })
          
        } else {
          VAL$Model=0
          
          output$modelfolderout <- renderPrint({
          "The WEAP model does not exist"
          })
        }
      
      rm(WEAP)
      gc()
      
      incProgress(1/2)
      
                   })
      
      
    })
    ###################################### 
    
    ###################################### 
    output$textRunEnsembleA <- renderText({
      outTxt = ""
      text=paste0("Press button to run. Run time will appear here when finished.")
      formatedFont = sprintf('<font color="%s">%s</font>',"red",text)
      outTxt = paste0(outTxt, formatedFont)
      outTxt
      })
    
    observeEvent(input$actionA,{ 
      try({
      Model=VAL$Model
      if (Model==1){
        start = Sys.time()
        req(input$srpercent)
        req(input$z1)
        req(input$z2)
        
        srpercent=as.numeric(input$srpercent)
        z1=as.numeric(input$z1)
        z2=as.numeric(input$z2)
        
        # srpercent=20
        # z1=30
        # z2=30
        
        withProgress(message = 'Calculation in progress',
                     detail = 'This may take a while...', value = 0, {
        
                       #run               
          ######################             
                       sy <- input$start
                       ey <- input$end
                       Warea <- input$warea
                       Scen <- input$Scen
                       ts <- input$ts
                       
                       RUNID=0
                       files=list.files(pattern ="Resultsk")
                       files1=list.files(pattern ="Results_Q_P_")
                       files2=list.files(pattern ="0_SummaryGOF_")
                       files3=list.files(pattern ="0_SummaryGOF2_")
                       files=c(files,files1,files2,files3,"0_ResultsGauges.csv",paste0(RUNID,"_",Scen,"_WaterBalance.csv"),paste0(RUNID,"_",Scen,"_ResultsGauges.csv"))
                       
                       if (length(files)>0){
                         fn=files
                         for (j in 1:length(fn)) {
                           if (file.exists(fn[j])) {
                             file.remove(fn[j])
                           }
                         }
                       }
                       
                       WEAP <- COMCreate("WEAP.WEAPApplication") 
                       
                       Sys.sleep(3)
                       WEAP[["ActiveArea"]] <- Warea
                       WEAP[["BaseYear"]] <- sy
                       WEAP[["EndYear"]] <- ey
                       WEAP[["Verbose"]] <- 0
                       
                       incProgress(1/5)
                       
                       sy=as.numeric(sy)+1
                       
                       WEAP[["ActiveScenario"]] <- "Current Accounts"
                       
                       C = "NumRun"  
                       var="\\Key\\"
                       res <- try(WEAP$Branch(var)$AddChild(C))
                       
                       C = "DaysTimeStep"  
                       var="\\Key\\"
                       res <- try(WEAP$Branch(var)$AddChild(C))
                       
                       var="Key\\NumRun:Annual Activity Level"
                       res <- try(WEAP$BranchVariable(var)[["Expression"]] <- 0)
                       
                       var="Key\\DaysTimeStep:Annual Activity Level"
                       res <- try(WEAP$BranchVariable(var)[["Expression"]] <- "days")
                       
                       #WEAPdays.csv
                       
                       incProgress(1/5)
                       
                       WEAP$DeleteResults()
                       
                       Sys.sleep(3)
                       
                       WEAP[["ActiveScenario"]] <- Scen
                       
                       WEAP$Calculate() 
                       
                       Sys.sleep(3)
                       
                       incProgress(1/5)
                       
                       
                       dir_outg = VAL$dir_outg
                       
                       
                       files=c(paste0(RUNID,"_",Scen,"_WaterBalance.csv"),paste0(RUNID,"_",Scen,"_ResultsGauges.csv"),"WEAPKeyGaugeBranches.csv","WEAPKeyGaugesCatchments.csv","WEAPdays.csv")
                       current.folder <- paste0(WEAP$AreasDirectory(),Warea)
                       new.folder <- dir_outg
                       list.of.files <- list.files(files)
                       file.copy(paste0(current.folder,"/",files), new.folder, overwrite =TRUE)
                       
                       fn=paste0(current.folder,"/",c(files))
                       for (j in 1:length(fn)) {
                         if (file.exists(fn[j])) {
                           file.remove(fn[j])
                         }
                       }
                       
                       KeyGaugesCatchments=read.csv("WEAPKeyGaugesCatchments.csv", stringsAsFactors=F, check.names=F)
                       uniqueGauges=sort(unique(KeyGaugesCatchments$Gauge))
                       
                       resultsWBG=read.csv(paste0(RUNID,"_",Scen,"_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
                       cols=c("Year",
                              "Time step",
                              "Gauge",
                              "Observed",
                              "Modeled"
                       )
                       #str(resultsWBG)
                       resultsWBG=resultsWBG[,cols]
                       
                       resultsWBC=read.csv(paste0(RUNID,"_",Scen,"_WaterBalance.csv"), stringsAsFactors=F, check.names=F)
                       cols=c("Year",
                              "Time step",
                              "Catchment",
                              "Precipitation",
                              "Evapotranspiration",
                              "Surface_Runoff",
                              "Interflow",
                              "Base_Flow",
                              "Decrease in Soil Moisture",
                              "Increase in Soil Moisture",
                              "Decrease in Surface Storage",
                              "Increase in Surface Storage",
                              "Area"
                       )
                       resultsWBC=resultsWBC[,cols]
                       
                       
                       resultsWBG[resultsWBG==-9999]= NA
                       resultsWBC[resultsWBC==-9999]= NA
                       resultsWBG[resultsWBG$Observed==0,"Observed"]= NA
                       
                       cols=c("Year",
                               "Time step",
                               "Gauge",
                               "Observed",
                               "Modeled",
                               "Precipitation",
                               "Evapotranspiration",
                               "Surface_Runoff",
                               "Interflow",
                               "Base_Flow",
                               "Decrease in Soil Moisture",
                               "Increase in Soil Moisture",
                               "Decrease in Surface Storage",
                               "Increase in Surface Storage",
                               "Area"
                       )
                       
                       resultsWB=NULL
                       g=1
                       for (g in 1:length(uniqueGauges)){ 
                         
                         NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
                         
                         
                         f=is.element(resultsWBC$Catchment,NamecatchG)
                         resultsWBC_g= resultsWBC[which(f==TRUE),]
                         resultsWBC_g=aggregate(resultsWBC_g[,4:ncol(resultsWBC_g)],list(Year=resultsWBC_g$Year,`Time step`=resultsWBC_g$`Time step`),sum, na.rm=TRUE)
                         resultsWBC_g$Gauge=uniqueGauges[g]
                         
                         
                         f=is.element( resultsWBG$Gauge,uniqueGauges[g])
                         resultsWB_g= resultsWBG[which(f==TRUE),]
                         
                         #str(resultsWBC_g)
                         #str(resultsWB_g)
                         resultsWBC_g1=merge(resultsWBC_g,resultsWB_g,by = c("Year","Time step","Gauge"))
                         
                         resultsWBC_g1=resultsWBC_g1[,cols]
                         #str(resultsWBC_g1)
                         resultsWBC_g1=resultsWBC_g1[order(resultsWBC_g1$Gauge,resultsWBC_g1$Year,resultsWBC_g1$`Time step`),]
                         resultsWB=rbind(resultsWB,resultsWBC_g1)
                         
                       }
                       
                       days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                       days1=unique(resultsWB[,c("Year","Time step")])
                       days=merge(days,days1,by="Time step")
                       days=days[order(days$Year,days$`Time step`),]
                       days$Dates=NA
                       days$Dates=as.Date(days$Dates)      
                       days$Dates[1]=as.Date(paste0(days$Year[1],"/01/01"))
                       days$Dates=as.Date(days$Dates)      
                       for (d in 2:nrow(days)) {
                         drow=as.Date(days$Dates[d-1]+days$Days[d-1])
                         if ((month(as.Date(days$Dates[d-1]+days$Days[d-1]))*100+day(as.Date(days$Dates[d-1]+days$Days[d-1])))==229){
                           days$Dates[d]=as.Date(days$Dates[d-1]+days$Days[d-1]+1)
                         }else {
                           days$Dates[d]=as.Date(days$Dates[d-1]+days$Days[d-1])
                         }
                         if(year(days$Dates[d])!=days$Year[d]){
                           days$Dates[d]=as.Date(paste0(days$Year[d],"/12/31"))
                         }
                         
                       }
                       days$Dates=as.Date(days$Dates)      
                       rownames(days)=NULL  
                       
                       incProgress(1/5)
                       
                       resultsWB = merge(resultsWB,days,by=c("Year","Time step"))
                       resultsWB = resultsWB[order(resultsWB$Gauge,resultsWB$Dates),]
                       write.csv(resultsWB,paste0("0_ResultsGauges.csv"),row.names=F) 
                       
                       files=c(paste0(RUNID,"_",Scen,"_WaterBalance.csv"),paste0(RUNID,"_",Scen,"_ResultsGauges.csv"))
                       
                       if (length(list.of.files)>0){
                         fn=files
                         for (j in 1:length(fn)) {
                           if (file.exists(fn[j])) {
                             file.remove(fn[j])
                           }
                         }
                       }
                       
                       #file <- resultsWB
                       #ResultsGauges=read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
                       ResultsGauges$Dates=ymd(ResultsGauges$Dates)
                       ResultsGauges$Precipitation<- ResultsGauges$Precipitation/ResultsGauges$Area*1000
                       ResultsGauges$Observed <- ResultsGauges$Observed/ResultsGauges$Area*1000
                       
                       ResultsGaugesa <- aggregate(ResultsGauges[,c("Observed","Precipitation")], by=list(Gauge=ResultsGauges$Gauge, Year=ResultsGauges$Year),sum,na.rm=F)
                       ResultsGaugesa$Q_P=round(ResultsGaugesa$Observed/ResultsGaugesa$Precipitation*100,2)
                    
                       ResultsGaugess <- aggregate(ResultsGaugesa[,c("Q_P"),drop=FALSE], by=list(Gauge=ResultsGaugesa$Gauge),mean,na.rm=TRUE)
                       colnames(ResultsGaugess)=c("Gauge","Q_P mean")
                       ResultsGaugesa=merge(ResultsGaugesa,ResultsGaugess,by="Gauge")
                       
                       Dates=seq(as.Date(paste0(year(min(ResultsGauges$Dates)),"-01-01")), to=as.Date(paste0(year(max(ResultsGauges$Dates)),"-12-31")),by="year")
                       Dates=as.data.frame(Dates)
                       Dates$Year=year(Dates$Dates)
                       ResultsGaugesa=merge(ResultsGaugesa,Dates,by="Year")
                       
                       ResultsGaugesa=ResultsGaugesa[,c( "Gauge" ,"Year",  "Dates","Observed","Precipitation", "Q_P","Q_P mean")]  
                       
                       write.csv(ResultsGaugesa,paste0("0_Results_Q_P_AnnualSummary.csv"),row.names=F) 

                       #WEAP$SaveArea()
                       rm(WEAP)
                       gc()
                       
          ######################           
                       starty <- min(ResultsGaugesa$Dates)
                       endy <- max(ResultsGaugesa$Dates)
                       gauges=sort(unique(ResultsGaugesa$Gauge))
                      
                       
        output$textRunEnsembleA <- renderText({
          outTxt = ""
          text=paste0("Run finished. Total run Time: ")
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          
          text=format(as.difftime(difftime(Sys.time(),start), format = "%H:%M")) 
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          
          outTxt
          
          
        })
        output$textRunEnsembleA1 <- renderText({
          outTxt = ""
          text=paste0("Results imported and saved within ",VAL$dir_outg)
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          
          
          outTxt
          
        })
        output$StreamflowA <- renderUI({
          selectInput("StreamflowSelectA", "Streamflow Gauge",gauges,selected = gauges[1])
        })
        output$daterangei <- renderUI({
          dateRangeInput("datesi",label="Select date range to filter streamflow and water balance",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
        })
        output$daterangegraphi <- renderUI({
          
          dateRangeInput("datesgraphi",label="Select date range to calculate performance metrics and save graphs",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
          
        })
        
        try({
          
        if (file.exists(paste0("0_ResultsGauges.csv")) && Model==1) {
          
          #gs=unique(ResultsGaugesa$Gauge)[1] 
          gs=gauges[1]
          
          ResultsGauges=read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
          ResultsGauges$Dates=ymd(ResultsGauges$Dates)
          ResultsGauges$Precipitation<- ResultsGauges$Precipitation/ResultsGauges$Area*1000
          ResultsGauges$Observed <- ResultsGauges$Observed/ResultsGauges$Area*1000
          
          Dates=seq(as.Date(paste0(year(min(ResultsGauges$Dates)),"-01-01")), to=as.Date(paste0(year(max(ResultsGauges$Dates)),"-12-31")),by="year")
          Dates=as.data.frame(Dates)
          Dates$Year=year(Dates$Dates)
          
          ResultsGaugesa <- aggregate(ResultsGauges[,c("Observed","Precipitation")], by=list(Gauge=ResultsGauges$Gauge, Year=ResultsGauges$Year),sum,na.rm=F)
          ResultsGaugesa$Q_P=round(ResultsGaugesa$Observed/ResultsGaugesa$Precipitation*100,2)
          ResultsGaugesa$Gauge=as.factor(ResultsGaugesa$Gauge)
          
          output$Q_Pboxplot <- renderPlotly({
            
            text=paste0("Annual Observed streamflow/Precipitation (%)")
            
            p <-plot_ly(ResultsGaugesa, x = ~Gauge, y = ~Q_P, color= ~Gauge,type="box")  %>% 
              layout( title = text,
                      xaxis = list(title=""),
                      yaxis = list(title= "Observed streamflow/Precipitation (%)"))
            p
          }) 
          
          output$Q_Panual <- renderPlotly({
            ResultsGaugesa=ResultsGaugesa[ResultsGaugesa$Gauge==gs,]
            ResultsGaugesa=merge(ResultsGaugesa,Dates,by="Year")
            text=paste0(gs," - Annual Observed streamflow and Precipitation (mm)")
            p <-plot_ly(ResultsGaugesa, x=~Dates, y=~Precipitation, name = "Precipitation", type="bar",text=~paste0("Precipitation = ", Precipitation)) %>%
              add_trace(x = ~Dates,y=~Observed, name="Observed Streamflow", type="scatter", mode="line", text=~paste0("Observed = ", Observed)) %>%
              add_trace(x = ~Dates, y = ~Q_P, name = "% Observed streamflow/Precipitation", type="scatter", mode="line", text=~paste0("% Observed streamflow/Precipitation = ", Q_P), yaxis = "y2") %>%
              layout(yaxis2 = list(overlaying = "y", side = "right", title = "Observed streamflow/Precipitation (%)"), 
                     title = text,
                     xaxis = list(title="Dates"),
                     yaxis = list(title= "Observed streamflow and Precipitation (mm)"))
            p
            
            
          })
          
        }
        })
        try({
            if (file.exists(paste0("0_ResultsGauges.csv")) && Model==1) {
              
              obs <- read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
              cols=c("Year",
                     "Time step",
                     "Gauge",
                     "Observed",
                     "Area",
                     "Dates")
              obs=obs[,cols]
              
              table <- data.frame(matrix(NA,ncol=3, nrow=length(unique(obs$Gauge))))
              colnames(table)=c("Gauge","Ks, top bucket","Kd, bottom bucket")
              
              
              for (i in 1:length(unique(obs$Gauge))){
                
                table[i,1]=unique(obs$Gauge)[i]
                
                flows=obs[obs$Gauge==unique(obs$Gauge)[i],]
                flows$Dates <- ymd(flows$Dates)
                
                high <- max(flows$Observed,na.rm=T) 
                low <- min(flows$Observed,na.rm=T) 
                if (low==0){
                  low <- unique(sort(na.exclude(flows$Observed)))[2] 
                }
                
                outflow <- high-low 
                sr <- outflow*(as.numeric(srpercent)/100)
                interflow <- outflow-sr 
                
                interflowd <- interflow/unique(flows$Area)*1000 
                ks <- interflowd/(as.numeric(z1)/100)^2 
                
                bfdepth <- low/unique(flows$Area)*1000 
                kd <- bfdepth/(as.numeric(z2)/100)^2 
                
                table[i,2] <- round(ks,2) 
                table[i,3] <- round(kd,2) 
                
              }
              
              write.csv(table[order(table$Gauge),],paste0("0_Resultsk_Summary","-DSR",srpercent,"-Z1",z1,"-Z2",z2,".csv"),row.names=F) 
              
              list=list.files(getwd(),pattern = "0_Resultsk_Summary-DSR")
              list
              list1=list
              list1=gsub(".csv","",list1,fixed = TRUE)
              list1=gsub("0_Resultsk_Summary-","",list1,fixed = TRUE)
              
              file1=NULL
              for (i in 1:length(list)){
                
                file <- read.csv(paste0("",list[i]), stringsAsFactors=F, check.names=F)
                file$Parameters=list1[i]
                file1=rbind(file1,file)
              }
              
              file1=file1[order(file1$Gauge),]
              write.csv(file1,paste0("0_Resultsk_SummaryALL.csv"),row.names=F) 
              
              output$textRunEnsembleAConduc <- renderText({ 
                
                outTxt = ""
                text=paste0("Initial Conductivity was calculated for "," DSR: ",srpercent," Z1: ",z1," Z2: ",z2, ". Check the Results folder: ", VAL$dir_outg) 
                formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                outTxt = paste0(outTxt, formatedFont)
                
                outTxt
                
              })
              
              output$textRunEnsembleAConduc1 <- renderText({ 
                
                outTxt = ""
                text=paste0("Conductivity:"," DSR: ",srpercent," Z1: ",z1," Z2: ",z2) 
                formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                outTxt = paste0(outTxt, formatedFont)
                
                outTxt
                
              })
              
              output$kestimate <- DT::renderDataTable({
                table=table[order(table$Gauge),]
                DT::datatable(table, rownames= FALSE)
                
              })
              
              file <- table
              file$Gauge=as.factor(file$Gauge)
              colnames(file)=c("Gauge", "ks", "Kd")
              
              output$kestimateGraphks <- renderPlotly({
                
                text=paste0("ks, top bucket conductivity "," DSR:",srpercent,"% Z1:",z1,"% Z2:",z2,"%")
                #text=""
                p1 <-plot_ly(file, x=~Gauge, y=~ks, type="bar",color = ~Gauge) %>%
                  layout(title =text ,
                         xaxis = list(title=""),
                         yaxis = list(title= "ks (mm)"))
                p1
                
              })
              
              output$kestimateGraphkd <- renderPlotly({
                
                text=paste0("kd, bottom bucket conductivity "," DSR:",srpercent,"% Z1:",z1,"% Z2:",z2,"%")
                #text=""
                p1 <-plot_ly(file, x=~Gauge, y=~ks, type="bar",color = ~Gauge) %>%
                  layout(title =text ,
                         xaxis = list(title=""),
                         yaxis = list(title= "ks (mm)"))
                p1
                
                
              })
            }
          }) 
        
        
        VAL$Model1=1
        
        incProgress(1/5)
        
                     })
        }
      })               
    })
    
    observeEvent(input$StreamflowSelectA,{
      gs=input$StreamflowSelectA
      req(input$StreamflowSelectA)
      Model=VAL$Model1
      try({
        
        if (file.exists(paste0("0_ResultsGauges.csv")) && Model==1) {
          
          ResultsGauges=read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
          ResultsGauges$Dates=ymd(ResultsGauges$Dates)
          ResultsGauges$Precipitation<- ResultsGauges$Precipitation/ResultsGauges$Area*1000
          ResultsGauges$Observed <- ResultsGauges$Observed/ResultsGauges$Area*1000
          
          Dates=seq(as.Date(paste0(year(min(ResultsGauges$Dates)),"-01-01")), to=as.Date(paste0(year(max(ResultsGauges$Dates)),"-12-31")),by="year")
          Dates=as.data.frame(Dates)
          Dates$Year=year(Dates$Dates)
          
          ResultsGaugesa <- aggregate(ResultsGauges[,c("Observed","Precipitation")], by=list(Gauge=ResultsGauges$Gauge, Year=ResultsGauges$Year),sum,na.rm=F)
          ResultsGaugesa$Q_P=round(ResultsGaugesa$Observed/ResultsGaugesa$Precipitation*100,2)
          ResultsGaugesa$Gauge=as.factor(ResultsGaugesa$Gauge)
          
          output$Q_Pboxplot <- renderPlotly({
            
            text=paste0("Annual Observed streamflow/Precipitation (%)")
            
            p <-plot_ly(ResultsGaugesa, x = ~Gauge, y = ~Q_P, color= ~Gauge,type="box")  %>% 
              layout( title = text,
                      xaxis = list(title=""),
                      yaxis = list(title= "Observed streamflow/Precipitation (%)"))
            p
          }) 
          
         
          
          output$Q_Panual <- renderPlotly({
            ResultsGaugesa=ResultsGaugesa[ResultsGaugesa$Gauge==gs,]
            ResultsGaugesa=merge(ResultsGaugesa,Dates,by="Year")
            
            text=paste0(gs," - Annual Observed streamflow and Precipitation (mm)")
            p <-plot_ly(ResultsGaugesa, x=~Dates, y=~Precipitation, name = "Precipitation", type="bar",text=~paste0("Precipitation = ", Precipitation)) %>%
              add_trace(x = ~Dates,y=~Observed, name="Observed Streamflow", type="scatter", mode="line", text=~paste0("Observed = ", Observed)) %>%
              add_trace(x = ~Dates, y = ~Q_P, name = "% Observed streamflow/Precipitation", type="scatter", mode="line", text=~paste0("% Observed streamflow/Precipitation = ", Q_P), yaxis = "y2") %>%
              layout(yaxis2 = list(overlaying = "y", side = "right", title = "Observed streamflow/Precipitation (%)"), 
                     title = text,
                     xaxis = list(title="Dates"),
                     yaxis = list(title= "Observed streamflow and Precipitation (mm)"))
            p
            
            
          })
          
        }
      })
    })
    
    observeEvent(input$actionCond,{
      
      Model=VAL$Model1
      req(input$srpercent)
      req(input$z1)
      req(input$z2)
      
      srpercent=as.numeric(input$srpercent)
      z1=as.numeric(input$z1)
      z2=as.numeric(input$z2)
      
      # srpercent=20
      # z1=30
      # z2=30

      try({
        if (file.exists(paste0("0_ResultsGauges.csv")) && Model==1) {
          
          obs <- read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
          cols=c("Year",
                 "Time step",
                 "Gauge",
                 "Observed",
                 "Area",
                 "Dates")
          obs=obs[,cols]
          
          table <- data.frame(matrix(NA,ncol=3, nrow=length(unique(obs$Gauge))))
          colnames(table)=c("Gauge","Ks, top bucket","Kd, bottom bucket")
          
          
          for (i in 1:length(unique(obs$Gauge))){
            
            table[i,1]=unique(obs$Gauge)[i]
            
            flows=obs[obs$Gauge==unique(obs$Gauge)[i],]
            flows$Dates <- ymd(flows$Dates)
            
            high <- max(flows$Observed,na.rm=T) 
            low <- min(flows$Observed,na.rm=T) 
            if (low==0){
              low <- unique(sort(na.exclude(flows$Observed)))[2] 
            }
            
            outflow <- high-low 
            sr <- outflow*(as.numeric(srpercent)/100)
            interflow <- outflow-sr 
            
            interflowd <- interflow/unique(flows$Area)*1000 
            ks <- interflowd/(as.numeric(z1)/100)^2 
            
            bfdepth <- low/unique(flows$Area)*1000 
            kd <- bfdepth/(as.numeric(z2)/100)^2 
            
            table[i,2] <- round(ks,2) 
            table[i,3] <- round(kd,2) 
            
          }
          
          write.csv(table[order(table$Gauge),],paste0("0_Resultsk_Summary","-DSR",srpercent,"-Z1",z1,"-Z2",z2,".csv"),row.names=F) 
          
          list=list.files(getwd(),pattern = "0_Resultsk_Summary-DSR")
          list
          list1=list
          list1=gsub(".csv","",list1,fixed = TRUE)
          list1=gsub("0_Resultsk_Summary-","",list1,fixed = TRUE)
          
          file1=NULL
          for (i in 1:length(list)){
            
            file <- read.csv(paste0("",list[i]), stringsAsFactors=F, check.names=F)
            file$Parameters=list1[i]
            file1=rbind(file1,file)
          }
          
          file1=file1[order(file1$Gauge),]
          write.csv(file1,paste0("0_Resultsk_SummaryALL.csv"),row.names=F) 
          
          output$textRunEnsembleAConduc <- renderText({ 
            
            outTxt = ""
            text=paste0("Initial Conductivity was calculated for "," DSR: ",srpercent," Z1: ",z1," Z2: ",z2, ". Check the Results folder: ", VAL$dir_outg) 
            formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
            outTxt = paste0(outTxt, formatedFont)
            
            outTxt
            
          })
          
          output$textRunEnsembleAConduc1 <- renderText({ 
            
            outTxt = ""
            text=paste0("Conductivity:"," DSR: ",srpercent," Z1: ",z1," Z2: ",z2) 
            formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
            outTxt = paste0(outTxt, formatedFont)
            
            outTxt
            
          })
          
          output$kestimate <- DT::renderDataTable({
            table=table[order(table$Gauge),]
            DT::datatable(table, rownames= FALSE)
            
          })
          
          file <- table
          file$Gauge=as.factor(file$Gauge)
          colnames(file)=c("Gauge", "ks", "Kd")
          
          output$kestimateGraphks <- renderPlotly({
            
            text=paste0("ks, top bucket conductivity "," DSR:",srpercent,"% Z1:",z1,"% Z2:",z2,"%")
            #text=""
            p1 <-plot_ly(file, x=~Gauge, y=~ks, type="bar",color = ~Gauge) %>%
              layout(title =text ,
                     xaxis = list(title=""),
                     yaxis = list(title= "ks (mm)"))
            p1
            
          })
          
          output$kestimateGraphkd <- renderPlotly({
            
            text=paste0("kd, bottom bucket conductivity "," DSR:",srpercent,"% Z1:",z1,"% Z2:",z2,"%")
            #text=""
            p1 <-plot_ly(file, x=~Gauge, y=~ks, type="bar",color = ~Gauge) %>%
              layout(title =text ,
                     xaxis = list(title=""),
                     yaxis = list(title= "ks (mm)"))
            p1
            
            
          })
        }
      }) 
      
    })
    
    observeEvent(input$graphsi,{ 
      
      Model=VAL$Model1
      if (Model==1){
        start = Sys.time()
        
        withProgress(message = 'Calculation in progress',
                     detail = 'This may take a while...', value = 0, {
                       
                       RUNID=0
                       Warea <- input$warea
                       Scen <- input$Scen
                       ts <- input$ts
                       Titles=input$titlesgi
                       yearINI=input$datesgraphi[1]
                       ey <-input$datesgraphi[2]
                       dir=VAL$dir_outg
                       
                       # Titles="Spanish" #English
                       # file=read.csv(paste0("0_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
                       # yearINI= file$Dates[1]
                       # ey= file$Dates[nrow(file)]
                       # dir=paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/Results ",Warea)

                       if (Titles=="Spanish"){
                         xtext="Fecha"
                       }else if (Titles=="English") {
                         xtext="Date"
                       }
                       
                       dates=c(ymd(as.Date(yearINI)),ymd(as.Date(ey)))
                       
                       multiplot = function(..., plotlist=NULL, file, cols=1, layout=NULL) {
                         # Multiple plot function
                         #
                         # ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
                         # - cols:   Number of columns in layout
                         # - layout: A matrix specifying the layout. If present, 'cols' is ignored.
                         #
                         # If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
                         # then plot 1 will go in the upper left, 2 will go in the upper right, and
                         # 3 will go all the way across the bottom.
                         #
                         library(grid)
                         
                         # Make a list from the ... arguments and plotlist
                         plots = c(list(...), plotlist)
                         
                         numPlots = length(plots)
                         
                         # If layout is NULL, then use 'cols' to determine layout
                         if (is.null(layout)) {
                           # Make the panel
                           # ncol: Number of columns of plots
                           # nrow: Number of rows needed, calculated from # of cols
                           layout = matrix(seq(1, cols * ceiling(numPlots/cols)),
                                           ncol = cols, nrow = ceiling(numPlots/cols))
                         }
                         
                         if (numPlots==1) {
                           print(plots[[1]])
                           
                         } else {
                           # Set up the page
                           grid.newpage()
                           pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
                           
                           # Make each plot, in the correct location
                           for (i in 1:numPlots) {
                             # Get the i,j matrix positions of the regions that contain this subplot
                             matchidx = as.data.frame(which(layout == i, arr.ind = TRUE))
                             
                             print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                                             layout.pos.col = matchidx$col))
                           }
                         }
                       }
                       start = Sys.time()
                       
                       errorEvaluar=c(
                         1, #1.	me, Mean Error
                         2, #2.	mae, Mean Absolute Error
                         # 3, #3.	mse, Mean Squared Error
                         # 4, #4.	rmse, Root Mean Square Error
                         5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
                         6, #6.	PBIAS, Percent Bias
                         # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
                         # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
                         9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
                         10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
                         # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
                         12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
                         13,  #13.	md, Modified Index of Agreement 
                         # 14,#14.	rd, Relative Index of Agreement
                         # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
                         # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
                         17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
                         18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
                         19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
                         20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
                       ) 
                       names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                                     "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                                     "KGE" ,    "VE" ) 
                       names_errorg=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE" ,"PBIAS", "RSR"   ,  "rSD"  ,   "NSE" ,   
                                      "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                                      "KGE" ,    "VE" ) 
                       #names_error[errorEvaluar]
                       
                       
                       ################################################################################################
                       names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 
                       metricsALL=NULL
                       setwd(dir)
                       
                       file=read.csv("0_ResultsGauges.csv", stringsAsFactors=F, check.names=F)
                       file$Dates=ymd(file$Dates)
                       file$YearMonth=year(file$Dates)*100+month(file$Dates)
                       file$Month=month(file$Dates)
                       
                       fileOrg=file
                       
                       
                       total <-length(unique(file$Gauge))
                       truns=total+2
                       
                       incProgress(1/truns)
                       
                       filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]
                       days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                       filesub1=filesub
                       
                       if (Titles=="Spanish"){
                         text=paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)")
                         
                       }else if (Titles=="English") {
                         text=paste0("Time serie: ","Modeled (blue) vs Observed (red)")
                         
                       }
                       
                       filesub1$Observed=filesub1$Observed/filesub1$Days/86400
                       filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400
                       p <- ggplot(filesub1, aes(x=Dates, y=Modeled)) + 
                         geom_line(color="blue",size=0.2)+
                         geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                         facet_wrap( ~ Gauge, scales = "free") +
                         ylab(paste0("[m3/s]"))+
                         xlab(xtext)+
                         ggtitle(text)
                       p
                       
                       plotpath = paste0(RUNID,"_Time series_sim vs obs_",paste(dates,collapse ="-"),".jpg") #creates a pdf path to produce a graphic of the span of records in the Data
                       ggsave(plotpath,width =40 , height = 22,units = "cm")
                       
                       ################################################################################################
                       runTimeGOF=difftime(Sys.time(),start)
                       runTimeGOF
                       
                       #procesaar graficas y GOF
                       ###############################################################################################
                       metricsALL <- NULL
                       setwd(dir)
                       
                       file=fileOrg
                       names=sort(unique(file$Gauge))
                       total <-length(unique(file$Gauge))
                       pbi=0
                       f=0
                       
                       #Graficas
                       ##################
                       setwd(dir)
                       Carpeta_Out=paste0(f,"_Graphs_",paste(dates,collapse ="-"))
                       dir.create(Carpeta_Out,showWarnings=F)
                       dir_file=paste(c(dir,"\\",Carpeta_Out),collapse="")
                       
                       year1 = yearINI
                       year2= ey
                       
                       RUNID=f
                       
                       file$Dates=ymd(file$Dates)
                       file$YearMonth=year(file$Dates)*100+month(file$Dates)
                       file$Month=month(file$Dates)
                       filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]
                       
                       days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                       #filesub=merge(filesub,days,by="Time step")
                       
                       days$Dates=NA
                       days$Dates[1]=as.Date("1981/01/01")
                       for (d in 2:nrow(days)) {
                         days$Dates[d]=days$Dates[d-1]+days$Days[d-1]
                       }
                       days$Dates=as.Date(days$Dates)
                       
                       filesub1=filesub
                       filesub1$Observed=filesub1$Observed/filesub1$Days/86400
                       filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400
                       
                       obsFile=filesub1[,c("Time step","Dates","Gauge","Observed")]
                       simFile=filesub1[,c("Time step","Dates","Gauge","Modeled")]
                       obsFile = obsFile %>% pivot_wider(names_from = Gauge, values_from = Observed)
                       simFile = simFile %>% pivot_wider(names_from = Gauge, values_from = Modeled)
                       obsFile=obsFile[order(obsFile$Dates),]
                       simFile=simFile[order(simFile$Dates),]
                       
                       GofGrafica=names_errorg[errorEvaluar]
                       GofTabla=names_error[errorEvaluar]
                       
                       obsv=as.data.frame(obsFile[,names])
                       simv=as.data.frame(simFile[,names])
                       
                       setwd(dir_file)
                       Carpeta_Out="SimObs_All"
                       dir.create(Carpeta_Out,showWarnings=F)
                       dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                       setwd(dir_file1)
                       
                       
                       filesub1=filesub1[,c("Time step","Dates","Gauge","Modeled","Observed","Year")]
                       
                       if (Titles=="Spanish"){
                         text=paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)")
                         
                       }else if (Titles=="English") {
                         text=paste0("Time serie: ","Modeled (blue) vs Observed (red)")
                         
                       }
                       
                       p <- ggplot(filesub1, aes(x=Dates, y=Modeled)) + 
                         geom_line(color="blue",size=0.2)+
                         geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                         facet_wrap( ~ Gauge, scales = "free") +
                         ylab(paste0("[m3/s]"))+
                         xlab(xtext)+
                         ggtitle(text)
                       p
                       
                       ggsave("TimeSeries.jpg",width =40 , height = 22,units = "cm")
                       
                       try({
                         filesub1$monthyear=floor_date(filesub1$Dates, "month")
                         filesub1 <- filesub1[order(filesub1$Gauge,filesub1$Dates),]
                         
                         df=filesub1
                         df_d=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, `Time step`=df$`Time step`),mean, na.rm=TRUE)
                         df_d=df_d[order(df_d$Gauge,df_d$`Time step`),]
                         
                         write.csv(df_d,"MultiannualTimeStepMean_LongFormat.csv",row.names=FALSE,na="")
                         
                         df_d = merge(df_d,days,by="Time step")
                         df_d=df_d[order(df_d$Gauge,df_d$Dates),]
                         #dfsim_d$date = format(dfsim_d$date, "%b %d")
                         
                         if (ts==365){
                           
                           if (Titles=="Spanish"){
                             text=paste0("Promedio Diario Multianual: ","Modelado (azul) vs Observado (rojo)")
                           }else if (Titles=="English") {
                             text=paste0("Multiannual Daily Mean: ","Modeled (blue) vs Observed (red)")
                           }
                           
                         } else {
                           if (Titles=="Spanish"){
                             text=paste0("Promedio a paso de tiempo Multianual: ","Modelado (azul) vs Observado (rojo)")
                           }else if (Titles=="English") {
                             text=paste0("Multiannual Time Step Mean: ","Modeled (blue) vs Observed (red)")
                           }
                           
                         }
                         
                         
                         p <- ggplot(df_d, aes(x=Dates, y=Modeled)) + 
                           geom_line(color="blue",size=0.2)+
                           geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                           facet_wrap( ~ Gauge, scales = "free") +
                           ylab(paste0("[m3/s]"))+
                           xlab(xtext)+
                           ggtitle(text)
                         p= p + scale_x_date(date_labels = "%b/%d")
                         p
                         ggsave("Multiannual time step Mean.jpg",width =40 , height = 22,units = "cm")
                       })  
                       
                       try({
                         df=filesub1
                         df_m=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, monthyear=df$monthyear),mean, na.rm=TRUE)
                         df_m$month <- month(df_m$monthyear)
                         df_m=aggregate(df_m[,c("Modeled","Observed")],list(Gauge=df_m$Gauge, month=df_m$month),mean, na.rm=TRUE)
                         df_m=df_m[order(df_m$Gauge,df_m$month),]
                         write.csv(df_m,"MultiannualMonthlyMean_LongFormat.csv",row.names=FALSE,na="")
                         
                         Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                         Dates=as.data.frame(Dates)
                         Dates$month=month(Dates$Dates)
                         
                         df_m = merge(df_m,Dates,by="month")
                         df_m=df_m[order(df_m$Gauge,df_m$month),]
                         
                         if (Titles=="Spanish"){
                           text=paste0("Promedio Mensual Multianual: ","Modelado (azul) vs Observado (rojo)")
                           
                         }else if (Titles=="English") {
                           text=paste0("Multiannual Monthly Mean: ","Modeled (blue) vs Observed (red)")
                           
                         }
                         
                         p <- ggplot(df_m, aes(x=Dates, y=Modeled)) + 
                           geom_line(color="blue",size=0.2)+
                           geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                           facet_wrap( ~ Gauge, scales = "free") +
                           ylab(paste0("[m3/s]"))+
                           xlab(xtext)+
                           ggtitle(text)
                         p= p + scale_x_date(date_labels = "%B")
                         p 
                         ggsave("Multiannual Monthly Mean.jpg",width =40 , height = 22,units = "cm")
                         
                       })
                       
                       try({
                         df=filesub1
                         df_m=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, Year=df$Year),mean, na.rm=TRUE)
                         df_m=df_m[order(df_m$Gauge,df_m$Year),]
                         write.csv(df_m,"AnnualMean_LongFormat.csv",row.names=FALSE,na="")
                         
                         Dates=seq(as.Date(paste(c(min(df_m$Year),"/",01,"/",01),collapse="")),as.Date(paste(c(max(df_m$Year),"/",12,"/",31),collapse="") ), by = "year")
                         Dates=as.data.frame(Dates)
                         Dates$Year=year(Dates$Dates)
                         
                         df_m = merge(df_m,Dates,by="Year")
                         df_m=df_m[order(df_m$Gauge,df_m$Year),]
                         
                         if (Titles=="Spanish"){
                           text=paste0("Promedio Anual: ","Modelado (azul) vs Observado (rojo)")
                           
                         }else if (Titles=="English") {
                           text=paste0("Annual Mean: ","Modeled (blue) vs Observed (red)")
                           
                         }
                         
                         p <- ggplot(df_m, aes(x=Dates, y=Modeled)) + 
                           geom_line(color="blue",size=0.2)+
                           geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                           facet_wrap( ~ Gauge, scales = "free") +
                           ylab(paste0("[m3/s]"))+
                           xlab(xtext)+
                           ggtitle(text)
                         p= p + scale_x_date(date_labels = "%B")
                         p 
                         ggsave("Multiannual Monthly Mean.jpg",width =40 , height = 22,units = "cm")
                       })
                       
                       ##################
                       i=1
                       for (i in 1:length(names)){
                         
                         name <- names[i]
                         pbi=pbi+1
                         
                         incProgress(1/truns)
                         print(paste0(pbi," of ",total)) #," Estacion ", name
                         
                         if (length(which(is.na(obsv[,i])==TRUE))<length(obsv[,i])){
                           
                           obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                           sim = zoo(simv[,i],as.Date(simFile$Dates))
                           
                           if (ts==12){
                             
                             try({
                               setwd(dir_file)
                               Carpeta_Out="SimObs_ma"
                               dir.create(Carpeta_Out,showWarnings=F)
                               dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                               setwd(dir_file1)
                               png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                               ggof(sim=sim, obs=obs, ftype="ma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                               #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                               dev.off()
                             })
                             
                           } else if (ts==365){
                             
                             try({
                               setwd(dir_file)
                               Carpeta_Out="SimObs_dma"
                               dir.create(Carpeta_Out,showWarnings=F)
                               dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                               setwd(dir_file1)
                               png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                               ggof(sim=sim, obs=obs, ftype="dma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                               #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                               dev.off()
                             })
                             
                             try({
                               setwd(dir_file)
                               Carpeta_Out="SimObs_seasons"
                               dir.create(Carpeta_Out,showWarnings=F)
                               dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                               setwd(dir_file1)
                               png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                               ggof(sim=sim, obs=obs, ftype="seasonal", season.names=c("", "", "", ""),na.rm=TRUE,FUN=mean, leg.cex=1.2, pch = c(20, 18),main = name, ylab=c("Q[m3/s]"))
                               dev.off()
                             })
                             
                             
                           } 
                           
                           try({
                             setwd(dir_file)
                             Carpeta_Out="SimObs_original"
                             dir.create(Carpeta_Out,showWarnings=F)
                             dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                             setwd(dir_file1)
                             png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                             ggof(sim=sim, obs=obs, FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), xlab=xtext,pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                             #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                             dev.off()
                           })
                           
                           try({   
                             if (ts==365){
                               df <- data.frame(date = as.Date(simFile$Dates), Gauge = simv[,i],timestep=simFile$`Time step`)
                               df$monthyear=floor_date(df$date, "month")
                               
                               df_d=as.data.frame(df %>%
                                                    group_by(timestep) %>%
                                                    summarize(mean = mean(Gauge ,na.rm = TRUE)))
                               
                               
                               df_d = merge(df_d,days,by.x="timestep",by.y = "Time step")
                               df_d=df_d[order(df_d$Dates),]
                               
                               dfsim_d=df_d
                               
                               ###
                               df <- data.frame(date = as.Date(obsFile$Dates), Gauge = obsv[,i],timestep=obsFile$`Time step`)
                               df$monthyear=floor_date(df$date, "month")
                               
                               df_d=as.data.frame(df %>%
                                                    group_by(timestep) %>%
                                                    summarize(mean = mean(Gauge ,na.rm = TRUE)))
                               
                               
                               df_d = merge(df_d,days,by.x="timestep",by.y = "Time step")
                               df_d=df_d[order(df_d$Dates),]
                               
                               dfobs_d=df_d
                               
                               #grafica medios diarios multianuales
                               obs = zoo(dfobs_d[,2],dfobs_d[,4])
                               sim = zoo(dfsim_d[,2],dfsim_d[,4])
                               
                               if (Titles=="Spanish"){
                                 text=paste0("Promedio Diario Multianual")
                               }else if (Titles=="English") {
                                 text=paste0("Multiannual Daily Mean")
                               }
                               
                               setwd(dir_file)
                               Carpeta_Out="SimObs_MultiannualDaily"
                               dir.create(Carpeta_Out,showWarnings=F)
                               dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                               setwd(dir_file1)
                               png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                               ggof(sim=sim, obs=obs, lab.fmt="%b %d", ftype="o",tick.tstep = "days", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- ",text), xlab=xtext, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                               dev.off()
                               
                             }
                           })
                           
                           try({  
                             #sim
                             df <- data.frame(date = as.Date(simFile$Dates), Caudal = simv[,i])
                             df$monthyear=floor_date(df$date, "month")
                             #tail(df)
                             
                             df_m=as.data.frame(df %>%
                                                  group_by(monthyear) %>%
                                                  summarize(mean = mean(Caudal,na.rm = TRUE)))
                             df_m$month <- month(df_m$monthyear)
                             df_m=as.data.frame(df_m %>%
                                                  group_by(month) %>%
                                                  summarize(mean = mean(mean,na.rm = TRUE)))
                             
                             Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                             Dates=as.data.frame(Dates)
                             Dates$month=month(Dates$Dates)
                             
                             df_m=merge(df_m,Dates,by="month")
                             dfsim_m=df_m
                             
                             #obs
                             df <- data.frame(date = as.Date(obsFile$Dates), Caudal = obsv[,i])
                             df$monthyear=floor_date(df$date, "month")
                             
                             df_m=as.data.frame(df %>%
                                                  group_by(monthyear) %>%
                                                  summarize(mean = mean(Caudal,na.rm = TRUE)))
                             df_m$month <- month(df_m$monthyear)
                             df_m=as.data.frame(df_m %>%
                                                  group_by(month) %>%
                                                  summarize(mean = mean(mean,na.rm = TRUE)))
                             
                             Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                             Dates=as.data.frame(Dates)
                             Dates$month=month(Dates$Dates)
                             
                             df_m=merge(df_m,Dates,by="month")
                             dfobs_m=df_m
                             
                             #grafica medios mensuales multianuales
                             obs = zoo(dfobs_m[,2],dfobs_m[,3])
                             sim = zoo(dfsim_m[,2],dfsim_m[,3])
                             
                             if (Titles=="Spanish"){
                               text=paste0("Promedio Mensual Multianual")
                             }else if (Titles=="English") {
                               text=paste0("Multiannual Monthly Mean")
                             }
                             setwd(dir_file)
                             Carpeta_Out="SimObs_MultiannualMonthly"
                             dir.create(Carpeta_Out,showWarnings=F)
                             dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                             setwd(dir_file1)
                             png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                             ggof(sim=sim, obs=obs, lab.fmt="%b", ftype="o",tick.tstep = "months", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- ",text), xlab=xtext, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                             dev.off()
                             
                           })
                           
                           #residuales
                           obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                           sim = zoo(simv[,i],as.Date(simFile$Dates))
                           
                           try({
                             setwd(dir_file)
                             Carpeta_Out="Sim"
                             dir.create(Carpeta_Out,showWarnings=F)
                             dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                             setwd(dir_file1)
                             png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                             hydroplot(sim, FUN=mean,var.unit="m3/s",main=paste0(name," Simu"),xlab="",na.rm=TRUE)
                             dev.off()
                           })
                           
                           try({
                             setwd(dir_file)
                             Carpeta_Out="Obs"
                             dir.create(Carpeta_Out,showWarnings=F)
                             dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                             setwd(dir_file1)
                             png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                             hydroplot(obs, FUN=mean,var.unit="m3/s",main=paste0(name," Obs"),xlab="",na.rm=TRUE)
                             dev.off()
                           })
                           
                           try({
                             r <- sim-obs
                             smry(r)
                             setwd(dir_file)
                             Carpeta_Out="SimObs_residuals"
                             dir.create(Carpeta_Out,showWarnings=F)
                             dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                             setwd(dir_file1)
                             png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                             hydroplot(r, FUN=mean,var.unit="m3/s",main=paste0(name," Residual"),xlab="",na.rm=TRUE)
                             dev.off()
                           })
                           #metricas en tabla
                           
                           metrics=NULL
                           obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                           sim = zoo(simv[,i],as.Date(simFile$Dates))
                           
                           
                           if (ts==365){
                             
                             try({
                               m <- gof(sim=sim, obs=obs)
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Diario"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Daily"
                               }
                               
                               metrics=rbind(metrics,m)
                             })
                             
                             try({
                               sim = daily2monthly.zoo(sim, FUN = mean)
                               obs = daily2monthly.zoo(obs, FUN = mean)
                               m <- gof(sim=sim, obs=obs)
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Mensual"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Monthly"
                               }
                               
                               metrics=rbind(metrics,m)
                             })
                             
                             try({
                               sim = monthly2annual(sim, FUN = mean)
                               obs = monthly2annual(obs, FUN = mean)
                               m <- gof(sim=sim, obs=obs)
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Anual"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Annual"
                               }
                               metrics=rbind(metrics,m)  
                             })
                             
                             try({
                               m <- gof(sim=dfsim_d[,2], obs=dfobs_d[,2])
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Medio Diario multianual"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Multiannual Daily Mean"
                               }
                               metrics=rbind(metrics,m)
                             })
                           }
                           
                           if (ts==12){
                             try({
                               m <- gof(sim=sim, obs=obs)
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Mensual"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Monthly"
                               }
                               metrics=rbind(metrics,m)
                             })
                             
                             try({
                               
                               sim = monthly2annual(sim, FUN = mean)
                               obs = monthly2annual(obs, FUN = mean)
                               m <- gof(sim=sim, obs=obs)
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Anual"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Annual"
                               }
                               metrics=rbind(metrics,m)  
                             })
                             
                             try({
                               m <- gof(sim=dfsim_m[,2], obs=dfobs_m[,2])
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Medio Mensual multianual"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Multiannual Monthly Mean"
                               }
                               metrics=rbind(metrics,m)
                             })
                           } else {
                             try({
                               m <- gof(sim=sim, obs=obs)
                               m <- as.data.frame(m)
                               m$Metricas <- rownames(m)
                               m$Estacion <- name
                               
                               if (Titles=="Spanish"){
                                 m$Tipo <- "Paso de tiempo del modelo"
                               }else if (Titles=="English") {
                                 m$Tipo <- "Model Time Step"
                               }
                               
                               metrics=rbind(metrics,m)
                             })
                           }
                           
                           metrics$ID=f
                           
                         }
                         
                         
                         metricsALL=rbind(metricsALL,metrics)
                         
                       }
                       try({
                         setwd(dir)
                         metricas <- subset(metricsALL, Metricas %in% GofTabla)
                         colnames(metricas)=c("Valor", "GOF", "Estacion", "Tipo" ,    "Run ID"  )
                         metricas=metricas[,c("Run ID", "Tipo","Estacion", "GOF","Valor")]
                         
                         if (Titles=="English") {
                           colnames(metricas)=c("Run ID", "Type","Gauge", "GOF","Value")
                         }
                         
                         write.csv(metricas, paste0("0_SummaryGOF2_",paste(dates,collapse ="-"),".csv"),row.names = FALSE)
                         
                       })
                       
                       
                       ################################################################################################
                       runTimeGOF2=difftime(Sys.time(),start)
                       runTimeGOF2
                       
                       ##############################################################
                       
                       output$textRunEnsemblegraphi <- renderText({
                         outTxt = ""
                         text=paste0("Graphs exported. Check ", dir,". Time: ")
                         formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                         outTxt = paste0(outTxt, formatedFont)
                         
                         text=format(as.difftime(difftime(Sys.time(),start), format = "%H:%M")) 
                         formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                         outTxt = paste0(outTxt, formatedFont)
                         
                         outTxt
                         
                         
                       })
                       
                       
                       incProgress(1/truns)
                       
                     })
      }
      
    })
    
    observeEvent(list(input$StreamflowSelectA,input$datesi),{
      
      Model=VAL$Model1 
      req(input$StreamflowSelectA)
      req(input$datesi)
      file=NULL
      gs=input$StreamflowSelectA
      
      if (file.exists(paste0("0_ResultsGauges.csv")) && Model==1){    
        
        name="0_ResultsGauges.csv"
        file <- read.csv(name, stringsAsFactors=F, check.names=F)
        file$Dates=ymd(file$Dates)
        file$YearMonth=year(file$Dates)*100+month(file$Dates)
        file$Month=month(file$Dates)
        file <- file[which(file$Dates >= input$datesi[1] & file$Dates <= input$datesi[2]),]
        #gs=unique(file$Gauge)[1]
        #file=file[file$Gauge==gauge,]
        file1=file[file$Gauge==gs,]
        
        try({
        if (!file.exists(paste0("0_SummaryGOF_",as.character(input$datesi[1]),"-",as.character(input$datesi[2]),".csv"))){
          #########################
          errorEvaluar=c(
            1, #1.	me, Mean Error
            2, #2.	mae, Mean Absolute Error
            # 3, #3.	mse, Mean Squared Error
            # 4, #4.	rmse, Root Mean Square Error
            5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
            6, #6.	PBIAS, Percent Bias
            # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
            # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
            9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
            10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
            # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
            12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
            13,  #13.	md, Modified Index of Agreement 
            # 14,#14.	rd, Relative Index of Agreement
            # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
            # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
            17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
            18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
            19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
            20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
          ) 
          names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                        "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                        "KGE" ,    "VE" ) 
          #names_error[errorEvaluar]
          
          names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 
          
          uniqueGauges=sort(unique(file$Gauge))
          
          metricsAll=NULL
          
          runID=0
          t=1
          for (t in 1:3){
            
            metrics=as.data.frame(matrix(nrow=length(uniqueGauges),ncol=(12+length(errorEvaluar)*2)))
            colnames(metrics) <- c("Gauge","Run ID",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Type","Period")
            
            metrics[,1]=uniqueGauges
            metrics[,2]=runID
            
            g=1
            for (g in 1:length(uniqueGauges)){
              
              filesub=file[file$Gauge==uniqueGauges[g],]
              total=nrow(filesub)
              
              filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
              r1=nrow(filesubt)
              DatesRegister=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
              
              metrics[g,"Period"]=DatesRegister
              
              n=round(nrow(filesubt)*0.7,0)
              
              
              if (t==1){
                
                filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                r1=nrow(filesubt)
                
                filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                
                total <- nrow(filewb)
                DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                DatesRegister
                
                metrics$Type="All"
                
              } else if (t==2) {
                
                filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                filesubt=filesubt[1:n,]
                r1=nrow(filesubt)
                
                filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                total <- nrow(filewb)
                DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                DatesRegister
                
                metrics$Type="Calibration (70%)"
                
              } else {
                
                filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                filesubt=filesubt[(n+1):nrow(filesubt),]
                r1=nrow(filesubt)
                
                filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                total <- nrow(filewb)
                DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                DatesRegister
                
                
                metrics$Type="Validation (30%)"
                
              }
              
              filesub=filewb
              Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
              Filemonthly$N=1
              Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
              Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
              Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
              Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
              Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
              metrics[g,(7+length(errorEvaluar)*2):(7+2*length(errorEvaluar)+3)]=Filemonthly[1,7:10]
              
              filesub=filesubt
              r=nrow(filesub)
              modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
              observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
              
              filesub$Modeled[which(filesub$Modeled ==0)]=NA
              filesub$Observed[which(filesub$Observed ==0)]=NA
              filesub=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
              modeledlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Modeled,10)
              observedlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Observed,10)
              
              if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
                error=gof(modeled,observed,na.rm=TRUE)
                metrics[g,3:(2+length(errorEvaluar))]=round(error[errorEvaluar],3)
                errorLOG=gof(modeledlog,observedlog,digits=5,na.rm=TRUE)
                metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=round(errorLOG[errorEvaluar],3)
              } else {
                metrics[g,3:(2+length(errorEvaluar))]=NA
                metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=NA
              }
              metrics$PeriodGOF[g]=DatesRegister
              metrics[g,2+length(errorEvaluar)*2+1]=min(na.exclude(filesub$Observed))/min( na.exclude(filesub$Modeled))*100   
              metrics[g,2+length(errorEvaluar)*2+2]=mean(na.exclude(filesub$Observed))/mean( na.exclude(filesub$Modeled))*100   
              metrics[g,2+length(errorEvaluar)*2+3]=max(na.exclude(filesub$Observed))/max( na.exclude(filesub$Modeled))*100   
              
            }
            
            metricsAll=rbind(metricsAll,metrics)
            
            
          }
          
          metrics=metricsAll
          
          metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")]=round(metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")],2)
          cols <- c("Type","Period","Gauge","PeriodGOF",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %")
          metrics=metrics[,cols]
          write.csv(metrics,paste0("0_SummaryGOF_",as.character(input$datesi[1]),"-",as.character(input$datesi[2]),".csv"),row.names=F) 
          #write.csv(metrics,paste0("SummaryGOF_",".csv"),row.names=F) 
          ####################################
        } else {
          name=paste0("0_SummaryGOF_",as.character(input$datesi[1]),"-",as.character(input$datesi[2]),".csv")
          metrics <- read.csv(name, stringsAsFactors=F, check.names=F)
        }
      }) 
        
        
        try({
          output$metricsi <- DT::renderDataTable({
            
            metrics=metrics[metrics$Gauge==gs,]
            DT::datatable(metrics, rownames= FALSE)
            
          })
        })               
        
        file = file1
        filesub=file[file$Gauge==gs,]
        filesub$Observed=filesub$Observed/filesub$Days/86400
        filesub$Modeled=filesub$Modeled/filesub$Days/86400
        filesub=filesub[order(filesub$Year,filesub$`Time step`),]
        
        try({
          output$Qi <- renderPlotly({
            
            p <-plot_ly(filesub, x=~Dates, y=~Observed, name = "Observed", type="scatter", mode="lines",
                        line = list(color="black",width=1.5)) %>%
              add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
              layout(title = paste0("Streamflow ",gs),
                     xaxis = list(title=""),
                     yaxis = list(title= "Q (M^3/s)"))
            p
            
            
          })
        })   
        
        try({
          output$Qmonthlyi <- renderPlotly({
            
            Qmonthly <- aggregate(filesub[,c("Observed","Modeled")], by=list(YearMonth=filesub$YearMonth),mean,na.rm=F)
            
            Qmonthly$Month=Qmonthly$YearMonth%%100
            
            Qmonthly <- aggregate(Qmonthly[,c("Observed","Modeled")], by=list(Month=Qmonthly$Month),mean,na.rm=T)
            
            pmonthly <- plot_ly(Qmonthly, x=~Month, y=~Observed, name = "Observed", showlegend=FALSE,type="scatter", mode="lines",
                                line = list(color="black",width=1.5)) %>%
              add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
              layout(title = paste0("Streamflow (Monthly Average) ",gs),
                     xaxis = list(title=""),
                     yaxis = list(title= "Q (M^3/s)"))
            pmonthly
            
          })
        })   
        
        try({
          output$fdci <- renderPlotly({
            
            prob <- seq(1:100)
            obs.cdf <- rep(0,100)
            sim.cdf <- rep(0,100)
            obs.cdf <- quantile(filesub$Observed, prob/100,na.rm=T)
            sim.cdf <- quantile(filesub$Modeled, prob/100,na.rm=T)
            
            table <- as.data.frame(cbind(c(1:100),obs.cdf,sim.cdf))
            row.names(table) <- NULL
            colnames(table)[1] <- "Prob"
            
            fdc <- plot_ly(table,x=~Prob, y=~obs.cdf,type="scatter",name="Observed",showlegend=FALSE,mode="lines",line = list(color='black',width=1.5))%>%
              add_trace(y=~sim.cdf,name="Modeled", line=list(color="red",width=1.5, dash='dot'))%>%
              layout(title =paste0("Flow Duration Curve ",gs),yaxis = list(title="Q (M^3)"),xaxis=list(title="Probability (%)"))
            fdc
          })
        })               
        
        file = file1
        filesub=file[file$Gauge==gs,]
        filesub[,4:14]=round(filesub[,4:14]/filesub[,15]*1000,2)
        filesub[,11]=-1*filesub[,11]
        filesub$SM=filesub[,11]+filesub[,12]
        filesub$Interflow2 <- filesub$Interflow+filesub$Base_Flow
        filesub$SurfaceRunoff2 <- filesub$Surface_Runof + filesub$Interflow2
        filesub$Evapotranspiration2 <- filesub$Evapotranspiration + filesub$SurfaceRunoff2
        
        try({
          output$WBi <- renderPlotly({
            
            pWB <- plot_ly(filesub, x=~Dates, y=~Precipitation, name="Precipitation", type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=0.5), text=~paste("Precip = ", Precipitation)) %>%
              add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
              add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
              add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
              add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
              layout(title = paste0("Water Balance ",gs),yaxis = list(title="mm"),  xaxis =list(title="Date"))
            
            pWB
          })
        })               
        try({
          output$WBSMi <- renderPlotly({
            p5 <-plot_ly(filesub, x=~Dates, y=filesub[,"SM"], name="Decrease in Surface Storage", type = "bar",
                         text=~paste("Decrease Surface Storage = ", filesub$`Decrease in Surface Storage`)) %>%
              layout(title = paste0("Soil Moisture ",gs),
                     xaxis = list(title="Date"),
                     yaxis = list(title= "mm"))
            p5
          })
        })               
        try({
          output$WBSEi <- renderPlotly({
            
            SMmonthly <- aggregate(filesub[,c("Decrease in Soil Moisture","Increase in Soil Moisture","SM")], by=list(YearMonth=filesub$YearMonth),mean,na.rm=F)
            SMmonthly$Month=SMmonthly$YearMonth%%100
            SMmonthly <- aggregate(SMmonthly[,c("Decrease in Soil Moisture","Increase in Soil Moisture","SM")], by=list(Month=SMmonthly$Month),mean,na.rm=T)
            
            p5 <- plot_ly(SMmonthly, x=~Month, y=SMmonthly[,"SM"], name = "Soil Moisture", showlegend=FALSE,type="bar",
                          text=~paste("Decrease Surface Storage = ", SMmonthly$SM)) %>%
              layout(title = paste0("Soil Moisture (Monthly Average) ",gs),
                     xaxis = list(title="Date"),
                     yaxis = list(title= "mm"))
            p5
            
            
          })
        })               
        try({
          output$WBmonthlyi <- renderPlotly({
            
            wbmonthly <- aggregate(filesub[,c(6:14,20:ncol(filesub))], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
            
            wbmonthly$Month=wbmonthly$YearMonth%%100
            
            wbmonthly <- aggregate(wbmonthly[,c(2:(ncol(wbmonthly)-1))], by=list(Month=wbmonthly$Month),mean,na.rm=T)
            
            p2monthly <- plot_ly(wbmonthly, x=~Month, y=~Precipitation, name="Precipitation", showlegend=TRUE, type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=1.5), text=~paste("Precip = ", Precipitation)) %>%
              add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
              add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
              add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
              add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
              layout(title =paste0("Water Balance Monthly Average ",gs),yaxis = list(title="mm"),xaxis=list(title="Months"))
            
            p2monthly
            
          })
        })               
         
        Filemonthly <- aggregate(filesub[,c("Precipitation","Evapotranspiration","Surface_Runoff","Interflow", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
        Filemonthly$Month=Filemonthly$YearMonth%%100
        Filemonthly <- aggregate(Filemonthly[,c("Precipitation","Evapotranspiration","Surface_Runoff","Interflow", "Base_Flow")], by=list(Month=Filemonthly$Month),mean,na.rm=T)
        Filemonthly$TotalRunoff=Filemonthly$Base_Flow+Filemonthly$Interflow+Filemonthly$Surface_Runoff
        #Filemonthly$Total2=Filemonthly$Total-Filemonthly$Modeled
        #summary(Filemonthly)
        Filemonthly$`Evapotranspiration/Precipitation%`=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
        Filemonthly$`SurfaceRunoff/TotalRunoff%`=round(Filemonthly$Surface_Runoff/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`Interflow/TotalRunoff%`=round(Filemonthly$Interflow/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`BaseFlow/TotalRunoff%`=round(Filemonthly$Base_Flow/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`TotalRunoff/Precipitation%`=round(Filemonthly$TotalRunoff/Filemonthly$Precipitation*100,1)
        #Filemonthly=Filemonthly[,-(2:6)]
        #str(Filemonthly)
        #colnames(Filemonthly)
        try({
          output$WBmonthlyBi <- renderPlotly({
            
            p2monthly <- plot_ly(Filemonthly, x=~Month, y=~`TotalRunoff/Precipitation%`, name="TotalRunoff/Precipitation%", showlegend=TRUE, type="scatter",mode="line",text=~paste("TotalRunoff/Precipitation% = ", `TotalRunoff/Precipitation%`)) %>%
              add_trace(y=~`BaseFlow/TotalRunoff%`, name="BaseFlow/TotalRunoff%", type="scatter",mode="line",text=~paste("BaseFlow/TotalRunoff% = ", `BaseFlow/TotalRunoff%`)) %>%
              add_trace(y=~`Interflow/TotalRunoff%`, name="Interflow/TotalRunoff%", type="scatter",mode="line",text=~paste("Interflow/TotalRunoff% = ", `Interflow/TotalRunoff%`)) %>%
              add_trace(y=~`SurfaceRunoff/TotalRunoff%`, name="SurfaceRunoff/TotalRunoff%", type="scatter",mode="line",text=~paste("SurfaceRunoff/TotalRunoff% = ", `SurfaceRunoff/TotalRunoff%`)) %>%
              add_trace(y=~`Evapotranspiration/Precipitation%`, name="Evapotranspiration/Precipitation%", type="scatter",mode="line",text=~paste("Evapotranspiration/Precipitation% = ", `Evapotranspiration/Precipitation%`)) %>%
              layout(title =paste0("Percentages ",gs),yaxis = list(title="%"),xaxis=list(title="Months"))
            
            p2monthly
            
          })
        })  
        try({
          output$WBtablei <- DT::renderDataTable({
            
            Filemonthly[,c(2:ncol(Filemonthly))] <- round(Filemonthly[,c(2:ncol(Filemonthly))],2)
            colnames(Filemonthly) <- c("Month","Precipitation (mm)","Evapotranspiration (mm)","Surface Runoff (mm)","Interflow (mm)","Base Flow (mm)",
                                       "Total Runoff (mm)",
                                       "Evapotranspiration / Precipitation %",
                                       "SurfaceRunoff / TotalRunoff %",
                                       "Interflow / TotalRunoff %",
                                       "BaseFlow / TotalRunoff %",
                                       "TotalRunoff / Precipitation %"
            )
            
            DT::datatable(Filemonthly, options = list(lengthMenu = c(12), pageLength = 12),rownames= FALSE)
            
          })
        }) 

    }
      
    })
    ###################################### 

    ###################################### 
    observeEvent(input$WEAPKeyEnsemble,{
      
      output$tableWEAPKeyEnsemble <- DT::renderDataTable({
        inFile1 <- input$WEAPKeyEnsemble
        Model=VAL$Model #&& Model==1
        if (!is.null(inFile1) && Model==1) {
          data <- read.csv(inFile1$datapath, stringsAsFactors=F, check.names=F)
          
          keyss <- list()
          for (i in 1:nrow(data)) {
            min <- data$Min[i]
            max <- data$Max[i]
            
            if (data$Variations[i]>1) {
              step <- (max-min)/(data$Variations[i]-1)
              options <- seq(from=min,to=max,by=step)
              
            }  else  {options <- data$Min[i]}
            
            keyss[[i]] <- options
          }
          
          table <- cbind(1:nrow(expand.grid(keyss)),expand.grid(keyss))
          colnames(table) <- c("Nrun",as.vector(data[,1]))
          
          write.csv(table,paste0("KeyModelInputs.csv"),row.names=F)
          
          output$textWEAPKeyEnsemble <- renderText({ 
            runs <- nrow(table)
            
            outTxt = ""
            text=paste0("Your WEAP model will need to run ", runs," times")
            formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
            outTxt = paste0(outTxt, formatedFont)
            
            outTxt
          })
          
          DT::datatable(data, rownames= FALSE)
          
          
          
        } else {
          return(NULL)
        }
      })
      
    })
    observeEvent(input$WEAPKeyEnsembleInputs,{
      output$tableWEAPKeyEnsemble <- DT::renderDataTable({
        inFile2 <- input$WEAPKeyEnsembleInputs
        Model=VAL$Model #&& Model==1
        if (!is.null(inFile2) && Model==1) {
          data <- read.csv(inFile2$datapath, stringsAsFactors=F, check.names=F)
          write.csv(data,paste0("KeyModelInputs.csv"),row.names=F)
          
          output$textWEAPKeyEnsemble <- renderText({ 
            runs <- nrow(data)
            outTxt = ""
            text=paste0("Your WEAP model will need to run ", runs," times")
            formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
            outTxt = paste0(outTxt, formatedFont)
            
            outTxt
          })
          
          DT::datatable(data, rownames= FALSE)
        } else {
          return(NULL)
        }
        
      })
    })
    
    output$textRunEnsemble <- renderText({
      outTxt = ""
      text=("Press the button to run. Run time will appear here when finished.")
      formatedFont = sprintf('<font color="%s">%s</font>',"red",text)
      outTxt = paste0(outTxt, formatedFont)
      
      outTxt
      
    })
    
    observeEvent(input$action,{ 
      
      Model=VAL$Model #&& 
      
      try({
        if (Model==1){
          withProgress(message = 'Calculation in progress',
                       detail = 'This may take a while...', value = 0, {
                         
                         start = Sys.time()
                         
                         sy <- input$start
                         ey <- input$end
                         Warea <- input$warea
                         Scen <- input$Scen
                         ts <- input$ts
                         
                         WEAP <- COMCreate("WEAP.WEAPApplication") 
                         Sys.sleep(3)
                         
                         keyinputs = NULL
                         if (file.exists(paste0("KeyModelInputs.csv"))){
                           keyinputs <- read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
                           keys <- colnames(keyinputs)[2:ncol(keyinputs)]
                           runs <- nrow(keyinputs)
                         } else {
                           runs=1
                         } 
                         
                         incProgress(1/(3*runs+2))
                         
                         
                         WEAP[["ActiveArea"]] <- Warea
                         WEAP[["BaseYear"]] <- sy
                         WEAP[["EndYear"]] <- ey
                         WEAP[["Verbose"]] <- 0
                         
                         
                         sy=as.numeric(sy)+1
                         
                         WEAP[["ActiveScenario"]] <- "Current Accounts"
                         
                         C = "NumRun"  
                         var="\\Key\\"
                         res <- try(WEAP$Branch(var)$AddChild(C))
                         
                         C = "DaysTimeStep"  
                         var="\\Key\\"
                         res <- try(WEAP$Branch(var)$AddChild(C))
                         
                         var="Key\\DaysTimeStep:Annual Activity Level"
                         res <- try(WEAP$BranchVariable(var)[["Expression"]] <- "days")
                         
                         files=c(list.files(pattern ="_ResultsGauges"),list.files(pattern ="_WaterBalance"),list.files(pattern ="ResultsWB-")) #,"KeyModelInputs.csv"   
                         list.of.files <- list.files(files)
                         
                         if (length(list.of.files)>0){
                           fn=files
                           for (j in 1:length(fn)) {
                             if (file.exists(fn[j])) {
                               file.remove(fn[j])
                             }
                           }
                         }
                         
                         
                         if (!is.null(keyinputs)){
                           
                           for(i in 1:nrow(keyinputs)) {
                             
                             RUNID=keyinputs[i,1]
                             WEAP[["ActiveScenario"]] <- "Current Accounts"
                             var="Key\\NumRun:Annual Activity Level"
                             res <- try(WEAP$BranchVariable(var)[["Expression"]] <- RUNID)
                             
                             WEAP[["ActiveScenario"]] <- Scen
                             WEAP$DeleteResults()
                             
                             Sys.sleep(3)
                             
                             for(k in 1:length(keys)) {
                               res <- try(
                                 WEAP$BranchVariable(keys[k])[["Expression"]] <- keyinputs[i,k+1] 
                               )
                             }
                             
                             WEAP$Calculate() 
                             
                             Sys.sleep(3)
                             
                             incProgress(1/(3*runs+2))
                             
                             dir_outg = dir_outg = VAL$dir_outg
                             
                             files=c(paste0(RUNID,"_",Scen,"_WaterBalance.csv"),paste0(RUNID,"_",Scen,"_ResultsGauges.csv"),"WEAPKeyGaugeBranches.csv","WEAPKeyGaugesCatchments.csv","WEAPdays.csv")
                             current.folder <- paste0(WEAP$AreasDirectory(),Warea)
                             new.folder <- dir_outg
                             list.of.files <- list.files(files)
                             file.copy(paste0(current.folder,"/",files), new.folder, overwrite =TRUE)
                             
                             fn=paste0(current.folder,"/",c(files))
                             for (j in 1:length(fn)) {
                               if (file.exists(fn[j])) {
                                 file.remove(fn[j])
                               }
                             }
                             
                             KeyGaugesCatchments=read.csv("WEAPKeyGaugesCatchments.csv", stringsAsFactors=F, check.names=F)
                             uniqueGauges=unique(KeyGaugesCatchments$Gauge)
                             
                             resultsWBG=read.csv(paste0(RUNID,"_",Scen,"_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
                             cols=c("Year",
                                    "Time step",
                                    "Gauge",
                                    "Observed",
                                    "Modeled"
                             )
                             #str(resultsWBG)
                             resultsWBG=resultsWBG[,cols]
                             
                             resultsWBC=read.csv(paste0(RUNID,"_",Scen,"_WaterBalance.csv"), stringsAsFactors=F, check.names=F)
                             cols=c("Year",
                                    "Time step",
                                    "Catchment",
                                    "Precipitation",
                                    "Evapotranspiration",
                                    "Surface_Runoff",
                                    "Interflow",
                                    "Base_Flow",
                                    "Decrease in Soil Moisture",
                                    "Increase in Soil Moisture",
                                    "Decrease in Surface Storage",
                                    "Increase in Surface Storage",
                                    "Area"
                             )
                             resultsWBC=resultsWBC[,cols]
                             
                             resultsWBG[resultsWBG==-9999]= NA
                             resultsWBC[resultsWBC==-9999]= NA
                             resultsWBG[resultsWBG$Observed==0,"Observed"]= NA
                             
                             incProgress(1/(3*runs+2))
                             
                             cols=c("Year",
                                    "Time step",
                                    "Gauge",
                                    "Observed",
                                    "Modeled",
                                    "Precipitation",
                                    "Evapotranspiration",
                                    "Surface_Runoff",
                                    "Interflow",
                                    "Base_Flow",
                                    "Decrease in Soil Moisture",
                                    "Increase in Soil Moisture",
                                    "Decrease in Surface Storage",
                                    "Increase in Surface Storage",
                                    "Area"
                             )
                             
                             resultsWB=NULL
                             g=1
                             for (g in 1:length(uniqueGauges)){ 
                               
                               NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
                               
                               
                               f=is.element(resultsWBC$Catchment,NamecatchG)
                               resultsWBC_g= resultsWBC[which(f==TRUE),]
                               resultsWBC_g=aggregate(resultsWBC_g[,4:ncol(resultsWBC_g)],list(Year=resultsWBC_g$Year,`Time step`=resultsWBC_g$`Time step`),sum, na.rm=TRUE)
                               resultsWBC_g$Gauge=uniqueGauges[g]
                               
                               
                               f=is.element( resultsWBG$Gauge,uniqueGauges[g])
                               resultsWB_g= resultsWBG[which(f==TRUE),]
                               
                               #str(resultsWBC_g)
                               #str(resultsWB_g)
                               resultsWBC_g1=merge(resultsWBC_g,resultsWB_g,by = c("Year","Time step","Gauge"))
                               
                               resultsWBC_g1=resultsWBC_g1[,cols]
                               #str(resultsWBC_g1)
                               resultsWBC_g1=resultsWBC_g1[order(resultsWBC_g1$Gauge,resultsWBC_g1$Year,resultsWBC_g1$`Time step`),]
                               resultsWB=rbind(resultsWB,resultsWBC_g1)
                               
                             }
                             
                             days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                             days1=unique(resultsWB[,c("Year","Time step")])
                             days=merge(days,days1,by="Time step")
                             days=days[order(days$Year,days$`Time step`),]
                             days$Dates=NA
                             days$Dates=as.Date(days$Dates)      
                             days$Dates[1]=as.Date(paste0(days$Year[1],"/01/01"))
                             days$Dates=as.Date(days$Dates)      
                             for (d in 2:nrow(days)) {
                               drow=as.Date(days$Dates[d-1]+days$Days[d-1])
                               if ((month(as.Date(days$Dates[d-1]+days$Days[d-1]))*100+day(as.Date(days$Dates[d-1]+days$Days[d-1])))==229){
                                 days$Dates[d]=as.Date(days$Dates[d-1]+days$Days[d-1]+1)
                               }else {
                                 days$Dates[d]=as.Date(days$Dates[d-1]+days$Days[d-1])
                               }
                               if(year(days$Dates[d])!=days$Year[d]){
                                 days$Dates[d]=as.Date(paste0(days$Year[d],"/12/31"))
                               }
                               
                             }
                             days$Dates=as.Date(days$Dates)      
                             rownames(days)=NULL  
                             
                             resultsWB = merge(resultsWB,days,by=c("Year","Time step"))
                             resultsWB=resultsWB[order(resultsWB$Gauge,resultsWB$Year,resultsWB$`Time step`),]
                             write.csv(resultsWB,paste0("ResultsWB-",RUNID,".csv"),row.names=F) 
                             incProgress(1/(3*runs+2))
                             
                             files=c(paste0(RUNID,"_",Scen,"_WaterBalance.csv"),paste0(RUNID,"_",Scen,"_ResultsGauges.csv"))
                             
                             if (length(list.of.files)>0){
                               fn=files
                               for (j in 1:length(fn)) {
                                 if (file.exists(fn[j])) {
                                   file.remove(fn[j])
                                 }
                               }
                             }
                             
                           }
                           VAL$Model3=1
                         }
                         
                         
                         if (is.null(keyinputs)){
                           
                           RUNID=1
                           
                           WEAP[["ActiveScenario"]] <- "Current Accounts"
                           var="Key\\NumRun:Annual Activity Level"
                           res <- try(WEAP$BranchVariable(var)[["Expression"]] <- RUNID)
                           
                           WEAP[["ActiveScenario"]] <- Scen
                           
                           WEAP$DeleteResults()
                           
                           Sys.sleep(3)
                           
                           WEAP$Calculate() 
                           
                           Sys.sleep(3)
                           
                           incProgress(1/(3*runs+2))
                           
                           dir_outg = VAL$dir_outg
                           
                           files=c(paste0(RUNID,"_",Scen,"_WaterBalance.csv"),paste0(RUNID,"_",Scen,"_ResultsGauges.csv"),"WEAPKeyGaugeBranches.csv","WEAPKeyGaugesCatchments.csv","WEAPdays.csv")
                           current.folder <- paste0(WEAP$AreasDirectory(),Warea)
                           new.folder <- dir_outg
                           list.of.files <- list.files(files)
                           file.copy(paste0(current.folder,"/",files), new.folder, overwrite =TRUE)
                           
                           fn=paste0(current.folder,"/",c(files))
                           for (j in 1:length(fn)) {
                             if (file.exists(fn[j])) {
                               file.remove(fn[j])
                             }
                           }
                           
                           KeyGaugesCatchments=read.csv("WEAPKeyGaugesCatchments.csv", stringsAsFactors=F, check.names=F)
                           uniqueGauges=unique(KeyGaugesCatchments$Gauge)
                           
                           resultsWBG=read.csv(paste0(RUNID,"_",Scen,"_ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
                           cols=c("Year",
                                  "Time step",
                                  "Gauge",
                                  "Observed",
                                  "Modeled"
                           )
                           #str(resultsWBG)
                           resultsWBG=resultsWBG[,cols]
                           
                           resultsWBC=read.csv(paste0(RUNID,"_",Scen,"_WaterBalance.csv"), stringsAsFactors=F, check.names=F)
                           cols=c("Year",
                                  "Time step",
                                  "Catchment",
                                  "Precipitation",
                                  "Evapotranspiration",
                                  "Surface_Runoff",
                                  "Interflow",
                                  "Base_Flow",
                                  "Decrease in Soil Moisture",
                                  "Increase in Soil Moisture",
                                  "Decrease in Surface Storage",
                                  "Increase in Surface Storage",
                                  "Area"
                           )
                           resultsWBC=resultsWBC[,cols]
                           
                           resultsWBG[resultsWBG==-9999]= NA
                           resultsWBC[resultsWBC==-9999]= NA
                           resultsWBG[resultsWBG$Observed==0,"Observed"]= NA
                           
                           incProgress(1/(3*runs+2))
                           
                           cols=c("Year",
                                  "Time step",
                                  "Gauge",
                                  "Observed",
                                  "Modeled",
                                  "Precipitation",
                                  "Evapotranspiration",
                                  "Surface_Runoff",
                                  "Interflow",
                                  "Base_Flow",
                                  "Decrease in Soil Moisture",
                                  "Increase in Soil Moisture",
                                  "Decrease in Surface Storage",
                                  "Increase in Surface Storage",
                                  "Area"
                           )
                           
                           resultsWB=NULL
                           g=1
                           for (g in 1:length(uniqueGauges)){ 
                             
                             NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
                             
                             
                             f=is.element(resultsWBC$Catchment,NamecatchG)
                             resultsWBC_g= resultsWBC[which(f==TRUE),]
                             resultsWBC_g=aggregate(resultsWBC_g[,4:ncol(resultsWBC_g)],list(Year=resultsWBC_g$Year,`Time step`=resultsWBC_g$`Time step`),sum, na.rm=TRUE)
                             resultsWBC_g$Gauge=uniqueGauges[g]
                             
                             
                             f=is.element( resultsWBG$Gauge,uniqueGauges[g])
                             resultsWB_g= resultsWBG[which(f==TRUE),]
                             
                             #str(resultsWBC_g)
                             #str(resultsWB_g)
                             resultsWBC_g1=merge(resultsWBC_g,resultsWB_g,by = c("Year","Time step","Gauge"))
                             
                             resultsWBC_g1=resultsWBC_g1[,cols]
                             #str(resultsWBC_g1)
                             resultsWBC_g1=resultsWBC_g1[order(resultsWBC_g1$Gauge,resultsWBC_g1$Year,resultsWBC_g1$`Time step`),]
                             resultsWB=rbind(resultsWB,resultsWBC_g1)
                             
                           }
                           
                           days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                           days1=unique(resultsWB[,c("Year","Time step")])
                           days=merge(days,days1,by="Time step")
                           days=days[order(days$Year,days$`Time step`),]
                           days$Dates=NA
                           days$Dates=as.Date(days$Dates)      
                           days$Dates[1]=as.Date(paste0(days$Year[1],"/01/01"))
                           days$Dates=as.Date(days$Dates)      
                           for (d in 2:nrow(days)) {
                             drow=as.Date(days$Dates[d-1]+days$Days[d-1])
                             if ((month(as.Date(days$Dates[d-1]+days$Days[d-1]))*100+day(as.Date(days$Dates[d-1]+days$Days[d-1])))==229){
                               days$Dates[d]=as.Date(days$Dates[d-1]+days$Days[d-1]+1)
                             }else {
                               days$Dates[d]=as.Date(days$Dates[d-1]+days$Days[d-1])
                             }
                             if(year(days$Dates[d])!=days$Year[d]){
                               days$Dates[d]=as.Date(paste0(days$Year[d],"/12/31"))
                             }
                             
                           }
                           days$Dates=as.Date(days$Dates)      
                           rownames(days)=NULL  
                           
                           
                           resultsWB = merge(resultsWB,days,by=c("Year","Time step"))
                           resultsWB=resultsWB[order(resultsWB$Gauge,resultsWB$Year,resultsWB$`Time step`),]
                           
                           write.csv(resultsWB,paste0("ResultsWB-",RUNID,".csv"),row.names=F) 
                           incProgress(1/(3*runs+2))
                           VAL$Model3=0
                           
                           files=c(paste0(RUNID,"_",Scen,"_WaterBalance.csv"),paste0(RUNID,"_",Scen,"_ResultsGauges.csv"))
                           
                           if (length(list.of.files)>0){
                             fn=files
                             for (j in 1:length(fn)) {
                               if (file.exists(fn[j])) {
                                 file.remove(fn[j])
                               }
                             }
                           }
                           
                         }
                         
                         #WEAP$SaveArea()
                         rm(WEAP)
                         gc()
                         
                         
                         
                         output$textRunEnsemble <- renderText({ 
                           
                           outTxt = ""
                           text=paste0("Run finished. Total run Time: ")
                           formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                           outTxt = paste0(outTxt, formatedFont)
                           
                           text=format(as.difftime(difftime(Sys.time(),start), format = "%H:%M")) 
                           formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                           outTxt = paste0(outTxt, formatedFont)
                           
                           outTxt
                         })
                         
                         VAL$Model2=1
                         Model=VAL$Model2 #&&  Model==1
                         
                         if (Model==1){
                           
                           output$Streamflow <- renderUI({
                             if (length(list.files(pattern ="ResultsWB-")>0)){
                               listResults=list.files(pattern ="ResultsWB-")
                               listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                               listResults=gsub(".csv","",listResults,fixed = TRUE)
                               listResults=unique(as.numeric(listResults))
                               file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
                               gauges=sort(c(unique(file$Gauge)))
                               selectInput("StreamflowSelect", "Streamflow Gauge",gauges,gauges[1])
                             } else {
                               gauges="Run the Ensemble runs section first"
                               selectInput("StreamflowSelect", "Streamflow Gauge",gauges)
                             }
                           })
                           
                           output$daterange <- renderUI({
                             if (length(list.files(pattern ="ResultsWB-")>0)){
                               listResults=list.files(pattern ="ResultsWB-")
                               listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                               listResults=gsub(".csv","",listResults,fixed = TRUE)
                               listResults=unique(as.numeric(listResults))
                               file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
                               file$Dates=ymd(file$Dates)
                               starty <- min(file$Dates)
                               endy <- max(file$Dates)
                               dateRangeInput("dates",label="Select date range",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
                             } else {
                               dateRangeInput("dates",label="Select date range",start=ymd("1900-01-01"),end=ymd("1900-01-01"),min=ymd("1900-01-01"),max=ymd("1900-01-01"),separator = " - ", format = "dd/mm/yyyy")
                             }
                           })
                           
                           output$daterangegraph <- renderUI({
                             if (length(list.files(pattern ="ResultsWB-")>0)){
                               listResults=list.files(pattern ="ResultsWB-")
                               listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                               listResults=gsub(".csv","",listResults,fixed = TRUE)
                               listResults=unique(as.numeric(listResults))
                               file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
                               file$Dates=ymd(file$Dates)
                               starty <- min(file$Dates)
                               endy <- max(file$Dates)
                               dateRangeInput("datesgraph",label="Select date range",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
                             } else {
                               dateRangeInput("datesgraph",label="Select date range",start=ymd("1900-01-01"),end=ymd("1900-01-01"),min=ymd("1900-01-01"),max=ymd("1900-01-01"),separator = " - ", format = "dd/mm/yyyy")
                             }
                           })
                           output$daterangegraph1 <- renderUI({
                             if (length(list.files(pattern ="ResultsWB-")>0)){
                               listResults=list.files(pattern ="ResultsWB-")
                               listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                               listResults=gsub(".csv","",listResults,fixed = TRUE)
                               listResults=unique(as.numeric(listResults))
                               file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
                               file$Dates=ymd(file$Dates)
                               starty <- min(file$Dates)
                               endy <- max(file$Dates)
                               dateRangeInput("datesgraph1",label="Select date range to calculate performance metrics and save graphs",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
                             } else {
                               dateRangeInput("datesgraph1",label="Select date range to calculate performance metrics and save graphs",start=ymd("1900-01-01"),end=ymd("1900-01-01"),min=ymd("1900-01-01"),max=ymd("1900-01-01"),separator = " - ", format = "dd/mm/yyyy")
                             }
                           })
                           
                           output$sliders <- renderUI({ 
                             if (file.exists(paste0("KeyModelInputs.csv")) && VAL$Model3==1){
                               
                               KeyEnsemble <-read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
                               keys <- KeyEnsemble 
                               
                               pvars <- colnames(keys)[2:length(colnames(keys))]
                               pvars1 <- gsub(":Annual Activity Level","",pvars,fixed = TRUE)
                               selected <- as.character(keys[1,2:ncol(keys)])
                               choices=list(as.character(sort(unique(keys[,2]))))
                               for (i in 2:ncol(keys)){
                                 choices[i-1]=list(as.character(sort(unique(keys[,i]))))
                               }
                               lapply(seq(pvars), function(i) {
                                 sliderTextInput(inputId = paste0("key", i),
                                                 label = pvars1[i],
                                                 animate=TRUE,
                                                 grid = TRUE,
                                                 choices=unlist(choices[i]),
                                                 selected =selected[i]
                                 )
                               })
                             } else {
                               sliderTextInput(inputId = "SliderWB",
                                               label = "No parameter combination is available, Run the Ensemble section first",
                                               animate=TRUE,
                                               grid = TRUE,
                                               choices="NA",
                                               selected ="NA")
                             }
                           })
                           
                           output$Streamflow1 <- renderUI({
                             if (length(list.files(pattern ="ResultsWB-")>0)){
                               listResults=list.files(pattern ="ResultsWB-")
                               listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                               listResults=gsub(".csv","",listResults,fixed = TRUE)
                               listResults=unique(as.numeric(listResults))
                               file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
                               gauges=sort(c(unique(file$Gauge)))
                               selectInput("StreamflowSelect1", "Streamflow Gauge",gauges,gauges[1])
                             } else {
                               gauges="Run the Ensemble runs section first"
                               selectInput("StreamflowSelect1", "Streamflow Gauge",gauges)
                             }
                           }) 
                           output$daterange1 <- renderUI({
                             if (length(list.files(pattern ="ResultsWB-")>0)){
                               listResults=list.files(pattern ="ResultsWB-")
                               listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                               listResults=gsub(".csv","",listResults,fixed = TRUE)
                               listResults=unique(as.numeric(listResults))
                               file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
                               file$Dates=ymd(file$Dates)
                               starty <- min(file$Dates)
                               endy <- max(file$Dates)
                               dateRangeInput("dates1",label="Select date range",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
                             } else {
                               dateRangeInput("dates1",label="Select date range",start=ymd("1900-01-01"),end=ymd("1900-01-01"),min=ymd("1900-01-01"),max=ymd("1900-01-01"),separator = " - ", format = "dd/mm/yyyy")
                             }
                           })
                           output$sliders1 <- renderUI({ 
                             if (file.exists(paste0("KeyModelInputs.csv")) && VAL$Model3==1){
                               
                               KeyEnsemble <-read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
                               
                               selectInput(
                                 "SliderWB1",
                                 "Run Number",
                                 KeyEnsemble$Nrun,
                                 selected = KeyEnsemble$Nrun[1]
                               )
                               
                               
                             } else {
                               
                               selectInput(
                                 "SliderWB1",
                                 "Run Number",
                                 "1",
                                 selected = "1"
                               )
                               
                             }
                           })
                           
                           output$GOFdaterange <- renderUI({
                             if (length(list.files(pattern ="ResultsWB-")>0)){
                               listResults=list.files(pattern ="ResultsWB-")
                               listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                               listResults=gsub(".csv","",listResults,fixed = TRUE)
                               listResults=unique(as.numeric(listResults))
                               file <- read.csv(paste0("ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
                               file$Dates=ymd(file$Dates)
                               starty <- min(file$Dates)
                               endy <- max(file$Dates)
                               dateRangeInput("datest",label="Select date range to calculate performance metrics",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
                             } else {
                               dateRangeInput("datest",label="Select date range to calculate performance metrics",start=ymd("1900-01-01"),end=ymd("1900-01-01"),min=ymd("1900-01-01"),max=ymd("1900-01-01"),separator = " - ", format = "dd/mm/yyyy")
                             }
                           })
                           
                         }
                         
                         incProgress(1/(3*runs+2))
                         
                       })
        }
        
      })   
      
    })
    
    ###################################### 
    
    ###################################### 
    observe({
      
      Model=VAL$Model2 
      req(input$StreamflowSelect)
      runID="No results available"
      file=NULL
      name=NULL
      gs=input$StreamflowSelect
      
      if (file.exists(paste0("KeyModelInputs.csv")) &&  Model==1){
        keysset <- read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
        keys=keysset
        num <- ncol(keys)-1
        
        values=NULL
        for (i in 1:num){
          values=c(values, as.numeric(input[[paste0("key",i)]][1]))
        }
        
        #   values <- sapply(1:num, function(i)
        #   {(as.numeric(input[[paste0("key",i)]])[1])})
        #   values=as.numeric(unlist(values))
        
        #values=keysset[1,2:ncol(keysset)]
        runID =keysset[row.match(values,keysset[2:ncol(keysset)]),1]
        name=paste0("ResultsWB-",as.character(runID),".csv")
        
        if (file.exists(name)){
          file <- read.csv(name, stringsAsFactors=F, check.names=F)
          file$Dates=ymd(file$Dates)
          #gauge=unique(file$Gauge)[1]
          #file=file[file$Gauge==gauge,]
          file=file[file$Gauge==gs,]
          file$YearMonth=year(file$Dates)*100+month(file$Dates)
          file$Month=month(file$Dates)
          file <- file[which(file$Dates >= input$dates[1] & file$Dates <= input$dates[2]),]
          uniqueGauges=sort(unique(file$Gauge))
        } else {
          name=NULL
        }
        
      } else if (length(list.files(pattern ="ResultsWB-"))==1 &&  Model==1) {    
        
        runID=1
        name=paste0("ResultsWB-",as.character(runID),".csv")
        file <- read.csv(name, stringsAsFactors=F, check.names=F)
        file$Dates=ymd(file$Dates)
        #gauge=unique(file$Gauge)[1]
        #file=file[file$Gauge==gauge,]
        file=file[file$Gauge==gs,]
        file$YearMonth=year(file$Dates)*100+month(file$Dates)
        file$Month=month(file$Dates)
        file <- file[which(file$Dates >= input$dates[1] & file$Dates <= input$dates[2]),]
        uniqueGauges=sort(unique(file$Gauge))
      }
      
      print(runID)
      runID=as.character(runID)
      VAL$runID=runID
      
      file1=file
      
      # output$keys <- renderPrint({
      #   name
      # })
      
      output$runID <- renderText({
        
        Model=VAL$Model #&&  Model==1
        if (file.exists(paste0("KeyModelInputs.csv")) &&  Model==1 && !is.null(name) ){
          
          outTxt = ""
          text=paste("Selected combination corresponds to the run: ", VAL$runID)
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          outTxt
          
        } else if (length(list.files(pattern ="ResultsWB-"))==1 &&  Model==1)  {
          outTxt = ""
          text=paste("Last model run results")
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          outTxt
          
        } else {
          outTxt = ""
          text="No results available"
          formatedFont = sprintf('<font color="%s">%s</font>',"red",text)
          outTxt = paste0(outTxt, formatedFont)
          outTxt
        }
        
      })
      
      if (!is.null(name)){
 
        try({
          output$metrics <- DT::renderDataTable({
            
            #file <- read.csv(paste0("ResultsWB-",1,".csv"), stringsAsFactors=F, check.names=F)
            
            file = file1
            file$Dates=ymd(file$Dates)
            file$YearMonth=year(file$Dates)*100+month(file$Dates)
            file$Month=month(file$Dates)
            #unique(file$Gauge)
            
            errorEvaluar=c(
              1, #1.	me, Mean Error
              2, #2.	mae, Mean Absolute Error
              # 3, #3.	mse, Mean Squared Error
              # 4, #4.	rmse, Root Mean Square Error
              5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
              6, #6.	PBIAS, Percent Bias
              # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
              # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
              9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
              10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
              # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
              12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
              13,  #13.	md, Modified Index of Agreement 
              # 14,#14.	rd, Relative Index of Agreement
              # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
              # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
              17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
              18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
              19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
              20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
            ) 
            names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                          "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                          "KGE" ,    "VE" ) 
            #names_error[errorEvaluar]
            
            names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 
            
            
            
            metricsAll=NULL
            
            for (t in 1:3){
              
              metrics=as.data.frame(matrix(nrow=length(uniqueGauges),ncol=(12+length(errorEvaluar)*2)))
              colnames(metrics) <- c("Gauge","Run ID",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Type","Period")
              
              metrics[,1]=uniqueGauges
              metrics[,2]=runID
              
              for (g in 1:length(uniqueGauges)){
                
                try({
                  
                  filesub=file[file$Gauge==uniqueGauges[g],]
                  total=nrow(filesub)
                  
                  filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                  r1=nrow(filesubt)
                  DatesRegister=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                  
                  metrics[g,"Period"]=DatesRegister
                  
                  n=round(nrow(filesubt)*0.7,0)
                  
                  if (t==1){
                    
                    filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                    r1=nrow(filesubt)
                    
                    filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                    
                    total <- nrow(filewb)
                    DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                    DatesRegister
                    
                    metrics$Type="All"
                    
                  } else if (t==2) {
                    
                    filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                    filesubt=filesubt[1:n,]
                    r1=nrow(filesubt)
                    
                    filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                    total <- nrow(filewb)
                    DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                    DatesRegister
                    
                    metrics$Type="Calibration (70%)"
                    
                  } else {
                    
                    filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                    filesubt=filesubt[(n+1):nrow(filesubt),]
                    r1=nrow(filesubt)
                    
                    filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                    total <- nrow(filewb)
                    DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                    DatesRegister
                    
                    
                    metrics$Type="Validation (30%)"
                    
                  }
                  
                  filesub=filewb
                  Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
                  Filemonthly$N=1
                  Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
                  Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
                  Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
                  Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
                  Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
                  metrics[g,(7+length(errorEvaluar)*2):(7+2*length(errorEvaluar)+3)]=Filemonthly[1,7:10]
                  
                  filesub=filesubt
                  r=nrow(filesub)
                  modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
                  observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
                  
                  filesub$Modeled[which(filesub$Modeled ==0)]=NA
                  filesub$Observed[which(filesub$Observed ==0)]=NA
                  filesub=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                  modeledlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Modeled,10)
                  observedlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Observed,10)
                  
                  if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
                    error=gof(modeled,observed,na.rm=TRUE)
                    metrics[g,3:(2+length(errorEvaluar))]=round(error[errorEvaluar],3)
                    errorLOG=gof(modeledlog,observedlog,digits=5,na.rm=TRUE)
                    metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=round(errorLOG[errorEvaluar],3)
                  } else {
                    metrics[g,3:(2+length(errorEvaluar))]=NA
                    metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=NA
                  }
                  metrics$PeriodGOF[g]=DatesRegister
                  metrics[g,2+length(errorEvaluar)*2+1]=min(na.exclude(filesub$Observed))/min( na.exclude(filesub$Modeled))*100   
                  metrics[g,2+length(errorEvaluar)*2+2]=mean(na.exclude(filesub$Observed))/mean( na.exclude(filesub$Modeled))*100   
                  metrics[g,2+length(errorEvaluar)*2+3]=max(na.exclude(filesub$Observed))/max( na.exclude(filesub$Modeled))*100   
                  
                  
                })  
                
                
              }
              
              metricsAll=rbind(metricsAll,metrics)
              
              
            }
            
            metrics=metricsAll
            
            metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")]=round(metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")],2)
            cols <- c("Type","Period","Gauge","Run ID","PeriodGOF",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %")
            metrics=metrics[,cols]
            #write.csv(metrics,paste0("SummaryGOF_",as.character(input$dates[1]),"-",as.character(input$dates[2]),".csv"),row.names=F) 
            #write.csv(metrics,paste0("SummaryGOF_",".csv"),row.names=F) 
            
            
            metrics=metrics[metrics$Gauge==gs,]
            DT::datatable(metrics, rownames= FALSE)
            
          })
        })               
        
        if (file.exists(paste0("KeyModelInputs.csv"))){
          shinyjs::show("metricsp")
          keysset <- read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors =F,check.names=F)
          keysset <- keysset[which(keysset[,1]==as.numeric(runID)),]
          output$metricsp <- DT::renderDataTable({
            DT::datatable(keysset, rownames= FALSE)
          })
        } 
        
        file = file1
        #gs=unique(file$Gauge)[1]
        filesub=file[file$Gauge==gs,]
        filesub$Observed=filesub$Observed/filesub$Days/86400
        filesub$Modeled=filesub$Modeled/filesub$Days/86400
        filesub=filesub[order(filesub$Year,filesub$`Time step`),]
        
        try({
          output$Q <- renderPlotly({
            
            p <-plot_ly(filesub, x=~Dates, y=~Observed, name = "Observed", type="scatter", mode="lines",
                        line = list(color="black",width=1.5)) %>%
              add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
              layout(title = paste0("Streamflow ",gs),
                     xaxis = list(title=""),
                     yaxis = list(title= "Q (M^3/s)"))
            p
            
            
          })
        })   
        
        try({
          output$Qmonthly <- renderPlotly({
            
            Qmonthly <- aggregate(filesub[,c("Observed","Modeled")], by=list(YearMonth=filesub$YearMonth),mean,na.rm=F)
            
            Qmonthly$Month=Qmonthly$YearMonth%%100
            
            Qmonthly <- aggregate(Qmonthly[,c("Observed","Modeled")], by=list(Month=Qmonthly$Month),mean,na.rm=T)
            
            pmonthly <- plot_ly(Qmonthly, x=~Month, y=~Observed, name = "Observed", showlegend=FALSE,type="scatter", mode="lines",
                                line = list(color="black",width=1.5)) %>%
              add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
              layout(title = paste0("Streamflow (Monthly Average) ",gs),
                     xaxis = list(title=""),
                     yaxis = list(title= "Q (M^3/s)"))
            pmonthly
            
          })
        })   
        
        try({
          output$fdc <- renderPlotly({
            
            prob <- seq(1:100)
            obs.cdf <- rep(0,100)
            sim.cdf <- rep(0,100)
            obs.cdf <- quantile(filesub$Observed, prob/100,na.rm=T)
            sim.cdf <- quantile(filesub$Modeled, prob/100,na.rm=T)
            
            table <- as.data.frame(cbind(c(1:100),obs.cdf,sim.cdf))
            row.names(table) <- NULL
            colnames(table)[1] <- "Prob"
            
            fdc <- plot_ly(table,x=~Prob, y=~obs.cdf,type="scatter",name="Observed",showlegend=FALSE,mode="lines",line = list(color='black',width=1.5))%>%
              add_trace(y=~sim.cdf,name="Modeled", line=list(color="red",width=1.5, dash='dot'))%>%
              layout(title =paste0("Flow Duration Curve ",gs),yaxis = list(title="Q (M^3)"),xaxis=list(title="Probability (%)"))
            fdc
          })
        })               
        
        file = file1
        #gs=unique(file$Gauge)[1]
        filesub=file[file$Gauge==gs,]
        #str(filesub)
        filesub[,4:14]=round(filesub[,4:14]/filesub[,15]*1000,2)
        filesub[,11]=-1*filesub[,11]
        filesub$SM=filesub[,11]+filesub[,12]
        filesub$Interflow2 <- filesub$Interflow+filesub$Base_Flow
        filesub$SurfaceRunoff2 <- filesub$Surface_Runof + filesub$Interflow2
        filesub$Evapotranspiration2 <- filesub$Evapotranspiration + filesub$SurfaceRunoff2
        
        try({
          output$WB <- renderPlotly({
            
            pWB <- plot_ly(filesub, x=~Dates, y=~Precipitation, name="Precipitation", type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=0.5), text=~paste("Precip = ", Precipitation)) %>%
              add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
              add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
              add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
              add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
              layout(title = paste0("Water Balance ",gs),yaxis = list(title="mm"),  xaxis =list(title="Date"))
            
            pWB
          })
        })               
        try({
          output$WBSM <- renderPlotly({
            p5 <-plot_ly(filesub, x=~Dates, y=filesub[,"SM"], name="Decrease in Surface Storage", type = "bar",
                         text=~paste("Decrease Surface Storage = ", filesub$`Decrease in Surface Storage`)) %>%
              layout(title = paste0("Soil Moisture ",gs),
                     xaxis = list(title="Date"),
                     yaxis = list(title= "mm"))
            p5
          })
        })               
        try({
          output$WBSE <- renderPlotly({
            
            SMmonthly <- aggregate(filesub[,c("Decrease in Soil Moisture","Increase in Soil Moisture","SM")], by=list(YearMonth=filesub$YearMonth),mean,na.rm=F)
            SMmonthly$Month=SMmonthly$YearMonth%%100
            SMmonthly <- aggregate(SMmonthly[,c("Decrease in Soil Moisture","Increase in Soil Moisture","SM")], by=list(Month=SMmonthly$Month),mean,na.rm=T)
            
            p5 <- plot_ly(SMmonthly, x=~Month, y=SMmonthly[,"SM"], name = "Soil Moisture", showlegend=FALSE,type="bar",
                          text=~paste("Decrease Surface Storage = ", SMmonthly$SM)) %>%
              layout(title = paste0("Soil Moisture (Monthly Average) ",gs),
                     xaxis = list(title="Date"),
                     yaxis = list(title= "mm"))
            p5
            
            
          })
        })               
        try({
          output$WBmonthly <- renderPlotly({
            
            wbmonthly <- aggregate(filesub[,c(6:14,20:ncol(filesub))], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
            
            wbmonthly$Month=wbmonthly$YearMonth%%100
            
            wbmonthly <- aggregate(wbmonthly[,c(2:(ncol(wbmonthly)-1))], by=list(Month=wbmonthly$Month),mean,na.rm=T)
            
            p2monthly <- plot_ly(wbmonthly, x=~Month, y=~Precipitation, name="Precipitation", showlegend=TRUE, type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=1.5), text=~paste("Precip = ", Precipitation)) %>%
              add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
              add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
              add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
              add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
              layout(title =paste0("Water Balance Monthly Average ",gs),yaxis = list(title="mm"),xaxis=list(title="Months"))
            
            p2monthly
            
          })
        })               
        
        
        Filemonthly <- aggregate(filesub[,c("Precipitation","Evapotranspiration","Surface_Runoff","Interflow", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
        Filemonthly$Month=Filemonthly$YearMonth%%100
        Filemonthly <- aggregate(Filemonthly[,c("Precipitation","Evapotranspiration","Surface_Runoff","Interflow", "Base_Flow")], by=list(Month=Filemonthly$Month),mean,na.rm=T)
        Filemonthly$TotalRunoff=Filemonthly$Base_Flow+Filemonthly$Interflow+Filemonthly$Surface_Runoff
        #Filemonthly$Total2=Filemonthly$Total-Filemonthly$Modeled
        #summary(Filemonthly)
        Filemonthly$`Evapotranspiration/Precipitation%`=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
        Filemonthly$`SurfaceRunoff/TotalRunoff%`=round(Filemonthly$Surface_Runoff/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`Interflow/TotalRunoff%`=round(Filemonthly$Interflow/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`BaseFlow/TotalRunoff%`=round(Filemonthly$Base_Flow/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`TotalRunoff/Precipitation%`=round(Filemonthly$TotalRunoff/Filemonthly$Precipitation*100,1)
        #Filemonthly=Filemonthly[,-(2:6)]
        #str(Filemonthly)
        #colnames(Filemonthly)
        try({
          output$WBmonthlyB <- renderPlotly({
            
            
            p2monthly <- plot_ly(Filemonthly, x=~Month, y=~`TotalRunoff/Precipitation%`, name="TotalRunoff/Precipitation%", showlegend=TRUE, type="scatter",mode="line",text=~paste("TotalRunoff/Precipitation% = ", `TotalRunoff/Precipitation%`)) %>%
              add_trace(y=~`BaseFlow/TotalRunoff%`, name="BaseFlow/TotalRunoff%", type="scatter",mode="line",text=~paste("BaseFlow/TotalRunoff% = ", `BaseFlow/TotalRunoff%`)) %>%
              add_trace(y=~`Interflow/TotalRunoff%`, name="Interflow/TotalRunoff%", type="scatter",mode="line",text=~paste("Interflow/TotalRunoff% = ", `Interflow/TotalRunoff%`)) %>%
              add_trace(y=~`SurfaceRunoff/TotalRunoff%`, name="SurfaceRunoff/TotalRunoff%", type="scatter",mode="line",text=~paste("SurfaceRunoff/TotalRunoff% = ", `SurfaceRunoff/TotalRunoff%`)) %>%
              add_trace(y=~`Evapotranspiration/Precipitation%`, name="Evapotranspiration/Precipitation%", type="scatter",mode="line",text=~paste("Evapotranspiration/Precipitation% = ", `Evapotranspiration/Precipitation%`)) %>%
              layout(title =paste0("Percentages ",gs),yaxis = list(title="%"),xaxis=list(title="Months"))
            
            p2monthly
            
            
          })
        })  
        try({
          output$WBtable <- DT::renderDataTable({
            
            Filemonthly[,c(2:ncol(Filemonthly))] <- round(Filemonthly[,c(2:ncol(Filemonthly))],2)
            colnames(Filemonthly) <- c("Month","Precipitation (mm)","Evapotranspiration (mm)","Surface Runoff (mm)","Interflow (mm)","Base Flow (mm)",
                                       "Total Runoff (mm)",
                                       "Evapotranspiration / Precipitation %",
                                       "SurfaceRunoff / TotalRunoff %",
                                       "Interflow / TotalRunoff %",
                                       "BaseFlow / TotalRunoff %",
                                       "TotalRunoff / Precipitation %"
            )
            
            DT::datatable(Filemonthly, options = list(lengthMenu = c(12), pageLength = 12),rownames= FALSE)
            
          })
        }) 
      } 
      
      
    })
    
    observeEvent(input$graphs,{ 
      
      Model=VAL$Model2
      if (Model==1){
        start = Sys.time()
        
        withProgress(message = 'Calculation in progress',
                     detail = 'This may take a while...', value = 0, {
                       
                       Warea <- input$warea
                       Scen <- input$Scen
                       ts <- input$ts
                       Titles=input$titlesg
                       yearINI=input$datesgraph[1]
                       ey <-input$datesgraph[2]
                       dir=VAL$dir_outg
                       
                       #Titles="Spanish" #English 
                       # file=read.csv(paste0("ResultsWB-",1,".csv"), stringsAsFactors=F, check.names=F)
                       # yearINI= file$Dates[1]
                       # ey= file$Dates[nrow(file)]
                       #dir=paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/Results ",Warea)
                       
                       if (Titles=="Spanish"){
                         xtext="Fecha"
                       }else if (Titles=="English") {
                         xtext="Date"
                       }
                       
                       dates=c(ymd(as.Date(yearINI)),ymd(as.Date(ey)))
                       multiplot = function(..., plotlist=NULL, file, cols=1, layout=NULL) {
                         # Multiple plot function
                         #
                         # ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
                         # - cols:   Number of columns in layout
                         # - layout: A matrix specifying the layout. If present, 'cols' is ignored.
                         #
                         # If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
                         # then plot 1 will go in the upper left, 2 will go in the upper right, and
                         # 3 will go all the way across the bottom.
                         #
                         library(grid)
                         
                         # Make a list from the ... arguments and plotlist
                         plots = c(list(...), plotlist)
                         
                         numPlots = length(plots)
                         
                         # If layout is NULL, then use 'cols' to determine layout
                         if (is.null(layout)) {
                           # Make the panel
                           # ncol: Number of columns of plots
                           # nrow: Number of rows needed, calculated from # of cols
                           layout = matrix(seq(1, cols * ceiling(numPlots/cols)),
                                           ncol = cols, nrow = ceiling(numPlots/cols))
                         }
                         
                         if (numPlots==1) {
                           print(plots[[1]])
                           
                         } else {
                           # Set up the page
                           grid.newpage()
                           pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
                           
                           # Make each plot, in the correct location
                           for (i in 1:numPlots) {
                             # Get the i,j matrix positions of the regions that contain this subplot
                             matchidx = as.data.frame(which(layout == i, arr.ind = TRUE))
                             
                             print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                                             layout.pos.col = matchidx$col))
                           }
                         }
                       }
                       start = Sys.time()
                       
                       errorEvaluar=c(
                         1, #1.	me, Mean Error
                         2, #2.	mae, Mean Absolute Error
                         # 3, #3.	mse, Mean Squared Error
                         # 4, #4.	rmse, Root Mean Square Error
                         5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
                         6, #6.	PBIAS, Percent Bias
                         # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
                         # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
                         9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
                         10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
                         # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
                         12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
                         13,  #13.	md, Modified Index of Agreement 
                         # 14,#14.	rd, Relative Index of Agreement
                         # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
                         # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
                         17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
                         18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
                         19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
                         20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
                       ) 
                       names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                                     "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                                     "KGE" ,    "VE" ) 
                       names_errorg=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE" ,"PBIAS", "RSR"   ,  "rSD"  ,   "NSE" ,   
                                      "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                                      "KGE" ,    "VE" ) 
                       #names_error[errorEvaluar]
                       
                       
                       ################################################################################################
                       names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 
                       metricsALL=NULL
                       setwd(dir)
                       listResults=list.files(pattern ="ResultsWB-")
                       listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                       listResults=gsub(".csv","",listResults,fixed = TRUE)
                       listResults=unique(as.numeric(listResults))
                       listResults
                       file=read.csv(paste0("ResultsWB-",listResults[1],".csv"), stringsAsFactors=F, check.names=F)
                       total <-length(unique(file$Gauge))*length(listResults)
                       truns=length(listResults)+total+2
                       
                       incProgress(1/truns)
                       
                       if (length(listResults)>0){
                         runs <- length(listResults)
                         pbi=0
                         total <- runs
                         j=1
                         
                         for (j in listResults){
                           pbi=pbi+1
                           incProgress(1/truns)
                           print(paste0(pbi," of ", total))
                           setwd(dir)
                           
                           ########
                           #i=1
                           RUNID=j
                           
                           file=read.csv(paste0("ResultsWB-",RUNID,".csv"), stringsAsFactors=F, check.names=F)
                           
                           file$Dates=ymd(file$Dates)
                           file$YearMonth=year(file$Dates)*100+month(file$Dates)
                           file$Month=month(file$Dates)
                           
                           fileOrg=file
                           
                           filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]
                           days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                           #filesub=merge(filesub,days,by="Time step")
                           filesub1=filesub
                           
                           if (Titles=="Spanish"){
                             text=paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)")
                             
                           }else if (Titles=="English") {
                             text=paste0("Time serie: ","Modeled (blue) vs Observed (red)")
                             
                           }
                           
                           filesub1$Observed=filesub1$Observed/filesub1$Days/86400
                           filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400
                           p <- ggplot(filesub1, aes(x=Dates, y=Modeled)) + 
                             geom_line(color="blue",size=0.2)+
                             geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                             facet_wrap( ~ Gauge, scales = "free") +
                             ylab(paste0("[m3/s]"))+
                             xlab(xtext)+
                             ggtitle(text)
                           p
                           
                           plotpath = paste0(RUNID,"_Time series_sim vs obs_",paste(dates,collapse ="-"),".jpg") #creates a pdf path to produce a graphic of the span of records in the Data
                           ggsave(plotpath,width =40 , height = 22,units = "cm")
                           
                           
                         }
                         
                       }
                       ################################################################################################
                       runTimeGOF=difftime(Sys.time(),start)
                       runTimeGOF
                       
                       #procesaar graficas y GOF
                       ###############################################################################################
                       metricsALL <- NULL
                       setwd(dir)
                       listResults=list.files(pattern ="ResultsWB-")
                       listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                       listResults=gsub(".csv","",listResults,fixed = TRUE)
                       listResults=unique(as.numeric(listResults))
                       listResults
                       
                       if (length(listResults)>0){
                         
                         file=read.csv(paste0("ResultsWB-",listResults[1],".csv"), stringsAsFactors=F, check.names=F)
                         names=sort(unique(file$Gauge))
                         total <-length(unique(file$Gauge))*length(listResults)
                         pbi=0
                         f=1
                         
                         for (f in listResults){
                           
                           #Graficas
                           ##################
                           setwd(dir)
                           Carpeta_Out=paste0(f,"_Graphs_",paste(dates,collapse ="-"))
                           dir.create(Carpeta_Out,showWarnings=F)
                           dir_file=paste(c(dir,"\\",Carpeta_Out),collapse="")
                           
                           year1 = yearINI
                           year2= ey
                           
                           RUNID=f
                           
                           file=read.csv(paste0("ResultsWB-",RUNID,".csv"), stringsAsFactors=F, check.names=F)
                           file$Dates=ymd(file$Dates)
                           file$YearMonth=year(file$Dates)*100+month(file$Dates)
                           file$Month=month(file$Dates)
                           filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]
                           
                           days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                           #filesub=merge(filesub,days,by="Time step")
                           
                           days$Dates=NA
                           days$Dates[1]=as.Date("1981/01/01")
                           for (d in 2:nrow(days)) {
                             days$Dates[d]=days$Dates[d-1]+days$Days[d-1]
                           }
                           days$Dates=as.Date(days$Dates)
                           
                           filesub1=filesub
                           filesub1$Observed=filesub1$Observed/filesub1$Days/86400
                           filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400
                           
                           obsFile=filesub1[,c("Time step","Dates","Gauge","Observed")]
                           simFile=filesub1[,c("Time step","Dates","Gauge","Modeled")]
                           obsFile = obsFile %>% pivot_wider(names_from = Gauge, values_from = Observed)
                           simFile = simFile %>% pivot_wider(names_from = Gauge, values_from = Modeled)
                           obsFile=obsFile[order(obsFile$Dates),]
                           simFile=simFile[order(simFile$Dates),]
                           
                           GofGrafica=names_errorg[errorEvaluar]
                           GofTabla=names_error[errorEvaluar]
                           
                           obsv=as.data.frame(obsFile[,names])
                           simv=as.data.frame(simFile[,names])
                           
                           setwd(dir_file)
                           Carpeta_Out="SimObs_All"
                           dir.create(Carpeta_Out,showWarnings=F)
                           dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                           setwd(dir_file1)
                           
                           
                           filesub1=filesub1[,c("Time step","Dates","Gauge","Modeled","Observed","Year")]
                           
                           if (Titles=="Spanish"){
                             text=paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)")
                             
                           }else if (Titles=="English") {
                             text=paste0("Time serie: ","Modeled (blue) vs Observed (red)")
                             
                           }
                           
                           p <- ggplot(filesub1, aes(x=Dates, y=Modeled)) + 
                             geom_line(color="blue",size=0.2)+
                             geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                             facet_wrap( ~ Gauge, scales = "free") +
                             ylab(paste0("[m3/s]"))+
                             xlab(xtext)+
                             ggtitle(text)
                           p
                           
                           ggsave("TimeSeries.jpg",width =40 , height = 22,units = "cm")
                           
                           try({
                             filesub1$monthyear=floor_date(filesub1$Dates, "month")
                             filesub1 <- filesub1[order(filesub1$Gauge,filesub1$Dates),]
                             
                             df=filesub1
                             df_d=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, `Time step`=df$`Time step`),mean, na.rm=TRUE)
                             df_d=df_d[order(df_d$Gauge,df_d$`Time step`),]
                             
                             write.csv(df_d,"MultiannualTimeStepMean_LongFormat.csv",row.names=FALSE,na="")
                             
                             df_d = merge(df_d,days,by="Time step")
                             df_d=df_d[order(df_d$Gauge,df_d$Dates),]
                             #dfsim_d$date = format(dfsim_d$date, "%b %d")
                             
                             if (ts==365){
                               
                               if (Titles=="Spanish"){
                                 text=paste0("Promedio Diario Multianual: ","Modelado (azul) vs Observado (rojo)")
                               }else if (Titles=="English") {
                                 text=paste0("Multiannual Daily Mean: ","Modeled (blue) vs Observed (red)")
                               }
                               
                             } else {
                               if (Titles=="Spanish"){
                                 text=paste0("Promedio a paso de tiempo Multianual: ","Modelado (azul) vs Observado (rojo)")
                               }else if (Titles=="English") {
                                 text=paste0("Multiannual Time Step Mean: ","Modeled (blue) vs Observed (red)")
                               }
                               
                             }
                             
                             
                             p <- ggplot(df_d, aes(x=Dates, y=Modeled)) + 
                               geom_line(color="blue",size=0.2)+
                               geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                               facet_wrap( ~ Gauge, scales = "free") +
                               ylab(paste0("[m3/s]"))+
                               xlab(xtext)+
                               ggtitle(text)
                             p= p + scale_x_date(date_labels = "%b/%d")
                             p
                             ggsave("Multiannual time step Mean.jpg",width =40 , height = 22,units = "cm")
                           })  
                           
                           try({
                             df=filesub1
                             df_m=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, monthyear=df$monthyear),mean, na.rm=TRUE)
                             df_m$month <- month(df_m$monthyear)
                             df_m=aggregate(df_m[,c("Modeled","Observed")],list(Gauge=df_m$Gauge, month=df_m$month),mean, na.rm=TRUE)
                             df_m=df_m[order(df_m$Gauge,df_m$month),]
                             write.csv(df_m,"MultiannualMonthlyMean_LongFormat.csv",row.names=FALSE,na="")
                             
                             Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                             Dates=as.data.frame(Dates)
                             Dates$month=month(Dates$Dates)
                             
                             df_m = merge(df_m,Dates,by="month")
                             df_m=df_m[order(df_m$Gauge,df_m$month),]
                             
                             if (Titles=="Spanish"){
                               text=paste0("Promedio Mensual Multianual: ","Modelado (azul) vs Observado (rojo)")
                               
                             }else if (Titles=="English") {
                               text=paste0("Multiannual Monthly Mean: ","Modeled (blue) vs Observed (red)")
                               
                             }
                             
                             p <- ggplot(df_m, aes(x=Dates, y=Modeled)) + 
                               geom_line(color="blue",size=0.2)+
                               geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                               facet_wrap( ~ Gauge, scales = "free") +
                               ylab(paste0("[m3/s]"))+
                               xlab(xtext)+
                               ggtitle(text)
                             p= p + scale_x_date(date_labels = "%B")
                             p 
                             ggsave("Multiannual Monthly Mean.jpg",width =40 , height = 22,units = "cm")
                             
                           })
                           
                           try({
                             df=filesub1
                             df_m=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, Year=df$Year),mean, na.rm=TRUE)
                             df_m=df_m[order(df_m$Gauge,df_m$Year),]
                             write.csv(df_m,"AnnualMean_LongFormat.csv",row.names=FALSE,na="")
                             
                             Dates=seq(as.Date(paste(c(min(df_m$Year),"/",01,"/",01),collapse="")),as.Date(paste(c(max(df_m$Year),"/",12,"/",31),collapse="") ), by = "year")
                             Dates=as.data.frame(Dates)
                             Dates$Year=year(Dates$Dates)
                             
                             df_m = merge(df_m,Dates,by="Year")
                             df_m=df_m[order(df_m$Gauge,df_m$Year),]
                             
                             if (Titles=="Spanish"){
                               text=paste0("Promedio Anual: ","Modelado (azul) vs Observado (rojo)")
                               
                             }else if (Titles=="English") {
                               text=paste0("Annual Mean: ","Modeled (blue) vs Observed (red)")
                               
                             }
                             
                             p <- ggplot(df_m, aes(x=Dates, y=Modeled)) + 
                               geom_line(color="blue",size=0.2)+
                               geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                               facet_wrap( ~ Gauge, scales = "free") +
                               ylab(paste0("[m3/s]"))+
                               xlab(xtext)+
                               ggtitle(text)
                             p= p + scale_x_date(date_labels = "%B")
                             p 
                             ggsave("Multiannual Monthly Mean.jpg",width =40 , height = 22,units = "cm")
                           })
                           
                           ##################
                           i=1
                           for (i in 1:length(names)){
                             
                             name <- names[i]
                             pbi=pbi+1
                             
                             incProgress(1/truns)
                             print(paste0(pbi," of ",total)) #," Estacion ", name
                             
                             if (length(which(is.na(obsv[,i])==TRUE))<length(obsv[,i])){
                               
                               obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                               sim = zoo(simv[,i],as.Date(simFile$Dates))
                               
                               if (ts==12){
                                 
                                 try({
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_ma"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, ftype="ma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                   #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                                   dev.off()
                                 })
                                 
                               } else if (ts==365){
                                 
                                 try({
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_dma"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, ftype="dma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                   #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                                   dev.off()
                                 })
                                 
                                 try({
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_seasons"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, ftype="seasonal", season.names=c("", "", "", ""),na.rm=TRUE,FUN=mean, leg.cex=1.2, pch = c(20, 18),main = name, ylab=c("Q[m3/s]"))
                                   dev.off()
                                 })
                                 
                                 
                               } 
                               
                               try({
                                 setwd(dir_file)
                                 Carpeta_Out="SimObs_original"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 ggof(sim=sim, obs=obs, FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), xlab=xtext,pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                 #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                                 dev.off()
                               })
                               
                               try({   
                                 if (ts==365){
                                   df <- data.frame(date = as.Date(simFile$Dates), Gauge = simv[,i],timestep=simFile$`Time step`)
                                   df$monthyear=floor_date(df$date, "month")
                                   
                                   df_d=as.data.frame(df %>%
                                                        group_by(timestep) %>%
                                                        summarize(mean = mean(Gauge ,na.rm = TRUE)))
                                   
                                   
                                   df_d = merge(df_d,days,by.x="timestep",by.y = "Time step")
                                   df_d=df_d[order(df_d$Dates),]
                                   
                                   dfsim_d=df_d
                                   
                                   ###
                                   df <- data.frame(date = as.Date(obsFile$Dates), Gauge = obsv[,i],timestep=obsFile$`Time step`)
                                   df$monthyear=floor_date(df$date, "month")
                                   
                                   df_d=as.data.frame(df %>%
                                                        group_by(timestep) %>%
                                                        summarize(mean = mean(Gauge ,na.rm = TRUE)))
                                   
                                   
                                   df_d = merge(df_d,days,by.x="timestep",by.y = "Time step")
                                   df_d=df_d[order(df_d$Dates),]
                                   
                                   dfobs_d=df_d
                                   
                                   #grafica medios diarios multianuales
                                   obs = zoo(dfobs_d[,2],dfobs_d[,4])
                                   sim = zoo(dfsim_d[,2],dfsim_d[,4])
                                   
                                   if (Titles=="Spanish"){
                                     text=paste0("Promedio Diario Multianual")
                                   }else if (Titles=="English") {
                                     text=paste0("Multiannual Daily Mean")
                                   }
                                   
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_MultiannualDaily"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, lab.fmt="%b %d", ftype="o",tick.tstep = "days", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- ",text), xlab=xtext, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                   dev.off()
                                   
                                 }
                               })
                               
                               try({  
                                 #sim
                                 df <- data.frame(date = as.Date(simFile$Dates), Caudal = simv[,i])
                                 df$monthyear=floor_date(df$date, "month")
                                 #tail(df)
                                 
                                 df_m=as.data.frame(df %>%
                                                      group_by(monthyear) %>%
                                                      summarize(mean = mean(Caudal,na.rm = TRUE)))
                                 df_m$month <- month(df_m$monthyear)
                                 df_m=as.data.frame(df_m %>%
                                                      group_by(month) %>%
                                                      summarize(mean = mean(mean,na.rm = TRUE)))
                                 
                                 Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                                 Dates=as.data.frame(Dates)
                                 Dates$month=month(Dates$Dates)
                                 
                                 df_m=merge(df_m,Dates,by="month")
                                 dfsim_m=df_m
                                 
                                 #obs
                                 df <- data.frame(date = as.Date(obsFile$Dates), Caudal = obsv[,i])
                                 df$monthyear=floor_date(df$date, "month")
                                 
                                 df_m=as.data.frame(df %>%
                                                      group_by(monthyear) %>%
                                                      summarize(mean = mean(Caudal,na.rm = TRUE)))
                                 df_m$month <- month(df_m$monthyear)
                                 df_m=as.data.frame(df_m %>%
                                                      group_by(month) %>%
                                                      summarize(mean = mean(mean,na.rm = TRUE)))
                                 
                                 Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                                 Dates=as.data.frame(Dates)
                                 Dates$month=month(Dates$Dates)
                                 
                                 df_m=merge(df_m,Dates,by="month")
                                 dfobs_m=df_m
                                 
                                 #grafica medios mensuales multianuales
                                 obs = zoo(dfobs_m[,2],dfobs_m[,3])
                                 sim = zoo(dfsim_m[,2],dfsim_m[,3])
                                 
                                 if (Titles=="Spanish"){
                                   text=paste0("Promedio Mensual Multianual")
                                 }else if (Titles=="English") {
                                   text=paste0("Multiannual Monthly Mean")
                                 }
                                 setwd(dir_file)
                                 Carpeta_Out="SimObs_MultiannualMonthly"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 ggof(sim=sim, obs=obs, lab.fmt="%b", ftype="o",tick.tstep = "months", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- ",text), xlab=xtext, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                 dev.off()
                                 
                               })
                               
                               #residuales
                               obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                               sim = zoo(simv[,i],as.Date(simFile$Dates))
                               
                               try({
                                 setwd(dir_file)
                                 Carpeta_Out="Sim"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 hydroplot(sim, FUN=mean,var.unit="m3/s",main=paste0(name," Simu"),xlab="",na.rm=TRUE)
                                 dev.off()
                               })
                               
                               try({
                                 setwd(dir_file)
                                 Carpeta_Out="Obs"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 hydroplot(obs, FUN=mean,var.unit="m3/s",main=paste0(name," Obs"),xlab="",na.rm=TRUE)
                                 dev.off()
                               })
                               
                               try({
                                 r <- sim-obs
                                 smry(r)
                                 setwd(dir_file)
                                 Carpeta_Out="SimObs_residuals"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 hydroplot(r, FUN=mean,var.unit="m3/s",main=paste0(name," Residual"),xlab="",na.rm=TRUE)
                                 dev.off()
                               })
                               #metricas en tabla
                               
                               metrics=NULL
                               obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                               sim = zoo(simv[,i],as.Date(simFile$Dates))
                               
                               
                               if (ts==365){
                                 
                                 try({
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Diario"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Daily"
                                   }
                                   
                                   metrics=rbind(metrics,m)
                                 })
                                 
                                 try({
                                   sim = daily2monthly.zoo(sim, FUN = mean)
                                   obs = daily2monthly.zoo(obs, FUN = mean)
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Mensual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Monthly"
                                   }
                                   
                                   metrics=rbind(metrics,m)
                                 })
                                 
                                 try({
                                   sim = monthly2annual(sim, FUN = mean)
                                   obs = monthly2annual(obs, FUN = mean)
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Anual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Annual"
                                   }
                                   metrics=rbind(metrics,m)  
                                 })
                                 
                                 try({
                                   m <- gof(sim=dfsim_d[,2], obs=dfobs_d[,2])
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Medio Diario multianual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Multiannual Daily Mean"
                                   }
                                   metrics=rbind(metrics,m)
                                 })
                               }
                               
                               if (ts==12){
                                 try({
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Mensual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Monthly"
                                   }
                                   metrics=rbind(metrics,m)
                                 })
                                 
                                 try({
                                   
                                   sim = monthly2annual(sim, FUN = mean)
                                   obs = monthly2annual(obs, FUN = mean)
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Anual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Annual"
                                   }
                                   metrics=rbind(metrics,m)  
                                 })
                                 
                                 try({
                                   m <- gof(sim=dfsim_m[,2], obs=dfobs_m[,2])
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Medio Mensual multianual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Multiannual Monthly Mean"
                                   }
                                   metrics=rbind(metrics,m)
                                 })
                               } else {
                                 try({
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Paso de tiempo del modelo"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Model Time Step"
                                   }
                                   
                                   metrics=rbind(metrics,m)
                                 })
                               }
                               
                               metrics$ID=f
                               
                             }
                             
                             
                             metricsALL=rbind(metricsALL,metrics)
                             
                           }
                           try({
                             setwd(dir)
                             metricas <- subset(metricsALL, Metricas %in% GofTabla)
                             colnames(metricas)=c("Valor", "GOF", "Estacion", "Tipo" ,    "Run ID"  )
                             metricas=metricas[,c("Run ID", "Tipo","Estacion", "GOF","Valor")]
                             
                             if (Titles=="English") {
                               colnames(metricas)=c("Run ID", "Type","Gauge", "GOF","Value")
                             }
                             
                             write.csv(metricas, paste0("SummaryGOF2_",paste(dates,collapse ="-"),".csv"),row.names = FALSE)
                             
                           })
                         }
                       }
                       ################################################################################################
                       runTimeGOF2=difftime(Sys.time(),start)
                       runTimeGOF2
                       
                       ##############################################################
                       
                       output$textRunEnsemblegraph <- renderText({
                         outTxt = ""
                         text=paste0("Graphs exported. Check ", dir,". Time: ")
                         formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                         outTxt = paste0(outTxt, formatedFont)
                         
                         text=format(as.difftime(difftime(Sys.time(),start), format = "%H:%M")) 
                         formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                         outTxt = paste0(outTxt, formatedFont)
                         
                         outTxt
                         
                         
                       })
                       
                       
                       incProgress(1/truns)
                       
                     })
      }
      
    })
    ###################################### 
    
    ###################################### 
    observe({
      
      Model=VAL$Model2 
      req(input$StreamflowSelect1)
      gs=input$StreamflowSelect1
      runID=as.numeric(input$SliderWB1)
      file=NULL
      name=NULL
      
      if (file.exists(paste0("KeyModelInputs.csv")) &&  Model==1){
        keysset <- read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
        
        name=paste0("ResultsWB-",as.character(runID),".csv")
        
        if (file.exists(name)){
          file <- read.csv(name, stringsAsFactors=F, check.names=F)
          file$Dates=ymd(file$Dates)
          #gauge=unique(file$Gauge)[1]
          #file=file[file$Gauge==gauge,]
          file=file[file$Gauge==gs,]
          file$YearMonth=year(file$Dates)*100+month(file$Dates)
          file$Month=month(file$Dates)
          file <- file[which(file$Dates >= input$dates1[1] & file$Dates <= input$dates1[2]),]
          uniqueGauges=sort(unique(file$Gauge))
        } else {
          name=NULL
        }
        
      } else if (length(list.files(pattern ="ResultsWB-"))==1 &&  Model==1) {    
        
        runID=1
        name=paste0("ResultsWB-",as.character(runID),".csv")
        file <- read.csv(name, stringsAsFactors=F, check.names=F)
        file$Dates=ymd(file$Dates)
        #gauge=unique(file$Gauge)[1]
        #file=file[file$Gauge==gauge,]
        file=file[file$Gauge==gs,]
        file$YearMonth=year(file$Dates)*100+month(file$Dates)
        file$Month=month(file$Dates)
        file <- file[which(file$Dates >= input$dates1[1] & file$Dates <= input$dates1[2]),]
        uniqueGauges=sort(unique(file$Gauge))
      }
      
      print(runID)
      runID=as.character(runID)
      VAL$runID=runID
     
      file1=file
      
      # output$keys <- renderPrint({
      #   name
      # })
      
      if (!is.null(name)){
         
        try({
          output$metrics1 <- DT::renderDataTable({
            
            #file <- read.csv(paste0("ResultsWB-",runID,".csv"), stringsAsFactors=F, check.names=F)
            
            file = file1
            file$Dates=ymd(file$Dates)
            file$YearMonth=year(file$Dates)*100+month(file$Dates)
            file$Month=month(file$Dates)
            #unique(file$Gauge)
            
            errorEvaluar=c(
              1, #1.	me, Mean Error
              2, #2.	mae, Mean Absolute Error
              # 3, #3.	mse, Mean Squared Error
              # 4, #4.	rmse, Root Mean Square Error
              5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
              6, #6.	PBIAS, Percent Bias
              # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
              # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
              9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
              10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
              # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
              12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
              13,  #13.	md, Modified Index of Agreement 
              # 14,#14.	rd, Relative Index of Agreement
              # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
              # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
              17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
              18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
              19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
              20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
            ) 
            names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                          "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                          "KGE" ,    "VE" ) 
            #names_error[errorEvaluar]
            
            names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 
            
            #1.	me, Mean Error
            #2.	mae, Mean Absolute Error
            #3.	mse, Mean Squared Error
            #4.	rmse, Root Mean Square Error
            #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
            #6.	PBIAS, Percent Bias
            #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
            #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
            #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
            #10.	mNSE, Modified Nash-Sutcliffe Efficiency
            #11.	rNSE, Relative Nash-Sutcliffe Efficiency
            #12.	d, Index of Agreement ( 0 <= d <= 1 )
            #13.	md, Modified Index of Agreement
            #14.	rd, Relative Index of Agreement
            #15.	cp, Persistence Index ( 0 <= PI <= 1 )
            #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
            #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
            #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
            #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
            #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
            
            
            
            metricsAll=NULL
            
            for (t in 1:3){
              
              metrics=as.data.frame(matrix(nrow=length(uniqueGauges),ncol=(12+length(errorEvaluar)*2)))
              colnames(metrics) <- c("Gauge","Run ID",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Type","Period")
              
              metrics[,1]=uniqueGauges
              metrics[,2]=runID
              
              for (g in 1:length(uniqueGauges)){
                
                try({
                  
                  filesub=file[file$Gauge==uniqueGauges[g],]
                  total=nrow(filesub)
                  
                  filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                  r1=nrow(filesubt)
                  DatesRegister=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                  
                  metrics[g,"Period"]=DatesRegister
                  
                  n=round(nrow(filesubt)*0.7,0)
                  
                  
                  if (t==1){
                    
                    filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                    r1=nrow(filesubt)
                    
                    filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                    
                    total <- nrow(filewb)
                    DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                    DatesRegister
                    
                    metrics$Type="All"
                    
                  } else if (t==2) {
                    
                    filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                    filesubt=filesubt[1:n,]
                    r1=nrow(filesubt)
                    
                    filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                    total <- nrow(filewb)
                    DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                    DatesRegister
                    
                    metrics$Type="Calibration (70%)"
                    
                  } else {
                    
                    filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                    filesubt=filesubt[(n+1):nrow(filesubt),]
                    r1=nrow(filesubt)
                    
                    filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                    total <- nrow(filewb)
                    DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                    DatesRegister
                    
                    
                    metrics$Type="Validation (30%)"
                    
                  }
                  
                  filesub=filewb
                  Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
                  Filemonthly$N=1
                  Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
                  Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
                  Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
                  Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
                  Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
                  metrics[g,(7+length(errorEvaluar)*2):(7+2*length(errorEvaluar)+3)]=Filemonthly[1,7:10]
                  
                  filesub=filesubt
                  r=nrow(filesub)
                  modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
                  observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
                  
                  filesub$Modeled[which(filesub$Modeled ==0)]=NA
                  filesub$Observed[which(filesub$Observed ==0)]=NA
                  filesub=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                  modeledlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Modeled,10)
                  observedlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Observed,10)
                  
                  if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
                    error=gof(modeled,observed,na.rm=TRUE)
                    metrics[g,3:(2+length(errorEvaluar))]=round(error[errorEvaluar],3)
                    errorLOG=gof(modeledlog,observedlog,digits=5,na.rm=TRUE)
                    metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=round(errorLOG[errorEvaluar],3)
                  } else {
                    metrics[g,3:(2+length(errorEvaluar))]=NA
                    metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=NA
                  }
                  metrics$PeriodGOF[g]=DatesRegister
                  metrics[g,2+length(errorEvaluar)*2+1]=min(na.exclude(filesub$Observed))/min( na.exclude(filesub$Modeled))*100   
                  metrics[g,2+length(errorEvaluar)*2+2]=mean(na.exclude(filesub$Observed))/mean( na.exclude(filesub$Modeled))*100   
                  metrics[g,2+length(errorEvaluar)*2+3]=max(na.exclude(filesub$Observed))/max( na.exclude(filesub$Modeled))*100   
                  
                  
                  
                })  
                
                
              }
              
              metricsAll=rbind(metricsAll,metrics)
              
              
            }
            
            metrics=metricsAll
            
            
            metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")]=round(metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")],2)
            cols <- c("Type","Period","Gauge","Run ID","PeriodGOF",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %")
            metrics=metrics[,cols]
            #write.csv(metrics,paste0("SummaryGOF_",as.character(input$dates[1]),"-",as.character(input$dates[2]),".csv"),row.names=F) 
            
       
            metrics=metrics[metrics$Gauge==gs,]
            DT::datatable(metrics, rownames= FALSE)
            
          })
        }) 
        
        if (file.exists(paste0("KeyModelInputs.csv"))){
          
          keysset <- read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors =F,check.names=F)
          keysset <- keysset[which(keysset[,1]==as.numeric(runID)),]
          output$metricsp1 <- DT::renderDataTable({
            DT::datatable(keysset, rownames= FALSE)
          })
        }
        
        file = file1
        #gs=unique(file$Gauge)[1]
        filesub=file[file$Gauge==gs,]
        #days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
        #filesub=merge(filesub,days,by="Time step")
        filesub$Observed=filesub$Observed/filesub$Days/86400
        filesub$Modeled=filesub$Modeled/filesub$Days/86400
        filesub=filesub[order(filesub$Year,filesub$`Time step`),]
        
        try({
          output$Q1 <- renderPlotly({
            
            p <-plot_ly(filesub, x=~Dates, y=~Observed, name = "Observed", type="scatter", mode="lines",
                        line = list(color="black",width=1.5)) %>%
              add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
              layout(title = paste0("Streamflow ",gs),
                     xaxis = list(title=""),
                     yaxis = list(title= "Q (M^3/s)"))
            p
            
            
          })
        }) 
        try({
          output$Qmonthly1 <- renderPlotly({
            
            Qmonthly <- aggregate(filesub[,c("Observed","Modeled")], by=list(YearMonth=filesub$YearMonth),mean,na.rm=F)
            
            Qmonthly$Month=Qmonthly$YearMonth%%100
            
            Qmonthly <- aggregate(Qmonthly[,c("Observed","Modeled")], by=list(Month=Qmonthly$Month),mean,na.rm=T)
            
            pmonthly <- plot_ly(Qmonthly, x=~Month, y=~Observed, name = "Observed", showlegend=FALSE,type="scatter", mode="lines",
                                line = list(color="black",width=1.5)) %>%
              add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
              layout(title = paste0("Streamflow (Monthly Average) ",gs),
                     xaxis = list(title=""),
                     yaxis = list(title= "Q (M^3/s)"))
            pmonthly
            
          })
        }) 
        try({
          output$fdc1 <- renderPlotly({
            
            prob <- seq(1:100)
            obs.cdf <- rep(0,100)
            sim.cdf <- rep(0,100)
            obs.cdf <- quantile(filesub$Observed, prob/100,na.rm=T)
            sim.cdf <- quantile(filesub$Modeled, prob/100,na.rm=T)
            
            table <- as.data.frame(cbind(c(1:100),obs.cdf,sim.cdf))
            row.names(table) <- NULL
            colnames(table)[1] <- "Prob"
            
            fdc <- plot_ly(table,x=~Prob, y=~obs.cdf,type="scatter",name="Observed",showlegend=FALSE,mode="lines",line = list(color='black',width=1.5))%>%
              add_trace(y=~sim.cdf,name="Modeled", line=list(color="red",width=1.5, dash='dot'))%>%
              layout(title =paste0("Flow Duration Curve ",gs),yaxis = list(title="Q (M^3)"),xaxis=list(title="Probability (%)"))
            fdc
          })
        }) 
        
        file = file1
        #gs=unique(file$Gauge)[1]
        filesub=file[file$Gauge==gs,]
        #str(filesub)
        filesub[,4:14]=round(filesub[,4:14]/filesub[,15]*1000,2)
        filesub[,11]=-1*filesub[,11]
        filesub$SM=filesub[,11]+filesub[,12]
        filesub$Interflow2 <- filesub$Interflow+filesub$Base_Flow
        filesub$SurfaceRunoff2 <- filesub$Surface_Runof + filesub$Interflow2
        filesub$Evapotranspiration2 <- filesub$Evapotranspiration + filesub$SurfaceRunoff2
        
        try({
          output$WB1 <- renderPlotly({
            
            pWB <- plot_ly(filesub, x=~Dates, y=~Precipitation, name="Precipitation", type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=0.5), text=~paste("Precip = ", Precipitation)) %>%
              add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
              add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
              add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
              add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
              layout(title = paste0("Water Balance ",gs),yaxis = list(title="mm"),  xaxis =list(title="Date"))
            
            pWB
          })
        }) 
        try({
          output$WBSM1 <- renderPlotly({
            p5 <-plot_ly(filesub, x=~Dates, y=filesub[,"SM"], name="Decrease in Surface Storage", type = "bar",
                         text=~paste("Decrease Surface Storage = ", filesub$`Decrease in Surface Storage`)) %>%
              layout(title = paste0("Soil Moisture ",gs),
                     xaxis = list(title="Date"),
                     yaxis = list(title= "mm"))
            p5
          })
        }) 
        try({
          output$WBSE1 <- renderPlotly({
            
            SMmonthly <- aggregate(filesub[,c("Decrease in Soil Moisture","Increase in Soil Moisture","SM")], by=list(YearMonth=filesub$YearMonth),mean,na.rm=F)
            SMmonthly$Month=SMmonthly$YearMonth%%100
            SMmonthly <- aggregate(SMmonthly[,c("Decrease in Soil Moisture","Increase in Soil Moisture","SM")], by=list(Month=SMmonthly$Month),mean,na.rm=T)
            
            p5 <- plot_ly(SMmonthly, x=~Month, y=SMmonthly[,"SM"], name = "Soil Moisture", showlegend=FALSE,type="bar",
                          text=~paste("Decrease Surface Storage = ", SMmonthly$SM)) %>%
              layout(title = paste0("Soil Moisture (Monthly Average) ",gs),
                     xaxis = list(title="Date"),
                     yaxis = list(title= "mm"))
            p5
            
            
          })
        }) 
        try({
          output$WBmonthly1 <- renderPlotly({
            
            wbmonthly <- aggregate(filesub[,c(6:14,20:ncol(filesub))], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
            
            wbmonthly$Month=wbmonthly$YearMonth%%100
            
            wbmonthly <- aggregate(wbmonthly[,c(2:(ncol(wbmonthly)-1))], by=list(Month=wbmonthly$Month),mean,na.rm=T)
            
            p2monthly <- plot_ly(wbmonthly, x=~Month, y=~Precipitation, name="Precipitation", showlegend=TRUE, type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=1.5), text=~paste("Precip = ", Precipitation)) %>%
              add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
              add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
              add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
              add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
              layout(title =paste0("Water Balance Monthly Average ",gs),yaxis = list(title="mm"),xaxis=list(title="Months"))
            
            p2monthly
            
          })
        }) 
        
        Filemonthly <- aggregate(filesub[,c("Precipitation","Evapotranspiration","Surface_Runoff","Interflow", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
        Filemonthly$Month=Filemonthly$YearMonth%%100
        Filemonthly <- aggregate(Filemonthly[,c("Precipitation","Evapotranspiration","Surface_Runoff","Interflow", "Base_Flow")], by=list(Month=Filemonthly$Month),mean,na.rm=T)
        Filemonthly$TotalRunoff=Filemonthly$Base_Flow+Filemonthly$Interflow+Filemonthly$Surface_Runoff
        #Filemonthly$Total2=Filemonthly$Total-Filemonthly$Modeled
        #summary(Filemonthly)
        Filemonthly$`Evapotranspiration/Precipitation%`=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
        Filemonthly$`SurfaceRunoff/TotalRunoff%`=round(Filemonthly$Surface_Runoff/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`Interflow/TotalRunoff%`=round(Filemonthly$Interflow/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`BaseFlow/TotalRunoff%`=round(Filemonthly$Base_Flow/Filemonthly$TotalRunoff*100,1)
        Filemonthly$`TotalRunoff/Precipitation%`=round(Filemonthly$TotalRunoff/Filemonthly$Precipitation*100,1)
        #Filemonthly=Filemonthly[,-(2:6)]
        #str(Filemonthly)
        #colnames(Filemonthly)
        
        try({
          output$WBmonthlyB1 <- renderPlotly({
            
            p2monthly <- plot_ly(Filemonthly, x=~Month, y=~`TotalRunoff/Precipitation%`, name="TotalRunoff/Precipitation%", showlegend=TRUE, type="scatter",mode="line",text=~paste("TotalRunoff/Precipitation% = ", `TotalRunoff/Precipitation%`)) %>%
              add_trace(y=~`BaseFlow/TotalRunoff%`, name="BaseFlow/TotalRunoff%", type="scatter",mode="line",text=~paste("BaseFlow/TotalRunoff% = ", `BaseFlow/TotalRunoff%`)) %>%
              add_trace(y=~`Interflow/TotalRunoff%`, name="Interflow/TotalRunoff%", type="scatter",mode="line",text=~paste("Interflow/TotalRunoff% = ", `Interflow/TotalRunoff%`)) %>%
              add_trace(y=~`SurfaceRunoff/TotalRunoff%`, name="SurfaceRunoff/TotalRunoff%", type="scatter",mode="line",text=~paste("SurfaceRunoff/TotalRunoff% = ", `SurfaceRunoff/TotalRunoff%`)) %>%
              add_trace(y=~`Evapotranspiration/Precipitation%`, name="Evapotranspiration/Precipitation%", type="scatter",mode="line",text=~paste("Evapotranspiration/Precipitation% = ", `Evapotranspiration/Precipitation%`)) %>%
              layout(title =paste0("Percentages ",gs),yaxis = list(title="%"),xaxis=list(title="Months"))
            
            p2monthly
            
            
          })
        }) 
        try({
          output$WBtable1 <- DT::renderDataTable({
            
            Filemonthly[,c(2:ncol(Filemonthly))] <- round(Filemonthly[,c(2:ncol(Filemonthly))],2)
            colnames(Filemonthly) <- c("Month","Precipitation (mm)","Evapotranspiration (mm)","Surface Runoff (mm)","Interflow (mm)","Base Flow (mm)",
                                       "Total Runoff (mm)",
                                       "Evapotranspiration / Precipitation %",
                                       "SurfaceRunoff / TotalRunoff %",
                                       "Interflow / TotalRunoff %",
                                       "BaseFlow / TotalRunoff %",
                                       "TotalRunoff / Precipitation %"
            )
            
            DT::datatable(Filemonthly, options = list(lengthMenu = c(12), pageLength = 12),rownames= FALSE)
            
          })
        }) 
        
      } 
      
    })
    observeEvent(input$graphs1,{ 
      
      Model=VAL$Model2
      if (Model==1){
        start = Sys.time()
        
        withProgress(message = 'Calculation in progress',
                     detail = 'This may take a while...', value = 0, {
                       
                       Warea <- input$warea
                       Scen <- input$Scen
                       ts <- input$ts
                       Titles=input$titlesg1
                       yearINI=input$datesgraph1[1]
                       ey <-input$datesgraph1[2]
                       dir=VAL$dir_outg
                       
                       #Titles="Spanish" #English 
                       # file=read.csv(paste0("ResultsWB-",1,".csv"), stringsAsFactors=F, check.names=F)
                       # yearINI= file$Dates[1]
                       # ey= file$Dates[nrow(file)]
                       #dir=paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/Results ",Warea)
                       
                       if (Titles=="Spanish"){
                         xtext="Fecha"
                       }else if (Titles=="English") {
                         xtext="Date"
                       }
                       
                       dates=c(ymd(as.Date(yearINI)),ymd(as.Date(ey)))
                       multiplot = function(..., plotlist=NULL, file, cols=1, layout=NULL) {
                         # Multiple plot function
                         #
                         # ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
                         # - cols:   Number of columns in layout
                         # - layout: A matrix specifying the layout. If present, 'cols' is ignored.
                         #
                         # If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
                         # then plot 1 will go in the upper left, 2 will go in the upper right, and
                         # 3 will go all the way across the bottom.
                         #
                         library(grid)
                         
                         # Make a list from the ... arguments and plotlist
                         plots = c(list(...), plotlist)
                         
                         numPlots = length(plots)
                         
                         # If layout is NULL, then use 'cols' to determine layout
                         if (is.null(layout)) {
                           # Make the panel
                           # ncol: Number of columns of plots
                           # nrow: Number of rows needed, calculated from # of cols
                           layout = matrix(seq(1, cols * ceiling(numPlots/cols)),
                                           ncol = cols, nrow = ceiling(numPlots/cols))
                         }
                         
                         if (numPlots==1) {
                           print(plots[[1]])
                           
                         } else {
                           # Set up the page
                           grid.newpage()
                           pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
                           
                           # Make each plot, in the correct location
                           for (i in 1:numPlots) {
                             # Get the i,j matrix positions of the regions that contain this subplot
                             matchidx = as.data.frame(which(layout == i, arr.ind = TRUE))
                             
                             print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                                             layout.pos.col = matchidx$col))
                           }
                         }
                       }
                       start = Sys.time()
                       
                       errorEvaluar=c(
                         1, #1.	me, Mean Error
                         2, #2.	mae, Mean Absolute Error
                         # 3, #3.	mse, Mean Squared Error
                         # 4, #4.	rmse, Root Mean Square Error
                         5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
                         6, #6.	PBIAS, Percent Bias
                         # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
                         # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
                         9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
                         10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
                         # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
                         12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
                         13,  #13.	md, Modified Index of Agreement 
                         # 14,#14.	rd, Relative Index of Agreement
                         # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
                         # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
                         17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
                         18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
                         19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
                         20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
                       ) 
                       names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                                     "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                                     "KGE" ,    "VE" ) 
                       names_errorg=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE" ,"PBIAS", "RSR"   ,  "rSD"  ,   "NSE" ,   
                                      "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                                      "KGE" ,    "VE" ) 
                       #names_error[errorEvaluar]
                       
                       
                       ################################################################################################
                       names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 
                       metricsALL=NULL
                       setwd(dir)
                       listResults=list.files(pattern ="ResultsWB-")
                       listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                       listResults=gsub(".csv","",listResults,fixed = TRUE)
                       listResults=unique(as.numeric(listResults))
                       listResults
                       file=read.csv(paste0("ResultsWB-",listResults[1],".csv"), stringsAsFactors=F, check.names=F)
                       total <-length(unique(file$Gauge))*length(listResults)
                       truns=length(listResults)+total+2
                       
                       incProgress(1/truns)
                       
                       if (length(listResults)>0){
                         runs <- length(listResults)
                         pbi=0
                         total <- runs
                         j=1
                         
                         for (j in listResults){
                           pbi=pbi+1
                           incProgress(1/truns)
                           print(paste0(pbi," of ", total))
                           setwd(dir)
                           
                           ########
                           #i=1
                           RUNID=j
                           
                           file=read.csv(paste0("ResultsWB-",RUNID,".csv"), stringsAsFactors=F, check.names=F)
                           
                           file$Dates=ymd(file$Dates)
                           file$YearMonth=year(file$Dates)*100+month(file$Dates)
                           file$Month=month(file$Dates)
                           
                           fileOrg=file
                           
                           filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]
                           days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                           #filesub=merge(filesub,days,by="Time step")
                           filesub1=filesub
                           
                           if (Titles=="Spanish"){
                             text=paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)")
                             
                           }else if (Titles=="English") {
                             text=paste0("Time serie: ","Modeled (blue) vs Observed (red)")
                             
                           }
                           
                           filesub1$Observed=filesub1$Observed/filesub1$Days/86400
                           filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400
                           p <- ggplot(filesub1, aes(x=Dates, y=Modeled)) + 
                             geom_line(color="blue",size=0.2)+
                             geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                             facet_wrap( ~ Gauge, scales = "free") +
                             ylab(paste0("[m3/s]"))+
                             xlab(xtext)+
                             ggtitle(text)
                           p
                           
                           plotpath = paste0(RUNID,"_Time series_sim vs obs_",paste(dates,collapse ="-"),".jpg") #creates a pdf path to produce a graphic of the span of records in the Data
                           ggsave(plotpath,width =40 , height = 22,units = "cm")
                           
                           
                         }
                         
                       }
                       ################################################################################################
                       runTimeGOF=difftime(Sys.time(),start)
                       runTimeGOF
                       
                       #procesaar graficas y GOF
                       ###############################################################################################
                       metricsALL <- NULL
                       setwd(dir)
                       listResults=list.files(pattern ="ResultsWB-")
                       listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
                       listResults=gsub(".csv","",listResults,fixed = TRUE)
                       listResults=unique(as.numeric(listResults))
                       listResults
                       
                       if (length(listResults)>0){
                         
                         file=read.csv(paste0("ResultsWB-",listResults[1],".csv"), stringsAsFactors=F, check.names=F)
                         names=sort(unique(file$Gauge))
                         total <-length(unique(file$Gauge))*length(listResults)
                         pbi=0
                         f=1
                         
                         for (f in listResults){
                           
                           #Graficas
                           ##################
                           setwd(dir)
                           Carpeta_Out=paste0(f,"_Graphs_",paste(dates,collapse ="-"))
                           dir.create(Carpeta_Out,showWarnings=F)
                           dir_file=paste(c(dir,"\\",Carpeta_Out),collapse="")
                           
                           year1 = yearINI
                           year2= ey
                           
                           RUNID=f
                           
                           file=read.csv(paste0("ResultsWB-",RUNID,".csv"), stringsAsFactors=F, check.names=F)
                           file$Dates=ymd(file$Dates)
                           file$YearMonth=year(file$Dates)*100+month(file$Dates)
                           file$Month=month(file$Dates)
                           filesub <- file[which(file$Dates >= dates[1] & file$Dates <= dates[2]),]
                           
                           days=read.csv("WEAPdays.csv",stringsAsFactors = F, check.names=F)
                           #filesub=merge(filesub,days,by="Time step")
                           
                           days$Dates=NA
                           days$Dates[1]=as.Date("1981/01/01")
                           for (d in 2:nrow(days)) {
                             days$Dates[d]=days$Dates[d-1]+days$Days[d-1]
                           }
                           days$Dates=as.Date(days$Dates)
                           
                           filesub1=filesub
                           filesub1$Observed=filesub1$Observed/filesub1$Days/86400
                           filesub1$Modeled=filesub1$Modeled/filesub1$Days/86400
                           
                           obsFile=filesub1[,c("Time step","Dates","Gauge","Observed")]
                           simFile=filesub1[,c("Time step","Dates","Gauge","Modeled")]
                           obsFile = obsFile %>% pivot_wider(names_from = Gauge, values_from = Observed)
                           simFile = simFile %>% pivot_wider(names_from = Gauge, values_from = Modeled)
                           obsFile=obsFile[order(obsFile$Dates),]
                           simFile=simFile[order(simFile$Dates),]
                           
                           GofGrafica=names_errorg[errorEvaluar]
                           GofTabla=names_error[errorEvaluar]
                           
                           obsv=as.data.frame(obsFile[,names])
                           simv=as.data.frame(simFile[,names])
                           
                           setwd(dir_file)
                           Carpeta_Out="SimObs_All"
                           dir.create(Carpeta_Out,showWarnings=F)
                           dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                           setwd(dir_file1)
                           
                           
                           filesub1=filesub1[,c("Time step","Dates","Gauge","Modeled","Observed","Year")]
                           
                           if (Titles=="Spanish"){
                             text=paste0("Serie de tiempo: ","Modelado (azul) vs Observado (rojo)")
                             
                           }else if (Titles=="English") {
                             text=paste0("Time serie: ","Modeled (blue) vs Observed (red)")
                             
                           }
                           
                           p <- ggplot(filesub1, aes(x=Dates, y=Modeled)) + 
                             geom_line(color="blue",size=0.2)+
                             geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                             facet_wrap( ~ Gauge, scales = "free") +
                             ylab(paste0("[m3/s]"))+
                             xlab(xtext)+
                             ggtitle(text)
                           p
                           
                           ggsave("TimeSeries.jpg",width =40 , height = 22,units = "cm")
                           
                           try({
                             filesub1$monthyear=floor_date(filesub1$Dates, "month")
                             filesub1 <- filesub1[order(filesub1$Gauge,filesub1$Dates),]
                             
                             df=filesub1
                             df_d=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, `Time step`=df$`Time step`),mean, na.rm=TRUE)
                             df_d=df_d[order(df_d$Gauge,df_d$`Time step`),]
                             
                             write.csv(df_d,"MultiannualTimeStepMean_LongFormat.csv",row.names=FALSE,na="")
                             
                             df_d = merge(df_d,days,by="Time step")
                             df_d=df_d[order(df_d$Gauge,df_d$Dates),]
                             #dfsim_d$date = format(dfsim_d$date, "%b %d")
                             
                             if (ts==365){
                               
                               if (Titles=="Spanish"){
                                 text=paste0("Promedio Diario Multianual: ","Modelado (azul) vs Observado (rojo)")
                               }else if (Titles=="English") {
                                 text=paste0("Multiannual Daily Mean: ","Modeled (blue) vs Observed (red)")
                               }
                               
                             } else {
                               if (Titles=="Spanish"){
                                 text=paste0("Promedio a paso de tiempo Multianual: ","Modelado (azul) vs Observado (rojo)")
                               }else if (Titles=="English") {
                                 text=paste0("Multiannual Time Step Mean: ","Modeled (blue) vs Observed (red)")
                               }
                               
                             }
                             
                             
                             p <- ggplot(df_d, aes(x=Dates, y=Modeled)) + 
                               geom_line(color="blue",size=0.2)+
                               geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                               facet_wrap( ~ Gauge, scales = "free") +
                               ylab(paste0("[m3/s]"))+
                               xlab(xtext)+
                               ggtitle(text)
                             p= p + scale_x_date(date_labels = "%b/%d")
                             p
                             ggsave("Multiannual time step Mean.jpg",width =40 , height = 22,units = "cm")
                           })  
                           
                           try({
                             df=filesub1
                             df_m=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, monthyear=df$monthyear),mean, na.rm=TRUE)
                             df_m$month <- month(df_m$monthyear)
                             df_m=aggregate(df_m[,c("Modeled","Observed")],list(Gauge=df_m$Gauge, month=df_m$month),mean, na.rm=TRUE)
                             df_m=df_m[order(df_m$Gauge,df_m$month),]
                             write.csv(df_m,"MultiannualMonthlyMean_LongFormat.csv",row.names=FALSE,na="")
                             
                             Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                             Dates=as.data.frame(Dates)
                             Dates$month=month(Dates$Dates)
                             
                             df_m = merge(df_m,Dates,by="month")
                             df_m=df_m[order(df_m$Gauge,df_m$month),]
                             
                             if (Titles=="Spanish"){
                               text=paste0("Promedio Mensual Multianual: ","Modelado (azul) vs Observado (rojo)")
                               
                             }else if (Titles=="English") {
                               text=paste0("Multiannual Monthly Mean: ","Modeled (blue) vs Observed (red)")
                               
                             }
                             
                             p <- ggplot(df_m, aes(x=Dates, y=Modeled)) + 
                               geom_line(color="blue",size=0.2)+
                               geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                               facet_wrap( ~ Gauge, scales = "free") +
                               ylab(paste0("[m3/s]"))+
                               xlab(xtext)+
                               ggtitle(text)
                             p= p + scale_x_date(date_labels = "%B")
                             p 
                             ggsave("Multiannual Monthly Mean.jpg",width =40 , height = 22,units = "cm")
                             
                           })
                           
                           try({
                             df=filesub1
                             df_m=aggregate(df[,c("Modeled","Observed")],list(Gauge=df$Gauge, Year=df$Year),mean, na.rm=TRUE)
                             df_m=df_m[order(df_m$Gauge,df_m$Year),]
                             write.csv(df_m,"AnnualMean_LongFormat.csv",row.names=FALSE,na="")
                             
                             Dates=seq(as.Date(paste(c(min(df_m$Year),"/",01,"/",01),collapse="")),as.Date(paste(c(max(df_m$Year),"/",12,"/",31),collapse="") ), by = "year")
                             Dates=as.data.frame(Dates)
                             Dates$Year=year(Dates$Dates)
                             
                             df_m = merge(df_m,Dates,by="Year")
                             df_m=df_m[order(df_m$Gauge,df_m$Year),]
                             
                             if (Titles=="Spanish"){
                               text=paste0("Promedio Anual: ","Modelado (azul) vs Observado (rojo)")
                               
                             }else if (Titles=="English") {
                               text=paste0("Annual Mean: ","Modeled (blue) vs Observed (red)")
                               
                             }
                             
                             p <- ggplot(df_m, aes(x=Dates, y=Modeled)) + 
                               geom_line(color="blue",size=0.2)+
                               geom_line(aes(x=Dates, y=Observed), color="red",size=0.1)+ # ,linetype = "dotted"
                               facet_wrap( ~ Gauge, scales = "free") +
                               ylab(paste0("[m3/s]"))+
                               xlab(xtext)+
                               ggtitle(text)
                             p= p + scale_x_date(date_labels = "%B")
                             p 
                             ggsave("Multiannual Monthly Mean.jpg",width =40 , height = 22,units = "cm")
                           })
                           
                           ##################
                           i=1
                           for (i in 1:length(names)){
                             
                             name <- names[i]
                             pbi=pbi+1
                             
                             incProgress(1/truns)
                             print(paste0(pbi," of ",total)) #," Estacion ", name
                             
                             if (length(which(is.na(obsv[,i])==TRUE))<length(obsv[,i])){
                               
                               obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                               sim = zoo(simv[,i],as.Date(simFile$Dates))
                               
                               if (ts==12){
                                 
                                 try({
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_ma"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, ftype="ma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                   #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                                   dev.off()
                                 })
                                 
                               } else if (ts==365){
                                 
                                 try({
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_dma"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, ftype="dma", FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                   #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                                   dev.off()
                                 })
                                 
                                 try({
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_seasons"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, ftype="seasonal", season.names=c("", "", "", ""),na.rm=TRUE,FUN=mean, leg.cex=1.2, pch = c(20, 18),main = name, ylab=c("Q[m3/s]"))
                                   dev.off()
                                 })
                                 
                                 
                               } 
                               
                               try({
                                 setwd(dir_file)
                                 Carpeta_Out="SimObs_original"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 ggof(sim=sim, obs=obs, FUN=mean, leg.cex=1.2,na.rm=TRUE, main = name, ylab=c("Q[m3/s]"), xlab=xtext,pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                 #col = c("#FF3030", "black"),lwd = c(1, 1),lty = c(1, 1),  
                                 dev.off()
                               })
                               
                               try({   
                                 if (ts==365){
                                   df <- data.frame(date = as.Date(simFile$Dates), Gauge = simv[,i],timestep=simFile$`Time step`)
                                   df$monthyear=floor_date(df$date, "month")
                                   
                                   df_d=as.data.frame(df %>%
                                                        group_by(timestep) %>%
                                                        summarize(mean = mean(Gauge ,na.rm = TRUE)))
                                   
                                   
                                   df_d = merge(df_d,days,by.x="timestep",by.y = "Time step")
                                   df_d=df_d[order(df_d$Dates),]
                                   
                                   dfsim_d=df_d
                                   
                                   ###
                                   df <- data.frame(date = as.Date(obsFile$Dates), Gauge = obsv[,i],timestep=obsFile$`Time step`)
                                   df$monthyear=floor_date(df$date, "month")
                                   
                                   df_d=as.data.frame(df %>%
                                                        group_by(timestep) %>%
                                                        summarize(mean = mean(Gauge ,na.rm = TRUE)))
                                   
                                   
                                   df_d = merge(df_d,days,by.x="timestep",by.y = "Time step")
                                   df_d=df_d[order(df_d$Dates),]
                                   
                                   dfobs_d=df_d
                                   
                                   #grafica medios diarios multianuales
                                   obs = zoo(dfobs_d[,2],dfobs_d[,4])
                                   sim = zoo(dfsim_d[,2],dfsim_d[,4])
                                   
                                   if (Titles=="Spanish"){
                                     text=paste0("Promedio Diario Multianual")
                                   }else if (Titles=="English") {
                                     text=paste0("Multiannual Daily Mean")
                                   }
                                   
                                   setwd(dir_file)
                                   Carpeta_Out="SimObs_MultiannualDaily"
                                   dir.create(Carpeta_Out,showWarnings=F)
                                   dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                   setwd(dir_file1)
                                   png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                   ggof(sim=sim, obs=obs, lab.fmt="%b %d", ftype="o",tick.tstep = "days", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- ",text), xlab=xtext, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                   dev.off()
                                   
                                 }
                               })
                               
                               try({  
                                 #sim
                                 df <- data.frame(date = as.Date(simFile$Dates), Caudal = simv[,i])
                                 df$monthyear=floor_date(df$date, "month")
                                 #tail(df)
                                 
                                 df_m=as.data.frame(df %>%
                                                      group_by(monthyear) %>%
                                                      summarize(mean = mean(Caudal,na.rm = TRUE)))
                                 df_m$month <- month(df_m$monthyear)
                                 df_m=as.data.frame(df_m %>%
                                                      group_by(month) %>%
                                                      summarize(mean = mean(mean,na.rm = TRUE)))
                                 
                                 Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                                 Dates=as.data.frame(Dates)
                                 Dates$month=month(Dates$Dates)
                                 
                                 df_m=merge(df_m,Dates,by="month")
                                 dfsim_m=df_m
                                 
                                 #obs
                                 df <- data.frame(date = as.Date(obsFile$Dates), Caudal = obsv[,i])
                                 df$monthyear=floor_date(df$date, "month")
                                 
                                 df_m=as.data.frame(df %>%
                                                      group_by(monthyear) %>%
                                                      summarize(mean = mean(Caudal,na.rm = TRUE)))
                                 df_m$month <- month(df_m$monthyear)
                                 df_m=as.data.frame(df_m %>%
                                                      group_by(month) %>%
                                                      summarize(mean = mean(mean,na.rm = TRUE)))
                                 
                                 Dates=seq(as.Date(paste(c(1981,"/",01,"/",01),collapse="")),as.Date(paste(c(1981,"/",12,"/",31),collapse="") ), by = "month")
                                 Dates=as.data.frame(Dates)
                                 Dates$month=month(Dates$Dates)
                                 
                                 df_m=merge(df_m,Dates,by="month")
                                 dfobs_m=df_m
                                 
                                 #grafica medios mensuales multianuales
                                 obs = zoo(dfobs_m[,2],dfobs_m[,3])
                                 sim = zoo(dfsim_m[,2],dfsim_m[,3])
                                 
                                 if (Titles=="Spanish"){
                                   text=paste0("Promedio Mensual Multianual")
                                 }else if (Titles=="English") {
                                   text=paste0("Multiannual Monthly Mean")
                                 }
                                 setwd(dir_file)
                                 Carpeta_Out="SimObs_MultiannualMonthly"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 ggof(sim=sim, obs=obs, lab.fmt="%b", ftype="o",tick.tstep = "months", lab.tstep = "months", FUN=mean, leg.cex=1.2,na.rm=TRUE, main=paste(name,"- ",text), xlab=xtext, ylab=c("Q[m3/s]"), pch = c(20, 18),lwd = c(1, 1), gofs=GofGrafica)
                                 dev.off()
                                 
                               })
                               
                               #residuales
                               obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                               sim = zoo(simv[,i],as.Date(simFile$Dates))
                               
                               try({
                                 setwd(dir_file)
                                 Carpeta_Out="Sim"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 hydroplot(sim, FUN=mean,var.unit="m3/s",main=paste0(name," Simu"),xlab="",na.rm=TRUE)
                                 dev.off()
                               })
                               
                               try({
                                 setwd(dir_file)
                                 Carpeta_Out="Obs"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 hydroplot(obs, FUN=mean,var.unit="m3/s",main=paste0(name," Obs"),xlab="",na.rm=TRUE)
                                 dev.off()
                               })
                               
                               try({
                                 r <- sim-obs
                                 smry(r)
                                 setwd(dir_file)
                                 Carpeta_Out="SimObs_residuals"
                                 dir.create(Carpeta_Out,showWarnings=F)
                                 dir_file1 = paste0(dir_file,"\\",Carpeta_Out)
                                 setwd(dir_file1)
                                 png(file=paste0(name,"_",Carpeta_Out,".png"),width =40 , height = 22,units = "cm",res=800)
                                 hydroplot(r, FUN=mean,var.unit="m3/s",main=paste0(name," Residual"),xlab="",na.rm=TRUE)
                                 dev.off()
                               })
                               #metricas en tabla
                               
                               metrics=NULL
                               obs = zoo(obsv[,i],as.Date(obsFile$Dates))
                               sim = zoo(simv[,i],as.Date(simFile$Dates))
                               
                               
                               if (ts==365){
                                 
                                 try({
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Diario"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Daily"
                                   }
                                   
                                   metrics=rbind(metrics,m)
                                 })
                                 
                                 try({
                                   sim = daily2monthly.zoo(sim, FUN = mean)
                                   obs = daily2monthly.zoo(obs, FUN = mean)
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Mensual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Monthly"
                                   }
                                   
                                   metrics=rbind(metrics,m)
                                 })
                                 
                                 try({
                                   sim = monthly2annual(sim, FUN = mean)
                                   obs = monthly2annual(obs, FUN = mean)
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Anual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Annual"
                                   }
                                   metrics=rbind(metrics,m)  
                                 })
                                 
                                 try({
                                   m <- gof(sim=dfsim_d[,2], obs=dfobs_d[,2])
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Medio Diario multianual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Multiannual Daily Mean"
                                   }
                                   metrics=rbind(metrics,m)
                                 })
                               }
                               
                               if (ts==12){
                                 try({
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Mensual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Monthly"
                                   }
                                   metrics=rbind(metrics,m)
                                 })
                                 
                                 try({
                                   
                                   sim = monthly2annual(sim, FUN = mean)
                                   obs = monthly2annual(obs, FUN = mean)
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Anual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Annual"
                                   }
                                   metrics=rbind(metrics,m)  
                                 })
                                 
                                 try({
                                   m <- gof(sim=dfsim_m[,2], obs=dfobs_m[,2])
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Medio Mensual multianual"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Multiannual Monthly Mean"
                                   }
                                   metrics=rbind(metrics,m)
                                 })
                               } else {
                                 try({
                                   m <- gof(sim=sim, obs=obs)
                                   m <- as.data.frame(m)
                                   m$Metricas <- rownames(m)
                                   m$Estacion <- name
                                   
                                   if (Titles=="Spanish"){
                                     m$Tipo <- "Paso de tiempo del modelo"
                                   }else if (Titles=="English") {
                                     m$Tipo <- "Model Time Step"
                                   }
                                   
                                   metrics=rbind(metrics,m)
                                 })
                               }
                               
                               metrics$ID=f
                               
                             }
                             
                             
                             metricsALL=rbind(metricsALL,metrics)
                             
                           }
                           try({
                             setwd(dir)
                             metricas <- subset(metricsALL, Metricas %in% GofTabla)
                             colnames(metricas)=c("Valor", "GOF", "Estacion", "Tipo" ,    "Run ID"  )
                             metricas=metricas[,c("Run ID", "Tipo","Estacion", "GOF","Valor")]
                             
                             if (Titles=="English") {
                               colnames(metricas)=c("Run ID", "Type","Gauge", "GOF","Value")
                             }
                             
                             write.csv(metricas, paste0("SummaryGOF2_",paste(dates,collapse ="-"),".csv"),row.names = FALSE)
                             
                           })
                         }
                       }
                       ################################################################################################
                       runTimeGOF2=difftime(Sys.time(),start)
                       runTimeGOF2
                       
                       ##############################################################
                       
                       output$textRunEnsemblegraph1 <- renderText({
                         outTxt = ""
                         text=paste0("Graphs exported. Check ", dir,". Time: ")
                         formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                         outTxt = paste0(outTxt, formatedFont)
                         
                         text=format(as.difftime(difftime(Sys.time(),start), format = "%H:%M")) 
                         formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
                         outTxt = paste0(outTxt, formatedFont)
                         
                         outTxt
                         
                         
                       })
                       
                       
                       incProgress(1/truns)
                       
                     })
      }
      
    })
    ###################################### 
    
    ###################################### 
    
    observeEvent(input$GOFmetrics,{
      
      Model=VAL$Model2 
      if (length(list.files(pattern ="ResultsWB-")>0) &&  Model==1){
        
        listResults=list.files(pattern ="ResultsWB-")
        listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
        listResults=gsub(".csv","",listResults,fixed = TRUE)
        listResults=unique(as.numeric(listResults))
        listResults
        
        runs <- length(listResults)
        
        errorEvaluar=c(
          1, #1.	me, Mean Error
          2, #2.	mae, Mean Absolute Error
          # 3, #3.	mse, Mean Squared Error
          # 4, #4.	rmse, Root Mean Square Error
          5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
          6, #6.	PBIAS, Percent Bias
          # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
          # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
          9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
          10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
          # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
          12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
          13,  #13.	md, Modified Index of Agreement 
          # 14,#14.	rd, Relative Index of Agreement
          # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
          # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
          17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
          18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
          19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
          20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
        ) 
        names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                      "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                      "KGE" ,    "VE" ) 
        #names_error[errorEvaluar]
        
        names_errorLOG=paste(rep("log10",length(names_error)),names_error) #"logNSE" 
        
        
        metricsALL=NULL
        
        withProgress(message = 'Calculation in progress',
                     detail = 'This may take a while...', value = 0, {
                       
                       
                       i=1
                       for (i in listResults) {
                         
                         runID=listResults[i]
                         name=paste0("ResultsWB-",as.character(runID),".csv")
                         file <- read.csv(name, stringsAsFactors=F, check.names=F)
                         file$Dates=ymd(file$Dates)
                         file$YearMonth=year(file$Dates)*100+month(file$Dates)
                         file$Month=month(file$Dates)
                         file <- file[which(file$Dates >= input$datest[1] & file$Dates <= input$datest[2]),]
                         uniqueGauges=sort(unique(file$Gauge))
                         incProgress(1/(length(uniqueGauges)*runs+2))
                         
                         metricsAll=NULL
                         
                         t=1
                         for (t in 1:3){
                           
                           metrics=as.data.frame(matrix(nrow=length(uniqueGauges),ncol=(12+length(errorEvaluar)*2)))
                           colnames(metrics) <- c("Gauge","Run ID",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Type","Period")
                           
                           metrics[,1]=uniqueGauges
                           metrics[,2]=runID
                           
                           g=1
                           for (g in 1:length(uniqueGauges)){
                             
                             try({
                               filesub=file[file$Gauge==uniqueGauges[g],]
                               total=nrow(filesub)
                               
                               filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                               r1=nrow(filesubt)
                               DatesRegister=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                               
                               metrics[g,"Period"]=DatesRegister
                               
                               n=round(nrow(filesubt)*0.7,0)
                               
                               
                               
                               if (t==1){
                                 
                                 filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                                 r1=nrow(filesubt)
                                 
                                 filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                                 
                                 total <- nrow(filewb)
                                 DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                                 DatesRegister
                                 
                                 metrics$Type="All"
                                 
                               } else if (t==2) {
                                 
                                 filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                                 filesubt=filesubt[1:n,]
                                 r1=nrow(filesubt)
                                 
                                 filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                                 total <- nrow(filewb)
                                 DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                                 DatesRegister
                                 
                                 metrics$Type="Calibration (70%)"
                                 
                               } else {
                                 
                                 filesubt=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                                 filesubt=filesubt[(n+1):nrow(filesubt),]
                                 r1=nrow(filesubt)
                                 
                                 filewb=filesub[which(filesub$Dates >=filesubt$Dates[1] & filesub$Dates <= filesubt$Dates[nrow(filesubt)]),]
                                 total <- nrow(filewb)
                                 DatesRegister=paste0(as.character(as.Date(filesubt$Dates[1]))," - ",as.character(as.Date(filesubt$Dates[nrow(filesubt)])),"(N",r1,",NA",round(100-r1/total*100,1),"%",")")
                                 DatesRegister
                                 
                                 
                                 metrics$Type="Validation (30%)"
                                 
                               }
                               
                               filesub=filewb
                               Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
                               Filemonthly$N=1
                               Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
                               Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
                               Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
                               Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
                               Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
                               metrics[g,(7+length(errorEvaluar)*2):(7+2*length(errorEvaluar)+3)]=Filemonthly[1,7:10]
                               
                               filesub=filesubt
                               r=nrow(filesub)
                               modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
                               observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
                               
                               filesub$Modeled[which(filesub$Modeled ==0)]=NA
                               filesub$Observed[which(filesub$Observed ==0)]=NA
                               filesub=na.exclude(filesub[filesub$Gauge==uniqueGauges[g],])
                               modeledlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Modeled,10)
                               observedlog <- log(filesub[filesub$Gauge==uniqueGauges[g],]$Observed,10)
                               
                               if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
                                 error=gof(modeled,observed,na.rm=TRUE)
                                 metrics[g,3:(2+length(errorEvaluar))]=round(error[errorEvaluar],3)
                                 errorLOG=gof(modeledlog,observedlog,digits=5,na.rm=TRUE)
                                 metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=round(errorLOG[errorEvaluar],3)
                               } else {
                                 metrics[g,3:(2+length(errorEvaluar))]=NA
                                 metrics[g,(3+length(errorEvaluar)):(2+2*length(errorEvaluar))]=NA
                               }
                               metrics$PeriodGOF[g]=DatesRegister
                               metrics[g,2+length(errorEvaluar)*2+1]=min(na.exclude(filesub$Observed))/min( na.exclude(filesub$Modeled))*100   
                               metrics[g,2+length(errorEvaluar)*2+2]=mean(na.exclude(filesub$Observed))/mean( na.exclude(filesub$Modeled))*100   
                               metrics[g,2+length(errorEvaluar)*2+3]=max(na.exclude(filesub$Observed))/max( na.exclude(filesub$Modeled))*100   
                               
                               
                               
                             })  
                             
                             incProgress(1/(length(uniqueGauges)*runs+2))
                             
                             
                           }
                           
                           
                           metricsAll=rbind(metricsAll,metrics)
                           
                           
                         }
                         
                         metrics=metricsAll
                         
                         metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")]=round(metrics[,c("Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %")],2)
                         cols <- c("Type","Period","Gauge","Run ID","PeriodGOF",names_error[errorEvaluar],names_errorLOG[errorEvaluar],"Qmin obs/Qmin sim %","Qmean obs/Qmean sim %","Qmax obs/Qmax sim %","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %")
                         metrics=metrics[,cols]
                         
                         metricsALL=rbind(metricsALL,metrics)
                         
                       }
                       
                     })
        try({
          if (file.exists(paste0("KeyModelInputs.csv"))){
            keysset <- read.csv(paste0("KeyModelInputs.csv"),stringsAsFactors =F,check.names=F)
            metricsALL=merge(metricsALL,keysset,by.x = "Run ID",by.y = "Nrun")
          }
        }) 
        
        write.csv(metricsALL,paste0("SummaryGOF_",as.character(input$datest[1]),"-",as.character(input$datest[2]),".csv"),row.names=F) 
        #write.csv(metricsALL,paste0("SummaryGOF_",".csv"),row.names=F) 
        
        
      } 
    })
    
    observe({
      req(input$datest)
      name=paste0("SummaryGOF_",as.character(input$datest[1]),"-",as.character(input$datest[2]),".csv")
      
      if (file.exists(name)){
        output$GOFtextRunactmetrics <- renderText({
          outTxt = ""
          text=paste0("Results from the file SummaryGOF_",as.character(input$datest[1]),"-",as.character(input$datest[2]),".csv.")
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          
          outTxt
          
        })
      } else {
        output$GOFtextRunactmetrics <- renderText({
          outTxt = ""
          text="Calculate the results first."
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          
          outTxt
          
        })
      }
      
      
    })
    
    observeEvent(list(input$GOFmetrics,input$nse,input$mnse,input$bias,input$d, input$md,input$r2,input$datest),{
      req(input$datest)
      Model=VAL$Model2 
      #name=paste0("SummaryGOF_",".csv")
      
      name=paste0("SummaryGOF_",as.character(input$datest[1]),"-",as.character(input$datest[2]),".csv")
      
      if (file.exists(name) &&  Model==1){
        
        nse=input$nse
        mnse=input$mnse
        bias=input$bias
        d=input$d
        md=input$md
        r2=input$r2
        
        # nse=-10000000
        # mnse=-10000000
        # bias=10000000
        # d=-10000000
        # md=-10000000
        # r2=-10000000

        metricsall <- read.csv(name,check.names=F,stringsAsFactors = F)
        #metricsall <- read.csv(paste0("SummaryGOF_2015-01-01-2018-12-31.csv"),check.names=F,stringsAsFactors = F)
        #str(metricsall)
        metricsall = metricsall[metricsall$NSE >= nse,]
        metricsall = metricsall[metricsall$mNSE >= mnse,]
        metricsall = metricsall[metricsall$`PBIAS %` >= -bias,]
        metricsall = metricsall[metricsall$`PBIAS %` <= bias,]
        metricsall = metricsall[metricsall$d >= d,]
        metricsall = metricsall[metricsall$md >= md,]
        metricsall = metricsall[metricsall$R2 >= r2,]
        metricsall=metricsall[order(metricsall$Type,metricsall$Gauge,metricsall$`Run ID`),]
        
        output$GOFmetricsruns <- DT::renderDataTable({
          DT::datatable(metricsall, rownames= FALSE)
          
        })
        
        if (nrow(metricsall)>=1) {
          
          shinyjs::show("GOF_1")
          shinyjs::show("GOF_2")
          shinyjs::show("GOF_3")
          shinyjs::show("GOF_4")
          shinyjs::show("GOF_5")
          shinyjs::show("GOF_6")
          shinyjs::show("GOF_7")
          shinyjs::show("GOF_8")
          shinyjs::show("GOF_9")
          shinyjs::show("GOF_10")
          shinyjs::show("GOF_11")
          shinyjs::show("GOF_12")
          
          errorEvaluar=c(
            1, #1.	me, Mean Error
            2, #2.	mae, Mean Absolute Error
            # 3, #3.	mse, Mean Squared Error
            # 4, #4.	rmse, Root Mean Square Error
            5, #5.	nrmse, Normalized Root Mean Square Error ( -100% <= nrms <= 100% )
            6, #6.	PBIAS, Percent Bias
            # 7, #7.	RSR, Ratio of RMSE to the Standard Deviation of the Observations, RSR = rms / sd(obs). ( 0 <= RSR <= +Inf )
            # 8, #8.	rSD, Ratio of Standard Deviations, rSD = sd(sim) / sd(obs)
            9, #9.	NSE, Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 )
            10, #10.	mNSE, Modified Nash-Sutcliffe Efficiency
            # 11, #11.	rNSE, Relative Nash-Sutcliffe Efficiency
            12,  #12.	d, Index of Agreement ( 0 <= d <= 1 )
            13,  #13.	md, Modified Index of Agreement 
            # 14,#14.	rd, Relative Index of Agreement
            # 15, #15.	cp, Persistence Index ( 0 <= PI <= 1 )
            # 16, #16.	r, Pearson Correlation coefficient ( -1 <= r <= 1 )
            17,  #17.	R2, Coefficient of Determination ( 0 <= R2 <= 1 ). 
            18,  #8.	bR2, R2 multiplied by the coefficient of the regression line between sim and obs ( 0 <= bR2 <= 1 )
            19, #19.	KGE, Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 )
            20 #20.	VE, Volumetric efficiency between sim and obs  ( -Inf <= VE <= 1)
          ) 
          names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                        "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                        "KGE" ,    "VE" ) 
          names_error=names_error[errorEvaluar]
          
          try({
            output[[paste0("GOF_",1)]] = renderPlotly({
              e=1
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",2)]] = renderPlotly({
              e=2
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",3)]] = renderPlotly({
              e=3
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",4)]] = renderPlotly({
              e=4
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
            }) 
          })               
          try({
            output[[paste0("GOF_",5)]] = renderPlotly({
              e=5
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",6)]] = renderPlotly({
              e=6
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",7)]] = renderPlotly({
              e=7
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",8)]] = renderPlotly({
              e=8
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",9)]] = renderPlotly({
              e=9
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",10)]] = renderPlotly({
              e=10
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          try({
            output[[paste0("GOF_",11)]] = renderPlotly({
              e=11
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
            }) 
          })               
          try({
            output[[paste0("GOF_",12)]] = renderPlotly({
              e=12
              data=metricsall
              title=names_error[e]
              data=data[,c("Type","Gauge",title)]
              colnames(data)=c("Type","Gauge","GOF")
              data$Gauge=as.factor(data$Gauge)
              data$Gauge=as.factor(data$Gauge)
              data$Type=as.factor(data$Type)
              
              data %>%
                group_by(Type) %>%
                group_map(~ plot_ly(data=., x = ~Gauge, y = ~GOF, color = ~Type, type =  "box"), .keep=TRUE) %>%
                subplot(nrows = 1, shareX = TRUE, shareY=TRUE)%>%  
                layout(title = paste0(title),
                       yaxis = list(title=title))
              
            }) 
          })               
          
        } else {
          shinyjs::hide("GOF_1")
          shinyjs::hide("GOF_2")
          shinyjs::hide("GOF_3")
          shinyjs::hide("GOF_4")
          shinyjs::hide("GOF_5")
          shinyjs::hide("GOF_6")
          shinyjs::hide("GOF_7")
          shinyjs::hide("GOF_8")
          shinyjs::hide("GOF_9")
          shinyjs::hide("GOF_10")
          shinyjs::hide("GOF_11")
          shinyjs::hide("GOF_12")
          
        }
        
        
      }else {
        shinyjs::hide("GOF_1")
        shinyjs::hide("GOF_2")
        shinyjs::hide("GOF_3")
        shinyjs::hide("GOF_4")
        shinyjs::hide("GOF_5")
        shinyjs::hide("GOF_6")
        shinyjs::hide("GOF_7")
        shinyjs::hide("GOF_8")
        shinyjs::hide("GOF_9")
        shinyjs::hide("GOF_10")
        shinyjs::hide("GOF_11")
        shinyjs::hide("GOF_12")
        
      }
      
    })
    
    ###################################### 
    
    ###################################### 
    
    observeEvent(input$WD_resultsGraphs,{
      output$textWD_resultsGraphs <-renderText({
        if (input$WD_resultsGraphs=="") {
          outTxt = ""
          text=paste0("Set the working directory")
          formatedFont = sprintf('<font color="%s">%s</font>',"red",text)
          outTxt = paste0(outTxt, formatedFont)
          
          outTxt
          
        } else {
          
          wd=input$WD_resultsGraphs
          setwd(wd)
          listResults=c("",sort(list.files(pattern =".csv"),decreasing = TRUE))
          
          output$UploadedFileCsv <- renderUI({
            selectInput("UploadedFile", "File selected",listResults,listResults[1])
          })
          
          outTxt = ""
          text=paste0("Working directory :",getwd())
          formatedFont = sprintf('<font color="%s">%s</font>',"green",text)
          outTxt = paste0(outTxt, formatedFont)
          
          outTxt
          
        }
      })
    })
    
    observeEvent(list(input$WD_resultsGraphs,input$UploadedFile),{
      
      req(input$UploadedFile)
      if (file.exists(input$UploadedFile)){
        data=as.data.frame(read.csv(input$UploadedFile, stringsAsFactors=F, check.names=F))
        
        output$tableUploadedFile <- DT::renderDataTable({
          DT::datatable(data, rownames= FALSE)
        })
        output$Xaxis <- renderUI({
          selectInput("Xaxisoptions", "X axis:",colnames(data))
        })
        output$Yaxis <- renderUI({
          selectInput("Yaxisoptions", "Y axis:",colnames(data))
        })
        output$Zaxis <- renderUI({
          selectInput("Zaxisoptions", "Z axis:",colnames(data))
        })
        
        if (length(which(colnames(data)=="Gauge"))==1){
          output$Gauges <- renderUI({
            selectInput("Gauge", "Gauge:",sort(unique(data$Gauge)))
          }) 
        } else {
          output$Gauges <- renderUI({
            selectInput("Gauge", "Gauge:","No Gauge Column")
          }) 
        }
        
        
        if (length(which(colnames(data)=="Catchment"))==1){
          output$Catchments <- renderUI({
            selectInput("Catchment", "Catchment:",sort(unique(data$Catchment)))
          })
        }else {
          output$Catchments <- renderUI({
            selectInput("Catchment", "Catchment:","No Catchment Column")
          }) 
        }
        
        
      }
      
    })
    
    observeEvent(list(input$UploadedFile,input$Xaxisoptions,input$Yaxisoptions,input$Zaxisoptions,input$Gauge,input$Catchment),{
      
      try({
        d=NULL
        req(input$UploadedFile)
        f=input$UploadedFile
        xa=input$Xaxisoptions
        ya=input$Yaxisoptions
        za=input$Zaxisoptions
        dataf=NULL
        
        output$col <- renderPrint({
          c("X: ",xa," Y: ",ya," Z: ",za," Catchment: ",input$Catchment,"Gauge: ",input$Gauge)
        })
        
        if (file.exists(f)){
          
          data=read.csv(f, stringsAsFactors=F, check.names=F)
          titleGraph=f
          
          if (length(which(colnames(data)=="Dates"))==1){
            data$Dates=ymd(data$Dates)
          }
          
          if (length(which(colnames(data)=="Gauge"))==1){
            data=data[data$Gauge==input$Gauge,]
            titleGraph=paste0(titleGraph," Gauge: ",input$Gauge)
          }
          
          if (length(which(colnames(data)=="Catchment"))==1){
            data=data[data$Catchment==input$Catchment,]
            titleGraph=paste0(titleGraph," Catchment: ",input$Catchment)
          }
          
          if (length(which(colnames(data)=="Gauge"))==1 && length(which(colnames(data)=="Catchment"))==1){
            titleGraph=paste0(titleGraph," Gauge: ",input$Gauge," Catchment: ",input$Catchment)
          }
          
          #str(data)
          
          if (nrow(data)>0){
            data1=data.frame(X=data[,xa])
            #colnames(data1)=paste0("X: ",xa)
            data2=data[,c(xa,ya)]
            #colnames(data2)=paste(c("X: ","Y: "),colnames(data2))
            data3=data[,c(xa,ya,za)]
            #colnames(data3)=paste(c("X: ","Y: ","Z: "),colnames(data3))
            
            
            if (input$Type=="scatter"){
              d=plot_ly(data, x =data[,xa], y =data[,ya], showlegend=TRUE, type = input$Type, mode = input$TypeMode, color =  data[,ya]) %>%  
                layout(title = titleGraph,
                       xaxis = list(title=xa),
                       yaxis = list(title=ya))
              
              dataf=data2
              
              
            } else if (input$Type== "histogram"){
              d=plot_ly(data,x =  data[,xa], showlegend=TRUE, type = "histogram", histnorm = "probability") %>%  
                layout(title = titleGraph,
                       xaxis = list(title=xa),
                       yaxis = list(title="Probability"))
              
              dataf=data1
              
            } else if (input$Type== "scatter3d"){
              d=plot_ly(data, x =  data[,xa], y =  data[,ya], z =  data[,za], type = "scatter3d" ,color =  data[,za] ) %>%  
                layout(title = titleGraph,
                       xaxis = list(title=xa),
                       yaxis = list(title=ya))
              
              dataf=data3
              
            } else if (input$Type== "mesh3d" || input$Type=="contour" || input$Type=="heatmap"){
              d=plot_ly(data, x =  data[,xa], y =  data[,ya], z =  data[,za], type = input$Type ) %>%   
                layout(title = titleGraph,
                       xaxis = list(title=xa),
                       yaxis = list(title=ya))
              
              
              dataf=data3
              
            } else if (input$Type== "bar" || input$Type== "histogram2d" || input$Type== "histogram2dcontour" || input$Type== "waterfall" || input$Type== "pointcloud"){
              d=plot_ly(data, x =  data[,xa], y =  data[,ya], showlegend=TRUE, type = input$Type, color =  data[,ya]) %>%  
                layout(title = titleGraph,
                       xaxis = list(title=xa),
                       yaxis = list(title=ya))
              
              dataf=data2
              
            } else if (input$Type== "box" || input$Type== "violin"){
              d=plot_ly(data, x =  data[,xa], y = data[,ya] , showlegend=TRUE, type = input$Type) %>%  
                layout(title = titleGraph,
                       xaxis = list(title=xa),
                       yaxis = list(title=ya))
              
              dataf=data2
            }
            
          }
          
          output$tableplotfile <- DT::renderDataTable({
            DT::datatable(dataf, rownames= FALSE)
          })
          
          output$ plotfile <- renderPlotly({
            d
          })
          
        }
        
      })
      
    })               
    
    ###################################### 

  }

  
)
