import React, { useState, useRef, useEffect } from 'react';
import { 
  File, FolderOpen, Save, FileOutput, FileInput, Plus, 
  Undo, Redo, Copy, Trash, Check
} from 'lucide-react';

interface MenuBarProps {
  onNew: () => void;
  onOpen: () => void;
  onSave: () => void;
  onSaveAs: () => void;
  onImport: () => void;
  onExport: () => void;
  onUndo: () => void;
  onRedo: () => void;
  onDelete: () => void;
  onDuplicate: () => void;
  onClearEverything: () => void;
  onToggleLayout?: () => void;
  isLayoutOpen?: boolean;
  canUndo: boolean;
  canRedo: boolean;
  hasSelection: boolean;
}

const MenuBar: React.FC<MenuBarProps> = ({
  onNew, onOpen, onSave, onSaveAs, onImport, onExport,
  onUndo, onRedo, onDelete, onDuplicate, onClearEverything, onToggleLayout, isLayoutOpen,
  canUndo, canRedo, hasSelection
}) => {
  const [activeMenu, setActiveMenu] = useState<string | null>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setActiveMenu(null);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  interface MenuItemProps {
    label: string;
    icon?: React.ElementType;
    shortcut?: string;
    onClick: () => void;
    disabled?: boolean;
    danger?: boolean;
    checked?: boolean;
  }

  const MenuItem = ({ label, icon: Icon, shortcut, onClick, disabled = false, danger = false, checked }: MenuItemProps) => (
    <button
      onClick={() => {
        if (!disabled) {
            onClick();
            setActiveMenu(null);
        }
      }}
      disabled={disabled}
      className={`w-full text-left px-4 py-1.5 text-xs flex items-center justify-between group ${disabled ? 'opacity-40 cursor-not-allowed' : 'hover:bg-blue-600 hover:text-white cursor-pointer'} ${danger && !disabled ? 'text-red-400 hover:bg-red-600' : 'text-neutral-300'}`}
    >
      <div className="flex items-center gap-2">
        {checked !== undefined && (
             <div className="w-3.5 flex items-center justify-center">
                 {checked && <Check className="w-3 h-3" />}
             </div>
        )}
        {Icon && <Icon className="w-3.5 h-3.5" />}
        <span>{label}</span>
      </div>
      {shortcut && <span className="ml-8 text-[10px] text-neutral-500 group-hover:text-neutral-200">{shortcut}</span>}
    </button>
  );

  const Divider = () => <div className="h-px bg-neutral-700 my-1 mx-2" />;

  const MenuDropdown = ({ title, id, children }: { title: string, id: string, children?: React.ReactNode }) => (
    <div className="relative">
      <button
        onClick={() => setActiveMenu(activeMenu === id ? null : id)}
        onMouseEnter={() => activeMenu && setActiveMenu(id)}
        className={`px-3 py-1.5 text-xs rounded-sm transition-colors ${activeMenu === id ? 'bg-blue-600 text-white' : 'text-neutral-300 hover:bg-neutral-800'}`}
      >
        {title}
      </button>
      {activeMenu === id && (
        <div className="absolute top-full left-0 mt-1 w-56 bg-neutral-800 border border-neutral-700 rounded shadow-xl py-1 z-50">
          {children}
        </div>
      )}
    </div>
  );

  return (
    <div className="h-8 bg-neutral-900 border-b border-neutral-800 flex items-center px-2 select-none" ref={menuRef}>
      <MenuDropdown title="File" id="file">
        <MenuItem label="New Project" icon={Plus} onClick={onNew} />
        <Divider />
        <MenuItem label="Open Project..." icon={FolderOpen} onClick={onOpen} shortcut="Ctrl+O" />
        <MenuItem label="Save Project" icon={Save} onClick={onSave} shortcut="Ctrl+S" />
        <MenuItem label="Save As..." icon={Save} onClick={onSaveAs} />
        <Divider />
        <MenuItem label="Import GLua..." icon={FileInput} onClick={onImport} />
        <MenuItem label="Export GLua..." icon={FileOutput} onClick={onExport} />
      </MenuDropdown>

      <MenuDropdown title="Edit" id="edit">
        <MenuItem label="Undo" icon={Undo} onClick={onUndo} disabled={!canUndo} shortcut="Ctrl+Z" />
        <MenuItem label="Redo" icon={Redo} onClick={onRedo} disabled={!canRedo} shortcut="Ctrl+Y" />
        <Divider />
        <MenuItem label="Duplicate" icon={Copy} onClick={onDuplicate} disabled={!hasSelection} shortcut="Ctrl+D" />
        <MenuItem label="Delete" icon={Trash} onClick={onDelete} disabled={!hasSelection} shortcut="Del" danger />
        <Divider />
        <MenuItem label="Clear Everything" icon={Trash} onClick={onClearEverything} danger />
      </MenuDropdown>

      <MenuDropdown title="View" id="view">
        <MenuItem label="Layout Tree" onClick={onToggleLayout ?? (() => {})} checked={isLayoutOpen ?? true} disabled={!onToggleLayout} />
        <Divider />
        <MenuItem label="Reset View" onClick={() => {}} shortcut="1:1" />
        <MenuItem label="Toggle Grid" onClick={() => {}} />
      </MenuDropdown>

    </div>
  );
};

export default MenuBar;