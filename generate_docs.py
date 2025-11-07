#!/usr/bin/env python3
"""
Documentation Generator for Lilia Framework

Parses Lua comment blocks and generates Markdown documentation.

Usage:
    python generate_docs.py [meta|library|definitions|hooks] [files...]

Path equivalencies (inputs → outputs):
    gamemode/core/meta                     → documentation/docs/meta
    gamemode/core/libraries                → documentation/docs/libraries
    gamemode/docs/definitions/*.lua        → documentation/docs/definitions/*.md
    gamemode/docs/hooks/*.lua              → documentation/docs/hooks/*.md

Notes:
- Meta outputs: [filename].md
- Library outputs: lia.[filename or module].md
- Definitions outputs:
    panels.lua → panels.md
    faction.lua → faction.md
    module.lua → module.md
    items.lua → items.md
    class.lua → class.md
- Hooks outputs: client.lua → client.md, server.lua → server.md, shared.lua → shared.md

The parser is flexible and supports additional fields beyond the standard
function comment headers, e.g. "Explanation of Panel" and "When Used".
"""

import os
import re
import sys
import argparse
from pathlib import Path
from typing import List, Dict, Tuple, Optional

# Core hooks that should not be documented in module files (they're documented centrally)
CORE_HOOKS = {
    'OnCharVarChanged', 'GetModelGender', 'CharPreSave', 'PlayerLoadedChar', 'PlayerDeath',
    'PlayerShouldPermaKill', 'CharLoaded', 'PrePlayerLoadedChar', 'OnPickupMoney',
    'CanItemBeTransfered', 'CanPlayerInteractItem', 'CanPlayerEquipItem', 'CanPlayerTakeItem',
    'CanPlayerDropItem', 'CheckPassword', 'PlayerSay', 'CanPlayerHoldObject', 'EntityTakeDamage',
    'KeyPress', 'InitializedSchema', 'GetGameDescription', 'PostPlayerLoadout', 'ShouldSpawnClientRagdoll',
    'DoPlayerDeath', 'PlayerSpawn', 'PreCleanupMap', 'PostCleanupMap', 'ShutDown', 'PlayerAuthed',
    'PlayerDisconnected', 'PlayerInitialSpawn', 'PlayerLoadout', 'CreateDefaultInventory',
    'SetupBotPlayer', 'PlayerShouldTakeDamage', 'CanDrive', 'PlayerDeathThink', 'SaveData',
    'LoadData', 'OnEntityCreated', 'UpdateEntityPersistence', 'EntityRemoved', 'LiliaTablesLoaded',
    'PlayerCanHearPlayersVoice', 'CreateSalaryTimers', 'ShowHelp', 'PlayerSpray', 'PlayerDeathSound',
    'CanPlayerSuicide', 'AllowPlayerPickup', 'PostDrawOpaqueRenderables', 'ShouldDrawEntityInfo',
    'GetInjuredText', 'DrawCharInfo', 'DrawEntityInfo', 'HUDPaint', 'TooltipInitialize',
    'TooltipPaint', 'TooltipLayout', 'DrawLiliaModelView', 'OnChatReceived', 'CreateMove',
    'CalcView', 'PlayerBindPress', 'ItemShowEntityMenu', 'HUDPaintBackground', 'OnContextMenuOpen',
    'OnContextMenuClose', 'CharListLoaded', 'ForceDermaSkin', 'DermaSkinChanged', 'HUDShouldDraw',
    'PrePlayerDraw', 'PlayerStartVoice', 'PlayerEndVoice', 'VoiceToggled', 'SpawnMenuOpen',
    'InitPostEntity', 'HUDDrawTargetID', 'HUDDrawPickupHistory', 'HUDAmmoPickedUp', 'DrawDeathNotice',
    'GetMainMenuPosition'
}


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
        'examples': [],
        # Extended/alternative fields for non-standard docs
        'explanation': '',       # e.g., Explanation of Panel
        'when_used': ''          # e.g., When Used
    }

    current_section = None
    current_example = None
    example_complexity = None
    section_content = []
    pending_parameter = None  # Track pending parameter for new format (name, type)

    def finalize_current_section():
        """Finalize the current section by joining accumulated content."""
        if current_section and section_content:
            content = '\n'.join(section_content).strip()
            if current_section == 'purpose':
                parsed['purpose'] = content
            elif current_section == 'when_called':
                parsed['when_called'] = content
            elif current_section == 'when_used':
                parsed['when_used'] = content
            elif current_section == 'explanation':
                parsed['explanation'] = content
            elif current_section == 'returns':
                parsed['returns'] = content
            elif current_section == 'realm':
                parsed['realm'] = content
        section_content.clear()

    for line in lines:
        original_line = line
        line = line.strip()

        # Skip comment markers and empty lines
        if line.startswith('--[[') or line.startswith('--]]') or not line:
            continue

        # Check for section headers
        if line.startswith('Purpose:'):
            finalize_current_section()
            current_section = 'purpose'
            inline_content = line[8:].strip()
            if inline_content:
                section_content.append(inline_content)
        elif line.startswith('When Called:'):
            finalize_current_section()
            current_section = 'when_called'
            inline_content = line[12:].strip()
            if inline_content:
                section_content.append(inline_content)
        elif line.startswith('When Used:'):
            # Alias used in panels/definitions
            finalize_current_section()
            current_section = 'when_used'
            inline_content = line[10:].strip()
            if inline_content:
                section_content.append(inline_content)
        elif line.startswith('Parameters:'):
            finalize_current_section()
            current_section = 'parameters'
            # Handle inline parameter on same line (e.g., "Parameters: name (Type): Description")
            inline = line[len('Parameters:'):].strip()
            if inline:
                m = re.match(r'-\s*([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*:\s*(.+)', inline)
                if m:
                    parsed['parameters'].append({'name': m.group(1), 'type': m.group(2), 'description': m.group(3)})
                else:
                    m = re.match(r'([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*:\s*(.+)', inline)
                    if m:
                        parsed['parameters'].append({'name': m.group(1), 'type': m.group(2), 'description': m.group(3)})
                    else:
                        m = re.match(r'([A-Za-z_][\w]*)\s*-\s*([^:]+):\s*(.+)', inline)
                        if m:
                            parsed['parameters'].append({'name': m.group(1), 'type': m.group(2).strip(), 'description': m.group(3)})
        elif current_section == 'parameters':
            # Parse parameter lines (various formats)
            if line.strip() and not line.startswith('--'):
                if line.startswith('Returns:'):
                    finalize_current_section()
                    if pending_parameter:
                        parsed['parameters'].append({
                            'name': pending_parameter['name'],
                            'type': pending_parameter['type'],
                            'description': ''
                        })
                        pending_parameter = None
                    current_section = 'returns'
                    inline_content = line[8:].strip()
                    if inline_content:
                        section_content.append(inline_content)
                elif line.startswith('Realm:'):
                    finalize_current_section()
                    if pending_parameter:
                        parsed['parameters'].append({
                            'name': pending_parameter['name'],
                            'type': pending_parameter['type'],
                            'description': ''
                        })
                        pending_parameter = None
                    current_section = 'realm'
                    inline_content = line[6:].strip()
                    if inline_content:
                        section_content.append(inline_content)
                elif line.startswith('Example Usage:'):
                    finalize_current_section()
                    if pending_parameter:
                        parsed['parameters'].append({
                            'name': pending_parameter['name'],
                            'type': pending_parameter['type'],
                            'description': ''
                        })
                        pending_parameter = None
                    current_section = 'examples'
                # Check if this line is indented (parameter) or a new section header
                elif len(original_line) > len(original_line.lstrip()):
                    # Check for parameter patterns first
                    m = re.match(r'^\s+([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*$', original_line)
                    if m:
                        # Found parameter name and type - commit any pending parameter first
                        if pending_parameter:
                            parsed['parameters'].append({
                                'name': pending_parameter['name'],
                                'type': pending_parameter['type'],
                                'description': ''
                            })
                        pending_parameter = {'name': m.group(1).strip(), 'type': m.group(2).strip()}
                    else:
                        # Not a parameter pattern - check if it's a description for pending parameter
                        if pending_parameter:
                            desc = line.strip()
                            parsed['parameters'].append({
                                'name': pending_parameter['name'],
                                'type': pending_parameter['type'],
                                'description': desc
                            })
                            pending_parameter = None
                            # OLD FORMAT: Indented format: name (Type) - Description (common in hooks)
                            m = re.match(r'^\s+([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*-\s*(.+)', original_line)
                            if m:
                                parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                            else:
                                # Fallback for indented lines without parentheses
                                m = re.match(r'^\s+([A-Za-z_][\w]*)\s*-\s*(.+)', original_line)
                                if m:
                                    parsed['parameters'].append({'name': m.group(1).strip(), 'type': 'unknown', 'description': m.group(2).strip()})
                else:
                    # Not indented, might be a new section - reset current_section
                    current_section = None
                    # Continue processing this line as a potential new section
                    if line.startswith('Returns:'):
                        finalize_current_section()
                        current_section = 'returns'
                        inline_content = line[8:].strip()
                        if inline_content:
                            section_content.append(inline_content)
                    elif line.startswith('Realm:'):
                        finalize_current_section()
                        current_section = 'realm'
                        inline_content = line[6:].strip()
                        if inline_content:
                            section_content.append(inline_content)
                    elif line.startswith('Example Usage:'):
                        current_section = 'examples'
                # If still in parameters section, try other formats
                if current_section == 'parameters':
                    # Bullet: - name (Type): Description
                    m = re.match(r'-\s*([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*:\s*(.+)', line)
                    if m:
                        parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                    else:
                        # Bullet without type: - name: Description
                        m = re.match(r'-\s*([A-Za-z_][\w]*)\s*:\s*(.+)', line)
                        if m:
                            parsed['parameters'].append({'name': m.group(1).strip(), 'type': 'unknown', 'description': m.group(2).strip()})
                        else:
                            # Inline no bullet: name (Type): Description
                            m = re.match(r'([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*:\s*(.+)', line)
                            if m:
                                parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                            else:
                                # Simple: name - type: Description
                                m = re.match(r'\s*([^\-\s]+)\s*-\s*([^:]+):\s*(.+)', line)
                                if m:
                                    parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                                else:
                                    # Fallback: name - Description
                                    m = re.match(r'\s*([^\-\s]+)\s*-\s*(.+)', line)
                                    if m:
                                        parsed['parameters'].append({'name': m.group(1).strip(), 'type': 'unknown', 'description': m.group(2).strip()})
        elif line.startswith('Returns:'):
            finalize_current_section()
            current_section = 'returns'
            inline_content = line[8:].strip()
            if inline_content:
                section_content.append(inline_content)
            # Check if next line might have the return type (new format)
            # This will be handled in the returns section processing
        elif line.startswith('Realm:'):
            finalize_current_section()
            current_section = 'realm'
            inline_content = line[6:].strip()
            if inline_content:
                section_content.append(inline_content)
        elif line.startswith('Explanation of Panel:'):
            finalize_current_section()
            current_section = 'explanation'
            inline_content = line[len('Explanation of Panel:'):].strip()
            if inline_content:
                section_content.append(inline_content)
        elif line.startswith('Example Usage:'):
            finalize_current_section()
            current_section = 'examples'
        elif line.startswith('Example Item:'):
            finalize_current_section()
            current_section = 'examples'
        elif current_section in ['purpose', 'when_called', 'when_used', 'returns', 'realm', 'explanation']:
            # Accumulate content for multi-line sections
            if line.strip():
                section_content.append(line)
        elif current_section == 'examples':
            # Handle example sections - but only if we're not inside a code block
            complexity_match = None
            if not (current_example and current_example.get('in_code_block', False)):
                complexity_match = re.match(r'(\w+)(?:\s+Complexity)?(?:\s+Example)?:', line)
                # Also handle special cases like "Hook Implementation Example:"
                if not complexity_match and 'Example:' in line:
                    complexity_match = re.match(r'(.+?)\s+Example:', line)
            if complexity_match:
                if current_example:
                    parsed['examples'].append(current_example)

                example_complexity = complexity_match.group(1).lower()
                current_example = {
                    'complexity': example_complexity,
                    'code': []
                }
            elif not current_example and line.strip().startswith('```'):
                # Start of code block without complexity - create default example
                current_example = {
                    'complexity': 'example',
                    'code': []
                }
                current_example['in_code_block'] = True
            elif current_example and line.strip().startswith('```'):
                # Start or end of code block
                if not current_example.get('in_code_block', False):
                    # Start of code block - skip the ```lua line
                    current_example['in_code_block'] = True
                else:
                    # End of code block - but don't end the example yet
                    # Only end the example if we encounter a new complexity level
                    current_example['in_code_block'] = False
                    # Add a blank line to separate multiple code blocks
                    current_example['code'].append('')
            elif current_example and current_example.get('in_code_block', False):
                # Inside code block - check for complexity level in comments
                if line.strip().startswith('--') and ':' in line:
                    # Check if this is a complexity level comment like "-- Low:"
                    complexity_match = re.match(r'--\s*(\w+):', line.strip())
                    if complexity_match and complexity_match.group(1).lower() in ['low', 'medium', 'high']:
                        # This is a complexity level comment, update the current example
                        current_example['complexity'] = complexity_match.group(1).lower()
                # Add the line to code (preserve original indentation from original_line)
                # Remove the leading whitespace that was added by the comment block indentation
                # but preserve the relative indentation within the code block
                # Strip only trailing whitespace, keep leading indentation
                current_example['code'].append(original_line.rstrip())

    # Finalize any remaining section
    finalize_current_section()
    
    # Commit any pending parameter before finishing
    if pending_parameter:
        parsed['parameters'].append({
            'name': pending_parameter['name'],
            'type': pending_parameter['type'],
            'description': ''
        })

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


