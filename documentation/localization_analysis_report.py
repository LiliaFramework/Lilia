#!/usr/bin/env python3
"""
Localization analysis module for analyzing language file usage.
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Tuple, Set
from collections import defaultdict


def analyze_data(language_file: str, gamemode_path: str) -> Dict:
    """
    Analyze localization data from language file and gamemode usage.

    Args:
        language_file: Path to the language file (e.g., english.lua)
        gamemode_path: Path to the gamemode directory

    Returns:
        Dict containing analysis results
    """
    # Load language keys from file
    keys, key_lines = _load_language_keys(language_file)

    # Scan gamemode for localization usage
    usage_data = _scan_localization_usage(gamemode_path)

    # Analyze the data
    return _analyze_localization_data(keys, key_lines, usage_data, gamemode_path)


def _load_language_keys(language_file: str) -> Tuple[Dict[str, str], Dict[str, int]]:
    """Load language keys from Lua language file"""
    keys = {}
    key_lines = {}

    if not os.path.exists(language_file):
        print(f"Warning: Language file not found: {language_file}")
        return keys, key_lines

    try:
        with open(language_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        print(f"Warning: Could not read language file {language_file}: {e}")
        return keys, key_lines

    lines = content.split('\n')

    # Pattern for language table entries
    # Matches: LANGUAGE["key"] = "value" or LANGUAGE.key = "value"
    pattern = r'LANGUAGE\s*\[\s*[\'"]([^\'"]+)[\'"]\s*\]\s*=\s*[\'"]([^\'"]*)[\'"]|LANGUAGE\.(\w+)\s*=\s*[\'"]([^\'"]*)[\'"]'

    for line_num, line in enumerate(lines, 1):
        match = re.search(pattern, line)
        if match:
            if match.group(1):  # LANGUAGE["key"] = "value"
                key = match.group(1)
                value = match.group(2)
            else:  # LANGUAGE.key = "value"
                key = match.group(3)
                value = match.group(4)

            keys[key] = value
            key_lines[key] = line_num

    return keys, key_lines


def _scan_localization_usage(gamemode_path: str) -> Dict[str, List[Tuple[str, int, str, str]]]:
    """Scan gamemode files for localization function calls"""
    usage_data = defaultdict(list)
    gamemode_path = Path(gamemode_path)

    # Patterns for localization calls
    patterns = [
        # L(key, ...)
        (r'L\s*\(\s*[\'"]([^\'"]+)[\'"]', 'L'),
        # lia.lang.Get(key, ...)
        (r'lia\.lang\.Get\s*\(\s*[\'"]([^\'"]+)[\'"]', 'lia.lang.Get'),
        # LANGUAGE[key]
        (r'LANGUAGE\s*\[\s*[\'"]([^\'"]+)[\'"]\s*\]', 'LANGUAGE[]'),
    ]

    # Scan all Lua files
    for root, dirs, files in os.walk(gamemode_path):
        # Skip certain directories
        dirs[:] = [d for d in dirs if d not in ['node_modules', '.git']]

        for file in files:
            if file.endswith('.lua'):
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, gamemode_path)

                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                except Exception:
                    continue

                lines = content.split('\n')

                for line_num, line in enumerate(lines, 1):
                    for pattern, func_type in patterns:
                        for match in re.finditer(pattern, line):
                            key = match.group(1)
                            usage_data[key].append((relative_path, line_num, line.strip(), func_type))

    return usage_data


def _analyze_localization_data(keys: Dict[str, str], key_lines: Dict[str, int],
                              usage_data: Dict[str, List[Tuple[str, int, str, str]]],
                              gamemode_path: str) -> Dict:
    """Analyze localization data and return results"""
    results = {
        'keys': keys,
        'key_lines': key_lines,
        'usage_data': usage_data,
        'unused': [],
        'undefined_rows': [],
        'mismatch_rows': [],
        'at_pattern_rows': [],
        'total_hits': 0,
        'unused_count': 0,
        'undefined_count': 0,
        'mismatch_count': 0,
        'at_pattern_count': 0
    }

    # Count total usage
    for key, usages in usage_data.items():
        results['total_hits'] += len(usages)

    # Find unused keys
    used_keys = set(usage_data.keys())
    unused_keys = []
    for key in keys:
        if key not in used_keys:
            unused_keys.append(key)
    results['unused'] = unused_keys
    results['unused_count'] = len(unused_keys)

    # Find undefined keys (used but not defined) - unique keys only
    undefined_keys_seen = set()
    for key, usages in usage_data.items():
        if key not in keys and key not in undefined_keys_seen:
            undefined_keys_seen.add(key)
            # Use the first usage as representative
            usage = usages[0]
            results['undefined_rows'].append(usage + (key,))
    results['undefined_count'] = len(results['undefined_rows'])

    # Look for @xxxxx patterns (placeholders) - unique keys only
    at_pattern_keys_seen = set()
    for key, usages in usage_data.items():
        if key in keys and key not in at_pattern_keys_seen:
            value = keys[key]
            if '@' in value:
                at_pattern_keys_seen.add(key)
                # Use the first usage as representative
                usage = usages[0]
                results['at_pattern_rows'].append(usage + (key,))
    results['at_pattern_count'] = len(results['at_pattern_rows'])

    # Look for argument mismatches - unique keys only
    mismatch_keys_seen = set()
    for key, usages in usage_data.items():
        if key in keys and key not in mismatch_keys_seen:
            value = keys[key]
            # Count %s placeholders in the value
            placeholder_count = value.count('%s')

            for usage in usages:
                file_path, line_num, line_content, func_type = usage

                # For L() function calls, check if arguments match placeholders
                if func_type == 'L':
                    # Extract arguments after the key
                    args_match = re.search(r'L\s*\(\s*[\'"][^\'"]+[\'"]\s*,\s*(.+)\)', line_content)
                    if args_match:
                        args_str = args_match.group(1)
                        # Count commas (rough estimate of argument count)
                        arg_count = args_str.count(',') + 1 if args_str.strip() else 0

                        if arg_count != placeholder_count:
                            mismatch_keys_seen.add(key)
                            results['mismatch_rows'].append(usage + (key,))
                            break  # Only add once per key
    results['mismatch_count'] = len(results['mismatch_rows'])

    return results


# Report generation functions
def write_framework_md(data: Dict, output_path: str = None) -> str:
    """Write framework localization analysis to markdown"""
    if not output_path:
        output_path = "localization_framework_report.md"

    content = ["# Framework Localization Analysis", ""]

    content.extend(_generate_localization_summary(data))

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(content))

    return output_path


def write_framework_txt(data: Dict, output_path: str = None) -> str:
    """Write framework localization analysis to text"""
    if not output_path:
        output_path = "localization_framework_report.txt"

    content = ["FRAMEWORK LOCALIZATION ANALYSIS", "=" * 40, ""]

    # Simple text summary
    content.append(f"Language Keys: {len(data.get('keys', {}))}")
    content.append(f"Total Usages: {data.get('total_hits', 0)}")
    content.append(f"Unused Keys: {len(data.get('unused', []))}")
    content.append(f"Undefined Calls: {len(data.get('undefined_rows', []))}")
    content.append(f"Argument Mismatches: {len(data.get('mismatch_rows', []))}")
    content.append(f"@xxxxx Patterns: {len(data.get('at_pattern_rows', []))}")
    content.append("")

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(content))

    return output_path


def write_modules_md(data: Dict, output_path: str = None) -> str:
    """Write modules localization analysis to markdown"""
    if not output_path:
        output_path = "localization_modules_report.md"

    content = ["# Modules Localization Analysis", ""]

    # This would analyze module-specific localization
    content.append("Module-specific localization analysis not yet implemented.")
    content.append("")

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(content))

    return output_path


def write_modules_txt(data: Dict, output_path: str = None) -> str:
    """Write modules localization analysis to text"""
    if not output_path:
        output_path = "localization_modules_report.txt"

    content = ["MODULES LOCALIZATION ANALYSIS", "=" * 30, ""]

    content.append("Module-specific localization analysis not yet implemented.")
    content.append("")

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(content))

    return output_path


def _generate_localization_summary(data: Dict) -> List[str]:
    """Generate localization summary section"""
    lines = ["## Summary", ""]

    lines.append(f"- **Language Keys:** {len(data.get('keys', {}))}")
    lines.append(f"- **Total Usages:** {data.get('total_hits', 0)}")
    lines.append(f"- **Unused Keys:** {len(data.get('unused', []))}")
    lines.append(f"- **Undefined Calls:** {len(data.get('undefined_rows', []))}")
    lines.append(f"- **Argument Mismatches:** {len(data.get('mismatch_rows', []))}")
    lines.append(f"- **@xxxxx Patterns:** {len(data.get('at_pattern_rows', []))}")
    lines.append("")

    return lines


# Default paths for backwards compatibility
DEFAULT_FRAMEWORK_GAMEMODE_DIR = r"E:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode"
DEFAULT_LANGUAGE_FILE = r"E:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\languages\english.lua"
DEFAULT_MODULES_PATHS = [
    r"E:\GMOD\Server\garrysmod\gamemodes\metrorp\gitmodules",
    r"E:\GMOD\Server\garrysmod\gamemodes\metrorp\modules",
    r"E:\GMOD\Server\garrysmod\gamemodes\metrorp\devmodules"
]
