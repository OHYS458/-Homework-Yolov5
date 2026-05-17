# YOLOv5 项目（作业）

这是一个干净、面向学生的 YOLOv5 项目模板。
它保持文件夹布局整洁，并避免包含上游的 git 历史。

## 目录结构

- yolov5/                上游 YOLOv5 代码（干净拷贝，无 git 历史）
- data/videos/           用户原始视频（输入）
- data/slices/           视频切片（手动或 AI 切片）
- data/images/           抽帧图像（用于标注）
- data/labels/           标注文件（XML 格式）
- data/labels_yolo/      标注文件（YOLO 格式）
- data/labels_auto/      自动标注结果（待人工修正）
- data/dataset/          训练/验证数据集结构
- configs/               数据集配置文件
- tools/                 辅助脚本（可选）
- runs/                  训练与推理输出
- runs/logs/             运行日志
- docs/                  项目文档

## 一键完成作业

### window运行shell脚本

你只需要执行两个脚本即可完成：

1) 一键切片-抽帧-自动打标-人工纠正（带环境检测与辅助下载）

powershell -ExecutionPolicy Bypass -File run_pipeline.ps1

2) 一键训练

powershell -ExecutionPolicy Bypass -File run_train.ps1

完整说明见 docs/USAGE.md。

### mac运行sh脚本

1) 一键切片-抽帧-自动打标-人工纠正（带环境检测与辅助下载）

bash run_pipeline.sh

2) 一键训练

bash run_train.sh