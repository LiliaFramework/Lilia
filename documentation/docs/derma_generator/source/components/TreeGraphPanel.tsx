import React, { useState, useCallback, useMemo } from 'react';
import { UIElement, ComponentType } from '../types';
import { canAcceptChildren, getDescendantIds, getTopLevelIds } from '../utils/hierarchy';
import {
  ChevronDown, ChevronRight, ChevronsDownUp, ChevronsUpDown,
  Lock as LockIcon, Network, Trash2,
  // Element type icons (covers the most common ones; the rest fall back to Box)
  LayoutTemplate, Square, MousePointer2, Type, SquareAsterisk, CheckSquare,
  List, Table, Image as ImageIcon, Layers, Folder, FormInput, Cuboid, Box,
  BarChart2, SlidersHorizontal, Sliders, ImageDown, BoxSelect,
  FileText, Keyboard, Hash, Rows3, Palette, Pipette, Grid3x3,
  X as XIcon, Globe, Menu as MenuIcon, MenuSquare, LayoutGrid,
} from 'lucide-react';

interface TreeGraphPanelProps {
  elements: Record<string, UIElement>;
  selectedId: string | null;
  selectedIds: string[];
  onSelect: (id: string | null) => void;
  onToggleSelection: (id: string) => void;
  onDelete?: (id: string) => void;
  onReparent?: (id: string, newParentId: string | null) => void;
}

// Map every ComponentType to a lucide icon. Keeps the tree visually consistent
// with the Sidebar palette so users can recognize element types at a glance.
const ICON_FOR_TYPE: Partial<Record<ComponentType, React.ComponentType<{ className?: string }>>> = {
  [ComponentType.DFrame]: LayoutTemplate,
  [ComponentType.DPanel]: Square,
  [ComponentType.DScrollPanel]: Square,
  [ComponentType.DButton]: MousePointer2,
  [ComponentType.DLabel]: Type,
  [ComponentType.DTextEntry]: SquareAsterisk,
  [ComponentType.DCheckBox]: CheckSquare,
  [ComponentType.DComboBox]: ChevronDown,
  [ComponentType.DListView]: List,
  [ComponentType.DGrid]: Table,
  [ComponentType.DImage]: ImageIcon,
  [ComponentType.DPropertySheet]: Layers,
  [ComponentType.DColumnSheet]: Layers,
  [ComponentType.DTab]: Folder,
  [ComponentType.DForm]: FormInput,
  [ComponentType.DModelPanel]: Cuboid,
  [ComponentType.DBevel]: BoxSelect,
  [ComponentType.DProgress]: BarChart2,
  [ComponentType.DSlider]: SlidersHorizontal,
  [ComponentType.DNumSlider]: Sliders,
  [ComponentType.DImageButton]: ImageDown,
  [ComponentType.DCollapsibleCategory]: ChevronsUpDown,
  [ComponentType.DRichText]: FileText,
  [ComponentType.DBinder]: Keyboard,
  [ComponentType.DNumberWang]: Hash,
  [ComponentType.DVerticalDivider]: Rows3,
  [ComponentType.DColorMixer]: Palette,
  [ComponentType.DColorCube]: Pipette,
  [ComponentType.DColorPalette]: Grid3x3,
  [ComponentType.DSysButton]: XIcon,
  [ComponentType.DHTML]: Globe,
  [ComponentType.DTree]: Network,
  [ComponentType.DMenu]: MenuIcon,
  [ComponentType.DMenuBar]: MenuSquare,
  [ComponentType.DIconLayout]: LayoutGrid,
};

