     CLS

Set WEAP_App = CreateObject("WEAP.WEAPApplication")
Set fso = CreateObject("Scripting.FileSystemObject")

rootDirectory = WEAP_App.ActiveAreaDirectory
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
if fso.FileExists(outfile1) then
set  oFile=fso.OpenTextFile(outfile1, 8)
else
sline= "Gauge Name"  & ","  &  "Observed Branch"   & ","  &  "Modeled Branch"
oFile.WriteLine sLine
End if

i=1
For each Br in WEAP.Branches

if Br.TypeID= 20 then

set Br1=Br.ReachAbove

    sLine = Br.Name  & ","  &  Br.FullName & ":Streamflow[M^3]"   & ","  &  Br1.ReachBelow.FullName & ":Streamflow[M^3]"
    oFile.WriteLine sLine
    i=1+i
    End if

Next




print "Done"