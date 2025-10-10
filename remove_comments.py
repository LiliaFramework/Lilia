#!/usr/bin/env python3
"""
Simple script to remove comments from Lua files.
Removes both single-line (--) and multi-line (--[[ ]]) comments.
"""

import os
import re
import sys
import subprocess

def remove_comments(content):
    """Remove Lua comments from content."""
    lines = content.split('\n')
    cleaned_lines = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Skip multi-line comments
        if '--[[' in line and ']]' not in line:
            i += 1
            while i < len(lines) and ']]' not in lines[i]:
                i += 1
            if i < len(lines):
                i += 1
            continue
        
        # Remove single-line comments
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

    # Always process gamemode folder for comment removal
    gamemode_dir = "gamemode"

    if os.path.isfile(target) and target.endswith('.lua'):
        # Single file - only process if it's in gamemode
        if gamemode_dir in target or target.startswith(gamemode_dir + os.sep):
            process_file(target)
    else:
        # Directory - always process gamemode folder for comment removal
        count = 0
        for root, dirs, files in os.walk(gamemode_dir):
            for file in files:
                if file.endswith('.lua'):
                    if process_file(os.path.join(root, file)):
                        count += 1
        print(f"Processed {count} files")

        # Run glualint pretty-print on the gamemode directory after processing
        run_glualint_pretty_print(gamemode_dir)

if __name__ == '__main__':
    main()
