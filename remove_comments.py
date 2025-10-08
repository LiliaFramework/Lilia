#!/usr/bin/env python3
"""
Script to remove comments from Lua files in the Lilia gamemode project.
Supports both single-line comments (--) and multi-line comments (--[[ ... ]]).
"""

import os
import re
import argparse
from pathlib import Path


def remove_lua_comments(content):
    """
    Remove Lua comments from content while preserving code structure.
    Handles both single-line comments (--) and multi-line comments (--[[ ... ]]).
    """
    # Remove single-line comments (but not if they're part of multi-line comment markers)
    lines = content.split('\n')
    cleaned_lines = []

    i = 0
    while i < len(lines):
        line = lines[i]

        # Check if this line starts a multi-line comment
        if '--[[' in line and ']]' not in line:
            # Skip lines until we find the closing ]]
            i += 1
            while i < len(lines) and ']]' not in lines[i]:
                i += 1
            # Skip the line with ]]
            if i < len(lines):
                i += 1
            continue

        # Remove single-line comments that aren't part of multi-line markers
        # This regex removes -- followed by anything, but not if it's --[[ or --]]
        line = re.sub(r'--(?![\[\]])[^-].*', '', line)

        # Clean up extra whitespace but preserve the line if it has content
        line = line.rstrip()
        if line:  # Only add non-empty lines
            cleaned_lines.append(line)

        i += 1

    return '\n'.join(cleaned_lines)


def process_file(file_path):
    """Process a single Lua file to remove comments."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content
        cleaned_content = remove_lua_comments(content)

        if original_content != cleaned_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(cleaned_content)
            return True
        return False

    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False


def find_lua_files(directory):
    """Recursively find all Lua files in the given directory."""
    lua_files = []
    for root, dirs, files in os.walk(directory):
        # Skip certain directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['node_modules', '__pycache__', '.git']]

        for file in files:
            if file.endswith('.lua'):
                lua_files.append(os.path.join(root, file))

    return lua_files


def main():
    parser = argparse.ArgumentParser(description='Remove comments from Lua files')
    parser.add_argument('--directory', '-d', default='.',
                        help='Directory to process (default: current directory)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be changed without making changes')
    parser.add_argument('--verbose', '-v', action='store_true',
                        help='Show detailed output')

    args = parser.parse_args()

    # Find all Lua files
    lua_files = find_lua_files(args.directory)

    if not lua_files:
        print("No Lua files found.")
        return

    print(f"Found {len(lua_files)} Lua files")

    if args.dry_run:
        print("\n--- DRY RUN MODE - No files will be modified ---")

    files_changed = 0

    for file_path in lua_files:
        if args.dry_run:
            # For dry run, just check if file would be changed
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                cleaned_content = remove_lua_comments(content)
                if content != cleaned_content:
                    print(f"Would modify: {file_path}")
                    files_changed += 1
            except Exception as e:
                print(f"Error reading {file_path}: {e}")
        else:
            if args.verbose:
                print(f"Processing: {file_path}")

            if process_file(file_path):
                if args.verbose:
                    print(f"  Modified: {file_path}")
                files_changed += 1

    print(f"\n{'Would modify' if args.dry_run else 'Modified'} {files_changed} files")

    if not args.dry_run and files_changed > 0:
        print(f"\nSuccessfully removed comments from {files_changed} Lua files!")


if __name__ == '__main__':
    main()
