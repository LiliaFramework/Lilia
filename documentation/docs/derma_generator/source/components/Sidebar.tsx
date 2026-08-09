import React, { useState, useMemo, useEffect } from 'react';
import { ComponentType } from '../types';
import { getLiaDefinition } from '../utils/liaComponentDefinitions';
import { LayoutTemplate, Square, Type, MousePointer2, CheckSquare, SquareAsterisk, Box, Search, List, Table, Image as ImageIcon, Layers, ChevronDown, Folder, FormInput, Cuboid, LayoutGrid, GitMerge, Sliders, SquareChevronDown, SplitSquareVertical, SplitSquareHorizontal, Bell, Link, ExternalLink, Menu, Scroll, Columns, Book, Github } from 'lucide-react';

interface SidebarProps {
  onAddComponent: (type: ComponentType) => void;
}

const WIKI_BASE = "https://wiki.facepunch.com/gmod/";
const GITHUB_BASE = "https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/";

// Comprehensive Wiki Data
const COMPONENT_INFO: Partial<Record<ComponentType, { desc: string, icon: any, wiki?: string }>> = {
  [ComponentType.DFrame]: { desc: "The standard window frame. It can be moved, resized, and closed.", icon: LayoutTemplate, wiki: "DFrame" },
  [ComponentType.DPanel]: { desc: "A base panel that everything else inherits from. Good for grouping.", icon: Square, wiki: "DPanel" },
  [ComponentType.DButton]: { desc: "A standard button. Triggers an action when clicked.", icon: MousePointer2, wiki: "DButton" },
  [ComponentType.DLabel]: { desc: "A simple text label. Supports fonts and colors.", icon: Type, wiki: "DLabel" },
  [ComponentType.DTextEntry]: { desc: "Allows the user to input text.", icon: SquareAsterisk, wiki: "DTextEntry" },
  [ComponentType.DCheckBox]: { desc: "A checkbox with a label. Returns 1 or 0.", icon: CheckSquare, wiki: "DCheckBox" },
  [ComponentType.DComboBox]: { desc: "A dropdown menu allowing single selection from a list.", icon: ChevronDown, wiki: "DComboBox" },
  [ComponentType.DListView]: { desc: "A multi-column list view with sortable headers.", icon: List, wiki: "DListView" },
  [ComponentType.DGrid]: { desc: "Arranges its children in a grid pattern.", icon: Table, wiki: "DGrid" },
  [ComponentType.DImage]: { desc: "Displays a texture or material.", icon: ImageIcon, wiki: "DImage" },
  [ComponentType.DPropertySheet]: { desc: "A tab control allowing switching between multiple panels.", icon: Layers, wiki: "DPropertySheet" },
  [ComponentType.DTab]: { desc: "A tab for use within a DPropertySheet.", icon: Folder, wiki: "DTab" },
  [ComponentType.DForm]: { desc: "A vertical list of label-widget pairs, useful for settings menus.", icon: FormInput, wiki: "DForm" },
  [ComponentType.DModelPanel]: { desc: "Renders a 3D model within the UI.", icon: Cuboid, wiki: "DModelPanel" },
  [ComponentType.DIconLayout]: { desc: "Automatically arranges children in a wrapping layout.", icon: LayoutGrid, wiki: "DIconLayout" },
  [ComponentType.DTree]: { desc: "A file-browser style tree view.", icon: GitMerge, wiki: "DTree" },
  [ComponentType.DCollapsibleCategory]: { desc: "A header that can expand or collapse to show content.", icon: SquareChevronDown, wiki: "DCollapsibleCategory" },
  [ComponentType.DNumSlider]: { desc: "A slider combined with a number text entry.", icon: Sliders, wiki: "DNumSlider" },
  [ComponentType.DVerticalDivider]: { desc: "A vertical bar that can resize two panels.", icon: SplitSquareVertical, wiki: "DVerticalDivider" },
  [ComponentType.DHorizontalDivider]: { desc: "A horizontal bar that can resize two panels.", icon: SplitSquareHorizontal, wiki: "DHorizontalDivider" },
  [ComponentType.DMenuBar]: { desc: "A menu bar, typically found at the top of a window.", icon: Menu, wiki: "DMenuBar" },
  [ComponentType.DMenu]: { desc: "A popup menu list.", icon: List, wiki: "DMenu" },
  [ComponentType.DHTML]: { desc: "Embeds an Awesomium/Chromium web browser.", icon: Box, wiki: "DHTML" },
  [ComponentType.DBinder]: { desc: "Input field for binding keys.", icon: Box, wiki: "DBinder" },
  [ComponentType.DColorCube]: { desc: "A color selection cube (Sat/Val).", icon: Box, wiki: "DColorCube" },
  [ComponentType.DColorPalette]: { desc: "A grid of selectable colors.", icon: Box, wiki: "DColorPalette" },
  [ComponentType.DColorMixer]: { desc: "A full color mixing control.", icon: Box, wiki: "DColorMixer" },
  [ComponentType.DSlider]: { desc: "A simple dragger/slider.", icon: Sliders, wiki: "DSlider" },
  [ComponentType.DImageButton]: { desc: "A button represented by an image.", icon: ImageIcon, wiki: "DImageButton" },
  [ComponentType.DNotify]: { desc: "A notification panel that fades out.", icon: Bell, wiki: "DNotify" },
  [ComponentType.DProgress]: { desc: "A progress bar.", icon: Box, wiki: "DProgress" },
  [ComponentType.DRichText]: { desc: "A text panel supporting colors and formatting.", icon: Type, wiki: "DRichText" },
  [ComponentType.DSysButton]: { desc: "OS-style window buttons (Close, Min, Max).", icon: Box, wiki: "DSysButton" },
  [ComponentType.DTooltip]: { desc: "A tooltip panel.", icon: Box, wiki: "DTooltip" },
  [ComponentType.DNumberWang]: { desc: "A numeric input with up/down arrows.", icon: Box, wiki: "DNumberWang" },
  [ComponentType.DBevel]: { desc: "A generic bevel panel.", icon: Box, wiki: "DBevel" },
  [ComponentType.DScrollPanel]: { desc: "A panel that handles scrolling for its children.", icon: Scroll, wiki: "DScrollPanel" },
  [ComponentType.DColumnSheet]: { desc: "A panel with a list of categories on the left.", icon: Columns, wiki: "DColumnSheet" }
};