def format_lua_code(code_lines):
    """
    Format Lua code blocks with proper indentation and spacing.
    """
    if not code_lines:
        return code_lines

    # Find the minimum indentation (excluding empty lines)
    min_indent = float('inf')
    for line in code_lines:
        stripped = line.strip()
        if stripped:  # Skip only empty lines
            indent = len(line) - len(line.lstrip())
            min_indent = min(min_indent, indent)

    # If no valid indentation found, return as-is but add 4 spaces
    if min_indent == float('inf') or min_indent == 0:
        final_lines = []
        for line in code_lines:
            if line.strip():  # Non-empty line
                final_lines.append('    ' + line)
            else:  # Empty line
                final_lines.append('')
        return final_lines

    # Remove the minimum indentation from all lines
    formatted_lines = []
    for line in code_lines:
        stripped = line.strip()
        if stripped:  # Non-empty line
            if len(line) >= min_indent:
                formatted_lines.append(line[min_indent:])
            else:
                formatted_lines.append(line)
        else:  # Empty line
            formatted_lines.append('')

    # Add 4 spaces by default to each line
    final_lines = []
    for line in formatted_lines:
        if line.strip():  # Non-empty line
            final_lines.append('    ' + line)
        else:  # Empty line
            final_lines.append('')

    return final_lines


