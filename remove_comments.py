#!/usr/bin/env python3
"""
Simple script to remove comments from Lua files.
Preserves long comment blocks that start at the beginning of a line ("--[[ ... ]]").
Removes:
- Pure single-line comments that start with "--" (with any leading whitespace)
- Inline comments introduced by "--" that appear after code, while respecting strings

Usage:
    python remove_comments.py [target] [--ignore file1.lua] [--ignore file2.lua]

Arguments:
    target: Target directory or file (default: current directory)
    --ignore: Files or patterns to ignore (can be used multiple times)
"""

import os
import re
import sys
import subprocess
import argparse

def remove_comments(content):
    """Remove Lua single-line and inline comments, preserve top-of-line long blocks."""
    # Preserve BOM (if present) and remove it from parsing
    bom_prefix = '\ufeff' if content.startswith('\ufeff') else ''
    if bom_prefix:
        content = content[1:]

    lines = content.split('\n')
    cleaned_lines = []

    # Detect a long comment block that starts at the beginning of a line (with optional indentation)
    long_block_start_re = re.compile(r"^\s*--\[(=*)\[")

    def find_inline_comment_start(s: str) -> int:
        """Return index of first '--' outside of strings/long strings; -1 if none."""
        in_single = False
        in_double = False
        long_str_eq = -1  # -1 means not in long string; otherwise number of '='
        i = 0
        length = len(s)
        while i < length:
            ch = s[i]
            # Inside single-quoted string
            if in_single:
                if ch == '\\':
                    i += 2
                    continue
                if ch == "'":
                    in_single = False
                i += 1
                continue
            # Inside double-quoted string
            if in_double:
                if ch == '\\':
                    i += 2
                    continue
                if ch == '"':
                    in_double = False
                i += 1
                continue
            # Inside long string [[...]] or [=[...]=]
            if long_str_eq >= 0:
                if ch == ']':
                    j = i + 1
                    eq_count = 0
                    while j < length and s[j] == '=':
                        eq_count += 1
                        j += 1
                    if eq_count == long_str_eq and j < length and s[j] == ']':
                        long_str_eq = -1
                        i = j + 1
                        continue
                i += 1
                continue

            # Not in any string
            if ch == "'":
                in_single = True
                i += 1
                continue
            if ch == '"':
                in_double = True
                i += 1
                continue
            if ch == '[':
                # possible long string start [=*[ (not comment, since no preceding --)
                j = i + 1
                eq_count = 0
                while j < length and s[j] == '=':
                    eq_count += 1
                    j += 1
                if j < length and s[j] == '[':
                    long_str_eq = eq_count
                    i = j + 1
                    continue
            if ch == '-' and i + 1 < length and s[i + 1] == '-':
                return i
            i += 1
        return -1

    i = 0
    while i < len(lines):
        line = lines[i]

        # 1) Preserve long comment blocks that start at the beginning of a line
        m = long_block_start_re.match(line)
        if m is not None:
            eqs = m.group(1)
            closing = "]" + eqs + "]"
            cleaned_lines.append(line.rstrip())
            # If closing is on the same line, done with this line
            if closing in line:
                i += 1
                continue
            i += 1
            # consume until closing ]=*=]
            while i < len(lines):
                cleaned_lines.append(lines[i].rstrip())
                if closing in lines[i]:
                    i += 1
                    break
                i += 1
            continue

        # 2) Drop pure single-line comments that start with '--'
        if line.lstrip().startswith('--'):
            i += 1
            continue

        # 3) Strip inline comments introduced by '--' outside of strings
        idx = find_inline_comment_start(line)
        if idx >= 0:
            kept = line[:idx].rstrip()
            tail = line[idx:]
            # If inline comment is a long block comment, skip following lines until closing
            m2 = re.match(r"--\[(=*)\[", tail)
            if m2 is not None:
                eqs2 = m2.group(1)
                closing2 = "]" + eqs2 + "]"
                # skip lines until closing token
                i += 1
                while i < len(lines) and closing2 not in lines[i]:
                    i += 1
                if i < len(lines):
                    # skip the closing line itself
                    i += 1
                cleaned_lines.append(kept)
                continue
            cleaned_lines.append(kept)
        else:
            cleaned_lines.append(line.rstrip())

        i += 1

    result = '\n'.join(cleaned_lines)
    return bom_prefix + result

def run_glualint_pretty_print(target_dir):
    """Run glualint pretty-print on the target directory."""
    try:
        print(f"Running glualint pretty-print on {target_dir}...")
        result = subprocess.run(['glualint', 'pretty-print', target_dir],
                              capture_output=True, text=True, check=True)
        print("glualint pretty-print completed successfully")
        if result.stdout:
            print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running glualint pretty-print: {e}")
        if e.stdout:
            print(f"stdout: {e.stdout}")
        if e.stderr:
            print(f"stderr: {e.stderr}")
    except FileNotFoundError:
        print("Error: glualint not found. Make sure it's installed and in your PATH.")

def process_file(filepath):
    """Process a single file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        cleaned = remove_comments(content)
        
        if content != cleaned:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(cleaned)
            print(f"Cleaned: {filepath}")
            return True
        return False
    except Exception as e:
        print(f"Error: {filepath} - {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Remove comments from Lua files.')
    parser.add_argument('target', nargs='?', default='.',
                       help='Target directory or file (default: current directory)')
    parser.add_argument('--ignore', action='append', default=[],
                       help='Files or patterns to ignore (can be used multiple times)')

    args = parser.parse_args()

    # Convert ignore patterns to absolute paths for comparison
    ignore_patterns = []
    for pattern in args.ignore:
        # If pattern contains path separators, treat as path relative to target
        if os.sep in pattern or (os.altsep and os.altsep in pattern):
            ignore_patterns.append(os.path.abspath(os.path.join(args.target, pattern)))
        else:
            # If just filename, match against basename
            ignore_patterns.append(pattern)

    def should_ignore(filepath):
        """Check if file should be ignored based on patterns."""
        abs_path = os.path.abspath(filepath)
        basename = os.path.basename(filepath)

        for pattern in ignore_patterns:
            if os.path.isabs(pattern):
                # Absolute path pattern - check if file matches
                if abs_path == pattern:
                    return True
            else:
                # Filename pattern - check if basename matches
                if basename == pattern:
                    return True
        return False

    if os.path.isfile(args.target) and args.target.endswith('.lua'):
        # Single file
        if not should_ignore(args.target):
            process_file(args.target)
        else:
            print(f"Ignored: {args.target}")
    else:
        # Directory - first remove comments from all files
        count = 0
        for root, dirs, files in os.walk(args.target):
            for file in files:
                if file.endswith('.lua'):
                    filepath = os.path.join(root, file)
                    if should_ignore(filepath):
                        print(f"Ignored: {filepath}")
                        continue
                    if process_file(filepath):
                        count += 1
        print(f"Processed {count} files")

        # Then run glualint pretty-print if available
        run_glualint_pretty_print(args.target)

if __name__ == '__main__':
    main()
