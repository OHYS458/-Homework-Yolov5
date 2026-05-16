# 待办清单

## 项目准备

- [ ] 下载 YOLOv5 源码（干净拷贝，无 git 历史）
- [ ] 将源码放入 yolov5/
- [ ] 确认项目结构与 docs/STRUCTURE.md 一致

## 数据流程

- [ ] 收集原始视频并放入 data/videos/
- [ ] （可选）切片后放入 data/slices/
- [ ] 抽帧到 data/images/
- [ ] 标注图片并将标签保存到 data/labels/
- [ ] 在 data/dataset/ 下建立数据集结构
- [ ] 在 configs/data.yaml 中填写类别名

## 训练与推理

- [ ] 使用 configs/data.yaml 训练 YOLOv5
- [ ] 验证并记录指标
- [ ] 对新视频进行推理

## 文档

- [ ] 用你的实际命令更新 docs/USAGE.md
- [ ] 记录数据集与类别说明
