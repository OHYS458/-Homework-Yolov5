import argparse
from pathlib import Path


def load_classes(classes_text, classes_file):
    if classes_text:
        return [c.strip() for c in classes_text.split(",") if c.strip()]
    if classes_file:
        path = Path(classes_file)
        if not path.exists():
            raise FileNotFoundError(f"找不到 classes 文件: {path}")
        return [c.strip() for c in path.read_text(encoding="utf-8").splitlines() if c.strip()]
    return []


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
    if not labels_in.exists():
        raise FileNotFoundError(f"找不到输入标签目录: {labels_in}")
    labels_out.mkdir(parents=True, exist_ok=True)

    name_to_index = {name: idx for idx, name in enumerate(classes)}
    if not name_to_index:
        raise ValueError("classes 不能为空，请提供 --classes 或 --classes-file")

    for src_file in labels_in.glob("*.txt"):
        out_lines = []
        for line in src_file.read_text(encoding="utf-8").splitlines():
            converted = convert_one_line(line, name_to_index)
            if converted:
                out_lines.append(converted)
        (labels_out / src_file.name).write_text("\n".join(out_lines) + ("\n" if out_lines else ""), encoding="utf-8")


def parse_args():
    parser = argparse.ArgumentParser(description="将 OBB labelTxt 转为 yolov5-obb 标签格式")
    parser.add_argument("--labels-in", required=True, help="输入 labelTxt 目录")
    parser.add_argument("--labels-out", required=True, help="输出 labels 目录")
    parser.add_argument("--classes", default="", help="类别列表，逗号分隔")
    parser.add_argument("--classes-file", default="", help="类别文件，每行一个")
    return parser.parse_args()


def main():
    args = parse_args()
    classes = load_classes(args.classes, args.classes_file)
    convert_labels(args.labels_in, args.labels_out, classes)


if __name__ == "__main__":
    main()
