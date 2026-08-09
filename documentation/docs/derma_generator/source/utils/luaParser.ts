import { EditorState, UIElement, ComponentType } from '../types';
import { getLiaDefaultProps, getLiaDefinition } from './liaComponentDefinitions';
import { getPrimaryRootId } from './hierarchy';

/**
 * A heuristic parser to convert simple GLua VGUI code back into EditorState.
 * Note: This is not a full Lua AST parser. It looks for specific patterns
 * used in VGUI creation (vgui.Create, SetPos, SetSize, etc.).
 */

const splitLuaArgs = (input: string): string[] => {
  const args: string[] = [];
  let current = '';
  let depth = 0;
  let quote = '';
  let escaped = false;
  for (const char of input) {
    if (quote) {
      current += char;
      if (escaped) escaped = false;
      else if (char === '\\') escaped = true;
      else if (char === quote) quote = '';
      continue;
    }
    if (char === '"' || char === "'") {
      quote = char;
      current += char;
      continue;
    }
    if (char === '(' || char === '{' || char === '[') depth++;
    if (char === ')' || char === '}' || char === ']') depth--;
    if (char === ',' && depth === 0) {
      args.push(current.trim());
      current = '';
      continue;
    }
    current += char;
  }
  if (current.trim()) args.push(current.trim());
  return args;
};

const parseLuaValue = (input: string): string | number | boolean | undefined => {
  const value = input.trim();
  if (value === 'true') return true;
  if (value === 'false') return false;
  if (/^-?\d+(?:\.\d+)?$/.test(value)) return Number(value);
  const stringMatch = value.match(/^"((?:\\.|[^"])*)"$/);
  if (stringMatch) return stringMatch[1].replace(/\\n/g, '\n').replace(/\\r/g, '\r').replace(/\\"/g, '"').replace(/\\\\/g, '\\');
  const colorMatch = value.match(/^Color\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*\d+)?\s*\)$/);
  if (colorMatch) return `#${[colorMatch[1], colorMatch[2], colorMatch[3]].map(part => Number(part).toString(16).padStart(2, '0')).join('')}`;
  return undefined;
};

const parseEditableLuaValue = (input: string): string => {
  const trimmed = input.trim();
  if (!trimmed || trimmed === 'nil') return '';
  const parsed = parseLuaValue(trimmed);
  return parsed === undefined ? trimmed : String(parsed);
};

const parseLuaTableEntries = (input: string): Record<string, string> => {
  const trimmed = input.trim().replace(/^\{/, '').replace(/\}$/, '');
  const entries: Record<string, string> = {};
  for (const part of splitLuaArgs(trimmed)) {
    const match = part.match(/^([A-Za-z_]\w*)\s*=\s*(.+)$/);
    if (match) entries[match[1]] = match[2].trim();
  }
  return entries;
};

const appendLiaOptionLine = (el: UIElement, key: string, line: string) => {
  const current = String(el.props.liaOptions?.[key] || '');
  el.props.liaOptions = {
    ...(el.props.liaOptions || {}),
    [key]: current ? `${current}
${line}` : line,
  };
};

