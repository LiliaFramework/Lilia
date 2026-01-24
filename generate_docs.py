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


def generate_anchor_from_name(name):
    anchor = name.lower()
    anchor = re.sub(r'[^\w\s-]', '', anchor)
    anchor = re.sub(r'[-\s]+', '-', anchor)
    return anchor


def get_type_link(type_name):
    type_links = {
        'string': 'https://www.lua.org/manual/5.1/manual.html#5.4',
        'number': 'https://www.lua.org/manual/5.1/manual.html#5.3',
        'boolean': 'https://www.lua.org/manual/5.1/manual.html#5.2',
        'table': 'https://www.lua.org/manual/5.1/manual.html#5.5',
        'function': 'https://www.lua.org/manual/5.1/manual.html#5.6',
        'nil': 'https://www.lua.org/manual/5.1/manual.html#5.1',
        'thread': 'https://www.lua.org/manual/5.1/manual.html#5.7',
        'userdata': 'https://www.lua.org/manual/5.1/manual.html#5.8',
        'Player': 'https://wiki.facepunch.com/gmod/Player',
        'Entity': 'https://wiki.facepunch.com/gmod/Entity',
        'Vector': 'https://wiki.facepunch.com/gmod/Vector',
        'Angle': 'https://wiki.facepunch.com/gmod/Angle',
        'Color': 'https://wiki.facepunch.com/gmod/Color',
        'Panel': 'https://wiki.facepunch.com/gmod/Panel',
        'IMaterial': 'https://wiki.facepunch.com/gmod/IMaterial',
        'ITexture': 'https://wiki.facepunch.com/gmod/ITexture',
        'ISound': 'https://wiki.facepunch.com/gmod/ISound',
        'ConVar': 'https://wiki.facepunch.com/gmod/ConVar',
        'CUserCmd': 'https://wiki.facepunch.com/gmod/CUserCmd',
        'CMoveData': 'https://wiki.facepunch.com/gmod/CMoveData',
        'CTakeDamageInfo': 'https://wiki.facepunch.com/gmod/CTakeDamageInfo',
        'CEffectData': 'https://wiki.facepunch.com/gmod/CEffectData',
        'CLuaEmitter': 'https://wiki.facepunch.com/gmod/CLuaEmitter',
        'CLuaEffect': 'https://wiki.facepunch.com/gmod/CLuaEffect',
        'CLuaParticle': 'https://wiki.facepunch.com/gmod/CLuaParticle',
        'PhysObj': 'https://wiki.facepunch.com/gmod/PhysObj',
        'VMatrix': 'https://wiki.facepunch.com/gmod/VMatrix',
        'IGModAudioChannel': 'https://wiki.facepunch.com/gmod/IGModAudioChannel',
        'File': 'https://wiki.facepunch.com/gmod/File',
        'HTTPRequest': 'https://wiki.facepunch.com/gmod/HTTPRequest',
        'Material': 'https://wiki.facepunch.com/gmod/Material',
        'Texture': 'https://wiki.facepunch.com/gmod/Texture',
        'Sound': 'https://wiki.facepunch.com/gmod/Sound',
        'Weapon': 'https://wiki.facepunch.com/gmod/Weapon',
        'Vehicle': 'https://wiki.facepunch.com/gmod/Vehicle',
        'NPC': 'https://wiki.facepunch.com/gmod/NPC',
        'NextBot': 'https://wiki.facepunch.com/gmod/NextBot',
        'PathFollower': 'https://wiki.facepunch.com/gmod/PathFollower',
        'CLuaLocomotion': 'https://wiki.facepunch.com/gmod/CLuaLocomotion',
        'CSEnt': 'https://wiki.facepunch.com/gmod/CSEnt',
        'CSoundPatch': 'https://wiki.facepunch.com/gmod/CSoundPatch',
        'SurfaceInfo': 'https://wiki.facepunch.com/gmod/SurfaceInfo',
        'TraceResult': 'https://wiki.facepunch.com/gmod/TraceResult',
        'Trace': 'https://wiki.facepunch.com/gmod/Trace',
        'any': 'https://www.lua.org/manual/5.1/manual.html#2.2',
        'vararg': 'https://www.lua.org/manual/5.1/manual.html#5.2.4',
    }

    if not type_name:
        return 'https://www.lua.org/manual/5.1/manual.html#2.2'
    key = type_name.strip()
    lower = key.lower()
    if lower in type_links:
        return type_links[lower]
    if key in type_links:
        return type_links[key]
    return 'https://www.lua.org/manual/5.1/manual.html#2.2'


