#!/usr/bin/env python3

import argparse
import os
import sys
from pathlib import Path

DEFAULT_DIRECTORY = Path(r"E:\GMOD\Server\garrysmod")


def _match_long_bracket_opener(text: str, start_index: int):
    i = start_index
    if i >= len(text) or text[i] != "[":
        return False, 0, start_index
    i += 1
    num_equals = 0
    while i < len(text) and text[i] == "=":
        num_equals += 1
        i += 1
    if i < len(text) and text[i] == "[":
        return True, num_equals, i + 1
    return False, 0, start_index


def _find_long_bracket_closer(text: str, start_index: int, num_equals: int):
    closer = "]" + ("=" * num_equals) + "]"
    pos = text.find(closer, start_index)
    return -1 if pos == -1 else pos + len(closer)


def remove_lua_comments(content: str) -> str:
    i = 0
    n = len(content)
    output_chars = []

    while i < n:
        ch = content[i]

        if ch == "-" and i + 1 < n and content[i + 1] == "-":
            j = i + 2
            if j < n and content[j] == "[":
                is_open, num_eq, end_opener = _match_long_bracket_opener(content, j)
                if is_open:
                    end_idx = _find_long_bracket_closer(content, end_opener, num_eq)
                    if end_idx == -1:
                        output_chars.append(content[i:])
                        break
                    output_chars.append(content[i:end_idx])
                    i = end_idx
                    continue
            while i < n and content[i] != "\n":
                i += 1
            if i < n and content[i] == "\n":
                output_chars.append("\n")
                i += 1
            continue

        if ch == '"' or ch == "'":
            quote = ch
            output_chars.append(ch)
            i += 1
            while i < n:
                c = content[i]
                output_chars.append(c)
                i += 1
                if c == "\\":
                    if i < n:
                        output_chars.append(content[i])
                        i += 1
                elif c == quote:
                    break
            continue

        if ch == "[":
            is_open, num_eq, end_opener = _match_long_bracket_opener(content, i)
            if is_open:
                output_chars.append(content[i:end_opener])
                end_idx = _find_long_bracket_closer(content, end_opener, num_eq)
                if end_idx == -1:
                    output_chars.append(content[end_opener:])
                    break
                output_chars.append(content[end_opener:end_idx])
                i = end_idx
                continue

        output_chars.append(ch)
        i += 1

    return "".join(output_chars)


def process_file(file_path, dry_run=False):
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            original_content = f.read()

        cleaned_content = remove_lua_comments(original_content)

        original_lines = original_content.split("\n")
        cleaned_lines = cleaned_content.split("\n")
        lines_removed = max(0, len(original_lines) - len(cleaned_lines))

        if original_content != cleaned_content:
            if not dry_run:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(cleaned_content)
                return file_path, lines_removed, True
            else:
                return file_path, lines_removed, False
        else:
            return file_path, 0, False

    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return file_path, 0, False


def find_lua_files(directory):
    lua_files = []

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".lua"):
                lua_files.append(Path(root) / file)

    return lua_files


def main():
    parser = argparse.ArgumentParser(description="Remove Lua comments from files")
    parser.add_argument(
        "directory",
        nargs="?",
        default=str(DEFAULT_DIRECTORY),
        help=f"Directory to process (default: {DEFAULT_DIRECTORY})",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be changed without modifying files",
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Show detailed output"
    )

    args = parser.parse_args()

    directory = Path(args.directory)
    if not directory.exists():
        print(f"Error: Directory '{directory}' does not exist.")
        sys.exit(1)

    if not directory.is_dir():
        print(f"Error: '{directory}' is not a directory.")
        sys.exit(1)

    print(f"Searching for Lua files in: {directory.absolute()}")

    lua_files = find_lua_files(directory)
    print(f"Found {len(lua_files)} Lua files")

    if not lua_files:
        print("No Lua files found.")
        return

    total_lines_removed = 0
    modified_files = 0

    for file_path in lua_files:
        if args.verbose:
            print(f"Processing: {file_path}")

        file_path, lines_removed, was_modified = process_file(file_path, args.dry_run)

        if lines_removed > 0:
            status = "Would remove" if args.dry_run else "Removed"
            print(f"{status} {lines_removed} comment lines from {file_path}")
            total_lines_removed += lines_removed
            if was_modified:
                modified_files += 1

    if args.dry_run:
        print(
            f"\nDry run complete. Would remove {total_lines_removed} comment lines from {modified_files} files."
        )
    else:
        print(
            f"\nComplete! Removed {total_lines_removed} comment lines from {modified_files} files."
        )


if __name__ == "__main__":
    main()
