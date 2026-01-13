#!/usr/bin/env python3

import os
import re
import sys
import argparse
from pathlib import Path
from typing import List, Dict, Tuple, Optional

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
    lines = comment_text.strip().split('\n')
    parsed = {
        'purpose': '',
        'when_called': '',
        'parameters': [],
        'returns': '',
        'realm': '',
        'examples': [],
        'explanation': '',
        'when_used': ''
    }

    current_section = None
    current_example = None
    example_complexity = None
    section_content = []
    pending_parameter = None  # Track pending parameter for new format (name, type)

    def finalize_current_section():
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

        if line.startswith('--[[') or line.startswith('--]]') or line.strip() in ['[[', ']]', '--[[', '--]]'] or not line:
            continue

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
            finalize_current_section()
            current_section = 'when_used'
            inline_content = line[10:].strip()
            if inline_content:
                section_content.append(inline_content)
        elif line.startswith('Parameters:'):
            finalize_current_section()
            current_section = 'parameters'
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
                elif len(original_line) > len(original_line.lstrip()):
                    m = re.match(r'^\s+([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*$', original_line)
                    if m:
                        if pending_parameter:
                            parsed['parameters'].append({
                                'name': pending_parameter['name'],
                                'type': pending_parameter['type'],
                                'description': ''
                            })
                        pending_parameter = {'name': m.group(1).strip(), 'type': m.group(2).strip()}
                    else:
                        if pending_parameter:
                            desc = line.strip()
                            parsed['parameters'].append({
                                'name': pending_parameter['name'],
                                'type': pending_parameter['type'],
                                'description': desc
                            })
                            pending_parameter = None
                            m = re.match(r'^\s+([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*-\s*(.+)', original_line)
                            if m:
                                parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                            else:
                                m = re.match(r'^\s+([A-Za-z_][\w]*)\s*-\s*(.+)', original_line)
                                if m:
                                    parsed['parameters'].append({'name': m.group(1).strip(), 'type': 'unknown', 'description': m.group(2).strip()})
                else:
                    current_section = None
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
                if current_section == 'parameters':
                    m = re.match(r'-\s*([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*:\s*(.+)', line)
                    if m:
                        parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                    else:
                        m = re.match(r'-\s*([A-Za-z_][\w]*)\s*:\s*(.+)', line)
                        if m:
                            parsed['parameters'].append({'name': m.group(1).strip(), 'type': 'unknown', 'description': m.group(2).strip()})
                        else:
                            m = re.match(r'([A-Za-z_][\w]*)\s*\(([^)]+)\)\s*:\s*(.+)', line)
                            if m:
                                parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                            else:
                                m = re.match(r'\s*([^\-\s]+)\s*-\s*([^:]+):\s*(.+)', line)
                                if m:
                                    parsed['parameters'].append({'name': m.group(1).strip(), 'type': m.group(2).strip(), 'description': m.group(3).strip()})
                                else:
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
        elif line.startswith('Example Item:') or line.startswith('Example Class:') or line.startswith('Example Faction:'):
            finalize_current_section()
            current_section = 'examples'
        elif current_section in ['purpose', 'when_called', 'when_used', 'returns', 'realm', 'explanation']:
            if line.strip():
                section_content.append(line)
        elif current_section == 'examples':
            if line.strip() in ['Example Item:', 'Example Class:', 'Example Faction:']:
                continue
            complexity_match = None
            if not (current_example and current_example.get('in_code_block', False)):
                complexity_match = re.match(r'(\w+)(?:\s+Complexity)?(?:\s+Example)?:', line)
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
                current_example = {
                    'complexity': 'example',
                    'code': []
                }
                current_example['in_code_block'] = True
            elif current_example and line.strip().startswith('```'):
                if not current_example.get('in_code_block', False):
                    current_example['in_code_block'] = True
                else:
                    current_example['in_code_block'] = False
                    current_example['code'].append('')
            elif current_example and current_example.get('in_code_block', False):
                if line.strip().startswith('--') and ':' in line:
                    complexity_match = re.match(r'--\s*(\w+):', line.strip())
                    if complexity_match and complexity_match.group(1).lower() in ['low', 'medium', 'high']:
                        current_example['complexity'] = complexity_match.group(1).lower()
                current_example['code'].append(original_line.rstrip())

    finalize_current_section()

    if pending_parameter:
        parsed['parameters'].append({
            'name': pending_parameter['name'],
            'type': pending_parameter['type'],
            'description': ''
        })

    if current_example:
        parsed['examples'].append(current_example)

    return parsed