def _split_optional_type(type_text: str) -> Tuple[str, str, bool]:
    if not type_text:
        return '', '', False
    raw_parts = [p.strip() for p in str(type_text).split('|') if p.strip()]
    has_nil = any(p.lower() == 'nil' for p in raw_parts)
    parts = [p for p in raw_parts if p.lower() != 'nil']
    if not parts:
        return 'nil', 'nil', False
    display = '|'.join(parts)
    link_type = parts[0]
    return display, link_type, has_nil


def _split_type_display_link(type_text: str) -> Tuple[str, str]:
    if not type_text:
        return '', ''
    raw_parts = [p.strip() for p in str(type_text).split('|') if p.strip()]
    if not raw_parts:
        return '', ''
    non_nil = next((p for p in raw_parts if p.lower() != 'nil'), raw_parts[0])
    return '|'.join(raw_parts), non_nil


def _split_returns_text(returns_text: str) -> Tuple[Optional[str], str]:
    if not returns_text:
        return None, ''
    lines = [ln.strip() for ln in str(returns_text).splitlines() if ln.strip()]
    if not lines:
        return None, ''
    if len(lines) == 1:
        m = re.match(r'^([^\s]+)\s*-\s*(.+)$', lines[0])
        if m:
            return m.group(1).strip(), m.group(2).strip()
        if re.match(r'^[\w\|\.]+$', lines[0]):
            return lines[0], ''
        return None, lines[0]
    if re.match(r'^[\w\|\.]+$', lines[0]):
        return lines[0], ' '.join(lines[1:]).strip()
    return None, ' '.join(lines).strip()

def generate_markdown_for_function(function_name, parsed_comment, is_library=False):
    display_name = function_name
    if is_library and not function_name.startswith('lia.'):
        display_name = f'lia.{function_name}'
    elif not is_library and ':' in function_name:
        display_name = function_name.split(':', 1)[1]
    elif is_library and function_name.startswith('lia.'):
        display_name = function_name

    realm_text_raw = (parsed_comment.get('realm') or '').strip()
    realm_text = realm_text_raw.lower()
    if realm_text == 'client':
        realm_class = 'realm-client'
    elif realm_text == 'server':
        realm_class = 'realm-server'
    else:
        realm_class = 'realm-shared'

    signature_params = ', '.join([p.get('name', '').strip() for p in parsed_comment.get('parameters', []) if p.get('name')])
    signature = f'({signature_params})' if signature_params else '()'
    anchor = generate_anchor_from_name(display_name)
    md = f'<details class="{realm_class}">\n'
    md += f'<summary><a id={display_name}></a>{display_name}{signature}</summary>\n'
    md += f'<a id="{anchor}"></a>\n'

    if parsed_comment['purpose']:
        md += f'<p>{parsed_comment["purpose"]}</p>\n'

    if parsed_comment['when_called']:
        md += f'<p>{parsed_comment["when_called"]}</p>\n'
    elif parsed_comment.get('when_used'):
        md += f'<p>{parsed_comment["when_used"]}</p>\n'

    if parsed_comment['parameters']:
        first_param = True
        for param in parsed_comment['parameters']:
            display_type, link_type, is_optional = _split_optional_type(param["type"])
            type_link = get_type_link(link_type)
            desc = (param.get("description") or "").strip()
            if first_param:
                md += '<p><h3>Parameters:</h3>\n'
                first_param = False
            else:
                md += '<p>'
            md += f'<span class="types"><a class="type" href="{type_link}">{display_type}</a></span> '
            md += f'<span class="parameter">{param["name"]}</span>'
            if is_optional:
                md += ' <span class="optional">optional</span>'
            if desc:
                md += f' {desc}'
            md += '</p>\n'
        md += '\n'

    if parsed_comment['returns']:
        ret_type, ret_desc = _split_returns_text(parsed_comment["returns"])
        if ret_type:
            display_type, link_type = _split_type_display_link(ret_type)
            type_link = get_type_link(link_type)
            ret_desc = (ret_desc or '').strip()
            md += '<p><h3>Returns:</h3>\n'
            md += f'<span class="types"><a class="type" href="{type_link}">{display_type}</a></span>'
            if ret_desc:
                md += f' {ret_desc}'
            md += '</p>\n\n'
        else:
            md += f'<p><h3>Returns:</h3>\n{ret_desc}</p>\n\n'

    if parsed_comment.get('explanation'):
        md += f'<p>{parsed_comment["explanation"]}</p>\n'

    if parsed_comment['examples']:
        md += '<h3>Example Usage:</h3>\n'
        for example in parsed_comment['examples']:
            md += '<pre><code class="language-lua">'
            formatted_code = format_lua_code(example['code'])
            md += '\n'.join(formatted_code).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            md += '</code></pre>\n'

    md += '</details>\n\n'
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

    if output_path.exists() and output_path.stat().st_size > 0 and not force and not append:
        print(f"  {output_path.name} already exists, skipping")
        return

    sections = []
    function_names = []

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

            display_name = func['name']
            if is_library and not func['name'].startswith('lia.'):
                display_name = f'lia.{func["name"]}'
            elif not is_library and ':' in func['name']:
                display_name = func['name'].split(':', 1)[1]
            elif is_library and func['name'].startswith('lia.'):
                display_name = func['name']
            
            function_names.append(display_name)
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


