# Hackmud-Macronator
Repo for the macro syncing tool I quickly made

It will sync the latest edited .macros file to all other .macros files, and will create .macros files for orphaned .key files (accounts with no macros)

This tool was written in powershell and compiled using ps2exe
To modify and compile:
- Open a shell: powershell (not shell:pwr, the default powershell for visual studio code) by doing Windows key+R and running Powershell.exe
- > Install-Module -Name ps2exe -Scope CurrentUser
- > Invoke-PS2exe -inputFile yourScript.ps1 -outputFile yourExecutable.exe -noConsole


