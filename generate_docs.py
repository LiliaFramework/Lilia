#!/usr/bin/env python3

import os
import re
import sys
import argparse
import urllib.request
import json
from pathlib import Path
from io import StringIO
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
    pending_parameter = None# Track pending parameter for new format (name, type)

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
                final_lines.append('  ' + line)
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
            final_lines.append('  ' + line)
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
        'string': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'number': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'boolean': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'table': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'function': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'nil': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'thread': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'userdata': 'https://www.lua.org/manual/5.1/manual.html#2.1',
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
        'any': 'https://www.lua.org/manual/5.1/manual.html#2.1',
        'vararg': 'https://www.lua.org/manual/5.1/manual.html#5.2.4',
    }

    if not type_name:
        return 'https://www.lua.org/manual/5.1/manual.html#2.2'

    key = type_name.strip()
    lower = key.lower()

    # Lilia-specific type mappings
    lilia_mappings = {
        'inventory': '/development/libraries/inventory/',
        'item': '/development/libraries/item/',
        'character': '/development/libraries/char/',
        'faction': '/development/libraries/faction/',
        'factions': '/development/libraries/faction/',
        'class': '/development/libraries/class/',
        'classes': '/development/libraries/class/',
        'attribute': '/development/libraries/attribs/',
        'attributes': '/development/libraries/attribs/',
        'player': '/development/meta/player/',
        'entity': '/development/meta/entity/',
        'panel': '/development/meta/panel/',
        'Character': '/development/meta/character/',
        'ItemDefinition': '/development/meta/item/',
        'InventoryType': '/development/libraries/inventory/',
    }

    # Check for lia. prefix
    if lower.startswith('lia.'):
        lib_name = lower[4:]
        if lib_name in lilia_mappings:
            return lilia_mappings[lib_name]
        return f'/development/libraries/{lib_name}/'

    if lower in lilia_mappings:
        return lilia_mappings[lower]
    if key in lilia_mappings:
        return lilia_mappings[key]

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

def generate_markdown_for_function(function_name, parsed_comment, is_library=False, no_realm=False, no_icon=False):
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
    slug = generate_anchor_from_name(display_name)
    classes = []
    if realm_class:
        classes.append(realm_class)
    if no_icon:
        classes.append('no-icon')
    
    realm_attr = f' class="{" ".join(classes)}"' if classes else ''
    md = f'<details{realm_attr} id="function-{slug}">\n'
    md += f'<summary><a id="{display_name}"></a>{display_name}{signature}</summary>\n'
    md += f'<div class="details-content">\n'
    if parsed_comment['purpose']:
        md += f'<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="{slug}"></a>Purpose</h3>\n'
        md += f'<div style="margin-left: 20px; margin-bottom: 20px;">\n  <p>{parsed_comment["purpose"]}</p>\n</div>\n\n'

    if parsed_comment['when_called']:
        md += f'<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>\n'
        md += f'<div style="margin-left: 20px; margin-bottom: 20px;">\n  <p>{parsed_comment["when_called"]}</p>\n</div>\n\n'
    elif parsed_comment.get('when_used'):
        md += f'<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>\n'
        md += f'<div style="margin-left: 20px; margin-bottom: 20px;">\n  <p>{parsed_comment["when_used"]}</p>\n</div>\n\n'


    if parsed_comment['parameters']:
        md += '<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>\n'
        md += '<div style="margin-left: 20px; margin-bottom: 20px;">\n'
        for param in parsed_comment['parameters']:
            display_type, link_type, is_optional = _split_optional_type(param["type"])
            type_link = get_type_link(link_type)
            desc = (param.get("description") or "").strip()
            md += '<p>'
            md += f'<span class="types"><a class="type" href="{type_link}">{display_type}</a></span> '
            md += f'<span class="parameter">{param["name"]}</span>'
            if is_optional:
                md += ' <span class="optional">optional</span>'
            if desc:
                md += f' {desc}'
            md += '</p>\n'
        md += '</div>\n\n'

    if parsed_comment['returns']:
        md += '<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>\n'
        md += '<div style="margin-left: 20px; margin-bottom: 20px;">\n'
        ret_type, ret_desc = _split_returns_text(parsed_comment["returns"])
        if ret_type:
            display_type, link_type = _split_type_display_link(ret_type)
            type_link = get_type_link(link_type)
            ret_desc = (ret_desc or '').strip()
            md += f'<p><span class="types"><a class="type" href="{type_link}">{display_type}</a></span>'
            if ret_desc:
                md += f' {ret_desc}'
            md += '</p>\n'
        else:
            md += f'<p>{ret_desc}</p>\n'
        md += '</div>\n\n'

    if parsed_comment.get('explanation'):
        md += f'<h3 style="margin-bottom: 5px; font-weight: 700;">Explanation</h3>\n'
        md += f'<div style="margin-left: 20px; margin-bottom: 20px;">\n  <p>{parsed_comment["explanation"]}</p>\n</div>\n\n'

    if parsed_comment['examples']:
        md += '<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>\n'
        md += '<div style="margin-left: 20px; margin-bottom: 20px;">\n'
        for example in parsed_comment['examples']:
            md += '<pre><code class="language-lua">'
            formatted_code = format_lua_code(example['code'])
            md += '\n'.join(formatted_code).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            md += '</code></pre>\n'
        md += '</div>\n\n'

    md += '</div>\n'
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