def generate_markdown_for_definition_entries(title: str, subtitle: str, overview_section: Optional[str], entries: List[Dict[str, object]], append: bool = False) -> str:
    md_parts: List[str] = []
    if not append:
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
        anchor = generate_anchor_from_name(name)
        md_parts.append(f'<a id="{anchor}"></a>\n### {name}\n\n')
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
            first_param = True
            for p in parsed['parameters']:
                display_type, link_type, is_optional = _split_optional_type(p["type"])
                type_link = get_type_link(link_type)
                desc = (p.get("description") or "").strip()
                if first_param:
                    md_parts.append('<p><h3>Parameters:</h3>\n')
                    first_param = False
                else:
                    md_parts.append('<p>')
                md_parts.append(f'<span class="types"><a class="type" href="{type_link}">{display_type}</a></span> ')
                md_parts.append(f'<span class="parameter">{p["name"]}</span>')
                if is_optional:
                    md_parts.append(' <span class="optional">optional</span>')
                if desc:
                    md_parts.append(f' {desc}')
                md_parts.append('</p>\n')
            md_parts.append('\n')
        if parsed.get('returns'):
            ret_type, ret_desc = _split_returns_text(parsed["returns"])
            if ret_type:
                display_type, link_type = _split_type_display_link(ret_type)
                type_link = get_type_link(link_type)
                ret_desc = (ret_desc or '').strip()
                md_parts.append('<p><h3>Returns:</h3>\n')
                md_parts.append(f'<span class="types"><a class="type" href="{type_link}">{display_type}</a></span>')
                if ret_desc:
                    md_parts.append(f' {ret_desc}')
                md_parts.append('</p>\n\n')
            else:
                md_parts.append(f'<p><h3>Returns:</h3>\n{ret_desc}</p>\n\n')
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

    custom_folder, custom_filename, append = parse_folder_directives(text)
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

    md = generate_markdown_for_definition_entries(title, subtitle, overview_section, entries, append)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    file_mode = 'a' if append else 'w'
    with open(output_path, file_mode, encoding='utf-8') as f:
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
    md = generate_markdown_for_definition_entries(title, subtitle, final_overview, entries, append)
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
    function_names = []
    for func in functions:
        parsed = parse_comment_block(func['comment'])
        func_name = func['name']
        if ':' in func_name:
            display_name = func_name.split(':', 1)[1]
        else:
            display_name = func_name
        function_names.append(display_name)
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
    parser.add_argument('type', choices=['meta', 'library', 'compatibility', 'definitions', 'hooks', 'guides', 'generators'], help='Type of files to process')
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
    elif args.type == 'guides':
        input_dir = None  # Guides are manually created, no input processing needed
        output_dir = script_dir / 'documentation' / 'docs' / 'guides'
    elif args.type == 'generators':
        input_dir = None  # Generators are manually created, no input processing needed
        output_dir = script_dir / 'documentation' / 'docs' / 'generators'

    output_dir.mkdir(parents=True, exist_ok=True)

    files_to_process = []

    if args.files:
        if input_dir is not None:
            for file_pattern in args.files:
                import glob
                matches = glob.glob(str(input_dir / file_pattern))
                files_to_process.extend(matches)

                if not matches:
                    matches = glob.glob(file_pattern)
                    files_to_process.extend(matches)
    else:
        if input_dir is not None:
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
        # For guides and generators, no file processing needed
        elif args.type in ('meta', 'library', 'compatibility'):
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

    if input_dir is not None and not files_to_process:
        print(f"No files found in {input_dir}")
        return

    if input_dir is not None:
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

    # Generate index for this specific type
    generate_index_file(output_dir, args.type)

    # Generate comprehensive index at the root docs directory
    generate_comprehensive_index(base_docs_dir)

    # Generate .pages file for navigation
    generate_pages_file(base_docs_dir)

    print("Documentation generation complete!")


