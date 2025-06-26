import re
import os
from pathlib import Path

lib_dir = Path('gamemode/core/libraries')
docs_root = Path('docs/docs/framework/libraries')
docs_root.mkdir(parents=True, exist_ok=True)

block_pattern = re.compile(r'--\[\[(.*?)\]\]', re.S)
header_pattern = re.compile(r'^\s*([A-Za-z ]+):\s*$')
param_pattern = re.compile(r'^(.*?)\(([^)]*)\)\s*[\-\u2013]\s*(.*)$')

indent1 = '        '
indent2 = '            '

for lua_path in lib_dir.rglob('*.lua'):
    rel_name = lua_path.stem
    doc_file = docs_root / f'lia.{rel_name}.md'
    content = lua_path.read_text(errors='ignore')
    blocks = re.findall(block_pattern, content)
    if not blocks:
        continue
    with open(doc_file, 'a') as f:
        for block in blocks:
            lines = [ln.rstrip() for ln in block.splitlines()]
            if not lines:
                continue
            # skip initial empty lines to find the name
            name = None
            idx = 0
            for i, ln in enumerate(lines):
                if ln.strip():
                    name = ln.strip()
                    idx = i + 1
                    break
            if not name:
                continue
            fields = {
                'Description': [],
                'Parameters': [],
                'Returns': [],
                'Example Usage': []
            }
            extras = {}
            current_field = 'Description'
            for ln in lines[idx:]:
                if not ln.strip():
                    continue
                m = header_pattern.match(ln)
                if m:
                    current_field = m.group(1)
                    if current_field not in fields:
                        extras[current_field] = []
                    continue
                if current_field in fields:
                    fields[current_field].append(ln.strip())
                else:
                    extras.setdefault(current_field, []).append(ln.strip())

            description = '\n'.join(fields['Description']).strip()
            params = fields['Parameters']
            returns = fields['Returns']
            example = '\n'.join(fields['Example Usage']).strip()

            param_lines = []
            for p in params:
                pm = param_pattern.match(p)
                if pm:
                    name_p, typ_p, desc_p = pm.groups()
                    param_lines.append(f"* **{name_p.strip()}** *({typ_p.strip()})*: {desc_p.strip()}")
                else:
                    param_lines.append(f"* {p}")

            return_lines = []
            for r in returns:
                rm = param_pattern.match(r)
                if rm:
                    name_r, typ_r, desc_r = rm.groups()
                    return_lines.append(f"* **{name_r.strip()}** *({typ_r.strip()})*: {desc_r.strip()}")
                else:
                    return_lines.append(f"* {r}")

            f.write(f"{indent1}## {name}\n\n")
            f.write(f"{indent1}**Description:**\n")
            if description:
                f.write(f"{indent2}{description}\n\n")
            else:
                f.write(f"{indent2}None\n\n")
            f.write(f"{indent1}---\n\n")
            f.write(f"{indent1}### Parameters\n\n")
            if param_lines:
                for ln_p in param_lines:
                    f.write(f"{indent2}{ln_p}\n")
                f.write("\n")
            else:
                f.write(f"{indent2}None\n\n")
            f.write(f"{indent1}---\n\n")
            f.write(f"{indent1}### Returns\n\n")
            if return_lines:
                for ln_r in return_lines:
                    f.write(f"{indent2}{ln_r}\n")
                f.write("\n")
            else:
                f.write(f"{indent2}None\n\n")
            f.write(f"{indent1}---\n\n")
            for key, val in extras.items():
                val_text = '\n'.join(val).strip()
                f.write(f"{indent1}**{key}:**\n")
                if val_text:
                    f.write(f"{indent2}{val_text}\n\n")
                else:
                    f.write(f"{indent2}None\n\n")
                f.write(f"{indent1}---\n\n")
            f.write(f"{indent1}### Example\n\n")
            f.write(f"{indent2}```lua\n")
            if example:
                for line in example.splitlines():
                    f.write(f"{indent2}{line}\n")
            f.write(f"{indent2}```\n\n")
