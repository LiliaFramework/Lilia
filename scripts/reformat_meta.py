import sys, re

RE_SECTION = re.compile(r'^### ')

files = sys.argv[1:]
for path in files:
    lines = open(path).read().splitlines()
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith('### '):
            name = line[4:].strip()
            j = i + 1
            while j < len(lines) and lines[j].strip() == '':
                j += 1
            code_block = []
            if j < len(lines) and lines[j].startswith('```'):
                start = j
                code_block.append(lines[j])
                j += 1
                while j < len(lines) and not lines[j].startswith('```'):
                    code_block.append(lines[j])
                    j += 1
                if j < len(lines):
                    code_block.append(lines[j])
                    j += 1
                while j < len(lines) and lines[j].strip() == '':
                    j += 1
            if j >= len(lines) or not lines[j].startswith('Description:'):
                # not a function section, keep as-is
                out.append(line)
                i += 1
                continue
            out.append(line)
            i = j
            # Description
            desc_lines = []
            if i < len(lines) and lines[i].startswith('Description:'):
                desc_line = lines[i][12:].strip()
                if desc_line:
                    desc_lines.append(desc_line)
                i += 1
                while i < len(lines) and not lines[i].startswith('Parameters:'):
                    if lines[i].strip():
                        desc_lines.append(lines[i].strip())
                    i += 1
            desc = ' '.join(l.strip() for l in desc_lines).strip()
            # Parameters
            params = []
            if i < len(lines) and lines[i].startswith('Parameters:'):
                i += 1
                while i < len(lines) and not lines[i].startswith('Realm:'):
                    if lines[i].strip():
                        params.append(lines[i].strip())
                    i += 1
            while i < len(lines) and lines[i].strip() == '':
                i += 1
            # Realm
            realm = ''
            if i < len(lines) and lines[i].startswith('Realm:'):
                realm = lines[i][6:].strip()
                i += 1
            while i < len(lines) and lines[i].strip() == '':
                i += 1
            # Returns
            returns = []
            if i < len(lines) and lines[i].startswith('Returns:'):
                i += 1
                while i < len(lines) and not (lines[i].startswith('Example') or lines[i].startswith('- *Example') or lines[i].startswith('```')):
                    if lines[i].strip():
                        returns.append(lines[i].strip())
                    i += 1
            while i < len(lines) and lines[i].strip() == '':
                i += 1
            # Example
            example = code_block[:]
            if i < len(lines) and (lines[i].startswith('Example') or lines[i].startswith('- *Example')):
                i += 1
                while i < len(lines) and not lines[i].startswith('```'):
                    i += 1
            if i < len(lines) and lines[i].startswith('```'):
                example.append(lines[i])
                i += 1
                while i < len(lines) and not lines[i].startswith('```'):
                    example.append(lines[i])
                    i += 1
                if i < len(lines):
                    example.append(lines[i])
                    i += 1
            # skip trailing blanks
            while i < len(lines) and lines[i].strip() == '':
                i += 1
            # expect ---
            if i < len(lines) and lines[i].startswith('---'):
                i += 1
            # Build new section
            out.append('')
            out.append('**Purpose**')
            out.append(desc)
            out.append('')
            out.append('**Parameters**')
            out.append('')
            if params:
                out.extend(params)
            else:
                out.append('- None')
            out.append('')
            out.append('**Realm**')
            out.append(f'`{realm}`')
            out.append('')
            out.append('**Returns**')
            out.append('')
            if returns:
                out.extend(returns)
            else:
                out.append('- nil')
            out.append('')
            out.append('**Example**')
            out.append('')
            out.extend(example)
            out.append('')
            out.append('---')
        else:
            out.append(line)
            i += 1
    with open(path, 'w') as f:
        f.write('\n'.join(out) + '\n')
