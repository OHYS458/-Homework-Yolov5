param(
    [string]$Video = "data/videos/交通视频素材.mp4",
    [int]$Every = 5,
    # [string]$Weights = "yolov5/runs/train/exp3/weights/best.pt",
    [string]$Weights = "yolov5s.pt",
    [string]$FramesDir = "data/images",
    [string]$SlicesDir = "data/slices"
)

$ErrorActionPreference = 'Stop'

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$DefaultYes = $true
    )
    $suffix = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }
    $answer = Read-Host "$Prompt $suffix"
    if ([string]::IsNullOrWhiteSpace($answer)) {
        return $DefaultYes
    }
    return $answer.Trim().ToLower().StartsWith('y')
}

$projectRoot = $PSScriptRoot
$venv = Join-Path $projectRoot '.venv310'
$python = Join-Path $venv 'Scripts\python.exe'
$labelImgScript = Join-Path $venv 'Scripts\labelImg-script.py'

Write-Host "[1/6] 检查 FFmpeg"
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "未检测到 ffmpeg，无法切片/抽帧。"
    if (Read-YesNo "是否打开 FFmpeg 下载页面？") {
        Start-Process "https://www.gyan.dev/ffmpeg/builds/"
    }
    throw "请先安装 ffmpeg 并配置到 PATH。"
}

Write-Host "[2/6] 检查 Python 3.10 环境"
if (-not (Test-Path $python)) {
    $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
    if ($pyLauncher) {
        Write-Host "未检测到 .venv310，开始创建虚拟环境..."
        & $pyLauncher.Source -3.10 -m venv $venv
    } else {
        Write-Host "未检测到 Python 3.10。"
        if (Read-YesNo "是否打开 Python 3.10 下载页面？") {
            Start-Process "https://www.python.org/downloads/release/python-31011/"
        }
        throw "请先安装 Python 3.10。"
    }
}

Write-Host "[3/6] 检查 LabelImg"
$labelImgOk = $false
if (Test-Path $labelImgScript) {
    try {
        & $python -c "import PyQt5, labelImg" | Out-Null
        $labelImgOk = $true
    } catch {
        $labelImgOk = $false
    }
}
if (-not $labelImgOk) {
    Write-Host "未检测到可用的 LabelImg，开始安装..."
    & $python -m pip install --upgrade pip
    & $python -m pip install labelImg PyQt5
}

$videoFull = Join-Path $projectRoot $Video
if (-not (Test-Path $videoFull)) {
    Write-Host "找不到视频文件: $videoFull"
    $videoDir = Join-Path $projectRoot 'data\videos'
    if (Test-Path $videoDir) {
        Write-Host "当前 data/videos 下的文件："
        Get-ChildItem -Path $videoDir | ForEach-Object { Write-Host "- $($_.Name)" }
    }
    throw "请确认视频已放入 data/videos/ 并保持文件名一致。"
}

$doSlice = Read-YesNo "是否需要先切片？" $false
$extracted = $false

if ($doSlice) {
    $sliceCount = Read-Host "请输入切片数量（默认 20）"
    if ([string]::IsNullOrWhiteSpace($sliceCount)) {
        $sliceCount = 20
    }
    $slicePrefix = Read-Host "请输入切片前缀（默认 traffic）"
    if ([string]::IsNullOrWhiteSpace($slicePrefix)) {
        $slicePrefix = "traffic"
    }

    & $python "tools/steps/slice_video.py" --input $Video --out-dir $SlicesDir --count $sliceCount --prefix $slicePrefix

    $sliceFull = Join-Path $projectRoot $SlicesDir
    $sliceFiles = Get-ChildItem -Path $sliceFull -Filter "*.mp4" -ErrorAction SilentlyContinue
    if (-not $sliceFiles) {
        throw "切片目录下未找到 mp4 文件: $sliceFull"
    }

    foreach ($slice in $sliceFiles) {
        $prefix = $slice.BaseName
        & $python "tools/steps/extract_frames.py" --input $slice.FullName --out-dir $FramesDir --every $Every --prefix $prefix
    }
    $extracted = $true
} else {
    & $python "tools/steps/extract_frames.py" --input $Video --out-dir $FramesDir --every $Every --prefix "frame"
    $extracted = $true
}

if (-not [string]::IsNullOrWhiteSpace($Weights)) {
    $weightsFull = Join-Path $projectRoot $Weights
    if (-not (Test-Path $weightsFull)) {
        throw "找不到权重文件: $weightsFull"
    }
}

Write-Host "[4/6] 开始自动打标"
$autoArgs = @(
    "tools/pipelines/auto_label_from_video.py",
    "--input", $Video,
    "--frames-dir", $FramesDir,
    "--every", $Every,
    "--weights", $Weights,
    "--labels-dir", "data/labels_auto",
    "--classes", "Bicycle,Bus,Jeepney,Motorcycle,Multicab,SUV,Sedan,Truck,Van"
)
if ($extracted) {
    $autoArgs += "--skip-extract"
}
& $python @autoArgs

Write-Host "[5/6] 打开 LabelImg 进行人工纠正"
Write-Host "请在 LabelImg 中打开图片目录：data/images"
Write-Host "保存目录设为：data/labels_auto"
& "tools/tests/start_labelimg.ps1"

Write-Host "[6/6] 完成。请在人工校正后运行训练脚本 run_train.ps1"