def generate_documentation_for_file(file_path, output_dir, is_library=False, base_docs_dir=None, force=False, no_realm=False, no_icon=False):
    print(f"Processing {file_path}")

    try:
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            file_content = f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return

    custom_folder, custom_filename, append = parse_folder_directives(file_content)
    
    # Remap legacy folder directives to new development structure
    if custom_folder:
        if custom_folder.lower() == 'meta':
             custom_folder = 'development/meta'
        elif custom_folder.lower() in ['libraries', 'library', 'core libraries']:
             custom_folder = 'development/libraries'
    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)

    if file_header and ('Folder:' in file_header or 'File:' in file_header):
        for block in comment_blocks:
            if block != file_header and not ('Folder:' in block or 'File:' in block):
                file_header = block
                break

    functions = find_functions_in_file(file_path, is_library)

    if not functions and not file_header and not overview_section:
        print(f" No structured functions or documentation content found in {file_path}")
        return

    if custom_folder and custom_filename and base_docs_dir:
        output_path = base_docs_dir / custom_folder / custom_filename
        print(f" Using custom output: {custom_folder}/{custom_filename}")
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
        print(f" {output_path.name} already exists, skipping")
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
                        print(f" Skipping hook implementation: {func_name} (documented centrally)")
                        continue

            display_name = func['name']
            if is_library and not func['name'].startswith('lia.'):
                display_name = f'lia.{func["name"]}'
            elif not is_library and ':' in func['name']:
                display_name = func['name'].split(':', 1)[1]
            elif is_library and func['name'].startswith('lia.'):
                display_name = func['name']
            
            function_names.append(display_name)
            section = generate_markdown_for_function(func['name'], parsed, is_library, no_realm=no_realm, no_icon=no_icon)
            sections.append(section)

    if not sections and not file_header and not overview_section:
        print(f" No valid function documentation or content found in {file_path}")
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
                f.write('<h3 style="margin-bottom: 5px;">Overview</h3>\n')
                f.write('<div style="margin-left: 20px; margin-bottom: 20px;">\n')
                overview_content = parse_overview_section(overview_section)
                f.write(overview_content)
                f.write('\n</div>\n\n')
                f.write('---\n\n')

        for section in sections:
            f.write(section)
            f.write('---\n\n')

    print(f" Generated {output_path.name}")


