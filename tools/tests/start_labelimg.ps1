$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$venv = Join-Path $projectRoot '.venv310'
$python = Join-Path $venv 'Scripts\python.exe'
$pythonw = Join-Path $venv 'Scripts\pythonw.exe'
$script = Join-Path $venv 'Scripts\labelImg-script.py'

if (-not (Test-Path $python)) {
    Write-Host "Python 3.10 venv not found: $venv"
    Write-Host "Please create .venv310 and install labelImg."
    exit 1
}

if (-not (Test-Path $script)) {
    Write-Host "labelImg entry script not found: $script"
    Write-Host "Please ensure labelImg is installed in .venv310."
    exit 1
}

$pluginPath = & $python -c "import os, PyQt5; print(os.path.join(os.path.dirname(PyQt5.__file__), 'Qt5', 'plugins'))"
$env:QT_PLUGIN_PATH = $pluginPath
$env:QT_QPA_PLATFORM_PLUGIN_PATH = "$pluginPath\platforms"

& $pythonw $script
