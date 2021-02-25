
# Modules:
# Install-Module WslInterop -Force
# Install-Module PSReadLine -AllowPrerelease -Force
# Install-Module oh-my-posh -AllowPrerelease -Force

Clear-Host

Import-WslCommand "apt", "awk", "emacs", "grep", "head", "less", "ls", "rm", "mv", "cp", "man", "sed", "seq", "tail", "vim", "tree"

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
} else {
  Remove-Variable ChocolateyProfile
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PoshPrompt -Theme negligible
