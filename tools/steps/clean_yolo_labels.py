import argparse
from pathlib import Path


def clean_labels(labels_dir, keep_cols):
    labels_dir = Path(labels_dir)
    if not labels_dir.exists():
        raise FileNotFoundError(f"找不到标签目录: {labels_dir}")

    for txt_file in labels_dir.glob("*.txt"):
        cleaned_lines = []
        for line in txt_file.read_text(encoding="utf-8").splitlines():
            parts = line.strip().split()
            if len(parts) < keep_cols:
                continue
            cleaned_lines.append(" ".join(parts[:keep_cols]))

        txt_file.write_text("\n".join(cleaned_lines) + ("\n" if cleaned_lines else ""), encoding="utf-8")


def parse_args():
    parser = argparse.ArgumentParser(description="清理 YOLO 标签列数，去除多余列")
    parser.add_argument("--labels-dir", required=True, help="标签目录")
    parser.add_argument("--keep-cols", type=int, default=5, help="保留前几列")
    return parser.parse_args()


def main():
    args = parse_args()
    if args.keep_cols <= 0:
        raise ValueError("参数 --keep-cols 必须大于 0")
    clean_labels(args.labels_dir, args.keep_cols)


if __name__ == "__main__":
    main()
