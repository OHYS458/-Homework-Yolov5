import argparse
import random
import shutil
from pathlib import Path


def collect_pairs(images_dir, labels_dir):
    pairs = []
    for img_file in images_dir.iterdir():
        if not img_file.is_file():
            continue
        label_file = labels_dir / f"{img_file.stem}.txt"
        if label_file.exists():
            pairs.append((img_file, label_file))
    return pairs


def copy_split(pairs, images_out, labels_out):
    images_out.mkdir(parents=True, exist_ok=True)
    labels_out.mkdir(parents=True, exist_ok=True)
    for img_file, label_file in pairs:
        shutil.copy2(img_file, images_out / img_file.name)
        shutil.copy2(label_file, labels_out / label_file.name)


def parse_args():
    parser = argparse.ArgumentParser(description="从 YOLO 标签构建数据集并拆分")
    parser.add_argument("--images-dir", required=True, help="图片目录")
    parser.add_argument("--labels-dir", required=True, help="YOLO 标签目录")
    parser.add_argument("--dataset-dir", required=True, help="输出数据集目录")
    parser.add_argument("--train-ratio", type=float, default=0.8, help="训练集比例")
    parser.add_argument("--seed", type=int, default=42, help="随机种子")
    return parser.parse_args()


def main():
    args = parse_args()
    images_dir = Path(args.images_dir)
    labels_dir = Path(args.labels_dir)
    dataset_dir = Path(args.dataset_dir)

    if not images_dir.exists():
        raise FileNotFoundError(f"找不到图片目录: {images_dir}")
    if not labels_dir.exists():
        raise FileNotFoundError(f"找不到标签目录: {labels_dir}")

    pairs = collect_pairs(images_dir, labels_dir)
    if not pairs:
        raise RuntimeError("未找到可用的图片/标签对")

    random.seed(args.seed)
    random.shuffle(pairs)

    split_idx = int(len(pairs) * args.train_ratio)
    train_pairs = pairs[:split_idx]
    val_pairs = pairs[split_idx:]

    copy_split(train_pairs, dataset_dir / "images" / "train", dataset_dir / "labels" / "train")
    copy_split(val_pairs, dataset_dir / "images" / "val", dataset_dir / "labels" / "val")


if __name__ == "__main__":
    main()
