#!/usr/bin/env pwsh

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
    $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
    Exit
  }
}

Write-Host "--> Installing Chocolatey" -F Blue
# Create $PROFILE if does not exist
if(-Not (Test-Path -Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE
}
# Install Chocolatey using the official snippet
iwr -useb 'https://chocolatey.org/install.ps1' | iex
choco feature enable -n=allowGlobalConfirmation
choco feature enable -n=useRememberedArgumentsForUpgrades

Write-Host "--> Installing Git" -F Blue
choco install git --params "/NoShellIntegration /NoAutoCrlf"

Write-Host "--> Installing Scoop" -F Blue
iwr -useb 'https://get.scoop.sh' | iex
