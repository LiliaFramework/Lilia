import React from 'react';
import { UIElement, ComponentType } from '../types';
import { Hash, Type, Layout, Palette, CheckCircle, Trash2, Settings2, AlignLeft, AlignCenter, AlignRight, MousePointer, Info, FolderTree, Sparkles, Image as ImageIcon, Layers, Move, Wand2, Box, Eye, LayoutTemplate } from 'lucide-react';
import { getLiaDefinition, isContainerType } from '../utils/liaComponentDefinitions';
import { canAcceptChildren, getDescendantIds } from '../utils/hierarchy';

interface PropertiesPanelProps {
  selectedElement: UIElement | null;
  allElements: Record<string, UIElement>; // Needed for parenting
  onChange: (id: string, updates: Partial<UIElement['props']>) => void;
  onReparent: (id: string, newParentId: string | null) => void;
  onDelete: (id: string) => void;
}

const Section = ({ title, icon: Icon, children }: { title: string, icon: any, children?: React.ReactNode }) => (
  <div className="border-b border-neutral-800 pb-4 mb-4 last:border-0 last:mb-0 last:pb-0">
    <div className="flex items-center gap-2 mb-3 text-neutral-500 bg-neutral-800/30 p-1.5 rounded">
      <Icon className="w-3.5 h-3.5" />
      <h3 className="text-[10px] font-bold uppercase tracking-wider">{title}</h3>
    </div>
    <div className="space-y-3 px-1">
      {children}
    </div>
  </div>
);

const ColorInput = ({ label, value, onChange }: { label: string, value: string, onChange: (val: string) => void }) => {
    // Basic hex helper
    const r = parseInt(value.slice(1, 3), 16) || 0;
    const g = parseInt(value.slice(3, 5), 16) || 0;
    const b = parseInt(value.slice(5, 7), 16) || 0;

    const updateHex = (c: 'r' | 'g' | 'b', val: number) => {
        val = Math.min(255, Math.max(0, val));
        const hex = val.toString(16).padStart(2, '0');
        let newHex = value;
        if (c === 'r') newHex = `#${hex}${value.slice(3, 7)}`;
        if (c === 'g') newHex = `#${value.slice(1, 3)}${hex}${value.slice(5, 7)}`;
        if (c === 'b') newHex = `#${value.slice(1, 5)}${hex}`;
        onChange(newHex);
    };

    return (
        <div className="space-y-2">
            <div className="flex items-center justify-between">
                <label className="block text-[10px] text-neutral-400">{label}</label>
                <span className="text-[9px] font-mono text-neutral-500">{value}</span>
            </div>
            <div className="flex gap-2">
                <div className="w-8 h-8 rounded border border-neutral-700 overflow-hidden relative cursor-pointer shrink-0">
                    <input 
                        type="color" value={value} onChange={(e) => onChange(e.target.value)}
                        className="absolute inset-[-4px] w-[150%] h-[150%] p-0 border-0 cursor-pointer"
                    />
                </div>
                <div className="flex gap-1 flex-1">
                    <input type="number" value={r} onChange={(e) => updateHex('r', parseInt(e.target.value))} className="w-full bg-neutral-800 rounded border border-neutral-700 text-center text-[10px] text-red-300" placeholder="R" />
                    <input type="number" value={g} onChange={(e) => updateHex('g', parseInt(e.target.value))} className="w-full bg-neutral-800 rounded border border-neutral-700 text-center text-[10px] text-green-300" placeholder="G" />
                    <input type="number" value={b} onChange={(e) => updateHex('b', parseInt(e.target.value))} className="w-full bg-neutral-800 rounded border border-neutral-700 text-center text-[10px] text-blue-300" placeholder="B" />
                </div>
            </div>
        </div>
    );
};

