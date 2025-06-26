import os
import re
from pathlib import Path


def guess_type(example: str) -> str:
    example = example.strip()
    if not example:
        return "Unknown"
    if example.startswith("function"):
        return "Function"
    if example.startswith("{") and example.endswith("}"):
        return "Table"
    if example.lower() in {"true", "false"}:
        return "Boolean"
    if re.fullmatch(r"[-+]?[0-9]+", example):
        return "Number"
    if re.fullmatch(r"[-+]?[0-9]*\.[0-9]+", example):
        return "Number"
    if example.startswith("\"") or example.startswith("'"):
        return "String"
    if "Color(" in example:
        return "Color"
    return "Unknown"


def parse_blocks(text: str):
    pattern = r"--\[\[(.*?)\]\]"
    blocks = re.findall(pattern, text, flags=re.S)
    results = []
    for block in blocks:
        lines = [l.rstrip() for l in block.splitlines()]
        # trim empty lines
        while lines and lines[0].strip() == "":
            lines.pop(0)
        while lines and lines[-1].strip() == "":
            lines.pop()
        if not lines:
            continue
        if not any("Example Usage:" in l for l in lines):
            continue  # skip non-field blocks
        name = lines[0].strip()
        current = None
        fields = {}
        buf = []
        for line in lines[1:]:
            m = re.match(r"\s*([A-Za-z ]+):\s*$", line)
            if m:
                if current:
                    fields[current] = "\n".join(buf).strip()
                    buf = []
                current = m.group(1)
            else:
                buf.append(line.strip())
        if current:
            fields[current] = "\n".join(buf).strip()
        results.append({"name": name, "fields": fields})
    return results


def build_section(entry):
    name = entry["name"]
    fields = entry["fields"]
    example = fields.get("Example Usage", "").strip()
    desc = fields.get("Description", "").strip()
    var_type = fields.get("Type", "").strip()
    if not var_type:
        var_type = guess_type(example.splitlines()[0] if example else "")
    table = (
        "| **Variable**                                 | **Purpose**" +
        "                                                                                                     | **Type**   | **Example**                           |\n" +
        "|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|\n" +
        f"| `{name}`                                  | {desc} | `{var_type}`    | `{example}` |"
    )
    detailed = (
        f"#### 1. `{name}`\n\n" +
        "- **Purpose:**  \n" +
        f"    {desc}\n\n" +
        "- **Type:**  \n" +
        f"    `{var_type}`\n\n" +
        "- **Example Usage:" +
        "\n    ```lua\n" +
        "\n".join(f"{line}" for line in example.splitlines()) +
        "\n    ```\n"
    )
    section = (
        "---\n\n" +
        "### **Example**\n\n" +
        "```lua\n" +
        "\n".join(example.splitlines()) +
        "\n```\n\n" +
        "---\n\n" +
        "### **Key Variables Explained**\n\n" +
        table +
        "\n\n---\n\n" +
        "### **Detailed Descriptions**\n\n" +
        detailed +
        "\n---\n"
    )
    return section


def main():
    definitions_dir = Path("docs/definitions")
    out_base = Path("docs/docs/framework/definitions")
    out_base.mkdir(parents=True, exist_ok=True)
    for file in definitions_dir.glob("*.lua"):
        basename = file.stem
        prefix = basename.split("_")[0]
        out_path = out_base / f"{prefix}.md"
        text = file.read_text(encoding="utf-8")
        entries = parse_blocks(text)
        with open(out_path, "a", encoding="utf-8") as f:
            for entry in entries:
                section = build_section(entry)
                f.write(section + "\n")

if __name__ == "__main__":
    main()
