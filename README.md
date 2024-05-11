# Hackmud-Macronator
User Macro syncing tool for the game Hackmud

Tested in Windows only, but feel free to try to run / fork to Linux: https://github.com/PowerShell/PowerShell - There should be no issues other than maybe needing to edit the $hackmudEnv for whatever one is used on Linux

Usage: make sure the last edited user's macros are the ones you want to sync, then run the tool.
To see changes in game, change user

 This tool is written in powershell and compiled using ps2exe

It will sync the latest edited .macros file to all other .macros files, and will create .macros files for orphaned .key files (users with no macros)

Backups: This tool will backup the last 5 versions of each individual file before updating, keeping them under %appdata%\hackmud\Macro Backups
Backup format is username_ddMMyyyyHHmmss

The tool checks for empty files to avoid emptying your macros, we use Hashes and .lastEdit for robust file comparison.

To run, simply execute. By default, it will detect and sync changes every 20 seconds. To edit this, or exit, call the executable from a console with the parameters:
- -exit to close all Macronator.exe instances
- -timerSeconds XX to change the frequency the program will check for file changes

To modify and compile:
- Open a shell: powershell (not shell:pwr, the default powershell for visual studio code) by doing Windows key+R and running Powershell.exe
- > Install-Module -Name ps2exe -Scope CurrentUser
- > Invoke-PS2exe -inputFile yourScript.ps1 -outputFile yourExecutable.exe -noConsole