export const parseLuaToState = (luaCode: string): EditorState | null => {
  try {
    const lines = luaCode.split('\n');
    const elements: Record<string, UIElement> = {};
    const varNameToId: Record<string, string> = {};
    let rootId: string | null = null;
    
    // Helper to get or create ID from varName
    const getId = (varName: string) => {
      if (varNameToId[varName]) return varNameToId[varName];
      const newId = Math.random().toString(36).substr(2, 9);
      varNameToId[varName] = newId;
      return newId;
    };

    // 1. First Pass: Identify all created elements
    lines.forEach(line => {
      const trimmed = line.trim();
      
      // Pattern: local myFrame = vgui.Create("DFrame")
      // Pattern: local btn = vgui.Create("DButton", myFrame)
      const createMatch = trimmed.match(/local\s+(\w+)\s*=\s*vgui\.Create\s*\(\s*"([^"]+)"(?:\s*,\s*(\w+))?\s*\)/);
      
      if (createMatch) {
        const varName = createMatch[1];
        const rawType = createMatch[2];
        if (rawType === 'liaItemIcon') return;
        const type = rawType as ComponentType;
        const parentVar = createMatch[3];
        
        const id = getId(varName);
        
        // Default props based on type (will be overwritten by setters)
        elements[id] = {
          id,
          type,
          parentId: parentVar ? getId(parentVar) : null,
          children: [], // will populate later
          props: {
            x: 0, y: 0, w: 100, h: 100,
            variableName: varName,
            // Defaults
            text: (type === 'DLabel' || type === 'DButton') ? type : undefined,
            ...getLiaDefaultProps(type)
          }
        };

        if (!parentVar && !rootId) rootId = id;
      }
    });

    // 2. Second Pass: properties and relationships
    lines.forEach(line => {
      const trimmed = line.trim();
      if (!trimmed) return;

      const paintlessFrameMatch = trimmed.match(/^(\w+)\.Paint\s*=\s*function\s*\([^)]*\)\s*end$/);
      if (paintlessFrameMatch) {
          const id = varNameToId[paintlessFrameMatch[1]];
          const el = id ? elements[id] : undefined;
          if (el?.type === ComponentType.DFrame) el.props.framePaintBackground = false;
          return;
      }

      const assignmentMatch = trimmed.match(/^(\w+)\.(\w+)\s*=\s*(.+)$/);
      if (assignmentMatch) {
        const assignmentId = varNameToId[assignmentMatch[1]];
        const assignmentEl = assignmentId ? elements[assignmentId] : undefined;
        const assignmentDefinition = assignmentEl ? getLiaDefinition(assignmentEl.type) : null;
        const setter = assignmentDefinition?.setters.find(item => item.kind === 'assign' && (item.target || item.method) === assignmentMatch[2]);
        if (assignmentEl && setter) {
          const key = setter.keys[0];
          const value = setter.rawKeys?.includes(key) ? assignmentMatch[3].trim() : parseLuaValue(assignmentMatch[3]);
          if (value !== undefined) {
            if (setter.source === 'props') {
              (assignmentEl.props as unknown as Record<string, unknown>)[key] = value;
            } else {
              assignmentEl.props.liaOptions = { ...(assignmentEl.props.liaOptions || {}), [key]: value };
            }
          }
          return;
        }
      }

      const memberMethodMatch = trimmed.match(/^(\w+)\.(\w+):(\w+)\((.*)\)$/);
      if (memberMethodMatch) {
        const memberId = varNameToId[memberMethodMatch[1]];
        const memberEl = memberId ? elements[memberId] : undefined;
        const memberDefinition = memberEl ? getLiaDefinition(memberEl.type) : null;
        const setter = memberDefinition?.setters.find(item => item.kind === 'memberMethod' && item.target === memberMethodMatch[2] && item.method === memberMethodMatch[3]);
        if (memberEl && setter) {
          const args = splitLuaArgs(memberMethodMatch[4]);
          setter.keys.forEach((key, index) => {
            const value = setter.rawKeys?.includes(key) ? (args[index] || '').trim() : parseLuaValue(args[index] || '');
            if (value === undefined) return;
            if (setter.source === 'props') {
              (memberEl.props as unknown as Record<string, unknown>)[key] = value;
            } else {
              memberEl.props.liaOptions = { ...(memberEl.props.liaOptions || {}), [key]: value };
            }
          });
          return;
        }
      }

      const varMatch = trimmed.match(/^(\w+):/);
      if (!varMatch) return;
      
      const varName = varMatch[1];
      const id = varNameToId[varName];
      if (!id || !elements[id]) return;

      const el = elements[id];
      const liaDefinition = getLiaDefinition(el.type);
      if (liaDefinition) {
        const methodMatch = trimmed.match(/^\w+:(\w+)\((.*)\)$/);
        if (methodMatch) {
          const comboRepeater = liaDefinition.repeaters?.find(item => item.format === 'comboItems');
          const menuRepeater = liaDefinition.repeaters?.find(item => item.format === 'dermaMenuItems');
          if (comboRepeater && methodMatch[1] === 'AddChoice') {
            const args = splitLuaArgs(methodMatch[2]);
            const text = parseEditableLuaValue(args[0] || '');
            const data = parseEditableLuaValue(args[1] || '');
            const tooltip = parseEditableLuaValue(args[2] || '');
            appendLiaOptionLine(el, comboRepeater.key, tooltip ? `${text}|${data}|${tooltip}` : data ? `${text}|${data}` : text);
          } else if (comboRepeater && methodMatch[1] === 'AddSpacer') {
            const args = splitLuaArgs(methodMatch[2]);
            appendLiaOptionLine(el, comboRepeater.key, `#spacer|${parseEditableLuaValue(args[0] || '')}`);
          } else if (menuRepeater && methodMatch[1] === 'AddOption') {
            const args = splitLuaArgs(methodMatch[2]);
            const text = parseEditableLuaValue(args[0] || '');
            const icon = parseEditableLuaValue(args[2] || '');
            if (el.props.liaOptions?.[menuRepeater.key] === liaDefinition.defaultOptions?.[menuRepeater.key]) {
              el.props.liaOptions = { ...(el.props.liaOptions || {}), [menuRepeater.key]: '' };
            }
            appendLiaOptionLine(el, menuRepeater.key, icon ? `${text}|${icon}` : text);
          } else if (menuRepeater && methodMatch[1] === 'AddSpacer') {
            if (el.props.liaOptions?.[menuRepeater.key] === liaDefinition.defaultOptions?.[menuRepeater.key]) {
              el.props.liaOptions = { ...(el.props.liaOptions || {}), [menuRepeater.key]: '' };
            }
            appendLiaOptionLine(el, menuRepeater.key, '#spacer');
          }

          if (el.type === ComponentType.liaLockCircle && methodMatch[1] === 'Start') {
            const args = splitLuaArgs(methodMatch[2]);
            const text = parseLuaValue(args[0] || '');
            const duration = parseLuaValue(args[1] || '');
            if (typeof text === 'string') el.props.text = text;
            if (typeof duration === 'number') el.props.liaOptions = { ...(el.props.liaOptions || {}), duration };
            const table = parseLuaTableEntries(args[2] || '{}');
            const rawKeys = new Set(['color', 'background', 'textColor', 'radius', 'thickness', 'position']);
            for (const [key, rawValue] of Object.entries(table)) {
              const value = rawKeys.has(key) ? rawValue : parseLuaValue(rawValue);
              if (value !== undefined) el.props.liaOptions = { ...(el.props.liaOptions || {}), [key]: value };
            }
          }

          const setter = liaDefinition.setters.find(item => (item.kind === undefined || item.kind === 'method') && item.method === methodMatch[1]);
          if (setter) {
            if (setter.method === 'LiteMode') {
              el.props.liaOptions = { ...(el.props.liaOptions || {}), liteMode: true };
            } else {
              const args = splitLuaArgs(methodMatch[2]);
              setter.keys.forEach((key, index) => {
                const parsedValue = setter.rawKeys?.includes(key) ? (args[index] || '').trim() : parseLuaValue(args[index] || '');
                if (parsedValue === undefined) return;
                if (setter.source === 'props') {
                  (el.props as unknown as Record<string, unknown>)[key] = parsedValue;
                } else {
                  el.props.liaOptions = { ...(el.props.liaOptions || {}), [key]: parsedValue };
                }
              });
            }
          }
        }
      }

      // :SetSize(w, h)
      const sizeMatch = trimmed.match(/:SetSize\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)/);
      if (sizeMatch) {
        el.props.w = parseInt(sizeMatch[1]);
        el.props.h = parseInt(sizeMatch[2]);
      }

      // :SetPos(x, y)
      const posMatch = trimmed.match(/:SetPos\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)/);
      if (posMatch) {
        el.props.x = parseInt(posMatch[1]);
        el.props.y = parseInt(posMatch[2]);
      }

      // :SetText("text") or :SetTitle("text")
      const textMatch = trimmed.match(/:(SetText|SetTitle)\s*\(\s*"([^"]*)"\s*\)/);
      if (textMatch) {
        const liaSetter = liaDefinition?.setters.find(setter => setter.method === textMatch[1]);
        if (!liaSetter || liaSetter.source === 'props') el.props.text = textMatch[2];
      }

      // :SetImage("path")
      const imgMatch = trimmed.match(/:SetImage\s*\(\s*"([^"]*)"\s*\)/);
      if (imgMatch) {
        el.props.imageUrl = imgMatch[1];
      }
      
      // :SetChecked(bool)
      const checkMatch = trimmed.match(/:SetChecked\s*\(\s*(true|false)\s*\)/);
      if (checkMatch && !liaDefinition?.setters.some(setter => setter.method === 'SetChecked')) {
        el.props.checked = checkMatch[1] === 'true';
      }

      // :SetAlpha(int)
      const alphaMatch = trimmed.match(/:SetAlpha\s*\(\s*(\d+)\s*\)/);
      if (alphaMatch) {
        el.props.opacity = parseInt(alphaMatch[1]);
      }
      
      // :SetContentAlignment(int) - heuristic map back to string
      const alignMatch = trimmed.match(/:SetContentAlignment\s*\(\s*(\d)\s*\)/);
      if (alignMatch && !liaDefinition?.setters.some(setter => setter.method === 'SetContentAlignment')) {
          const val = parseInt(alignMatch[1]);
          if (val === 4) el.props.textAlign = 'left';
          else if (val === 6) el.props.textAlign = 'right';
          else el.props.textAlign = 'center';
      }

      // Color parsing is tricky in Lua "Color(r,g,b)", simplistic approach
      // Look for custom paint containing Color(r,g,b)
      // This is very loose, but handles the generator's style
      if (line.includes('draw.RoundedBox')) {
          const colorMatch = line.match(/Color\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
          if (colorMatch) {
              const r = parseInt(colorMatch[1]).toString(16).padStart(2,'0');
              const g = parseInt(colorMatch[2]).toString(16).padStart(2,'0');
              const b = parseInt(colorMatch[3]).toString(16).padStart(2,'0');
              
              // If we see IsHovered, it might be hover color, otherwise base color
              // This parser assumes the generator structure: if else block
              // We'll simplisticly assume first color found in Paint is base or hover
              if (!el.props.color) {
                   el.props.color = `#${r}${g}${b}`;
              }
          }
      }
    });

    // 3. Link Children
    Object.values(elements).forEach(el => {
      if (el.parentId && elements[el.parentId]) {
        elements[el.parentId].children.push(el.id);
      }
    });

    if (Object.keys(elements).length === 0) return null;
    rootId = getPrimaryRootId(elements, rootId);

    return {
      elements,
      rootId,
      selectedId: rootId,
      selectedIds: rootId ? [rootId] : [],
      canvasWidth: 800,
      canvasHeight: 600
    };

  } catch (e) {
    console.error("Failed to parse Lua:", e);
    return null;
  }
};
