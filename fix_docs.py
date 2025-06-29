import os,glob,re

def format_block(text):
    lines=text.split('\n')
    indent=0
    out=[]
    for ln in lines:
        stripped=ln.strip()
        if stripped=='' and not ln.strip():
            out.append('')
            continue
        # decrease indent before line if closing
        if re.match(r'^(end|else|elseif|until)\b', stripped) or stripped.startswith('}'):
            indent=max(indent-1,0)
        out.append('    '*(indent+1)+stripped)
        # increase indent after line if opener
        if re.search(r'(\bdo$|\bthen$|\bfunction\b.*$)', stripped) or stripped.endswith('{') or stripped=='repeat':
            indent+=1
    return '\n'.join(out)

for path in glob.glob('docs/docs/libraries/*.md'):
    with open(path,'r') as f:
        lines=f.readlines()
    new=[]
    in_block=False
    code=[]
    for line in lines:
        if line.startswith('```lua') and not in_block:
            in_block=True
            new.append('```lua\n')
            code=[]
            continue
        if line.startswith('```') and in_block:
            in_block=False
            new.append(format_block('\n'.join(code))+'\n')
            new.append('```\n')
            continue
        if in_block:
            code.append(line.rstrip('\n'))
        else:
            new.append(line)
    with open(path,'w') as f:
        f.writelines(new)
