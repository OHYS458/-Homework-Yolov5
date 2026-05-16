import argparse
import math
import subprocess
from pathlib import Path


def run_cmd(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "命令执行失败")
    return result.stdout.strip()


def get_duration_seconds(input_path):
    cmd = [
        "ffprobe",
        "-v",
        "error",
        "-show_entries",
        "format=duration",
        "-of",
        "default=noprint_wrappers=1:nokey=1",
        str(input_path),
    ]
    output = run_cmd(cmd)
    return float(output)


def slice_video(input_path, out_dir, count, prefix):
    out_dir.mkdir(parents=True, exist_ok=True)
    duration = get_duration_seconds(input_path)
    if duration <= 0:
        raise ValueError("视频时长无效")

    segment = duration / count
    for i in range(count):
        start = i * segment
        length = segment if i < count - 1 else duration - start
        index = i + 1
        out_file = out_dir / f"{prefix}_{index:03d}.mp4"

        cmd = [
            "ffmpeg",
            "-hide_banner",
            "-y",
            "-ss",
            f"{start:.3f}",
            "-i",
            str(input_path),
            "-t",
            f"{length:.3f}",
            "-c",
            "copy",
            "-reset_timestamps",
            "1",
            str(out_file),
        ]
        subprocess.run(cmd, check=True)


def parse_args():
    parser = argparse.ArgumentParser(description="将视频按指定数量进行切片")
    parser.add_argument("--input", required=True, help="输入视频路径")
    parser.add_argument("--out-dir", required=True, help="输出切片目录")
    parser.add_argument("--count", type=int, required=True, help="切片数量")
    parser.add_argument("--prefix", default="slice", help="输出文件名前缀")
    return parser.parse_args()


def main():
    args = parse_args()
    input_path = Path(args.input)
    out_dir = Path(args.out_dir)
    if not input_path.exists():
        raise FileNotFoundError(f"找不到输入文件: {input_path}")
    if args.count <= 0:
        raise ValueError("切片数量必须大于 0")

    slice_video(input_path, out_dir, args.count, args.prefix)


if __name__ == "__main__":
    main()