def parse_file_header(header_text):
    content = re.sub(r'--\[\[(.*)\]\]', r'\1', header_text, flags=re.DOTALL).strip()
    lines = content.split('\n')
    formatted_lines = []

    for line in lines:
        line = line.strip()
        if not line:
            continue
        line = re.sub(r'^--\s*', '', line)
        if line:
            formatted_lines.append(line)

    if len(formatted_lines) >= 2:
        title = formatted_lines[0]
        short_description = formatted_lines[1]
        return f"**{title}**\n\n{short_description}"
    elif len(formatted_lines) == 1:
        title = formatted_lines[0]
        return f"**{title}**"
    return ""


def parse_folder_directives(file_content):
    lines = file_content.split('\n')
    folder = None
    filename = None
    append = False

    in_comment = False
    for line in lines:
        stripped = line.strip()

        if stripped.startswith('--[['):
            in_comment = True
            continue
        elif stripped.startswith(']]'):
            break

        if in_comment:
            line_content = re.sub(r'^--\s*', '', line).strip()

            if line_content.startswith('Folder:'):
                folder = line_content.replace('Folder:', '').strip()
            elif line_content.startswith('File:'):
                filename = line_content.replace('File:', '').strip()
            elif line_content.startswith('Append:'):
                append_value = line_content.replace('Append:', '').strip().lower()
                append = append_value in ('true', 'yes', '1')

    return folder, filename, append


def format_lua_code(code_lines):
    if not code_lines:
        return code_lines

    min_indent = float('inf')
    for line in code_lines:
        stripped = line.strip()
        if stripped:
            indent = len(line) - len(line.lstrip())
            min_indent = min(min_indent, indent)

    if min_indent == float('inf') or min_indent == 0:
        final_lines = []
        for line in code_lines:
            if line.strip():
                final_lines.append('    ' + line)
            else:
                final_lines.append('')
        return final_lines

    formatted_lines = []
    for line in code_lines:
        stripped = line.strip()
        if stripped:
            if len(line) >= min_indent:
                formatted_lines.append(line[min_indent:])
            else:
                formatted_lines.append(line)
        else:
            formatted_lines.append('')

    final_lines = []
    for line in formatted_lines:
        if line.strip():
            final_lines.append('    ' + line)
        else:
            final_lines.append('')

    return final_lines


def parse_overview_section(overview_text):
    content = re.sub(r'--\[\[(.*)\]\]', r'\1', overview_text, flags=re.DOTALL).strip()
    content = re.sub(r'^\s*(Overview|Improvements Done):\s*', '', content, flags=re.MULTILINE)

    raw_lines = content.split('\n')
    formatted_lines = []

    for raw in raw_lines:
        line = re.sub(r'^\s*--\s*', '', raw.rstrip())
        if not line.strip():
            formatted_lines.append('')
            continue
        line = re.sub(r'[ \t]+', ' ', line.strip())
        formatted_lines.append(line)

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

    result = '\n'.join(out_lines).strip()
    result = re.sub(r'\n{3,}', '\n\n', result)
    return result


def extract_function_name_from_comment(comment_text, file_path):
    filename = Path(file_path).stem
    return filename