def _read_file_text(file_path: Path) -> str:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except UnicodeDecodeError:
        print(f"Warning: Could not read {file_path} due to encoding issues")
        return ''


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
        print(f" Using custom output: {custom_folder}/{custom_filename}")
    else:
        filename = file_path.stem
        output_filename = f'{filename}.md'
        output_path = output_dir / output_filename

    comment_blocks, file_header, overview_section = find_comment_blocks_in_file(file_path)

    functions = find_functions_in_file(file_path, is_library=False)

    if not functions and not file_header and not overview_section:
        print(f" No hooks or documentation content found in {file_path}")
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
                f.write('<h3 style="margin-bottom: 5px;">Overview</h3>\n')
                f.write('<div style="margin-left: 20px; margin-bottom: 20px;">\n')
                f.write(parse_overview_section(overview_section) + '\n')
                f.write('</div>\n\n')
                f.write('---\n\n')
        for section in sections:
            f.write(section)
            f.write('---\n\n')
    print(f" Generated {output_path.name}")


def generate_about_page(output_path, force=False):
    print(f"Generating About page at {output_path}")

    # 1. Fetch modules list
    modules_url = "https://raw.githubusercontent.com/LiliaFramework/Modules/gh-pages/modules.json"
    try:
        print(f" Fetching modules from {modules_url}...")
        with urllib.request.urlopen(modules_url) as response:
            data = json.loads(response.read().decode())
    except Exception as e:
        print(f" Failed to fetch modules list: {e}")
        return

    # Sort by name
    modules = sorted(data, key=lambda x: x.get('name', ''))

    table_lines = []
    table_lines.append("| Name | Description | Author |")
    table_lines.append("| :--- | :--- | :--- |")

    for mod in modules:
        name = mod.get('name', 'Unknown')
        desc = mod.get('description', '').replace('|', '\\|').replace('\n', ' ')
        author = mod.get('author', 'Unknown')
        url = mod.get('url', '')
        # Construct local path instead of using external URL
        module_id = url.rstrip('/').split('/')[-2] if '/' in url else name.lower().replace(' ', '')
        name_link = f"[{name}](./modules/{module_id}/about.md)"

        table_lines.append(f"| {name_link} | {desc} | {author} |")

    modules_content = "\n".join(table_lines)

    # 3. Read template (existing about.md)
    if not output_path.exists():
        print(f" Warning: {output_path} does not exist. Cannot inject module list.")
        return

    try:
        with open(output_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f" Error reading {output_path}: {e}")
        return

    # 4. Inject
    start_marker = "<!-- MODULES_LIST_START -->"
    end_marker = "<!-- MODULES_LIST_END -->"

    pattern = re.compile(f"{re.escape(start_marker)}.*?{re.escape(end_marker)}", re.DOTALL)
    
    if not pattern.search(content):
        print(f" Markers {start_marker}...{end_marker} not found in {output_path}")
        return

    replacement = f"{start_marker}\n{modules_content}\n{end_marker}"
    new_content = pattern.sub(replacement, content)

    if new_content == content:
        print(f" {output_path.name} is already up to date.")
        if not force:
            return

    # 5. Write back
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f" Successfully updated {output_path} with {len(modules)} modules.")
    except Exception as e:
        print(f" Error writing {output_path}: {e}")


