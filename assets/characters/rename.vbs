set fso = CreateObject("Scripting.FileSystemObject")
set rootTrivial = fso.getFolder("C:\Users\bigpl\Desktop\characters\Tail\trivial")
set rootRare = fso.getFolder("C:\Users\bigpl\Desktop\characters\Tail\rare")
set rootSuperrare = fso.getFolder("C:\Users\bigpl\Desktop\characters\Tail\superrare")
Dim totalNumberTrivial
Dim numberTrivial

for each file in rootTrivial.Files
    totalNumberTrivial=totalNumberTrivial+1
Next

for each file in rootTrivial.Files
numberTrivial=numberTrivial+1
If (numberTrivial < totalNumberTrivial\3) Then
	file.Name = numberTrivial & "." & fso.GetExtensionName(file.Name)
ElseIf (numberTrivial < 2*totalNumberTrivial\3) Then
	file.Name = numberTrivial & "." & fso.GetExtensionName(file.Name)
Else 
	file.Name = numberTrivial & "." & fso.GetExtensionName(file.Name)
End If
next

Dim totalNumberRare
Dim numberRare

for each file in rootRare.Files
    totalNumberRare=totalNumberRare+1
Next

for each file in rootRare.Files
numberRare=numberRare+1
If (numberRare < totalNumberRare\3) Then
	file.Name = numberRare & "." & fso.GetExtensionName(file.Name)
ElseIf (numberRare < 2*totalNumberRare\3) Then
	file.Name = numberRare & "." & fso.GetExtensionName(file.Name)
Else 
	file.Name = numberRare & "." & fso.GetExtensionName(file.Name)
End If
next

Dim totalNumberSuperrare
Dim numberSuperrare

for each file in rootSuperrare.Files
    totalNumberSuperrare=totalNumberSuperrare+1
Next

for each file in rootSuperrare.Files
numberSuperrare=numberSuperrare+1
If (numberSuperrare < totalNumberSuperrare\3) Then
	file.Name = numberSuperrare & "." & fso.GetExtensionName(file.Name)
ElseIf (numberSuperrare < 2*totalNumberSuperrare\3) Then
	file.Name = numberSuperrare & "." & fso.GetExtensionName(file.Name)
Else 
	file.Name = numberSuperrare & "." & fso.GetExtensionName(file.Name)
End If
next