param(
    [int]$Img = 640,
    [int]$Batch = 16,
    [int]$Epochs = 50,
    [string]$Weights = "yolov5s.pt",
    [double]$TrainRatio = 0.8
)

# === 编码设置必须放在 param 块下方 ===
# 强制当前 PowerShell 标签页使用 UTF-8 编码，彻底解决中文提示词乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = 'Stop'

# === 交互式询问训练回合数 ===
$inputEpochs = Read-Host "请输入训练回合数 (Epochs) [默认: $Epochs]"
if (-not [string]::IsNullOrWhiteSpace($inputEpochs)) {
    # 使用正则表达式判断输入是否为纯数字
    if ($inputEpochs -match '^\d+$') {
        $Epochs = [int]$inputEpochs
    } else {
        Write-Warning "输入格式不正确（不是纯数字），将使用默认值: $Epochs"
    }
}
Write-Host "当前训练回合数设置为: $Epochs"
# ===============================================

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