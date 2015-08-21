#
#
# Specialized script to fix a specific error. If you don't know
# what this script is for, you almost certainly do not need it.
#
#
# Recursively update all files in the current folder. 
# Read notes in the Rewrite-WAV-Header.ps1 script for important details.
#
# !!
# !! BACK UP YOUR FILES FIRST !!
# !!
#
# TO USE:
# 1. Make a copy of your wav files and put them into some easily-found 
#    directory. There can be subfolders. This script will process them.
#
# 2. Copy these two files (the .ps1 and .psm1) to the same directory
#
# 3. Open a Windows PowerShell command prompt. In Windows 10, just 
#    type "PowerShell" into the search box on the taskbar
#
# 4. Navigate to the directory where the files are. 
#
# 5. Type "recurs<tab>". When you hit tab, the statement will complete
#    saving you a bit of typing.
#
# 6. Hit enter on the line that says .\Recursive-Fix-WAV-Files.ps1
#
# 7. Let the script process each file. Note any errors that come up
#
# 8. Report any failures to Pete through either twitter or, preferably
#    through the github issues/discussion for this script.
#
#
# !! USE AT YOUR OWN RISK !!
#
# https://github.com/Psychlist1972/Fix-SoundDevices-File-Corruption


Import-Module .\Update-WAVHeader.psm1

Write-Host " "
Write-Host "This PowerShell script recursively fixes the Sound Devices broadcast wav files corrupted by an EFS check in Windows 10" -ForegroundColor DarkMagenta
Write-Host " "
Write-Host "Written by Pete Brown @pete_brown"  -ForegroundColor DarkMagenta
Write-Host "See script and GitHub location for important usage information"  -ForegroundColor DarkMagenta
Write-Host "Original GitHub location: https://github.com/Psychlist1972/Fix-SoundDevices-File-Corruption"  -ForegroundColor DarkMagenta

# prompt to ensure they backed up the files. Don't run if the user answers "no"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)

$caption = "Warning!"
$message = "Did you back up your files in this CURRENT folder and ALL subfolders?"
$result = $Host.UI.PromptForChoice($caption,$message,$choices,1)
if($result -eq 0) { $continue = $true }
if($result -eq 1) { $continue = $false }


Write-Host " "

if ($continue -eq $true)
{
	Write-Host "Processing current directory and all subdirectories, looking for .wav files." -ForegroundColor Cyan

	Get-ChildItem -recurse -include *.wav |	Foreach-Object { Update-WavHeader -FileName $_.FullName  }
}
else
{
	Write-Host "Aborting script." -ForegroundColor Red
}

Write-Host "Directory processing complete." -ForegroundColor Cyan
