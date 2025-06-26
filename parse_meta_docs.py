import os
import re

def parse_blocks(text):
    pattern = r"--\[\[(.*?)\]\]"
    blocks = re.findall(pattern, text, flags=re.S)
    results = []
    for block in blocks:
        lines = block.splitlines()
        while lines and lines[0].strip() == "":
            lines.pop(0)
        while lines and lines[-1].strip() == "":
            lines.pop()
        if not lines:
            continue
        header = lines[0].strip()
        method = header.split(":")[-1].split("(")[0].strip()
        fields = {}
        current = "Description"
        buf = []
        for line in lines[1:]:
            if re.match(r"\s*[A-Za-z ][A-Za-z0-9 ]*:\s*$", line):
                if buf:
                    fields[current] = "\n".join(l.strip() for l in buf).rstrip()
                    buf = []
                current = line.strip()[:-1]
            else:
                buf.append(line)
        if buf:
            fields[current] = "\n".join(l.strip() for l in buf).rstrip()
        results.append((method, fields))
    return results

def to_markdown(method, fields):
    lines = []
    lines.append(f"## {method}\n")
    desc = fields.pop("Description", "")
    lines.append("**Description:**")
    lines.append(f"    {desc}\n")
    lines.append("---\n")
    params = fields.pop("Parameters", None)
    lines.append("### Parameters\n")
    param_lines = []
    if params:
        for p in params.splitlines():
            p = p.strip()
            if p:
                param_lines.append(p)
    if not param_lines:
        param_lines.append("none")
    for p in param_lines:
        lines.append(f"    * {p}")
    lines.append("")
    lines.append("---\n")

    returns = fields.pop("Returns", None)
    lines.append("### Returns\n")
    return_lines = []
    if returns:
        for r in returns.splitlines():
            r = r.strip()
            if r:
                return_lines.append(r)
    if not return_lines:
        return_lines.append("none")
    for r in return_lines:
        lines.append(f"    * {r}")
    lines.append("")
    lines.append("---\n")
    example = None
    extras = []
    for key, value in fields.items():
        if key.lower().startswith("example"):
            example = value
        else:
            extras.append((key, value))
    for key, value in extras:
        lines.append(f"**{key}:**")
        lines.append(f"    {value}\n")
        lines.append("---\n")
    if example:
        lines.append("### Example\n")
        lines.append("    ```lua")
        for line in example.splitlines():
            lines.append(f"    {line}")
        lines.append("    ```\n")
    return "\n".join(lines)

def main():
    meta_dir = os.path.join("gamemode", "core", "meta")
    out_dir = os.path.join("docs", "docs", "framework", "meta")
    os.makedirs(out_dir, exist_ok=True)
    for filename in os.listdir(meta_dir):
        if not filename.endswith(".lua"):
            continue
        prefix = filename.split("_")[0].split(".")[0]
        filepath = os.path.join(meta_dir, filename)
        text = open(filepath, "r", encoding="utf-8").read()
        blocks = parse_blocks(text)
        if not blocks:
            continue
        md_path = os.path.join(out_dir, f"{prefix}_meta.md")
        with open(md_path, "a", encoding="utf-8") as f:
            for method, fields in blocks:
                section = to_markdown(method, dict(fields))
                f.write(section + "\n")

if __name__ == "__main__":
    main()
