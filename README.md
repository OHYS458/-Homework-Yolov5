# YOLOv5 项目（作业）

这是一个干净、面向学生的 YOLOv5 项目模板。
它保持文件夹布局整洁，并避免包含上游的 git 历史。

## 目录结构

- yolov5/                上游 YOLOv5 代码（干净拷贝，无 git 历史）
- data/videos/           用户原始视频（输入）
- data/slices/           视频切片（手动或 AI 切片）
- data/images/           抽帧图像（用于标注）
- data/labels/           标注文件（YOLO 格式）
- data/dataset/          训练/验证数据集结构
- configs/               数据集配置文件
- tools/                 辅助脚本（可选）
- runs/                  训练与推理输出
- docs/                  项目文档

## 快速开始

1. 将视频放入 data/videos/。
2. 将视频切片到 data/slices/（如不需要可跳过）。
3. 抽帧到 data/images/。
4. 标注并将标签放入 data/labels/。
5. 在 data/dataset/ 下构建数据集结构。
6. 在 configs/data.yaml 中创建数据集配置。
7. 使用 YOLOv5 训练或推理。

完整说明见 docs/USAGE.md。