def parse_overview_section(overview_text):
    """
    Parse and format the overview section comment.
    """
    # Remove comment block markers
    content = re.sub(r'--\[\[(.*)\]\]', r'\1', overview_text, flags=re.DOTALL).strip()

    # Remove "Overview:" prefix if present
    content = re.sub(r'^\s*Overview:\s*', '', content, flags=re.MULTILINE)

    raw_lines = content.split('\n')
    formatted_lines = []

    for raw in raw_lines:
        # Remove leading per-line comment markers
        line = re.sub(r'^\s*--\s*', '', raw.rstrip())
        # Preserve blank lines as paragraph breaks
        if not line.strip():
            formatted_lines.append('')
            continue
        line = re.sub(r'[ \t]+', ' ', line.strip())
        formatted_lines.append(line)

    # Collapse multiple blank lines to a single blank line
    out_lines = []
    blank = False
    for ln in formatted_lines:
        if ln == '':
            if not blank:
                out_lines.append('')
                blank = True
        else:
            out_lines.append(ln)
            blank = False

    # Join with single newlines, then replace double newlines with paragraph breaks
    result = '\n'.join(out_lines).strip()
    # Replace multiple newlines with double newlines for proper paragraph spacing
    result = re.sub(r'\n{3,}', '\n\n', result)
    return result


