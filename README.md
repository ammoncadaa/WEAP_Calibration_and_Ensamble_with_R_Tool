Developed by Angelica Moncada (SEI-LAC Water Group member) (2020)
R version 4.0.2

The WEAP Calibration and Ensemble with R tool serves to provide model builders with an automatic tool to assist in calibrating a WEAP model and/or run a WEAP ensemble.

*The WEAP Calibration and Ensemble with R tool is shiny application (app.R). 
*The -Inputs for Model Example- folder has a model and input files that can be used to test the tool in your computer. 
*The -input templates- folder has the template files for you to modify them considering your own models.  
*One of the input files can be obtained automatically by running -ScriptWEAPKeyGaugeBranches.vbs-. First, Copy and paste this file within your WEAP area folder. Then, run it (Advance/Scripting/Run/Area Scripts/ScriptWEAPKeyGaugeBranches.vbs). Within the folder "WEAPKeyGaugeBranches" you will get "WEAPKeyGaugeBranches.csv".
*In case that you have any problem installing the RDCOMClient package, you can add the folder of the package that is within the -RDCOMClient.zip- file. Extract the folder, then copy and paste it within your library folder. In general, the library can be found at -Documents\R\win-library\4.0-.
