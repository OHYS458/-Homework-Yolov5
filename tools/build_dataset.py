import argparse
import random
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(description="Convert VOC XML to YOLO labels and split train/val.")
    parser.add_argument("--images-dir", required=True, help="Image directory")
    parser.add_argument("--xml-dir", required=True, help="VOC XML labels directory")
    parser.add_argument("--labels-out", required=True, help="Output YOLO labels directory")
    parser.add_argument("--dataset-dir", required=True, help="Dataset output directory")
    parser.add_argument("--classes", required=True, help="Comma-separated class names")
    parser.add_argument("--train-ratio", type=float, default=0.8, help="Train split ratio")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    return parser.parse_args()


def voc_to_yolo(xml_path, class_to_id, labels_out_dir):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    filename = root.findtext("filename") or ""
    size = root.find("size")
    if size is None:
        raise ValueError(f"Missing size in {xml_path}")
    width = int(size.findtext("width", "0"))
    height = int(size.findtext("height", "0"))
    if width <= 0 or height <= 0:
        raise ValueError(f"Invalid image size in {xml_path}")

    lines = []
    for obj in root.findall("object"):
        name = obj.findtext("name")
        if name not in class_to_id:
            continue
        bbox = obj.find("bndbox")
        if bbox is None:
            continue
        xmin = float(bbox.findtext("xmin", "0"))
        ymin = float(bbox.findtext("ymin", "0"))
        xmax = float(bbox.findtext("xmax", "0"))
        ymax = float(bbox.findtext("ymax", "0"))

        x_center = (xmin + xmax) / 2.0 / width
        y_center = (ymin + ymax) / 2.0 / height
        w = (xmax - xmin) / width
        h = (ymax - ymin) / height

        class_id = class_to_id[name]
        lines.append(f"{class_id} {x_center:.6f} {y_center:.6f} {w:.6f} {h:.6f}")

    labels_out_dir.mkdir(parents=True, exist_ok=True)
    label_path = labels_out_dir / (xml_path.stem + ".txt")
    label_path.write_text("\n".join(lines), encoding="utf-8")
    return filename


def main():
    args = parse_args()
    images_dir = Path(args.images_dir)
    xml_dir = Path(args.xml_dir)
    labels_out = Path(args.labels_out)
    dataset_dir = Path(args.dataset_dir)

    classes = [c.strip() for c in args.classes.split(",") if c.strip()]
    if not classes:
        raise ValueError("No classes provided")

    class_to_id = {name: idx for idx, name in enumerate(classes)}

    xml_files = sorted(xml_dir.glob("*.xml"))
    if not xml_files:
        raise FileNotFoundError(f"No XML files found in {xml_dir}")

    items = []
    for xml_path in xml_files:
        filename = voc_to_yolo(xml_path, class_to_id, labels_out)
        if filename:
            image_path = images_dir / filename
        else:
            image_path = images_dir / (xml_path.stem + ".jpg")
        if not image_path.exists():
            continue
        label_path = labels_out / (xml_path.stem + ".txt")
        items.append((image_path, label_path))

    if not items:
        raise FileNotFoundError("No matching image/label pairs found")

    random.seed(args.seed)
    random.shuffle(items)
    split_index = int(len(items) * args.train_ratio)
    train_items = items[:split_index]
    val_items = items[split_index:]

    train_img_dir = dataset_dir / "images" / "train"
    val_img_dir = dataset_dir / "images" / "val"
    train_lbl_dir = dataset_dir / "labels" / "train"
    val_lbl_dir = dataset_dir / "labels" / "val"

    for d in [train_img_dir, val_img_dir, train_lbl_dir, val_lbl_dir]:
        d.mkdir(parents=True, exist_ok=True)

    for img_path, lbl_path in train_items:
        shutil.copy2(img_path, train_img_dir / img_path.name)
        shutil.copy2(lbl_path, train_lbl_dir / lbl_path.name)

    for img_path, lbl_path in val_items:
        shutil.copy2(img_path, val_img_dir / img_path.name)
        shutil.copy2(lbl_path, val_lbl_dir / lbl_path.name)

    print(f"Classes: {classes}")
    print(f"Total: {len(items)}, Train: {len(train_items)}, Val: {len(val_items)}")
    print(f"Labels out: {labels_out}")
    print(f"Dataset: {dataset_dir}")


if __name__ == "__main__":
    main()
