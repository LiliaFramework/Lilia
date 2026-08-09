import { EditorState, UIElement, ComponentType } from '../types';
import { getMethodsForComponent } from './componentDefinitions';
import { getLiaDefinition, isLiaComponent } from './liaComponentDefinitions';
import { getTopLevelIds } from './hierarchy';

const hexToRgb = (hex: string) => {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? `${parseInt(result[1], 16)}, ${parseInt(result[2], 16)}, ${parseInt(result[3], 16)}`
    : '255, 255, 255';
};

const hexToColorObj = (hex: string, alpha: number = 255) => {
  return `Color(${hexToRgb(hex)}, ${alpha})`;
};


const escapeLuaString = (value: string) => value
  .replace(/\\/g, '\\\\')
  .replace(/"/g, '\\"')
  .replace(/\n/g, '\\n')
  .replace(/\r/g, '\\r');

const serializeLiaValue = (value: string | number | boolean) => {
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  if (typeof value === 'number') return Number.isFinite(value) ? String(value) : '0';
  if (/^#[0-9a-f]{6}$/i.test(value)) return hexToColorObj(value);
  return `"${escapeLuaString(value)}"`;
};

const serializeComboData = (value: string) => {
  const trimmed = value.trim();
  if (!trimmed) return 'nil';
  if (trimmed === 'true' || trimmed === 'false') return trimmed;
  if (/^-?\d+(?:\.\d+)?$/.test(trimmed)) return trimmed;
  return `"${escapeLuaString(trimmed)}"`;
};

const emitComboItems = (varName: string, rawItems: string): string[] => {
  const lines: string[] = [];
  for (const rawLine of rawItems.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line) continue;
    const parts = line.split('|').map(part => part.trim());
    if (parts[0].toLowerCase() === '#spacer') {
      const text = parts.slice(1).join('|');
      lines.push(`${varName}:AddSpacer("${escapeLuaString(text)}")`);
      continue;
    }
    const text = parts[0] || '';
    const data = parts[1] || '';
    const tooltip = parts.slice(2).join('|');
    if (tooltip) {
      lines.push(`${varName}:AddChoice("${escapeLuaString(text)}", ${serializeComboData(data)}, "${escapeLuaString(tooltip)}")`);
    } else if (data) {
      lines.push(`${varName}:AddChoice("${escapeLuaString(text)}", ${serializeComboData(data)})`);
    } else {
      lines.push(`${varName}:AddChoice("${escapeLuaString(text)}")`);
    }
  }
  return lines;
};

const emitDermaMenuItems = (varName: string, rawItems: string): string[] => {
  const lines: string[] = [];
  for (const rawLine of rawItems.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line) continue;
    const parts = line.split('|').map(part => part.trim());
    if (parts[0].toLowerCase() === '#spacer') {
      lines.push(`${varName}:AddSpacer()`);
      continue;
    }
    const text = parts[0] || '';
    const icon = parts.slice(1).join('|');
    lines.push(`${varName}:AddOption("${escapeLuaString(text)}", function() end${icon ? `, "${escapeLuaString(icon)}"` : ''})`);
  }
  return lines;
};

const emitLockCircleStart = (varName: string, el: UIElement): string => {
  const options = el.props.liaOptions || {};
  const entries: string[] = [];
  const pushValue = (key: string, value: string | number | boolean | undefined, raw = false) => {
    if (value === undefined || value === '' || (typeof value === 'string' && value.trim() === '')) return;
    entries.push(`${key} = ${raw ? String(value).trim() : serializeLiaValue(value)}`);
  };
  pushValue('uppercase', options.uppercase as boolean | undefined);
  pushValue('holdTime', options.holdTime as number | undefined);
  pushValue('color', options.color as string | undefined, true);
  pushValue('background', options.background as string | undefined, true);
  pushValue('textColor', options.textColor as string | undefined, true);
  pushValue('percentFont', options.percentFont as string | undefined);
  pushValue('labelFont', options.labelFont as string | undefined);
  pushValue('radius', options.radius as string | undefined, true);
  pushValue('thickness', options.thickness as string | undefined, true);
  pushValue('startAngle', options.startAngle as number | undefined);
  pushValue('position', options.position as string | undefined, true);
  const duration = typeof options.duration === 'number' ? options.duration : 8;
  return `${varName}:Start("${escapeLuaString(el.props.text || 'Testing')}", ${duration}, {${entries.join(', ')}})`;
};

