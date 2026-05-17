# 错误总结与处理方案

本文记录在启动 LabelImg 过程中遇到的常见问题与解决方案，便于复盘与快速排查。

## 1. 无法识别 labelImg 命令

现象：
- 直接运行 labelImg 提示“无法将 labelImg 识别为命令”。

原因：
- 当前环境中没有可用的 labelImg 可执行入口，或安装在其他 Python 环境。

解决方案：
- 使用安装 LabelImg 的 Python 环境直接运行脚本入口：
  - .\.venv310\Scripts\pythonw.exe .\.venv310\Scripts\labelImg-script.py

## 2. Python 3.13 报 distutils 缺失

现象：
- ModuleNotFoundError: No module named 'distutils'

原因：
- Python 3.12+ 已移除 distutils，LabelImg 依赖该模块。

解决方案：
- 使用 Python 3.10/3.11 运行 LabelImg。
- 本项目已安装 Python 3.10 并建立 .venv310 作为专用环境。

## 3. labelImg 不能通过 -m 方式启动

现象：
- No module named labelImg.__main__; 'labelImg' is a package and cannot be directly executed

原因：
- LabelImg 不是以模块入口方式运行。

解决方案：
- 直接运行脚本入口或 exe：
  - .\.venv310\Scripts\pythonw.exe .\.venv310\Scripts\labelImg-script.py

## 4. Qt platform plugin 初始化失败

现象：
- 弹窗提示：This application failed to start because no Qt platform plugin could be initialized.

原因：
- Qt 插件路径无法正确解析，可能与中文路径或 Qt 插件定位失败有关。

解决方案：
- 使用 PyQt5 的实际安装路径设置插件环境变量后启动：
  - $pluginPath = .\.venv310\Scripts\python.exe -c "import os, PyQt5; print(os.path.join(os.path.dirname(PyQt5.__file__), 'Qt5', 'plugins'))"
  - $env:QT_PLUGIN_PATH = $pluginPath
  - $env:QT_QPA_PLATFORM_PLUGIN_PATH = "$pluginPath\platforms"
  - .\.venv310\Scripts\pythonw.exe .\.venv310\Scripts\labelImg-script.py

## 5. labelImg-script.py 编码异常

现象：
- Non-UTF-8 code starting with ...

原因：
- 脚本首行含非 ASCII 路径，未声明编码。

解决方案：
- 在脚本首部增加编码声明（本次已处理）：
  - # -*- coding: gbk -*-

## 6. 标注时绘图崩溃（float 传给 Qt）

现象：
- 打标或拖拽时直接闪退。
- 终端/日志出现 TypeError，提示 drawLine/drawRect 不接受 float。

原因：
- LabelImg 内部绘图函数传入了 float，但 PyQt5 需要 int。

解决方案（已在本机 .venv310 修复）：
- 将绘图坐标强制转换为 int：
  - libs/canvas.py 的 drawLine 与 drawRect 相关代码
  - labelImg/labelImg.py 的 scroll_request

说明：
- 以上修复位于 .venv310 中的第三方包，如果重装 labelImg 可能需要重复修补。

## 7. 自动标注标签加载失败（classes.txt 缺失）

现象：
- 选择 data/labels_auto 后无法显示标签，切换图片时崩溃。
- 日志提示找不到 classes.txt。

原因：
- LabelImg 读取 YOLO 标签时依赖 classes.txt，但自动标注输出只有 txt 标签。

解决方案：
- 在 data/labels_auto/ 下创建 classes.txt，内容为每行一个类别名：
  - truck
  - car
  - bus
  - bicycle

## 8. 自动标注带置信度导致解析失败

现象：
- 点击下一张图片崩溃。
- 日志提示 ValueError: too many values to unpack (expected 5)。

原因：
- 自动标注的 txt 行包含 6 列（多了置信度），而 LabelImg 只支持 5 列。

解决方案（已在本机 .venv310 修复）：
- 解析时忽略第 6 列：
  - libs/yolo_io.py 中只取前 5 个字段

---

## 推荐使用方式（本项目）

在 PowerShell 中执行以下命令启动 LabelImg：

$pluginPath = .\.venv310\Scripts\python.exe -c "import os, PyQt5; print(os.path.join(os.path.dirname(PyQt5.__file__), 'Qt5', 'plugins'))"
$env:QT_PLUGIN_PATH = $pluginPath
$env:QT_QPA_PLATFORM_PLUGIN_PATH = "$pluginPath\platforms"
.\.venv310\Scripts\pythonw.exe .\.venv310\Scripts\labelImg-script.py
