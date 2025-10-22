#!/usr/bin/env python3
"""
Documentation Generator for Lilia Framework

This script parses Lua comment blocks in meta and library files and generates
markdown documentation in the specified format.

Usage:
    python generate_docs.py [meta|library] [file1.lua] [file2.lua] ...

The script will generate documentation files in the appropriate directories:
- Meta files: documentation/docs/meta/
- Library files: documentation/docs/libraries/

For meta files, the output format is: [filename].md
For library files, the output format is: lia.[filename].md
"""

import os
import re
import sys
import argparse
from pathlib import Path


def parse_comment_block(comment_text):
    """
    Parse a Lua comment block and extract structured information.

    Expected format:
    --[[
    Purpose: [description]
    When Called: [description]
    Parameters:
        param - type: Description
    Returns: type - Description
    Realm: [realm]
    Example Usage:
        Low Complexity:
        ```lua
        [code]
        ```

        Medium Complexity:
        ```lua
        [code]
        ```
    ]]
    """

    lines = comment_text.strip().split('\n')
    parsed = {
        'purpose': '',
        'when_called': '',
        'parameters': [],
        'returns': '',
        'realm': '',
        'examples': []
    }

    current_section = None
    current_example = None
    example_complexity = None

    for line in lines:
        line = line.strip()

        # Skip comment markers and empty lines
        if line.startswith('--[[') or line.startswith('--]]') or not line:
            continue

        # Check for section headers
        if line.startswith('Purpose:'):
            current_section = 'purpose'
            parsed['purpose'] = line[8:].strip()
        elif line.startswith('When Called:'):
            current_section = 'when_called'
            parsed['when_called'] = line[12:].strip()
        elif line.startswith('Parameters:'):
            current_section = 'parameters'
        elif line.startswith('Returns:'):
            current_section = 'returns'
            # Extract returns info (format varies)
            returns_text = line[8:].strip()
            if returns_text:
                parsed['returns'] = returns_text
        elif line.startswith('Realm:'):
            current_section = 'realm'
            parsed['realm'] = line[6:].strip()
        elif line.startswith('Example Usage:'):
            current_section = 'examples'
        elif current_section == 'parameters':
            # Parse parameter lines (various formats)
            if line.strip() and not line.startswith('*') and not line.startswith('--'):
                # Simple format: param - type: Description
                param_match = re.match(r'\s*([^-\s]+)\s*-\s*([^:]+):\s*(.+)', line)
                if param_match:
                    parsed['parameters'].append({
                        'name': param_match.group(1).strip(),
                        'type': param_match.group(2).strip(),
                        'description': param_match.group(3).strip()
                    })
                else:
                    # Alternative format or continuation
                    param_match = re.match(r'\s*([^-\s]+)\s*-\s*(.+)', line)
                    if param_match:
                        parsed['parameters'].append({
                            'name': param_match.group(1).strip(),
                            'type': 'unknown',
                            'description': param_match.group(2).strip()
                        })
        elif current_section == 'examples':
            # Handle example sections
            complexity_match = re.match(r'(\w+)\s+Complexity:', line)
            if complexity_match:
                if current_example:
                    parsed['examples'].append(current_example)

                example_complexity = complexity_match.group(1).lower()
                current_example = {
                    'complexity': example_complexity,
                    'code': []
                }
            elif current_example and line.strip().startswith('```'):
                # Start or end of code block
                if not current_example['code']:
                    # Start of code block
                    current_example['code'].append(line)
                else:
                    # End of code block
                    current_example['code'].append(line)
                    parsed['examples'].append(current_example)
                    current_example = None
            elif current_example and current_example['code']:
                # Inside code block - add the line
                current_example['code'].append(line)

    # Add final example if exists
    if current_example:
        parsed['examples'].append(current_example)

    return parsed


def parse_file_header(header_text):
    """
    Parse and format the file header comment for title and subtitle.
    """
    # Remove comment block markers - be more specific
    # Match --[[ at start and ]] at end
    content = re.sub(r'--\[\[(.*)\]\]', r'\1', header_text, flags=re.DOTALL).strip()

    lines = content.split('\n')
    formatted_lines = []

    for line in lines:
        line = line.strip()
        # Skip empty lines
        if not line:
            continue
        # Remove leading comment dashes and whitespace
        line = re.sub(r'^--\s*', '', line)
        if line:
            formatted_lines.append(line)

    # Check if we have a title (first line) followed by short description (second line)
    if len(formatted_lines) >= 2:
        title = formatted_lines[0]
        short_description = formatted_lines[1]

        return f"**{title}**\n\n{short_description}"

    # If only one line, treat it as title only
    elif len(formatted_lines) == 1:
        title = formatted_lines[0]
        return f"**{title}**"

    # Fallback for no content
    return ""


