import React, { useState } from 'react';
import { getTopLevelIds } from '../utils/hierarchy';
import { UIElement, ComponentType } from '../types';
import { 
  X, ChevronRight, ChevronDown, LayoutTemplate, Square, MousePointer2, 
  Type, SquareAsterisk, CheckSquare, ChevronDown as ComboIcon, List, 
  Table, Image as ImageIcon, Layers, Folder, FormInput, Cuboid, Box,
  LayoutGrid, GitMerge, SquareChevronDown, Sliders
} from 'lucide-react';

interface LayoutPanelProps {
  elements: Record<string, UIElement>;
  selectedId: string | null;
  onSelect: (id: string | null) => void;
  isOpen: boolean;
  onClose: () => void;
}

// Icon mapping (matching Sidebar)
const getIconForType = (type: ComponentType) => {
  switch (type) {
    case ComponentType.DFrame: return LayoutTemplate;
    case ComponentType.DPanel: return Square;
    case ComponentType.DButton: return MousePointer2;
    case ComponentType.DLabel: return Type;
    case ComponentType.DTextEntry: return SquareAsterisk;
    case ComponentType.DCheckBox: return CheckSquare;
    case ComponentType.DComboBox: return ComboIcon;
    case ComponentType.DListView: return List;
    case ComponentType.DGrid: return Table;
    case ComponentType.DImage: return ImageIcon;
    case ComponentType.DPropertySheet: return Layers;
    case ComponentType.DTab: return Folder;
    case ComponentType.DForm: return FormInput;
    case ComponentType.DModelPanel: return Cuboid;
    case ComponentType.DIconLayout: return LayoutGrid;
    case ComponentType.DTree: return GitMerge;
    case ComponentType.DCollapsibleCategory: return SquareChevronDown;
    case ComponentType.DNumSlider: return Sliders;
    default: return Box;
  }
};

const TreeNode: React.FC<{
  id: string;
  elements: Record<string, UIElement>;
  selectedId: string | null;
  onSelect: (id: string | null) => void;
  depth: number;
}> = ({ id, elements, selectedId, onSelect, depth }) => {
  const el = elements[id];
  const [isExpanded, setIsExpanded] = useState(true);

  if (!el) return null;

  const hasChildren = el.children && el.children.length > 0;
  const Icon = getIconForType(el.type);
  const isSelected = selectedId === id;

  const handleToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsExpanded(!isExpanded);
  };

  return (
    <div className="select-none">
      <div 
        className={`flex items-center gap-1 py-1 px-2 cursor-pointer transition-colors border-l-2 ${
          isSelected 
            ? 'bg-blue-600/20 border-blue-500 text-white' 
            : 'hover:bg-neutral-800 border-transparent text-neutral-400 hover:text-neutral-200'
        }`}
        style={{ paddingLeft: `${depth * 12 + 4}px` }}
        onClick={() => onSelect(id)}
      >
        <button 
          onClick={handleToggle}
          className={`p-0.5 rounded hover:bg-white/10 ${!hasChildren ? 'opacity-0 pointer-events-none' : ''}`}
        >
          {isExpanded ? <ChevronDown className="w-3 h-3" /> : <ChevronRight className="w-3 h-3" />}
        </button>
        
        <Icon className={`w-3.5 h-3.5 ${isSelected ? 'text-blue-400' : 'opacity-70'}`} />
        
        <span className="text-xs truncate font-mono ml-1.5">
            {el.props.variableName}
            <span className="ml-2 opacity-30 text-[10px] font-sans">{el.type}</span>
        </span>
      </div>

      {isExpanded && hasChildren && (
        <div>
          {el.children.map(childId => (
            <TreeNode 
              key={childId}
              id={childId}
              elements={elements}
              selectedId={selectedId}
              onSelect={onSelect}
              depth={depth + 1}
            />
          ))}
        </div>
      )}
    </div>
  );
};

const LayoutPanel: React.FC<LayoutPanelProps> = ({ elements, selectedId, onSelect, isOpen, onClose }) => {
  if (!isOpen) return null;

  return (
    <div className="absolute left-4 top-20 w-64 bg-neutral-900 border border-neutral-700 rounded-lg shadow-2xl flex flex-col z-30 max-h-[500px] overflow-hidden backdrop-blur-sm bg-opacity-95">
      <div className="flex items-center justify-between p-3 border-b border-neutral-800 bg-neutral-800/50">
        <h3 className="text-xs font-bold uppercase tracking-wider text-neutral-400">Layout Tree</h3>
        <button onClick={onClose} className="text-neutral-500 hover:text-white transition-colors">
          <X className="w-4 h-4" />
        </button>
      </div>
      
      <div className="flex-1 overflow-y-auto custom-scrollbar p-1">
        {getTopLevelIds(elements).length > 0 ? (
          getTopLevelIds(elements).map(id => (
            <TreeNode 
              key={id}
              id={id}
              elements={elements}
              selectedId={selectedId}
              onSelect={onSelect}
              depth={0}
            />
          ))
        ) : (
          <div className="p-4 text-center text-neutral-500 text-xs italic">
            No components
          </div>
        )}
      </div>
    </div>
  );
};

export default LayoutPanel;