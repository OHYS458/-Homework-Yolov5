# 工具说明

脚本按用途分组：

- tools/steps：单步骤脚本
- tools/pipelines：总执行脚本
- tools/tests：测试或排错脚本

## 视频切片脚本

脚本：tools/steps/slice_video.py

用途：将单个视频按指定数量切片，输出到指定目录。

使用方法：

python tools/steps/slice_video.py --input "data/videos/交通视频素材.mp4" --out-dir "data/slices" --count 20 --prefix "traffic"

参数说明：

- --input：输入视频路径
- --out-dir：切片输出目录
- --count：切片数量
- --prefix：输出文件名前缀（可选）

## 抽帧脚本

脚本：tools/steps/extract_frames.py

用途：按帧间隔从视频抽帧，输出到指定目录。

使用方法（每 5 帧抽 1 张）：

python tools/steps/extract_frames.py --input "data/videos/交通视频素材.mp4" --out-dir "data/images" --every 5 --prefix "traffic"

参数说明：

- --input：输入视频路径
- --out-dir：输出图片目录
- --every：每隔多少帧抽一张（默认 5）
- --prefix：输出文件名前缀（可选）
- --ext：输出图片格式（默认 jpg）

## LabelImg 启动脚本

脚本：tools/tests/start_labelimg.ps1

用途：一键启动 LabelImg，并自动设置 Qt 插件路径，避免常见的启动报错。

使用方法：

powershell -ExecutionPolicy Bypass -File tools/tests/start_labelimg.ps1

说明：

- 依赖 .venv310 环境与 labelImg 安装。
- 仅用于启动，不写日志。

## LabelImg 启动与日志脚本

脚本：tools/tests/start_labelimg_console.ps1

用途：启动 LabelImg 并记录日志，便于定位闪退和插件问题。

使用方法：

powershell -ExecutionPolicy Bypass -File tools/tests/start_labelimg_console.ps1

日志位置：

- runs/logs/labelimg_stdout.log
- runs/logs/labelimg_stderr.log
- runs/logs/labelimg_crash.log

## VOC 转 YOLO + 数据集拆分脚本

脚本：tools/steps/build_dataset.py

用途：

- 将 LabelImg 生成的 VOC XML 转成 YOLO txt
- 按比例拆分训练/验证集并生成 data/dataset 结构

使用方法（4 类，8:2 拆分）：

python tools/steps/build_dataset.py --images-dir "data/images" --xml-dir "data/labels" --labels-out "data/labels_yolo" --dataset-dir "data/dataset" --classes "truck,car,bus,bicycle" --train-ratio 0.8

## 一键清理用户数据

脚本：tools/steps/clean_user_data.ps1

用途：

- 删除切片、抽帧、标注、自动标注、训练/推理输出等用户生成数据
- 保留 data/videos 中的原始视频

使用方法：

powershell -ExecutionPolicy Bypass -File tools/steps/clean_user_data.ps1

## 清理 YOLO 标签多余列

脚本：tools/steps/clean_yolo_labels.py

用途：

- 去除自动标注标签中的多余列（比如置信度）
- 避免 LabelImg 读取时报错

使用方法：

python tools/steps/clean_yolo_labels.py --labels-dir "data/labels_auto" --keep-cols 5

## OBB 标签转换（labelTxt -> yolov5-obb）

脚本：tools/steps/convert_obb_labels.py

用途：

- 将 OBB labelTxt（8 点 + 类名 + 0）转换为 yolov5-obb 训练格式
- 输出格式：class_index + 8 点坐标

使用方法：

python tools/steps/convert_obb_labels.py --labels-in "Car Detection Model.v1i.yolov5-obb/train/labelTxt" --labels-out "data/labels_obb/train" --classes "Bicycle,Bus,Jeepney,Motorcycle,Multicab,SUV,Sedan,Truck,Van"

## OBB 抽帧 + 自动打标总流程

脚本：tools/pipelines/auto_label_from_video_obb.py

用途：

- 从视频抽帧
- 使用 yolov5-obb 进行自动打标
- 清理输出标签列数（默认保留 9 列）

使用方法：

python tools/pipelines/auto_label_from_video_obb.py --input "data/videos/交通视频素材.mp4" --frames-dir "data/images" --every 5 --weights "yolov5-obb/runs/train/exp/weights/best.pt" --labels-dir "data/labels_auto_obb"

## OBB 数据集准备

脚本：tools/pipelines/prepare_obb_dataset.py

用途：

- 拷贝图片到 data/obb_dataset/images
- 将 labelTxt 转为 yolov5-obb 标签，输出到 data/obb_dataset/labels

使用方法：

python tools/pipelines/prepare_obb_dataset.py

## OBB 数据集转标准 YOLOv5（水平框）

脚本：tools/pipelines/prepare_aabb_dataset.py

用途：

- 将 OBB labelTxt 转为标准 YOLOv5 水平框标签
- 输出到 data/aabb_dataset

使用方法：

python tools/pipelines/prepare_aabb_dataset.py

## OBB 训练脚本

脚本：tools/pipelines/train_obb.ps1

用途：

- 调用 yolov5-obb 进行训练

使用方法：

powershell -ExecutionPolicy Bypass -File tools/pipelines/train_obb.ps1 -Epochs 50 -Batch 16 -Img 640 -Weights yolov5s.pt

## 抽帧 + 自动打标总流程

脚本：tools/pipelines/auto_label_from_video.py

用途：

- 从视频抽帧
- 调用 YOLOv5 进行自动打标
- 复制并清洗标签（去除多余置信度列）

使用方法：

python tools/pipelines/auto_label_from_video.py --input "data/videos/交通视频素材.mp4" --frames-dir "data/images" --every 5 --weights "yolov5/runs/train/exp/weights/best.pt" --labels-dir "data/labels_auto" --classes "Bicycle,Bus,Jeepney,Motorcycle,Multicab,SUV,Sedan,Truck,Van"