def find_functions_in_file(file_path, is_library=False):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return []

    functions = []

    comment_pattern = r'--\[\[.*?\]\]'
    comments = []
    for match in re.finditer(comment_pattern, content, re.DOTALL):
        comments.append((match.start(), match.end(), match.group(0)))

    func_pattern = r'(?<!local\s)function\s+([\w\.:]+)\s*\('
    for match in re.finditer(func_pattern, content):
        func_name = match.group(1)
        func_line = content[:match.start()].count('\n') + 1

        if is_library and not func_name.startswith('lia.'):
            continue

        preceding_comment = None
        for comment_start, comment_end, comment_text in comments:
            comment_line = content[:comment_start].count('\n') + 1
            if comment_line < func_line and (preceding_comment is None or comment_line > preceding_comment[0]):
                if any(header in comment_text for header in ['Purpose:', 'When Called:', 'When Used:', 'Parameters:', 'Returns:', 'Realm:', 'Explanation of Panel:', 'Example Usage:']):
                    preceding_comment = (comment_line, comment_text)

        if preceding_comment:
            functions.append({
                'name': func_name,
                'comment': preceding_comment[1]
            })

    return functions


def generate_markdown_for_function(function_name, parsed_comment, is_library=False):
    display_name = function_name
    if is_library and not function_name.startswith('lia.'):
        display_name = f'lia.{function_name}'
    elif not is_library and ':' in function_name:
        display_name = function_name.split(':', 1)[1]
    elif is_library and function_name.startswith('lia.'):
        display_name = function_name

    md = f'### {display_name}\n\n'

    if parsed_comment['purpose']:
        md += f'#### 📋 Purpose\n{parsed_comment["purpose"]}\n\n'

    if parsed_comment['when_called']:
        md += f'#### ⏰ When Called\n{parsed_comment["when_called"]}\n\n'
    elif parsed_comment.get('when_used'):
        md += f'#### ⏰ When Called\n{parsed_comment["when_used"]}\n\n'

    if parsed_comment['parameters']:
        md += '#### ⚙️ Parameters\n\n'
        md += '| Parameter | Type | Description |\n'
        md += '|-----------|------|-------------|\n'
        for param in parsed_comment['parameters']:
            md += f'| `{param["name"]}` | **{param["type"]}** | {param["description"]} |\n'
        md += '\n'

    if parsed_comment['returns']:
        md += f'#### ↩️ Returns\n* {parsed_comment["returns"]}\n\n'

    if parsed_comment['realm']:
        md += f'#### 🌐 Realm\n{parsed_comment["realm"]}\n\n'

    if parsed_comment.get('explanation'):
        md += f'#### 📋 Purpose\n{parsed_comment["explanation"]}\n\n'

    if parsed_comment['examples']:
        md += '#### 💡 Example Usage\n\n'
        for example in parsed_comment['examples']:
            md += '```lua\n'
            formatted_code = format_lua_code(example['code'])
            md += '\n'.join(formatted_code)
            md += '\n```\n\n'

    return md


def find_comment_blocks_in_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return [], None, None

    comment_pattern = r'--\[\[.*?\]\]'
    all_comment_blocks = []
    file_header = None
    overview_section = None

    for match in re.finditer(comment_pattern, content, re.DOTALL):
        comment_text = match.group(0)
        all_comment_blocks.append(comment_text)

        if file_header is None and not any(header in comment_text for header in ['Purpose:', 'When Called:', 'Parameters:', 'Returns:', 'Realm:', 'Example Usage:', 'Overview:', 'Improvements Done:', 'Example Item:', 'Folder:', 'File:']):
            file_header = comment_text
        elif ('Overview:' in comment_text or 'Improvements Done:' in comment_text) and overview_section is None:
            overview_section = comment_text

    return all_comment_blocks, file_header, overview_section