def extract_title_and_summary(md_file: Path) -> Tuple[str, str]:
    """Extract title and summary from a markdown file."""
    try:
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        name = md_file.stem
        display_name = name.replace('lia.', '').replace('_', ' ').title()
        return display_name, ''
    
    lines = content.split('\n')
    title = ''
    summary = ''
    
    for i, line in enumerate(lines):
        stripped = line.strip()
        
        if stripped.startswith('# ') and not title:
            title = stripped[2:].strip()
            if i + 1 < len(lines):
                next_line = lines[i + 1].strip()
                if next_line and not next_line.startswith('#') and not next_line.startswith('---'):
                    summary = next_line
                    break
        elif stripped.startswith('## ') and not title:
            title = stripped[3:].strip()
            if i + 1 < len(lines):
                next_line = lines[i + 1].strip()
                if next_line and not next_line.startswith('#') and not next_line.startswith('---'):
                    summary = next_line
                    break
    
    if not title:
        name = md_file.stem
        title = name.replace('lia.', '').replace('_', ' ').title()
    
    if not summary:
        overview_match = re.search(r'Overview\s*\n\s*\n(.+?)(?:\n\n---|\n\n###|$)', content, re.DOTALL)
        if overview_match:
            overview_text = overview_match.group(1).strip()
            overview_text = re.sub(r'\n+', ' ', overview_text)
            first_sentence = re.split(r'[.!?]\s+', overview_text)[0]
            if first_sentence:
                summary = first_sentence.strip()
                if len(summary) > 200:
                    summary = summary[:197] + '...'
                if not summary.endswith(('.', '!', '?')):
                    summary += '.'
    
    if not summary:
        summary = f'Documentation for {title.lower()}.'
    
    summary = summary.replace('|', '\\|')
    
    return title, summary


# Custom summaries for guides and generators
GUIDE_SUMMARIES = {
    'installation.md': 'Step-by-step guide to set up Lilia Framework on your Garry\'s Mod server.',
    'factions.md': 'Complete guide to creating and managing factions in your roleplay server.',
    'classes.md': 'Guide to creating specialized roles and classes within factions.',
    'items.md': 'Comprehensive guide to creating weapons, consumables, outfits, and other items.',
    'modules.md': 'How to install and create custom modules to extend Lilia\'s functionality.',
    'compatibility.md': 'Integration guides for popular Garry\'s Mod addons and frameworks.'
}

GUIDE_TITLES = {
    'installation.md': 'Installation',
    'factions.md': 'Factions',
    'classes.md': 'Classes',
    'items.md': 'Items',
    'modules.md': 'Modules',
    'compatibility.md': 'Compatibility'
}

