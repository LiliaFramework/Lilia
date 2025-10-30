#!/usr/bin/env python3
"""
Script to fix Lua code block indentation with proper multi-level indentation.

This script implements proper indentation levels for Lua code blocks:
- Base: where ```lua starts
- Level 1: base + 4 (top-level code)
- Level 2: base + 8 (inside functions, if blocks, loops)
- Level 3+: base + 12+ (nested blocks)
"""

import os
import re
import glob

def analyze_lua_indentation(content_lines, base_indent):
    """
    Analyze Lua code and apply proper multi-level indentation.

    Args:
        content_lines (list): Lines of Lua code
        base_indent (int): Base indentation where ```lua starts

    Returns:
        list: Properly indented code lines
    """
    result_lines = []
    indent_level = 0  # 0 = top-level, 1 = inside block, 2 = nested block, etc.

    i = 0
    while i < len(content_lines):
        line = content_lines[i]
        stripped = line.strip()

        # Skip empty lines
        if not stripped:
            result_lines.append("")
            i += 1
            continue

        # Comments - keep them at their logical level
        if stripped.startswith('--'):
            current_indent = base_indent + (indent_level * 4)
            result_lines.append(' ' * current_indent + stripped)
            i += 1
            continue

        # Calculate proper indentation for this line
        proper_indent = base_indent + (indent_level * 4)

        # Analyze what type of line this is to determine if it changes indent level

        # Function definitions - increase indent for next line (function body)
        if stripped.startswith(('function', 'local function')):
            result_lines.append(' ' * proper_indent + stripped)
            indent_level += 1  # Next line will be indented more

        # Control structures - increase indent for body
        elif stripped.startswith(('if ', 'elseif ', 'else')):
            result_lines.append(' ' * proper_indent + stripped)
            if 'then' in stripped or stripped.startswith('else'):
                indent_level += 1

        # Loops - increase indent for body
        elif stripped.startswith(('for ', 'while ', 'repeat')):
            result_lines.append(' ' * proper_indent + stripped)
            if 'do' in stripped or stripped.startswith('repeat'):
                indent_level += 1

        # Standalone do blocks
        elif stripped == 'do':
            result_lines.append(' ' * proper_indent + stripped)
            indent_level += 1

        # Block enders - decrease indent level
        elif stripped.startswith(('end', 'until')):
            # End statements go back one level
            if indent_level > 0:
                indent_level -= 1
            result_lines.append(' ' * (base_indent + (indent_level * 4)) + stripped)

        # Regular statements (assignments, function calls, etc.)
        else:
            result_lines.append(' ' * proper_indent + stripped)

        i += 1

    return result_lines

def fix_code_blocks(content_lines):
    """
    Fix all code blocks in documentation with proper indentation.

    Args:
        content_lines (list): Lines of documentation content

    Returns:
        list: Content with properly indented code blocks
    """
    fixed_lines = []
    i = 0

    while i < len(content_lines):
        line = content_lines[i]

        # Check if we're entering a code block
        if '```lua' in line:
            base_indent = len(line) - len(line.lstrip(' '))
            fixed_lines.append(line)

            # Collect code lines
            code_lines = []
            i += 1

            while i < len(content_lines):
                if '```' in content_lines[i] and '```lua' not in content_lines[i]:
                    break
                code_lines.append(content_lines[i])
                i += 1

            # Apply proper indentation to code lines
            if code_lines:
                fixed_code_lines = analyze_lua_indentation(code_lines, base_indent)
                fixed_lines.extend(fixed_code_lines)

            # Add closing ```
            if i < len(content_lines):
                fixed_lines.append(content_lines[i])

        else:
            fixed_lines.append(line)

        i += 1

    return fixed_lines

def process_file(filepath):
    """
    Process a single Lua file to fix code block indentation.

    Args:
        filepath (str): Path to the Lua file to process
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find all documentation blocks
        doc_block_pattern = r'--\[\[(.*?)\]\]'
        doc_blocks = re.findall(doc_block_pattern, content, re.DOTALL)

        if not doc_blocks:
            return  # No documentation blocks found

        modified = False
        for block in doc_blocks:
            # Skip blocks that don't contain code examples
            if not re.search(r'```lua', block):
                continue

            # Process the documentation block
            block_lines = block.split('\n')
            fixed_block_lines = fix_code_blocks(block_lines)
            fixed_block = '\n'.join(fixed_block_lines)

            if fixed_block != block:
                content = content.replace(f'--[[{block}]]', f'--[[{fixed_block}]]', 1)
                modified = True

        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed Lua code indentation in: {filepath}")

    except Exception as e:
        print(f"Error processing {filepath}: {e}")

def main():
    """Main function to process all Lua files in the gamemode directory."""
    gamemode_dir = "gamemode"

    if not os.path.exists(gamemode_dir):
        print(f"Directory '{gamemode_dir}' not found!")
        return

    lua_files = glob.glob(os.path.join(gamemode_dir, "**", "*.lua"), recursive=True)
    print(f"Found {len(lua_files)} Lua files to process...")

    for filepath in lua_files:
        process_file(filepath)

    print("Lua code indentation fixing complete!")

if __name__ == "__main__":
    main()
