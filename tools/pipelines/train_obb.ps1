param(
    [int]$Img = 640,
    [int]$Batch = 16,
    [int]$Epochs = 50,
    [string]$Weights = "yolov5s.pt",
    [string]$Data = "configs\obb_data.yaml"
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$venv = Join-Path $projectRoot '.venv310'
$python = Join-Path $venv 'Scripts\python.exe'
$trainScript = Join-Path $projectRoot 'yolov5-obb\train.py'
$prepareScript = Join-Path $projectRoot 'tools\pipelines\prepare_obb_dataset.py'

if (-not (Test-Path $python)) {
    Write-Host "Python 3.10 venv not found: $venv"
    exit 1
}

if (-not (Test-Path $trainScript)) {
    Write-Host "yolov5-obb not found: $trainScript"
    Write-Host "Please place yolov5-obb/ at project root."
    exit 1
}

if (-not (Test-Path $prepareScript)) {
    Write-Host "prepare_obb_dataset.py not found: $prepareScript"
    exit 1
}

& $python $prepareScript

Push-Location (Split-Path -Parent $trainScript)
& $python $trainScript --img $Img --batch $Batch --epochs $Epochs --data (Join-Path $projectRoot $Data) --weights (Join-Path $projectRoot $Weights)
Pop-Location
