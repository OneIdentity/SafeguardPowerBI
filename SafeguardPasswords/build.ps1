
#Parse and increment Version 
$ver = get-content .\Version.txt
$splitVer = $ver.Split(".")
$intVer = [int]::Parse($splitVer[2]) + 1
$splitVer[2] = $intVer
$newVer = [string]::Join(".",$splitVer)

#New file name to include version
$name = "OneIdentitySafeguardForPrivilegedPasswords-$newVer.mez"
$path = "C:\$env:HOMEPATH\OneDrive - Quest\Documents\Power BI Desktop\Custom Connectors"

#Update Constants file
$constantsFile = get-content ..\Common\Modules\Constants.pqm
$newConstantsFile = $constantsFile.Replace("$ver","$newVer")
$newConstantsFile | Out-File ..\Common\Modules\Constants.pqm -Encoding utf8

#Update Version file
$newVer > .\Version.txt

#Make and move
make
copy-item bin/OneIdentitySafeguardForPrivilegedPasswords.mez "$path\$name"

# cp bin/OneIdentitySafeguardForPrivilegedPasswords.mez "C:\Users\aamburn\OneDrive - Quest\Documents\Power BI Desktop\Custom Connectors"