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


try:
    from PIL import Image

    def get_image_size(path):
        with Image.open(path) as img:
            return img.size

except ImportError:  # pragma: no cover
    try:
        import cv2

        def get_image_size(path):
            img = cv2.imread(str(path))
            if img is None:
                raise RuntimeError(f"无法读取图片: {path}")
            height, width = img.shape[:2]
            return width, height

    except ImportError as exc:  # pragma: no cover
        raise RuntimeError("缺少 Pillow 或 OpenCV，请先安装 Pillow 或 opencv-python") from exc


def find_image(images_dir, stem):
    for path in images_dir.glob(f"{stem}.*"):
        if path.is_file():
            return path
    return None


def convert_one_line(line, name_to_index, width, height):
    parts = line.strip().split()
    if len(parts) < 10:
        return None
    coords = list(map(float, parts[:8]))
    class_name = parts[8]
    if class_name not in name_to_index:
        return None

    xs = coords[0::2]
    ys = coords[1::2]
    x_min = max(min(xs), 0.0)
    x_max = min(max(xs), float(width))
    y_min = max(min(ys), 0.0)
    y_max = min(max(ys), float(height))

    if x_max <= x_min or y_max <= y_min:
        return None

    x_center = (x_min + x_max) / 2.0 / width
    y_center = (y_min + y_max) / 2.0 / height
    box_w = (x_max - x_min) / width
    box_h = (y_max - y_min) / height

    class_index = name_to_index[class_name]
    return f"{class_index} {x_center:.6f} {y_center:.6f} {box_w:.6f} {box_h:.6f}"


def convert_labels(labels_in, labels_out, images_in, classes):
    labels_in = Path(labels_in)
    labels_out = Path(labels_out)
    labels_out.mkdir(parents=True, exist_ok=True)
    name_to_index = {name: idx for idx, name in enumerate(classes)}

    for src_file in labels_in.glob("*.txt"):
        image_path = find_image(images_in, src_file.stem)
        if not image_path:
            print(f"[Skip] 找不到对应图片: {src_file.name}")
            continue

        width, height = get_image_size(image_path)
        out_lines = []
        for line in src_file.read_text(encoding="utf-8").splitlines():
            converted = convert_one_line(line, name_to_index, width, height)
            if converted:
                out_lines.append(converted)

        (labels_out / src_file.name).write_text("\n".join(out_lines) + ("\n" if out_lines else ""), encoding="utf-8")


def copy_images(images_in, images_out):
    images_out.mkdir(parents=True, exist_ok=True)
    for img_file in images_in.iterdir():
        if img_file.is_file():
            shutil.copy2(img_file, images_out / img_file.name)


def parse_args():
    parser = argparse.ArgumentParser(description="将 OBB 数据集转为标准 YOLOv5 水平框数据集")
    parser.add_argument("--dataset-root", default="Car Detection Model.v1i.yolov5-obb", help="原始数据集根目录")
    parser.add_argument("--out-dir", default="data/aabb_dataset", help="输出数据集目录")
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
        convert_labels(labels_in, labels_out, images_in, classes)


if __name__ == "__main__":
    main()