def generate_documentation_for_file(file_path, output_dir, is_library=False, base_docs_dir=None, force=False):
    print(f"Processing {file_path}")

    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            file_content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return

    custom_folder, custom_filename, append = parse_folder_directives(file_content)
    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)

    if file_header and ('Folder:' in file_header or 'File:' in file_header):
        for block in comment_blocks:
            if block != file_header and not ('Folder:' in block or 'File:' in block):
                file_header = block
                break

    functions = find_functions_in_file(file_path, is_library)

    if not functions and not file_header and not overview_section:
        print(f"  No structured functions or documentation content found in {file_path}")
        return

    if custom_folder and custom_filename and base_docs_dir:
        output_path = base_docs_dir / custom_folder / custom_filename
        print(f"  Using custom output: {custom_folder}/{custom_filename}")
    else:
        filename = Path(file_path).stem

        if is_library and 'modules' in str(file_path):
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

    if output_path.exists() and output_path.stat().st_size > 0 and not force:
        print(f"  {output_path.name} already exists, skipping")
        return

    sections = []

    for func in functions:
        parsed = parse_comment_block(func['comment'])
        if parsed['purpose']:
            if is_library and 'modules' in str(file_path):
                func_name = func['name']
                if ':' in func_name:
                    hook_name = func_name.split(':', 1)[1]
                    if hook_name in CORE_HOOKS:
                        print(f"  Skipping hook implementation: {func_name} (documented centrally)")
                        continue

            section = generate_markdown_for_function(func['name'], parsed, is_library)
            sections.append(section)

    if not sections and not file_header and not overview_section:
        print(f"  No valid function documentation or content found in {file_path}")
        return

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_filename = output_path.name

    file_mode = 'a' if append else 'w'
    with open(output_path, file_mode, encoding='utf-8') as f:
        if not append:
            if custom_filename:
                display_name = custom_filename.replace('.md', '').title()
            else:
                display_name = Path(file_path).stem.title()

            title = display_name
            subtitle = f'This page documents the functions and methods in the { "Lilia library" if is_library else "meta table" }.'

            if file_header:
                parsed_header = parse_file_header(file_header)
                if '\n\n' in parsed_header:
                    parts = parsed_header.split('\n\n', 1)
                    title = parts[0].replace('**', '').replace('*', '').strip()
                    if len(parts) > 1 and parts[1].strip():
                        subtitle = parts[1].strip()

            f.write(f'# {title}\n\n')
            f.write(f'{subtitle}\n\n')
            f.write('---\n\n')

            if overview_section:
                f.write('Overview\n\n')
                overview_content = parse_overview_section(overview_section)
                f.write(overview_content)
                f.write('\n\n')
                f.write('---\n\n')

        for section in sections:
            f.write(section)
            f.write('---\n\n')

    print(f"  Generated {output_path.name}")


def _read_file_text(file_path: Path) -> str:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return ''


def parse_definition_property_blocks(file_path: Path, entity_prefixes: Tuple[str, ...]) -> List[Dict[str, object]]:
    text = _read_file_text(file_path)
    if not text:
        return []

    entries: List[Dict[str, object]] = []

    for match in re.finditer(r'--\[\[.*?\]\]', text, re.DOTALL):
        block_text = match.group(0)
        if any(header in block_text for header in ['Example Item:', 'Example Class:', 'Example Faction:']):
            continue
        if not any(header in block_text for header in ['Purpose:', 'When Called:', 'When Used:', 'Parameters:', 'Returns:', 'Realm:', 'Explanation of Panel:', 'Example Usage:']):
            continue

        tail = text[match.end():]
        prop_name = None
        for ln in tail.splitlines():
            s = ln.strip()
            if not s:
                continue
            if s.startswith('--'):
                continue
            for prefix in entity_prefixes:
                m = re.match(rf'{prefix}\.([A-Za-z_][\w]*)', s)
                if m:
                    prop_name = m.group(1)
                    break
                m = re.match(rf'function\s+{prefix}:([A-Za-z_][\w]*)', s)
                if m:
                    prop_name = m.group(1)
                    break
            if prop_name:
                break

        if prop_name:
            parsed = parse_comment_block(block_text)
            entries.append({'name': prop_name, 'parsed': parsed})

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

    for entry in entries:
        name = entry['name']
        parsed = entry['parsed']
        md_parts.append(f'### {name}\n\n')
        if parsed.get('purpose'):
            md_parts.append(f'#### 📋 Purpose\n{parsed["purpose"]}\n\n')
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
                md_parts.append('```lua\n')
                formatted_code = format_lua_code(example.get('code', []))
                md_parts.append('\n'.join(formatted_code))
                md_parts.append('\n```\n\n')
        md_parts.append('---\n\n')

    return ''.join(md_parts)


