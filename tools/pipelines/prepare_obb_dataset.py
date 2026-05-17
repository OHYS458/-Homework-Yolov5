import argparse
import shutil
from pathlib import Path


DEFAULT_CLASSES = [
    "Bicycle",
    "Bus",
    "Jeepney",
    "Motorcycle",
    "Multicab",
    "SUV",
    "Sedan",
    "Truck",
    "Van",
]


def convert_one_line(line, name_to_index):
    parts = line.strip().split()
    if len(parts) < 10:
        return None
    coords = parts[:8]
    class_name = parts[8]
    if class_name not in name_to_index:
        return None
    class_index = name_to_index[class_name]
    return " ".join([str(class_index)] + coords)


def convert_labels(labels_in, labels_out, classes):
    labels_in = Path(labels_in)
    labels_out = Path(labels_out)
    labels_out.mkdir(parents=True, exist_ok=True)
    name_to_index = {name: idx for idx, name in enumerate(classes)}

    for src_file in labels_in.glob("*.txt"):
        out_lines = []
        for line in src_file.read_text(encoding="utf-8").splitlines():
            converted = convert_one_line(line, name_to_index)
            if converted:
                out_lines.append(converted)
        (labels_out / src_file.name).write_text("\n".join(out_lines) + ("\n" if out_lines else ""), encoding="utf-8")


def copy_images(images_in, images_out):
    images_out.mkdir(parents=True, exist_ok=True)
    for img_file in images_in.iterdir():
        if img_file.is_file():
            shutil.copy2(img_file, images_out / img_file.name)


def parse_args():
    parser = argparse.ArgumentParser(description="准备 OBB 数据集目录结构")
    parser.add_argument("--dataset-root", default="Car Detection Model.v1i.yolov5-obb", help="原始数据集根目录")
    parser.add_argument("--out-dir", default="data/obb_dataset", help="输出数据集目录")
    parser.add_argument("--classes", default="", help="类别列表，逗号分隔")
    parser.add_argument("--skip-copy", action="store_true", help="跳过图片拷贝")
    return parser.parse_args()


def main():
    args = parse_args()
    root_dir = Path(__file__).resolve().parents[2]
    dataset_root = root_dir / args.dataset_root
    out_dir = root_dir / args.out_dir

    if not dataset_root.exists():
        raise FileNotFoundError(f"找不到数据集目录: {dataset_root}")

    classes = [c.strip() for c in args.classes.split(",") if c.strip()] or DEFAULT_CLASSES

    split_map = {"train": "train", "valid": "val", "test": "test"}
    for src_split, dst_split in split_map.items():
        images_in = dataset_root / src_split / "images"
        labels_in = dataset_root / src_split / "labelTxt"
        images_out = out_dir / "images" / dst_split
        labels_out = out_dir / "labels" / dst_split

        if not images_in.exists() or not labels_in.exists():
            raise FileNotFoundError(f"找不到子目录: {images_in} 或 {labels_in}")

        if not args.skip_copy:
            copy_images(images_in, images_out)
        convert_labels(labels_in, labels_out, classes)


if __name__ == "__main__":
    main()