const createFontName = (family: string, size: number, weight: number) => {
    const standardFonts = ['DermaDefault', 'DermaDefaultBold', 'DermaLarge', 'ChatFont', 'TargetID', 'BudgetLabel'];
    if (standardFonts.includes(family)) return null;
    return `${family.replace(/\s+/g, '')}_${size}_${weight}`;
};

export const generateLuaCode = (state: EditorState): string => {
  const { elements } = state;
  const topLevelIds = getTopLevelIds(elements);
  if (topLevelIds.length === 0) return "-- Add a component to start";

  const lines: string[] = [];
  
  // Recursive function to generate code
  const traverse = (id: string, parentVarName: string | null) => {
    const el = elements[id];
    if (!el) return;
    
    const parent = parentVarName ? Object.values(elements).find(e => e.props.variableName === parentVarName) : null;
    const isDocked = (parent && parent.props.layoutMode && parent.props.layoutMode !== 'none') || (parent?.type === ComponentType.DCollapsibleCategory) || (parent?.type === ComponentType.DIconLayout);
    const isTab = el.type === ComponentType.DTab && parent?.type === ComponentType.DPropertySheet;
    const autoBehavior = el.props.autoLayoutBehavior || 'fixed';
    const varName = el.props.variableName;
    const isRoot = parentVarName === null;

    lines.push("");
    if (isTab) lines.push(`local ${varName} = vgui.Create("DPanel", ${parentVarName})`);
    else lines.push(`local ${varName} = vgui.Create("${el.type}"${!isRoot ? `, ${parentVarName}` : ''})`);
    
    if (isTab) {
        lines.push(`${varName}:SetBackgroundColor(${hexToColorObj(el.props.color || '#ffffff')})`);
    } else if (isDocked) {
         if (parent?.type === ComponentType.DIconLayout) {
             lines.push(`${varName}:SetSize(${el.props.w}, ${el.props.h})`);
         } else if (parent?.type === ComponentType.DCollapsibleCategory) {
              lines.push(`${varName}:Dock(TOP)`);
              if (autoBehavior === 'fixed') lines.push(`${varName}:SetHeight(${el.props.h})`);
         } else {
             if (autoBehavior === 'fill') lines.push(`${varName}:Dock(FILL)`);
             else lines.push(`${varName}:Dock(${parent?.props.layoutMode === 'vertical' ? 'TOP' : 'LEFT'})`);
             
             if (parent?.props.layoutSpacing) {
                  lines.push(`${varName}:DockMargin(0, 0, ${parent.props.layoutMode === 'horizontal' ? parent.props.layoutSpacing : 0}, ${parent.props.layoutMode === 'vertical' ? parent.props.layoutSpacing : 0})`);
             }
             if (autoBehavior === 'fixed') lines.push(`${varName}:SetSize(${el.props.w}, ${el.props.h})`);
         }
    } else {
         lines.push(`${varName}:SetSize(${el.props.w}, ${el.props.h})`);
         lines.push(`${varName}:SetPos(${el.props.x}, ${el.props.y})`);
    }

    if (isRoot) lines.push(`${varName}:MakePopup()`);

    if (el.props.layoutMode && el.props.layoutMode !== 'none' && el.props.layoutPadding) {
        lines.push(`${varName}:DockPadding(${el.props.layoutPadding}, ${el.props.layoutPadding}, ${el.props.layoutPadding}, ${el.props.layoutPadding})`);
    }

    if (el.props.text !== undefined) {
      if ([ComponentType.DLabel, ComponentType.DButton, ComponentType.DCheckBox, ComponentType.DNumSlider].includes(el.type)) lines.push(`${varName}:SetText("${el.props.text}")`);
      else if (el.type === ComponentType.DFrame) lines.push(`${varName}:SetTitle("${el.props.text}")`);
      else if (el.type === ComponentType.DCollapsibleCategory) lines.push(`${varName}:SetLabel("${el.props.text}")`);
    }

    // DFrame specific properties
    if (el.type === ComponentType.DFrame) {
        if (el.props.sizable === false) lines.push(`${varName}:SetSizable(false)`);
        if (el.props.draggable === false) lines.push(`${varName}:SetDraggable(false)`);
        if (el.props.showCloseButton === false) lines.push(`${varName}:ShowCloseButton(false)`);
        if (el.props.deleteOnClose) lines.push(`${varName}:SetDeleteOnClose(true)`);
    }

    // DImage specific properties
    if (el.type === ComponentType.DImage) {
        if (el.props.imageUrl) lines.push(`${varName}:SetImage("${el.props.imageUrl}")`);
        if (el.props.keepAspect) lines.push(`${varName}:SetKeepAspect(true)`);
        if (el.props.imageColor) lines.push(`${varName}:SetImageColor(${hexToColorObj(el.props.imageColor)})`);
    }
    
    // Visibility and Enabled
    if (el.props.visible === false) {
        lines.push(`${varName}:SetVisible(false)`);
    }
    if (el.props.enabled === false) {
        lines.push(`${varName}:SetEnabled(false)`);
    }

    const liaDefinition = getLiaDefinition(el.type);
    if (liaDefinition) {
        if (el.type === ComponentType.liaLockCircle) lines.push(emitLockCircleStart(varName, el));
        const finalizeMethods: string[] = [];
        for (const repeater of liaDefinition.repeaters || []) {
            const rawValue = el.props.liaOptions?.[repeater.key];
            if (typeof rawValue === 'string' && rawValue.trim()) {
                if (repeater.format === 'comboItems') lines.push(...emitComboItems(varName, rawValue));
                else if (repeater.format === 'dermaMenuItems') lines.push(...emitDermaMenuItems(varName, rawValue));
                if (repeater.finalizeMethod) finalizeMethods.push(repeater.finalizeMethod);
            }
        }
        for (const setter of liaDefinition.setters) {
            const source = setter.source === 'props' ? el.props : el.props.liaOptions || {};
            const values = setter.keys.map(key => (source as Record<string, unknown>)[key]) as Array<string | number | boolean | undefined>;
            if (setter.method === 'LiteMode') {
                if (values[0] === true) lines.push(`${varName}:LiteMode()`);
                continue;
            }
            if (values.some(value => value === undefined)) continue;
            if (!setter.alwaysEmit && values.some(value => typeof value === 'string' && value.length === 0)) continue;
            const serialized = values.map((value, index) => {
                const key = setter.keys[index];
                if (setter.rawKeys?.includes(key)) return String(value).trim();
                return serializeLiaValue(value as string | number | boolean);
            });
            if (serialized.some(value => value.length === 0)) continue;
            if (setter.kind === 'assign') {
                lines.push(`${varName}.${setter.target || setter.method} = ${serialized[0]}`);
            } else if (setter.kind === 'memberMethod' && setter.target) {
                lines.push(`${varName}.${setter.target}:${setter.method}(${serialized.join(', ')})`);
            } else {
                lines.push(`${varName}:${setter.method}(${serialized.join(', ')})`);
            }
        }
        finalizeMethods.forEach(method => lines.push(`${varName}:${method}()`));
        if (el.type === ComponentType.liaVoicePanel && el.props.liaOptions?.voiceType) {
            lines.push(`${varName}:UpdateText()`);
            lines.push(`${varName}:UpdateTooltip()`);
        }
    }

    const isPaintlessFrame = el.type === ComponentType.DFrame && el.props.framePaintBackground === false;
    const hasCustomPaint = !isLiaComponent(el.type) && !isPaintlessFrame && (el.props.color || el.props.hoverColor || (el.props.borderWidth && el.props.borderWidth > 0) || el.props.hoverBorderColor || el.props.hoverBorderWidth || el.props.textShadow);
    const hasTitleBarColor = !isPaintlessFrame && el.type === ComponentType.DFrame && el.props.titleBarColor;

    if (isPaintlessFrame) {
         lines.push(`${varName}.Paint = function() end`);
    } else if (hasCustomPaint || hasTitleBarColor) {
         lines.push(`${varName}.Paint = function(self, w, h)`);
         
         if (el.props.hoverScale && el.props.hoverScale !== 1) {
              lines.push(`    if self:IsHovered() then`);
              lines.push(`        local m = Matrix()`);
              lines.push(`        m:Translate(Vector(w/2, h/2, 0))`);
              lines.push(`        m:Scale(Vector(${el.props.hoverScale}, ${el.props.hoverScale}, 1))`);
              lines.push(`        m:Translate(-Vector(w/2, h/2, 0))`);
              lines.push(`        cam.PushModelMatrix(m)`);
              lines.push(`    end`);
         }

         const baseColor = el.props.color || (el.type === ComponentType.DPanel || el.type === ComponentType.DFrame ? '#ffffff' : null);
         if (baseColor) {
             const hoverColor = el.props.hoverColor || baseColor;
             lines.push(`    local bg = self:IsHovered() and ${hexToColorObj(hoverColor)} or ${hexToColorObj(baseColor)}`);
             lines.push(`    draw.RoundedBox(${el.props.borderRadius || 0}, 0, 0, w, h, bg)`);
         }
         
         if (hasTitleBarColor) {
             lines.push(`    draw.RoundedBoxEx(${el.props.borderRadius || 0}, 0, 0, w, 24, ${hexToColorObj(el.props.titleBarColor!)}, true, true, false, false)`);
         }

         const bWidth = el.props.borderWidth || 0;
         const hbWidth = el.props.hoverBorderWidth !== undefined ? el.props.hoverBorderWidth : bWidth;
         if (bWidth > 0 || hbWidth > 0) {
             const bColor = el.props.borderColor || '#000000';
             const hbColor = el.props.hoverBorderColor || bColor;
             lines.push(`    local bw = self:IsHovered() and ${hbWidth} or ${bWidth}`);
             lines.push(`    local bc = self:IsHovered() and ${hexToRgb(hbColor)} or ${hexToRgb(bColor)}`);
             lines.push(`    surface.SetDrawColor(bc)`);
             lines.push(`    surface.DrawOutlinedRect(0, 0, w, h, bw)`); 
         }

         if (el.props.text && [ComponentType.DLabel, ComponentType.DButton].includes(el.type)) {
             const font = el.props.fontFamily || (el.type === ComponentType.DLabel ? "DermaDefault" : "DermaDefaultBold");
             const align = el.props.textAlign === 'left' ? 0 : el.props.textAlign === 'right' ? 2 : 1;
             const tx = el.props.textAlign === 'left' ? 5 : el.props.textAlign === 'right' ? 'w-5' : 'w/2';
             
             if (el.props.textShadow) {
                 const so = el.props.textShadowOffset || 1;
                 const sc = el.props.textShadowColor || '#000000';
                 lines.push(`    draw.SimpleText("${el.props.text}", "${font}", ${tx}+${so}, h/2+${so}, ${hexToColorObj(sc)}, ${align}, 1)`);
             }
             lines.push(`    draw.SimpleText("${el.props.text}", "${font}", ${tx}, h/2, color_white, ${align}, 1)`);
         }

         if (el.props.hoverScale && el.props.hoverScale !== 1) {
             lines.push(`    if self:IsHovered() then cam.PopModelMatrix() end`);
         }
         lines.push(`end`);
    }
    
    // Add custom methods
    if (el.props.methods) {
        Object.entries(el.props.methods).forEach(([methodName, code]) => {
             lines.push(`function ${varName}:${methodName}(${getMethodsForComponent(el.type).find(m => m.name === methodName)?.args.join(', ') || ''})`);
             lines.push(code);
             lines.push(`end`);
        });
    }

    el.children.forEach(childId => traverse(childId, varName));
  };

  topLevelIds.forEach(id => traverse(id, null));
  return lines.join('\n');
};
