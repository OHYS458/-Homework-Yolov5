param(
    [int]$Img = 640,
    [int]$Batch = 16,
    [int]$Epochs = 50,
    [string]$Weights = "yolov5s.pt",
    [double]$TrainRatio = 0.8
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$venv = Join-Path $projectRoot '.venv310'
$python = Join-Path $venv 'Scripts\python.exe'
$trainScript = Join-Path $projectRoot 'yolov5\train.py'

if (-not (Test-Path $python)) {
    throw "未找到 .venv310，请先运行 run_pipeline.ps1 进行环境准备。"
}
if (-not (Test-Path $trainScript)) {
    throw "未找到 yolov5/train.py，请先放置 yolov5 代码到根目录。"
}

$imagesDir = Join-Path $projectRoot 'data\images'
$labelsDir = Join-Path $projectRoot 'data\labels_auto'
if (-not (Test-Path $imagesDir)) {
    throw "找不到抽帧图片目录: $imagesDir"
}
if (-not (Test-Path $labelsDir)) {
    throw "找不到自动标注目录: $labelsDir"
}

Write-Host "[1/2] 构建训练数据集（data/dataset_auto）"
& $python "tools/steps/build_dataset_from_yolo.py" --images-dir $imagesDir --labels-dir $labelsDir --dataset-dir "data/dataset_auto" --train-ratio $TrainRatio

Write-Host "[2/2] 开始训练"
Push-Location (Split-Path -Parent $trainScript)
& $python $trainScript --img $Img --batch $Batch --epochs $Epochs --data ../configs/labels_auto_data.yaml --weights (Join-Path $projectRoot $Weights)
Pop-Location
