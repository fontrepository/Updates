# MIT License (MIT) 

# Copyright © 2020 Charles Ray Shisler III
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Script preferences
$ProgressPreference = "SilentlyContinue"

# Required Variables
$ExeUrl = "https://go.microsoft.com/fwlink/?LinkID=799445"
$ExeDirectory = "C:\Windows\LTsvc\Win10"
$ExeName = "Windows10Upgrade.exe"
$ExePath = "$ExeDirectory\$ExeName"
$UpgradeVersion = 10
$UpgradeRelease = 2009
$MinimumSpace = 16

# Check if upgrade should proceed due to current version and release
Write-Host "Confirming that the device version and release numbers are conformant"
$CurrentVersion = [Version](Get-WmiObject -Class Win32_OperatingSystem).Version | Select-Object -ExpandProperty Major
$CurrentRelease = [int](Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
if ($CurrentVersion -ne $UpgradeVersion) {
    Write-Host "Device is not on Windows 10. Exiting.."
    exit 1
}
if ($CurrentRelease -ge $UpgradeRelease) {
    Write-Host "Current version $CurrentRelease meets or exceeds version $UpgradeRelease to upgrade to. Exiting.."
    exit 1
}

# Check if upgrade should proceed due to current amount of space free on system drive
Write-Host "Confirming that the device has enough space on the system drive"
$CurrentSpace = [Math]::Round((Get-WMIObject -Class Win32_Volume | 
    Where-Object {$_.DriveLetter -eq $env:SystemDrive} | 
    Select-Object -ExpandProperty FreeSpace) / 1GB)
if ($CurrentSpace -lt $MinimumSpace) {
    Write-Host "Device does not meet the space requirements to perform the upgrade. Exiting.."
    exit 1
}

# Create desired directory if it does not already exist (will not override existing dir)
Write-Host "Creating directory $ExeDirectory if it does not already exist"
[System.IO.Directory]::CreateDirectory($ExeDirectory) | Out-Null
Write-Host "Setting current working directory to $ExeDirectory"
Set-Location $ExeDirectory

Write-Host "Downloading Windows 10 Upgrade Assistant executable"
Invoke-WebRequest -Uri $ExeUrl -OutFile $ExePath

Write-Host "Starting Windows 10 Upgrade Assistant: $ExeDirectory\$ExeName"
Start-Process $ExeName -ArgumentList "/quietinstall /skipeula /auto upgrade"

