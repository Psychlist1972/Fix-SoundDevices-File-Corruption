# Fix-SoundDevices-File-Corruption
PowerShell scripts to fix files corrupted by a very specific issue.

Files written by Sound Devices recorders had an incorrect FAT32 bit set. That caused Windows 10 to treat the file as EFS encrypted, and overwrite the RIFF header.

This script restores the first three parts of a RIFF/WAVE header:
     Position 0-3 "RIFF"
     Position 4-7 32 bit integer with file size
     Position 8-11 "WAVE"
Then, this script conditionally restores one more bit. The FMT header for a broadcast wave file, which is the file impacted here, inclues a "bext" chunk as the first chunk. The corruption appears to destroy the first two characters of that. So if we find _ _ x t then we'll replace with "bext".


You must already have the Windows 10 hotfix for the EFS FAT32 corruption in place to use this script. That hotfix makes the files readible by no longer treating them as encrypted.

## Use at your own risk. Always backup your files before doing any sort of processing on them

## Instructions

TO USE:
1. Make a copy of your wav files and put them into some easily-found directory. There can be subfolders. This script will process them.

2. Copy these two files (the .ps1 and .psm1) to the same directory

3. Open a Windows PowerShell command prompt. In Windows 10, just type "PowerShell" into the search box on the taskbar

4. Navigate to the directory where the files are. 

5. Type "recurs<tab>". When you hit tab, the statement will complete saving you a bit of typing.

6. Hit enter on the line that says .\Recursive-Fix-WAV-Files.ps1

7. Let the script process each file. Note any errors that come up

8. Report any failures to Pete through either twitter or, preferably through the github issues/discussion for this script.
