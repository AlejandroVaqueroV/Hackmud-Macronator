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

#announce interval, params and backup
Write-Host "Macronator will sync files every $timerSeconds seconds. 
Change by calling file in console with -timerSeconds XX, Exit with -exit
We keep the last 5 versions of each .macros file under %appdata%\hackmud\Macro Backups"

#gets hackmud folder
$hackmudEnv = "$env:APPDATA\hackmud"

#creating backup folder
$backupDir = Join-Path $hackmudEnv "Macro Backups"
if (-Not (Test-Path $backupDir)) {
    New-Item -Path $backupDir -ItemType Directory
}

#function to create backups of files before editing them
function Backup-File {
    param (
        [String]$sourceFilePath
    )
    $baseName = [IO.Path]::GetFileNameWithoutExtension($sourceFilePath)

    #for 'Murica time use yyyyMMddHHmmss
    $backupFileName = "{0}_{1:ddMMyyyyHHmmss}.macros" -f $baseName, (Get-Date)
    $backupFilePath = Join-Path $backupDir $backupFileName

    #copy the file to backup directory
    Copy-Item -Path $sourceFilePath -Destination $backupFilePath

    #get all backup files and sort by creation time, remove the oldest if more than 5
    $existingBackups = Get-ChildItem -Path $backupDir -Filter "$baseName*.macros" | Sort-Object CreationTime -Descending
    if ($existingBackups.Count -gt 5) {
        $toRemove = $existingBackups | Select-Object -Skip 5
        Remove-Item -Path $toRemove.FullName
    }
}

#main sync loop
while($true) {

#get .macros and .key macroFiles in macroFiles array
$macroFiles = Get-ChildItem -Path $hackmudEnv -Filter "*.macros"
$keyFiles = Get-ChildItem -Path $hackmudEnv -Filter "*.key"

#sort macro macroFiles by first and last edited
$firstEdited = $macroFiles | Sort-Object LastWriteTime | Select-Object -first 1
$lastEdited = $macroFiles | Sort-Object LastWriteTime | Select-Object -last 1

#gets content of las edited file before doing any operations
$content = Get-Content $lastEdited.FullName

#only sync if file is not empty
if ($null -ne $content -and $content -ne "") {

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

                #create backup first, then sync
                Backup-File -sourceFilePath $file.FullName
                Set-Content -Path $file.FullName -Value $content
            }
        }
    }

}

Start-Sleep -Seconds $timerSeconds

}
