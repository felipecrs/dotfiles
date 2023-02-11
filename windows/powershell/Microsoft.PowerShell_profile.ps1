# Oh My Posh (https://github.com/JanDeDobbeleer/oh-my-posh)
# Installation: winget install JanDeDobbeleer.OhMyPosh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_lean.omp.json" | Invoke-Expression

# PSReadLine (https://github.com/PowerShell/PSReadLine)
# Installation: Install-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# WSL Interop (https://github.com/mikebattista/PowerShell-WSL-Interop)
# Installation: Install-Module WslInterop
Import-WslCommand "cat", "cp", "echo", "find", "grep", "head", "ls", "mv", "rm", "sed", "touch", "tree"

# Chocolatey (https://github.com/chocolatey/choco)
# Installation: https://chocolatey.org/install#individual
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
} else {
  Remove-Variable ChocolateyProfile
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

# gsudo (https://github.com/gerardog/gsudo)
# Installation: winget install gerardog.gsudo
# PSWindowsUpdate (https://github.com/mgajda83/PSWindowsUpdate)
# Installation: Install-Module PSWindowsUpdate
function Full-Upgrade {
  gsudo {
    Set-PSDebug -Trace 1
    choco upgrade all --yes
    winget upgrade --all
    Get-WindowsUpdate -Install -AcceptAll
  }
}

Clear-Host
