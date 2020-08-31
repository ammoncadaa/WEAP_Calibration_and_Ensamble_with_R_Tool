## WEAP_Calibration_and_Ensamble_with_R_Tool v.2.0##
## Developed by Angelica Moncada (SEI-LAC Water Group member) (2020) ##
## R version 4.0.2 ##

rm(list=ls()) 
list.of.packages <- c("data.table") 
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

list.of.packages <- c("glue","bindrcpp","deSolve","DT","plotly", "prodlim","hydroGOF","RDCOMClient","lintr","shiny","shinydashboard","shinyFiles","lubridate","shinyWidgets") 
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(lintr)
library(shiny)
library(shinydashboard)
library(shinyFiles)
library(lubridate)
library(shinyWidgets)
library(glue)
library(bindrcpp)
library(plotly) 
library(prodlim)
library(hydroGOF)
library(RDCOMClient)
library(DT)
library(deSolve)

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
    dashboardHeader(title = "WEAP Tool v2.0"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Home", tabName = "Home", icon = icon("home")),   
        menuItem("1. Initial Estimations", tabName = "Initial_Estimations", icon = icon("calculator")),
        menuItem("2. Ensemble runs", tabName = "Calibration_Ensemble", icon = icon("laptop")),
        menuItem("3. Navigating Results", tabName = "Navigating_Results", icon = icon("chart-area")),
        menuItem("4. GOF filters", tabName = "GOF_filter", icon = icon("sort-amount-up")),
        menuItem("5. User Graphs", tabName = "Graphs", icon = icon("chart-bar"))
      )),
    
    dashboardBody(
      tabItems(
        
        tabItem("Home", 
                fluidPage(
                  titlePanel(h1("WEAP Ensemble & Calibration Tool with R", style = "color:green")),
                  hr(),
                  wellPanel(style = "background: white",
                            img(src = "https://www.weap21.org/img/logocard2.png", height = 200, width = 400),
                            hr(),
                            h4(p(br("The WEAP Calibration and Ensemble with R tool serves to provide model builders with an automatic tool to assist in calibrating 
                         a WEAP model and/or run a WEAP ensemble."), 
                                 br("It uses an ensemble-based approach to automatically produce a complete set of WEAP results from Water-Balance variables (automaticaly), user-defined variables 
                        and WEAP branch value ranges."),
                                 br("The model builder can then interact with these results, which include modeled vs. observed streamflow and catchment
                        inflows and outflows, in a set of dynamic graphics and Goodness-Of-Fit (GOF) to identify the optimal set of parameter values. The tool 
                        is designed to be customizable to each WEAP model, and although its primary function is to inform calibration, can also be applied for 
                        any ensemble-based WEAP results exploration activity."),
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
                                        more upstream catchments on a model with any time step. Now, it extracts all the water balance variables automatically and allows to extract additional variables. Some additional graphs were added and a new 
                                        section was included for customizing and exploring graphs by using a results of the tool or
                            any file with time series data. This version was built under the R version 4.0.2")),
                                 br(strong("Contact: angelica.moncada@sei.org; angelicammoncada@hotmail.com; angelicammoncada@gmail.com")),
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
                                 hr(),
                                 br("To run the tool, you will need to have the following programs installed: R, RStudio, and WEAP."),
                                 br(strong("Make sure you have installed the package -RDCOMClient- and it is working properly.")),
                                 br("You will need some of the four input files: 1- WEAPKeyGaugesCatchments.csv, 2- WEAPKeyGaugeBranches.csv, 3- WEAPKeyEnsemble.csv or KeyModelInputs.csv,   
                      , and/or 4- WEAPKeyExport.csv. The need for each file depends on the purpose which the tool is used for.
                      The name of the files does not need to be the same. However, column names of each file must be the same."),
                                 br("Templates of the input files can be downloaded from:"),
                                 tags$div(class = "submit",
                                          tags$a(href = "https://github.com/ammoncadaa/WEAP_Calibration_and_Ensamble_with_R_Tool", 
                                                 "Download template files", 
                                                 target="_blank")
                                 ),
                                 
                                 br("You will see six tabs on the left: a -Home- tab, which contains an introduction to the tool; a -1.	Initial Estimations- tab for an initial conductivity estimation and the ratio (in percentage) of the Observed Streamflow to Precipitation, a  
                          -2. Ensemble runs- tab where the ensemble is set up, WEAP model is run and results are saved, a -3. Navigating Results- tab where the calibration ensemble results can be explored, 
                          a -4. GOF filter- tab where the calibration ensemble results can be filtered by setting GOF thresholds, and a -5. User Graphs- where the user can set graphs by uploading a file. Each of these will be 
                          explained within each tab with more detail")
                            )
                            )),
                  hr(),
                  wellPanel(
                    h3("1. Set the working directory where the results will be saved.", style = "color:green"),
                    h5("Copy and paste the full path.", style = "color:green"),
                    textInput("WD_results", "", "", width="80%"),
                    hr(),
                    h4("The folder -SEI tool Results- will be created within it."),
                    h4("The working directory was set as:"),
                    textOutput("textWD_results"))
                )),
        tabItem("Initial_Estimations", 
                fluidPage(
                  titlePanel(h1("Initial estimations of observed streamflow data", style = "color:green")),
                  hr(),
                  wellPanel(style = "background: white",
                            h4("A first, optional step when using the WEAP Calibration with R tool is to estimate the root zone conductivity and deep conductivity values for a basin based on the characteristics of observed streamflow and its upstream area, and the ratio of observed streamflow to precipitation."), 
                            h4("The R code will automatically estimate the ratio of observed streamflow to precipitation, and the the root zone conductivity and deep conductivity, and report back values and graphs. Note that these conductivity values are estimations, not absolute measurements, so calibration is still necessary to refine these values."),
                            h4("The variables calculated and used to estimate Ks and kd are:"),
                            h5("-	Base Flow (m3) = Lowest average observed flow volume. Represents the base flow runoff in the observed streamflow"),
                            h5("-	Outflow (m3) = Highest average observed flow volume - Base Flow. Represents the non-base flow runoff"),
                            h5("-	Interflow (m3) = Highest average observed flow volume - Surface Runoff. Represents the volume of runoff in your catchment that is considered interflow."),
                            h5("-	Surface Runoff (m3) = Outflow * User-defined Percent. Represents the outflow that is considered direct surface runoff. The user defines the proportion of surface runoff to outflow; a typical value is 20%."),
                            h5("-	Depth of interflow (mm) = Interflow / Area of Catchment."),
                            h5("-	Depth of base flow (mm) = Base Flow / Area of Catchment."),
                            h5("-	Ks, root zone conductivity (mm/timeStep) = Depth of interflow / Z1^2. Z1 is an estimate of the soil moisture content in the top bucket of the WEAP 2-bucket soil moisture model, and is entered in as a user-defined percent." ),
                            h5("-	Ks, deep zone conductivity (mm/timeStep) = Depth of base flow / Z2^2. Z2 is an estimate of the soil moisture content in the bottom bucket of the WEAP 2-bucket soil moisture model, and is entered in as a user-defined percent."),
                            hr(),
                            h4(
                              p("You will need the input files: 1- WEAPKeyGaugesCatchments.csv, 2- WEAPKeyGaugeBranches.csv, 
                      The name of the files does not need to be the same. However, column names of each file must be the same."),
                              hr(),
                              p(strong("1-	WEAPKeyGaugesCatchments.csv")),
                              p("This file contains the list of catchments of each of the streamflow gauges to be analyzed.
                      "),
                              hr(),
                              p(strong("2-	WEAPKeyGaugeBranches.csv")),
                              p("This file contains the list of the observed and modeled streamflow branch of each of the streamflow gauges to be analyzed. 
                      ")
                            ),
                            hr(),
                            h4("The R code will automatically estimate the root zone conductivity and deep conductivity using the calculations and method discussed at the start of this section, and report back the two values and graphs. Note that these values are estimations, not absolute measurements, so calibration is still necessary to refine these values. "),
                            hr(),
                            h4(strong("Follow the instructions in each of the numbered items within this tab. Be careful of uploading input files with the proper structure (column names), values (format) and WEAP expressions."))
                  ),
                  hr(),
                  fluidRow(
                    column(4,
                           wellPanel(
                             h2("1.  Gauges-catchments relationship file.", style = "color:green"),
                             hr(),
                             h3(strong("Choose file to upload, WEAPKeyGaugesCatchments.csv", style = "color:green")),
                             h5("Columns: Gauge, Catchment"),
                             fileInput('WEAPKeyGaugesCatchmentsA', '',
                                       accept = c(
                                         'text/csv',
                                         'text/comma-separated-values',
                                         'text/tab-separated-values',
                                         'text/plain',
                                         '.csv',
                                         '.tsv' )            
                             ),
                             hr(),
                             h5("When the file is imported, it will appear here below:"),
                             column(12,
                                    DT::dataTableOutput("tableWEAPKeyGaugesCatchmentsA"),style = "overflow-x: scroll;" 
                             ) 
                             
                           ),
                           wellPanel(
                             h2("2.  Modeled and Observed Gauge Branches file.", style = "color:green"),
                             hr(),
                             h3(strong("Choose file to upload, WEAPKeyGaugeBranches.csv", style = "color:green")),
                             h5("Columns: Gauge Name,	Observed Branch,	Modeled Branch"),
                             fileInput('WEAPKeyGaugeBranchesA', '',
                                       accept = c(
                                         'text/csv',
                                         'text/comma-separated-values',
                                         'text/tab-separated-values',
                                         'text/plain',
                                         '.csv',
                                         '.tsv' )            
                             ),
                             hr(),
                             h5("When the file is imported, it will appear here below:"),
                             column(12,
                                    DT::dataTableOutput("tableWEAPKeyGaugeBranchesA"),style = "overflow-x: scroll;" 
                             )
                           ),
                           wellPanel(h2("3.  WEAP Area Information.", style = "color:green"),
                                     hr(),
                                     textInput("wareaA",label="Name of WEAP Area:"),
                                     textInput("startA",label="Start Year:"),
                                     textInput("endA",label="End Year:"),
                                     textInput("tsA",label="TimeStep per year:"),
                                     textInput("ScenA",label="Scenario:"),
                                     hr(),
                                     h3("Summary:"),
                                     hr(),
                                     textOutput("textWEAPKeyGaugesCatchmentsA"), 
                                     hr(),
                                     actionButton("actionA", label = "Run WEAP and Extract streamflow"),
                                     hr(),
                                     h5("When you click on -Run WEAP and Extract streamflow-, the calculations will begin and a progress bar at the bottom right corner of the tool interface will tell you the progress percentage of the calculations. You will also see that the result files appear within the working directoy."),
                                     hr(),
                                     textOutput("textRunEnsembleA"),
                                     textOutput("textRunEnsembleA1")
                           ),
                           wellPanel(h2("4.  User-defined values for estimating the initial conductivity", style = "color:green"),
                                     h5("Default values are already set. Update these to reflect the reality of your particular basin."),
                                     numericInput('srpercent','3.1. How much of the streamflow is direct surface runoff (excluding base flow)? (DSR, %)',value=20),
                                     numericInput('z1','3.2. Enter in an estimate of the soil moisture content in the top bucket (z1, %)',value=30),
                                     numericInput('z2','3.3. Enter in an estimate of the soil moisture content in the bottom bucket (z2, %)',value=30),
                                     hr(),
                                     h5("First you must Run WEAP and Extract streamflow (seccion 3)"),
                                     hr(),
                                     actionButton("actionAConduc", label = "Calculate conductivity"),
                                     hr(),
                                     h5("When finished, the name of the file created will appear below"),
                                     textOutput("textRunEnsembleAConduc")
                                     
                           )
                    ),
                    column(8,
                           wellPanel(
                             h2("6. View results", style = "color:green"),
                             #hr(),
                             h4("If the tool was used before and the results were already calculated (section 1 to 4), the button -Update results- will load the -ResultsGauges.csv-, -Resultsk_Summary-DSR_-Z1_-Z2_.csv- and -Resultsk-DSR_-Z1_-Z2_.csv- files. Graphs will be shown."),
                             actionButton("actionUpdate", label = "Update results"),
                             hr(),
                             h3("Ratio of Observed Streamflow to Precipitation", style = "color:green"),
                             uiOutput("StreamflowA"),
                             wellPanel(
                               plotlyOutput("Q_Pmonthly")),
                             wellPanel(
                               plotlyOutput("Q_Pboxplot")),
                             hr(),
                             h3("Conductivity", style = "color:green"),
                             wellPanel(
                               dataTableOutput("kestimate")),
                             uiOutput("StreamflowAA"),
                             wellPanel(
                               plotlyOutput("kestimateGraphks")),
                             wellPanel(
                               plotlyOutput("kestimateGraphkd"))
                             
                           )
                    )
                  )
                )),
        
        tabItem("Calibration_Ensemble", 
                fluidPage(
                  titlePanel(h1("Setting up your WEAP Runs", style = "color:green")),
                  wellPanel(style = "background: white",
                            h4(
                              p("You will need some of the four input files: 1- WEAPKeyGaugesCatchments.csv, 2- WEAPKeyGaugeBranches.csv, 3- WEAPKeyEnsemble.csv or KeyModelInputs.csv,   
                      , and/or 4- WEAPKeyExport.csv. The need for each file depends on the purpose which the tool is used for.
                      The name of the files does not need to be the same. However, column names of each file must be the same."),
                              hr(),
                              p(strong("1-	WEAPKeyGaugesCatchments.csv")),
                              p("This file contains the list of catchments of each of the streamflow gauges to be analyzed.
                      "),
                              hr(),
                              p(strong("2-	WEAPKeyGaugeBranches.csv")),
                              p("This file contains the list of the observed and modeled streamflow branch of each of the streamflow gauges to be analyzed. 
                      "),
                              hr(),
                              p(strong("3- WEAPKeyEnsemble.csv or KeyModelInputs.csv")),
                              p("This file lists the variables in the WEAP model that you want to adjust as part of the calibration exercise. These variables 
                      could correspond to the soil parameter variables for a catchment, a key assumption controlling a particular parameter, or any 
                      other variable relevant to the calibration process (for example, a buffer coefficient to determine reservoir operating rules).
                      The range of the potential values is crucial for the calibration process. As a model builder, it is important to think critically about the physical 
                      realities of the basin that is being modelled and attempt to correlate that to the soil parameters used in the algorithms. 
                      Remember that, based on the number of combinations of sets of parameter values you have dictated WEAP to test out, the ensemble 
                      may include hundreds or thousands of runs. This means that both WEAP and R will be in use during the totality of the ensemble run; 
                      this may last hours or days. So, plan ahead to invest the time to run the ensemble and later interpret the results.")
                            ),
                            fluidRow(
                              column(6,
                                     h5(
                                       p("     3a-	WEAPKeyEnsamble.csv"),
                                       p("In this file, you identify the minimum and maximum value for each of the variables that you want to test, 
                               and the number of variations of values within that range you will test. The total runs will be the product of 
                               all the variations values. The algorithm will evenly distribute the variations within the range of potential values.
                               If you upload the -WEAPKeyEnsamble.csv-, the file -KeyModelInputs.csv- will be created and it will contain the list of all 
                               combinations of the supplied Keys within the thresholds and considering the number of Variations.")
                                     )),
                              column(6,
                                     h5(
                                       p("     3b-	KeyModelInputs.csv"),
                                       p("In this file, you identify the list the combination of the variables that you want to test. Each row must be 
                               identified with a numeric ID (Nrun Column). It is not necessary ID starts in 1. The file can contain as many rows as you 
                               want, but you need to have in mind the calculation time. If you upload a the -KeyModelInputs.csv-, it will be use directly.")
                                     ))
                            ),
                            hr(),
                            h4(p(strong("4-	WEAPKeyExport.csv  ")),
                               p("This file serves to indicate any results that want to be saved for each model run in the ensemble. 
                    The -Name- column contains the user-defined name and the - WEAPBranch:Variable[unit]- column indicates where in the WEAP model 
                    the variable can be found. This column contains an expression indicating the WEAP Branch, the variable, and the unit of the result 
                    of each user-defined result (Name column). Each variable of each element within your model has its own expression. 
                    It is not necessary to export -Observed Precipitation[M^3]-, -Evapotranspiration[M^3]-, -Surface Runoff[M^3]-, -Interflow[M^3]-, -
                    Base Flow[M^3]-, -Decrease in Soil Moisture[M^3]-, -Increase in Soil Moisture[M^3]-, -Decrease in Surface Storage[M^3]-, -Increase
                    in Surface Storage[M^3]-, -Area Calculated[M^2]-, -Relative Soil Moisture 1[%]- or Relative Soil Moisture 2[%]- for a particular 
                    catchment. Because these variables are part of the water balance variable, they are exported automatically in an aggregated way per 
                    each basin conformed for all the catchments that are upstream of a streamflow gauge.
                      ")
                            ),
                            hr(),
                            h4(strong("Follow the instructions in each of the numbered items within this tab. Be careful of uploading input files with the proper structure (column names), values (format) and WEAP expressions."))
                  ),
                  hr(),
                  fluidRow(
                    column(9,
                           wellPanel(
                             h2("1.  Gauge-catchment relationship file.", style = "color:green"),
                             hr(),
                             h3(strong("Choose file to upload, WEAPKeyGaugesCatchments.csv", style = "color:green")),
                             h5("Columns: Gauge, Catchment"),
                             fileInput('WEAPKeyGaugesCatchments', '',
                                       accept = c(
                                         'text/csv',
                                         'text/comma-separated-values',
                                         'text/tab-separated-values',
                                         'text/plain',
                                         '.csv',
                                         '.tsv' )            
                             ),
                             hr(),
                             h5("When the file is imported, it will appear here below:"),
                             column(12,
                                    DT::dataTableOutput("tableWEAPKeyGaugesCatchments"),style = "overflow-x: scroll;" 
                             )
                             
                           ),
                           wellPanel(
                             h2("2.  Modeled and Observed Gauge Branches file.", style = "color:green"),
                             hr(),
                             h3(strong("Choose file to upload, WEAPKeyGaugeBranches.csv", style = "color:green")),
                             h5("Columns: Gauge Name,	Observed Branch,	Modeled Branch"),
                             fileInput('WEAPKeyGaugeBranches', '',
                                       accept = c(
                                         'text/csv',
                                         'text/comma-separated-values',
                                         'text/tab-separated-values',
                                         'text/plain',
                                         '.csv',
                                         '.tsv' )            
                             ),
                             hr(),
                             h5("When the file is imported, it will appear here below:"),
                             column(12,
                                    DT::dataTableOutput("tableWEAPKeyGaugeBranches"),style = "overflow-x: scroll;" 
                             )
                             
                           ),
                           wellPanel(
                             h2("3.  WEAP Ensemble file.", style = "color:green"),
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
                             column(12,
                                    DT::dataTableOutput("tableWEAPKeyEnsemble"),style = "overflow-x: scroll;" 
                             )

                           ),
                           
                           wellPanel(
                             h2("4.  WEAP Export variable file.", style = "color:green"),
                             hr(),
                             h3(strong("Choose file to upload, WEAPKeyExport.csv", style = "color:green")), 
                             h5("Columns: Name, WEAPBranch:Variable[unit]"),
                             fileInput('WEAPKeyExport', '',
                                       accept = c(
                                         'text/csv',
                                         'text/comma-separated-values',
                                         'text/tab-separated-values',
                                         'text/plain',
                                         '.csv',
                                         '.tsv')            
                             ),
                             h5("When the file is imported, it will appear here below:"),
                             hr(),
                             column(12,
                                    DT::dataTableOutput("tableWEAPKeyExport"),style = "overflow-x: scroll;" 
                             )
                            
                           )
                    ),
                    column(3,
                           wellPanel(h2("5.  WEAP Area Information.", style = "color:green"),
                                     hr(),
                                     textInput("warea",label="Name of WEAP Area:"),
                                     textInput("start",label="Start Year:"),
                                     textInput("end",label="End Year:"),
                                     textInput("ts",label="TimeStep per year:"),
                                     textInput("Scen",label="Scenario:")
                           ),
                           wellPanel(h2("6. Run your WEAP ensemble.", style = "color:green"),
                                     hr(),
                                     h3("Ensemble summary:"),
                                     hr(),
                                     textOutput("textWEAPKeyEnsemble"),  
                                     textOutput("textWEAPKeyGaugesCatchments"), 
                                     textOutput("textWEAPKeyExport"), 
                                     hr(),
                                     actionButton("action", label = "Run WEAP"),
                                     
                                     hr(),
                                     h5("When you click on -Run WEAP-, the ensemble will begin and a progress bar at the bottom right corner of the tool interface will tell you the progress percentage of the ensemble. You will also see new files start to appear within the working directoy, containing the results for each model run."),
                                     h5("After starting ensemble run, wait for all the runs to be done and the WEAP application to save before continuing."),
                                     h5("You will know that the ensemble is finished when the progress bar disappears, and when you see the WEAP model stop running. At this point, you can go to the -3. Navigating Results- tab or -4. GOF filters- for exploring and filter the calibration results or to the -5.User Graphs- tab to graph variables from any *.csv file."),
                                     hr(),
                                     textOutput("textRunEnsemble")
                           )
                    )
                    
                    
                  )
                )
        ),
        
        tabItem("Navigating_Results", 
                  titlePanel(h1("Navigate Water balance results by combination of set of parameters", style = "color:green")),
                  hr(),
                  wellPanel(style = "background: white",
                            h4(
                              p("This section was made to interact with and visualize the results of the ensemble runs, in order to understand how the modeled 
                      hydrograph changes with changes in values of key parameters, and how that matches with observed streamflow and the water balance of the basin"),
                              p("When the calibration ensemble has finished a series of sliders will be shown on the left panel; these sliders 
                         correspond to each of your key parameters of the -WEAPKeyEnsemble.csv- or -KeyModelInputs.csv- file. You can click 
                         on and drag these sliders to select a different set of key parameter values"),
                              p("In the second panel, you are able to visualize results from the model run. The -Streamflow- tab plots i) the observed 
                      streamflow at the selected gauge station vs. the modeled streamflow, which has been output from the WEAP model and saved 
                      into your working directory, ii) the multiannual monthly average observed vs. modeled streamflow plot, and iii) the corresponding monthly 
                      flow duration curves.
                      The -Water Balance- tab will show the water balance plots. This set of visualizations give you information about the key components of the water balance 
                      in your basins for each model run: precipitation (black line), evapotranspiration (green), surface runoff (light blue), interflow (blue), and base flow (dark blue). 
                      Including this information in your calibration process is useful to verify the validity of different sets of key parameters: 
                      does the evapotranspiration produced by this set of key parameter values make sense for your model region? And does the ratio of surface runoff 
                      to base flow match your expectation? The plots show the time series for each of the components and the multiannual monthly average values of precipitation, evapotranspiration, and total streamflow. 
                      This multiannual values are also reported in a table"),
                              p("The table of values at the top shows the Goodness Of Fit (GOF) metrics quantifying the performance of your calibration showing the GOF values for the 
                    entire period, and validation (70% of the data) and calibration (30% of the data) period.
                      The GOF metrics reported are: Mean Absolute Error (mae), Normalized Root Mean Square Error ( -100% <= nrms <= 100% ) (NRMSE), Percent Bias (PBIAS),
                      Nash-Sutcliffe Efficiency ( -Inf <= NSE <= 1 ), Index of Agreement ( 0 <= d <= 1 ), Coefficient of Determination ( 0 <= R2 <= 1 ), 
                      Kling-Gupta efficiency between sim and obs ( 0 <= KGE <= 1 ), Volumetric efficiency between sim and obs ( -Inf <= VE <= 1)."),
                              p("All the plots are interactive, so you can zoom into the plot and/or compare any two data points when you place your mouse over the plot. 
                    Note that you may have to scroll to see the all the plots"), 
                              p("You can interact with the plots and with the sliders to see how your basin responds to changes in value of your key parameter, 
                      notice how the GOF values change, and how the hydrographs of the modeled streamflow shifts."),
                              p("In addition, If you are interested in calculating the GOF metrics for a particular subset of years, you can select the date range for which to 
                    calculate the metrics in the -2. Select value of parameters- panel.")),
                            hr(),
                            h4(strong("Follow each of the numbered items within this tab.")
                            )),
                  wellPanel(
                    h3("1. Select Gauge", style = "color:green"),
                    uiOutput("Streamflow"),
                    hr(),
                    column(12,
                           DT::dataTableOutput("metrics"),style = "overflow-x: scroll;" 
                    )
                    
                  ),
                  fluidRow(
                    column(3,
                           wellPanel(h3("2. Select value of parameters", style = "color:green"),
                                     hr(),
                                     uiOutput("daterange"),
                                     hr(),
                                     textOutput("runID"),
                                     hr(),
                                     uiOutput("sliders")
                           )),
                    column(9,
                           
                           wellPanel(
                             tabsetPanel(type="tabs",
                                         tabPanel("Streamflow",
                                                  fluidRow(
                                                    
                                                    wellPanel(plotlyOutput("Q")),
                                                    hr(),
                                                    column(6, 
                                                           wellPanel(plotlyOutput("Qmonthly"))),
                                                    column(6,
                                                           wellPanel(plotlyOutput("fdc")))
                                                  )),
                                         tabPanel("Water Balance",
                                                  fluidRow(
                                                    
                                                    wellPanel(plotlyOutput("WB")),
                                                    hr(),
                                                    column(6, 
                                                           wellPanel(plotlyOutput("WBmonthly"))),
                                                    column(6,
                                                           wellPanel(plotlyOutput("WBmonthlyB"))),
                                                    hr(),
                                                    wellPanel(
                                                      column(12,
                                                             DT::dataTableOutput("WBtable"),style = "overflow-x: scroll;" 
                                                      )
                                                     
                                                    ),
                                                    column(6,
                                                           wellPanel(plotlyOutput("WBSM"))),
                                                    column(6,
                                                           wellPanel(plotlyOutput("WBSE"))),
                                                    column(6,
                                                           wellPanel(plotlyOutput("SM1"))),
                                                    column(6,
                                                           wellPanel(plotlyOutput("SM2")))
                                                  ))))
                    ))
                ),
      
        tabItem("GOF_filter", 
                fluidPage(
                  titlePanel(h1("Select paramaters based on performance metrics", style = "color:green")),
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
                              p("In the panel -2. Enter thresholds for performance metrics-, the minimum Nash-Sutcliffe Efficiency (NSE), the maximum normalized 
                       root mean square error (nRMSE, %), and/or maximum bias (absolute value, %) can be set. These user-defined thresholds define an -acceptable- 
                       calibration. Each time that you set a diferent time period and press on the -calculte- button a new file is created."),
                              p("the panel -3. See filtered performance metrics- shows the set of GOF indices that satisfy the user-defined thresholds. 
                       You can also interact with the table and order the results by values and identified which model runs fall within an acceptable calibration range"),
                              p("In the panel -4. Choose run based on performance metrics-, you can enter in the run ID for the model run you would like to visualize. 
                       The table at the left and the plots will be updated automatically, and provide you the value of each of your key parameters for this particular model run.")
                            ),
                            hr(),
                            h4(strong("Follow each of the numbered items within this tab."))
                  ),
                  hr(),
                  wellPanel(
                    fluidRow(
                      column(5,
                             
                             h3("1. Calculate performance metrics within the indicated date range", style = "color:green"),
                             uiOutput("dateranget"),
                             actionButton("actmetrics", label = "Calculate"),
                            h5("When you click on -Calculate-, the calclations will begin and a progress bar at the bottom right corner of the tool interface will tell you the progress percentage of the calculations."),
                            hr(),
                            textOutput("textRunactmetrics")),
                            
                      column(7,
                             
                             h3("2. Enter thresholds for performance metrics", style = "color:green"),
                             column(4,numericInput("nse", label = "Minimum NSE", value = 0.7)),
                             column(4,numericInput("nrmse", label = "Maximum nRMSE (%)", value = 50)),
                             column(4,numericInput("bias",label="Maximum Bias (absolute value, %)", value = 10))))),
                 
                  wellPanel(
                    h3("3. See filtered performance metrics", style = "color:green"),
                    wellPanel(
                      column(12,
                             DT::dataTableOutput("metricsruns"),style = "overflow-x: scroll;" 
                      )
                      )
                  ),
                  hr(),
                  wellPanel(
                    fluidRow(
                      h3("4. Visualize results for a specified run", style = "color:green"),
                      column(2,
                             wellPanel(
                               h4("set of parameters of the specified run", style = "color:green"),
                               textOutput("runIDtt"),
                               hr(),
                               tableOutput("keysresults"))),
                      column(10,
                             
                             fluidRow(textOutput("runIDValues")),
                             fluidRow(
                               column(6, 
                                      uiOutput("inputRunIDt")),
                               
                               column(6,
                                      uiOutput("Streamflowt"))),
                             fluidRow(
                               
                               wellPanel(
                                 h4("the -Filtered GOF Graphs- tab shows only the filtered GOFs of the selected gauge. The graphs shown in the -Streamflow- tab and the -Water Balance- tab are for the selected run and the selected gauge."),
                                 tabsetPanel(type="tabs",
                                             tabPanel("Filtered GOF Graphs",
                                                      wellPanel(
                                                        fluidRow(
                                                          column(3,
                                                                 plotlyOutput("GOFtMAE")),
                                                          column(3,
                                                                 plotlyOutput("GOFtNRMSE")),
                                                          column(3,
                                                                 plotlyOutput("GOFtPBIAS")),
                                                          column(3,
                                                                 plotlyOutput("GOFtNSE"))
                                                        )),
                                                      hr(),
                                                      wellPanel(
                                                        fluidRow(
                                                          
                                                          column(3,
                                                                 plotlyOutput("GOFtd")),
                                                          column(3,
                                                                 plotlyOutput("GOFtR2")),
                                                          column(3,
                                                                 plotlyOutput("GOFtKGE")),
                                                          column(3,
                                                                 plotlyOutput("GOFtVE"))
                                                        ))
                                             ),
                                             tabPanel("Streamflow",
                                                      fluidRow(
                                                        
                                                        wellPanel(plotlyOutput("Qt")),
                                                        hr(),
                                                        column(6, 
                                                               wellPanel(plotlyOutput("Qmonthlyt"))),
                                                        column(6,
                                                               wellPanel(plotlyOutput("fdct")))
                                                      )),
                                             tabPanel("Water Balance",
                                                      fluidRow(
                                                        
                                                        wellPanel(plotlyOutput("WBt")),
                                                        hr(),
                                                        column(6, 
                                                               wellPanel(plotlyOutput("WBmonthlyt"))),
                                                        column(6,
                                                               wellPanel(plotlyOutput("WBmonthlytB"))),  
                                                        hr(),
                                                        wellPanel(
                                                          column(12,
                                                                 DT::dataTableOutput("WBtablet"),style = "overflow-x: scroll;" 
                                                          )
                                                          
                                                        ),
                                                        column(6,
                                                               wellPanel(plotlyOutput("WBSMt"))),
                                                        column(6,
                                                               wellPanel(plotlyOutput("WBSEt"))),
                                                        column(6,
                                                               wellPanel(plotlyOutput("SM1t"))),
                                                        column(6,
                                                               wellPanel(plotlyOutput("SM2t")))
                                                      ))))
                             )
                      )))
                )),
      
        tabItem("Graphs", 
                fluidPage(
                  titlePanel(h1("Select the file which contains the variables to plot", style = "color:green")),
                  wellPanel(style = "background: white",
                            h4("You can set graphs by uploading a file within the working directory"),
                            h4("* If the file contains a column with dates, the column must be named as -Dates- and follow a format yyyy-mm-dd"),
                            h4("* If the file contains a column with streamflow gauge stations, the column must be named as -Gauge-"),
                            h4("* If the file contains a column with catchment, the column must be named as -Catchment-"),
                            hr(),
                            h4(strong("Follow each of the numbered items within this tab."))
                  ),
                  hr(),
                  wellPanel(
                    h2("1. Set the working directory where the files are", style = "color:green"),
                    h5("Copy and paste the full path:"),
                    textInput("WD_resultsGraphs", "", "", width="80%"),
                    textOutput("textWD_resultsGraphs"),
                    hr(),
                    h2("2. Choose de *.csv file.", style = "color:green"),
                    h5("The list of the *.csv files within the working directory are listed below:"),
                    uiOutput("UploadedFileCsv"),
                    hr(),
                    h5("When the file is imported, it will appear here below:"),
                    
                    column(12,
                           DT::dataTableOutput("tableUploadedFile"),style = "overflow-x: scroll;" 
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
                             uiOutput("Xaxis")),
                      column(4,
                             uiOutput("Yaxis")),
                      column(4,
                             uiOutput("Zaxis"))
                    ),
                    
                    fluidRow(
                      column(6,
                             uiOutput("Gauges")),
                      column(6,
                             uiOutput("Catchment"))
                    ),
                    h2("5. Explore the graph", style = "color:green"),
                    plotlyOutput("plotfile"),
                    
                    h5("The plotted data is:"),
                    column(12,
                           DT::dataTableOutput("tableplotfile"),style = "overflow-x: scroll;" 
                    )  
                    
                  )
                  
                ))
        
      ))
  ),

  server = function(input, output) { 
    
    output$textWD_results <-renderText({
      if (is.null(input$WD_results)) {
        return(NULL)
      } else {
        setwd(input$WD_results)
        Carpeta_Out=as.character("SEI tool Results")
        dir.create(Carpeta_Out,showWarnings=F)
        dir_outg = paste(c(input$WD_results,"\\",Carpeta_Out),collapse="")
        setwd(dir_outg)
        paste0("The working directory was changed to: ",getwd())
      }
    })
    
    
    output$textRunEnsembleA <- renderText({("Press button to run. Run time will appear here when finished.")})
    
    output$textRunEnsembleAConduc <- renderText({("Press button to calculate")})
    
    output$tableWEAPKeyGaugesCatchmentsA <- renderDataTable({
      inFile <- input$WEAPKeyGaugesCatchmentsA
      if (is.null(inFile))
        return(NULL)
      read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
    })
    
    output$textWEAPKeyGaugesCatchmentsA <- renderText({ 
      if(is.null(input$WEAPKeyGaugesCatchmentsA)){return("Calibration analisis will be made in 0 streamflowgauges")}
      inFile <- input$WEAPKeyGaugesCatchmentsA
      data <- read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
      runs <- length(unique(data$Gauge))
      paste0("Estimations will be made in ", runs," streamflowgauges")
    })
    
    output$tableWEAPKeyGaugeBranchesA <- renderDataTable({
      inFile <- input$WEAPKeyGaugeBranchesA
      if (is.null(inFile))
        return(NULL)
      read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
    })
    
    observeEvent(input$actionA,{ 
      
      start = Sys.time()
      
      sy <- input$startA
      ey <- input$endA
      Warea <- input$wareaA
      Scen <- input$ScenA
      ts <- input$tsA
      
      WEAP <- COMCreate("WEAP.WEAPApplication") 
      
      Sys.sleep(3)
      WEAP[["ActiveArea"]] <- Warea
      WEAP[["BaseYear"]] <- sy
      WEAP[["EndYear"]] <- ey
      WEAP[["Verbose"]] <- 0
      
      years <- seq(as.numeric(sy),as.numeric(ey))
      rows <- (as.numeric(ey)-as.numeric(sy)+1)*as.numeric(ts)
      
      if (ts==365){
        myDates=data.frame(seq(as.Date(paste0(sy,"-01-01")), to=as.Date(paste0(ey,"-12-31")),by="day"))
        names(myDates)= "Dates"
        myDates <- myDates[!(format(myDates$Dates,"%m") == "02" & format(myDates$Dates, "%d") == "29"), ,drop = FALSE]
      }else if (ts==12){
        myDates=data.frame(seq(as.Date(paste0(sy,"-01-01")), to=as.Date(paste0(ey,"-12-31")),by="month"))
        names(myDates)= "Dates"
      }else{
        d=seq(from=0, by=round(365/ts),length.out = ts)
        myDates=data.frame(as.Date(paste0(sy,"-01-01"))+d)
        names(myDates)= "Dates"
        if (length(years)>1){
          for (i in years[2:length(years)]){
            myDates1==data.frame(as.Date(paste0(i,"-01-01"))+d)
            names(myDates1)= "Dates"
            myDates=rbind(myDates,myDates1) 
          }
        }
      }
      
      KeyGaugeBranches = NULL
      KeyGaugesCatchments=NULL
      inFile <- input$WEAPKeyGaugesCatchmentsA
      if (!is.null(inFile)){
        KeyGaugesCatchments=read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
        uniqueGauges=unique(KeyGaugesCatchments$Gauge)
        
        Catchment_gauges=unique(KeyGaugesCatchments$Catchment)
        WEAPKeyBranchesCatchment=as.data.frame(matrix(NA,ncol=3,nrow = length(Catchment_gauges)))
        colnames(WEAPKeyBranchesCatchment)=c("Catchment",
                                             "Area Calculated[M^2]",
                                             "Observed Precipitation[M^3]")
        rowG_C=1
        for (g in 1:length(uniqueGauges)){
          NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
          NcatchG=length(NamecatchG)
          
          for (c in 1:NcatchG){
            WEAPKeyBranchesCatchment[rowG_C,1]=NamecatchG[c]
            WEAPKeyBranchesCatchment[rowG_C,2:ncol(WEAPKeyBranchesCatchment)]=paste0("Demand Sites and Catchments\\",NamecatchG[c],":",colnames(WEAPKeyBranchesCatchment)[2:ncol(WEAPKeyBranchesCatchment)])
            rowG_C=rowG_C+1
          }
        }
        WEAPKeyBranchesCatchment=unique(WEAPKeyBranchesCatchment)
        write.csv(WEAPKeyBranchesCatchment,paste0(getwd(),"\\WEAPKeyBranchesCatchmentk.csv"),row.names=F) 
        inFile <- input$WEAPKeyGaugeBranchesA
        KeyGaugeBranches <- read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
      }
      
      withProgress(message = 'Progress of exporting results:', value = 0, 
                   {
                     
                     
                     WEAP$DeleteResults()
                     
                     WEAP[["ActiveScenario"]] <- Scen
                     
                     WEAP$Calculate() 
                     
                   
                     resultsWBG=matrix(0,ncol=4,nrow = rows*length(uniqueGauges))
                     colnames(resultsWBG)=c("Year",
                                            "Time step",
                                            "Gauge",
                                            "Observed [M^3]")
                     
                     
                     resultsWBC=matrix(0,ncol=5,nrow = rows*length(Catchment_gauges))
                     colnames(resultsWBC)=c("Year",
                                            "Time step",
                                            "Catchment",
                                            "Area Calculated[M^2]",
                                            "Observed Precipitation[M^3]")
                     rowWBG=1
                     rowWBC=1
                     
                     prog=1
                     
                     for(a in 1:length(years)) {
                       
                       
                       y <- years[a] 
                       
                       for(t in 1:ts) {
                         
                         incProgress(1/(length(years)*as.numeric(ts)), detail = paste0("Importing results for ",length(years)," years: ", round(prog/(length(years)*as.numeric(ts))*100,3),"%")) 
                         
                         for (g in 1:length(uniqueGauges)){
                           resultsWBG[rowWBG,1] <- as.numeric(y)
                           resultsWBG[rowWBG,2] <- as.numeric(t)
                           resultsWBG[rowWBG,3] <- uniqueGauges[g]
                           resultspathWB=as.character(KeyGaugeBranches[KeyGaugeBranches$`Gauge Name`==uniqueGauges[g],2:3])
                           res=-9999
                           r=1
                           res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                           if(res==-9999) {res<- NA}
                           {resultsWBG[rowWBG,r+3] <- res}
                           rowWBG=rowWBG+1
                         }
                         
                         for (c in 1:length(Catchment_gauges)) {
                           resultsWBC[rowWBC,1] <- as.numeric(y)
                           resultsWBC[rowWBC,2] <- as.numeric(t)
                           resultsWBC[rowWBC,3] <- Catchment_gauges[c]
                           resultspathWB=as.character(WEAPKeyBranchesCatchment[WEAPKeyBranchesCatchment$Catchment==Catchment_gauges[c],2:ncol(WEAPKeyBranchesCatchment)])
                           r=1
                           res=-9999
                           res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                           if(res==-9999) {res<- NA}
                           {resultsWBC[rowWBC,r+3] <- res}
                           r=2
                           res=-9999
                           res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                           if(res==-9999) {res<- NA}
                           {resultsWBC[rowWBC,r+3] <- res}
                           
                           rowWBC=rowWBC+1
                         }
                         
                         prog=prog+1
                         
                       }
                     }
                     
                     
                     Catchs=as.data.frame(resultsWBC)
                     Gauges=as.data.frame(resultsWBG)
                     
                     resultsWB=matrix(0,ncol=6,nrow = rows*length(uniqueGauges))
                     colnames(resultsWB)=c("Year",
                                           "Time step",
                                           "Gauge",
                                           "Observed [M^3]",
                                           "Area Calculated[M^2]",
                                           "Observed Precipitation[M^3]")
                     
                     rowWB=1
                     for (g in 1:length(uniqueGauges)) {
                       Gaugessub=Gauges[Gauges$Gauge==uniqueGauges[g],]
                       Gaugessub$`Observed [M^3]`=gsub(-9999,NA,Gaugessub$`Observed [M^3]`,fixed = TRUE)
                       resultsWB[rowWB:(rowWB+rows-1),1] <- as.numeric(Gaugessub$Year)
                       resultsWB[rowWB:(rowWB+rows-1),2] <- as.numeric(Gaugessub$`Time step`)
                       resultsWB[rowWB:(rowWB+rows-1),3] <- uniqueGauges[g]
                       resultsWB[rowWB:(rowWB+rows-1),4] <- as.numeric(Gaugessub$`Observed [M^3]`)
                       
                       for (c in 1:length(NamecatchG)) {
                         Catchssub=Catchs[Catchs$Catchment==NamecatchG[c],]
                         resultsWB[rowWB:(rowWB+rows-1),5]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),5])+as.numeric(Catchssub[,4])
                         resultsWB[rowWB:(rowWB+rows-1),6]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),6])+as.numeric(Catchssub[,5])
                       }
                       
                       rowWB=rowWB+rows
                     }
                     
                     resultsWB = cbind(resultsWB,myDates)
                     write.csv(resultsWB,paste0(getwd(),"\\ResultsGauges.csv"),row.names=F) 
                   
                     
                     WEAP$SaveArea()
                     rm(WEAP)
                     gc()
                     
                   })

      output$textRunEnsembleA <- renderText({format(as.difftime(difftime(Sys.time(),start), format = "%H:%M")) })
      output$textRunEnsembleA1 <- renderText({paste0("Results imported and save within the working directory") })
      
      output$StreamflowA <- renderUI({
          gauges=unique(resultsWB[,3])
          selectInput("StreamflowSelectA", "Streamflow Gauge",gauges)
      })
    
    })
    
    observeEvent(input$actionAConduc,{ 
      
      if (file.exists(paste0(getwd(),"\\ResultsGauges.csv"))) {
       
        obs <- read.csv(paste0(getwd(),"//ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
        obs=obs[,-6]
        colnames(obs)=c("Year",
                        "Time step",
                        "Gauge",
                        "Observed",
                        "Area",
                        "Dates")
        
        
        sy <- min(obs$Year)
        ey <- max(obs$Year)
        ts <- max(obs$`Time step`)
        
        years <- seq(as.numeric(sy),as.numeric(ey))
        rows <- (as.numeric(ey)-as.numeric(sy)+1)*as.numeric(ts)
        
        obs$ks=NA
        obs$kd=NA
        
        table <- data.frame(matrix(NA,ncol=5, nrow=length(unique(obs$Gauge))))
        colnames(table)=c("Gauge","Min Ks, top bucket","Max Ks, top bucket","Min Kd, bottom bucket","Max Kd, bottom bucket")
        
        row=1
        
        for (i in 1:length(unique(obs$Gauge))){
          
          table[i,1]=unique(obs$Gauge)[i]
          
          flows=obs[obs$Gauge==table[i,1],]
          flows$Dates <- ymd(flows$Dates)
          
          high <- max(flows$Observed,na.rm=T) 
          low <- min(flows$Observed,na.rm=T) 
          if (low==0){
            low <- unique(sort(na.exclude(flows$Observed)))[2] 
          }
          
          outflow <- high-low 
          sr <- outflow*(as.numeric(input$srpercent)/100)
          interflow <- outflow-sr 
          
          interflowd <- interflow/flows$Area*1000 
          flows$ks <- interflowd/(as.numeric(input$z1)/100)^2 
          
          bfdepth <- low/flows$Area*1000 
          flows$kd <- bfdepth/(as.numeric(input$z2)/100)^2 
          
          table[i,2] <- round(min(flows$ks),2) 
          table[i,3] <- round(max(flows$ks),2)
          table[i,4] <- round(min(flows$kd),2) 
          table[i,5] <- round(max(flows$kd),2)
          
          obs[(row):(i*rows),7]=flows$ks
          obs[(row):(i*rows),8]=flows$kd
          row=row+rows
          
        }
        
        write.csv(obs[,c(-4,-5)],paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"),row.names=F) 
        write.csv(table,paste0(getwd(),"\\Resultsk_Summary","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"),row.names=F) 
        
        output$textRunEnsembleAConduc <- renderText({ paste0("Initial Conductivity was calculated for "," DSR: ",input$srpercent," Z1: ",input$z1," Z2: ",input$z2, ". Check the -SEI tool Results- folder within your working directory")  })
      
        table <- read.csv(paste0(getwd(),"\\Resultsk_Summary","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"), stringsAsFactors=F, check.names=F)
        output$kestimate <- renderDataTable({
          table
        })
        
        output$StreamflowAA <- renderUI({
          gauges=unique(table[,1])
          selectInput("StreamflowSelectAA", "Streamflow Gauge",gauges)
        })
        
        if (file.exists(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"))){
          
          file <- read.csv(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"), stringsAsFactors=F, check.names=F)
          file$Dates=ymd(file$Dates)
          file=file[file$Gauge==input$StreamflowSelectAA,]
          #fileA=file
          #fileA
          
          output$kestimateGraphks <- renderPlotly({
            #file=fileA()
            if (file.exists(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"))){
              
              p1 <-plot_ly(file, x=~Dates, y=~ks, name = "ks, top bucket conductivity", type="scatter", mode="lines",
                           line = list(color="red",width=1.5)) %>%
                layout(title = paste0("ks, top bucket conductivity ",input$StreamflowSelectAA," DSR:",input$srpercent,"% Z1:",input$z1,"% Z2:",input$z2,"%"),
                       xaxis = list(title=""),
                       yaxis = list(title= "ks (mm)"))
              p1
            }
            
          })
          
          output$kestimateGraphkd <- renderPlotly({
            #file=fileA()
            if (file.exists(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"))){
              
              p2 <-plot_ly(file, x=~Dates, y=~kd, name = "kd, bottom bucket conductivity", type="scatter", mode="lines",
                           line = list(color="red",width=1.5)) %>%
                layout(title = paste0("kd, bottom bucket conductivity ",input$StreamflowSelectAA," DSR:",input$srpercent,"% Z1:",input$z1,"% Z2:",input$z2,"%"),
                       xaxis = list(title=""),
                       yaxis = list(title= "kd (mm)"))
              p2
            }
          })
        }
        
        
        
        }
      
    })
    
    observeEvent(input$actionUpdate,{
      
      if (file.exists(paste0(getwd(),"\\ResultsGauges.csv")) && file.exists(paste0(getwd(),"\\Resultsk_Summary","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"))){
        
      table <- read.csv(paste0(getwd(),"\\Resultsk_Summary","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"), stringsAsFactors=F, check.names=F)
      file <- read.csv(paste0(getwd(),"\\ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
      
      output$StreamflowA <- renderUI({
        
        gauges=unique(file[,3])
        selectInput("StreamflowSelectA", "Streamflow Gauge",gauges)
      })
      
      output$StreamflowAA <- renderUI({
        gauges=unique(table[,1])
        selectInput("StreamflowSelectAA", "Streamflow Gauge",gauges)
      })
      
      output$kestimate <- renderDataTable({
        table
      })
      
      
      }
      
    })

    observeEvent(input$StreamflowSelectA,{ 
      
      if (file.exists(paste0(getwd(),"\\ResultsGauges.csv"))){
        
        file <- read.csv(paste0(getwd(),"\\ResultsGauges.csv"), stringsAsFactors=F, check.names=F)
        colnames(file)=c("Year",
                         "Time step",
                         "Gauge",
                         "Observed",
                         "Area",
                         "Precipitation",
                         "Dates")
        file$Dates=ymd(file$Dates)
        file$YearMonth=year(file$Dates)*100+month(file$Dates)
        file$Precipitation<- file$Precipitation/file$Area*1000
        file$Observed <- file$Observed/file$Area*1000
        file=file[which(file$Gauge==input$StreamflowSelectA),]
        years <- seq(as.numeric(year(min(file$Dates))),as.numeric(year(max(file$Dates))))
        myDates=seq(as.Date(paste0(year(min(file$Dates)),"-01-01")), to=as.Date(paste0(year(max(file$Dates)),"-12-31")),by="month")
        file=file[,c("Observed","Precipitation","YearMonth")]
        file <- aggregate(file[,1:(ncol(file)-1)], by=list(YearMonth=file$YearMonth),sum,na.rm=F)
        file$Dates=ymd(myDates)
        file$Q_P=round(file$Observed/file$Precipitation*100,2)
        #fileB=file
        #fileB
        
        output$Q_Pmonthly <- renderPlotly({
          # file=fileB()
          p <-plot_ly(file, x=~Dates, y=~Precipitation, name = "Precipitation", type="bar",text=~paste0("Precipitation = ", Precipitation)) %>%
            add_trace(y=~Observed, name="Observed Streamflow", type="scatter", mode="line", text=~paste0("Observed = ", Observed)) %>%
            add_trace(x = ~Dates, y = ~Q_P, name = "% Observed streamflow/Precipitation", type="scatter", mode="line", text=~paste0("% Observed streamflow/Precipitation = ", Q_P), yaxis = "y2") %>%
            layout(yaxis2 = list(overlaying = "y", side = "right", title = "Observed streamflow/Precipitation (%)"), 
                   title = paste0("Monthly Precipitation and Observed streamflow ",input$StreamflowSelectA),
                   xaxis = list(title="Dates"),
                   yaxis = list(title= "Observed streamflow and Precipitation (mm)"))
          p
          
          
        })
        
        output$Q_Pboxplot <- renderPlotly({
          # file=fileB()
          file$Month=file$YearMonth%%100
          file1 <- aggregate(file[,c(2,3,5)], by=list(Month=file$Month),mean,na.rm=T)
          final_df=merge(file1,file,all.x = TRUE,all.y = TRUE,by="Month")
          p <-plot_ly(final_df, x = ~Month, y = ~Q_P.x, name = "% Observed streamflow/Precipitation", type="scatter", mode="line", text=~paste0("% Observed streamflow/Precipitation = ",  Q_P.x))  %>% 
            add_trace(x = ~Month, y = ~Q_P.y, type="box", name="% Observed streamflow/Precipitation",  text=~paste0("% Observed streamflow/Precipitation = ", Q_P.y)) %>% 
            layout( title = paste0("Monthly Observed streamflow/Precipitation (%) ",input$StreamflowSelectA),
                    xaxis = list(title="Month"),
                    yaxis = list(title= "Observed streamflow/Precipitation (%)"))
          p
        }) 
        
      }
    })
    
    observeEvent(
      {input$StreamflowSelectAA 
       input$srpercent 
       input$z1 
       input$z2},{ 
      
      if (file.exists(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"))){
      
      file <- read.csv(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"), stringsAsFactors=F, check.names=F)
      file$Dates=ymd(file$Dates)
      file=file[file$Gauge==input$StreamflowSelectAA,]
      #fileA=file
      #fileA
      
      output$kestimateGraphks <- renderPlotly({
        #file=fileA()
        if (file.exists(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"))){
          
        p1 <-plot_ly(file, x=~Dates, y=~ks, name = "ks, top bucket conductivity", type="scatter", mode="lines",
                     line = list(color="red",width=1.5)) %>%
          layout(title = paste0("ks, top bucket conductivity ",input$StreamflowSelectAA," DSR:",input$srpercent,"% Z1:",input$z1,"% Z2:",input$z2,"%"),
                 xaxis = list(title=""),
                 yaxis = list(title= "ks (mm)"))
        p1
        }
        
      })
      
      output$kestimateGraphkd <- renderPlotly({
        #file=fileA()
        if (file.exists(paste0(getwd(),"\\Resultsk","-DSR",input$srpercent,"-Z1",input$z1,"-Z2",input$z2,".csv"))){
          
          p2 <-plot_ly(file, x=~Dates, y=~kd, name = "kd, bottom bucket conductivity", type="scatter", mode="lines",
                     line = list(color="red",width=1.5)) %>%
          layout(title = paste0("kd, bottom bucket conductivity ",input$StreamflowSelectAA," DSR:",input$srpercent,"% Z1:",input$z1,"% Z2:",input$z2,"%"),
                 xaxis = list(title=""),
                 yaxis = list(title= "kd (mm)"))
        p2
        }
      })
      }
      
    })
    
     ##
    
    observeEvent(input$WEAPKeyEnsemble,{
      output$tableWEAPKeyEnsemble <- renderDataTable({
        inFile1 <- input$WEAPKeyEnsemble
        
        if (!is.null(inFile1)) {
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
          
          write.csv(table,paste0(getwd(),"//KeyModelInputs.csv"),row.names=F)
          
          output$textWEAPKeyEnsemble <- renderText({ 
            runs <- nrow(table)
            paste0("Your WEAP model will need to run ", runs," times")
          })
          
          data
          
        } else {
          return(NULL)
        }
      })
      
    })
    observeEvent(input$WEAPKeyEnsembleInputs,{
      output$tableWEAPKeyEnsemble <- renderDataTable({
        inFile2 <- input$WEAPKeyEnsembleInputs
        
        if (!is.null(inFile2)) {
          data <- read.csv(inFile2$datapath, stringsAsFactors=F, check.names=F)
          write.csv(data,paste0(getwd(),"//KeyModelInputs.csv"),row.names=F)
          
          output$textWEAPKeyEnsemble <- renderText({ 
            runs <- nrow(data)
            paste0("Your WEAP model will need to run ", runs," times")
          })
          
          data
        } else {
          return(NULL)
        }
        
      })
      
      
    })
    
    output$tableWEAPKeyGaugeBranches <- renderDataTable({
      inFile <- input$WEAPKeyGaugeBranches
      
      if (is.null(inFile))
        return(NULL)
      
      read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
    })
    
    output$tableWEAPKeyExport <- renderDataTable({
      inFile <- input$WEAPKeyExport
      if (is.null(inFile))
        return(NULL)
      
      read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
    })
    
    output$textWEAPKeyExport <- renderText({ 
      if(is.null(input$WEAPKeyExport)){return("After each run 0 variables will be exported")}
      inFile <- input$WEAPKeyExport
      data <- read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
      runs <- nrow(data)
      paste0("After each run ", runs," variables will be exported")
    })
    
    output$tableWEAPKeyGaugesCatchments <- renderDataTable({
      inFile <- input$WEAPKeyGaugesCatchments
      if (is.null(inFile))
        return(NULL)
      read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
    })
    
    output$textWEAPKeyGaugesCatchments <- renderText({ 
      if(is.null(input$WEAPKeyGaugesCatchments)){return("Calibration analysis will be made in 0 streamflowgauges")}
      inFile <- input$WEAPKeyGaugesCatchments
      data <- read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
      runs <- length(unique(data$Gauge))
      paste0("Calibration analysis will be made in ", runs," streamflowgauges")
    })
    
    output$textRunEnsemble <- renderText({("Press button to run. Run time will appear here when finished.")})
    
    observeEvent(input$action,{ 
      
      start = Sys.time()
      
      sy <- input$start
      ey <- input$end
      Warea <- input$warea
      Scen <- input$Scen
      ts <- input$ts
      
      WEAP <- COMCreate("WEAP.WEAPApplication") 
      
      Sys.sleep(3)
      WEAP[["ActiveArea"]] <- Warea
      WEAP[["BaseYear"]] <- sy
      WEAP[["EndYear"]] <- ey
      WEAP[["Verbose"]] <- 0
      
      years <- seq(as.numeric(sy),as.numeric(ey))
      rows <- (as.numeric(ey)-as.numeric(sy)+1)*as.numeric(ts)
      
      if (ts==365){
        myDates=data.frame(seq(as.Date(paste0(sy,"-01-01")), to=as.Date(paste0(ey,"-12-31")),by="day"))
        names(myDates)= "Dates"
        myDates <- myDates[!(format(myDates$Dates,"%m") == "02" & format(myDates$Dates, "%d") == "29"), ,drop = FALSE]
      }else if (ts==12){
        myDates=data.frame(seq(as.Date(paste0(sy,"-01-01")), to=as.Date(paste0(ey,"-12-31")),by="month"))
        names(myDates)= "Dates"
      }else{
        d=seq(from=0, by=round(365/ts),length.out = ts)
        myDates=data.frame(as.Date(paste0(sy,"-01-01"))+d)
        names(myDates)= "Dates"
        if (length(years)>1){
          for (i in years[2:length(years)]){
            myDates1==data.frame(as.Date(paste0(i,"-01-01"))+d)
            names(myDates1)= "Dates"
            myDates=rbind(myDates,myDates1) 
          }
        }
      }
      
      keyinputs = NULL
      if (file.exists(paste0(getwd(),"\\KeyModelInputs.csv"))){
        keyinputs <- read.csv(paste0(getwd(),"\\KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
        keys <- colnames(keyinputs)[2:ncol(keyinputs)]
        runs <- nrow(keyinputs)
      }
      
      KeyExport=NULL
      inFile <- input$WEAPKeyExport
      if (!is.null(inFile)){
         KeyExport=read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
        resultsp <- KeyExport
        names <- resultsp$Name
        resultspath <- resultsp$`WEAPBranch:Variable[unit]`
      }
      
      KeyGaugeBranches = NULL
      KeyGaugesCatchments=NULL
      inFile <- input$WEAPKeyGaugesCatchments
      if (!is.null(inFile)){
        KeyGaugesCatchments=read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
        uniqueGauges=unique(KeyGaugesCatchments$Gauge)
        
        Catchment_gauges=unique(KeyGaugesCatchments$Catchment)
        WEAPKeyBranchesCatchment=as.data.frame(matrix(NA,ncol=13,nrow = length(Catchment_gauges)))
        colnames(WEAPKeyBranchesCatchment)=c("Catchment",
                                             "Observed Precipitation[M^3]",
                                             "Evapotranspiration[M^3]",
                                             "Surface Runoff[M^3]",
                                             "Interflow[M^3]",
                                             "Base Flow[M^3]",
                                             "Decrease in Soil Moisture[M^3]",
                                             "Increase in Soil Moisture[M^3]",
                                             "Decrease in Surface Storage[M^3]",
                                             "Increase in Surface Storage[M^3]",
                                             "Area Calculated[M^2]",
                                             "Relative Soil Moisture 1[%]",
                                             "Relative Soil Moisture 2[%]"
        )
        rowG_C=1
        for (g in 1:length(uniqueGauges)){
          NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
          NcatchG=length(NamecatchG)
          
          for (c in 1:NcatchG){
            WEAPKeyBranchesCatchment[rowG_C,1]=NamecatchG[c]
            WEAPKeyBranchesCatchment[rowG_C,2:ncol(WEAPKeyBranchesCatchment)]=paste0("Demand Sites and Catchments\\",NamecatchG[c],":",colnames(WEAPKeyBranchesCatchment)[2:ncol(WEAPKeyBranchesCatchment)])
            rowG_C=rowG_C+1
          }
        }
        WEAPKeyBranchesCatchment=unique(WEAPKeyBranchesCatchment)
        write.csv(WEAPKeyBranchesCatchment,paste0(getwd(),"\\WEAPKeyBranchesCatchment.csv"),row.names=F) 
        
         inFile <- input$WEAPKeyGaugeBranches
        KeyGaugeBranches <- read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
      }
      
      KeyEnsemble=NULL
      inFile <- input$WEAPKeyEnsemble
      if (!is.null(inFile)){
         KeyEnsemble=read.csv(inFile$datapath, stringsAsFactors=F, check.names=F)
      }
      
      withProgress(message = 'Progress of WEAP Ensemble:', value = 0, 
                   {
                     if (!is.null(keyinputs) && !is.null(KeyGaugeBranches) && !is.null(KeyExport)){
                       prog=1
                       for(i in 1:nrow(keyinputs)) {
                         
                         RUNID=keyinputs[i,1]
                         
                         WEAP[["ActiveScenario"]] <- Scen
                         WEAP$DeleteResults()
                         
                         for(k in 1:length(keys)) {
                           res <- try(
                             WEAP$BranchVariable(keys[k])[["Expression"]] <- keyinputs[i,k+1] 
                           )
                         }
                         
                         WEAP$Calculate() 
                         
                         results <- as.data.frame(matrix(NA,nrow=rows,ncol=length(names)+2)) 
                         colnames(results) <- c("Year","Time step",names)
                         
                         resultsWBG=as.data.frame(matrix(0,ncol=5,nrow = rows*length(uniqueGauges)))
                         colnames(resultsWBG)=c("Year",
                                                "Time step",
                                                "Gauge",
                                                "Observed",
                                                "Modeled"
                         )
                         
                         
                         resultsWBC=as.data.frame(matrix(0,ncol=15,nrow = rows*length(Catchment_gauges)))
                         colnames(resultsWBC)=c("Year",
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
                                                "Area",
                                                "Relative Soil Moisture 1",
                                                "Relative Soil Moisture 2"
                         )
                         row=1
                         rowWBG=1
                         rowWBC=1
                         
                         for(a in 1:length(years)) {
                           
                           y <- years[a] 
                           
                           for(t in 1:ts) {
                             
                             incProgress(1/(nrow(keyinputs)*length(years)*as.numeric(ts)), detail = paste0("Progress of ",nrow(keyinputs)," runs: ",round(prog/(nrow(keyinputs)*length(years)*as.numeric(ts))*100,3),"%") )
                             
                             for (g in 1:length(uniqueGauges)){
                               resultsWBG[rowWBG,1] <- as.numeric(y)
                               resultsWBG[rowWBG,2] <- as.numeric(t)
                               resultsWBG[rowWBG,3] <- uniqueGauges[g]
                                resultspathWB=as.character(KeyGaugeBranches[KeyGaugeBranches$`Gauge Name`==uniqueGauges[g],2:3])
                               for(r in 1:length(resultspathWB)){
                                 res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                                 if(res==-9999) {res<- NA}
                                 {resultsWBG[rowWBG,r+3] <- res}
                               }
                               rowWBG=rowWBG+1
                             }
                             
                             for (c in 1:length(Catchment_gauges)){
                               resultsWBC[rowWBC,1] <- as.numeric(y)
                               resultsWBC[rowWBC,2] <- as.numeric(t)
                               resultsWBC[rowWBC,3] <- Catchment_gauges[c]
                                resultspathWB=as.character(WEAPKeyBranchesCatchment[WEAPKeyBranchesCatchment$Catchment==Catchment_gauges[c],2:ncol(WEAPKeyBranchesCatchment)])
                               for(r in 1:length(resultspathWB)){
                                 res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                                 if(res==-9999) {res<- NA}
                                 {resultsWBC[rowWBC,r+3] <- res}
                               }
                               rowWBC=rowWBC+1
                             }
                             
                             if (length(names)>0){  
                               results[row,1] <- as.numeric(y)
                               results[row,2]  <- as.numeric(t)
                               for(r in 1:length(names)) {
                                 res <- WEAP$ResultValue(resultspath[r],y,t) 
                                 if(res==-9999) {res<- NA}
                                 {results[row,r+2] <- res}
                               }
                               row=row+1
                             }  
                             
                             prog=prog+1
                           }
                           prog=prog+1
                         }
                         
                         
                         write.csv(cbind(results,myDates),paste0(getwd(),"\\Results-",RUNID,".csv"),row.names=F) 
                         
                         Catchs=as.data.frame(resultsWBC)
                         colnames(Catchs)=c("Year",
                                            "Time step",
                                            "Catchment",
                                            "Observed Precipitation[M^3]",
                                            "Evapotranspiration[M^3]",
                                            "Surface Runoff[M^3]",
                                            "Interflow[M^3]",
                                            "Base Flow[M^3]",
                                            "Decrease in Soil Moisture[M^3]",
                                            "Increase in Soil Moisture[M^3]",
                                            "Decrease in Surface Storage[M^3]",
                                            "Increase in Surface Storage[M^3]",
                                            "Area Calculated[M^2]",
                                            "Relative Soil Moisture 1[%]",
                                            "Relative Soil Moisture 2[%]"
                         )
                         
                         Gauges=as.data.frame(resultsWBG)
                         colnames(resultsWBG)=c("Year",
                                                "Time step",
                                                "Gauge",
                                                "Observed [M^3]",
                                                "Modeled [M^3]"
                         )
                         
                         resultsWB=as.data.frame(matrix(0,ncol=17,nrow = rows*length(uniqueGauges)))
                         colnames(resultsWB)=c("Year",
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
                                               "Area",
                                               "Relative Soil Moisture 1",
                                               "Relative Soil Moisture 2"
                         )
                         
                         rowWB=1
                         for (g in 1:length(uniqueGauges)) {
                           Gaugessub=Gauges[Gauges$Gauge==uniqueGauges[g],]
                           Gaugessub$`Observed`=gsub(-9999,NA,Gaugessub$`Observed`,fixed = TRUE)
                           resultsWB[rowWB:(rowWB+rows-1),1] <- as.numeric(Gaugessub$Year)
                           resultsWB[rowWB:(rowWB+rows-1),2] <- as.numeric(Gaugessub$`Time step`)
                           resultsWB[rowWB:(rowWB+rows-1),3] <- uniqueGauges[g]
                           resultsWB[rowWB:(rowWB+rows-1),4] <- as.numeric(Gaugessub$`Observed`)
                           resultsWB[rowWB:(rowWB+rows-1),5] <- as.numeric(Gaugessub$`Modeled`)
                           
                           NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
                           
                           for (c in 1:length(NamecatchG)) {
                             Catchssub=Catchs[Catchs$Catchment==NamecatchG[c],]
                             resultsWB[rowWB:(rowWB+rows-1),6]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),6])+as.numeric(Catchssub[,4])
                             resultsWB[rowWB:(rowWB+rows-1),7]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),7])+as.numeric(Catchssub[,5])
                             resultsWB[rowWB:(rowWB+rows-1),8]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),8])+as.numeric(Catchssub[,6])
                             resultsWB[rowWB:(rowWB+rows-1),9]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),9])+as.numeric(Catchssub[,7])
                             resultsWB[rowWB:(rowWB+rows-1),10]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),10])+as.numeric(Catchssub[,8])
                             resultsWB[rowWB:(rowWB+rows-1),11]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),11])+as.numeric(Catchssub[,9])
                             resultsWB[rowWB:(rowWB+rows-1),12]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),12])+as.numeric(Catchssub[,10])
                             resultsWB[rowWB:(rowWB+rows-1),13]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),13])+as.numeric(Catchssub[,11])
                             resultsWB[rowWB:(rowWB+rows-1),14]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),14])+as.numeric(Catchssub[,12])
                             resultsWB[rowWB:(rowWB+rows-1),15]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),15])+as.numeric(Catchssub[,13])
                             resultsWB[rowWB:(rowWB+rows-1),16]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),16])+as.numeric(Catchssub[,14])*as.numeric(Catchssub[,13])
                             resultsWB[rowWB:(rowWB+rows-1),17]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),17])+as.numeric(Catchssub[,15])*as.numeric(Catchssub[,13])
                           }
                           
                           rowWB=rowWB+rows
                         }
                         
                         resultsWB$`Relative Soil Moisture 1`=resultsWB$`Relative Soil Moisture 1`/resultsWB$Area
                         resultsWB$`Relative Soil Moisture 2`=resultsWB$`Relative Soil Moisture 2`/resultsWB$Area
                         resultsWB = cbind(resultsWB,myDates)
                         write.csv(resultsWB,paste0(getwd(),"\\ResultsWB-",RUNID,".csv"),row.names=F) 
                         prog=prog+1
                       }
                     }
                     if (is.null(keyinputs) && !is.null(KeyGaugeBranches) && !is.null(KeyExport)){
                       
                       prog=1
                       
                       RUNID=1
                       
                       WEAP[["ActiveScenario"]] <- Scen
                       WEAP$DeleteResults()
                       
                       
                       WEAP$Calculate() 
                       
                       results <- as.data.frame(matrix(NA,nrow=rows,ncol=length(names)+2))
                       colnames(results) <- c("Year","Time step",names)
                       
                       resultsWBG=as.data.frame(matrix(0,ncol=5,nrow = rows*length(uniqueGauges)))
                       colnames(resultsWBG)=c("Year",
                                              "Time step",
                                              "Gauge",
                                              "Observed",
                                              "Modeled"
                       )
                       
                       
                       resultsWBC=as.data.frame(matrix(0,ncol=15,nrow = rows*length(Catchment_gauges)))
                       colnames(resultsWBC)=c("Year",
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
                                              "Area",
                                              "Relative Soil Moisture 1",
                                              "Relative Soil Moisture 2"
                       )
                       row=1
                       rowWBG=1
                       rowWBC=1
                       
                       for(a in 1:length(years)) {
                         
                         y <- years[a] 
                         
                         for(t in 1:ts) {
                           
                           incProgress(1/(length(years)*as.numeric(ts)), detail = paste0("Progress of ",nrow(keyinputs)," runs: ",round(prog/(length(years)*as.numeric(ts))*100,3),"%") )
                           
                           for (g in 1:length(uniqueGauges)){
                             resultsWBG[rowWBG,1] <- as.numeric(y)
                             resultsWBG[rowWBG,2] <- as.numeric(t)
                             resultsWBG[rowWBG,3] <- uniqueGauges[g]
                            resultspathWB=as.character(KeyGaugeBranches[KeyGaugeBranches$`Gauge Name`==uniqueGauges[g],2:3])
                             for(r in 1:length(resultspathWB)){
                               res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                               if(res==-9999) {res<- NA}
                               {resultsWBG[rowWBG,r+3] <- res}
                             }
                             rowWBG=rowWBG+1
                           }
                           
                           for (c in 1:length(Catchment_gauges)){
                             resultsWBC[rowWBC,1] <- as.numeric(y)
                             resultsWBC[rowWBC,2] <- as.numeric(t)
                             resultsWBC[rowWBC,3] <- Catchment_gauges[c]
                             resultspathWB=as.character(WEAPKeyBranchesCatchment[WEAPKeyBranchesCatchment$Catchment==Catchment_gauges[c],2:ncol(WEAPKeyBranchesCatchment)])
                             for(r in 1:length(resultspathWB)){
                               res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                               if(res==-9999) {res<- NA}
                               {resultsWBC[rowWBC,r+3] <- res}
                             }
                             rowWBC=rowWBC+1
                           }
                           
                           if (length(names)>0){   
                             results[row,1] <- as.numeric(y)
                             results[row,2]  <- as.numeric(t)
                             for(r in 1:length(names)) {
                               res <- WEAP$ResultValue(resultspath[r],y,t) 
                               if(res==-9999) {res<- NA}
                               {results[row,r+2] <- res}
                             }
                             row=row+1
                           }  
                           
                           prog=prog+1
                         }
                         prog=prog+1
                       }
                       
                       
                       write.csv(cbind(results,myDates),paste0(getwd(),"\\Results-",RUNID,".csv"),row.names=F) 
                       
                        Catchs=as.data.frame(resultsWBC)
                       colnames(Catchs)=c("Year",
                                          "Time step",
                                          "Catchment",
                                          "Observed Precipitation[M^3]",
                                          "Evapotranspiration[M^3]",
                                          "Surface Runoff[M^3]",
                                          "Interflow[M^3]",
                                          "Base Flow[M^3]",
                                          "Decrease in Soil Moisture[M^3]",
                                          "Increase in Soil Moisture[M^3]",
                                          "Decrease in Surface Storage[M^3]",
                                          "Increase in Surface Storage[M^3]",
                                          "Area Calculated[M^2]",
                                          "Relative Soil Moisture 1[%]",
                                          "Relative Soil Moisture 2[%]"
                       )
                       
                       Gauges=as.data.frame(resultsWBG)
                       colnames(resultsWBG)=c("Year",
                                              "Time step",
                                              "Gauge",
                                              "Observed [M^3]",
                                              "Modeled [M^3]"
                       )
                       
                       resultsWB=as.data.frame(matrix(0,ncol=17,nrow = rows*length(uniqueGauges)))
                       colnames(resultsWB)=c("Year",
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
                                             "Area",
                                             "Relative Soil Moisture 1",
                                             "Relative Soil Moisture 2"
                       )
                       
                       rowWB=1
                       for (g in 1:length(uniqueGauges)) {
                         
                         Gaugessub=Gauges[Gauges$Gauge==uniqueGauges[g],]
                         Gaugessub$`Observed`=gsub(-9999,NA,Gaugessub$`Observed`,fixed = TRUE)
                         resultsWB[rowWB:(rowWB+rows-1),1] <- as.numeric(Gaugessub$Year)
                         resultsWB[rowWB:(rowWB+rows-1),2] <- as.numeric(Gaugessub$`Time step`)
                         resultsWB[rowWB:(rowWB+rows-1),3] <- uniqueGauges[g]
                         resultsWB[rowWB:(rowWB+rows-1),4] <- as.numeric(Gaugessub$`Observed`)
                         resultsWB[rowWB:(rowWB+rows-1),5] <- as.numeric(Gaugessub$`Modeled`)
                         
                         NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
                         
                         for (c in 1:length(NamecatchG)) {
                           Catchssub=Catchs[Catchs$Catchment==NamecatchG[c],]
                           resultsWB[rowWB:(rowWB+rows-1),6]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),6])+as.numeric(Catchssub[,4])
                           resultsWB[rowWB:(rowWB+rows-1),7]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),7])+as.numeric(Catchssub[,5])
                           resultsWB[rowWB:(rowWB+rows-1),8]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),8])+as.numeric(Catchssub[,6])
                           resultsWB[rowWB:(rowWB+rows-1),9]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),9])+as.numeric(Catchssub[,7])
                           resultsWB[rowWB:(rowWB+rows-1),10]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),10])+as.numeric(Catchssub[,8])
                           resultsWB[rowWB:(rowWB+rows-1),11]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),11])+as.numeric(Catchssub[,9])
                           resultsWB[rowWB:(rowWB+rows-1),12]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),12])+as.numeric(Catchssub[,10])
                           resultsWB[rowWB:(rowWB+rows-1),13]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),13])+as.numeric(Catchssub[,11])
                           resultsWB[rowWB:(rowWB+rows-1),14]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),14])+as.numeric(Catchssub[,12])
                           resultsWB[rowWB:(rowWB+rows-1),15]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),15])+as.numeric(Catchssub[,13])
                           resultsWB[rowWB:(rowWB+rows-1),16]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),16])+as.numeric(Catchssub[,14])*as.numeric(Catchssub[,13])
                           resultsWB[rowWB:(rowWB+rows-1),17]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),17])+as.numeric(Catchssub[,15])*as.numeric(Catchssub[,13])
                         }
                         
                         rowWB=rowWB+rows
                       }
                       
                       resultsWB$`Relative Soil Moisture 1`=resultsWB$`Relative Soil Moisture 1`/resultsWB$Area
                       resultsWB$`Relative Soil Moisture 2`=resultsWB$`Relative Soil Moisture 2`/resultsWB$Area
                       resultsWB = cbind(resultsWB,myDates)
                       write.csv(resultsWB,paste0(getwd(),"\\ResultsWB-",RUNID,".csv"),row.names=F)
                       
                       
                       prog=prog+1
                       
                       
                     }
                     if (is.null(keyinputs) && is.null(KeyGaugeBranches) && !is.null(KeyExport)){
                       
                       prog=1
                       
                       RUNID=1
                       
                       WEAP[["ActiveScenario"]] <- Scen
                       WEAP$DeleteResults()
                       
                       
                       WEAP$Calculate() 
                       
                       results <- as.data.frame(matrix(NA,nrow=rows,ncol=length(names)+2)) 
                       colnames(results) <- c("Year","Time step",names)
                       
                       
                       row=1
                       
                       for(a in 1:length(years)) {
                         
                         y <- years[a] 
                         
                         for(t in 1:ts) {
                           incProgress(1/(length(years)*as.numeric(ts)), detail = paste0("Progress of ",nrow(keyinputs)," runs: ",round(prog/(length(years)*as.numeric(ts))*100,3),"%") )
                           
                           
                           if (length(names)>0){   
                             results[row,1] <- as.numeric(y)
                             results[row,2]  <- as.numeric(t)
                             for(r in 1:length(names)) {
                               res <- WEAP$ResultValue(resultspath[r],y,t) 
                               if(res==-9999) {res<- NA}
                               {results[row,r+2] <- res}
                             }
                             row=row+1
                           }  
                           
                           prog=prog+1
                         }
                         prog=prog+1
                       }
                       
                       
                       write.csv(cbind(results,myDates),paste0(getwd(),"\\Results-",RUNID,".csv"),row.names=F) 
                       
                       
                       prog=prog+1
                       
                       
                     }
                     if (!is.null(keyinputs) && !is.null(KeyGaugeBranches) && is.null(KeyExport)){
                       prog=1
                       for(i in 1:nrow(keyinputs)) {
                         
                         RUNID=keyinputs[i,1]
                         
                         WEAP[["ActiveScenario"]] <- Scen
                         WEAP$DeleteResults()
                         
                         for(k in 1:length(keys)) {
                           res <- try(
                             WEAP$BranchVariable(keys[k])[["Expression"]] <- keyinputs[i,k+1] 
                           )
                         }
                         
                         WEAP$Calculate() 
                         
                         
                         resultsWBG=as.data.frame(matrix(0,ncol=5,nrow = rows*length(uniqueGauges)))
                         colnames(resultsWBG)=c("Year",
                                                "Time step",
                                                "Gauge",
                                                "Observed",
                                                "Modeled"
                         )
                         
                         
                         resultsWBC=as.data.frame(matrix(0,ncol=15,nrow = rows*length(Catchment_gauges)))
                         colnames(resultsWBC)=c("Year",
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
                                                "Area",
                                                "Relative Soil Moisture 1",
                                                "Relative Soil Moisture 2"
                         )
                         row=1
                         rowWBG=1
                         rowWBC=1
                         
                         for(a in 1:length(years)) {
                           
                           y <- years[a] 
                           
                           for(t in 1:ts) {
                             
                             incProgress(1/(nrow(keyinputs)*length(years)*as.numeric(ts)), detail = paste0("Progress of ",nrow(keyinputs)," runs: ",round(prog/(nrow(keyinputs)*length(years)*as.numeric(ts))*100,3),"%") )
                             
                             for (g in 1:length(uniqueGauges)){
                               resultsWBG[rowWBG,1] <- as.numeric(y)
                               resultsWBG[rowWBG,2] <- as.numeric(t)
                               resultsWBG[rowWBG,3] <- uniqueGauges[g]
                               resultspathWB=as.character(KeyGaugeBranches[KeyGaugeBranches$`Gauge Name`==uniqueGauges[g],2:3])
                               for(r in 1:length(resultspathWB)){
                                 res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                                 if(res==-9999) {res<- NA}
                                 {resultsWBG[rowWBG,r+3] <- res}
                               }
                               rowWBG=rowWBG+1
                             }
                             
                             for (c in 1:length(Catchment_gauges)){
                               resultsWBC[rowWBC,1] <- as.numeric(y)
                               resultsWBC[rowWBC,2] <- as.numeric(t)
                               resultsWBC[rowWBC,3] <- Catchment_gauges[c]
                             
                               resultspathWB=as.character(WEAPKeyBranchesCatchment[WEAPKeyBranchesCatchment$Catchment==Catchment_gauges[c],2:ncol(WEAPKeyBranchesCatchment)])
                               for(r in 1:length(resultspathWB)){
                                 res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                                 if(res==-9999) {res<- NA}
                                 {resultsWBC[rowWBC,r+3] <- res}
                               }
                               rowWBC=rowWBC+1
                             }
                             
                             
                             prog=prog+1
                           }
                           prog=prog+1
                         }
                         
                            Catchs=as.data.frame(resultsWBC)
                         colnames(Catchs)=c("Year",
                                            "Time step",
                                            "Catchment",
                                            "Observed Precipitation[M^3]",
                                            "Evapotranspiration[M^3]",
                                            "Surface Runoff[M^3]",
                                            "Interflow[M^3]",
                                            "Base Flow[M^3]",
                                            "Decrease in Soil Moisture[M^3]",
                                            "Increase in Soil Moisture[M^3]",
                                            "Decrease in Surface Storage[M^3]",
                                            "Increase in Surface Storage[M^3]",
                                            "Area Calculated[M^2]",
                                            "Relative Soil Moisture 1[%]",
                                            "Relative Soil Moisture 2[%]"
                         )
                         
                         Gauges=as.data.frame(resultsWBG)
                         colnames(resultsWBG)=c("Year",
                                                "Time step",
                                                "Gauge",
                                                "Observed [M^3]",
                                                "Modeled [M^3]"
                         )
                         
                         resultsWB=as.data.frame(matrix(0,ncol=17,nrow = rows*length(uniqueGauges)))
                         colnames(resultsWB)=c("Year",
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
                                               "Area",
                                               "Relative Soil Moisture 1",
                                               "Relative Soil Moisture 2"
                         )
                         
                         rowWB=1
                         for (g in 1:length(uniqueGauges)) {
                          Gaugessub=Gauges[Gauges$Gauge==uniqueGauges[g],]
                           Gaugessub$`Observed`=gsub(-9999,NA,Gaugessub$`Observed`,fixed = TRUE)
                           resultsWB[rowWB:(rowWB+rows-1),1] <- as.numeric(Gaugessub$Year)
                           resultsWB[rowWB:(rowWB+rows-1),2] <- as.numeric(Gaugessub$`Time step`)
                           resultsWB[rowWB:(rowWB+rows-1),3] <- uniqueGauges[g]
                           resultsWB[rowWB:(rowWB+rows-1),4] <- as.numeric(Gaugessub$`Observed`)
                           resultsWB[rowWB:(rowWB+rows-1),5] <- as.numeric(Gaugessub$`Modeled`)
                           
                           NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
                           
                           for (c in 1:length(NamecatchG)) {
                             Catchssub=Catchs[Catchs$Catchment==NamecatchG[c],]
                             resultsWB[rowWB:(rowWB+rows-1),6]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),6])+as.numeric(Catchssub[,4])
                             resultsWB[rowWB:(rowWB+rows-1),7]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),7])+as.numeric(Catchssub[,5])
                             resultsWB[rowWB:(rowWB+rows-1),8]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),8])+as.numeric(Catchssub[,6])
                             resultsWB[rowWB:(rowWB+rows-1),9]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),9])+as.numeric(Catchssub[,7])
                             resultsWB[rowWB:(rowWB+rows-1),10]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),10])+as.numeric(Catchssub[,8])
                             resultsWB[rowWB:(rowWB+rows-1),11]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),11])+as.numeric(Catchssub[,9])
                             resultsWB[rowWB:(rowWB+rows-1),12]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),12])+as.numeric(Catchssub[,10])
                             resultsWB[rowWB:(rowWB+rows-1),13]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),13])+as.numeric(Catchssub[,11])
                             resultsWB[rowWB:(rowWB+rows-1),14]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),14])+as.numeric(Catchssub[,12])
                             resultsWB[rowWB:(rowWB+rows-1),15]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),15])+as.numeric(Catchssub[,13])
                             resultsWB[rowWB:(rowWB+rows-1),16]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),16])+as.numeric(Catchssub[,14])*as.numeric(Catchssub[,13])
                             resultsWB[rowWB:(rowWB+rows-1),17]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),17])+as.numeric(Catchssub[,15])*as.numeric(Catchssub[,13])
                           }
                           
                           rowWB=rowWB+rows
                         }
                         
                         resultsWB$`Relative Soil Moisture 1`=resultsWB$`Relative Soil Moisture 1`/resultsWB$Area
                         resultsWB$`Relative Soil Moisture 2`=resultsWB$`Relative Soil Moisture 2`/resultsWB$Area
                         resultsWB = cbind(resultsWB,myDates)
                         write.csv(resultsWB,paste0(getwd(),"\\ResultsWB-",RUNID,".csv"),row.names=F) 
                         prog=prog+1
                       }
                     }
                     if (!is.null(keyinputs) && is.null(KeyGaugeBranches) && !is.null(KeyExport)){
                       prog=1
                       for(i in 1:nrow(keyinputs)) {
                         
                         RUNID=keyinputs[i,1]
                         
                         WEAP[["ActiveScenario"]] <- Scen
                         WEAP$DeleteResults()
                         
                         for(k in 1:length(keys)) {
                           res <- try(
                             WEAP$BranchVariable(keys[k])[["Expression"]] <- keyinputs[i,k+1] 
                           )
                         }
                         
                         WEAP$Calculate()
                         
                         results <- as.data.frame(matrix(NA,nrow=rows,ncol=length(names)+2)) 
                         colnames(results) <- c("Year","Time step",names)
                         
                         
                         row=1
                         
                         
                         for(a in 1:length(years)) {
                           
                           y <- years[a] 
                           
                           for(t in 1:ts) {
                             
                             incProgress(1/(nrow(keyinputs)*length(years)*as.numeric(ts)), detail = paste0("Progress of ",nrow(keyinputs)," runs: ",round(prog/(nrow(keyinputs)*length(years)*as.numeric(ts))*100,3),"%") )
                             
                             if (length(names)>0){   
                               results[row,1] <- as.numeric(y)
                               results[row,2]  <- as.numeric(t)
                               for(r in 1:length(names)) {
                                 res <- WEAP$ResultValue(resultspath[r],y,t)
                                 if(res==-9999) {res<- NA}
                                 {results[row,r+2] <- res}
                               }
                               row=row+1
                             }  
                             
                             prog=prog+1
                           }
                           prog=prog+1
                         }
                         
                         
                         write.csv(cbind(results,myDates),paste0(getwd(),"\\Results-",RUNID,".csv"),row.names=F) 
                         
                         prog=prog+1
                       }
                     }
                     if (is.null(keyinputs) && !is.null(KeyGaugeBranches) && is.null(KeyExport)){
                       
                       prog=1
                       
                       RUNID=1
                       
                       WEAP[["ActiveScenario"]] <- Scen
                       WEAP$DeleteResults()
                       
                       
                       WEAP$Calculate() 
                       
                       
                       resultsWBG=as.data.frame(matrix(0,ncol=5,nrow = rows*length(uniqueGauges)))
                       colnames(resultsWBG)=c("Year",
                                              "Time step",
                                              "Gauge",
                                              "Observed",
                                              "Modeled"
                       )
                       
                       
                       resultsWBC=as.data.frame(matrix(0,ncol=15,nrow = rows*length(Catchment_gauges)))
                       colnames(resultsWBC)=c("Year",
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
                                              "Area",
                                              "Relative Soil Moisture 1",
                                              "Relative Soil Moisture 2"
                       )
                       row=1
                       rowWBG=1
                       rowWBC=1
                       
                       for(a in 1:length(years)) {
                         
                         y <- years[a] 
                         
                         for(t in 1:ts) {
                           
                           incProgress(1/(length(years)*as.numeric(ts)), detail = paste0("Progress of ",nrow(keyinputs)," runs: ",round(prog/(length(years)*as.numeric(ts))*100,3),"%") )
                           
                           for (g in 1:length(uniqueGauges)){
                             resultsWBG[rowWBG,1] <- as.numeric(y)
                             resultsWBG[rowWBG,2] <- as.numeric(t)
                             resultsWBG[rowWBG,3] <- uniqueGauges[g]
                              resultspathWB=as.character(KeyGaugeBranches[KeyGaugeBranches$`Gauge Name`==uniqueGauges[g],2:3])
                             for(r in 1:length(resultspathWB)){
                               res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                               if(res==-9999) {res<- NA}
                               {resultsWBG[rowWBG,r+3] <- res}
                             }
                             rowWBG=rowWBG+1
                           }
                           
                           for (c in 1:length(Catchment_gauges)){
                             resultsWBC[rowWBC,1] <- as.numeric(y)
                             resultsWBC[rowWBC,2] <- as.numeric(t)
                             resultsWBC[rowWBC,3] <- Catchment_gauges[c]
                            
                             resultspathWB=as.character(WEAPKeyBranchesCatchment[WEAPKeyBranchesCatchment$Catchment==Catchment_gauges[c],2:ncol(WEAPKeyBranchesCatchment)])
                             for(r in 1:length(resultspathWB)){
                               res <- WEAP$ResultValue(resultspathWB[r],y,t) 
                               if(res==-9999) {res<- NA}
                               {resultsWBC[rowWBC,r+3] <- res}
                             }
                             rowWBC=rowWBC+1
                           }
                           
                           
                           
                           prog=prog+1
                         }
                         prog=prog+1
                       }
                       
                        Catchs=as.data.frame(resultsWBC)
                       colnames(Catchs)=c("Year",
                                          "Time step",
                                          "Catchment",
                                          "Observed Precipitation[M^3]",
                                          "Evapotranspiration[M^3]",
                                          "Surface Runoff[M^3]",
                                          "Interflow[M^3]",
                                          "Base Flow[M^3]",
                                          "Decrease in Soil Moisture[M^3]",
                                          "Increase in Soil Moisture[M^3]",
                                          "Decrease in Surface Storage[M^3]",
                                          "Increase in Surface Storage[M^3]",
                                          "Area Calculated[M^2]",
                                          "Relative Soil Moisture 1[%]",
                                          "Relative Soil Moisture 2[%]"
                       )
                       
                       Gauges=as.data.frame(resultsWBG)
                       colnames(resultsWBG)=c("Year",
                                              "Time step",
                                              "Gauge",
                                              "Observed [M^3]",
                                              "Modeled [M^3]"
                       )
                       
                       resultsWB=as.data.frame(matrix(0,ncol=17,nrow = rows*length(uniqueGauges)))
                       colnames(resultsWB)=c("Year",
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
                                             "Area",
                                             "Relative Soil Moisture 1",
                                             "Relative Soil Moisture 2"
                       )
                       
                       rowWB=1
                       for (g in 1:length(uniqueGauges)) {
                        
                         Gaugessub=Gauges[Gauges$Gauge==uniqueGauges[g],]
                         Gaugessub$`Observed`=gsub(-9999,NA,Gaugessub$`Observed`,fixed = TRUE)
                         resultsWB[rowWB:(rowWB+rows-1),1] <- as.numeric(Gaugessub$Year)
                         resultsWB[rowWB:(rowWB+rows-1),2] <- as.numeric(Gaugessub$`Time step`)
                         resultsWB[rowWB:(rowWB+rows-1),3] <- uniqueGauges[g]
                         resultsWB[rowWB:(rowWB+rows-1),4] <- as.numeric(Gaugessub$`Observed`)
                         resultsWB[rowWB:(rowWB+rows-1),5] <- as.numeric(Gaugessub$`Modeled`)
                         
                         NamecatchG=KeyGaugesCatchments[KeyGaugesCatchments$Gauge==uniqueGauges[g],2]
                         
                         for (c in 1:length(NamecatchG)) {
                           Catchssub=Catchs[Catchs$Catchment==NamecatchG[c],]
                           resultsWB[rowWB:(rowWB+rows-1),6]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),6])+as.numeric(Catchssub[,4])
                           resultsWB[rowWB:(rowWB+rows-1),7]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),7])+as.numeric(Catchssub[,5])
                           resultsWB[rowWB:(rowWB+rows-1),8]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),8])+as.numeric(Catchssub[,6])
                           resultsWB[rowWB:(rowWB+rows-1),9]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),9])+as.numeric(Catchssub[,7])
                           resultsWB[rowWB:(rowWB+rows-1),10]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),10])+as.numeric(Catchssub[,8])
                           resultsWB[rowWB:(rowWB+rows-1),11]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),11])+as.numeric(Catchssub[,9])
                           resultsWB[rowWB:(rowWB+rows-1),12]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),12])+as.numeric(Catchssub[,10])
                           resultsWB[rowWB:(rowWB+rows-1),13]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),13])+as.numeric(Catchssub[,11])
                           resultsWB[rowWB:(rowWB+rows-1),14]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),14])+as.numeric(Catchssub[,12])
                           resultsWB[rowWB:(rowWB+rows-1),15]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),15])+as.numeric(Catchssub[,13])
                           resultsWB[rowWB:(rowWB+rows-1),16]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),16])+as.numeric(Catchssub[,14])*as.numeric(Catchssub[,13])
                           resultsWB[rowWB:(rowWB+rows-1),17]=as.numeric(resultsWB[rowWB:(rowWB+rows-1),17])+as.numeric(Catchssub[,15])*as.numeric(Catchssub[,13])
                         }
                         
                         rowWB=rowWB+rows
                       }
                       
                       resultsWB$`Relative Soil Moisture 1`=resultsWB$`Relative Soil Moisture 1`/resultsWB$Area
                       resultsWB$`Relative Soil Moisture 2`=resultsWB$`Relative Soil Moisture 2`/resultsWB$Area
                       resultsWB = cbind(resultsWB,myDates)
                       write.csv(resultsWB,paste0(getwd(),"\\ResultsWB-",RUNID,".csv"),row.names=F)
                        prog=prog+1
                       
                       
                     }
                     
                     WEAP$SaveArea()
                     rm(WEAP)
                     gc()
                   })
      
      output$textRunEnsemble <- renderText({ format(as.difftime(difftime(Sys.time(),start), format = "%H:%M"))})
      
    })
    
     output$Streamflow <- renderUI({
      if (length(list.files(getwd(),pattern ="ResultsWB-")>0)){
         listResults=list.files(getwd(),pattern ="ResultsWB-")
        listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
        listResults=gsub(".csv","",listResults,fixed = TRUE)
        listResults=unique(as.numeric(listResults))
        file <- read.csv(paste0(getwd(),"//ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
        gauges=c(unique(file$Gauge))
        selectInput("StreamflowSelect", "Streamflow Gauge",gauges)
      } else {
        gauges="Run -2. Calibration Ensemble- section first"
        selectInput("StreamflowSelect", "Streamflow Gauge",gauges)
      }
    })
    
    output$daterange <- renderUI({
      if (length(list.files(getwd(),pattern ="ResultsWB-")>0)){
        listResults=list.files(getwd(),pattern ="ResultsWB-")
        listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
        listResults=gsub(".csv","",listResults,fixed = TRUE)
        listResults=unique(as.numeric(listResults))
        file <- read.csv(paste0(getwd(),"//ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
        file$Dates=ymd(file$Dates)
        starty <- min(file$Dates)
        endy <- max(file$Dates)
        dateRangeInput("dates",label="Select date range for which to calculate performance metrics)",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
      } else {
        dateRangeInput("dates",label="Select date range for which to calculate performance metrics)",start=ymd("1900-01-01"),end=ymd("1900-01-01"),min=ymd("1900-01-01"),max=ymd("1900-01-01"),separator = " - ", format = "dd/mm/yyyy")
      }
    })
    
    daterange <- reactive({
      input$dates
    })
    
    output$sliders <- renderUI({ 
      if (file.exists(paste0(getwd(),"\\KeyModelInputs.csv"))){
        
        KeyEnsemble <- read.csv(paste0(getwd(),"\\KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
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
                        label = "Run -2. Calibration Ensemble- section first",
                        animate=TRUE,
                        grid = TRUE,
                        choices="NA",
                        selected ="NA")
      }
    })
    
    runID <- reactive({
      runID="No parameter combination is available"
      if (file.exists(paste0(getwd(),"\\KeyModelInputs.csv"))){
        keysset <- read.csv(paste0(getwd(),"\\KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
        keys=keysset
        num <- ncol(keys)-1
        
        values <- sapply(1:num, function(i)
        {(input[[paste0("key",i)]])[1]})
        values=as.numeric(values)
        
        if (is.numeric(keysset[row.match(values,keysset[2:ncol(keysset)]),1])){
          runID <-keysset[row.match(values,keysset[2:ncol(keysset)]),1]
        }
      }
      runID=as.character(runID)
      runID
    })
    
    output$runID <- renderText({
      paste("Selected combination corresponds to the run: ", runID())
    })
    
    file <- reactive({
       file <- read.csv(paste0(getwd(),"//ResultsWB-",runID(),".csv"), stringsAsFactors=F, check.names=F)
      file$Dates=ymd(file$Dates)
       file=file[file$Gauge==input$StreamflowSelect,]
      file$YearMonth=year(file$Dates)*100+month(file$Dates)
      file$Month=month(file$Dates)
      file <- file[which(file$Dates >= input$dates[1] & file$Dates <= input$dates[2]),]
      file
      
    })
    
    output$metrics <- renderDataTable({
      file <- file()
      filesub=file
      
      runID=runID()
      keysset <- read.csv(paste0(getwd(),"//KeyModelInputs.csv"),stringsAsFactors =F,check.names=F)
      runs <- nrow(keysset)
      
      errorEvaluar=c(2, 5, 6, 9, 12, 17, 19, 20)
      names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                    "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                    "KGE" ,    "VE" ) 
      
      metricsALL <- as.data.frame(matrix(NA,nrow=1,ncol=(9+ncol(keysset)+length(errorEvaluar))))
      colnames(metricsALL) <- c("Gauge","Run ID",colnames(keysset),names_error[errorEvaluar],"PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Period %","Type")
   
      uniqueGauges=unique(file$Gauge)
      
      metrics=as.data.frame(matrix(nrow=length(uniqueGauges),ncol=(8+ncol(keysset)+length(errorEvaluar))))
      colnames(metrics) <- c("Gauge","Run ID",colnames(keysset),names_error[errorEvaluar],"PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Period %")
      
      metrics[,1]=uniqueGauges
      metrics[,2]=runID
      
      for (j in 3:(4+length(3:ncol(keysset)))){
        metrics[,j]=as.numeric(keysset[which(keysset$Nrun==runID),j-2])
      }
      metrics1=metrics
      metrics2=metrics
      
      for (g in 1:length(uniqueGauges)){
        
        filesub=file[file$Gauge==uniqueGauges[g],]
        
        Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
        Filemonthly$N=1
        Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
        Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
        Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
        Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
        Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
        Filemonthly$Period=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",nrow(filesub),")")
        metrics[g,23:27]=Filemonthly[1,7:11]
        
        total=nrow(filesub)
        filesub1=filesub[1:round(total*0.7,0),]
        filesub2=filesub[(round(total*0.7,0)+1):nrow(filesub),]
        r1=length(1:round(total*0.7,0))
        r2=length((round(total*0.7,0)+1):nrow(filesub))
        DatesRegister1=paste0(as.character(as.Date(filesub1$Dates[1]))," - ",as.character(as.Date(filesub1$Dates[nrow(filesub1)]))," N(",r1,")")
        DatesRegister2=paste0(as.character(as.Date(filesub2$Dates[1]))," - ",as.character(as.Date(filesub2$Dates[nrow(filesub2)]))," N(",r2,")")
        filesub=filesub1
        Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
        Filemonthly$N=1
        Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
        Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
        Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
        Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
        Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
        Filemonthly$Period=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",nrow(filesub),")")
        metrics1[g,23:27]=Filemonthly[1,7:11]
        filesub=filesub2
        Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
        Filemonthly$N=1
        Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
        Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
        Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
        Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
        Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
        Filemonthly$Period=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",nrow(filesub),")")
        metrics2[g,23:27]=Filemonthly[1,7:11]
        
        filesub=na.exclude(file[file$Gauge==uniqueGauges[g],])
        r=nrow(filesub)
        DatesRegister=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",r,")")
        modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
        observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
        if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
          error=gof(modeled,observed,digits=5,na.rm=TRUE)
          metrics[g,(3+ncol(keysset)):(ncol(metrics)-6)]=round(error[errorEvaluar],3)
        } else {metrics[g,(3+ncol(keysset)):(ncol(metrics)-6)]=NA}
        metrics$PeriodGOF[g]=DatesRegister
        
        total=nrow(filesub)
        filesub1=filesub[1:round(total*0.7,0),]
        filesub2=filesub[(round(total*0.7,0)+1):nrow(filesub),]
        r1=length(1:round(total*0.7,0))
        r2=length((round(total*0.7,0)+1):nrow(filesub))
        DatesRegister1=paste0(as.character(as.Date(filesub1$Dates[1]))," - ",as.character(as.Date(filesub1$Dates[nrow(filesub1)]))," N(",r1,")")
        DatesRegister2=paste0(as.character(as.Date(filesub2$Dates[1]))," - ",as.character(as.Date(filesub2$Dates[nrow(filesub2)]))," N(",r2,")")
        
        filesub=filesub1
        modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
        observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
        if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
          error=gof(modeled,observed,digits=5,na.rm=TRUE)
          metrics1[g,(3+ncol(keysset)):(ncol(metrics)-6)]=round(error[errorEvaluar],2)
        } else {metrics1[g,(3+ncol(keysset)):(ncol(metrics)-6)]=NA}
        metrics1$PeriodGOF[g]=DatesRegister1
        
        filesub=filesub2
        modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
        observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
        if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
          error=gof(modeled,observed,digits=5,na.rm=TRUE)
          metrics2[g,(3+ncol(keysset)):(ncol(metrics)-6)]=round(error[errorEvaluar],2)
        } else {metrics2[g,(3+ncol(keysset)):(ncol(metrics)-6)]=NA}
        metrics2$PeriodGOF[g]=DatesRegister2
      }
      metrics$Type="All"
      metrics1$Type="Calibration (70%)"
      metrics2$Type="Validation (30%)"
      metricsALL=rbind(metricsALL,metrics,metrics1,metrics2)
      
      metricsALL=metricsALL[-1,]
      metricsALL=metricsALL[,-2]

      
      metrics=metricsALL[,c(1,(ncol(keysset)+2):ncol(metricsALL))]
      metrics
      
    })
    output$Q <- renderPlotly({
      
      file <- file()
      filesub=file
        filesub=file
      p <-plot_ly(filesub, x=~Dates, y=~Observed, name = "Observed", type="scatter", mode="lines",
                  line = list(color="black",width=1.5)) %>%
        add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
        layout(title = paste0("Streamflow ",input$StreamflowSelect),
               xaxis = list(title=""),
               yaxis = list(title= "Q (M^3)"))
      p
      
      
    })
    output$Qmonthly <- renderPlotly({
      
      file <- file()
      filesub=file
        Qmonthly <- aggregate(filesub[,c("Observed","Modeled")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      
      Qmonthly$Month=Qmonthly$YearMonth%%100
      
      Qmonthly <- aggregate(Qmonthly[,c("Observed","Modeled")], by=list(Month=Qmonthly$Month),mean,na.rm=T)
      
      pmonthly <- plot_ly(Qmonthly, x=~Month, y=~Observed, name = "Observed", showlegend=FALSE,type="scatter", mode="lines",
                          line = list(color="black",width=1.5)) %>%
        add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
        layout(title = paste0("Monthly Average ",input$StreamflowSelect),
               xaxis = list(title=""),
               yaxis = list(title= "Q (M^3)"))
      pmonthly
      
    })
    output$fdc <- renderPlotly({
      
      file <- file()
      filesub=file
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
        layout(title =paste0("Flow Duration Curve ",input$StreamflowSelect),yaxis = list(title="Q (M^3)"),xaxis=list(title="Probability (%)"))
      fdc  
    })
    output$WB <- renderPlotly({
      
      file <- file()
      filesub=file
        filesub[,6:14]=round(filesub[,6:14]/filesub[,15]*1000,2)
      
      filesub$Interflow2 <- filesub$Interflow+filesub$Base_Flow
      filesub$SurfaceRunoff2 <- filesub$Surface_Runof + filesub$Interflow2
      filesub$Evapotranspiration2 <- filesub$Evapotranspiration + filesub$SurfaceRunoff2
      
      pWB <- plot_ly(filesub, x=~Dates, y=~Precipitation, name="Precipitation", type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=0.5), text=~paste("Precip = ", Precipitation)) %>%
        add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
        add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
        add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
        add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
        layout(title = paste0("Water Balance ",input$StreamflowSelect),yaxis = list(title="mm"),  xaxis =list(title="Date"))
      
      pWB
    })
    output$WBSM <- renderPlotly({
      
      file <- file()
      filesub=file
      filesub[,6:14]=round(filesub[,6:14]/filesub[,15]*1000,2)
      filesub[,11]=-1*filesub[,11]
      filesub$SM=filesub[,11]+filesub[,12]
      
      p4 <-plot_ly(filesub, x=~Dates, y=filesub[,11], name="Decrease in Soil Moisture", type="scatter", mode="lines",
                   line = list(color="#CF6D0C",width=1.5),text=~paste("Decrease Soil Moisture = ", filesub$`Decrease in Soil Moisture`)) %>%
        add_trace(y=~filesub[,12], name="Increase in Soil Moisture", line=list(color="#167FE8",width=1.5),text=~paste("Increase Soil Moisture = ", filesub$`Increase in Soil Moisture`)) %>%
        layout(title = paste0("Water Balance (Soil Moisture) ",input$StreamflowSelect),
               xaxis = list(title="Date"),
               yaxis = list(title= "mm"))
      p4
    })
    output$WBSE <- renderPlotly({
      
      file <- file()
      filesub=file
       filesub[,6:14]=round(filesub[,6:14]/filesub[,15]*1000,2)
      filesub[,13]=-1*filesub[,13]
      filesub$SE=filesub[,13]+filesub[,14]
      
      p5 <-plot_ly(filesub, x=~Dates, y=filesub[,13], name="Decrease in Surface Storage", type="scatter", mode="lines",
                   line = list(color="#CF6D0C",width=1.5),text=~paste("Decrease Surface Storage = ", filesub$`Decrease in Surface Storage`)) %>%
        add_trace(y=~filesub[,14], name="Increase in Surface Storage", line=list(color="#167FE8",width=1.5),text=~paste("Increase Surface Storage = ", filesub$`Increase in Surface Storage`)) %>%
        layout(title = paste0("Water Balance (Surface Storage) ",input$StreamflowSelect),
               xaxis = list(title="Date"),
               yaxis = list(title= "mm"))
      p5
    })
    output$WBmonthly <- renderPlotly({
      
      file <- file()
      filesub=file
        filesub[,4:14]=round(filesub[,4:14]/filesub[,15]*1000,2)
      
      filesub$Interflow2 <- filesub$Interflow+filesub$Base_Flow
      filesub$SurfaceRunoff2 <- filesub$Surface_Runof + filesub$Interflow2
      filesub$Evapotranspiration2 <- filesub$Evapotranspiration + filesub$SurfaceRunoff2
      
      if (ncol(filesub)==23){
        wbmonthly <- aggregate(filesub[,c(6:14,19:23)], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      }
      if (ncol(filesub)==21){
        wbmonthly <- aggregate(filesub[,c(6:14,19:21)], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      }
      
      wbmonthly$Month=wbmonthly$YearMonth%%100
      
      if (ncol(wbmonthly)==15){
        wbmonthly <- aggregate(wbmonthly[,c(2:15)], by=list(Month=wbmonthly$Month),mean,na.rm=T)
      }
      if (ncol(wbmonthly)==14){
        wbmonthly <- aggregate(wbmonthly[,c(2:14)], by=list(Month=wbmonthly$Month),mean,na.rm=T)
      }
      
      p2monthly <- plot_ly(wbmonthly, x=~Month, y=~Precipitation, name="Precipitation", showlegend=TRUE, type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=1.5), text=~paste("Precip = ", Precipitation)) %>%
        add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
        add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
        add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
        add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
        layout(title =paste0("Water Balance Monthly Average ",input$StreamflowSelect),yaxis = list(title="mm"),xaxis=list(title="Months"))
      
      p2monthly
      
    })
    output$WBmonthlyB <- renderPlotly({
      
      file <- file()
      filesub=file
      Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      Filemonthly$Month=Filemonthly$YearMonth%%100
      Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(Month=Filemonthly$Month),mean,na.rm=T)
      Filemonthly$`TotalRunoff/Precipitation%`=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
      Filemonthly$`BaseFlow/TotalRunoff%`=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
      Filemonthly$`SurfaceRunoff/TotalRunoff%`=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
      Filemonthly$`Evapotranspiration/Precipitation%`=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
      Filemonthly=Filemonthly[,-(2:6)]
      
      p2monthly <- plot_ly(Filemonthly, x=~Month, y=~`TotalRunoff/Precipitation%`, name="TotalRunoff/Precipitation%", showlegend=TRUE, type="scatter",mode="line",text=~paste("TotalRunoff/Precipitation% = ", `TotalRunoff/Precipitation%`)) %>%
        add_trace(y=~`BaseFlow/TotalRunoff%`, name="BaseFlow/TotalRunoff%", type="scatter",mode="line",text=~paste("BaseFlow/TotalRunoff% = ", `BaseFlow/TotalRunoff%`)) %>%
        add_trace(y=~`SurfaceRunoff/TotalRunoff%`, name="SurfaceRunoff/TotalRunoff%", type="scatter",mode="line",text=~paste("SurfaceRunoff/TotalRunoff% = ", `SurfaceRunoff/TotalRunoff%`)) %>%
        add_trace(y=~`Evapotranspiration/Precipitation%`, name="Evapotranspiration/Precipitation%", type="scatter",mode="line",text=~paste("Evapotranspiration/Precipitation% = ", `Evapotranspiration/Precipitation%`)) %>%
        layout(title =paste0("% ",input$StreamflowSelect),yaxis = list(title="%"),xaxis=list(title="Months"))
      
      p2monthly
      
    })
    output$WBtable <- renderDataTable({
      
      file <- file()
      filesub=file
       filesub[,4:14]=round(filesub[,4:14]/filesub[,15]*1000,2)
      
      wbmonthly <- aggregate(filesub[,c(4:14)], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      wbmonthly$Month=wbmonthly$YearMonth%%100
      wbmonthly <- aggregate(wbmonthly[,c(2:12)], by=list(Month=wbmonthly$Month),mean,na.rm=T)
      wbmonthly$`TotalRunoff/Precipitation%`=round(wbmonthly$Modeled/wbmonthly$Precipitation*100,1)
      wbmonthly$`BaseFlow/TotalRunoff%`=round(wbmonthly$Base_Flow/wbmonthly$Modeled*100,1)
      wbmonthly$`SurfaceRunoff/TotalRunoff%`=round(wbmonthly$Surface_Runoff/wbmonthly$Modeled*100,1)
      wbmonthly$`Evapotranspiration/Precipitation%`=round(wbmonthly$Evapotranspiration/wbmonthly$Precipitation*100,1)
      
      
      wbtable <- round(wbmonthly[,c("Month","Precipitation","Evapotranspiration","Surface_Runoff","Interflow","Base_Flow","Modeled", "TotalRunoff/Precipitation%","BaseFlow/TotalRunoff%", "SurfaceRunoff/TotalRunoff%","Evapotranspiration/Precipitation%")],3)
      colnames(wbtable) <- c("Month","Precipitation (mm)","Evapotranspiration (mm)","Surface_Runoff (mm)","Interflow (mm)","Base_Flow (mm)","Q Modeled (mm)", "TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %")
      wbtable
    })
    output$SM1 <- renderPlotly({
      
      file <- file()
      filesub=file
        pSM1 <-plot_ly(filesub, x=~Dates, y=~`Relative Soil Moisture 1`, name = "Relative Soil Moisture 1 %", type="scatter", mode="lines",
                     line = list(color="black",width=1.5)) %>%
        layout(title = paste0("Relative Soil Moisture 1 % ",input$StreamflowSelect),
               xaxis = list(title="Date"),
               yaxis = list(title= "Relative Soil Moisture 1 (%)"))
      pSM1
      
      
    })
    output$SM2 <- renderPlotly({
      
      file <- file()
      filesub=file
       pSM2 <-plot_ly(filesub, x=~Dates, y=~`Relative Soil Moisture 2`, name = "Relative Soil Moisture 2 %", type="scatter", mode="lines",
                     line = list(color="blue",width=1.5)) %>%
        layout(title = paste0("Relative Soil Moisture 2 % ",input$StreamflowSelect),
               xaxis = list(title="Date"),
               yaxis = list(title= "Relative Soil Moisture 2 (%)"))
      pSM2
      
      
    })
    
     output$inputRunIDt <- renderUI({
      if (file.exists(paste0(getwd(),"\\KeyModelInputs.csv"))){
         keys <- read.csv(paste0(getwd(),"\\KeyModelInputs.csv"),stringsAsFactors = F, check.names=F)
        numericInput("runIDt",label="Select Run ID:", min(as.numeric(keys[,1])), min=min(as.numeric(keys[,1])), max=max(as.numeric(keys[,1])))
      } else {
        numericInput("runIDt",label="Select Run ID:", NA, min=NA, max=NA)
      }
    })
    
    output$runIDValues <- renderText({
      if (file.exists(paste0(getwd(),"\\KeyModelInputs.csv"))){
        keysset <- read.csv(paste0(getwd(),"\\KeyModelInputs.csv"),stringsAsFactors =F,check.names=F)
        paste0("Runs are between ",min(keysset[,1]), " and ", max(keysset[,1])) 
      } else {
        paste0("Run -2. Calibration Ensemble- section first") 
      }
    })
    
    output$Streamflowt <- renderUI({
      if (length(list.files(getwd(),pattern ="ResultsWB-")>0)){
         listResults=list.files(getwd(),pattern ="ResultsWB-")
        listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
        listResults=gsub(".csv","",listResults,fixed = TRUE)
        listResults=unique(as.numeric(listResults))
        file <- read.csv(paste0(getwd(),"//ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
         gauges=c(unique(file$Gauge))
        selectInput("StreamflowSelectt", "Streamflow Gauge",gauges)
      } else {
        gauges="Run -2. Calibration Ensemble- section first"
        selectInput("StreamflowSelectt", "Streamflow Gauge",gauges)
      }
    })
    
    output$dateranget <- renderUI({
      if (length(list.files(getwd(),pattern ="ResultsWB-")>0)){
        listResults=list.files(getwd(),pattern ="ResultsWB-")
        listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
        listResults=gsub(".csv","",listResults,fixed = TRUE)
        listResults=unique(as.numeric(listResults))
        file <- read.csv(paste0(getwd(),"//ResultsWB-",min(listResults),".csv"), stringsAsFactors=F, check.names=F)
        file$Dates=ymd(file$Dates)
        starty <- min(file$Dates)
        endy <- max(file$Dates)
        dateRangeInput("datest",label="Select date range for which to calculate performance metrics)",start=starty,end=endy,min=starty,max=endy,separator = " - ", format = "dd/mm/yyyy")
      }else {
        dateRangeInput("datest",label="Select date range for which to calculate performance metrics)",start=ymd("1900-01-01"),end=ymd("1900-01-01"),min=ymd("1900-01-01"),max=ymd("1900-01-01"),separator = " - ", format = "dd/mm/yyyy")
      }
    })
    
    dateranget <- reactive({
      input$datest
    })
    
    output$textRunactmetrics <- renderText({("Press button to calculate")})
    
    observeEvent(input$actmetrics,{
      
      if (length(list.files(getwd(),pattern ="ResultsWB-")>0) && file.exists(paste0(getwd(),"//KeyModelInputs.csv"))){
        
        keysset <- read.csv(paste0(getwd(),"//KeyModelInputs.csv"),stringsAsFactors =F,check.names=F)
        runs <- nrow(keysset)
        listResults=list.files(getwd(),pattern ="ResultsWB-")
        listResults=gsub("ResultsWB-","",listResults,fixed = TRUE)
        listResults=gsub(".csv","",listResults,fixed = TRUE)
        listResults=unique(as.numeric(listResults))
        
        errorEvaluar=c(2, 5, 6, 9, 12, 17, 19, 20)
        names_error=c("ME"  ,    "MAE"  ,   "MSE" ,    "RMSE" ,   "NRMSE %" ,"PBIAS %", "RSR"   ,  "rSD"  ,   "NSE" ,   
                      "mNSE" ,   "rNSE"  ,  "d"  ,     "md"    ,  "rd"   ,   "cp"    ,  "r"  ,     "R2"    ,  "bR2",    
                      "KGE" ,    "VE" ) 
        
        metricsALL <- as.data.frame(matrix(NA,nrow=1,ncol=(9+ncol(keysset)+length(errorEvaluar))))
        colnames(metricsALL) <- c("Gauge","Run ID",colnames(keysset),names_error[errorEvaluar],"PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Period %","Type")
        
        iprogress=1 
        withProgress(message = 'Progress of GOF Calculations:', value = 0, 
                     {
                       for (i in listResults) {
                         
                         incProgress(1/runs, detail = paste0("Calculation of ",nrow(keysset),": ", round(iprogress/runs*100,0),"%"))
                         
                         RUNID=i
                         runID=i
                         file=read.csv(paste0(getwd(),"\\ResultsWB-",RUNID,".csv"), stringsAsFactors=F, check.names=F)
                         file$Dates=ymd(file$Dates)
                         file$YearMonth=year(file$Dates)*100+month(file$Dates)
                         file$Month=month(file$Dates)
                         filesub <- file[which(file$Dates >= input$datest[1] & file$Dates <= input$datest[2]),]
                         
                         uniqueGauges=unique(file$Gauge)
                         
                         metrics=as.data.frame(matrix(nrow=length(uniqueGauges),ncol=(8+ncol(keysset)+length(errorEvaluar))))
                         colnames(metrics) <- c("Gauge","Run ID",colnames(keysset),names_error[errorEvaluar],"PeriodGOF","TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %","Period %")
                         
                         metrics[,1]=uniqueGauges
                         metrics[,2]=runID
                         
                         for (j in 3:(4+length(3:ncol(keysset)))){
                           metrics[,j]=as.numeric(keysset[which(keysset$Nrun==runID),j-2])
                         }
                         metrics1=metrics
                         metrics2=metrics
                         
                         for (g in 1:length(uniqueGauges)){
                           
                           filesub=file[file$Gauge==uniqueGauges[g],]
                           
                           Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
                           Filemonthly$N=1
                           Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
                           Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
                           Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
                           Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
                           Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
                           Filemonthly$Period=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",nrow(filesub),")")
                           metrics[g,23:27]=Filemonthly[1,7:11]
                           
                           total=nrow(filesub)
                           filesub1=filesub[1:round(total*0.7,0),]
                           filesub2=filesub[(round(total*0.7,0)+1):nrow(filesub),]
                           r1=length(1:round(total*0.7,0))
                           r2=length((round(total*0.7,0)+1):nrow(filesub))
                           DatesRegister1=paste0(as.character(as.Date(filesub1$Dates[1]))," - ",as.character(as.Date(filesub1$Dates[nrow(filesub1)]))," N(",r1,")")
                           DatesRegister2=paste0(as.character(as.Date(filesub2$Dates[1]))," - ",as.character(as.Date(filesub2$Dates[nrow(filesub2)]))," N(",r2,")")
                           filesub=filesub1
                           Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
                           Filemonthly$N=1
                           Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
                           Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
                           Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
                           Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
                           Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
                           Filemonthly$Period=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",nrow(filesub),")")
                           metrics1[g,23:27]=Filemonthly[1,7:11]
                           filesub=filesub2
                           Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
                           Filemonthly$N=1
                           Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(N=Filemonthly$N),mean,na.rm=T)
                           Filemonthly$TotalRunoff_Precipitation=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
                           Filemonthly$BaseFlow_TotalRunoff=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
                           Filemonthly$SurfaceRunoff_TotalRunoff=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
                           Filemonthly$Evapotranspiration_Precipitation=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
                           Filemonthly$Period=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",nrow(filesub),")")
                           metrics2[g,23:27]=Filemonthly[1,7:11]
                           
                           filesub=na.exclude(file[file$Gauge==uniqueGauges[g],])
                           r=nrow(filesub)
                           DatesRegister=paste0(as.character(as.Date(filesub$Dates[1]))," - ",as.character(as.Date(filesub$Dates[nrow(filesub)]))," N(",r,")")
                           modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
                           observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
                           if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
                             error=gof(modeled,observed,digits=5,na.rm=TRUE)
                             metrics[g,(3+ncol(keysset)):(ncol(metrics)-6)]=round(error[errorEvaluar],3)
                           } else {metrics[g,(3+ncol(keysset)):(ncol(metrics)-6)]=NA}
                           metrics$PeriodGOF[g]=DatesRegister
                           
                           total=nrow(filesub)
                           filesub1=filesub[1:round(total*0.7,0),]
                           filesub2=filesub[(round(total*0.7,0)+1):nrow(filesub),]
                           r1=length(1:round(total*0.7,0))
                           r2=length((round(total*0.7,0)+1):nrow(filesub))
                           DatesRegister1=paste0(as.character(as.Date(filesub1$Dates[1]))," - ",as.character(as.Date(filesub1$Dates[nrow(filesub1)]))," N(",r1,")")
                           DatesRegister2=paste0(as.character(as.Date(filesub2$Dates[1]))," - ",as.character(as.Date(filesub2$Dates[nrow(filesub2)]))," N(",r2,")")
                           
                           filesub=filesub1
                           modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
                           observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
                           if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
                             error=gof(modeled,observed,digits=5,na.rm=TRUE)
                             metrics1[g,(3+ncol(keysset)):(ncol(metrics)-6)]=round(error[errorEvaluar],2)
                           } else {metrics1[g,(3+ncol(keysset)):(ncol(metrics)-6)]=NA}
                           metrics1$PeriodGOF[g]=DatesRegister1
                           
                           filesub=filesub2
                           modeled <- filesub[filesub$Gauge==uniqueGauges[g],]$Modeled
                           observed <- filesub[filesub$Gauge==uniqueGauges[g],]$Observed
                           if (sum(modeled)!=0 && sum(observed,na.rm=TRUE)!=0) {
                             error=gof(modeled,observed,digits=5,na.rm=TRUE)
                             metrics2[g,(3+ncol(keysset)):(ncol(metrics)-6)]=round(error[errorEvaluar],2)
                           } else {metrics2[g,(3+ncol(keysset)):(ncol(metrics)-6)]=NA}
                           metrics2$PeriodGOF[g]=DatesRegister2
                         }
                         
                         metrics$Type="All"
                         metrics1$Type="Calibration (70%)"
                         metrics2$Type="Validation (30%)"
                         metricsALL=rbind(metricsALL,metrics,metrics1,metrics2)
                         
                         iprogress=iprogress+1
                       }
                       
                     })
        
        metricsALL=metricsALL[-1,]
        metricsALL=metricsALL[,-2]
        write.csv(metricsALL,paste0(getwd(),"\\SummaryGOF_",as.character(input$datest[1]),"-",as.character(input$datest[2]),".csv"),row.names=F) 
        
        
        output$inputRunIDt <- renderUI({
          numericInput("runIDt",label="Select Run ID:", min(as.numeric(keysset[,1])), min=min(as.numeric(keysset[,1])), max=max(as.numeric(keysset[,1])))
        })
        output$runIDValues <- renderText({
          
          paste0("Runs are between ",min(keysset[,1]), " and ", max(keysset[,1])) 
        })
        
        output$textRunactmetrics <- renderText({
          paste0("The file SummaryGOF_",as.character(input$datest[1]),"-",as.character(input$datest[2]),".csv was created")
          })
        
      } 
    })
    
    metricssub <- reactive({
      nset <- input$nse
      nrmset <- input$nrmse
      biast <- input$bias
      
     metricsall <- read.csv(paste0(getwd(),"\\SummaryGOF_",as.character(input$datest[1]),"-",as.character(input$datest[2]),".csv"),check.names=F,stringsAsFactors = F)
     metricssub <- metricsall[which(metricsall[,16] >= nset & metricsall[,14] <= nrmset & abs(metricsall[,15]) <= biast),c(1,2,13:ncol(metricsall))]
     metricssub
      
    })
    output$metricsruns <- renderDataTable({
      metricssub()
    })
    
    output$runIDtt <- renderText({
      if (file.exists(paste0(getwd(),"\\KeyModelInputs.csv"))) {
        output$keysresults <- renderTable({
          runID <- input$runIDt
          keysset <- read.csv(paste0(getwd(),"\\KeyModelInputs.csv"),stringsAsFactors =F,check.names=F)
          keyssub <- keysset[which(keysset$Nrun==runID),]
          k <- colnames(keyssub)[2:ncol(keyssub)]
          k <- gsub(":Annual Activity Level","",k)
          t <- cbind(k,as.numeric(t(keyssub[2:ncol(keyssub)])[,1]))
          colnames(t) <- c("Key","Value")
          t
        })
      }
      paste0("Selected run: ", input$runIDt)
      
    })
    
    filet <- reactive({
      
      file <- read.csv(paste0(getwd(),"//ResultsWB-",input$runIDt,".csv"), stringsAsFactors=F, check.names=F)
      file$Dates=ymd(file$Dates)
      file=file[file$Gauge==input$StreamflowSelectt,]
      file$YearMonth=year(file$Dates)*100+month(file$Dates)
      file$Month=month(file$Dates)
      filet <- file[which(file$Dates >= input$datest[1] & file$Dates <= input$datest[2]),]
      filet
    })
    
    output$Qt <- renderPlotly({
      
      
      file <- filet()
      filesub=file
      p <-plot_ly(filesub, x=~Dates, y=~Observed, name = "Observed", type="scatter", mode="lines",
                  line = list(color="black",width=1.5)) %>%
        add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
        layout(title = paste0("Streamflow ",input$StreamflowSelectt),
               xaxis = list(title=""),
               yaxis = list(title= "Q (M^3)"))
      p
      
      
    })
    output$Qmonthlyt <- renderPlotly({
      
      file <- filet()
      filesub=file
      Qmonthly <- aggregate(filesub[,c("Observed","Modeled")], by=list(YearMonth=filesub$YearMonth),mean,na.rm=F)
      
      Qmonthly$Month=Qmonthly$YearMonth%%100
      
      Qmonthly <- aggregate(Qmonthly[,c("Observed","Modeled")], by=list(Month=Qmonthly$Month),mean,na.rm=T)
      
      pmonthly <- plot_ly(Qmonthly, x=~Month, y=~Observed, name = "Observed", showlegend=FALSE,type="scatter", mode="lines",
                          line = list(color="black",width=1.5)) %>%
        add_trace(y=~Modeled, name="Modeled", line=list(color="red",width=1.5, dash="dot")) %>%
        layout(title = paste0("Monthly Average ",input$StreamflowSelectt),
               xaxis = list(title=""),
               yaxis = list(title= "Q (M^3)"))
      pmonthly
      
    })
    output$fdct <- renderPlotly({
      
      file <- filet()
      filesub=file
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
        layout(title =paste0("Flow Duration Curve ",input$StreamflowSelectt),yaxis = list(title="Q (M^3)"),xaxis=list(title="Probability (%)"))
      fdc  
    })
    output$WBt <- renderPlotly({
      
      file <- filet()
      filesub=file
      filesub[,6:14]=round(filesub[,6:14]/filesub[,15]*1000,2)
      
      filesub$Interflow2 <- filesub$Interflow+filesub$Base_Flow
      filesub$SurfaceRunoff2 <- filesub$Surface_Runof + filesub$Interflow2
      filesub$Evapotranspiration2 <- filesub$Evapotranspiration + filesub$SurfaceRunoff2
      
      pWB <- plot_ly(filesub, x=~Dates, y=~Precipitation, name="Precipitation", type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=0.5), text=~paste("Precip = ", Precipitation)) %>%
        add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
        add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
        add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
        add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
        layout(title = paste0("Water Balance ",input$StreamflowSelectt),yaxis = list(title="mm"),  xaxis =list(title="Date"))
      
      pWB
    })
    output$WBSMt <- renderPlotly({
      
      file <- filet()
      filesub=file
      filesub[,6:14]=round(filesub[,6:14]/filesub[,15]*1000,2)
      filesub[,11]=-1*filesub[,11]
      filesub$SM=filesub[,11]+filesub[,12]
      
      p4 <-plot_ly(filesub, x=~Dates, y=filesub[,11], name="Decrease in Soil Moisture", type="scatter", mode="lines",
                   line = list(color="#CF6D0C",width=1.5),text=~paste("Decrease Soil Moisture = ", filesub$`Decrease in Soil Moisture`)) %>%
        add_trace(y=~filesub[,12], name="Increase in Soil Moisture", line=list(color="#167FE8",width=1.5),text=~paste("Increase Soil Moisture = ", filesub$`Increase in Soil Moisture`)) %>%
        layout(title = paste0("Water Balance (Soil Moisture) ",input$StreamflowSelectt),
               xaxis = list(title="Date"),
               yaxis = list(title= "mm"))
      p4
    })
    output$WBSEt <- renderPlotly({
      
      file <- filet()
      filesub=file
      filesub[,6:14]=round(filesub[,6:14]/filesub[,15]*1000,2)
      filesub[,13]=-1*filesub[,13]
      filesub$SE=filesub[,13]+filesub[,14]
      
      p5 <-plot_ly(filesub, x=~Dates, y=filesub[,13], name="Decrease in Surface Storage", type="scatter", mode="lines",
                   line = list(color="#CF6D0C",width=1.5),text=~paste("Decrease Surface Storage = ", filesub$`Decrease in Surface Storage`)) %>%
        add_trace(y=~filesub[,14], name="Increase in Surface Storage", line=list(color="#167FE8",width=1.5),text=~paste("Increase Surface Storage = ", filesub$`Increase in Surface Storage`)) %>%
        layout(title = paste0("Water Balance (Surface Storage) ",input$StreamflowSelectt),
               xaxis = list(title="Date"),
               yaxis = list(title= "mm"))
      p5
    })
    output$WBmonthlyt <- renderPlotly({
      
      file <- filet()
      filesub=file
      filesub[,4:14]=round(filesub[,4:14]/filesub[,15]*1000,2)
      
      filesub$Interflow2 <- filesub$Interflow+filesub$Base_Flow
      filesub$SurfaceRunoff2 <- filesub$Surface_Runof + filesub$Interflow2
      filesub$Evapotranspiration2 <- filesub$Evapotranspiration + filesub$SurfaceRunoff2
      
      if (ncol(filesub)==23){
        wbmonthly <- aggregate(filesub[,c(6:14,19:23)], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      }
      if (ncol(filesub)==21){
        wbmonthly <- aggregate(filesub[,c(6:14,19:21)], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      }
      
      wbmonthly$Month=wbmonthly$YearMonth%%100
      
      if (ncol(wbmonthly)==15){
        wbmonthly <- aggregate(wbmonthly[,c(2:15)], by=list(Month=wbmonthly$Month),mean,na.rm=T)
      }
      if (ncol(wbmonthly)==14){
        wbmonthly <- aggregate(wbmonthly[,c(2:14)], by=list(Month=wbmonthly$Month),mean,na.rm=T)
      }
      
      p2monthly <- plot_ly(wbmonthly, x=~Month, y=~Precipitation, name="Precipitation", showlegend=TRUE, type="scatter",mode="none",fill="tozeroy",fillcolor ="white",line=list(color="black",width=1.5), text=~paste("Precip = ", Precipitation)) %>%
        add_trace(y=~Evapotranspiration2, name="Evapotranspiration", fill="tozeroy", fillcolor="rgba(127,191,63,0.57)",line=list(color="rgba(127,191,63,0.57)",width=1.5,dash="line"),text=~paste("ET = ", Evapotranspiration)) %>%
        add_trace(y=~SurfaceRunoff2, name="Surface Runoff", fill="tozeroy", fillcolor="rgba(63,127,191,0.57)",line=list(color="rgba(63,127,191,1)",width=1.5,dash="line"),text=~paste("Surface Runoff = ", Surface_Runoff)) %>%
        add_trace(y=~Interflow2, name="Interflow",fillcolor="rgba(71,74,249,0.73)",line=list(color="rgba(71,74,249,0.73)",width=1.5,dash="line"),text=~paste("Interflow = ", Interflow)) %>%
        add_trace(y=~Base_Flow, name="Base Flow",fillcolor="rgba(0,3,183,0.73)",line=list(color="rgba(0,3,183,0.0.73)",width=1.5,dash="line"),text=~paste("Base Flow = ", Base_Flow)) %>%
        layout(title =paste0("Water Balance Monthly Average ",input$StreamflowSelectt),yaxis = list(title="mm"),xaxis=list(title="Months"))
      
      p2monthly
      
    })
    output$WBmonthlytB <- renderPlotly({
      
      file <- filet()
      filesub=file
      Filemonthly <- aggregate(filesub[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      Filemonthly$Month=Filemonthly$YearMonth%%100
      Filemonthly <- aggregate(Filemonthly[,c("Modeled","Precipitation","Evapotranspiration","Surface_Runoff", "Base_Flow")], by=list(Month=Filemonthly$Month),mean,na.rm=T)
      Filemonthly$`TotalRunoff/Precipitation%`=round(Filemonthly$Modeled/Filemonthly$Precipitation*100,1)
      Filemonthly$`BaseFlow/TotalRunoff%`=round(Filemonthly$Base_Flow/Filemonthly$Modeled*100,1)
      Filemonthly$`SurfaceRunoff/TotalRunoff%`=round(Filemonthly$Surface_Runoff/Filemonthly$Modeled*100,1)
      Filemonthly$`Evapotranspiration/Precipitation%`=round(Filemonthly$Evapotranspiration/Filemonthly$Precipitation*100,1)
      Filemonthly=Filemonthly[,-(2:6)]
      
      p2monthly <- plot_ly(Filemonthly, x=~Month, y=~`TotalRunoff/Precipitation%`, name="TotalRunoff/Precipitation%", showlegend=TRUE, type="scatter",mode="line",text=~paste("TotalRunoff/Precipitation% = ", `TotalRunoff/Precipitation%`)) %>%
        add_trace(y=~`BaseFlow/TotalRunoff%`, name="BaseFlow/TotalRunoff%", type="scatter",mode="line",text=~paste("BaseFlow/TotalRunoff% = ", `BaseFlow/TotalRunoff%`)) %>%
        add_trace(y=~`SurfaceRunoff/TotalRunoff%`, name="SurfaceRunoff/TotalRunoff%", type="scatter",mode="line",text=~paste("SurfaceRunoff/TotalRunoff% = ", `SurfaceRunoff/TotalRunoff%`)) %>%
        add_trace(y=~`Evapotranspiration/Precipitation%`, name="Evapotranspiration/Precipitation%", type="scatter",mode="line",text=~paste("Evapotranspiration/Precipitation% = ", `Evapotranspiration/Precipitation%`)) %>%
        layout(title =paste0("% ",input$StreamflowSelectt),yaxis = list(title="%"),xaxis=list(title="Months"))
      
      p2monthly
      
    })
    output$WBtablet <- renderDataTable({
      
      file <- filet()
      filesub=file
      filesub[,4:14]=round(filesub[,4:14]/filesub[,15]*1000,2)
      
      wbmonthly <- aggregate(filesub[,c(4:14)], by=list(YearMonth=filesub$YearMonth),sum,na.rm=F)
      wbmonthly$Month=wbmonthly$YearMonth%%100
      wbmonthly <- aggregate(wbmonthly[,c(2:12)], by=list(Month=wbmonthly$Month),mean,na.rm=T)
      wbmonthly$`TotalRunoff/Precipitation%`=round(wbmonthly$Modeled/wbmonthly$Precipitation*100,1)
      wbmonthly$`BaseFlow/TotalRunoff%`=round(wbmonthly$Base_Flow/wbmonthly$Modeled*100,1)
      wbmonthly$`SurfaceRunoff/TotalRunoff%`=round(wbmonthly$Surface_Runoff/wbmonthly$Modeled*100,1)
      wbmonthly$`Evapotranspiration/Precipitation%`=round(wbmonthly$Evapotranspiration/wbmonthly$Precipitation*100,1)
      
      
      wbtable <- round(wbmonthly[,c("Month","Precipitation","Evapotranspiration","Surface_Runoff","Interflow","Base_Flow","Modeled", "TotalRunoff/Precipitation%","BaseFlow/TotalRunoff%", "SurfaceRunoff/TotalRunoff%","Evapotranspiration/Precipitation%")],3)
      colnames(wbtable) <- c("Month","Precipitation (mm)","Evapotranspiration (mm)","Surface_Runoff (mm)","Interflow (mm)","Base_Flow (mm)","Q Modeled (mm)", "TotalRunoff / Precipitation %","BaseFlow / TotalRunoff %", "SurfaceRunoff / TotalRunoff %","Evapotranspiration / Precipitation %")
      wbtable
    })
    output$SM1t <- renderPlotly({
      
      file <- filet()
      filesub=file
      pSM1 <-plot_ly(filesub, x=~Dates, y=~`Relative Soil Moisture 1`, name = "Relative Soil Moisture 1 %", type="scatter", mode="lines",
                     line = list(color="black",width=1.5)) %>%
        layout(title = paste0("Relative Soil Moisture 1 % ",input$StreamflowSelectt),
               xaxis = list(title="Dates"),
               yaxis = list(title= "Relative Soil Moisture 1 (%)"))
      pSM1
      
      
    })
    output$SM2t <- renderPlotly({
      
      file <- filet()
      filesub=file
      pSM2 <-plot_ly(filesub, x=~Dates, y=~`Relative Soil Moisture 2`, name = "Relative Soil Moisture 2 %", type="scatter", mode="lines",
                     line = list(color="blue",width=1.5)) %>%
        layout(title = paste0("Relative Soil Moisture 2 % ",input$StreamflowSelectt),
               xaxis = list(title="Dates"),
               yaxis = list(title= "Relative Soil Moisture 2 (%)"))
      pSM2
      
      
    })
    
    output$GOFtMAE = renderPlotly({
        file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="MAE"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data[,which(colnames(data)=="MAE")], showlegend=TRUE, type = "box") %>%  
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="MAE"))
        
        d     
    })  
    output$GOFtNRMSE = renderPlotly({
         file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="NRMSE"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data$`NRMSE %`, showlegend=TRUE, type = "box") %>%  
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="NRMSE"))
        
        d
    })  
    output$GOFtPBIAS = renderPlotly({
        file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="PBIAS"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data$`PBIAS %`, showlegend=TRUE, type = "box") %>% 
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="PBIAS"))
        
        d
      
    })  
    output$GOFtNSE = renderPlotly({
        file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="NSE"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data[,which(colnames(data)=="NSE")], showlegend=TRUE, type = "box") %>%  
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="NSE"))
        
        d
      
    })  
    output$GOFtd = renderPlotly({
        file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="d"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data[,which(colnames(data)=="d")], showlegend=TRUE, type = "box") %>% 
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="d"))
        
        d
      
    })  
    output$GOFtR2 = renderPlotly({
        file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="R2"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data[,which(colnames(data)=="R2")], showlegend=TRUE, type = "box") %>%  
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="R2"))
        
        d
    })  
    output$GOFtKGE = renderPlotly({
        file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="KGE"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data[,which(colnames(data)=="KGE")], showlegend=TRUE, type = "box") %>%  
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="KGE"))
        
        d
      
    })  
    output$GOFtVE = renderPlotly({
        file=metricssub()
        file=file[file$Gauge==input$StreamflowSelectt,]
        data=file
        
        title="VE"
        d=plot_ly(data, x = data[,which(colnames(data)=="Type")], y = data[,which(colnames(data)=="VE")], showlegend=TRUE, type = "box") %>%  
          layout(title = paste0(title," ",input$StreamflowSelectt),
                 xaxis = list(title="Type"),
                 yaxis = list(title="VE"))
        
        d
      
    })  
    
    output$textWD_resultsGraphs <-renderText({
      if (is.null(input$WD_resultsGraphs)) {
        return(NULL)
      } else {
        setwd(input$WD_resultsGraphs)
        listResults=as.data.frame(sort(list.files(getwd(),pattern =".csv"),decreasing = TRUE))
        
        output$UploadedFileCsv <- renderUI({
          selectInput("UploadedFile", "",listResults)
        })
        
        paste0("The working directory was changed to: ",getwd())
        
      }
    })
    
    observeEvent(input$UploadedFile,{
      data=as.data.frame(read.csv(input$UploadedFile, stringsAsFactors=F, check.names=F))
      output$tableUploadedFile <- renderDataTable({
        data
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
      
      if ((length(which(colnames(data)=="Gauge"))>0)) {
        output$Gauges <- renderUI({
          selectInput("Gauge", "Gauge:",unique(data$Gauge))
        })
      }
      
      if ((length(which(colnames(data)=="Catchment"))>0)) {
        output$Gauges <- renderUI({
          selectInput("Catchment", "Catchment:",unique(data$Catchment))
        })
      }
    })
    
    output$plotfile = renderPlotly({
      d=NULL
      if (file.exists(input$UploadedFile)){
        data=as.data.frame(read.csv(input$UploadedFile, stringsAsFactors=F, check.names=F))
        titleGraph=input$UploadedFile
        
        if (length(which(colnames(data)=="Dates"))>0){
          data$Dates=ymd(data$Dates)
        }
        
        if (length(which(colnames(data)=="Gauge"))>0){
          data=data[data$Gauge==input$Gauge,]
          titleGraph=paste0(titleGraph," Gauge: ",input$Gauge)
        }
        
        if (length(which(colnames(data)=="Catchment"))>0){
          data=data[data$Catchment==input$Catchment,]
          titleGraph=paste0(titleGraph," Catchment: ",input$Catchment)
        }
        
        if (length(which(colnames(data)=="Gauge"))>0 && length(which(colnames(data)=="Catchment"))>0){
          titleGraph=paste0(titleGraph," Gauge: ",input$Gauge," Catchment: ",input$Catchment)
        }
        
        
        data1=data[,c(which(colnames(data)==input$Xaxisoptions))]
        data1=as.data.frame(data1)
        colnames(data1)=paste(c("X: "),input$Xaxisoptions)
        data2=data[,c(which(colnames(data)==input$Xaxisoptions),which(colnames(data)==input$Yaxisoptions))]
        colnames(data2)=paste(c("X: ","Y: "),colnames(data2))
        data3=data[,c(which(colnames(data)==input$Xaxisoptions),which(colnames(data)==input$Yaxisoptions),which(colnames(data)==input$Zaxisoptions))]
        colnames(data3)=paste(c("X: ","Y: ","Z: "),colnames(data3))
        
        if (input$Type=="scatter"){
          d=plot_ly(data, x = data[,which(colnames(data)==input$Xaxisoptions)], y = data[,which(colnames(data)==input$Yaxisoptions)], showlegend=TRUE, type = input$Type, mode = input$TypeMode, color = data[,which(colnames(data)==input$Yaxisoptions)]) %>%  
            layout(title = titleGraph,
                   xaxis = list(title=input$Xaxisoptions),
                   yaxis = list(title=input$Yaxisoptions))
          
          output$tableplotfile <- renderDataTable({
            data2
            
          })
          
        } else if (input$Type== "histogram"){
          d=plot_ly(x = data[,which(colnames(data)==input$Xaxisoptions)], showlegend=TRUE, type = input$Type, histnorm = "probability") %>%  
            layout(title = titleGraph,
                   xaxis = list(title=input$Xaxisoptions),
                   yaxis = list(title="Probability"))
          
          output$tableplotfile <- renderDataTable({
            data1
            
          })
          
        } else if (input$Type== "scatter3d"){
          d=plot_ly(data, x = data[,which(colnames(data)==input$Xaxisoptions)], y = data[,which(colnames(data)==input$Yaxisoptions)], z = data[,which(colnames(data)==input$Zaxisoptions)], type = input$Type ,color = data[,which(colnames(data)==input$Zaxisoptions)] ) %>%  
            layout(title = titleGraph,
                   xaxis = list(title=input$Xaxisoptions),
                   yaxis = list(title=input$Yaxisoptions))
          
          output$tableplotfile <- renderDataTable({

            data3
          })
          
        } else if (input$Type== "mesh3d" || input$Type=="contour" || input$Type=="heatmap"){
          d=plot_ly(data, x = data[,which(colnames(data)==input$Xaxisoptions)], y = data[,which(colnames(data)==input$Yaxisoptions)], z = data[,which(colnames(data)==input$Zaxisoptions)], type = input$Type ) %>%   
            layout(title = titleGraph,
                   xaxis = list(title=input$Xaxisoptions),
                   yaxis = list(title=input$Yaxisoptions))
          
          output$tableplotfile <- renderDataTable({
            
            data3
          })
          
        } else if (input$Type== "bar" || input$Type== "histogram2d" || input$Type== "histogram2dcontour" || input$Type== "waterfall" || input$Type== "pointcloud"){
          d=plot_ly(data, x = data[,which(colnames(data)==input$Xaxisoptions)], y = data[,which(colnames(data)==input$Yaxisoptions)], showlegend=TRUE, type = input$Type, color = data[,which(colnames(data)==input$Yaxisoptions)]) %>%  
            layout(title = titleGraph,
                   xaxis = list(title=input$Xaxisoptions),
                   yaxis = list(title=input$Yaxisoptions))
          
          output$tableplotfile <- renderDataTable({
            
            data2
            
          })
          
        } else if (input$Type== "box" || input$Type== "violin"){
          d=plot_ly(data, x = data[,which(colnames(data)==input$Xaxisoptions)], y = data[,which(colnames(data)==input$Yaxisoptions)], showlegend=TRUE, type = input$Type) %>%  
            layout(title = titleGraph,
                   xaxis = list(title=input$Xaxisoptions),
                   yaxis = list(title=input$Yaxisoptions))
          
          output$tableplotfile <- renderDataTable({
            
            data2
            
          })
          
        } 
        
        d
      }
      d
    })  
    
    
  }

  
)