def main():
    parser = argparse.ArgumentParser(description='Lilia Documentation Generator')
    subparsers = parser.add_subparsers(dest='command', help='Command to run')

    # Meta command
    meta_parser = subparsers.add_parser('meta', help='Generate meta documentation')
    meta_parser.add_argument('--force', action='store_true', help='Force regeneration of existing files')

    # Library command
    library_parser = subparsers.add_parser('library', help='Generate library documentation')
    library_parser.add_argument('--force', action='store_true', help='Force regeneration of existing files')

    # Hooks command
    hooks_parser = subparsers.add_parser('hooks', help='Generate hooks documentation')
    hooks_parser.add_argument('--force', action='store_true', help='Force regeneration of existing files')

    # Compatibility command
    compatibility_parser = subparsers.add_parser('compatibility', help='Generate compatibility documentation')
    compatibility_parser.add_argument('--force', action='store_true', help='Force regeneration of existing files')

    # Generators command
    generators_parser = subparsers.add_parser('generators', help='Generate generators index')
    generators_parser.add_argument('--force', action='store_true', help='Force regeneration')

    # About command
    about_parser = subparsers.add_parser('about', help='Generate about page with dynamic content')
    about_parser.add_argument('--force', action='store_true', help='Force regeneration (checking for updates)')

    args = parser.parse_args()

    base_dir = Path(__file__).parent
    docs_dir = base_dir / 'documentation' / 'docs'

    if args.command == 'meta':
        meta_dir = base_dir / 'gamemode' / 'core' / 'meta'
        output_dir = docs_dir / 'development' / 'meta'
        if meta_dir.exists():
            for file_path in meta_dir.rglob('*.lua'):
                generate_documentation_for_file(file_path, output_dir, is_library=False, base_docs_dir=docs_dir, force=args.force, no_realm=False, no_icon=False)
        generate_index_file(output_dir, 'meta')

    elif args.command == 'library':
        lib_dirs = [
             base_dir / 'gamemode' / 'core' / 'libraries',
             base_dir / 'gamemode' / 'modules'
        ]
        output_dir = docs_dir / 'development' / 'libraries'
        for lib_dir in lib_dirs:
            if lib_dir.exists():
                for file_path in lib_dir.rglob('*.lua'):
                    generate_documentation_for_file(file_path, output_dir, is_library=True, base_docs_dir=docs_dir, force=args.force, no_realm=False, no_icon=False)
        generate_index_file(output_dir, 'library')

    elif args.command == 'hooks':
        hooks_dir = base_dir / 'gamemode' / 'core' / 'hooks' / 'docs'
        output_dir = docs_dir / 'development' / 'hooks'
        if hooks_dir.exists():
            for file_path in hooks_dir.rglob('*.lua'):
                generate_documentation_for_file(file_path, output_dir, is_library=False, base_docs_dir=docs_dir, force=args.force, no_realm=False, no_icon=False)
        generate_index_file(output_dir, 'hooks')

    elif args.command == 'compatibility':
        comp_dir = base_dir / 'gamemode' / 'core' / 'libraries' / 'compatibility'
        output_dir = docs_dir / 'development' / 'compatibility'
        if comp_dir.exists():
            for file_path in comp_dir.rglob('*.lua'):
                generate_documentation_for_file(file_path, output_dir, is_library=False, base_docs_dir=docs_dir, force=args.force, no_realm=False, no_icon=True)
        generate_index_file(output_dir, 'compatibility')

    elif args.command == 'generators':
        output_dir = docs_dir / 'generators'
        generate_index_file(output_dir, 'generators')

    elif args.command == 'about':
        output_path = docs_dir / 'about.md'
        generate_about_page(output_path, force=args.force)
        # Generate index for About directory
        generate_index_file(docs_dir / 'About', 'about')

    else:
        parser.print_help()
        return

    # Generate pages file for all commands
    # generate_comprehensive_index(docs_dir)  # Disabled to preserve manual index.md
    generate_development_index(docs_dir / 'development')
    generate_pages_file(docs_dir)


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
        
        if (stripped.startswith('# ') or stripped.startswith('## ')) and not title:
            title = stripped.lstrip('#').strip()
            # Look ahead for the first non-empty line that isn't a header or separator
            for j in range(i + 1, min(i + 5, len(lines))):
                next_line = lines[j].strip()
                if next_line and not next_line.startswith('#') and not next_line.startswith('---') and not next_line.startswith('<'):
                    summary = next_line
                    break
            if summary:
                break
    
    if not title:
        name = md_file.stem
        title = name.replace('lia.', '').replace('_', ' ').title()
    
    if not summary:
        # Try to find content after Overview header (with or without strong tags)
        overview_match = re.search(r'(?:<strong>)?Overview(?:</strong>)?\s*\n\s*\n(.+?)(?:\n\n---|\n\n###|$)', content, re.DOTALL)
        if overview_match:
            overview_text = overview_match.group(1).strip()
            overview_text = re.sub(r'\n+', ' ', overview_text)
            # Try to get the first sentence
            first_sentence = re.split(r'[.!?]\s+', overview_text)[0]
            if first_sentence:
                summary = first_sentence.strip()
                if not summary.endswith(('.', '!', '?')):
                    summary += '.'
    
    if not summary:
        summary = f'Documentation for {title.lower()}.'
    
    if len(summary) > 200:
        summary = summary[:197] + '...'
    
    summary = summary.replace('|', '\\|')
    
    return title, summary


