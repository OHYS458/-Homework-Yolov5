#!/bin/bash

# 出错时立即退出
set -e

# 获取项目根目录 (相当于 PowerShell 的 Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
# 假设脚本存放在项目根目录的某个子目录的子目录中（例如：project/scripts/cleanup/clean.sh）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# 需要删除的路径列表
paths=(
    "data/slices"
    "data/images"
    "data/labels"
    "data/labels_yolo"
    "data/labels_auto"
    "data/labels_auto_obb"
    "data/aabb_dataset"
    "data/dataset_auto"
    "data/dataset"
    "runs/detect"
    "runs/obb_detect"
    "runs/logs"
    "yolov5/runs"
)

echo "This will delete generated data folders (videos are kept)."

# 遍历并删除文件夹
for rel in "${paths[@]}"; do
    full="$PROJECT_ROOT/$rel"
    if [ -d "$full" ]; then
        rm -rf "$full"
        echo "Removed: $rel"
    fi
done

# 需要重新创建的空文件夹列表
recreate=(
    "data/slices"
    "data/images"
    "data/labels"
    "data/labels_yolo"
    "data/labels_auto"
    "data/labels_auto_obb"
    "data/dataset"
    "runs/detect"
    "runs/obb_detect"
    "runs/logs"
    "yolov5/runs"
)

# 遍历并重建文件夹
for rel in "${recreate[@]}"; do
    full="$PROJECT_ROOT/$rel"
    if [ ! -d "$full" ]; then
        mkdir -p "$full"
    fi
done

echo "Done. User videos in data/videos are preserved."