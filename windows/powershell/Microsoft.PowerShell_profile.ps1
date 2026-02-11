# Oh My Posh (https://github.com/JanDeDobbeleer/oh-my-posh)
# Installation: winget install JanDeDobbeleer.OhMyPosh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_lean.omp.json" | Invoke-Expression

# PSReadLine (https://github.com/PowerShell/PSReadLine)
# Installation: Install-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# WSL Interop (https://github.com/mikebattista/PowerShell-WSL-Interop)
# Installation: Install-Module WslInterop -Force
Import-WslCommand "cat", "cp", "echo", "find", "grep", "head", "ls", "mv", "rm", "sed", "touch", "tree", "which"

# Chocolatey (https://github.com/chocolatey/choco)
# Installation: https://chocolatey.org/install#individual
if (Get-Command choco -ErrorAction SilentlyContinue) {
  Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
}

# WinGet (https://github.com/microsoft/winget-cli)
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function Reinstall-WinGet {
  curl.exe -fL "-#" -o "$env:USERPROFILE\Downloads\winget.msixbundle" "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
  Add-AppxPackage -Path "$env:USERPROFILE\Downloads\winget.msixbundle"
  Remove-Item -Force "$env:USERPROFILE\Downloads\winget.msixbundle"
}

#34de4b3d-13a8-4540-b76d-b9e8d3851756 PowerToys CommandNotFound module
if (Test-Path "C:\Program Files\PowerToys\WinGetCommandNotFound.psd1") {
  Import-Module "C:\Program Files\PowerToys\WinGetCommandNotFound.psd1"
}
#34de4b3d-13a8-4540-b76d-b9e8d3851756

function Refresh-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# gsudo (https://github.com/gerardog/gsudo)
# Installation: winget install gerardog.gsudo
# PSWindowsUpdate (https://github.com/mgajda83/PSWindowsUpdate)
# Installation: Install-Module PSWindowsUpdate -Force
function Full-Upgrade {
  gsudo {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
      Write-Host '-> Updating Chocolatey packages'
      choco upgrade all --yes
    }

    Write-Host '-> Updating WinGet packages'
    winget upgrade --all

    Write-Host '-> Updating Microsoft Store apps'
    store updates --apply

    Write-Host '-> Installing Windows updates'
    Get-WindowsUpdate -Install -AcceptAll

    Write-Host '-> Updating PowerShell modules'
    Update-Module -Confirm:$false
  }
}