# Custom summaries for guides and generators
GUIDE_SUMMARIES = {
    'getting_started.md': 'Step-by-step guide to set up Lilia Framework on your Garry\'s Mod server.',
    'factions.md': 'Complete guide to creating and managing factions in your roleplay server.',
    'classes.md': 'Guide to creating specialized roles and classes within factions.',
    'items.md': 'Comprehensive guide to creating weapons, consumables, outfits, and other items.',
    'modules.md': 'How to install and create custom modules to extend Lilia\'s functionality.',
    'compatibility.md': 'Integration guides for popular Garry\'s Mod addons and frameworks.',
    'features.md': 'Essential features for server owners including permissions, sit rooms, and configuration.',
    'tools.md': 'Overview of tools available in the Lilia framework.'
}

GUIDE_TITLES = {
    'getting_started.md': 'Getting Started',
    'factions.md': 'Factions',
    'classes.md': 'Classes',
    'items.md': 'Items',
    'modules.md': 'Modules',
    'compatibility.md': 'Compatibility',
    'features.md': 'Features',
    'tools.md': 'Tools'
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
    'hooks': 'Hooks',
    'guides': 'Guides',
    'generators': 'Generators',
    'about': 'About Lilia'
}

def get_custom_summary(section_name, file_path, docs_dir):
    """Get custom summary for guides and generators."""
    if section_name == 'Guides' or section_name == 'About':
        filename = file_path.name
        return GUIDE_SUMMARIES.get(filename, '')
    elif section_name == 'Generators':
        try:
             # Try relative to generators directory
             gen_dir = docs_dir / 'generators'
             rel_path = file_path.relative_to(gen_dir).as_posix()
        except ValueError:
             # Fallback
             rel_path = file_path.relative_to(docs_dir).as_posix()
             
        return GENERATOR_SUMMARIES.get(rel_path, GENERATOR_SUMMARIES.get(file_path.name, ''))
    return ''

def get_custom_title(section_name, file_path):
    """Get custom title for guides and generators."""
    if section_name == 'Guides' or section_name == 'About':
        filename = file_path.name
        return GUIDE_TITLES.get(filename, file_path.stem.title())
    elif section_name == 'Generators':
        # Check if file is directly in generators dir or in a subdir
        parent_dir = file_path.parent
        grandparent_dir = parent_dir.parent

        if parent_dir.name == 'generators':
            rel_path_str = file_path.name
        elif grandparent_dir.name == 'generators':
            # e.g. items/aid.md
            rel_path = file_path.relative_to(grandparent_dir)
            rel_path_str = str(rel_path).replace('\\', '/')
        else:
             rel_path_str = file_path.name

        return GENERATOR_TITLES.get(rel_path_str, file_path.stem.title())
    return file_path.stem.title()


def write_cards(f, items):
    """Write a grid of reactive cards for documentation indexes."""
    f.write('<div class="card-grid">\n')
    for item in items:
        # Support both (title, link, summary) and (title, link, summary, realm)
        if len(item) == 4:
            title, link, summary, realm = item
        else:
            title, link, summary = item
            realm = None

        # Clean up links to work with MkDocs directory URLs
        clean_link = link
        if clean_link.endswith('.md'):
            clean_link = clean_link[:-3]
            if not clean_link.endswith('/'):
                clean_link += '/'

        realm_class = f' realm-{realm.lower()}' if realm else ''
        # Escape any potential HTML in summary but keep it readable
        safe_summary = summary.replace('<', '&lt;').replace('>', '&gt;')
        f.write(f'  <a href="{clean_link}" class="card{realm_class}">\n')
        f.write(f'    <h3>{title}</h3>\n')
        f.write(f'    <p>{safe_summary}</p>\n')
        f.write(f'  </a>\n')
    f.write('</div>\n\n')


