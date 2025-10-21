#!/usr/bin/env python3
"""
Simple script to remove comments from Lua files.
Preserves comment blocks (--[[ ]]) and pure comment lines (starting with --).
Only removes inline comments (-- at end of code lines).
"""

import os
import re
import sys
import subprocess

def remove_comments(content):
    """Remove Lua comments from content, but preserve comment blocks."""
    lines = content.split('\n')
    cleaned_lines = []

    i = 0
    while i < len(lines):
        line = lines[i]

        # Preserve multi-line comment blocks (--[[ ]])
        if '--[[' in line:
            # Check if it's a complete block on one line
            if ']]' in line:
                # Complete block on one line - clean whitespace and preserve it
                cleaned_line = line.rstrip()
                cleaned_lines.append(cleaned_line)
            else:
                # Multi-line block - clean whitespace and preserve all lines until closing ]]
                cleaned_line = line.rstrip()
                cleaned_lines.append(cleaned_line)
                i += 1
                while i < len(lines) and ']]' not in lines[i]:
                    cleaned_line = lines[i].rstrip()
                    cleaned_lines.append(cleaned_line)
                    i += 1
                if i < len(lines):
                    cleaned_line = lines[i].rstrip()
                    cleaned_lines.append(cleaned_line)
            i += 1
            continue

        # Remove only inline single-line comments (-- at end of code lines)
        # But preserve lines that are purely comments
        stripped_line = line.strip()
        
        # If line starts with --, it's a pure comment line - clean whitespace and preserve it
        if stripped_line.startswith('--'):
            cleaned_line = line.rstrip()
            cleaned_lines.append(cleaned_line)
        else:
            # Remove inline comments (-- followed by text)
            line = re.sub(r'--.*', '', line)
            
            # Keep non-empty lines
            line = line.rstrip()
            if line:
                cleaned_lines.append(line)

        i += 1

    return '\n'.join(cleaned_lines)

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
