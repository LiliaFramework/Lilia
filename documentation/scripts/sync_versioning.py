#!/usr/bin/env python3

import json
import re
import sys
import urllib.request
from io import BytesIO
from pathlib import Path
from zipfile import ZipFile


MODULES_BRANCH = "main"
MODULES_TREE_URL = "https://github.com/LiliaFramework/Modules/tree/main"
MODULES_ARCHIVE_URL = f"https://codeload.github.com/LiliaFramework/Modules/zip/refs/heads/{MODULES_BRANCH}"
USER_AGENT = "LiliaDocumentationVersioningSync/1.0"


def fetch_bytes(url):
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request) as response:
        return response.read()


def extract_lua_value(content, field_names):
    for field_name in field_names:
        pattern = re.compile(rf"MODULE\.{re.escape(field_name)}\s*=\s*(.+)")
        match = pattern.search(content)
        if not match:
            continue

        raw_value = match.group(1).strip().rstrip(",")
        if raw_value.startswith('"') and raw_value.endswith('"'):
            return raw_value[1:-1]
        if raw_value.startswith("'") and raw_value.endswith("'"):
            return raw_value[1:-1]
        return raw_value
    return ""


def build_module_entry(module_id, content):
    name = extract_lua_value(content, ("name", "Name")) or module_id.replace("_", " ").title()
    description = extract_lua_value(content, ("desc", "description", "Desc"))
    author = extract_lua_value(content, ("author", "Author"))
    version_id = extract_lua_value(content, ("versionID",))
    version = extract_lua_value(content, ("version", "Version"))

    entry = {
        "moduleID": module_id,
        "name": name,
        "description": description,
        "author": author,
        "versionID": version_id,
        "version": version,
        "url": f"{MODULES_TREE_URL}/{module_id}",
    }
    return entry


def iter_module_lua_files_from_archive():
    archive_bytes = fetch_bytes(MODULES_ARCHIVE_URL)

    with ZipFile(BytesIO(archive_bytes)) as archive:
        for archive_name in archive.namelist():
            path = Path(archive_name)
            if len(path.parts) != 3 or path.name != "module.lua":
                continue

            yield path.parts[1], archive.read(archive_name).decode("utf-8-sig")


def iter_module_lua_files_from_directory(source_dir):
    for module_file in sorted(Path(source_dir).glob("*/module.lua")):
        yield module_file.parent.name, module_file.read_text(encoding="utf-8-sig")


def collect_modules(source_dir=None):
    modules = []

    if source_dir:
        module_files = iter_module_lua_files_from_directory(source_dir)
    else:
        module_files = iter_module_lua_files_from_archive()

    for module_id, content in module_files:
        module_entry = build_module_entry(module_id, content)
        if module_entry["versionID"]:
            modules.append(module_entry)

    modules.sort(key=lambda item: item["name"].lower())
    return modules


def write_modules_versioning_file(output_path, source_dir=None):
    modules = collect_modules(source_dir=source_dir)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(modules, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(modules)} modules to {output_path}")


def main():
    docs_root = Path(__file__).resolve().parent.parent / "docs"
    source_dir = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else None
    write_modules_versioning_file(docs_root / "versioning" / "modules.json", source_dir=source_dir)


if __name__ == "__main__":
    main()
