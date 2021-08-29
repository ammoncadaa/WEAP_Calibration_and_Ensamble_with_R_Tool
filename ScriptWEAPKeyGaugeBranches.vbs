CLS

Set fso = CreateObject("Scripting.FileSystemObject")
rootDirectory = WEAP.ActiveAreaDirectory
folderToBeCreated = "WEAPKeyGaugeBranches"
path = rootDirectory & "\"  & folderToBeCreated
BuildFullPath path
Sub BuildFullPath(ByVal FullPath)
    If Not fso.FolderExists(FullPath) Then
        BuildFullPath fso.GetParentFolderName(FullPath)
        fso.CreateFolder FullPath
    End If
End Sub


myFile = path & "\" & "WEAPKeyGaugeBranches" & ".csv"
Set oFile = fso.CreateTextFile(myFile)
REM if fso.FileExists(myFile) then
REM set  oFile=fso.OpenTextFile(myFile, 8)
REM else
sline= "Gauge Name"  & ","  &  "Observed Branch"   & ","  &  "Modeled Branch"
oFile.WriteLine sLine
REM End if

For each Br in WEAP.Branches

if Br.TypeID= 20 then

set Br1=Br.ReachAbove

sLine = Br.Name  & ","  &  Br.FullName & ":Streamflow[M^3]"   & ","  &  Br1.ReachBelow.FullName & ":Streamflow[M^3]"
oFile.WriteLine sLine
i=1+i
End if

Next

oFile.close



print "Done"