def parse_overview_section(overview_text):
    """
    Parse and format the overview section comment.
    """
    # Remove comment block markers
    content = re.sub(r'--\[\[(.*)\]\]', r'\1', overview_text, flags=re.DOTALL).strip()

    # Remove "Overview:" prefix if present
    content = re.sub(r'^\s*Overview:\s*', '', content, flags=re.MULTILINE)

    lines = content.split('\n')
    formatted_lines = []

    for line in lines:
        line = line.strip()
        # Skip empty lines
        if not line:
            continue
        # Remove leading comment dashes and whitespace
        line = re.sub(r'^--\s*', '', line)
        if line:
            formatted_lines.append(line)

    # Join the lines and clean up extra whitespace
    content = '\n'.join(formatted_lines)
    content = re.sub(r'\s+', ' ', content)
    content = content.strip()

    return content


def extract_function_name_from_comment(comment_text, file_path):
    """
    Extract the function name from the comment block or file context.
    """
    # Fallback: extract from filename
    filename = Path(file_path).stem
    return filename


def find_functions_in_file(file_path):
    """
    Find all function definitions in a Lua file with their line numbers.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return []

    functions = []

    # Find all comment blocks first (we'll get both function comments and file header)
    comment_pattern = r'--\[\[.*?\]\]'
    comments = []
    for match in re.finditer(comment_pattern, content, re.DOTALL):
        comments.append((match.start(), match.end(), match.group(0)))

    # Find all function definitions (including meta methods and namespaced functions)
    func_pattern = r'function\s+([\w\.:]+)\s*\('
    for match in re.finditer(func_pattern, content):
        func_name = match.group(1)
        func_line = content[:match.start()].count('\n') + 1

        # Find the preceding comment block (closest one before this function)
        preceding_comment = None
        for comment_start, comment_end, comment_text in comments:
            comment_line = content[:comment_start].count('\n') + 1
            if comment_line < func_line and (preceding_comment is None or comment_line > preceding_comment[0]):
                # Check if this comment has structured format (function comments only)
                if any(header in comment_text for header in ['Purpose:', 'When Called:', 'Parameters:', 'Returns:', 'Realm:', 'Example Usage:']):
                    preceding_comment = (comment_line, comment_text)

        if preceding_comment:
            functions.append({
                'name': func_name,
                'comment': preceding_comment[1]
            })

    return functions


def generate_markdown_for_function(function_name, parsed_comment, is_library=False):
    """
    Generate markdown documentation for a single function.
    """
    # Determine the function name for display (handle both meta and library functions)
    display_name = function_name
    if is_library and not function_name.startswith('lia.'):
        display_name = f'lia.{function_name}'

    md = f'### {display_name}\n\n'

    # Purpose
    if parsed_comment['purpose']:
        md += f'**Purpose**\n\n{parsed_comment["purpose"]}\n\n'

    # When Called
    if parsed_comment['when_called']:
        md += f'**When Called**\n\n{parsed_comment["when_called"]}\n\n'

    # Parameters
    if parsed_comment['parameters']:
        md += '**Parameters**\n\n'
        for param in parsed_comment['parameters']:
            md += f'* `{param["name"]}` (*{param["type"]}*): {param["description"]}\n'
        md += '\n'

    # Returns
    if parsed_comment['returns']:
        md += f'**Returns**\n\n* {parsed_comment["returns"]}\n\n'

    # Realm
    if parsed_comment['realm']:
        md += f'**Realm**\n\n{parsed_comment["realm"]}\n\n'

    # Example Usage
    if parsed_comment['examples']:
        md += '**Example Usage**\n\n'
        for example in parsed_comment['examples']:
            complexity = example['complexity'].title()
            md += f'**{complexity} Complexity:**\n'
            md += '```lua\n'
            md += '\n'.join(example['code'])
            md += '\n```\n\n'

    return md


def find_comment_blocks_in_file(file_path):
    """
    Find all comment blocks in a Lua file.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return [], None, None

    # Find all comment blocks that start with --[[
    comment_pattern = r'--\[\[.*?\]\]'
    comment_blocks = []
    file_header = None
    overview_section = None

    for match in re.finditer(comment_pattern, content, re.DOTALL):
        comment_text = match.group(0)
        # Check if this comment block has the structured format we expect (function comments)
        if any(header in comment_text for header in ['Purpose:', 'When Called:', 'Parameters:', 'Returns:', 'Realm:', 'Example Usage:']):
            comment_blocks.append(comment_text)
        # Check if this is a file header (first comment block that doesn't have function structure or overview)
        elif file_header is None and not any(header in comment_text for header in ['Purpose:', 'When Called:', 'Parameters:', 'Returns:', 'Realm:', 'Example Usage:', 'Overview:']):
            file_header = comment_text
        # Check if this is an overview section (contains "Overview:")
        elif 'Overview:' in comment_text and overview_section is None:
            overview_section = comment_text

    return comment_blocks, file_header, overview_section


