Param (
   [INT]$timerSeconds = 20, #parameter to adjust how often the sync job runs
   [bool]$exit = $false #parameter to stop the process
)

#we close all Macronator processes if exit = true
if ($exit) {
    Write-Host "Terminating all instances of Macronator.exe"
    Get-Process Macronator -ErrorAction SilentlyContinue | Stop-Process
    exit
}

#announce interval
Write-Host "Macronator will sync files every $timerSeconds seconds. 
Change by calling file in console with -timerSeconds XX, Exit with -exit"

#gets hackmud folder
$hackmudEnv = "$env:APPDATA\hackmud"

#main loop
while($true) {

#get .macros and .key macroFiles in macroFiles array
$macroFiles = Get-ChildItem -Path $hackmudEnv -Filter "*.macros"
$keyFiles = Get-ChildItem -Path $hackmudEnv -Filter "*.key"

#sort macro macroFiles by first and last edited
$firstEdited = $macroFiles | Sort-Object LastWriteTime | Select-Object -first 1
$lastEdited = $macroFiles | Sort-Object LastWriteTime | Select-Object -last 1

#gets content of las edited file before doing any operations
$content = Get-Content $lastEdited.FullName

#create .macros files for orphaned .key files
foreach ($keyFile in $keyFiles) {

    #populate var with theoretical .key name and with .macros extension
    $expectedMacroFile = [IO.Path]::ChangeExtension($keyFile.FullName, ".macros")

    #test if such a file exists
    if (-Not (Test-Path $expectedMacroFile)) {

        #create a macro file copy of the latest macro file if it doesn't
        Set-Content -Path $expectedMacroFile -Value $content
    }
}

#check if all the .macros files have been synced. If they haven't, runs sync job
if($firstEdited.LastWriteTime -ne $lastEdited.LastWriteTime) {

    #overwrite contents of all macroFiles with the last edited file, excluding original
    foreach($file in $macroFiles){
        if($file.FullName -ne $lastEdited.FullName){
            Set-Content -Path $file.FullName -Value $content
        }
    }
}

Start-Sleep -Seconds $timerSeconds

}