GENERATOR_SUMMARIES = {
    'attribute.md': 'Code templates and examples for creating character attributes.',
    'class.md': 'Code templates and examples for creating character classes.',
    'faction.md': 'Code templates and examples for creating factions.',
    'items/aid.md': 'Templates for creating medical aid and healing items.',
    'items/ammo.md': 'Templates for creating ammunition and magazine items.',
    'items/books.md': 'Templates for creating readable books and documents.',
    'items/grenade.md': 'Templates for creating explosive and grenade items.',
    'items/outfit.md': 'Templates for creating clothing and appearance items.',
    'items/stackable.md': 'Templates for creating items that can stack in inventory.',
    'items/weapons.md': 'Templates for creating weapons and firearms.',
    # Full paths for comprehensive index
    'generators/attribute.md': 'Code templates and examples for creating character attributes.',
    'generators/class.md': 'Code templates and examples for creating character classes.',
    'generators/faction.md': 'Code templates and examples for creating factions.',
    'generators/items/aid.md': 'Templates for creating medical aid and healing items.',
    'generators/items/ammo.md': 'Templates for creating ammunition and magazine items.',
    'generators/items/books.md': 'Templates for creating readable books and documents.',
    'generators/items/grenade.md': 'Templates for creating explosive and grenade items.',
    'generators/items/outfit.md': 'Templates for creating clothing and appearance items.',
    'generators/items/stackable.md': 'Templates for creating items that can stack in inventory.',
    'generators/items/weapons.md': 'Templates for creating weapons and firearms.'
}

GENERATOR_TITLES = {
    'attribute.md': 'Attribute Generator',
    'class.md': 'Class Generator',
    'faction.md': 'Faction Generator',
    'items/aid.md': 'Aid Item Generator',
    'items/ammo.md': 'Ammo Item Generator',
    'items/books.md': 'Books Item Generator',
    'items/grenade.md': 'Grenade Item Generator',
    'items/outfit.md': 'Outfit Item Generator',
    'items/stackable.md': 'Stackable Item Generator',
    'items/weapons.md': 'Weapons Item Generator'
}

TITLE_MAP = {
    'meta': 'Meta Tables',
    'library': 'Libraries',
    'compatibility': 'Compatibility',
    'definitions': 'Definitions',
    'hooks': 'Hooks',
    'guides': 'Guides',
    'generators': 'Generators',
    'items': 'Item Definitions'
}

def get_custom_summary(section_name, file_path, docs_dir):
    """Get custom summary for guides and generators."""
    if section_name == 'Guides':
        filename = file_path.name
        return GUIDE_SUMMARIES.get(filename, '')
    elif section_name == 'Generators':
        rel_path = file_path.relative_to(docs_dir).as_posix()
        # Try the full path first, then just the filename
        return GENERATOR_SUMMARIES.get(rel_path, GENERATOR_SUMMARIES.get(file_path.name, ''))
    return ''

def get_custom_title(section_name, file_path):
    """Get custom title for guides and generators."""
    if section_name == 'Guides':
        filename = file_path.name
        return GUIDE_TITLES.get(filename, file_path.stem.title())
    elif section_name == 'Generators':
        # Check if file is directly in generators dir or in a subdir
        parent_dir = file_path.parent  # docs/generators or docs/generators/items
        grandparent_dir = parent_dir.parent  # docs/generators or docs

        if grandparent_dir.name == 'docs':  # File is in docs/generators/
            rel_path_str = file_path.name  # Just the filename like 'attribute.md'
        else:  # File is in docs/generators/items/
            rel_path = file_path.relative_to(grandparent_dir)  # generators/items/aid.md
            rel_path_str = str(rel_path).replace('\\', '/')

        return GENERATOR_TITLES.get(rel_path_str, file_path.stem.title())
    return file_path.stem.title()