def generate_documentation_for_file(file_path, output_dir, is_library=False):
    """
    Generate documentation for a single Lua file.
    """
    print(f"Processing {file_path}")

    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)
    functions = find_functions_in_file(file_path)

    if not functions:
        print(f"  No structured functions found in {file_path}")
        return

    # Extract filename for the output file
    filename = Path(file_path).stem
    
    # For module libraries, use the module name instead of the filename
    if is_library and 'modules' in str(file_path):
        # Extract module name from path like gamemode/modules/doors/libraries/server.lua
        path_parts = Path(file_path).parts
        if 'modules' in path_parts:
            module_index = path_parts.index('modules')
            if module_index + 1 < len(path_parts):
                module_name = path_parts[module_index + 1]
                output_filename = f"lia.{module_name}.md"
            else:
                output_filename = f"lia.{filename}.md"
        else:
            output_filename = f"lia.{filename}.md"
    elif is_library:
        output_filename = f"lia.{filename}.md"
    else:
        output_filename = f"{filename}.md"

    output_path = Path(output_dir) / output_filename

    # Check if file already exists and has content
    if output_path.exists() and output_path.stat().st_size > 0:
        print(f"  {output_filename} already exists, skipping")
        return

    # Generate markdown content
    sections = []

    for func in functions:
        parsed = parse_comment_block(func['comment'])
        if parsed['purpose']:  # Only process blocks that have at least a purpose
            section = generate_markdown_for_function(func['name'], parsed, is_library)
            sections.append(section)

    if not sections:
        print(f"  No valid function documentation found in {file_path}")
        return

    # Write the documentation file
    with open(output_path, 'w', encoding='utf-8') as f:
        # Generate title and subtitle from file header
        title = filename.title()
        subtitle = f'This page documents the functions and methods in the { "Lilia library" if is_library else "meta table" }.'

        if file_header:
            parsed_header = parse_file_header(file_header)
            # If header has both title and description, use them
            if '\n\n' in parsed_header:
                parts = parsed_header.split('\n\n', 1)
                title = parts[0].replace('**', '').replace('*', '').strip()
                if len(parts) > 1 and parts[1].strip():
                    subtitle = parts[1].strip()

        f.write(f'# {title}\n\n')
        f.write(f'{subtitle}\n\n')
        f.write('---\n\n')

        # Add Overview section with overview content if available
        if overview_section:
            f.write('## Overview\n\n')
            # Parse the overview section (remove "Overview:" and format)
            overview_content = parse_overview_section(overview_section)
            f.write(overview_content)
            f.write('\n\n')
            f.write('---\n\n')

        for section in sections:
            f.write(section)
            f.write('---\n\n')

    print(f"  Generated {output_filename}")


def main():
    parser = argparse.ArgumentParser(description='Generate documentation from Lua comment blocks')
    parser.add_argument('type', choices=['meta', 'library'], help='Type of files to process')
    parser.add_argument('files', nargs='*', help='Specific files to process (if empty, processes all)')

    args = parser.parse_args()

    # Set up paths
    script_dir = Path(__file__).parent
    base_dir = script_dir / 'gamemode' / 'core'
    modules_dir = script_dir / 'gamemode' / 'modules'

    if args.type == 'meta':
        input_dir = base_dir / 'meta'
        output_dir = script_dir / 'documentation' / 'docs' / 'meta'
    else:
        input_dir = base_dir / 'libraries'
        output_dir = script_dir / 'documentation' / 'docs' / 'libraries'

    # Create output directory if it doesn't exist
    output_dir.mkdir(parents=True, exist_ok=True)

    # Get list of files to process
    files_to_process = []
    
    if args.files:
        for file_pattern in args.files:
            # Support wildcards
            import glob
            matches = glob.glob(str(input_dir / file_pattern))
            files_to_process.extend(matches)

            # Also check for files in current directory if pattern doesn't match full path
            if not matches:
                matches = glob.glob(file_pattern)
                files_to_process.extend(matches)
    else:
        # Process core library files
        files_to_process.extend(list(input_dir.glob('*.lua')))
        
        # Process module library files (for library type only)
        if args.type == 'library':
            for module_dir in modules_dir.iterdir():
                if module_dir.is_dir():
                    module_lib_dir = module_dir / 'libraries'
                    if module_lib_dir.exists():
                        files_to_process.extend(list(module_lib_dir.glob('*.lua')))

    if not files_to_process:
        print(f"No files found in {input_dir}")
        return

    print(f"Processing {len(files_to_process)} {args.type} files...")

    # Process each file
    for file_path in files_to_process:
        if str(file_path).endswith('.lua'):
            generate_documentation_for_file(file_path, output_dir, args.type == 'library')

    print("Documentation generation complete!")


if __name__ == '__main__':
    main()