type ComponentCategory = 'GMOD' | 'Controls' | 'Internal Controls' | 'Menus' | 'Overlays' | 'Windows';

const CATEGORY_ORDER: ComponentCategory[] = [
  'Windows',
  'Controls',
  'Menus',
  'Overlays',
  'Internal Controls',
  'GMOD',
];

const LIA_COMPONENT_CATEGORIES: Partial<Record<ComponentType, ComponentCategory>> = {
  [ComponentType.liaFrame]: 'Windows',
  [ComponentType.liaSlider]: 'Controls',
  [ComponentType.liaSlideBox]: 'Controls',
  [ComponentType.liaButton]: 'Controls',
  [ComponentType.liaHugeButton]: 'Controls',
  [ComponentType.liaBigButton]: 'Controls',
  [ComponentType.liaMediumButton]: 'Controls',
  [ComponentType.liaSmallButton]: 'Controls',
  [ComponentType.liaMiniButton]: 'Controls',
  [ComponentType.liaNoBGButton]: 'Controls',
  [ComponentType.liaCustomFontButton]: 'Controls',
  [ComponentType.liaCheckbox]: 'Controls',
  [ComponentType.liaComboBox]: 'Controls',
  [ComponentType.liaEntry]: 'Controls',
  [ComponentType.liaProgressBar]: 'Controls',
  [ComponentType.liaHeaderPanel]: 'Controls',
  [ComponentType.liaScrollPanel]: 'Controls',
  [ComponentType.liaHorizontalScroll]: 'Controls',
  [ComponentType.liaHorizontalScrollBar]: 'Internal Controls',
  [ComponentType.liaSheet]: 'Controls',
  [ComponentType.liaTable]: 'Controls',
  [ComponentType.liaTabs]: 'Controls',
  [ComponentType.liaTabButton]: 'Controls',
  [ComponentType.liaModelPanel]: 'Controls',
  [ComponentType.liaSpawnIcon]: 'Controls',
  [ComponentType.CircularAvatar]: 'Controls',
  [ComponentType.liaNotice]: 'Overlays',
  [ComponentType.liaNoticePanel]: 'Controls',
  [ComponentType.liaVoicePanel]: 'Overlays',
  [ComponentType.liaLockCircle]: 'Overlays',
  [ComponentType.liaDermaMenu]: 'Menus',
};

