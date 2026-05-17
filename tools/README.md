# 工具说明

可选的辅助脚本可放在此处。

## 视频切片脚本

脚本：slice_video.py

用途：将单个视频按指定数量切片，输出到指定目录。

使用方法：

python tools/slice_video.py --input "data/videos/交通视频素材.mp4" --out-dir "data/slices" --count 20 --prefix "traffic"

参数说明：

- --input：输入视频路径
- --out-dir：切片输出目录
- --count：切片数量
- --prefix：输出文件名前缀（可选）

## 抽帧脚本

脚本：extract_frames.py

用途：按帧间隔从视频抽帧，输出到指定目录。

使用方法（每 5 帧抽 1 张）：

python tools/extract_frames.py --input "data/videos/交通视频素材.mp4" --out-dir "data/images" --every 5 --prefix "traffic"

参数说明：

- --input：输入视频路径
- --out-dir：输出图片目录
- --every：每隔多少帧抽一张（默认 5）
- --prefix：输出文件名前缀（可选）
- --ext：输出图片格式（默认 jpg）

## LabelImg 启动脚本

脚本：start_labelimg.ps1

用途：一键启动 LabelImg，并自动设置 Qt 插件路径，避免常见的启动报错。

使用方法：

powershell -ExecutionPolicy Bypass -File tools/start_labelimg.ps1

说明：

- 依赖 .venv310 环境与 labelImg 安装。
- 仅用于启动，不写日志。

## LabelImg 启动与日志脚本

脚本：start_labelimg_console.ps1

用途：启动 LabelImg 并记录日志，便于定位闪退和插件问题。

使用方法：

powershell -ExecutionPolicy Bypass -File tools/start_labelimg_console.ps1

日志位置：

- runs/logs/labelimg_stdout.log
- runs/logs/labelimg_stderr.log
- runs/logs/labelimg_crash.log

## VOC 转 YOLO + 数据集拆分脚本

脚本：build_dataset.py

用途：

- 将 LabelImg 生成的 VOC XML 转成 YOLO txt
- 按比例拆分训练/验证集并生成 data/dataset 结构

使用方法（4 类，8:2 拆分）：

python tools/build_dataset.py --images-dir "data/images" --xml-dir "data/labels" --labels-out "data/labels_yolo" --dataset-dir "data/dataset" --classes "truck,car,bus,bicycle" --train-ratio 0.8

## 一键清理用户数据

脚本：clean_user_data.ps1

用途：

- 删除切片、抽帧、标注、自动标注、训练/推理输出等用户生成数据
- 保留 data/videos 中的原始视频

使用方法：

powershell -ExecutionPolicy Bypass -File tools/clean_user_data.ps1
