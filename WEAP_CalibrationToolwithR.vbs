REM ***********************************************************************************************
REM Instructions
REM Add the script as an after calculation event
REM .net FRAMEWORK IS REQUIRED !
REM ***********************************************************************************************

CLS
WEAP.Verbose = 0
WEAP.Visible = True
WEAP.AutoCalc = True
time1=time
print(time & " ... Wait")

Set fso = CreateObject("Scripting.FileSystemObject")
REM rootDirectory = WEAP.ActiveAreaDirectory
REM folderToBeCreated = "WEAPKeyGaugeBranches"
REM path = rootDirectory & "\"  & folderToBeCreated
REM BuildFullPath path
REM Sub BuildFullPath(ByVal FullPath)
REM     If Not fso.FolderExists(FullPath) Then
REM         BuildFullPath fso.GetParentFolderName(FullPath)
REM         fso.CreateFolder FullPath
REM     End If
REM End Sub

REM myFile = path & "\" & "WEAPKeyGaugeBranches" & ".csv"
myFile = WEAP.ActiveArea.Directory & "WEAPKeyGaugeBranches" & ".csv"
Set oFile = fso.CreateTextFile(myFile)
REM if fso.FileExists(myFile) then
REM set  oFile=fso.OpenTextFile(myFile, 8)
REM else
sline= "Gauge Name"  & ","  &  "Observed Branch"   & ","  &  "Modeled Branch"
oFile.WriteLine sLine
REM End if

REM myFile = path & "\" & "WEAPKeyGaugesCatchments" & ".csv"
myFile = WEAP.ActiveArea.Directory & "WEAPKeyGaugesCatchments" & ".csv"
Set oFile1 = fso.CreateTextFile(myFile)
REM if fso.FileExists(myFile) then
REM set  oFile=fso.OpenTextFile(myFile, 8)
REM else
sline= "Gauge"  & ","  &  "Catchment"
oFile1.WriteLine sLine
REM End if

For each Br in WEAP.Branches

    if Br.TypeID= 20 then
       set Br1=Br.ReachAbove
       sLine = Br.Name  & ","  &  Br.FullName & ":Streamflow[M^3]"   & ","  &  Br1.ReachBelow.FullName & ":Streamflow[M^3]"
       oFile.WriteLine sLine
       i=1+i

       For each Br2 in WEAP.Branch(Br.Name).UpstreamNodes(True).FilterByType("Catchment")

           REM Print Br2.Name
           sLine = Br.Name  & ","  &  Br2.Name
           oFile1.WriteLine sLine

       Next

    End if
Next

oFile.close
oFile1.close

myFile = WEAP.ActiveArea.Directory & "WEAPdays" & ".csv"
Set oFile1 = fso.CreateTextFile(myFile)
sline= "Time step"  & ","  &  "Days"
oFile1.WriteLine sLine
FOR i = 1 to WEAP.NumTimeSteps
    Val = WEAP.ResultValue("Key\DaysTimeStep:Annual Activity Level", WEAP.BaseYear, i)
    z1 =  i  & "," &  Val
    oFile1.WriteLine z1
NEXT
oFile1.close

file1 = WEAP.ActiveArea.Directory & "WEAPKeyGaugeBranches.csv"

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFS = CreateObject("Scripting.FileSystemObject")

CodRun = WEAP.Branch("Key\NumRun").Variables("Annual Activity Level").Value

    of1 = CodRun &"_"& WEAP.ActiveScenario & "_WaterBalance.csv"
    outfile1 = WEAP.ActiveArea.Directory & "\"  & of1
    set objFile1 = objFSO.CreateTextFile(outfile1)
    z1 = "Year,Time step,Branch,ObjectType,Scenario,Catchment,Precipitation,Evapotranspiration,Surface_Runoff,Interflow,Base_Flow,Decrease in Soil Moisture,Increase in Soil Moisture,Decrease in Surface Storage,Increase in Surface Storage,Area,Relative Soil Moisture 1,Relative Soil Moisture 2"
    objFile1.WriteLine z1

    of1 = CodRun &"_"& WEAP.ActiveScenario & "_ResultsGauges.csv"
    outfile2 = WEAP.ActiveArea.Directory & "\"  & of1
    set objFile2 = objFSO.CreateTextFile(outfile2)
    z1 = "Year,Time step,Gauge,Observed,Modeled,Scenario"
    objFile2.WriteLine z1


FOR i =(WEAP.BaseYear+1)  to WEAP.EndYear

  FOR ii = 1 to WEAP.NumTimeSteps
  REM WEAP.NumTimeSteps

     YearFilter =i
     TimeStepFilter = ii

    ObjectTyp = "Catchment" REM vo(2)
    Sce   = WEAP.ActiveScenario REM vo(3)
    ObjectTypID = 21
    LevelFilter = 2

         For each Br in WEAP.Branches
              if cint(Br.TypeID) = cint(ObjectTypID) then
                  levels = split(Br.fullname,"\")
                  if (Ubound(levels) + 1) = cint(LevelFilter) then
                       BrName=Br.Name

                        
                        Val = WEAP.ResultValue(Br.fullname & ":Observed Precipitation[M^3]", i, ii, sce)
                        z1 =  YearFilter & "," & TimeStepFilter & "," & BR.fullname & "," & ObjectTyp  & "," & Sce & "," & BrName & "," & Val
                        Val = WEAP.ResultValue(Br.fullname & ":Evapotranspiration[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Surface Runoff[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Interflow[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Base Flow[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Decrease in Soil Moisture[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Increase in Soil Moisture[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Decrease in Surface Storage[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Increase in Surface Storage[M^3]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Area Calculated[M^2]", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Relative Soil Moisture 1", i, ii, sce)
                        z1 =  z1  & "," &  Val
                        Val = WEAP.ResultValue(Br.fullname & ":Relative Soil Moisture 2", i, ii, sce)
                        z1 =  z1  & "," &  Val
                       

                       objFile1.WriteLine z1
                   End If
              End If
         Next

    Set  objFile = objFS.OpenTextFile(file1)
    strLine = objFile.ReadLine

    Do Until objFile.AtEndOfStream
        strLine = objFile.ReadLine

    vo = split(strLine,",")
    gauge = vo(0)
    VarObs = vo(1)
    VarSim = vo(2)

      Val = WEAP.ResultValue(VarObs, i, ii, sce)
      Val1 = WEAP.ResultValue(VarSim, i, ii, sce)
      z1 =  YearFilter & "," & TimeStepFilter & "," & gauge &"," & Val&"," & Val1& "," & Sce

    objFile2.WriteLine z1

    Loop
    objFile.Close

Next
Next


objFile1.Close
objFile2.Close

print(time & " ... Finish")