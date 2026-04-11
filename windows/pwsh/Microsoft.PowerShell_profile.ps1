function Refresh-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Reinstall-WinGet {
  curl.exe -fL "-#" -o "$env:USERPROFILE\Downloads\winget.msixbundle" "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
  Add-AppxPackage -Path "$env:USERPROFILE\Downloads\winget.msixbundle"
  Remove-Item -Force "$env:USERPROFILE\Downloads\winget.msixbundle"
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

# Uutils Coreutils (https://github.com/uutils/coreutils)
# Installation: winget install uutils.coreutils
foreach ($commandName in "cat", "cksum", "cp", "cut", "date", "df", "du", "echo", "env", "false", "head", "ln", "ls", "md5sum", "mkdir", "mktemp", "mv", "nproc", "printenv", "printf", "realpath", "rm", "sha256sum", "sha512sum", "sleep", "sort", "tail", "tee", "timeout", "touch", "tr", "true", "uname", "uniq", "wc", "whoami", "yes") {
  Remove-Alias $commandName -Scope Global -Force -ErrorAction Ignore
  Remove-Alias $commandName -Scope Local -Force -ErrorAction SilentlyContinue
}

# https://dev.to/ankitg12/getting-unix-tools-to-work-in-powershell-a-debugging-war-story-1ipl
function ls {
  $flags = ""; $paths = @()
  foreach ($a in $args) {
    if ($a -match '^-') { $flags += $a.TrimStart('-') } else { $paths += $a }
  }
  if ($paths.Count -eq 0) { $paths = @('.') }
  $showHidden = $flags -match 'a'; $longFormat = $flags -match 'l'
  $sortByTime = $flags -match 't'; $reverse = $flags -match 'r'
  foreach ($p in $paths) {
    $items = Get-ChildItem -Path $p -Force:$showHidden
    if ($sortByTime) { $items = $items | Sort-Object LastWriteTime -Descending:(!$reverse) }
    else { $items = $items | Sort-Object Name -Descending:$reverse }
    if ($longFormat) {
      $items | Select-Object Mode,
      @{N = 'Modified'; E = { $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm') } },
      @{N = 'Size'; E = { if ($_.PSIsContainer) { '<DIR>' }else { $_.Length } } }, Name
    }
    else { $items.Name }
  }
}

function cdr {
  param(
    [ArgumentCompleter({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $reposDir = "$env:USERPROFILE\repos"
        if (Test-Path $reposDir) {
          Get-ChildItem -Path $reposDir -Directory -Filter "$wordToComplete*" | Select-Object -ExpandProperty Name
        }
      })]
    [string]$repo = ""
  )
  Set-Location "$env:USERPROFILE\repos\$repo"
}

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

#34de4b3d-13a8-4540-b76d-b9e8d3851756 PowerToys CommandNotFound module
if (Test-Path "C:\Program Files\PowerToys\WinGetCommandNotFound.psd1") {
  Import-Module "C:\Program Files\PowerToys\WinGetCommandNotFound.psd1"
}
#34de4b3d-13a8-4540-b76d-b9e8d3851756

# PSReadLine (https://github.com/PowerShell/PSReadLine)
# Installation: Install-Module PSReadLine -Force
Import-Module PSReadline
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History

# Oh My Posh (https://github.com/JanDeDobbeleer/oh-my-posh)
# Installation: winget install JanDeDobbeleer.OhMyPosh
# Must be the last line of the profile
oh-my-posh init pwsh --config powerlevel10k_lean | Invoke-Expression