def generate_index_file(output_dir: Path, doc_type: str) -> None:
    """Generate an index.md file listing all documentation files in the directory with summaries."""
    output_dir.mkdir(parents=True, exist_ok=True)

    if not output_dir.exists():
        return

    md_files = sorted([f for f in output_dir.glob('*.md') if f.name != 'index.md'])

    subdirs = []
    if doc_type == 'generators':
        items_dir = output_dir / 'items'
        if items_dir.exists():
            items_files = sorted([f for f in items_dir.glob('*.md') if f.name != 'index.md'])
            if items_files:
                subdirs.append(('Item Generators', items_files))

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
        elif doc_type == 'about':
            f.write('General information about the Lilia framework, its features, and compatibility.\n\n')

        if md_files:
            items = []
            for md_file in md_files:
                # Use custom title for guides and generators
                if doc_type == 'guides':
                    file_title = get_custom_title('Guides', md_file)
                elif doc_type == 'about':
                    file_title = get_custom_title('About', md_file)
                elif doc_type == 'generators':
                    file_title = get_custom_title('Generators', md_file)
                else:
                    file_title, _ = extract_title_and_summary(md_file)

                link_name = md_file.name
                
                # Custom summary logic
                if doc_type == 'guides':
                    summary = get_custom_summary('Guides', md_file, output_dir.parent.parent)
                elif doc_type == 'about':
                    summary = get_custom_summary('About', md_file, output_dir.parent.parent)
                elif doc_type == 'generators':
                    summary = get_custom_summary('Generators', md_file, output_dir.parent.parent)
                else:
                    _, summary = extract_title_and_summary(md_file)
                
                items.append((file_title, f'./{link_name}', summary))
            
            write_cards(f, items)
        
        for subdir_name, subdir_files in subdirs:
            f.write(f'## {subdir_name.title()}\n\n')
            items = []
            for md_file in subdir_files:
                if doc_type == 'generators':
                     file_title = get_custom_title('Generators', md_file)
                     summary = get_custom_summary('Generators', md_file, output_dir.parent.parent)
                else:
                     file_title, _ = extract_title_and_summary(md_file)
                     _, summary = extract_title_and_summary(md_file)
                
                # Make link relative
                try:
                     rel_link = md_file.relative_to(output_dir).as_posix()
                except ValueError:
                     rel_link = md_file.name

                items.append((file_title, rel_link, summary))
            write_cards(f, items)
    
    print(f" Generated index.md for {doc_type}")