const TreeGraphPanel: React.FC<TreeGraphPanelProps> = ({
  elements, selectedId, selectedIds,
  onSelect, onToggleSelection, onDelete, onReparent,
}) => {
  // Set of element ids whose children are HIDDEN. Default behavior: nothing in
  // the set means everything is expanded. We track collapsed-ness (rather than
  // expanded-ness) so newly-added nodes default to expanded.
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());
  const [draggedId, setDraggedId] = useState<string | null>(null);
  const [dropTargetId, setDropTargetId] = useState<string | null>(null);
  const [isRootDropActive, setIsRootDropActive] = useState(false);

  const elementCount = useMemo(() => Object.keys(elements).length, [elements]);

  const toggleCollapsed = useCallback((id: string) => {
    setCollapsed(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  }, []);

  const expandAll = useCallback(() => setCollapsed(new Set()), []);

  const collapseAll = useCallback(() => {
    // Collapse every node that has children (so the tree shows just the roots).
    const next = new Set<string>();
    for (const el of Object.values(elements) as UIElement[]) {
      if (el.children.length > 0) next.add(el.id);
    }
    setCollapsed(next);
  }, [elements]);

  const handleNodeClick = useCallback((id: string, e: React.MouseEvent) => {
    // Match the Canvas's selection rules: Ctrl/Cmd toggles, plain click replaces.
    if (e.ctrlKey || e.metaKey) onToggleSelection(id);
    else onSelect(id);
  }, [onSelect, onToggleSelection]);


  const topLevelIds = useMemo(() => getTopLevelIds(elements), [elements]);

  const isInSubtree = useCallback((ancestorId: string, candidateId: string) => {
    return getDescendantIds(elements, ancestorId).has(candidateId);
  }, [elements]);

  const canDropOn = useCallback((targetId: string) => {
    if (!draggedId || draggedId === targetId) return false;
    const dragged = elements[draggedId];
    const target = elements[targetId];
    if (!dragged || !target) return false;
    if (!canAcceptChildren(target.type)) return false;
    if (isInSubtree(draggedId, targetId)) return false;
    return dragged.parentId !== targetId;
  }, [draggedId, elements, isInSubtree]);

  const handleDragStart = useCallback((id: string, e: React.DragEvent<HTMLDivElement>) => {
    const el = elements[id];
    if (!el) {
      e.preventDefault();
      return;
    }
    setDraggedId(id);
    setDropTargetId(null);
    setIsRootDropActive(false);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', id);
  }, [elements]);

  const handleDragEnd = useCallback(() => {
    setDraggedId(null);
    setDropTargetId(null);
    setIsRootDropActive(false);
  }, []);

  const handleNodeDragOver = useCallback((id: string, e: React.DragEvent<HTMLDivElement>) => {
    if (!canDropOn(id)) return;
    e.preventDefault();
    e.stopPropagation();
    e.dataTransfer.dropEffect = 'move';
    setDropTargetId(id);
    setIsRootDropActive(false);
  }, [canDropOn]);

  const handleNodeDrop = useCallback((id: string, e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.stopPropagation();
    if (draggedId && canDropOn(id)) onReparent?.(draggedId, id);
    handleDragEnd();
  }, [draggedId, canDropOn, onReparent, handleDragEnd]);

  const handleTreeDragOver = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    if (e.target !== e.currentTarget) return;
    if (!draggedId) return;
    const dragged = elements[draggedId];
    if (!dragged || !dragged.parentId) return;
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
    setDropTargetId(null);
    setIsRootDropActive(true);
  }, [draggedId, elements]);

  const handleTreeDrop = useCallback((e: React.DragEvent<HTMLDivElement>) => {
    if (e.target !== e.currentTarget) return;
    if (!draggedId) return;
    const dragged = elements[draggedId];
    if (!dragged || !dragged.parentId) return;
    e.preventDefault();
    onReparent?.(draggedId, null);
    handleDragEnd();
  }, [draggedId, elements, onReparent, handleDragEnd]);

  // Recursive node renderer. Returns a flat sequence of <div>s (depth controls
  // the left indent). We render children inline below the parent node so the
  // collapsed map controls visibility without unmounting the children.
  const renderNode = (id: string, depth: number): React.ReactNode => {
    const el = elements[id];
    if (!el) return null;

    const isExpanded = !collapsed.has(id);
    const hasChildren = el.children.length > 0;
    const isPrimary = selectedId === id;
    const isMulti = selectedIds.includes(id) && !isPrimary;
    const Icon = ICON_FOR_TYPE[el.type] || Box;

    let bgClass = 'border-transparent text-neutral-400 hover:bg-neutral-800 hover:text-neutral-200';
    if (isPrimary)      bgClass = 'bg-blue-600/30 border-blue-500 text-white';
    else if (isMulti)   bgClass = 'bg-blue-600/10 border-blue-400/60 text-white/90';

    return (
      <React.Fragment key={id}>
        <div
          draggable
          className={`group flex items-center gap-0.5 py-0.5 cursor-pointer border-l-2 select-none transition-colors ${bgClass} ${draggedId === id ? 'opacity-40' : ''} ${dropTargetId === id ? 'bg-emerald-500/20 border-emerald-400 text-white' : ''}`}
          style={{ paddingLeft: depth * 14 + 4 }}
          onClick={(e) => handleNodeClick(id, e)}
          onDragStart={(e) => handleDragStart(id, e)}
          onDragEnd={handleDragEnd}
          onDragOver={(e) => handleNodeDragOver(id, e)}
          onDragLeave={(e) => {
            e.stopPropagation();
            if (dropTargetId === id) setDropTargetId(null);
          }}
          onDrop={(e) => handleNodeDrop(id, e)}
          title={`${el.props.variableName} (${el.type})`}
        >
          {/* Expand/collapse caret — invisible if no children, but takes up the same space */}
          <button
            type="button"
            onClick={(e) => { e.stopPropagation(); toggleCollapsed(id); }}
            className={`p-0.5 rounded hover:bg-white/10 shrink-0 ${!hasChildren ? 'invisible' : ''}`}
            tabIndex={-1}
          >
            {isExpanded
              ? <ChevronDown className="w-3 h-3" />
              : <ChevronRight className="w-3 h-3" />}
          </button>

          <Icon className={`w-3.5 h-3.5 shrink-0 ${isPrimary ? 'text-blue-300' : 'opacity-70'}`} />

          <span className="text-[11px] truncate font-mono ml-1 flex-1">
            {el.props.variableName}
          </span>

          {el.props.locked && (
            <LockIcon className="w-3 h-3 text-red-400 shrink-0" />
          )}

          <span className="opacity-30 text-[9px] mr-1 shrink-0 font-mono">{el.type}</span>

          {/* Quick-delete (visible on row hover; root frame can be deleted too via this) */}
          {onDelete && (
            <button
              type="button"
              onClick={(e) => { e.stopPropagation(); onDelete(id); }}
              className="opacity-0 group-hover:opacity-60 hover:!opacity-100 hover:text-red-400 mr-1 shrink-0"
              title="Delete element"
              tabIndex={-1}
            >
              <Trash2 className="w-3 h-3" />
            </button>
          )}
        </div>

        {isExpanded && hasChildren && el.children.map(cid => renderNode(cid, depth + 1))}
      </React.Fragment>
    );
  };

  return (
    <div className="w-60 bg-neutral-900 border-r border-neutral-800 flex flex-col shrink-0 overflow-hidden">
      {/* Header */}
      <div className="p-3 border-b border-neutral-800 flex items-center justify-between gap-2">
        <div className="flex items-center gap-2 min-w-0">
          <Network className="w-4 h-4 text-neutral-500 shrink-0" />
          <h2 className="text-xs font-semibold text-neutral-400 uppercase tracking-wider truncate">Tree Graph</h2>
        </div>
        <div className="flex items-center gap-0.5 shrink-0">
          <button
            type="button"
            onClick={expandAll}
            className="p-1 text-neutral-500 hover:text-white hover:bg-neutral-800 rounded transition-colors"
            title="Expand all"
          >
            <ChevronsUpDown className="w-3.5 h-3.5" />
          </button>
          <button
            type="button"
            onClick={collapseAll}
            className="p-1 text-neutral-500 hover:text-white hover:bg-neutral-800 rounded transition-colors"
            title="Collapse all"
          >
            <ChevronsDownUp className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* Tree body */}
      <div
        className={`flex-1 overflow-y-auto custom-scrollbar py-1 relative transition-colors ${isRootDropActive ? 'bg-blue-500/10 ring-1 ring-inset ring-blue-500/60' : ''}`}
        onDragOver={handleTreeDragOver}
        onDragLeave={(e) => {
          if (e.currentTarget === e.target) isRootDropActive && setIsRootDropActive(false);
        }}
        onDrop={handleTreeDrop}
      >
        {topLevelIds.length > 0
          ? topLevelIds.map(id => renderNode(id, 0))
          : (
            <div className="p-4 text-center text-neutral-500 text-[11px] italic">
              No elements yet — add any component from the Components palette to get started.
            </div>
          )}
        {draggedId && elements[draggedId]?.parentId && (
          <div className={`mx-2 mt-2 rounded border border-dashed px-2 py-3 text-center text-[10px] pointer-events-none transition-colors ${isRootDropActive ? 'border-blue-400 bg-blue-500/15 text-blue-200' : 'border-neutral-700 text-neutral-500'}`}>
            Drop in empty tree space to move to the top level
          </div>
        )}
      </div>

      {/* Footer — element count + multi-selection status */}
      <div className="px-3 py-1.5 border-t border-neutral-800 bg-neutral-900/80 flex items-center justify-between text-[10px] text-neutral-500 shrink-0">
        <span>{elementCount} element{elementCount === 1 ? '' : 's'}</span>
        {selectedIds.length > 1 && (
          <span className="text-blue-400 font-medium">{selectedIds.length} selected</span>
        )}
      </div>
    </div>
  );
};

export default TreeGraphPanel;
