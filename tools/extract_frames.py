import argparse
import subprocess
from pathlib import Path


def extract_frames(input_path, out_dir, every, prefix, ext):
    out_dir.mkdir(parents=True, exist_ok=True)
    output_pattern = out_dir / f"{prefix}_%06d.{ext}"

    # select every N frames using frame index n
    vf = rf"select=not(mod(n\,{every}))"
    cmd = [
        "ffmpeg",
        "-hide_banner",
        "-y",
        "-i",
        str(input_path),
        "-vf",
        vf,
        "-fps_mode",
        "vfr",
        str(output_pattern),
    ]
    subprocess.run(cmd, check=True)


def parse_args():
    parser = argparse.ArgumentParser(description="按帧间隔从视频抽帧")
    parser.add_argument("--input", required=True, help="输入视频路径")
    parser.add_argument("--out-dir", required=True, help="输出图片目录")
    parser.add_argument("--every", type=int, default=5, help="每隔多少帧抽一张")
    parser.add_argument("--prefix", default="frame", help="输出文件名前缀")
    parser.add_argument("--ext", default="jpg", help="输出图片格式，例如 jpg 或 png")
    return parser.parse_args()


def main():
    args = parse_args()
    input_path = Path(args.input)
    out_dir = Path(args.out_dir)
    if not input_path.exists():
        raise FileNotFoundError(f"找不到输入文件: {input_path}")
    if args.every <= 0:
        raise ValueError("参数 --every 必须大于 0")

    extract_frames(input_path, out_dir, args.every, args.prefix, args.ext)


if __name__ == "__main__":
    main()
