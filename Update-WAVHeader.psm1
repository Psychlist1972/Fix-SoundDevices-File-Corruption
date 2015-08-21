#
#
# Files written by Sound Devices recorders had an incorrect FAT32 bit set. That caused
# Windows 10 to treat the file as EFS encrypted, and overwrite the RIFF header.
# This script restores the first three parts of a RIFF/WAVE header:
#     Position 0-3 "RIFF"
#     Position 4-7 32 bit integer with file size
#     Position 8-11 "WAVE"
# Then, this script conditionally restores one more bit. The FMT header for a broadcast wave
# file, which is the file impacted here, inclues a "bext" chunk as the first chunk. The corruption
# appears to destroy the first two characters of that. So if we find _ _ x t then we'll replace with
# "bext".
#
#
# You must already have the Windows 10 hotfix for the EFS FAT32 corruption in place to use this
# script. That hotfix makes the files readible by no longer treating them as encrypted.
#
# !! Always backup your files before doing any sort of processing on them !!
#
#
# This Windows 10 PowerShell script operates on a single file
# To operate on multiple files, use standard powershell constructs to pipe the results through this
#
# Written 2015-08-20 
# Pete Brown
# See GitHub repo for MIT license and usage considerations
# https://github.com/Psychlist1972/Fix-SoundDevices-File-Corruption
#
# USE AT YOUR OWN RISK
#
#

function Update-WavHeader
{
	# single parameter is file name
	[CmdletBinding()]
	param(
		[parameter(Mandatory=$True)]
		[string]$FileName
	)

	Process
	{
		$extension = [System.IO.Path]::GetExtension($fileName).ToLower()


		# check extension to see if it's a wav file. If it's not a wav file, prompt to process

		[bool]$continue = $false

		Write-Debug "Filename: $fileName"
		Write-Debug "Extension: $extension"


		if ($extension -eq ".wav") 
		{
			$continue = $true
			Write-Debug "Extension matches. Continuing."
		} 
		else 
		{
			#prompt because extension is not .wav

			$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
			$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
			$choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)

			$caption = "Warning!"
			$message = "File extension '$extension' is not '.wav'. Continue? (Answer Yes only if you're sure this is a .wav file)"
			$result = $Host.UI.PromptForChoice($caption,$message,$choices,1)
			if($result -eq 0) { $continue = $true }
			if($result -eq 1) { $continue = $false }
		}



		# process the file. This involves rewriting the first four bytes as "RIFF"

		if ($continue) 
		{
			# process the file
			Write-Host "Processing file: $FileName" -ForegroundColor Green


			# get the file's size. We need this for the header

			$fileInfo = New-Object System.Io.FileInfo($FileName)
			$size = $fileInfo.Length
			Write-Debug "File size is $size bytes"

			# open the file for writing

			$filestream = New-Object System.Io.FileStream($FileName, [System.IO.FileMode]'Open', [System.IO.FileAccess]'ReadWrite')


			# RIFF Header

			[byte[]] $riffHeader = 0x52, 0x49, 0x46, 0x46
			$riffHeaderSize = 4
			$fileStream.Write($riffHeader, 0, $riffHeaderSize)



			# File size header. This is file size - 8 bytes according to WAV/RIFF spec

			[System.UInt32]$fileSizeForHeader = $size - 8

			Write-Debug "File size for header is $fileSizeForHeader"

			$fileSizeBuffer = [System.BitConverter]::GetBytes($fileSizeForHeader)
			$fileStream.Write($fileSizeBuffer, 0, 4)



			# The word WAVE in the header. This is the file type header. So far, these have been intact

			[byte[]] $waveHeader = 0x57, 0x41, 0x56, 0x45
			$fileStream.Write($waveHeader, 0, 4)



			# deal with that "bext" header only if we find "xt" in the right position

			$null = $fileStream.Seek(14, [System.IO.SeekOrigin]'Begin')
			$b = $fileStream.ReadByte()
			if ($b -eq 0x78)
			{
				$b = $fileStream.ReadByte()

				if ($b -eq 0x74)
				{
					Write-Host "File appears to be broadcast wave file. Repairing bext header." -ForegroundColor Cyan


					# back up to right spot
					$null = $fileStream.Seek(12, [System.IO.SeekOrigin]'Begin')

					[byte[]] $bext = 0x62, 0x65, 0x78, 0x74
					$fileStream.Write($bext, 0, 4)
				}
			}
			else
			{
				Write-Host "File does not appear to be a broadcast wave file. No bext format marker found. May still be a valid wav file." -ForegroundColor DarkCyan
			}


			$filestream.Flush();
			$fileStream.Close();

		} 
		else 
		{
			Write-Debug "Not processing the file."
			Write-Host "Processing aborted for file."
		}

	}


	
}


