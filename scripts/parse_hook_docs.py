import re
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HOOKS_DIR = ROOT / 'docs' / 'hooks'
OUTPUT_MAP = {
    'class': ROOT / 'docs' / 'docs' / 'framework' / 'hooks' / 'class_hooks.md',
    'faction': ROOT / 'docs' / 'docs' / 'framework' / 'hooks' / 'faction_hooks.md',
    'gamemode': ROOT / 'docs' / 'docs' / 'framework' / 'hooks' / 'gamemode_hooks.md',
}

FIELD_ORDER = ['Description', 'Parameters', 'Returns', 'Realm', 'Example Usage']

FIELD_PATTERN = re.compile(r'^\s*(\w[\w ]+):\s*$')
PARAM_PATTERN = re.compile(r'^\s*(.*?)\s*\(([^)]*)\)\s*[\-\u2013\:]\s*(.*)')


def parse_block(lines):
    block = {}
    extra_fields = []
    iterator = iter(lines)
    # first line is the hook name with args
    for line in iterator:
        line = line.strip()
        if line:
            name_line = line
            break
    else:
        return None
    if '(' not in name_line:
        return None
    name = name_line.split('(')[0].strip()
    block['Name'] = name
    current_field = None
    current_lines = []
    for line in iterator:
        if line.strip() == '':
            if current_field:
                current_lines.append('')
            continue
        match = FIELD_PATTERN.match(line)
        if match:
            if current_field:
                block.setdefault(current_field, []).extend(current_lines)
                current_lines = []
            current_field = match.group(1)
            continue
        current_lines.append(line.strip())
    if current_field:
        block.setdefault(current_field, []).extend(current_lines)
    # cleanup values
    for k, v in block.items():
        if isinstance(v, list):
            block[k] = '\n'.join(v).strip()
    return block


def parse_file(path):
    hooks = []
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    for chunk in re.findall(r'--\[\[(.*?)\]\]', content, re.S):
        lines = chunk.split('\n')
        parsed = parse_block(lines)
        if parsed and parsed.get('Name'):
            hooks.append(parsed)
    return hooks


def format_markdown(hook):
    lines = []
    lines.append(f"## {hook['Name']}")
    realm = hook.get('Realm', '').strip()
    if realm:
        lines.append(f"\n**Realm:** {realm}")
    desc = hook.get('Description', '').strip()
    if desc:
        lines.append(f"\n**Description:**  \n{desc}")
    lines.append("\n---")
    params = hook.get('Parameters')
    if params:
        lines.append("\n### Parameters")
        for p in params.split('\n'):
            if not p:
                continue
            m = PARAM_PATTERN.match(p)
            if m:
                name, typ, desc = m.groups()
                lines.append(f"* **{name.strip()}** *({typ.strip()})*: {desc.strip()}")
            else:
                lines.append(f"* {p.strip()}")
        lines.append("\n---")
    returns = hook.get('Returns')
    if returns:
        lines.append("\n### Returns")
        for r in returns.split('\n'):
            if not r:
                continue
            m = PARAM_PATTERN.match(r)
            if m:
                name, typ, desc = m.groups()
                lines.append(f"* **{name.strip()}** *({typ.strip()})*: {desc.strip()}")
            else:
                lines.append(f"* {r.strip()}")
        lines.append("\n---")
    # extras
    for key, value in hook.items():
        if key in ['Name', 'Description', 'Parameters', 'Returns', 'Realm', 'Example Usage']:
            continue
        if value.strip():
            lines.append(f"\n**{key}:**  \n{value.strip()}")
            lines.append("\n---")
    example = hook.get('Example Usage', '').strip()
    if example:
        lines.append("\n### Example\n")
        lines.append("```lua")
        lines.append(example)
        lines.append("```")
    lines.append("\n")
    return '\n'.join(lines)


def append_hooks(hooks, output_path):
    output = Path(output_path)
    if output.exists():
        existing = output.read_text(encoding='utf-8')
    else:
        existing = ''
    for hook in hooks:
        pattern = re.compile(r'^##\s+\**%s\**\s*$' % re.escape(hook['Name']), re.M)
        if pattern.search(existing):
            continue
        existing += format_markdown(hook)
    output.write_text(existing, encoding='utf-8')


def main():
    for lua_path in HOOKS_DIR.glob('*.lua'):
        name = lua_path.stem
        prefix = name.split('_')[0]
        target = OUTPUT_MAP.get(prefix)
        if not target:
            continue
        hooks = parse_file(lua_path)
        append_hooks(hooks, target)


if __name__ == '__main__':
    main()
