# Fix Broadcast Wave File Corruption
PowerShell scripts to fix files corrupted by a very specific issue.

Files written by Sound Devices recorders had an incorrect FAT32 bit set. Windows 10 introduces the Encrypting File System (EFS) for removable FAT media. The reserved bit used by Sound Devices was also used by Microsoft to indicate whether or not a file is encrypted. Together, that caused Windows 10 to treat the file as EFS encrypted, and overwrite the RIFF header, thinking it was an encryption header. Prior to Windows 10, Microsoft did not use this bit, so Sound Devices testing would not have revealed any problem.

(NOTE that as of this writing a fix is now available in Windows 10. The fix does additional metadata checking before treating a file as encrypted. You'll find the fix in your updates as KB3093266, released on 2015-09-30)

This script restores the first three parts of a RIFF/WAVE header:

     Position 0-3 "RIFF"
     
     Position 4-7 32 bit integer with file size
     
     Position 8-11 "WAVE"
     
Then, this script conditionally restores one more bit. The FMT header for a broadcast wave file, which is the file impacted here, inclues a "bext" chunk as the first chunk. The corruption appears to destroy the first two characters of that. So if we find _ _ x t then we'll replace with "bext".


You must already have the Windows 10 hotfix for the EFS FAT32 corruption in place to use this script. That hotfix makes the files readible by no longer treating them as encrypted.

## Use at your own risk. Always backup your files before doing any sort of processing on them. This is not an official Microsoft product. It is just a tool to try to help out some folks who don't deserve to have their data lost.

## Instructions

### Enabling scripts on your system

If you're not a developer, your PC likely doesn't have scripting enabled. 

This script is not digitally signed, so to run it, you'll need to set teh execution policy to unrestricted. Start PowerShell as an administrator (In Windows 10, just type "PowerShell" into the search box on the taskbar, right-click the PowerShell icon and then choose "Run as administrator"). Then, at the PowerShell prompt, type:

     Set-ExecutionPolicy unrestricted

That setting allows you to run any PowerShell script you click on. Obviously, this can be a security hole for some folks. So, when you've finished the cleanup, you can set PowerShell to no longer allow you to run unsigned scripts from the Internet by typing:

     Set-ExecutionPolicy remotesigned

Or you can simply leave it as unrestricted, if you're not the type to click on other random malicious scripts from the Internet. (I have other music-focused scripts here on GitHub, for example, which require unrestricted to run.

More information here:
https://technet.microsoft.com/en-us/library/bb613481.aspx

### TO USE:

Use a Windows 10 PC, with the FAT32 EFS patch.

1. Make a copy of your wav files and put them into some easily-found directory. There can be subfolders. This script will process them.

2. Copy these two files (the .ps1 and .psm1) to the same directory

3. Open a Windows PowerShell command prompt. In Windows 10, just type "PowerShell" into the search box on the taskbar

4. Navigate to the directory where the files are. 

5. Type "recurs<tab>". When you hit tab, the statement will complete saving you a bit of typing.

6. Hit enter on the line that says .\Recursive-Fix-WAV-Files.ps1

7. Let the script process each file. Note any errors that come up

8. Report any failures to Pete through either twitter or, preferably through the github issues/discussion for this script.

## Useful tool

One tool I used to debug the corruption was a great HTML5 Hex editor. You can try it here: https://hexed.it/