def generate_documentation_for_panels(file_path: Path, output_path: Path) -> None:
    print(f"Processing {file_path}")
    text = _read_file_text(file_path)
    if not text:
        return

    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)

    lines = text.splitlines()
    block_positions: List[Tuple[int, int, str]] = []
    for match in re.finditer(r'--\[\[.*?\]\]', text, re.DOTALL):
        block_positions.append((match.start(), match.end(), match.group(0)))

    entries: List[Dict[str, object]] = []
    for start, end, block_text in block_positions:
        if not any(k in block_text for k in ['Purpose:', 'Explanation of Panel:', 'When Used:']):
            continue

        tail = text[end:]
        panel_name = None
        for ln in tail.splitlines():
            s = ln.strip()
            if not s:
                continue
            if s.startswith('--'):
                continue
            panel_name = s
            break

        parsed = parse_comment_block(block_text)
        if panel_name:
            entries.append({'name': panel_name, 'parsed': parsed})

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


def generate_documentation_for_definitions_file(file_path: Path, output_dir: Path, base_docs_dir: Path) -> None:
    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            file_content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return

    is_item_file = 'items' in str(file_path)
    custom_folder, custom_filename, append = parse_folder_directives(file_content)

    if custom_folder and custom_filename:
        output_path = base_docs_dir / custom_folder / custom_filename
        print(f"  Using custom output: {custom_folder}/{custom_filename}")
    else:
        name = file_path.stem.lower()
        output_filename = f'{name}.md'

        if is_item_file:
            output_path = output_dir / 'items' / output_filename
        else:
            output_path = output_dir / output_filename

    if file_path.stem.lower() == 'panels':
        generate_documentation_for_panels(file_path, output_path)
        return

    if is_item_file:
        entity_prefixes: Tuple[str, ...] = ('ITEM',)
    elif file_path.stem.lower() == 'attributes':
        entity_prefixes: Tuple[str, ...] = ('ATTRIBUTE',)
    else:
        entity_prefixes: Tuple[str, ...] = ('CLASS', 'FACTION', 'MODULE')

    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)

    if is_item_file:
        content_blocks = []
        for block in comment_blocks:
            if not ('Folder:' in block or 'File:' in block):
                content_blocks.append(block)

        if len(content_blocks) >= 2:
            file_header = content_blocks[0]
            overview_section = content_blocks[1]
        elif len(content_blocks) == 1:
            file_header = content_blocks[0]
    else:
        if file_header and ('Folder:' in file_header or 'File:' in file_header):
            for block in comment_blocks:
                if block != file_header and not ('Folder:' in block or 'File:' in block):
                    file_header = block
                    break

    entries = parse_definition_property_blocks(file_path, entity_prefixes)

    if custom_filename:
        display_name = custom_filename.replace('.md', '').title()
    else:
        display_name = file_path.stem.lower().title()

    title = display_name
    subtitle = f'This page documents the {display_name.lower()} definitions.'

    if file_header:
        if is_item_file:
            parsed_header = parse_file_header(file_header)
            if '\n\n' in parsed_header:
                parts = parsed_header.split('\n\n', 1)
                title = parts[0].replace('**', '').replace('*', '').strip()
                if len(parts) > 1 and parts[1].strip():
                    subtitle = parts[1].strip()
        else:
            parsed_header = parse_file_header(file_header)
            if '\n\n' in parsed_header:
                parts = parsed_header.split('\n\n', 1)
                title = parts[0].replace('**', '').replace('*', '').strip()
                if len(parts) > 1 and parts[1].strip():
                    subtitle = parts[1].strip()

    final_overview = overview_section
    md = generate_markdown_for_definition_entries(title, subtitle, final_overview, entries)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    file_mode = 'a' if append else 'w'
    with open(output_path, file_mode, encoding='utf-8') as f:
        f.write(md)
    print(f"  Generated {output_path.name}")


