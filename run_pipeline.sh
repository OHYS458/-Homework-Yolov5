#!/bin/bash

# 参数默认值
VIDEO="data/videos/交通视频素材.mp4"
EVERY=5
WEIGHTS="yolov5s.pt"
FRAMES_DIR="data/images"
SLICES_DIR="data/slices"

# 遇到错误时停止执行
set -e

# 获取脚本所在目录的绝对路径
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$PROJECT_ROOT/.venv310"
PYTHON="$VENV/bin/python"
LABELIMG_SCRIPT="$VENV/bin/labelImg"

# 读取 Yes/No 的函数
read_yes_no() {
    local prompt="$1"
    local default_yes="${2:-true}"
    local suffix
    
    if [ "$default_yes" = true ]; then
        suffix="[Y/n]"
    else
        suffix="[y/N]"
    fi
    
    read -p "$prompt $suffix " answer
    
    if [ -z "$answer" ]; then
        return $([ "$default_yes" = true ] && echo 0 || echo 1)
    fi
    
    # 转换为小写并检查是否以 'y' 开头
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    if [[ "$answer" =~ ^y ]]; then
        return 0
    else
        return 1
    fi
}

echo "[1/6] 检查 FFmpeg"
if ! command -v ffmpeg &> /dev/null; then
    echo "未检测到 ffmpeg，无法切片/抽帧。"
    if read_yes_no "是否打开 FFmpeg 下载页面？"; then
        # Linux 下使用 xdg-open 打开网页，macOS 可以改为 open
        xdg-open "https://www.gyan.dev/ffmpeg/builds/" || open "https://www.gyan.dev/ffmpeg/builds/" 2>/dev/null || true
    fi
    echo "错误：请先安装 ffmpeg 并配置到 PATH。" >&2
    exit 1
fi

echo "[2/6] 检查 Python 3.10 环境"
if [ ! -f "$PYTHON" ]; then
    if command -v python3.10 &> /dev/null; then
        echo "未检测到 .venv310，开始创建虚拟环境..."
        python3.10 -m venv "$VENV"
    else
        echo "未检测到 Python 3.10。"
        if read_yes_no "是否打开 Python 3.10 下载页面？"; then
            xdg-open "https://www.python.org/downloads/release/python-31011/" || open "https://www.python.org/downloads/release/python-31011/" 2>/dev/null || true
        fi
        echo "错误：请先安装 Python 3.10。" >&2
        exit 1
    fi
fi

echo "[3/6] 检查 LabelImg"
LABELIMG_OK=false
if [ -f "$LABELIMG_SCRIPT" ]; then
    if "$PYTHON" -c "import PyQt5, labelImg" &> /dev/null; then
        LABELIMG_OK=true
    fi
fi

if [ "$LABELIMG_OK" = false ]; then
    echo "未检测到可用的 LabelImg，开始安装..."
    "$PYTHON" -m pip install --upgrade pip
    "$PYTHON" -m pip install labelImg PyQt5
fi

VIDEO_FULL="$PROJECT_ROOT/$VIDEO"
if [ ! -f "$VIDEO_FULL" ]; then
    echo "找不到视频文件: $VIDEO_FULL"
    VIDEO_DIR="$PROJECT_ROOT/data/videos"
    if [ -d "$VIDEO_DIR" ]; then
        echo "当前 data/videos 下的文件："
        for file in "$VIDEO_DIR"/*; do
            if [ -f "$file" ]; then
                echo "- $(basename "$file")"
            fi
        done
    fi
    echo "错误：请确认视频已放入 data/videos/ 并保持文件名一致。" >&2
    exit 1
fi

EXTRACTED=false
if read_yes_no "是否需要先切片？" false; then
    read -p "请输入切片数量（默认 20）：" SLICE_COUNT
    [ -z "$SLICE_COUNT" ] && SLICE_COUNT=20
    
    read -p "请输入切片前缀（默认 traffic）：" SLICE_PREFIX
    [ -z "$SLICE_PREFIX" ] && SLICE_PREFIX="traffic"

    "$PYTHON" "tools/steps/slice_video.py" --input "$VIDEO" --out-dir "$SLICES_DIR" --count "$SLICE_COUNT" --prefix "$SLICE_PREFIX"

    SLICE_FULL="$PROJECT_ROOT/$SLICES_DIR"
    # 检查是否存在 mp4 文件
    if [ ! -d "$SLICE_FULL" ] || [ -z "$(ls -A "$SLICE_FULL"/*.mp4 2>/dev/null)" ]; then
        echo "错误：切片目录下未找到 mp4 文件: $SLICE_FULL" >&2
        exit 1
    fi

    for slice in "$SLICE_FULL"/*.mp4; do
        [ -e "$slice" ] || continue
        basename=$(basename "$slice" .mp4)
        "$PYTHON" "tools/steps/extract_frames.py" --input "$slice" --out-dir "$FRAMES_DIR" --every "$EVERY" --prefix "$basename"
    done
    EXTRACTED=true
else
    "$PYTHON" "tools/steps/extract_frames.py" --input "$VIDEO" --out-dir "$FRAMES_DIR" --every "$EVERY" --prefix "frame"
    EXTRACTED=true
fi

if [ -not -z "$WEIGHTS" ]; then
    WEIGHTS_FULL="$PROJECT_ROOT/$WEIGHTS"
    if [ ! -f "$WEIGHTS_FULL" ]; then
        echo "错误：找不到权重文件: $WEIGHTS_FULL" >&2
        exit 1
    fi
fi

echo "[4/6] 开始自动打标"
AUTO_ARGS=(
    "tools/pipelines/auto_label_from_video.py"
    "--input" "$VIDEO"
    "--frames-dir" "$FRAMES_DIR"
    "--every" "$EVERY"
    "--weights" "$WEIGHTS"
    "--labels-dir" "data/labels_auto"
    "--classes" "Bicycle,Bus,Jeepney,Motorcycle,Multicab,SUV,Sedan,Truck,Van"
)

if [ "$EXTRACTED" = true ]; then
    AUTO_ARGS+=("--skip-extract")
fi

"$PYTHON" "${AUTO_ARGS[@]}"

echo "[5/6] 打开 LabelImg 进行人工纠正"
echo "请在 LabelImg 中打开图片目录：data/images"
echo "保存目录设为：data/labels_auto"

# 运行对应的 shell 脚本
if [ -f "tools/tests/start_labelimg.sh" ]; then
    bash "tools/tests/start_labelimg.sh"
else
    echo "提示：未找到 tools/tests/start_labelimg.sh，请手动启动 labelImg。"
fi

echo "[6/6] 完成。请在人工校正后运行训练脚本 run_train.sh"