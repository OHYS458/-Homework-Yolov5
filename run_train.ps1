param(
    [int]$Img = 640,
    [int]$Batch = 16,
    [int]$Epochs = 50,
    [string]$Weights = "yolov5s.pt",
    [double]$TrainRatio = 0.8
)

$ErrorActionPreference = 'Stop'

# 使用当前脚本所在目录作为项目根目录
$projectRoot = $PSScriptRoot 
$venv = Join-Path $projectRoot '.venv310'
$python = Join-Path $venv 'Scripts\python.exe'
$trainScript = Join-Path $projectRoot 'yolov5\train.py'

if (-not (Test-Path $python)) {
    throw "Error: No .venv310 found. Please run run_pipeline.ps1 first."
}
if (-not (Test-Path $trainScript)) {
    throw "Error: No yolov5/train.py found. Please check your folder structure."
}

$imagesDir = Join-Path $projectRoot 'data\images'
$labelsDir = Join-Path $projectRoot 'data\labels_auto'
if (-not (Test-Path $imagesDir)) {
    throw "Error: Cannot find images dir: $imagesDir"
}
if (-not (Test-Path $labelsDir)) {
    throw "Error: Cannot find labels dir: $labelsDir"
}

Write-Host "[1/2] Building dataset (data/dataset_auto)..."
$buildScript = Join-Path $projectRoot "tools\steps\build_dataset_from_yolo.py"
& $python $buildScript --images-dir $imagesDir --labels-dir $labelsDir --dataset-dir (Join-Path $projectRoot "data/dataset_auto") --train-ratio $TrainRatio

Write-Host "[2/2] Starting training..."
Push-Location (Split-Path -Parent $trainScript)
& $python $trainScript --img $Img --batch $Batch --epochs $Epochs --data ../configs/labels_auto_data.yaml --weights (Join-Path $projectRoot $Weights)
Pop-Location