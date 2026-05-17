#!/bin/bash

# 参数默认值
IMG=640
BATCH=16
EPOCHS=5
WEIGHTS="yolov5s.pt"
TRAIN_RATIO=0.8

# 遇到错误时停止执行
set -e

# === 交互式询问训练回合数 ===
read -p "请输入训练回合数 (Epochs) [默认: $EPOCHS]: " INPUT_EPOCHS
# 如果用户输入为空，则保留默认值，否则赋值新值
EPOCHS=${INPUT_EPOCHS:-$EPOCHS}
echo "当前训练回合数设置为: $EPOCHS"
# ==================================

# 获取脚本所在目录的绝对路径
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$PROJECT_ROOT/.venv310"
PYTHON="$VENV/bin/python"
TRAIN_SCRIPT="$PROJECT_ROOT/yolov5/train.py"

if [ ! -f "$PYTHON" ]; then
    echo "Error: No .venv310 found. Please run run_pipeline.sh first." >&2
    exit 1
fi

if [ ! -f "$TRAIN_SCRIPT" ]; then
    echo "Error: No yolov5/train.py found. Please check your folder structure." >&2
    exit 1
fi

IMAGES_DIR="$PROJECT_ROOT/data/images"
LABELS_DIR="$PROJECT_ROOT/data/labels_auto"

if [ ! -d "$IMAGES_DIR" ]; then
    echo "Error: Cannot find images dir: $IMAGES_DIR" >&2
    exit 1
fi

if [ ! -d "$LABELS_DIR" ]; then
    echo "Error: Cannot find labels dir: $LABELS_DIR" >&2
    exit 1
fi

echo "[1/2] Building dataset (data/dataset_auto)..."
BUILD_SCRIPT="$PROJECT_ROOT/tools/steps/build_dataset_from_yolo.py"
"$PYTHON" "$BUILD_SCRIPT" --images-dir "$IMAGES_DIR" --labels-dir "$LABELS_DIR" --dataset-dir "$PROJECT_ROOT/data/dataset_auto" --train-ratio "$TRAIN_RATIO"

echo "[2/2] Starting training..."
# 切换到 yolov5 目录
cd "$(dirname "$TRAIN_SCRIPT")"
"$PYTHON" "train.py" --img "$IMG" --batch "$BATCH" --epochs "$EPOCHS" --data ../configs/labels_auto_data.yaml --weights "$PROJECT_ROOT/$WEIGHTS"
# 切回原来的目录
cd - > /dev/null