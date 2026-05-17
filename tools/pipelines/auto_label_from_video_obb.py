import argparse
import subprocess
import sys
from pathlib import Path


def run_extract_frames(python_exe, script_path, input_path, out_dir, every, prefix, ext):
    cmd = [
        str(python_exe),
        str(script_path),
        "--input",
        str(input_path),
        "--out-dir",
        str(out_dir),
        "--every",
        str(every),
        "--prefix",
        prefix,
        "--ext",
        ext,
    ]
    subprocess.run(cmd, check=True)


def run_detect(python_exe, detect_script, weights, source_dir, project_dir, name, conf, iou):
    cmd = [
        str(python_exe),
        str(detect_script),
        "--weights",
        str(weights),
        "--source",
        str(source_dir),
        "--save-txt",
        "--project",
        str(project_dir),
        "--name",
        name,
        "--conf-thres",
        str(conf),
        "--iou-thres",
        str(iou),
    ]
    subprocess.run(cmd, check=True)


def clean_label_cols(src_dir, dst_dir, keep_cols):
    dst_dir.mkdir(parents=True, exist_ok=True)
    if not src_dir.exists():
        raise FileNotFoundError(f"找不到自动标注输出目录: {src_dir}")

    for txt_file in src_dir.glob("*.txt"):
        cleaned_lines = []
        for line in txt_file.read_text(encoding="utf-8").splitlines():
            parts = line.strip().split()
            if len(parts) < keep_cols:
                continue
            cleaned_lines.append(" ".join(parts[:keep_cols]))
        (dst_dir / txt_file.name).write_text("\n".join(cleaned_lines) + ("\n" if cleaned_lines else ""), encoding="utf-8")


def parse_args():
    parser = argparse.ArgumentParser(description="OBB 抽帧 + 自动打标总流程")
    parser.add_argument("--input", required=True, help="输入视频路径")
    parser.add_argument("--frames-dir", default="data/images", help="抽帧输出目录")
    parser.add_argument("--every", type=int, default=5, help="每隔多少帧抽一张")
    parser.add_argument("--prefix", default="frame", help="输出图片前缀")
    parser.add_argument("--ext", default="jpg", help="输出图片格式")
    parser.add_argument("--weights", required=True, help="用于自动打标的权重路径")
    parser.add_argument("--labels-dir", default="data/labels_auto_obb", help="自动标注输出目录")
    parser.add_argument("--project", default="runs/obb_detect", help="推理输出根目录")
    parser.add_argument("--name", default="auto", help="推理输出名称")
    parser.add_argument("--conf", type=float, default=0.25, help="置信度阈值")
    parser.add_argument("--iou", type=float, default=0.45, help="NMS IOU 阈值")
    parser.add_argument("--keep-cols", type=int, default=9, help="保留前几列（默认 OBB 9 列）")
    parser.add_argument("--skip-extract", action="store_true", help="跳过抽帧步骤")
    return parser.parse_args()


def main():
    args = parse_args()
    root_dir = Path(__file__).resolve().parents[2]
    tools_steps = root_dir / "tools" / "steps"
    extract_script = tools_steps / "extract_frames.py"
    detect_script = root_dir / "yolov5-obb" / "detect.py"

    input_path = Path(args.input)
    frames_dir = root_dir / args.frames_dir
    labels_dir = root_dir / args.labels_dir
    project_dir = root_dir / args.project
    weights_path = Path(args.weights)

    if not input_path.exists():
        raise FileNotFoundError(f"找不到输入视频: {input_path}")
    if not weights_path.exists():
        raise FileNotFoundError(f"找不到权重文件: {weights_path}")
    if not detect_script.exists():
        raise FileNotFoundError(f"找不到 detect.py: {detect_script}，请先放置 yolov5-obb 仓库")
    if not extract_script.exists():
        raise FileNotFoundError(f"找不到抽帧脚本: {extract_script}")

    if args.every <= 0:
        raise ValueError("参数 --every 必须大于 0")

    python_exe = Path(sys.executable)

    if not args.skip_extract:
        run_extract_frames(python_exe, extract_script, input_path, frames_dir, args.every, args.prefix, args.ext)

    run_detect(python_exe, detect_script, weights_path, frames_dir, project_dir, args.name, args.conf, args.iou)

    labels_src = project_dir / args.name / "labels"
    clean_label_cols(labels_src, labels_dir, args.keep_cols)


if __name__ == "__main__":
    main()
