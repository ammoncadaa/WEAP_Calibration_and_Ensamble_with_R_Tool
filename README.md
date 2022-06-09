Developed by Angelica Moncada (SEI-LAC Water Group member) (2022) under the R version 4.1.1
https://www.weap21.org/
https://www.sei.org/centres/latinoamerica/

The WEAP Calibration and Ensemble with R tool serves to provide model builders with an automatic tool to assist in calibrating a WEAP model 

*The WEAP Calibration and Ensemble with R tool is shiny application (app.R).

*The -Inputs for Model Example- folder has a model and input files that can be used to test the tool in your computer. 

*The -input templates- folder has the template files for you to modify them considering your own models.  

*Copy and paste the script - WEAP_CalibrationToolwithR.vbs -within the WEAP model folder. Then, go to Advanced/Scripting/Edit Events. Finally, specify the script - WEAP_CalibrationToolwithR.vbs - as after WEAP's calculations within the Event Scripts screen. You will see in the After Calculation box: Call( WEAP_CalibrationToolwithR.vbs 

*In case that you have any problem installing the RDCOMClient package, you can add the folder of the package that is within the -RDCOMClient.zip- file. Extract the folder, then copy and paste it within your library folder. In general, the library can be found at -Documents\R\win-library\4.0-.

--------------------------------------------------------------------------------------------------------------------------------------------------

Instructions within each tab. READ CAREFULLY.

--------------------------------------------------------------------------------------------------------------------------------------------------