const getComponentCategory = (type: ComponentType): ComponentCategory => {
  return LIA_COMPONENT_CATEGORIES[type] || (getLiaDefinition(type) ? 'Controls' : 'GMOD');
};

const Sidebar: React.FC<SidebarProps> = ({ onAddComponent }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [hoveredType, setHoveredType] = useState<ComponentType | null>(null);
  const [contextMenu, setContextMenu] = useState<{ x: number, y: number, type: ComponentType } | null>(null);
  const [collapsedCategories, setCollapsedCategories] = useState<Set<ComponentCategory>>(new Set());

  useEffect(() => {
    const handleClick = () => setContextMenu(null);
    document.addEventListener('click', handleClick);
    return () => document.removeEventListener('click', handleClick);
  }, []);

  const groupedComponents = useMemo(() => {
    const term = searchTerm.trim().toLowerCase();
    return CATEGORY_ORDER.map(category => {
      const types = Object.values(ComponentType)
        .filter(type => getComponentCategory(type) === category)
        .filter(type => {
          if (!term) return true;
          const info = COMPONENT_INFO[type];
          const liaDefinition = getLiaDefinition(type);
          const description = info?.desc || liaDefinition?.description || '';
          return `${type} ${category} ${description}`.toLowerCase().includes(term);
        })
        .sort((a, b) => a.localeCompare(b));
      return { category, types };
    }).filter(group => group.types.length > 0);
  }, [searchTerm]);

  const filteredCount = useMemo(() => {
    return groupedComponents.reduce((count, group) => count + group.types.length, 0);
  }, [groupedComponents]);

  const activeInfo = hoveredType ? COMPONENT_INFO[hoveredType] || (() => {
    const definition = getLiaDefinition(hoveredType);
    return definition ? { desc: definition.description, icon: Box } : null;
  })() : null;

  const toggleCategory = (category: ComponentCategory) => {
    if (searchTerm.trim()) return;
    setCollapsedCategories(current => {
      const next = new Set(current);
      if (next.has(category)) {
        next.delete(category);
      } else {
        next.add(category);
      }
      return next;
    });
  };

  const handleContextMenu = (e: React.MouseEvent, type: ComponentType) => {
      e.preventDefault();
      setContextMenu({
          x: e.clientX,
          y: e.clientY,
          type
      });
  };

  const openWiki = (type: ComponentType) => {
      const info = COMPONENT_INFO[type];
      if (info?.wiki) window.open(`${WIKI_BASE}${info.wiki}`, '_blank');
  };

  const openGithub = (type: ComponentType) => {
      // Heuristic: most Lua VGUI files are lowercase named matching the component name
      const filename = `${type.toLowerCase()}.lua`;
      window.open(`${GITHUB_BASE}${filename}`, '_blank');
  };

  return (
    <div className="w-64 bg-neutral-900 border-r border-neutral-800 flex flex-col shrink-0 overflow-hidden z-10">
      <div className="p-4 border-b border-neutral-800 bg-neutral-900">
        <h2 className="text-xs font-semibold text-neutral-500 uppercase tracking-wider mb-3">Components</h2>
        <div className="relative">
          <Search className="w-4 h-4 absolute left-3 top-2.5 text-neutral-500" />
          <input 
            type="text" 
            placeholder="Search VGUI..." 
            className="w-full bg-neutral-800 border border-neutral-700 rounded-lg pl-9 pr-3 py-2 text-sm text-neutral-200 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 placeholder-neutral-600"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>
      
      <div className="flex-1 overflow-y-auto p-2 custom-scrollbar">
        {groupedComponents.map(({ category, types }) => {
          const collapsed = !searchTerm.trim() && collapsedCategories.has(category);
          return (
            <div key={category} className="mb-2">
              <button
                type="button"
                onClick={() => toggleCategory(category)}
                className="w-full flex items-center gap-2 px-2 py-2 rounded-md text-left text-[11px] font-semibold uppercase tracking-wider text-neutral-500 hover:text-neutral-300 hover:bg-neutral-800/70 transition-colors"
              >
                <ChevronDown className={`w-3.5 h-3.5 transition-transform ${collapsed ? '-rotate-90' : ''}`} />
                <span className="flex-1 truncate">{category}</span>
                <span className="text-[10px] font-mono text-neutral-600">{types.length}</span>
              </button>

              {!collapsed && (
                <div className="mt-1 space-y-1 border-l border-neutral-800 ml-2 pl-2">
                  {types.map((type) => {
                    const info = COMPONENT_INFO[type];
                    const liaDefinition = getLiaDefinition(type);
                    const Icon = info?.icon || (liaDefinition ? Box : Box);

                    return (
                      <button
                        key={type}
                        onClick={() => onAddComponent(type)}
                        onMouseEnter={() => setHoveredType(type)}
                        onMouseLeave={() => setHoveredType(null)}
                        onContextMenu={(e) => handleContextMenu(e, type)}
                        className="w-full flex items-center p-2 rounded-md hover:bg-neutral-800 border border-transparent hover:border-neutral-700 transition-all group text-left relative"
                      >
                        <div className="p-1.5 bg-neutral-800 rounded mr-3 group-hover:bg-neutral-700 text-neutral-400 group-hover:text-blue-400 transition-colors">
                          <Icon className="w-4 h-4" />
                        </div>
                        <div className="flex flex-col overflow-hidden">
                          <span className="text-sm font-medium text-neutral-300 group-hover:text-white truncate">
                            {type}
                          </span>
                        </div>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
        
        {filteredCount === 0 && (
          <div className="p-4 text-center text-neutral-500 text-sm">
            No components found.
          </div>
        )}
      </div>
      
      <div className="p-4 border-t border-neutral-800 bg-neutral-900 min-h-[140px] flex flex-col">
        {activeInfo ? (
            <div className="animate-in fade-in duration-200">
                 <div className="flex items-center gap-2 mb-2">
                     <span className="font-bold text-base text-white">{hoveredType}</span>
                     {activeInfo.wiki && (
                       <a
                          href={`${WIKI_BASE}${activeInfo.wiki}`}
                          target="_blank"
                          rel="noreferrer"
                          className="text-blue-400 hover:text-blue-300"
                          title="Open GMod Wiki"
                       >
                          <ExternalLink className="w-3.5 h-3.5" />
                       </a>
                     )}
                 </div>
                 <p className="text-sm text-neutral-300 leading-relaxed">
                     {activeInfo.desc}
                 </p>
                 <div className="mt-3 text-[10px] text-neutral-500 flex items-center gap-1.5">
                    <Link className="w-3 h-3" />
                    <span>Right-click for options</span>
                 </div>
            </div>
        ) : (
            <div className="text-sm text-neutral-500 text-center flex flex-col items-center justify-center h-full opacity-60">
                <MousePointer2 className="w-8 h-8 mb-2 opacity-20" />
                <span>Hover over a component<br/>to see details</span>
            </div>
        )}
      </div>

      {contextMenu && (
        <div 
            className="fixed z-50 bg-neutral-800 border border-neutral-700 shadow-xl rounded-md py-1 w-48 animate-in fade-in zoom-in-95 duration-100"
            style={{ top: contextMenu.y, left: contextMenu.x }}
            onClick={(e) => e.stopPropagation()} 
        >
            <div className="px-3 py-1.5 text-xs font-semibold text-neutral-400 border-b border-neutral-700 mb-1">
                {contextMenu.type}
            </div>
            <button 
                onClick={() => { openWiki(contextMenu.type); setContextMenu(null); }}
                className="w-full text-left px-3 py-2 text-sm text-neutral-200 hover:bg-blue-600 hover:text-white flex items-center gap-2 transition-colors"
            >
                <Book className="w-4 h-4" />
                GMod Wiki
            </button>
            <button 
                onClick={() => { openGithub(contextMenu.type); setContextMenu(null); }}
                className="w-full text-left px-3 py-2 text-sm text-neutral-200 hover:bg-blue-600 hover:text-white flex items-center gap-2 transition-colors"
            >
                <Github className="w-4 h-4" />
                Github Source
            </button>
        </div>
      )}
    </div>
  );
};

export default Sidebar;