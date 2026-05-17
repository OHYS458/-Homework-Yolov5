# 运行指南

本指南说明用户仅通过提供数据即可运行项目。

## 0. 一键完成作业（推荐）

你只需要执行两个脚本：

1) 一键切片-抽帧-自动打标-人工纠正（带环境检测与辅助下载）

powershell -ExecutionPolicy Bypass -File run_pipeline.ps1

脚本会自动：

- 检测 FFmpeg、Python 3.10、LabelImg
- 必要时打开下载页面
- 切片、抽帧、自动打标
- 打开 LabelImg 进行人工纠正

2) 一键训练

powershell -ExecutionPolicy Bypass -File run_train.ps1

## 1. OBB 训练与自动打标流程（可选）

说明：

- OBB 数据集是旋转框格式，建议使用 yolov5-obb 仓库进行训练与推理。
- 请将 yolov5-obb 放在项目根目录下：yolov5-obb/。
- Car Detection Model.v1i.yolov5-obb 的 labelTxt 需要先转换为 yolov5-obb 标签格式。

OBB 数据集准备：

python tools/pipelines/prepare_obb_dataset.py

准备完成后，训练配置文件为：configs/obb_data.yaml

OBB 训练（使用 yolov5-obb）：

powershell -ExecutionPolicy Bypass -File tools/pipelines/train_obb.ps1 -Epochs 50 -Batch 16 -Img 640 -Weights yolov5s.pt

转换标签（train/valid/test 各自执行一次）：

python tools/steps/convert_obb_labels.py --labels-in "Car Detection Model.v1i.yolov5-obb/train/labelTxt" --labels-out "data/labels_obb/train" --classes "Bicycle,Bus,Jeepney,Motorcycle,Multicab,SUV,Sedan,Truck,Van"

OBB 自动打标（使用 yolov5-obb 权重）：

python tools/pipelines/auto_label_from_video_obb.py --input "data/videos/交通视频素材.mp4" --frames-dir "data/images" --every 5 --weights "yolov5-obb/runs/train/exp/weights/best.pt" --labels-dir "data/labels_auto_obb"

## 2. 使用 OBB 数据集训练标准 YOLOv5（水平框）

说明：

- 将 OBB 旋转框转换为水平框，适配标准 YOLOv5。
- 输出数据集位置：data/aabb_dataset。

准备数据集：

python tools/pipelines/prepare_aabb_dataset.py

训练（在 yolov5/ 下运行）：

python train.py --img 640 --batch 16 --epochs 50 --data ../configs/aabb_data.yaml --weights yolov5s.pt

训练完成后，用标准自动打标脚本：

python tools/pipelines/auto_label_from_video.py --input "data/videos/交通视频素材.mp4" --frames-dir "data/images" --every 5 --weights "yolov5/runs/train/exp/weights/best.pt" --labels-dir "data/labels_auto"

运行后将 runs/detect/auto/labels 下的 txt 复制到 data/labels_auto/，再进行人工修正。

## 3. XML 转 YOLO 并构建数据集结构

如果 LabelImg 保存的是 VOC XML，需要先转换为 YOLO txt 并拆分训练/验证集：

python tools/steps/build_dataset.py --images-dir "data/images" --xml-dir "data/labels" --labels-out "data/labels_yolo" --dataset-dir "data/dataset" --classes "truck,car,bus,bicycle" --train-ratio 0.8

脚本会生成：

- data/labels_yolo/
- data/dataset/images/train
- data/dataset/images/val
- data/dataset/labels/train
- data/dataset/labels/val

完成后可进入训练步骤。

## 4. 创建数据集配置（人工步骤）

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

## 5. 训练

在 yolov5/ 文件夹中运行：

python train.py --img 640 --batch 16 --epochs 50 --data ../configs/data.yaml --weights yolov5s.pt

## 6. 推理

在 yolov5/ 文件夹中运行：

python detect.py --weights runs/train/exp/weights/best.pt --source ../data/videos/your_video.mp4

## 提示

- 保持数据与输出分离。
- 不要把上游 git 历史加入本仓库。
- 只提交你自己的项目文件。
