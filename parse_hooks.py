import re, os, pathlib, textwrap
from collections import defaultdict

root = pathlib.Path('docs/hooks')
output_dir = pathlib.Path('docs/docs/framework/hooks')
output_dir.mkdir(parents=True, exist_ok=True)

# Map prefixes to markdown filenames
prefix_map = {
    'class': output_dir / 'class_hooks.md',
    'faction': output_dir / 'faction_hooks.md',
    'gamemode': output_dir / 'gamemode_hooks.md',
}

pattern = re.compile(r"--\[\[(.*?)\]\]", re.S)
field_pattern = re.compile(r"^\s*(\w[\w ]*?):\s*$")
param_pattern = re.compile(r"^\s*(\S+)\s*\(([^)]+)\)\s*[\u2013\-]\s*(.*)$")

blocks_by_prefix = defaultdict(list)

for path in root.glob('*.lua'):
    prefix = path.stem.split('_')[0]
    out_path = prefix_map.get(prefix)
    if not out_path:
        continue
    text = path.read_text()
    for block in pattern.findall(text):
        lines = [l.rstrip() for l in block.splitlines()]
        # remove leading/trailing empty lines
        while lines and not lines[0].strip():
            lines.pop(0)
        while lines and not lines[-1].strip():
            lines.pop()
        if not lines:
            continue
        first = lines[0].strip()
        # skip blocks that don't look like hooks
        if ':' in first or first.lower().startswith('this file'):
            continue
        hook_name = first.split('(')[0].strip()
        fields = {}
        current = None
        for line in lines[1:]:
            m = field_pattern.match(line)
            if m:
                current = m.group(1)
                fields[current] = []
            else:
                if current:
                    fields[current].append(line.strip())
        if not fields:
            continue
        blocks_by_prefix[prefix].append((hook_name, fields))

for prefix, blocks in blocks_by_prefix.items():
    out_path = prefix_map[prefix]
    with open(out_path, 'a') as f:
        for hook_name, fields in blocks:
            f.write('        ## ' + hook_name + '\n\n')
            realm = fields.get('Realm', ['Unknown'])
            realm_text = realm[0] if realm else 'Unknown'
            f.write(f'        **Realm:** {realm_text}\n\n')
            desc_lines = fields.get('Description', [''])
            f.write('        **Description:**\n')
            for dl in desc_lines:
                f.write('            ' + dl + '\n')
            f.write('\n        ---\n\n')
            if 'Parameters' in fields:
                f.write('        ### Parameters\n\n')
                for pl in fields['Parameters']:
                    if not pl.strip():
                        continue
                    pm = param_pattern.match(pl)
                    if pm:
                        name, typ, desc = pm.groups()
                        f.write(f'            * **{name}** *({typ})*: {desc}\n')
                    else:
                        f.write(f'            * {pl}\n')
                f.write('\n        ---\n\n')
            if 'Returns' in fields:
                f.write('        ### Returns\n\n')
                for rl in fields['Returns']:
                    if not rl.strip():
                        continue
                    rm = param_pattern.match(rl)
                    if rm:
                        name, typ, desc = rm.groups()
                        f.write(f'            * **{name}** *({typ})*: {desc}\n')
                    else:
                        f.write(f'            * {rl}\n')
                f.write('\n        ---\n\n')
            for key, val in fields.items():
                if key in ('Description','Parameters','Returns','Realm','Example Usage'):
                    continue
                f.write(f'        **{key}:**\n')
                for l in val:
                    f.write('            ' + l + '\n')
                f.write('\n        ---\n\n')
            if 'Example Usage' in fields:
                f.write('        ### Example\n\n')
                f.write('            ```lua\n')
                for line in fields['Example Usage']:
                    f.write('            ' + line + '\n')
                f.write('            ```\n\n')