def generate_documentation_for_hooks_file(file_path: Path, output_dir: Path, base_docs_dir: Path) -> None:
    print(f"Processing {file_path}")

    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            file_content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return

    custom_folder, custom_filename, append = parse_folder_directives(file_content)

    if custom_folder and custom_filename:
        output_path = base_docs_dir / custom_folder / custom_filename
        print(f"  Using custom output: {custom_folder}/{custom_filename}")
    else:
        filename = file_path.stem
        output_filename = f'{filename}.md'
        output_path = output_dir / output_filename

    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)

    functions = find_functions_in_file(file_path, is_library=False)

    if not functions and not file_header and not overview_section:
        print(f"  No hooks or documentation content found in {file_path}")
        return

    sections: List[str] = []
    for func in functions:
        parsed = parse_comment_block(func['comment'])
        sections.append(generate_markdown_for_function(func['name'], parsed, is_library=False))

    if custom_filename:
        display_name = custom_filename.replace('.md', '').title()
    else:
        display_name = file_path.stem.title()

    title = display_name
    subtitle = f'This page documents the {display_name.lower()} hooks.'
    if file_header:
        parsed_header = parse_file_header(file_header)
        if '\n\n' in parsed_header:
            parts = parsed_header.split('\n\n', 1)
            title = parts[0].replace('**', '').replace('*', '').strip()
            if len(parts) > 1 and parts[1].strip():
                subtitle = parts[1].strip()

    output_path.parent.mkdir(parents=True, exist_ok=True)
    file_mode = 'a' if append else 'w'
    with open(output_path, file_mode, encoding='utf-8') as f:
        if not append:
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
    print(f"  Generated {output_path.name}")