def extract_function_name_from_comment(comment_text, file_path):
    """
    Extract the function name from the comment block or file context.
    """
    # Fallback: extract from filename
    filename = Path(file_path).stem
    return filename


def find_functions_in_file(file_path, is_library=False):
    """
    Find all function definitions in a Lua file with their line numbers.
    For library files, only include functions that are part of the public API (start with 'lia.').
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

    # Find all function definitions (excluding local functions)
    func_pattern = r'(?<!local\s)function\s+([\w\.:]+)\s*\('
    for match in re.finditer(func_pattern, content):
        func_name = match.group(1)
        func_line = content[:match.start()].count('\n') + 1

        # For library files, only include functions that are part of the public API
        if is_library and not func_name.startswith('lia.'):
            continue

        # Find the preceding comment block (closest one before this function)
        preceding_comment = None
        for comment_start, comment_end, comment_text in comments:
            comment_line = content[:comment_start].count('\n') + 1
            if comment_line < func_line and (preceding_comment is None or comment_line > preceding_comment[0]):
                # Check if this comment has structured format (function comments only)
                if any(header in comment_text for header in ['Purpose:', 'When Called:', 'When Used:', 'Parameters:', 'Returns:', 'Realm:', 'Explanation of Panel:', 'Example Usage:']):
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
    elif not is_library and ':' in function_name:
        # For meta functions, remove the prefix (e.g., "panelMeta:liaListenForInventoryChanges" -> "liaListenForInventoryChanges")
        display_name = function_name.split(':', 1)[1]
    elif is_library and function_name.startswith('lia.'):
        # For library functions, keep the full function name as it appears in code
        display_name = function_name

    md = f'### {display_name}\n\n'

    # Purpose
    if parsed_comment['purpose']:
        md += f'#### 📋 Purpose\n{parsed_comment["purpose"]}\n\n'

    # When Called / When Used
    if parsed_comment['when_called']:
        md += f'#### ⏰ When Called\n{parsed_comment["when_called"]}\n\n'
    elif parsed_comment.get('when_used'):
        md += f'#### ⏰ When Called\n{parsed_comment["when_used"]}\n\n'

    # Parameters
    if parsed_comment['parameters']:
        md += '#### ⚙️ Parameters\n\n'
        md += '| Parameter | Type | Description |\n'
        md += '|-----------|------|-------------|\n'
        for param in parsed_comment['parameters']:
            md += f'| `{param["name"]}` | **{param["type"]}** | {param["description"]} |\n'
        md += '\n'

    # Returns
    if parsed_comment['returns']:
        md += f'#### ↩️ Returns\n* {parsed_comment["returns"]}\n\n'

    # Realm
    if parsed_comment['realm']:
        md += f'#### 🌐 Realm\n{parsed_comment["realm"]}\n\n'

    # Explanation (for panels)
    if parsed_comment.get('explanation'):
        md += f'#### 📋 Purpose\n{parsed_comment["explanation"]}\n\n'

    # Example Usage
    if parsed_comment['examples']:
        md += '#### 💡 Example Usage\n\n'
        for example in parsed_comment['examples']:
            complexity = example.get('complexity', 'example').lower()
            # Map complexity to emoji headers
            if complexity == 'low':
                md += '#### 🔰 Low Complexity\n'
            elif complexity == 'medium':
                md += '#### 📊 Medium Complexity\n'
            elif complexity == 'high':
                md += '#### ⚙️ High Complexity\n'
            else:
                # For generic examples without complexity, skip the header
                pass
            md += '```lua\n'
            formatted_code = format_lua_code(example['code'])
            md += '\n'.join(formatted_code)
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
        if any(header in comment_text for header in ['Purpose:', 'When Called:', 'When Used:', 'Parameters:', 'Returns:', 'Realm:', 'Explanation of Panel:', 'Example Usage:', 'Example Item:']):
            comment_blocks.append(comment_text)
        # Check if this is a file header (first comment block that doesn't have function structure or overview)
        elif file_header is None and not any(header in comment_text for header in ['Purpose:', 'When Called:', 'Parameters:', 'Returns:', 'Realm:', 'Example Usage:', 'Overview:', 'Example Item:']):
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
    functions = find_functions_in_file(file_path, is_library)

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
            # Skip documenting core hook implementations in module files
            # These should only be documented in the central hooks documentation
            if is_library and 'modules' in str(file_path):
                func_name = func['name']
                if ':' in func_name:
                    hook_name = func_name.split(':', 1)[1]
                    if hook_name in CORE_HOOKS:
                        print(f"  Skipping hook implementation: {func_name} (documented centrally)")
                        continue

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
            f.write('Overview\n\n')
            # Parse the overview section (remove "Overview:" and format)
            overview_content = parse_overview_section(overview_section)
            f.write(overview_content)
            f.write('\n\n')
            f.write('---\n\n')

        for section in sections:
            f.write(section)
            f.write('---\n\n')

    print(f"  Generated {output_filename}")


def _read_file_text(file_path: Path) -> str:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return ''


def parse_definition_property_blocks(file_path: Path, entity_prefixes: Tuple[str, ...]) -> List[Dict[str, object]]:
    """
    Parse comment blocks that document properties or callbacks for definition files (CLASS/FACTION/MODULE).

    Returns list of entries with keys: name, parsed_comment
    """
    text = _read_file_text(file_path)
    if not text:
        return []

    entries: List[Dict[str, object]] = []

    # Find all comment blocks with their positions
    for match in re.finditer(r'--\[\[.*?\]\]', text, re.DOTALL):
        block_text = match.group(0)
        # Only process structured comment blocks
        if not any(header in block_text for header in ['Purpose:', 'When Called:', 'When Used:', 'Parameters:', 'Returns:', 'Realm:', 'Explanation of Panel:', 'Example Usage:', 'Example Item:']):
            continue

        # Find the property name from the line immediately following this comment block
        tail = text[match.end():]
        prop_name = None
        for ln in tail.splitlines():
            s = ln.strip()
            if not s:
                continue
            if s.startswith('--'):
                continue
            # Extract property name from patterns like CLASS.name, ITEM.name, etc.
            # Also handle function definitions like function CLASS:OnCanBe
            for prefix in entity_prefixes:
                # Check for property assignments: CLASS.name =
                m = re.match(rf'{prefix}\.([A-Za-z_][\w]*)', s)
                if m:
                    prop_name = m.group(1)  # Only the property name (suffix)
                    break
                # Check for function definitions: function CLASS:FunctionName
                m = re.match(rf'function\s+{prefix}:([A-Za-z_][\w]*)', s)
                if m:
                    prop_name = m.group(1)  # Only the function name (suffix)
                    break
            if prop_name:
                break

        if prop_name:
            parsed = parse_comment_block(block_text)
            entries.append({'name': prop_name, 'parsed': parsed})

    # Also extract comprehensive example sections (Example Class, Example Faction, Example Item)
    example_patterns = [
        ('Example Class:', 'example_class'),
        ('Example Faction:', 'example_faction'),
        ('Example Item:', 'example_item')
    ]

    for pattern, entry_name in example_patterns:
        # Find the comprehensive example section
        example_match = re.search(rf'--\[\[.*?\b{re.escape(pattern)}.*?\]\]', text, re.DOTALL)
        if example_match:
            example_block = example_match.group(0)
            # Parse the example block to extract the code
            parsed_example = parse_comment_block(example_block)
            if parsed_example.get('examples'):
                # Create a special entry for the comprehensive example
                entries.append({
                    'name': entry_name,
                    'parsed': parsed_example,
                    'is_comprehensive_example': True
                })

    return entries


def generate_markdown_for_definition_entries(title: str, subtitle: str, overview_section: Optional[str], entries: List[Dict[str, object]]) -> str:
    md_parts: List[str] = []
    md_parts.append(f'# {title}\n\n')
    if subtitle:
        md_parts.append(subtitle + '\n\n')
    md_parts.append('---\n\n')

    if overview_section:
        md_parts.append('Overview\n\n')
        md_parts.append(parse_overview_section(overview_section) + '\n\n')
        md_parts.append('---\n\n')

    # Separate regular entries from comprehensive examples
    regular_entries = []
    comprehensive_examples = []

    for entry in entries:
        if entry.get('is_comprehensive_example', False):
            comprehensive_examples.append(entry)
        else:
            regular_entries.append(entry)

    # Process regular entries
    for entry in regular_entries:
        name = entry['name']
        parsed = entry['parsed']
        # Use existing function section generator for consistent field rendering
        md_parts.append(f'### {name}\n\n')
        if parsed.get('purpose'):
            md_parts.append(f'#### 📋 Purpose\n{parsed["purpose"]}\n\n')
        # When Called / When Used
        if parsed.get('when_called'):
            md_parts.append(f'#### ⏰ When Called\n{parsed["when_called"]}\n\n')
        elif parsed.get('when_used'):
            md_parts.append(f'#### ⏰ When Called\n{parsed["when_used"]}\n\n')
        if parsed.get('realm'):
            md_parts.append(f'#### 🌐 Realm\n{parsed["realm"]}\n\n')
        if parsed.get('explanation'):
            md_parts.append(f'#### 📋 Purpose\n{parsed["explanation"]}\n\n')
        if parsed.get('parameters'):
            md_parts.append('#### ⚙️ Parameters\n\n')
            md_parts.append('| Parameter | Type | Description |\n')
            md_parts.append('|-----------|------|-------------|\n')
            for p in parsed['parameters']:
                md_parts.append(f'| `{p["name"]}` | **{p["type"]}** | {p["description"]} |\n')
            md_parts.append('\n')
        if parsed.get('returns'):
            md_parts.append(f'#### ↩️ Returns\n* {parsed["returns"]}\n\n')
        if parsed.get('examples'):
            md_parts.append('#### 💡 Example Usage\n\n')
            for example in parsed['examples']:
                complexity = example.get('complexity', 'example').lower()
                # Map complexity to emoji headers
                if complexity == 'low':
                    md_parts.append('#### 🔰 Low Complexity\n')
                elif complexity == 'medium':
                    md_parts.append('#### 📊 Medium Complexity\n')
                elif complexity == 'high':
                    md_parts.append('#### ⚙️ High Complexity\n')
                else:
                    # For generic examples without complexity, skip the header
                    pass
                md_parts.append('```lua\n')
                formatted_code = format_lua_code(example.get('code', []))
                md_parts.append('\n'.join(formatted_code))
                md_parts.append('\n```\n\n')
        md_parts.append('---\n\n')

    # Add comprehensive examples at the end
    if comprehensive_examples:
        md_parts.append('## Complete Examples\n\n')
        md_parts.append('The following examples demonstrate how to use all the properties and methods together to create complete definitions.\n\n')

        for example_entry in comprehensive_examples:
            parsed = example_entry['parsed']
            entry_name = example_entry['name']

            # Set appropriate title based on entry type
            if entry_name == 'example_class':
                example_title = "Complete Class Example"
                description = "Below is a comprehensive example showing how to define a complete class with all available properties and methods. This example creates a \"Police Officer\" class that demonstrates typical usage of the class system."
            elif entry_name == 'example_faction':
                example_title = "Complete Faction Example"
                description = "Below is a comprehensive example showing how to define a complete faction with all available properties and methods."
            elif entry_name == 'example_item':
                example_title = "Complete Item Example"
                description = "Below is a comprehensive example showing how to define a complete item with all available properties and methods."
            else:
                example_title = "Complete Example"
                description = parsed.get('purpose', '')

            md_parts.append(f'### {example_title}\n\n')

            # Add description
            if description:
                md_parts.append(f'{description}\n\n')

            # Add the example code
            if parsed.get('examples'):
                for example in parsed['examples']:
                    md_parts.append('```lua\n')
                    formatted_code = format_lua_code(example.get('code', []))
                    md_parts.append('\n'.join(formatted_code))
                    md_parts.append('\n```\n\n')

            md_parts.append('---\n\n')

    return ''.join(md_parts)


def generate_documentation_for_panels(file_path: Path, output_path: Path) -> None:
    """
    Panels file pattern:
      [header]
      [overview]
      Repeat: [comment block with Purpose/Explanation/When Used] + [next line: PanelName]
    """
    print(f"Processing {file_path}")
    text = _read_file_text(file_path)
    if not text:
        return

    # Identify blocks
    # Reuse comment block finder to obtain header/overview separation
    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)

    # Extract panel names that follow each block by scanning the file
    lines = text.splitlines()
    block_positions: List[Tuple[int, int, str]] = []  # (start_idx, end_idx, block_text)
    for match in re.finditer(r'--\[\[.*?\]\]', text, re.DOTALL):
        block_positions.append((match.start(), match.end(), match.group(0)))

    entries: List[Dict[str, object]] = []
    for start, end, block_text in block_positions:
        # Associate only structured blocks (contain our fields)
        if not any(k in block_text for k in ['Purpose:', 'Explanation of Panel:', 'When Used:']):
            continue

        # Find the next non-empty, non-comment line after this block for the panel name
        tail = text[end:]
        panel_name = None
        for ln in tail.splitlines():
            s = ln.strip()
            if not s:
                continue
            if s.startswith('--'):
                continue
            # The first identifier line is the panel name (e.g., liaCharacterBiography)
            panel_name = s
            break

        parsed = parse_comment_block(block_text)
        if panel_name:
            entries.append({'name': panel_name, 'parsed': parsed})

    # Title/subtitle
    filename = file_path.stem
    title = filename.title()
    subtitle = 'This page documents available VGUI panels.'
    if file_header:
        parsed_header = parse_file_header(file_header)
        if '\n\n' in parsed_header:
            parts = parsed_header.split('\n\n', 1)
            title = parts[0].replace('**', '').replace('*', '').strip()
            if len(parts) > 1 and parts[1].strip():
                subtitle = parts[1].strip()

    md = generate_markdown_for_definition_entries(title, subtitle, overview_section, entries)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(md)
    print(f"  Generated {output_path.name}")


def generate_documentation_for_definitions_file(file_path: Path, output_dir: Path) -> None:
    name = file_path.stem.lower()
    output_filename = f'{name}.md'
    
    # Check if this is an item definition file
    if file_path.parent.name == 'items':
        # Put item files in an items subdirectory
        output_path = output_dir / 'items' / output_filename
    else:
        output_path = output_dir / output_filename

    if name == 'panels':
        generate_documentation_for_panels(file_path, output_path)
        return

    # Check if this is an item definition file
    if file_path.parent.name == 'items':
        # This is an item definition file
        entity_prefixes: Tuple[str, ...] = ('ITEM',)
    elif name == 'attributes':
        # Attributes file uses ATTRIBUTE prefix
        entity_prefixes: Tuple[str, ...] = ('ATTRIBUTE',)
    else:
        # Generic CLASS/FACTION/MODULE definitions
        entity_prefixes: Tuple[str, ...] = ('CLASS', 'FACTION', 'MODULE')
    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)
    entries = parse_definition_property_blocks(file_path, entity_prefixes)

    # Title/subtitle
    title = name.title()
    subtitle = f'This page documents the {name} definitions.'
    if file_header:
        parsed_header = parse_file_header(file_header)
        if '\n\n' in parsed_header:
            parts = parsed_header.split('\n\n', 1)
            title = parts[0].replace('**', '').replace('*', '').strip()
            if len(parts) > 1 and parts[1].strip():
                subtitle = parts[1].strip()

    md = generate_markdown_for_definition_entries(title, subtitle, overview_section, entries)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(md)
    print(f"  Generated {output_path.name}")


def generate_documentation_for_hooks_file(file_path: Path, output_dir: Path) -> None:
    print(f"Processing {file_path}")
    filename = file_path.stem
    output_filename = f'{filename}.md'
    output_path = output_dir / output_filename

    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)
    functions = find_functions_in_file(file_path, is_library=False)
    if not functions:
        print(f"  No hooks found in {file_path}")
        return

    sections: List[str] = []
    for func in functions:
        parsed = parse_comment_block(func['comment'])
        # For hooks we do not prefix with lia.
        sections.append(generate_markdown_for_function(func['name'], parsed, is_library=False))

    title = filename.title()
    subtitle = f'This page documents the {filename} hooks.'
    if file_header:
        parsed_header = parse_file_header(file_header)
        if '\n\n' in parsed_header:
            parts = parsed_header.split('\n\n', 1)
            title = parts[0].replace('**', '').replace('*', '').strip()
            if len(parts) > 1 and parts[1].strip():
                subtitle = parts[1].strip()

    output_dir.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(f'# {title}\n\n')
        f.write(subtitle + '\n\n')
        f.write('---\n\n')
        if overview_section:
            f.write('Overview\n\n')
            f.write(parse_overview_section(overview_section) + '\n\n')
            f.write('---\n\n')
        for section in sections:
            f.write(section)
            f.write('---\n\n')
    print(f"  Generated {output_filename}")


def main():
    parser = argparse.ArgumentParser(description='Generate documentation from Lua comment blocks')
    parser.add_argument('type', choices=['meta', 'library', 'definitions', 'hooks'], help='Type of files to process')
    parser.add_argument('files', nargs='*', help='Specific files to process (if empty, processes defaults per type)')

    args = parser.parse_args()

    # Set up paths
    script_dir = Path(__file__).parent
    base_dir = script_dir / 'gamemode' / 'core'
    modules_dir = script_dir / 'gamemode' / 'modules'
    docs_definitions_dir = script_dir / 'gamemode' / 'docs' / 'definitions'
    docs_hooks_dir = script_dir / 'gamemode' / 'docs' / 'hooks'

    if args.type == 'meta':
        input_dir = base_dir / 'meta'
        output_dir = script_dir / 'documentation' / 'docs' / 'meta'
    elif args.type == 'library':
        input_dir = base_dir / 'libraries'
        output_dir = script_dir / 'documentation' / 'docs' / 'libraries'
    elif args.type == 'definitions':
        input_dir = docs_definitions_dir
        output_dir = script_dir / 'documentation' / 'docs' / 'definitions'
    elif args.type == 'hooks':
        input_dir = docs_hooks_dir
        output_dir = script_dir / 'documentation' / 'docs' / 'hooks'

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
        if args.type in ('meta', 'library'):
            # Process core files
            files_to_process.extend(list(input_dir.glob('*.lua')))

            # Process module library files (for library type only)
            if args.type == 'library':
                for module_dir in modules_dir.iterdir():
                    if module_dir.is_dir():
                        module_lib_dir = module_dir / 'libraries'
                        if module_lib_dir.exists():
                            files_to_process.extend(list(module_lib_dir.glob('*.lua')))
        elif args.type == 'definitions':
            # Specific known definition files
            for name in ('panels.lua', 'faction.lua', 'module.lua', 'items.lua', 'class.lua', 'attributes.lua'):
                p = input_dir / name
                if p.exists():
                    files_to_process.append(str(p))
            
            # Process items subdirectory
            items_dir = input_dir / 'items'
            if items_dir.exists():
                for item_file in items_dir.glob('*.lua'):
                    files_to_process.append(str(item_file))
        elif args.type == 'hooks':
            for name in ('client.lua', 'server.lua', 'shared.lua'):
                p = input_dir / name
                if p.exists():
                    files_to_process.append(str(p))

    if not files_to_process:
        print(f"No files found in {input_dir}")
        return

    print(f"Processing {len(files_to_process)} {args.type} files...")

    # Process each file
    for file_path in files_to_process:
        if args.type in ('meta', 'library') and str(file_path).endswith('.lua'):
            generate_documentation_for_file(file_path, output_dir, args.type == 'library')
        elif args.type == 'definitions' and str(file_path).endswith('.lua'):
            generate_documentation_for_definitions_file(Path(file_path), output_dir)
        elif args.type == 'hooks' and str(file_path).endswith('.lua'):
            generate_documentation_for_hooks_file(Path(file_path), output_dir)

    print("Documentation generation complete!")


if __name__ == '__main__':
    main()