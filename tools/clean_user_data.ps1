$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot

$paths = @(
    'data\slices',
    'data\images',
    'data\labels',
    'data\labels_yolo',
    'data\labels_auto',
    'data\dataset',
    'runs\detect',
    'runs\logs',
    'yolov5\runs'
)

Write-Host "This will delete generated data folders (videos are kept)."

foreach ($rel in $paths) {
    $full = Join-Path $projectRoot $rel
    if (Test-Path $full) {
        Remove-Item -Path $full -Recurse -Force
        Write-Host "Removed: $rel"
    }
}

# Recreate empty folders expected by the workflow
$recreate = @(
    'data\slices',
    'data\images',
    'data\labels',
    'data\labels_yolo',
    'data\labels_auto',
    'data\dataset',
    'runs\detect',
    'runs\logs',
    'yolov5\runs'
)

foreach ($rel in $recreate) {
    $full = Join-Path $projectRoot $rel
    if (-not (Test-Path $full)) {
        New-Item -ItemType Directory -Path $full | Out-Null
    }
}

Write-Host "Done. User videos in data\\videos are preserved."