def generate_index_file(output_dir: Path, doc_type: str) -> None:
    """Generate an index.md file listing all documentation files in the directory with summaries."""
    output_dir.mkdir(parents=True, exist_ok=True)

    if not output_dir.exists():
        return

    md_files = sorted([f for f in output_dir.glob('*.md') if f.name != 'index.md'])

    subdirs = []
    if doc_type == 'definitions' or doc_type == 'generators':
        items_dir = output_dir / 'items'
        if items_dir.exists():
            items_files = sorted([f for f in items_dir.glob('*.md') if f.name != 'index.md'])
            if items_files:
                subdirs.append(('Item Generators' if doc_type == 'generators' else 'items', items_files))

    if not md_files and not subdirs:
        return

    title = TITLE_MAP.get(doc_type, doc_type.title())

    index_path = output_dir / 'index.md'

    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(f'# {title}\n\n')

        if doc_type == 'guides':
            f.write('This section contains comprehensive guides for setting up and customizing your Lilia roleplay server.\n\n')
        elif doc_type == 'generators':
            f.write('This section contains generators and templates for creating Lilia framework components.\n\n')

        if md_files:
            f.write('| Name | Summary |\n')
            f.write('|------|---------|\n')
            for md_file in md_files:
                # Use custom title for guides and generators
                if doc_type == 'guides':
                    file_title = get_custom_title('Guides', md_file)
                elif doc_type == 'generators':
                    file_title = get_custom_title('Generators', md_file)
                else:
                    file_title, _ = extract_title_and_summary(md_file)


                link_name = md_file.name

                # Use custom summary for guides and generators
                if doc_type == 'guides' and link_name in GUIDE_SUMMARIES:
                    summary = GUIDE_SUMMARIES[link_name]
                elif doc_type == 'generators' and link_name in GENERATOR_SUMMARIES:
                    summary = GENERATOR_SUMMARIES[link_name]
                else:
                    _, summary = extract_title_and_summary(md_file)

                f.write(f'| [{file_title}](./{link_name}) | {summary} |\n')
            f.write('\n')
        
        for subdir_name, subdir_files in subdirs:
            f.write(f'## {subdir_name.title()}\n\n')
            f.write('| Name | Summary |\n')
            f.write('|------|---------|\n')
            for md_file in subdir_files:
                if doc_type == 'generators':
                    file_title = get_custom_title('Generators', md_file)
                else:
                    file_title, _ = extract_title_and_summary(md_file)

                rel_path = md_file.relative_to(output_dir).as_posix()
                if doc_type == 'generators' and rel_path in GENERATOR_SUMMARIES:
                    summary = GENERATOR_SUMMARIES[rel_path]
                else:
                    _, summary = extract_title_and_summary(md_file)
                f.write(f'| [{file_title}](./{rel_path}) | {summary} |\n')
            f.write('\n')
    
    print(f"  Generated index.md for {doc_type}")


