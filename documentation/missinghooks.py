#!/usr/bin/env python3
"""
Hook analysis module for finding missing hook documentation.
"""

import os
import re
from pathlib import Path
from typing import List, Set


def scan_hooks(base_path: str) -> List[str]:
    """Scan Lua files for hook.Add and hook.Run calls"""
    hooks_found = set()
    base_path = Path(base_path)

    # Scan all .lua files
    for root, dirs, files in os.walk(base_path):
        # Skip certain directories
        dirs[:] = [d for d in dirs if d not in ['node_modules', '.git']]

        for file in files:
            if file.endswith('.lua'):
                file_path = os.path.join(root, file)
                file_hooks = _extract_hooks_from_file(file_path)
                hooks_found.update(file_hooks)

    return sorted(list(hooks_found))


def _extract_hooks_from_file(file_path: str) -> Set[str]:
    """Extract hooks from a single Lua file"""
    hooks = set()

    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}")
        return hooks

    # Pattern for hook.Add calls
    # Matches: hook.Add("hook_name", ...)
    hook_add_pattern = r'hook\.Add\s*\(\s*([\'"`])([^\'"`]+)\1'

    # Pattern for hook.Run calls
    # Matches: hook.Run("hook_name", ...)
    hook_run_pattern = r'hook\.Run\s*\(\s*([\'"`])([^\'"`]+)\1'

    # Find hook.Add calls
    for match in re.finditer(hook_add_pattern, content):
        hook_name = match.group(2)
        if hook_name:
            hooks.add(hook_name.strip())

    # Find hook.Run calls
    for match in re.finditer(hook_run_pattern, content):
        hook_name = match.group(2)
        if hook_name:
            hooks.add(hook_name.strip())

    return hooks


def read_documented_hooks(hooks_doc_path: str) -> List[str]:
    """Read documented hooks from the hooks documentation file"""
    documented_hooks = set()
    hooks_doc_path = Path(hooks_doc_path)

    if not hooks_doc_path.exists():
        print(f"Warning: Hooks documentation file not found: {hooks_doc_path}")
        return []

    try:
        with open(hooks_doc_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        print(f"Warning: Could not read hooks documentation: {e}")
        return []

    lines = content.split('\n')

    for line in lines:
        # Look for hook names in backticks or as headers
        # Matches: `hook_name` or ## hook_name
        hook_match = re.search(r'`([^`]+)`', line)
        if hook_match:
            hook_name = hook_match.group(1).strip()
            if hook_name:
                documented_hooks.add(hook_name)

        # Also check for markdown headers
        header_match = re.search(r'^#+\s+(.+)', line)
        if header_match:
            header_text = header_match.group(1).strip()
            # If it looks like a hook name (contains Hook or has specific patterns)
            if 'Hook' in header_text or re.search(r'^[A-Z][a-zA-Z]+Hook', header_text):
                documented_hooks.add(header_text)

    return sorted(list(documented_hooks))
