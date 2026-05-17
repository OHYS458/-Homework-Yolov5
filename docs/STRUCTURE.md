# 目录结构说明

本项目保持清晰、干净的布局：

- yolov5/ 存放上游代码的干净拷贝。
- data/ 存放用户提供的所有数据。
- data/videos/ 原始视频输入目录。
- data/images/ 抽帧图片输出目录。
- data/obb_dataset/ OBB 训练数据集输出。
- data/aabb_dataset/ OBB 转水平框后的训练数据集输出。
- configs/ 存放数据集配置文件。
- tools/ 辅助脚本目录，分为 steps/、pipelines/、tests/。
- runs/ 存放输出结果，建议不提交。
- runs/detect/ 自动标注与推理输出结果。
- runs/obb_detect/ OBB 推理输出结果。
- runs/logs/ 存放运行日志。

这样可以让文件更有条理，便于理解和维护。
