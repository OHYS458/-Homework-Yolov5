$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$venv = Join-Path $projectRoot '.venv310'
$python = Join-Path $venv 'Scripts\python.exe'
$script = Join-Path $venv 'Scripts\labelImg-script.py'
$logPath = Join-Path $projectRoot 'runs\logs\labelimg_crash.log'
$logOut = Join-Path $projectRoot 'runs\logs\labelimg_stdout.log'
$logErr = Join-Path $projectRoot 'runs\logs\labelimg_stderr.log'

if (-not (Test-Path $python)) {
    Write-Host "Python 3.10 venv not found: $venv"
    exit 1
}

if (-not (Test-Path $script)) {
    Write-Host "labelImg entry script not found: $script"
    exit 1
}

$pluginPath = & $python -c "import os, PyQt5; print(os.path.join(os.path.dirname(PyQt5.__file__), 'Qt5', 'plugins'))"
$env:QT_PLUGIN_PATH = $pluginPath
$env:QT_QPA_PLATFORM_PLUGIN_PATH = "$pluginPath\platforms"
$env:QT_DEBUG_PLUGINS = '1'

"[Start] $(Get-Date -Format s)" | Out-File -FilePath $logPath -Encoding utf8
"stdout -> $logOut" | Out-File -FilePath $logPath -Append
"stderr -> $logErr" | Out-File -FilePath $logPath -Append

$ErrorActionPreference = 'Continue'
Start-Process -FilePath $python -ArgumentList @($script) -WorkingDirectory $projectRoot -NoNewWindow `
    -RedirectStandardOutput $logOut -RedirectStandardError $logErr