const PropertiesPanel: React.FC<PropertiesPanelProps> = ({ selectedElement, allElements, onChange, onReparent, onDelete }) => {
  if (!selectedElement) {
    return (
      <div className="w-full h-full bg-neutral-900 p-6 flex flex-col items-center justify-center text-center text-neutral-500 shrink-0">
        <Settings2 className="w-10 h-10 mb-4 opacity-20" />
        <p className="text-sm font-medium">No Selection</p>
        <p className="text-xs mt-1 opacity-60">Click an element to edit</p>
      </div>
    );
  }

  const { props, type, id } = selectedElement;
  const liaDefinition = getLiaDefinition(type);

  const handleChange = (key: string, value: any) => {
    const intKeys = ['x','y','w','h', 'borderWidth', 'borderRadius', 'opacity', 'fontSize', 'fontWeight', 'layoutSpacing', 'layoutPadding', 'textShadowOffset', 'hoverOpacity', 'modelFov', 'sliderDecimals'];
    // Floats include the new slider/progress 0–1 ratios + DNumSlider value/min/max
    // (which can be fractional with decimals > 0).
    const floatKeys = ['hoverScale', 'progressFraction', 'sliderX', 'sliderY', 'sliderLockX', 'sliderLockY', 'sliderMin', 'sliderMax', 'sliderValue'];
    let finalValue: any = value;
    if (intKeys.includes(key)) finalValue = parseInt(value) || 0;
    else if (floatKeys.includes(key)) finalValue = parseFloat(value) || 0;
    onChange(id, { [key]: finalValue });
  };

  const handleLiaOptionChange = (key: string, value: string | number | boolean) => {
    onChange(id, { liaOptions: { ...(props.liaOptions || {}), [key]: value } });
  };

  const autoGenerateHoverColor = () => {
      if (!props.color) return;
      // Simple lighten logic
      const hex = props.color.replace('#', '');
      const r = parseInt(hex.substring(0, 2), 16);
      const g = parseInt(hex.substring(2, 4), 16);
      const b = parseInt(hex.substring(4, 6), 16);
      
      // Lighten by 20%
      const lighten = (c: number) => Math.min(255, Math.floor(c + (255 - c) * 0.2));
      const nr = lighten(r).toString(16).padStart(2, '0');
      const ng = lighten(g).toString(16).padStart(2, '0');
      const nb = lighten(b).toString(16).padStart(2, '0');
      
      onChange(id, { hoverColor: `#${nr}${ng}${nb}` });
  };

  // Logic for finding valid parents
  const descendants = getDescendantIds(allElements, id);
  const validParents = (Object.values(allElements) as UIElement[]).filter((el) => {
      if (el.id === id || descendants.has(el.id)) return false;
      return canAcceptChildren(el.type);
  });

  // Check parent layout mode
  const parent = selectedElement.parentId ? allElements[selectedElement.parentId] : null;
  const isParentAutoLayout = parent && parent.props.layoutMode && parent.props.layoutMode !== 'none';
  const parentLayoutMode = parent?.props.layoutMode;

  // DTab specific: if parent is DPropertySheet, we assume auto layout in a way (tab managed)
  const isTabInSheet = type === ComponentType.DTab && parent?.type === ComponentType.DPropertySheet;

  return (
    <div className="w-full h-full bg-neutral-900 flex flex-col shrink-0 overflow-y-auto custom-scrollbar">
      {/* Header */}
      <div className="p-4 border-b border-neutral-800 flex justify-between items-center bg-neutral-800/50 sticky top-0 z-10 backdrop-blur-sm">
        <div className="flex flex-col min-w-0 pr-2">
          <span className="text-[10px] font-mono text-blue-400 uppercase tracking-tight">{type}</span>
          <span className="text-sm font-bold text-white truncate font-mono" title={props.variableName}>{props.variableName}</span>
        </div>
        <button 
          onClick={() => onDelete(id)}
          className="text-neutral-500 hover:text-red-400 hover:bg-red-900/20 p-2 rounded transition-colors shrink-0"
          title="Delete Element"
        >
          <Trash2 className="w-4 h-4" />
        </button>
      </div>

      <div className="p-4">
        
        {/* Dimensions Section */}
        <Section title="Geometry" icon={Layout}>
          <div className="grid grid-cols-2 gap-2">
            <div>
              <label className="block text-[10px] text-neutral-400 mb-1">X Pos</label>
              <input 
                type="number" value={props.x} onChange={(e) => handleChange('x', e.target.value)}
                className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white focus:border-blue-500 focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed"
                disabled={isParentAutoLayout || isTabInSheet}
                title={(isParentAutoLayout || isTabInSheet) ? "Controlled by parent layout" : ""}
              />
            </div>
            <div>
              <label className="block text-[10px] text-neutral-400 mb-1">Y Pos</label>
              <input 
                type="number" value={props.y} onChange={(e) => handleChange('y', e.target.value)}
                className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white focus:border-blue-500 focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed"
                disabled={isParentAutoLayout || isTabInSheet}
                title={(isParentAutoLayout || isTabInSheet) ? "Controlled by parent layout" : ""}
              />
            </div>
            <div>
              <label className="block text-[10px] text-neutral-400 mb-1">Width</label>
              <input 
                type="number" value={props.w} onChange={(e) => handleChange('w', e.target.value)}
                className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white focus:border-blue-500 focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed"
                disabled={(isParentAutoLayout && parentLayoutMode === 'vertical') || isTabInSheet}
                title={((isParentAutoLayout && parentLayoutMode === 'vertical') || isTabInSheet) ? "Fills parent width" : ""}
              />
            </div>
            <div>
              <label className="block text-[10px] text-neutral-400 mb-1">Height</label>
              <input 
                type="number" value={props.h} onChange={(e) => handleChange('h', e.target.value)}
                className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white focus:border-blue-500 focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed"
                disabled={(isParentAutoLayout && parentLayoutMode === 'horizontal') || isTabInSheet}
                title={((isParentAutoLayout && parentLayoutMode === 'horizontal') || isTabInSheet) ? "Fills parent height" : ""}
              />
            </div>
          </div>
        </Section>
        
        {/* Structure Section for Parenting */}
        <Section title="Hierarchy" icon={FolderTree}>
            <div className="space-y-1">
                <label className="block text-[10px] text-neutral-400">Parent Element</label>
                <select 
                    value={selectedElement.parentId || ''}
                    onChange={(e) => onReparent(id, e.target.value || null)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 focus:outline-none"
                >
                    <option value="">Top level (no parent)</option>
                    {validParents.map(parent => (
                        <option key={parent.id} value={parent.id}>
                            {parent.props.variableName} ({parent.type})
                        </option>
                    ))}
                </select>
            </div>
        </Section>

        {/* Auto Layout Section */}
        {(type === ComponentType.DFrame || type === ComponentType.DPanel || type === ComponentType.DScrollPanel || type === ComponentType.DTab || type === ComponentType.DForm || isContainerType(type)) && (
             <Section title="Auto Layout" icon={Move}>
                 <div className="space-y-3">
                     <div>
                        <label className="block text-[10px] text-neutral-400 mb-1">Children Layout Mode</label>
                        <select 
                            value={props.layoutMode || 'none'} 
                            onChange={(e) => handleChange('layoutMode', e.target.value)}
                            className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                        >
                            <option value="none">None (Manual)</option>
                            <option value="vertical">Vertical Stack (Fill Top)</option>
                            <option value="horizontal">Horizontal Stack (Fill Left)</option>
                        </select>
                     </div>
                     {props.layoutMode && props.layoutMode !== 'none' && (
                         <div className="grid grid-cols-2 gap-2">
                             <div>
                                <label className="block text-[10px] text-neutral-400 mb-1">Spacing (px)</label>
                                <input 
                                    type="number" value={props.layoutSpacing || 0} onChange={(e) => handleChange('layoutSpacing', e.target.value)}
                                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                                />
                             </div>
                             <div>
                                <label className="block text-[10px] text-neutral-400 mb-1">Padding (px)</label>
                                <input 
                                    type="number" value={props.layoutPadding || 0} onChange={(e) => handleChange('layoutPadding', e.target.value)}
                                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                                />
                             </div>
                         </div>
                     )}
                 </div>
             </Section>
        )}
        
        {/* DFrame Window Settings */}
        {type === ComponentType.DFrame && (
            <Section title="Window Settings" icon={LayoutTemplate}>
                <div className="space-y-3">
                    <ColorInput label="Title Bar Color" value={props.titleBarColor || '#2a2a2a'} onChange={(v) => handleChange('titleBarColor', v)} />
                    
                    <div className="flex flex-col gap-2">
                         <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                            <span>Paint Frame</span>
                            <input
                                type="checkbox" checked={props.framePaintBackground !== false} onChange={(e) => handleChange('framePaintBackground', e.target.checked)}
                                className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                            />
                         </label>
                         <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                            <span>Show Close Button</span>
                            <input 
                                type="checkbox" checked={props.showCloseButton !== false} onChange={(e) => handleChange('showCloseButton', e.target.checked)} 
                                className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                            />
                         </label>
                         <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                            <span>Draggable (Runtime)</span>
                            <input 
                                type="checkbox" checked={props.draggable !== false} onChange={(e) => handleChange('draggable', e.target.checked)} 
                                className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                            />
                         </label>
                         <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                            <span>Sizable (Runtime)</span>
                            <input 
                                type="checkbox" checked={props.sizable !== false} onChange={(e) => handleChange('sizable', e.target.checked)} 
                                className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                            />
                         </label>
                         <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                            <span>Delete on Close</span>
                            <input 
                                type="checkbox" checked={props.deleteOnClose !== false} onChange={(e) => handleChange('deleteOnClose', e.target.checked)} 
                                className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                            />
                         </label>
                    </div>
                </div>
            </Section>
        )}

        {/* Content Section */}
        <Section title="Content" icon={Type}>
             <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Variable Name</label>
                <input 
                  type="text" value={props.variableName} onChange={(e) => handleChange('variableName', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono focus:border-blue-500 focus:outline-none"
                />
             </div>
             
             {(type === ComponentType.DLabel || type === ComponentType.DButton || type === ComponentType.DFrame || type === ComponentType.DCheckBox || type === ComponentType.DTextEntry || type === ComponentType.DComboBox || type === ComponentType.DTab || type === ComponentType.DForm || type === ComponentType.DNumSlider || type === ComponentType.DCollapsibleCategory || liaDefinition?.defaultText !== undefined) && (
                <div className="mt-2">
                  <label className="block text-[10px] text-neutral-400 mb-1">
                      {type === ComponentType.DTab ? "Tab Title" :
                       type === ComponentType.DForm ? "Form Label" :
                       type === ComponentType.DNumSlider ? "Slider Label" :
                       type === ComponentType.DCollapsibleCategory ? "Header Label" :
                       "Label / Text"}
                  </label>
                  <input
                    type="text" value={props.text || ''} onChange={(e) => handleChange('text', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 focus:outline-none"
                  />
                </div>
             )}

             {/* DRichText: multi-line textarea for content */}
             {type === ComponentType.DRichText && (
                <div className="mt-2">
                  <label className="block text-[10px] text-neutral-400 mb-1">Rich Text Content</label>
                  <textarea
                    value={props.text || ''}
                    onChange={(e) => handleChange('text', e.target.value)}
                    rows={6}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 focus:outline-none font-mono"
                    placeholder={'Line one\nLine two\n...'}
                  />
                  <p className="text-[10px] text-neutral-600 mt-1">Use \n for line breaks. Emitted via :AppendText().</p>
                </div>
             )}

             {/* Text Shadow */}
             {(type === ComponentType.DLabel || type === ComponentType.DButton) && (
                 <div className="mt-3 pt-3 border-t border-neutral-800">
                     <div className="flex items-center justify-between mb-2">
                         <label className="text-[10px] text-neutral-400 font-semibold">Text Shadow</label>
                         <input 
                            type="checkbox" checked={props.textShadow || false} onChange={(e) => handleChange('textShadow', e.target.checked)}
                            className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                         />
                     </div>
                     {props.textShadow && (
                         <div className="space-y-2">
                             <ColorInput 
                                label="Shadow Color" 
                                value={props.textShadowColor || '#000000'} 
                                onChange={(val) => handleChange('textShadowColor', val)} 
                             />
                             <div>
                                <label className="block text-[10px] text-neutral-400 mb-1">Offset (px)</label>
                                <input 
                                    type="number" value={props.textShadowOffset || 1} onChange={(e) => handleChange('textShadowOffset', e.target.value)}
                                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                                />
                             </div>
                         </div>
                     )}
                 </div>
             )}

             {/* Font Controls */}
             {(type === ComponentType.DLabel || type === ComponentType.DButton || type === ComponentType.DTextEntry || type === ComponentType.DCheckBox) && (
                 <div className="mt-4 pt-3 border-t border-neutral-800">
                     <label className="block text-[10px] text-neutral-400 mb-2 font-semibold">Typography</label>
                     <div className="space-y-2">
                         <div>
                            <label className="block text-[10px] text-neutral-500 mb-1">Font Family</label>
                            <select
                                value={props.fontFamily || 'DermaDefault'}
                                onChange={(e) => handleChange('fontFamily', e.target.value)}
                                className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                            >
                                <optgroup label="Derma">
                                    <option value="DermaDefault">DermaDefault</option>
                                    <option value="DermaDefaultBold">DermaDefaultBold</option>
                                    <option value="DermaLarge">DermaLarge</option>
                                </optgroup>
                                <optgroup label="Source UI">
                                    <option value="Default">Default</option>
                                    <option value="DefaultSmall">DefaultSmall</option>
                                    <option value="DefaultVerySmall">DefaultVerySmall</option>
                                    <option value="DefaultFixed">DefaultFixed (mono)</option>
                                    <option value="ChatFont">ChatFont</option>
                                    <option value="MenuLarge">MenuLarge</option>
                                    <option value="CenterPrintText">CenterPrintText</option>
                                </optgroup>
                                <optgroup label="HUD">
                                    <option value="HudHintTextLarge">HudHintTextLarge</option>
                                    <option value="HudHintTextSmall">HudHintTextSmall</option>
                                    <option value="HudSelectionText">HudSelectionText</option>
                                    <option value="TargetID">TargetID</option>
                                    <option value="TargetIDSmall">TargetIDSmall</option>
                                    <option value="BudgetLabel">BudgetLabel</option>
                                    <option value="CloseCaption_Normal">CloseCaption_Normal</option>
                                </optgroup>
                                <optgroup label="Trebuchet">
                                    <option value="Trebuchet18">Trebuchet18</option>
                                    <option value="Trebuchet24">Trebuchet24</option>
                                </optgroup>
                                <optgroup label="Fallback">
                                    <option value="Arial">Arial (Standard)</option>
                                </optgroup>
                            </select>
                         </div>
                         <div className="grid grid-cols-2 gap-2">
                            <div>
                                <label className="block text-[10px] text-neutral-500 mb-1">Size (Override)</label>
                                <input 
                                    type="number" value={props.fontSize || 0} onChange={(e) => handleChange('fontSize', e.target.value)}
                                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white placeholder-neutral-600"
                                    placeholder="Default"
                                />
                            </div>
                            <div>
                                <label className="block text-[10px] text-neutral-500 mb-1">Weight</label>
                                <select 
                                    value={props.fontWeight || 400} 
                                    onChange={(e) => handleChange('fontWeight', e.target.value)}
                                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                                >
                                    <option value="300">Light (300)</option>
                                    <option value="400">Normal (400)</option>
                                    <option value="600">Semi-Bold (600)</option>
                                    <option value="700">Bold (700)</option>
                                </select>
                            </div>
                         </div>
                     </div>
                 </div>
             )}

             {/* Text Alignment */}
             {(type === ComponentType.DLabel || type === ComponentType.DButton || type === ComponentType.DTextEntry) && (
                 <div className="mt-3">
                    <label className="block text-[10px] text-neutral-400 mb-1">Text Alignment</label>
                    <div className="flex bg-neutral-800 rounded border border-neutral-700 p-0.5">
                        {['left', 'center', 'right'].map((align) => (
                            <button
                                key={align}
                                onClick={() => handleChange('textAlign', align)}
                                className={`flex-1 flex items-center justify-center py-1 rounded-sm transition-colors ${props.textAlign === align || (!props.textAlign && align === 'center') ? 'bg-neutral-600 text-white' : 'text-neutral-500 hover:text-neutral-300'}`}
                                title={`Align ${align}`}
                            >
                                {align === 'left' && <AlignLeft className="w-3.5 h-3.5" />}
                                {align === 'center' && <AlignCenter className="w-3.5 h-3.5" />}
                                {align === 'right' && <AlignRight className="w-3.5 h-3.5" />}
                            </button>
                        ))}
                    </div>
                 </div>
             )}
             
             {/* Tooltip */}
             <div className="mt-3">
                  <label className="block text-[10px] text-neutral-400 mb-1 flex items-center gap-1">
                      <Info className="w-3 h-3" /> Tooltip Text
                  </label>
                  <input 
                    type="text" value={props.tooltip || ''} onChange={(e) => handleChange('tooltip', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 focus:outline-none placeholder-neutral-700"
                    placeholder="Hover text..."
                  />
             </div>
        </Section>

        {liaDefinition && liaDefinition.options.length > 0 && (
          <Section title="Lilia Options" icon={Settings2}>
            {liaDefinition.options.map(option => {
              const value = props.liaOptions?.[option.key] ?? option.defaultValue;
              if (option.input === 'boolean') {
                return (
                  <label key={option.key} className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                    <span>{option.label}</span>
                    <input
                      type="checkbox"
                      checked={Boolean(value)}
                      onChange={(e) => handleLiaOptionChange(option.key, e.target.checked)}
                      className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                    />
                  </label>
                );
              }
              if (option.input === 'color') {
                return (
                  <div key={option.key}>
                    <ColorInput
                      label={option.label}
                      value={String(value)}
                      onChange={(nextValue) => handleLiaOptionChange(option.key, nextValue)}
                    />
                  </div>
                );
              }
              if (option.input === 'textarea') {
                return (
                  <div key={option.key}>
                    <label className="block text-[10px] text-neutral-400 mb-1">{option.label}</label>
                    <textarea
                      value={String(value)}
                      rows={5}
                      placeholder={option.placeholder}
                      onChange={(e) => handleLiaOptionChange(option.key, e.target.value)}
                      className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 focus:outline-none font-mono resize-y"
                    />
                  </div>
                );
              }
              if (option.input === 'select') {
                return (
                  <div key={option.key}>
                    <label className="block text-[10px] text-neutral-400 mb-1">{option.label}</label>
                    <select
                      value={String(value)}
                      onChange={(e) => {
                        const selected = option.choices?.find(choice => String(choice.value) === e.target.value);
                        handleLiaOptionChange(option.key, selected?.value ?? e.target.value);
                      }}
                      className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 focus:outline-none"
                    >
                      {(option.choices || []).map(choice => (
                        <option key={String(choice.value)} value={String(choice.value)}>{choice.label}</option>
                      ))}
                    </select>
                  </div>
                );
              }
              return (
                <div key={option.key}>
                  <label className="block text-[10px] text-neutral-400 mb-1">{option.label}</label>
                  <input
                    type={option.input === 'number' ? 'number' : 'text'}
                    value={String(value)}
                    min={option.min}
                    max={option.max}
                    step={option.step}
                    placeholder={option.placeholder}
                    onChange={(e) => handleLiaOptionChange(option.key, option.input === 'number' ? (parseFloat(e.target.value) || 0) : e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 focus:outline-none"
                  />
                </div>
              );
            })}
          </Section>
        )}

        {/* Image Section */}
        {(type === ComponentType.DImage || type === ComponentType.DTab) && (
             <Section title={type === ComponentType.DTab ? "Icon" : "Image Source"} icon={ImageIcon}>
                <div className="space-y-3">
                    <div>
                       <label className="block text-[10px] text-neutral-400 mb-1">
                           {type === ComponentType.DTab ? "Icon Path (icon16/...)" : "Image URL / Material Path"}
                       </label>
                       <input 
                         type="text" value={props.imageUrl || ''} onChange={(e) => handleChange('imageUrl', e.target.value)}
                         className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 font-mono"
                         placeholder={type === ComponentType.DTab ? "icon16/page.png" : "vgui/avatar.png"}
                       />
                    </div>
                    {type === ComponentType.DImage && (
                        <ColorInput 
                            label="Image Tint Color" 
                            value={props.imageColor || '#ffffff'} 
                            onChange={(val) => handleChange('imageColor', val)} 
                        />
                    )}
                </div>
             </Section>
        )}

        {/* Model Section */}
        {type === ComponentType.DModelPanel && (
            <Section title="Model Settings" icon={Box}>
                <div className="space-y-3">
                    <div>
                        <label className="block text-[10px] text-neutral-400 mb-1">Model Path</label>
                        <input 
                            type="text" value={props.modelPath || ''} onChange={(e) => handleChange('modelPath', e.target.value)}
                            className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 font-mono"
                            placeholder="models/player/kleiner.mdl"
                        />
                    </div>
                    <div>
                        <label className="block text-[10px] text-neutral-400 mb-1">FOV</label>
                        <input 
                            type="number" value={props.modelFov || 50} onChange={(e) => handleChange('modelFov', e.target.value)}
                            className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500"
                        />
                    </div>
                </div>
            </Section>
        )}

        {/* Style Section */}
        <Section title="Styling" icon={Palette}>
            <div className="space-y-4">
                <ColorInput 
                    label="Background Color" 
                    value={props.color || '#ffffff'} 
                    onChange={(val) => handleChange('color', val)} 
                />
                
                {/* ... existing styles ... */}

                <div className="space-y-2">
                    <label className="block text-[10px] text-neutral-400">Opacity (0-255)</label>
                    <div className="flex gap-2 items-center">
                        <input 
                           type="range" min="0" max="255" value={props.opacity !== undefined ? props.opacity : 255} 
                           onChange={(e) => handleChange('opacity', e.target.value)}
                           className="flex-1 h-1 bg-neutral-700 rounded-lg appearance-none cursor-pointer"
                        />
                        <input 
                           type="number" min="0" max="255" value={props.opacity !== undefined ? props.opacity : 255} 
                           onChange={(e) => handleChange('opacity', e.target.value)}
                           className="w-10 bg-neutral-800 border border-neutral-700 rounded px-1 py-0.5 text-xs text-right"
                        />
                    </div>
                </div>

                <div className="border-t border-neutral-800 pt-3 mt-3">
                     <label className="block text-[10px] text-neutral-400 mb-2 font-semibold">Border Style</label>
                     <div className="space-y-2">
                        <ColorInput 
                            label="Border Color" 
                            value={props.borderColor || '#000000'} 
                            onChange={(val) => handleChange('borderColor', val)} 
                        />
                        <div className="grid grid-cols-2 gap-2">
                             <div>
                                <label className="block text-[10px] text-neutral-400 mb-1">Width (px)</label>
                                <input 
                                    type="number" value={props.borderWidth || 0} onChange={(e) => handleChange('borderWidth', e.target.value)}
                                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white focus:border-blue-500"
                                    min="0"
                                />
                             </div>
                             <div>
                                <label className="block text-[10px] text-neutral-400 mb-1">Radius (px)</label>
                                <input 
                                    type="number" value={props.borderRadius || 0} onChange={(e) => handleChange('borderRadius', e.target.value)}
                                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white focus:border-blue-500"
                                    min="0"
                                />
                             </div>
                        </div>
                     </div>
                </div>
            </div>
        </Section>
        
        {/* Effects Section */}
         <Section title="Effects" icon={Sparkles}>
            <div className="space-y-4">
                 <div>
                    <div className="flex items-center justify-between mb-2">
                         <label className="block text-[10px] text-neutral-400">Hover Color</label>
                         <button 
                             onClick={autoGenerateHoverColor}
                             className="text-[10px] text-blue-400 hover:text-blue-300 flex items-center gap-1 hover:underline"
                             title="Auto-generate a lighter hover color"
                         >
                             <Wand2 className="w-3 h-3" /> Auto
                         </button>
                    </div>
                    <ColorInput 
                        label="" 
                        value={props.hoverColor || props.color || '#ffffff'} 
                        onChange={(val) => handleChange('hoverColor', val)} 
                    />
                 </div>
                 
                 <div>
                     <label className="block text-[10px] text-neutral-400 mb-2">Hover Scale Multiplier</label>
                     <div className="flex gap-2 items-center">
                         <input 
                            type="range" min="0.5" max="2.0" step="0.05" 
                            value={props.hoverScale || 1} 
                            onChange={(e) => handleChange('hoverScale', e.target.value)}
                            className="flex-1 h-1 bg-neutral-700 rounded-lg appearance-none cursor-pointer"
                         />
                         <span className="text-xs font-mono w-8 text-right">{props.hoverScale || 1}x</span>
                     </div>
                 </div>

                 <div className="space-y-2">
                    <label className="block text-[10px] text-neutral-400">Hover Opacity (0-255)</label>
                    <div className="flex gap-2 items-center">
                        <input 
                           type="range" min="0" max="255" value={props.hoverOpacity !== undefined ? props.hoverOpacity : 255} 
                           onChange={(e) => handleChange('hoverOpacity', e.target.value)}
                           className="flex-1 h-1 bg-neutral-700 rounded-lg appearance-none cursor-pointer"
                        />
                        <input 
                           type="number" min="0" max="255" value={props.hoverOpacity !== undefined ? props.hoverOpacity : 255} 
                           onChange={(e) => handleChange('hoverOpacity', e.target.value)}
                           className="w-10 bg-neutral-800 border border-neutral-700 rounded px-1 py-0.5 text-xs text-right"
                        />
                    </div>
                </div>
                
                <ColorInput 
                    label="Hover Border Color" 
                    value={props.hoverBorderColor || props.borderColor || '#000000'} 
                    onChange={(val) => handleChange('hoverBorderColor', val)} 
                />
            </div>
         </Section>

        {/* Component Specifics */}
        {type === ComponentType.DCheckBox && (
           <Section title="Specifics" icon={CheckCircle}>
              <div className="flex items-center justify-between p-2 rounded bg-neutral-800/50 border border-neutral-800">
                <label htmlFor="chk-prop" className="text-xs text-neutral-300">Default Checked</label>
                <input
                  type="checkbox" id="chk-prop" checked={props.checked || false} onChange={(e) => handleChange('checked', e.target.checked)}
                  className="rounded bg-neutral-700 border-neutral-600 text-blue-600 focus:ring-offset-neutral-900"
                />
             </div>
           </Section>
        )}

        {/* DProgress: fraction 0-1 */}
        {type === ComponentType.DProgress && (
          <Section title="Progress" icon={Settings2}>
            <div className="space-y-2">
              <label className="block text-[10px] text-neutral-400">Fraction (0–1)</label>
              <div className="flex gap-2 items-center">
                <input
                  type="range" min="0" max="1" step="0.01"
                  value={props.progressFraction ?? 0}
                  onChange={(e) => handleChange('progressFraction', e.target.value)}
                  className="flex-1 h-1 bg-neutral-700 rounded-lg appearance-none cursor-pointer"
                />
                <input
                  type="number" min="0" max="1" step="0.01"
                  value={props.progressFraction ?? 0}
                  onChange={(e) => handleChange('progressFraction', e.target.value)}
                  className="w-14 bg-neutral-800 border border-neutral-700 rounded px-1 py-0.5 text-xs text-right"
                />
              </div>
              <p className="text-[10px] text-neutral-600">Fill color uses the Background Color in Styling.</p>
            </div>
          </Section>
        )}

        {/* DSlider: knob position + locks + trap */}
        {type === ComponentType.DSlider && (
          <Section title="Slider" icon={Settings2}>
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Slide X (0–1)</label>
                  <input
                    type="number" min="0" max="1" step="0.01"
                    value={props.sliderX ?? 0.5}
                    onChange={(e) => handleChange('sliderX', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Slide Y (0–1)</label>
                  <input
                    type="number" min="0" max="1" step="0.01"
                    value={props.sliderY ?? 0.5}
                    onChange={(e) => handleChange('sliderY', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Lock X (blank = free)</label>
                  <input
                    type="number" min="0" max="1" step="0.01"
                    value={props.sliderLockX ?? ''}
                    onChange={(e) => onChange(id, { sliderLockX: e.target.value === '' ? undefined : parseFloat(e.target.value) })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Lock Y (blank = free)</label>
                  <input
                    type="number" min="0" max="1" step="0.01"
                    value={props.sliderLockY ?? ''}
                    onChange={(e) => onChange(id, { sliderLockY: e.target.value === '' ? undefined : parseFloat(e.target.value) })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Trap Inside (knob bounded by track)</span>
                <input
                  type="checkbox" checked={props.sliderTrapInside || false}
                  onChange={(e) => handleChange('sliderTrapInside', e.target.checked)}
                  className="rounded bg-neutral-700 border-neutral-600 text-blue-600"
                />
              </label>
            </div>
          </Section>
        )}

        {/* DNumSlider: min/max/value/decimals + ConVar */}
        {type === ComponentType.DNumSlider && (
          <Section title="Number Slider" icon={Settings2}>
            <div className="space-y-3">
              <div className="grid grid-cols-3 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Min</label>
                  <input
                    type="number" step="0.01"
                    value={props.sliderMin ?? 0}
                    onChange={(e) => handleChange('sliderMin', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Max</label>
                  <input
                    type="number" step="0.01"
                    value={props.sliderMax ?? 100}
                    onChange={(e) => handleChange('sliderMax', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Decimals</label>
                  <input
                    type="number" min="0" max="6" step="1"
                    value={props.sliderDecimals ?? 0}
                    onChange={(e) => handleChange('sliderDecimals', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Value</label>
                <div className="flex gap-2 items-center">
                  <input
                    type="range"
                    min={props.sliderMin ?? 0} max={props.sliderMax ?? 100}
                    step={props.sliderDecimals ? Math.pow(10, -(props.sliderDecimals)) : 1}
                    value={props.sliderValue ?? 0}
                    onChange={(e) => handleChange('sliderValue', e.target.value)}
                    className="flex-1 h-1 bg-neutral-700 rounded-lg appearance-none cursor-pointer"
                  />
                  <input
                    type="number" step="0.01"
                    value={props.sliderValue ?? 0}
                    onChange={(e) => handleChange('sliderValue', e.target.value)}
                    className="w-16 bg-neutral-800 border border-neutral-700 rounded px-1 py-0.5 text-xs text-right"
                  />
                </div>
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">ConVar (optional)</label>
                <input
                  type="text" value={props.sliderConVar || ''}
                  onChange={(e) => handleChange('sliderConVar', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="e.g. sv_gravity"
                />
              </div>
            </div>
          </Section>
        )}

        {/* DImageButton: image source + fit modes */}
        {type === ComponentType.DImageButton && (
          <Section title="Image Button" icon={ImageIcon}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Image URL / Material Path</label>
                <input
                  type="text" value={props.imageUrl || ''}
                  onChange={(e) => handleChange('imageUrl', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 font-mono"
                  placeholder="vgui/avatar.png"
                />
              </div>
              <ColorInput
                label="Image Tint Color"
                value={props.imageColor || '#ffffff'}
                onChange={(val) => handleChange('imageColor', val)}
              />
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Stretch To Fit</span>
                <input
                  type="checkbox" checked={props.imageStretchToFit !== false}
                  onChange={(e) => handleChange('imageStretchToFit', e.target.checked)}
                  className="rounded bg-neutral-700 border-neutral-600 text-blue-600"
                />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Keep Aspect Ratio</span>
                <input
                  type="checkbox" checked={props.imageKeepAspect || false}
                  onChange={(e) => handleChange('imageKeepAspect', e.target.checked)}
                  className="rounded bg-neutral-700 border-neutral-600 text-blue-600"
                />
              </label>
            </div>
          </Section>
        )}

        {/* DCollapsibleCategory: expanded + header height */}
        {type === ComponentType.DCollapsibleCategory && (
          <Section title="Collapsible Category" icon={Settings2}>
            <div className="space-y-3">
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Expanded (default state)</span>
                <input
                  type="checkbox" checked={props.expanded !== false}
                  onChange={(e) => handleChange('expanded', e.target.checked)}
                  className="rounded bg-neutral-700 border-neutral-600 text-blue-600"
                />
              </label>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Header Height (px)</label>
                <input
                  type="number" min="10" max="60"
                  value={props.headerHeight ?? 20}
                  onChange={(e) => onChange(id, { headerHeight: parseInt(e.target.value) || 20 })}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                />
              </div>
            </div>
          </Section>
        )}

        {/* DRichText: scrollbar toggle */}
        {type === ComponentType.DRichText && (
          <Section title="Rich Text" icon={Settings2}>
            <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
              <span>Vertical Scrollbar</span>
              <input
                type="checkbox" checked={props.richScrollbar !== false}
                onChange={(e) => handleChange('richScrollbar', e.target.checked)}
                className="rounded bg-neutral-700 border-neutral-600 text-blue-600"
              />
            </label>
          </Section>
        )}

        {/* DBinder: key name + key code + ConVar */}
        {type === ComponentType.DBinder && (
          <Section title="Key Binder" icon={Settings2}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Display Key Name</label>
                <input
                  type="text" value={props.binderKey || ''}
                  onChange={(e) => handleChange('binderKey', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white focus:border-blue-500 font-mono"
                  placeholder="NONE"
                />
                <p className="text-[10px] text-neutral-600 mt-1">Visual only — what shows on the button face.</p>
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Key Code (KEY_*)</label>
                <input
                  type="number" min="0" value={props.binderKeyCode ?? 0}
                  onChange={(e) => onChange(id, { binderKeyCode: parseInt(e.target.value) || 0 })}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white"
                />
                <p className="text-[10px] text-neutral-600 mt-1">Numeric code emitted via :SetSelectedNumber().</p>
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">ConVar (optional)</label>
                <input
                  type="text" value={props.binderConVar || ''}
                  onChange={(e) => handleChange('binderConVar', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="e.g. cl_pickupplaysound"
                />
              </div>
            </div>
          </Section>
        )}

        {/* DNumberWang: min/max/value/decimals/interval */}
        {type === ComponentType.DNumberWang && (
          <Section title="Number Wang" icon={Settings2}>
            <div className="space-y-3">
              <div className="grid grid-cols-3 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Min</label>
                  <input
                    type="number" step="0.01"
                    value={props.sliderMin ?? 0}
                    onChange={(e) => handleChange('sliderMin', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Max</label>
                  <input
                    type="number" step="0.01"
                    value={props.sliderMax ?? 100}
                    onChange={(e) => handleChange('sliderMax', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Decimals</label>
                  <input
                    type="number" min="0" max="6" step="1"
                    value={props.sliderDecimals ?? 0}
                    onChange={(e) => handleChange('sliderDecimals', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Value</label>
                  <input
                    type="number" step="0.01"
                    value={props.sliderValue ?? 0}
                    onChange={(e) => handleChange('sliderValue', e.target.value)}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Interval (step)</label>
                  <input
                    type="number" step="0.01"
                    value={props.numberInterval ?? 1}
                    onChange={(e) => onChange(id, { numberInterval: parseFloat(e.target.value) || 1 })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
              </div>
            </div>
          </Section>
        )}

        {/* DColorMixer: composite picker config */}
        {type === ComponentType.DColorMixer && (
          <Section title="Color Mixer" icon={Palette}>
            <div className="space-y-3">
              <ColorInput label="Initial Color" value={props.mixerColor || '#ff8000'} onChange={(v) => handleChange('mixerColor', v)} />
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Alpha (0–255)</label>
                <input
                  type="number" min="0" max="255"
                  value={props.mixerAlpha ?? 255}
                  onChange={(e) => onChange(id, { mixerAlpha: parseInt(e.target.value) || 0 })}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                />
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Optional Label</label>
                <input
                  type="text" value={props.mixerLabel || ''}
                  onChange={(e) => handleChange('mixerLabel', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                />
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Show Alpha Bar</span>
                <input type="checkbox" checked={props.mixerShowAlphaBar !== false} onChange={(e) => handleChange('mixerShowAlphaBar', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Show Palette</span>
                <input type="checkbox" checked={props.mixerShowPalette !== false} onChange={(e) => handleChange('mixerShowPalette', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Show RGBA Wangs</span>
                <input type="checkbox" checked={props.mixerShowWangs !== false} onChange={(e) => handleChange('mixerShowWangs', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <div className="grid grid-cols-2 gap-2 pt-2 border-t border-neutral-800">
                <input type="text" placeholder="ConVar R" value={props.mixerConVarR || ''} onChange={(e) => handleChange('mixerConVarR', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
                <input type="text" placeholder="ConVar G" value={props.mixerConVarG || ''} onChange={(e) => handleChange('mixerConVarG', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
                <input type="text" placeholder="ConVar B" value={props.mixerConVarB || ''} onChange={(e) => handleChange('mixerConVarB', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
                <input type="text" placeholder="ConVar A" value={props.mixerConVarA || ''} onChange={(e) => handleChange('mixerConVarA', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
              </div>
            </div>
          </Section>
        )}

        {/* DColorCube: base hue + position */}
        {type === ComponentType.DColorCube && (
          <Section title="Color Cube" icon={Palette}>
            <div className="space-y-3">
              <ColorInput label="Base Hue (RGB)" value={props.cubeBaseColor || '#ff0000'} onChange={(v) => handleChange('cubeBaseColor', v)} />
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Slide X (0–1)</label>
                  <input type="number" min="0" max="1" step="0.01" value={props.sliderX ?? 0.5} onChange={(e) => handleChange('sliderX', e.target.value)} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Slide Y (0–1)</label>
                  <input type="number" min="0" max="1" step="0.01" value={props.sliderY ?? 0.5} onChange={(e) => handleChange('sliderY', e.target.value)} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
              </div>
            </div>
          </Section>
        )}

        {/* DColorPalette: CSV swatches + grid config */}
        {type === ComponentType.DColorPalette && (
          <Section title="Color Palette" icon={Palette}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Swatches (comma-separated hex)</label>
                <textarea
                  rows={3}
                  value={props.paletteColors || ''}
                  onChange={(e) => handleChange('paletteColors', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="#ffffff,#ff0000,#00ff00,..."
                />
              </div>
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Button Size (px)</label>
                  <input
                    type="number" min="4"
                    value={props.paletteButtonSize ?? 16}
                    onChange={(e) => onChange(id, { paletteButtonSize: parseInt(e.target.value) || 16 })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Num Rows</label>
                  <input
                    type="number" min="1"
                    value={props.paletteNumRows ?? 2}
                    onChange={(e) => onChange(id, { paletteNumRows: parseInt(e.target.value) || 1 })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-2 pt-2 border-t border-neutral-800">
                <input type="text" placeholder="ConVar R" value={props.paletteConVarR || ''} onChange={(e) => handleChange('paletteConVarR', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
                <input type="text" placeholder="ConVar G" value={props.paletteConVarG || ''} onChange={(e) => handleChange('paletteConVarG', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
                <input type="text" placeholder="ConVar B" value={props.paletteConVarB || ''} onChange={(e) => handleChange('paletteConVarB', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
                <input type="text" placeholder="ConVar A" value={props.paletteConVarA || ''} onChange={(e) => handleChange('paletteConVarA', e.target.value)} className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-[10px] text-white font-mono" />
              </div>
            </div>
          </Section>
        )}

        {/* DSysButton: glyph type */}
        {type === ComponentType.DSysButton && (
          <Section title="System Button" icon={Settings2}>
            <div>
              <label className="block text-[10px] text-neutral-400 mb-1">Type (glyph)</label>
              <select
                value={props.sysButtonType || 'close'}
                onChange={(e) => handleChange('sysButtonType', e.target.value)}
                className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
              >
                <option value="close">close (✕)</option>
                <option value="minim">minim (–)</option>
                <option value="maxim">maxim (□)</option>
                <option value="newwin">newwin (↗)</option>
              </select>
            </div>
          </Section>
        )}

        {/* DHTML: URL or inline HTML, plus options */}
        {type === ComponentType.DHTML && (
          <Section title="HTML Viewer" icon={Settings2}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">URL</label>
                <input
                  type="text" value={props.htmlUrl || ''}
                  onChange={(e) => handleChange('htmlUrl', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="https://example.com  or  asset://garrysmod/..."
                />
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Inline HTML (used if URL is blank)</label>
                <textarea
                  rows={4}
                  value={props.htmlContent || ''}
                  onChange={(e) => handleChange('htmlContent', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="<html>...</html>"
                />
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Allow Lua callbacks (SetAllowLua)</span>
                <input type="checkbox" checked={props.htmlAllowLua || false} onChange={(e) => handleChange('htmlAllowLua', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Show Scrollbars</span>
                <input type="checkbox" checked={props.htmlScrollbars !== false} onChange={(e) => handleChange('htmlScrollbars', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
            </div>
          </Section>
        )}

        {/* DFrame audit extras */}
        {type === ComponentType.DFrame && (
          <Section title="Frame Extras" icon={LayoutTemplate}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Title Icon (path)</label>
                <input
                  type="text" value={props.frameIcon || ''}
                  onChange={(e) => handleChange('frameIcon', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="icon16/application.png"
                />
              </div>
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Min Width</label>
                  <input type="number" value={props.frameMinWidth ?? ''} onChange={(e) => onChange(id, { frameMinWidth: e.target.value === '' ? undefined : parseInt(e.target.value) })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Min Height</label>
                  <input type="number" value={props.frameMinHeight ?? ''} onChange={(e) => onChange(id, { frameMinHeight: e.target.value === '' ? undefined : parseInt(e.target.value) })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Lock to Screen</span>
                <input type="checkbox" checked={props.frameScreenLock || false} onChange={(e) => handleChange('frameScreenLock', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Background Blur</span>
                <input type="checkbox" checked={props.frameBackgroundBlur || false} onChange={(e) => handleChange('frameBackgroundBlur', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
            </div>
          </Section>
        )}

        {/* DButton audit extras */}
        {type === ComponentType.DButton && (
          <Section title="Button Extras" icon={MousePointer}>
            <div className="space-y-3">
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Enabled</span>
                <input type="checkbox" checked={props.buttonEnabled !== false} onChange={(e) => handleChange('buttonEnabled', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Icon (path)</label>
                <input
                  type="text" value={props.buttonIcon || ''}
                  onChange={(e) => handleChange('buttonIcon', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="icon16/accept.png"
                />
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Console Command (on click)</label>
                <input
                  type="text" value={props.buttonConsoleCommand || ''}
                  onChange={(e) => handleChange('buttonConsoleCommand', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="say hello   (cmd + space-separated args)"
                />
              </div>
            </div>
          </Section>
        )}

        {/* DLabel audit extras */}
        {type === ComponentType.DLabel && (
          <Section title="Label Extras" icon={Type}>
            <div className="space-y-3">
              <ColorInput label="Text Color (overrides default)" value={props.labelTextColor || '#ffffff'} onChange={(v) => handleChange('labelTextColor', v)} />
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Auto-Stretch Vertical</span>
                <input type="checkbox" checked={props.labelAutoStretchVertical || false} onChange={(e) => handleChange('labelAutoStretchVertical', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
            </div>
          </Section>
        )}

        {/* DTextEntry audit extras */}
        {type === ComponentType.DTextEntry && (
          <Section title="Text Entry Extras" icon={Settings2}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Placeholder Text</label>
                <input
                  type="text" value={props.entryPlaceholderText || ''}
                  onChange={(e) => handleChange('entryPlaceholderText', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white"
                  placeholder="Type something..."
                />
              </div>
              <ColorInput label="Text Color" value={props.entryTextColor || '#000000'} onChange={(v) => handleChange('entryTextColor', v)} />
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Max Characters (blank = unlimited)</label>
                <input
                  type="number" min="0"
                  value={props.entryMaxChars ?? ''}
                  onChange={(e) => onChange(id, { entryMaxChars: e.target.value === '' ? undefined : parseInt(e.target.value) })}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                />
              </div>
              <div className="grid grid-cols-2 gap-1">
                <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                  <span>Multiline</span>
                  <input type="checkbox" checked={props.entryMultiline || false} onChange={(e) => handleChange('entryMultiline', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
                </label>
                <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                  <span>Numeric Only</span>
                  <input type="checkbox" checked={props.entryNumeric || false} onChange={(e) => handleChange('entryNumeric', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
                </label>
                <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                  <span>Editable</span>
                  <input type="checkbox" checked={props.entryEditable !== false} onChange={(e) => handleChange('entryEditable', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
                </label>
                <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                  <span>Enter Allowed</span>
                  <input type="checkbox" checked={props.entryEnterAllowed !== false} onChange={(e) => handleChange('entryEnterAllowed', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
                </label>
                <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded col-span-2">
                  <span>Update On Every Keystroke</span>
                  <input type="checkbox" checked={props.entryUpdateOnType || false} onChange={(e) => handleChange('entryUpdateOnType', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
                </label>
              </div>
            </div>
          </Section>
        )}

        {/* DPanel audit extras */}
        {type === ComponentType.DPanel && (
          <Section title="Panel Extras" icon={Box}>
            <div className="space-y-2">
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Disabled (preview)</span>
                <input type="checkbox" checked={props.panelDisabled || false} onChange={(e) => handleChange('panelDisabled', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Paint Background</span>
                <input type="checkbox" checked={props.panelPaintBackground !== false} onChange={(e) => handleChange('panelPaintBackground', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
            </div>
          </Section>
        )}

        {/* DListView: columns + rows + display toggles */}
        {type === ComponentType.DListView && (
          <Section title="List View" icon={Settings2}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Columns (CSV)</label>
                <input
                  type="text" value={props.listColumns || ''}
                  onChange={(e) => handleChange('listColumns', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder="Name,Value,Date"
                />
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Rows (one per line, CSV cells)</label>
                <textarea
                  rows={5}
                  value={props.listRows || ''}
                  onChange={(e) => handleChange('listRows', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder={'Foo,42,today\nBar,7,yesterday'}
                />
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Multi-Select</span>
                <input type="checkbox" checked={props.listMultiSelect || false} onChange={(e) => handleChange('listMultiSelect', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Hide Headers</span>
                <input type="checkbox" checked={props.listHideHeaders || false} onChange={(e) => handleChange('listHideHeaders', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Sortable Columns</span>
                <input type="checkbox" checked={props.listSortable !== false} onChange={(e) => handleChange('listSortable', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
            </div>
          </Section>
        )}

        {/* DComboBox: choices + sortItems */}
        {type === ComponentType.DComboBox && (
          <Section title="Combo Box" icon={Settings2}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Choices (one per line)</label>
                <textarea
                  rows={5}
                  value={props.comboChoices || ''}
                  onChange={(e) => handleChange('comboChoices', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder={'Option A\nOption B\nOption C'}
                />
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Sort Items Alphabetically</span>
                <input type="checkbox" checked={props.comboSortItems !== false} onChange={(e) => handleChange('comboSortItems', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <p className="text-[10px] text-neutral-600">The "Label / Text" field above is the displayed value (emitted via :SetValue).</p>
            </div>
          </Section>
        )}

        {/* DColumnSheet: just a help note — children handle the rest */}
        {type === ComponentType.DColumnSheet && (
          <Section title="Column Sheet" icon={Settings2}>
            <p className="text-[10px] text-neutral-400">Add DTab children. Each DTab becomes a vertical column button on the left. Use the Tab Title field on each DTab to set the button label and the Icon field for the optional icon.</p>
          </Section>
        )}

        {/* DCheckBox audit hint */}
        {type === ComponentType.DCheckBox && props.text && (
          <Section title="Checkbox Note" icon={Info}>
            <p className="text-[10px] text-neutral-400">Because this checkbox has label text, the generator will emit it as <code className="text-blue-400">DCheckBoxLabel</code> (not plain DCheckBox) so the label actually shows in-game. Clear the text to emit a plain DCheckBox.</p>
          </Section>
        )}

        {/* DTree: indented text + indent/line-height/icons */}
        {type === ComponentType.DTree && (
          <Section title="Tree" icon={Settings2}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Nodes (indented text — 2 spaces per level)</label>
                <textarea
                  rows={8}
                  value={props.treeNodes || ''}
                  onChange={(e) => handleChange('treeNodes', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder={'Folder|icon16/folder.png\n  Subfolder\n    Doc.txt|icon16/page.png'}
                />
                <p className="text-[10px] text-neutral-600 mt-1">Format: <code>Label|icon16/path.png</code> per line. Indent = nesting.</p>
              </div>
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Indent Size (px)</label>
                  <input type="number" value={props.treeIndentSize ?? 16} onChange={(e) => onChange(id, { treeIndentSize: parseInt(e.target.value) || 16 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Line Height (px)</label>
                  <input type="number" value={props.treeLineHeight ?? 17} onChange={(e) => onChange(id, { treeLineHeight: parseInt(e.target.value) || 17 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Show Icons</span>
                <input type="checkbox" checked={props.treeShowIcons !== false} onChange={(e) => handleChange('treeShowIcons', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
            </div>
          </Section>
        )}

        {/* DMenu: items textarea + icon col toggle */}
        {type === ComponentType.DMenu && (
          <Section title="Menu" icon={Settings2}>
            <div className="space-y-3">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Items (one per line; --- = spacer)</label>
                <textarea
                  rows={6}
                  value={props.menuItems || ''}
                  onChange={(e) => handleChange('menuItems', e.target.value)}
                  className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                  placeholder={'Open|icon16/folder.png\nSave|icon16/disk.png\n---\nQuit'}
                />
              </div>
              <label className="flex items-center justify-between text-[10px] text-neutral-400 bg-neutral-800/50 p-1.5 rounded">
                <span>Show Icon Column</span>
                <input type="checkbox" checked={props.menuShowIconColumn !== false} onChange={(e) => handleChange('menuShowIconColumn', e.target.checked)} className="rounded bg-neutral-700 border-neutral-600 text-blue-600" />
              </label>
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Min Width</label>
                  <input type="number" value={props.menuMinWidth ?? ''} onChange={(e) => onChange(id, { menuMinWidth: e.target.value === '' ? undefined : parseInt(e.target.value) })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Max Height</label>
                  <input type="number" value={props.menuMaxHeight ?? ''} onChange={(e) => onChange(id, { menuMaxHeight: e.target.value === '' ? undefined : parseInt(e.target.value) })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
              </div>
            </div>
          </Section>
        )}

        {/* DMenuBar: nested menus textarea */}
        {type === ComponentType.DMenuBar && (
          <Section title="Menu Bar" icon={Settings2}>
            <div>
              <label className="block text-[10px] text-neutral-400 mb-1">Menus (one per line: <code>Label: opt1, opt2, ---, opt3</code>)</label>
              <textarea
                rows={6}
                value={props.menuBarItems || ''}
                onChange={(e) => handleChange('menuBarItems', e.target.value)}
                className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1.5 text-xs text-white font-mono"
                placeholder={'File: New, Open, ---, Quit\nEdit: Undo, Redo'}
              />
            </div>
          </Section>
        )}

        {/* DGrid: cols + cell size */}
        {type === ComponentType.DGrid && (
          <Section title="Grid Layout" icon={Settings2}>
            <div className="grid grid-cols-3 gap-2">
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Cols</label>
                <input type="number" min="1" value={props.gridCols ?? 4} onChange={(e) => onChange(id, { gridCols: parseInt(e.target.value) || 1 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Col Wide</label>
                <input type="number" min="1" value={props.gridColWide ?? 50} onChange={(e) => onChange(id, { gridColWide: parseInt(e.target.value) || 1 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Row Height</label>
                <input type="number" min="1" value={props.gridRowHeight ?? 50} onChange={(e) => onChange(id, { gridRowHeight: parseInt(e.target.value) || 1 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
              </div>
            </div>
            <p className="text-[10px] text-neutral-600 mt-2">Children placed by grid; their X/Y are ignored. Lua emits <code>SetCols</code>/<code>SetColWide</code>/<code>SetRowHeight</code> + per-child <code>:AddItem()</code>.</p>
          </Section>
        )}

        {/* DIconLayout: spacing + border + dir */}
        {type === ComponentType.DIconLayout && (
          <Section title="Icon Layout" icon={Settings2}>
            <div className="space-y-3">
              <div className="grid grid-cols-3 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Space X</label>
                  <input type="number" min="0" value={props.iconSpaceX ?? 5} onChange={(e) => onChange(id, { iconSpaceX: parseInt(e.target.value) || 0 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Space Y</label>
                  <input type="number" min="0" value={props.iconSpaceY ?? 5} onChange={(e) => onChange(id, { iconSpaceY: parseInt(e.target.value) || 0 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Border</label>
                  <input type="number" min="0" value={props.iconBorder ?? 0} onChange={(e) => onChange(id, { iconBorder: parseInt(e.target.value) || 0 })} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white" />
                </div>
              </div>
              <div>
                <label className="block text-[10px] text-neutral-400 mb-1">Layout Direction</label>
                <select value={props.iconLayoutDir || 'TOP'} onChange={(e) => handleChange('iconLayoutDir', e.target.value)} className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white">
                  <option value="TOP">TOP (wrap into columns)</option>
                  <option value="LEFT">LEFT (wrap into rows)</option>
                </select>
              </div>
            </div>
          </Section>
        )}

        {/* DVerticalDivider: top/divider sizing */}
        {type === ComponentType.DVerticalDivider && (
          <Section title="Vertical Divider" icon={Settings2}>
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-2">
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Top Height</label>
                  <input
                    type="number" min="0"
                    value={props.dividerTopHeight ?? 100}
                    onChange={(e) => onChange(id, { dividerTopHeight: parseInt(e.target.value) || 0 })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Divider Height</label>
                  <input
                    type="number" min="0"
                    value={props.dividerHeight ?? 4}
                    onChange={(e) => onChange(id, { dividerHeight: parseInt(e.target.value) || 0 })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Top Min (blank=none)</label>
                  <input
                    type="number"
                    value={props.dividerTopMin ?? ''}
                    onChange={(e) => onChange(id, { dividerTopMin: e.target.value === '' ? undefined : parseInt(e.target.value) })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Top Max (blank=none)</label>
                  <input
                    type="number"
                    value={props.dividerTopMax ?? ''}
                    onChange={(e) => onChange(id, { dividerTopMax: e.target.value === '' ? undefined : parseInt(e.target.value) })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
                <div>
                  <label className="block text-[10px] text-neutral-400 mb-1">Bottom Min (blank=none)</label>
                  <input
                    type="number"
                    value={props.dividerBottomMin ?? ''}
                    onChange={(e) => onChange(id, { dividerBottomMin: e.target.value === '' ? undefined : parseInt(e.target.value) })}
                    className="w-full bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-white"
                  />
                </div>
              </div>
              <p className="text-[10px] text-neutral-600">First child = SetTop, second child = SetBottom.</p>
            </div>
          </Section>
        )}

      </div>
    </div>
  );
};

export default PropertiesPanel;