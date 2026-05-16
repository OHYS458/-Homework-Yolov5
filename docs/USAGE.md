# 运行指南

本指南说明用户仅通过提供数据即可运行项目。

## 0. 准备 YOLOv5 代码（干净拷贝）

- 从官方开源发布页下载 YOLOv5 源码。
- 解压后放入 yolov5/ 文件夹。
- 不要保留 .git/ 文件夹或任何 git 历史文件。

## 1. 放入视频

- 将原始视频放入 data/videos/。

## 2. 视频切片（可选）

- 如需切片，将片段放入 data/slices/。
- 可使用切片工具或手动处理。

如果使用内置脚本切片（先切片再抽帧）：

python tools/slice_video.py --input "data/videos/交通视频素材.mp4" --out-dir "data/slices" --count 20 --prefix "traffic"

## 3. 抽帧

- 从视频或切片中抽帧到 data/images/。
- 保持统一的命名规则。

如果从原始视频抽帧（每 5 帧 1 张）：

python tools/extract_frames.py --input "data/videos/交通视频素材.mp4" --out-dir "data/images" --every 5 --prefix "traffic"

如果从切片视频抽帧（示例，需替换输入文件）：

python tools/extract_frames.py --input "data/slices/traffic_001.mp4" --out-dir "data/images" --every 5 --prefix "traffic"

## 4. 数据标注（人工步骤）

- 使用标注工具生成 YOLO 格式标签文件。
- 将标签文件放入 data/labels/。

LabelImg 启动方式（推荐 .venv310 环境）：

$pluginPath = .\.venv310\Scripts\python.exe -c "import os, PyQt5; print(os.path.join(os.path.dirname(PyQt5.__file__), 'Qt5', 'plugins'))"
$env:QT_PLUGIN_PATH = $pluginPath
$env:QT_QPA_PLATFORM_PLUGIN_PATH = "$pluginPath\platforms"
.\.venv310\Scripts\pythonw.exe .\.venv310\Scripts\labelImg-script.py

LabelImg 使用步骤：

- 打开图片目录：data/images/
- 设置保存目录：data/labels/
- 保存格式选择：YOLO
- 完成框选后保存，生成同名 .txt 标签文件

## 5. 构建数据集结构（人工步骤）

使用标准 YOLOv5 目录结构，例如：

- data/dataset/
  - images/
    - train/
    - val/
  - labels/
    - train/
    - val/

将 data/images/ 与 data/labels/ 中的文件移动或复制到上述数据集目录。

## 6. 创建数据集配置（人工步骤）

在 configs/data.yaml 中填写类别名与数据集路径。
示例：

- train: data/dataset/images/train
- val: data/dataset/images/val
- nc: 1
- names: ["类别名"]

## 7. 训练

在 yolov5/ 文件夹中运行：

python train.py --img 640 --batch 16 --epochs 50 --data ../configs/data.yaml --weights yolov5s.pt

## 8. 推理

在 yolov5/ 文件夹中运行：

python detect.py --weights runs/train/exp/weights/best.pt --source ../data/videos/your_video.mp4

## 提示

- 保持数据与输出分离。
- 不要把上游 git 历史加入本仓库。
- 只提交你自己的项目文件。
