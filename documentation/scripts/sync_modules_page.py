#!/usr/bin/env python3

import html
import json
from pathlib import Path


def render_modules_page(modules):
    table_lines = [
        "| Module | Description | Author | Download |",
        "| :--- | :--- | :--- | :--- |",
    ]

    for module in modules:
        name = html.escape(module["name"])
        description = html.escape(module.get("description") or "No description provided.")
        author = html.escape(module.get("author") or "Unknown")
        url = module["url"]
        module_id = module["moduleID"]
        download_url = f"https://github.com/LiliaFramework/Modules/raw/refs/heads/gh-pages/{module_id}.zip"

        name_link = f'[{name}]({url})'
        download_button = f'[Download]({download_url})'
        table_lines.append(
            f"| {name_link} | {description.replace('|', '\\|')} | {author.replace('|', '\\|')} | {download_button} |"
        )

    table = "\n".join(table_lines)

    return f"""# Modules

{table}
"""


def main():
    docs_root = Path(__file__).resolve().parent.parent / "docs"
    modules_path = docs_root / "versioning" / "modules.json"
    output_path = docs_root / "modules" / "index.md"

    modules = json.loads(modules_path.read_text(encoding="utf-8"))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(render_modules_page(modules), encoding="utf-8")
    print(f"Wrote module page to {output_path}")


if __name__ == "__main__":
    main()