def generate_comprehensive_index(docs_dir: Path) -> None:
    """Generate a comprehensive index.md file that lists all documentation types in one page."""
    docs_dir.mkdir(parents=True, exist_ok=True)
    index_path = docs_dir / 'index.md'

    # Update sections based on new structure
    sections = []

    # Development Section
    dev_dir = docs_dir / 'development'
    if dev_dir.exists():
        # Subdirectories in development
        libraries_dir = dev_dir / 'libraries'
        meta_dir = dev_dir / 'meta'
        generators_dir = dev_dir / 'generators'
        hooks_dir = dev_dir / 'hooks'

        dev_subdirs = []
        
        if libraries_dir.exists():
            lib_files = sorted([f for f in libraries_dir.glob('*.md') if f.name != 'index.md'])
            if lib_files:
                dev_subdirs.append(('Libraries', libraries_dir, lib_files))
        
        if meta_dir.exists():
            meta_files = sorted([f for f in meta_dir.glob('*.md') if f.name != 'index.md'])
            if meta_files:
                dev_subdirs.append(('Meta', meta_dir, meta_files))
        
        if hooks_dir.exists():
            hook_files = sorted([f for f in hooks_dir.glob('*.md') if f.name != 'index.md'])
            if hook_files:
                dev_subdirs.append(('Hooks', hooks_dir, hook_files))

        if generators_dir.exists():
            gen_files = sorted([f for f in generators_dir.glob('*.md') if f.name != 'index.md'])
            gen_items_dir = generators_dir / 'items'
            gen_items_files = []
            if gen_items_dir.exists():
                gen_items_files = sorted([f for f in gen_items_dir.glob('*.md') if f.name != 'index.md'])
            
            # Combine generic generators and item generators
            all_gen_files = gen_files + gen_items_files
            if all_gen_files:
                dev_subdirs.append(('Generators', generators_dir, all_gen_files))

        if dev_subdirs:
             sections.append(('Development', dev_dir, [], dev_subdirs))


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
            
            items = []
            for md_file in files:
                custom_title = get_custom_title(section_name, md_file)
                if custom_title:
                    file_title = custom_title
                else:
                    file_title, _ = extract_title_and_summary(md_file)

                rel_path = md_file.relative_to(docs_dir).as_posix()
                custom_summary = get_custom_summary(section_name, md_file, docs_dir)
                summary = custom_summary or extract_title_and_summary(md_file)[1]
                items.append((file_title, f'./{rel_path}', summary))
            
            write_cards(f, items)

            # Handle subdirectories
            for subdir_info in subdirs:
                subdir_name = subdir_info[0]
                subdir_dir = subdir_info[1]
                subdir_files = subdir_info[2]

                f.write(f'### {subdir_name}\n\n')
                items = []
                for md_file in subdir_files:
                    # Logic for titles/summaries might need refinement based on subdir types
                    # For now generic extract
                    # Hacky hint (reusing guides logic for server owner files if needed, but 'Guides' logic is minimal)
                    
                    if subdir_name == 'Generators':
                         file_title = get_custom_title('Generators', md_file)
                    elif subdir_name == 'Compatibility':
                         file_title = get_custom_title('Guides', md_file) # Compatibility uses Guide titles map
                    else:
                         file_title, _ = extract_title_and_summary(md_file)

                    if not file_title:
                        file_title = md_file.stem.title()

                    rel_path = md_file.relative_to(docs_dir).as_posix()
                    
                    if subdir_name == 'Generators':
                        custom_summary = get_custom_summary('Generators', md_file, docs_dir)
                    elif subdir_name == 'Compatibility':
                        custom_summary = get_custom_summary('Guides', md_file, docs_dir)
                    else:
                        custom_summary = ''
                        
                    summary = custom_summary or extract_title_and_summary(md_file)[1]
                    items.append((file_title, f'./{rel_path}', summary))
                
                write_cards(f, items)

            f.write('\n')

    print(" Generated comprehensive index.md")


def generate_development_index(dev_dir: Path) -> None:
    """Generate an index.md for the development directory listing its subdirectories."""
    if not dev_dir.exists():
        return

    index_path = dev_dir / 'index.md'
    
    sections = [
        ('Libraries', 'libraries', 'Documentation for Lilia libraries.'),
        ('Meta', 'meta', 'Documentation for Lilia meta tables.'),
        ('Hooks', 'hooks', 'Documentation for Lilia hooks.')
    ]

    with open(index_path, 'w', encoding='utf-8') as f:
        f.write('# Development\n\n')
        f.write('Welcome to the development documentation associated with Lilia.\n\n')
        
        cards = []
        for title, dirname, summary in sections:
            subdir = dev_dir / dirname
            if subdir.exists() and any(subdir.iterdir()):
                cards.append((title, f'./{dirname}/', summary))
        
        write_cards(f, cards)

    print(f" Generated development/index.md")

def generate_pages_file(docs_dir: Path) -> None:
    """Generate .pages file for MkDocs navigation."""
    pages_path = docs_dir / '.pages'

 # Define the preferred order of navigation items
    nav_order = [
        'About',
        'Getting Started.md',
        'development',
        'generators'
    ]
    
    # We should also generate .pages for subdirectories to ensure order there
    
    # Development Pages
    dev_pages_path = docs_dir / 'development' / '.pages'
    if dev_pages_path.parent.exists():
        with open(dev_pages_path, 'w', encoding='utf-8') as f:
            f.write('title: Development\narrange:\n')
            f.write(' - libraries\n')
            f.write(' - meta\n')
            f.write(' - hooks\n')

 # Write root .pages file
    with open(pages_path, 'w', encoding='utf-8') as f:
        f.write('arrange:\n')
        for item in nav_order:
            f.write(f' - {item}\n')
            
    print(f"Generated .pages files for navigation")


if __name__ == '__main__':
    main()