def main():
    parser = argparse.ArgumentParser(description='Generate documentation from Lua comment blocks')
    parser.add_argument('type', choices=['meta', 'library', 'compatibility', 'definitions', 'hooks'], help='Type of files to process')
    parser.add_argument('files', nargs='*', help='Specific files to process (if empty, processes defaults per type)')
    parser.add_argument('--force', action='store_true', help='Overwrite existing documentation files')

    args = parser.parse_args()

    script_dir = Path(__file__).parent
    base_docs_dir = script_dir / 'documentation' / 'docs'
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
    elif args.type == 'compatibility':
        input_dir = base_dir / 'libraries' / 'compatibility'
        output_dir = script_dir / 'documentation' / 'docs' / 'compatibility'
    elif args.type == 'definitions':
        input_dir = docs_definitions_dir
        output_dir = script_dir / 'documentation' / 'docs' / 'definitions'
    elif args.type == 'hooks':
        input_dir = docs_hooks_dir
        output_dir = script_dir / 'documentation' / 'docs' / 'hooks'

    output_dir.mkdir(parents=True, exist_ok=True)

    files_to_process = []

    if args.files:
        for file_pattern in args.files:
            import glob
            matches = glob.glob(str(input_dir / file_pattern))
            files_to_process.extend(matches)

            if not matches:
                matches = glob.glob(file_pattern)
                files_to_process.extend(matches)
    else:
        if args.type in ('meta', 'library', 'compatibility'):
            files_to_process.extend(list(input_dir.glob('*.lua')))

            if args.type == 'library':
                for module_dir in modules_dir.iterdir():
                    if module_dir.is_dir():
                        module_lib_dir = module_dir / 'libraries'
                        if module_lib_dir.exists():
                            files_to_process.extend(list(module_lib_dir.glob('*.lua')))
        elif args.type == 'definitions':
            for name in ('panels.lua', 'faction.lua', 'module.lua', 'items.lua', 'class.lua', 'attributes.lua'):
                p = input_dir / name
                if p.exists():
                    files_to_process.append(str(p))

            items_dir = input_dir / 'items'
            if items_dir.exists():
                for item_file in items_dir.glob('*.lua'):
                    files_to_process.append(str(item_file))

            items_base_dir = script_dir / 'gamemode' / 'items' / 'base'
            if items_base_dir.exists():
                for item_file in items_base_dir.glob('*.lua'):
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

    for file_path in files_to_process:
        if args.type == 'meta' and str(file_path).endswith('.lua'):
            generate_documentation_for_file(file_path, output_dir, False, base_docs_dir, args.force)
        elif args.type == 'library' and str(file_path).endswith('.lua'):
            generate_documentation_for_file(file_path, output_dir, True, base_docs_dir, args.force)
        elif args.type == 'compatibility' and str(file_path).endswith('.lua'):
            # Check if this is a meta file with custom directives
            try:
                with open(file_path, 'r', encoding='utf-8-sig') as f:
                    content = f.read()
                custom_folder, custom_filename, _ = parse_folder_directives(content)
                is_meta_file = custom_folder and custom_folder.lower() == 'meta'
                generate_documentation_for_file(file_path, output_dir, not is_meta_file, base_docs_dir, args.force)
            except:
                generate_documentation_for_file(file_path, output_dir, True, base_docs_dir, args.force)
        elif args.type == 'definitions' and str(file_path).endswith('.lua'):
            generate_documentation_for_definitions_file(Path(file_path), output_dir, base_docs_dir)
        elif args.type == 'hooks' and str(file_path).endswith('.lua'):
            generate_documentation_for_hooks_file(Path(file_path), output_dir, base_docs_dir)


    if args.type in ('meta', 'library', 'compatibility', 'definitions', 'hooks'):
        output_dir.mkdir(parents=True, exist_ok=True)
        generate_index_file(output_dir, args.type)
        
        items_dir = output_dir / 'items'
        if items_dir.exists():
            generate_index_file(items_dir, 'items')

    print("Documentation generation complete!")


def generate_index_file(output_dir: Path, doc_type: str) -> None:
    """Generate an index.md file listing all documentation files in the directory."""
    output_dir.mkdir(parents=True, exist_ok=True)
    
    if not output_dir.exists():
        return

    md_files = sorted([f for f in output_dir.glob('*.md') if f.name != 'index.md'])
    
    subdirs = []
    if doc_type == 'definitions':
        items_dir = output_dir / 'items'
        if items_dir.exists():
            items_files = sorted([f for f in items_dir.glob('*.md') if f.name != 'index.md'])
            if items_files:
                subdirs.append(('items', items_files))
    
    if not md_files and not subdirs:
        return

    title_map = {
        'meta': 'Meta Tables',
        'library': 'Libraries',
        'compatibility': 'Compatibility',
        'definitions': 'Definitions',
        'hooks': 'Hooks',
        'items': 'Item Definitions'
    }
    
    title = title_map.get(doc_type, doc_type.title())
    
    index_path = output_dir / 'index.md'
    
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(f'# {title}\n\n')
        
        if md_files:
            for md_file in md_files:
                name = md_file.stem
                display_name = name.replace('lia.', '').replace('_', ' ').title()
                link_name = md_file.name
                f.write(f'- [{display_name}](./{link_name})\n\n')
        
        for subdir_name, subdir_files in subdirs:
            f.write(f'## {subdir_name.title()}\n\n')
            for md_file in subdir_files:
                name = md_file.stem
                display_name = name.replace('lia.', '').replace('_', ' ').title()
                link_name = f'{subdir_name}/{md_file.name}'
                f.write(f'- [{display_name}](./{link_name})\n\n')
    
    print(f"  Generated index.md for {doc_type}")


if __name__ == '__main__':
    main()