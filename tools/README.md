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
