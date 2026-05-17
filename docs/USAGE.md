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

标注数量建议（用于第一次训练）：

- 至少标注 50 张用于快速试跑流程。
- 建议标注 100-200 张获得可用的初版模型。
- 之后可用该模型辅助自动标注，再人工修正。

## 4.1 自动标注（可选）

自动标注需要已有训练好的权重文件（例如 best.pt）。如果没有权重，无法生成自动标签。

常用参数说明：

- conf（置信度阈值）：模型认为“这是目标”的最低把握程度，数值越高越严格。
- iou（重叠度阈值）：用于去除重复框，数值越高越“保留更多框”。

推荐默认值（入门）：

- conf = 0.25
- iou = 0.45

自动标注结果建议存放位置：

- data/labels_auto/

自动标注命令（使用训练得到的 best.pt）：

python yolov5/detect.py --weights yolov5/runs/train/exp4/weights/best.pt --source data/images --save-txt --save-conf --project runs/detect --name auto

运行后将 runs/detect/auto/labels 下的 txt 复制到 data/labels_auto/，再进行人工修正。

## 5. XML 转 YOLO 并构建数据集结构

如果 LabelImg 保存的是 VOC XML，需要先转换为 YOLO txt 并拆分训练/验证集：

python tools/build_dataset.py --images-dir "data/images" --xml-dir "data/labels" --labels-out "data/labels_yolo" --dataset-dir "data/dataset" --classes "truck,car,bus,bicycle" --train-ratio 0.8

脚本会生成：

- data/labels_yolo/
- data/dataset/images/train
- data/dataset/images/val
- data/dataset/labels/train
- data/dataset/labels/val

完成后可进入训练步骤。

## 6. 创建数据集配置（人工步骤）

在 configs/data.yaml 中填写类别名与数据集路径。
示例：

- train: data/dataset/images/train
- val: data/dataset/images/val
- nc: 4
- names: ["truck", "car", "bus", "bicycle"]

如果路径包含中文，建议用盘符映射（例如 W:）以避免训练找不到数据：

subst W: "E:\大学\VScode\Projects\-Homework-Yolov5"

然后在 configs/data.yaml 中填写：

- train: W:/data/dataset/images/train
- val: W:/data/dataset/images/val

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
