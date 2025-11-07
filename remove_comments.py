#!/usr/bin/env python3
"""
Simple script to remove comments from Lua files.
Preserves long comment blocks that start at the beginning of a line ("--[[ ... ]]").
Removes:
- Pure single-line comments that start with "--" (with any leading whitespace)
- Inline comments introduced by "--" that appear after code, while respecting strings
"""

import os
import re
import sys
import subprocess

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
            # Use regex to find the actual closing token (not just any occurrence)
            closing_re = re.compile(re.escape(closing))
            found_closing = False
            while i < len(lines):
                cleaned_lines.append(lines[i].rstrip())
                # Check if this line contains the closing token
                if closing_re.search(lines[i]):
                    i += 1
                    found_closing = True
                    break
                i += 1
            # Safety check: if we didn't find closing and consumed too many lines, stop
            if not found_closing and i >= len(lines):
                # We've consumed the entire rest of the file - this shouldn't happen
                # but if it does, at least we've preserved everything
                break
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
                # Use regex to find the actual closing token
                closing2_re = re.compile(re.escape(closing2))
                # Check if closing is on the same line
                if closing2_re.search(tail):
                    # Comment closes on same line, just strip it
                    cleaned_lines.append(kept)
                    i += 1
                    continue
                # For inline long comments that span multiple lines, we need to be very careful
                # If the closing is not on the same line, we'll look for it, but with strict limits
                # to prevent accidentally removing code
                i += 1
                found_closing2 = False
                max_skip = 50  # Very strict limit: inline multi-line comments are rare
                skipped = 0
                start_skip = i  # Remember where we started skipping
                while i < len(lines) and skipped < max_skip:
                    if closing2_re.search(lines[i]):
                        # Found closing, skip this line and continue
                        i += 1
                        found_closing2 = True
                        break
                    i += 1
                    skipped += 1
                # If we didn't find closing within the limit, this is likely malformed
                # or not actually a comment. Don't skip - treat those lines as code.
                if not found_closing2:
                    # Reset to where we started - don't skip those lines
                    # They'll be processed as normal code in the next iteration
                    i = start_skip
                    # Just strip the comment start from the original line
                    cleaned_lines.append(kept)
                    i += 1
                    continue
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
    if len(sys.argv) > 1:
        target = sys.argv[1]
    else:
        target = "."

    if os.path.isfile(target) and target.endswith('.lua'):
        # Single file
        process_file(target)
    else:
        # Directory - first remove comments from all files
        count = 0
        for root, dirs, files in os.walk(target):
            for file in files:
                if file.endswith('.lua'):
                    if process_file(os.path.join(root, file)):
                        count += 1
        print(f"Processed {count} files")

        # Then run glualint pretty-print if available
        run_glualint_pretty_print(target)

if __name__ == '__main__':
    main()