def generate_comprehensive_index(docs_dir: Path) -> None:
    """Generate a comprehensive index.md file that lists all documentation types in one page."""
    docs_dir.mkdir(parents=True, exist_ok=True)
    index_path = docs_dir / 'index.md'

    sections = []

    # Guides
    guides_dir = docs_dir / 'guides'
    if guides_dir.exists():
        guide_files = sorted([f for f in guides_dir.glob('*.md') if f.name != 'index.md'])
        if guide_files:
            sections.append(('Guides', guides_dir, guide_files))

    # Generators
    generators_dir = docs_dir / 'generators'
    if generators_dir.exists():
        gen_files = sorted([f for f in generators_dir.glob('*.md') if f.name != 'index.md'])
        gen_subdirs = []
        items_dir = generators_dir / 'items'
        if items_dir.exists():
            items_files = sorted([f for f in items_dir.glob('*.md') if f.name != 'index.md'])
            if items_files:
                gen_subdirs.append(('Item Generators', items_dir, items_files))

        if gen_files or gen_subdirs:
            sections.append(('Generators', generators_dir, gen_files, gen_subdirs))

    # Meta Tables
    meta_dir = docs_dir / 'meta'
    if meta_dir.exists():
        meta_files = sorted([f for f in meta_dir.glob('*.md') if f.name != 'index.md'])
        if meta_files:
            sections.append(('Meta Tables', meta_dir, meta_files))

    # Libraries
    libraries_dir = docs_dir / 'libraries'
    if libraries_dir.exists():
        lib_files = sorted([f for f in libraries_dir.glob('*.md') if f.name != 'index.md'])
        if lib_files:
            sections.append(('Libraries', libraries_dir, lib_files))

    # Compatibility
    compatibility_dir = docs_dir / 'compatibility'
    if compatibility_dir.exists():
        compat_files = sorted([f for f in compatibility_dir.glob('*.md') if f.name != 'index.md'])
        if compat_files:
            sections.append(('Compatibility', compatibility_dir, compat_files))

    # Hooks
    hooks_dir = docs_dir / 'hooks'
    if hooks_dir.exists():
        hook_files = sorted([f for f in hooks_dir.glob('*.md') if f.name != 'index.md'])
        if hook_files:
            sections.append(('Hooks', hooks_dir, hook_files))

    # Definitions
    definitions_dir = docs_dir / 'definitions'
    if definitions_dir.exists():
        def_files = sorted([f for f in definitions_dir.glob('*.md') if f.name != 'index.md'])
        items_dir = definitions_dir / 'items'
        subdirs = []
        if items_dir.exists():
            items_files = sorted([f for f in items_dir.glob('*.md') if f.name != 'index.md'])
            if items_files:
                subdirs.append(('Item Definitions', items_dir, items_files))

        if def_files or subdirs:
            sections.append(('Definitions', definitions_dir, def_files, subdirs))

    if not sections:
        return

    with open(index_path, 'w', encoding='utf-8') as f:
        f.write('# Index\n\n')
        f.write('This page provides an index of all available documentation.\n\n')

        for section_info in sections:
            section_name = section_info[0]
            section_dir = section_info[1]
            files = section_info[2]
            subdirs = section_info[3] if len(section_info) > 3 else []

            f.write(f'## {section_name}\n\n')
            f.write('| Name | Summary |\n')
            f.write('|------|---------|\n')

            for md_file in files:
                custom_title = get_custom_title(section_name, md_file)
                if custom_title:
                    file_title = custom_title
                else:
                    file_title, _ = extract_title_and_summary(md_file)

                rel_path = md_file.relative_to(docs_dir).as_posix()
                custom_summary = get_custom_summary(section_name, md_file, docs_dir)
                summary = custom_summary or extract_title_and_summary(md_file)[1]
                f.write(f'| [{file_title}](./{rel_path}) | {summary} |\n')

            # Handle subdirectories (like items under definitions)
            for subdir_info in subdirs:
                subdir_name = subdir_info[0]
                subdir_dir = subdir_info[1]
                subdir_files = subdir_info[2]

                f.write(f'\n### {subdir_name}\n\n')
                f.write('| Name | Summary |\n')
                f.write('|------|---------|\n')

                for md_file in subdir_files:
                    custom_title = get_custom_title(section_name, md_file)
                    if custom_title:
                        file_title = custom_title
                    else:
                        file_title, _ = extract_title_and_summary(md_file)

                    rel_path = md_file.relative_to(docs_dir).as_posix()
                    custom_summary = get_custom_summary(section_name, md_file, docs_dir)
                    summary = custom_summary or extract_title_and_summary(md_file)[1]
                    f.write(f'| [{file_title}](./{rel_path}) | {summary} |\n')

            f.write('\n')

    print("  Generated comprehensive index.md")

def generate_pages_file(docs_dir: Path) -> None:
    """Generate .pages file for MkDocs navigation."""
    pages_path = docs_dir.parent / '.pages'

    # Define the preferred order of navigation items
    nav_order = [
        'index.md',
        'gettingstarted.md',
        # Directory sections (documentation)
        'guides',
        'generators',
        'libraries',
        'hooks',
        'meta',
        'definitions',
        'modules',
        # Standalone files
        'compatibility.md',
        'changelog.md'
    ]

    # Directories to exclude from navigation
    exclude_dirs = {'assets', 'compatibility', 'tools', 'versioning'}

    # Get all directories and files in docs, excluding certain directories
    existing_items = set()
    if docs_dir.exists():
        for item in docs_dir.iterdir():
            if item.is_dir() and item.name not in exclude_dirs:
                existing_items.add(item.name)
            elif item.is_file() and item.name.endswith('.md') and item.name != '_index.md':
                existing_items.add(item.name)

    # Build navigation list in preferred order
    nav_items = []
    for item in nav_order:
        if item in existing_items:
            nav_items.append(f'  - {item}')

    # Add any remaining items not in the preferred order (excluding excluded dirs)
    remaining_items = existing_items - set(nav_order) - exclude_dirs
    if remaining_items:
        # Sort remaining items
        sorted_remaining = sorted(remaining_items)
        nav_items.extend(f'  - {item}' for item in sorted_remaining)

    # Write .pages file
    with open(pages_path, 'w', encoding='utf-8') as f:
        f.write('arrange:\n')
        for item in nav_items:
            f.write(f'{item}\n')

    print(f"Generated .pages file with {len(nav_items)} navigation items")


if __name__ == '__main__':
    main()