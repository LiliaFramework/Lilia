import React, { useState, useEffect, useCallback, useRef } from 'react';
import { ComponentType, EditorState, UIElement, ViewState } from './types';
import Sidebar from './components/Sidebar';
import PropertiesPanel from './components/PropertiesPanel';
import Canvas from './components/Canvas';
import MenuBar from './components/MenuBar';
import MethodsMenu from './components/MethodsMenu';
import TreeGraphPanel from './components/TreeGraphPanel';
import { generateLuaCode } from './utils/luaGenerator';
import { parseLuaToState } from './utils/luaParser';
import { getLiaDefaultProps, getLiaDefinition } from './utils/liaComponentDefinitions';
import { canAcceptChildren, findNearestContainerId, getAbsolutePosition, getDescendantIds, getPrimaryRootId } from './utils/hierarchy';
import { DEFAULT_LIA_THEME_ID, LIA_THEMES } from './utils/liaThemes';
import { Copy, Terminal, Undo2, Redo2, Grid, ChevronDown, ChevronUp, ScrollText } from 'lucide-react';

const initialState: EditorState = {
  elements: {},
  rootId: null,
  selectedId: null,
  selectedIds: [],
  canvasWidth: 800,
  canvasHeight: 600
};

// Backward-compat: legacy saved state had only selectedId. Materialize selectedIds
// from it so the rest of the app can assume the field exists.
const normalizeState = (s: EditorState): EditorState => {
  const removedIds = new Set(Object.values(s.elements || {}).filter(element => String(element.type) === 'liaItemIcon').map(element => element.id));
  const elements = Object.fromEntries(
    Object.entries(s.elements || {})
      .filter(([id]) => !removedIds.has(id))
      .map(([id, element]) => [id, { ...element, children: element.children.filter(childId => !removedIds.has(childId)) }])
  );
  const selectedIds = (Array.isArray(s.selectedIds) ? s.selectedIds : (s.selectedId ? [s.selectedId] : [])).filter(id => !removedIds.has(id));
  const selectedId = s.selectedId && !removedIds.has(s.selectedId) ? s.selectedId : selectedIds[0] || null;
  const preferredRootId = s.rootId && !removedIds.has(s.rootId) ? s.rootId : null;
  return {
    ...s,
    elements,
    rootId: getPrimaryRootId(elements, preferredRootId),
    selectedId,
    selectedIds,
  };
};

const initialViewState: ViewState = {
    zoom: 1,
    panX: 0,
    panY: 0,
    gridSize: 10,
    showGrid: true
};

const App: React.FC = () => {
  const [history, setHistory] = useState<EditorState[]>([initialState]);
  const [historyIndex, setHistoryIndex] = useState(0);
  const currentState = history[historyIndex];

  const [viewState, setViewState] = useState<ViewState>(initialViewState);
  const [generatedCode, setGeneratedCode] = useState<string>('');
  const [isOutputCollapsed, setIsOutputCollapsed] = useState(false);
  const [isMethodsMenuOpen, setIsMethodsMenuOpen] = useState(false);
  const [currentFileName, setCurrentFileName] = useState<string>("project.json");
  const [liaThemeId, setLiaThemeId] = useState<string>(() => localStorage.getItem('dermaGenLiaThemePreview') || DEFAULT_LIA_THEME_ID);

  // Hidden inputs for file operations
  const openFileRef = useRef<HTMLInputElement>(null);
  const importLuaRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const savedState = localStorage.getItem('dermaGenState');
    if (savedState) {
        try {
            const parsed = JSON.parse(savedState);
            setHistory([normalizeState(parsed)]);
            setHistoryIndex(0);
        } catch (e) {
            console.error("Failed to load state", e);
        }
    }
  }, []);

  useEffect(() => {
    localStorage.setItem('dermaGenState', JSON.stringify(currentState));
    setGeneratedCode(generateLuaCode(currentState));
  }, [currentState]);

  useEffect(() => {
    localStorage.setItem('dermaGenLiaThemePreview', liaThemeId);
  }, [liaThemeId]);

  const pushState = useCallback((newState: EditorState) => {
    setHistory(prev => {
        const newHistory = prev.slice(0, historyIndex + 1);
        newHistory.push(newState);
        return newHistory;
    });
    setHistoryIndex(prev => prev + 1);
  }, [historyIndex]);

  const undo = () => {
    if (historyIndex > 0) setHistoryIndex(historyIndex - 1);
  };

  const redo = () => {
    if (historyIndex < history.length - 1) setHistoryIndex(historyIndex + 1);
  };

  // --- FILE OPERATIONS ---

  const handleNew = () => {
    if (confirm("Create new project? Unsaved changes will be lost.")) {
      pushState(initialState);
      setCurrentFileName("project.json");
    }
  };

  const handleOpenClick = () => {
    if (openFileRef.current) openFileRef.current.click();
  };

  const handleFileOpen = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const json = JSON.parse(event.target?.result as string);
        // Basic validation
        if (json.elements && typeof json.elements === 'object') {
           pushState(normalizeState(json));
           setCurrentFileName(file.name);
        } else {
           alert("Invalid project file format.");
        }
      } catch (err) {
        alert("Failed to parse project file.");
      }
    };
    reader.readAsText(file);
    e.target.value = ''; // Reset
  };

  const downloadFile = (content: string, filename: string, type: string) => {
    const blob = new Blob([content], { type });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const handleSave = () => {
    downloadFile(JSON.stringify(currentState, null, 2), currentFileName, 'application/json');
  };

  const handleSaveAs = () => {
    const name = prompt("Enter filename:", currentFileName);
    if (name) {
      const finalName = name.endsWith('.json') ? name : `${name}.json`;
      setCurrentFileName(finalName);
      downloadFile(JSON.stringify(currentState, null, 2), finalName, 'application/json');
    }
  };

  const handleExport = () => {
    const name = currentFileName.replace('.json', '.lua');
    downloadFile(generatedCode, name, 'text/plain');
  };

  const handleImportClick = () => {
     if (importLuaRef.current) importLuaRef.current.click();
  };

  const handleLuaImport = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const code = event.target?.result as string;
      const newState = parseLuaToState(code);
      if (newState) {
          if (confirm("Import successful. This will overwrite current canvas. Proceed?")) {
              pushState(normalizeState(newState));
          }
      } else {
          alert("Could not parse Lua code. Ensure it follows standard vgui.Create patterns.");
      }
    };
    reader.readAsText(file);
    e.target.value = '';
  };

  // --- STATE MODIFIERS ---

  const addComponent = (type: ComponentType) => {
    const id = Math.random().toString(36).substr(2, 9);
    const parentId = findNearestContainerId(currentState.elements, currentState.selectedId)
      || findNearestContainerId(currentState.elements, currentState.rootId);
    
    // Default sizes for different types
    let w = 100, h = 30;
    if (type === ComponentType.DFrame) { w = 600; h = 400; }
    else if (type === ComponentType.DPanel) { w = 200; h = 200; }
    else if (type === ComponentType.DCheckBox) { w = 100; h = 20; }
    else if (type === ComponentType.DListView) { w = 200; h = 150; }
    else if (type === ComponentType.DBevel) { w = 200; h = 100; }
    else if (type === ComponentType.DProgress) { w = 200; h = 16; }
    else if (type === ComponentType.DSlider) { w = 150; h = 16; }
    else if (type === ComponentType.DNumSlider) { w = 220; h = 24; }
    else if (type === ComponentType.DImageButton) { w = 64; h = 64; }
    else if (type === ComponentType.DCollapsibleCategory) { w = 200; h = 100; }
    else if (type === ComponentType.DRichText) { w = 240; h = 120; }
    else if (type === ComponentType.DBinder) { w = 80; h = 22; }
    else if (type === ComponentType.DNumberWang) { w = 60; h = 22; }
    else if (type === ComponentType.DVerticalDivider) { w = 200; h = 200; }
    else if (type === ComponentType.DColorMixer) { w = 220; h = 260; }
    else if (type === ComponentType.DColorCube) { w = 100; h = 100; }
    else if (type === ComponentType.DColorPalette) { w = 120; h = 40; }
    else if (type === ComponentType.DSysButton) { w = 16; h = 16; }
    else if (type === ComponentType.DHTML) { w = 320; h = 240; }
    else if (type === ComponentType.DTree) { w = 200; h = 180; }
    else if (type === ComponentType.DMenu) { w = 140; h = 120; }
    else if (type === ComponentType.DMenuBar) { w = 200; h = 22; }
    else if (type === ComponentType.DGrid) { w = 220; h = 120; }
    else if (type === ComponentType.DIconLayout) { w = 200; h = 120; }
    else if (type === ComponentType.DColumnSheet) { w = 400; h = 300; }

    const liaDefinition = getLiaDefinition(type);
    if (liaDefinition) {
      w = liaDefinition.size.w;
      h = liaDefinition.size.h;
    }

    // Element-specific default props beyond size.
    const extraProps: Partial<UIElement['props']> = { ...getLiaDefaultProps(type) };
    if (type === ComponentType.DProgress) extraProps.progressFraction = 0.5;
    if (type === ComponentType.DSlider) { extraProps.sliderX = 0.5; extraProps.sliderY = 0.5; }
    if (type === ComponentType.DNumSlider) {
      extraProps.sliderMin = 0; extraProps.sliderMax = 100;
      extraProps.sliderValue = 50; extraProps.sliderDecimals = 0;
    }
    if (type === ComponentType.DImageButton) extraProps.imageStretchToFit = true;
    if (type === ComponentType.DCollapsibleCategory) {
      extraProps.expanded = true;
      extraProps.headerHeight = 20;
    }
    if (type === ComponentType.DRichText) extraProps.richScrollbar = true;
    if (type === ComponentType.DBinder) extraProps.binderKey = 'NONE';
    if (type === ComponentType.DNumberWang) {
      extraProps.sliderMin = 0; extraProps.sliderMax = 100;
      extraProps.sliderValue = 0; extraProps.sliderDecimals = 0;
      extraProps.numberInterval = 1;
    }
    if (type === ComponentType.DVerticalDivider) {
      extraProps.dividerTopHeight = 100;
      extraProps.dividerHeight = 4;
    }
    if (type === ComponentType.DColorMixer) {
      extraProps.mixerColor = '#ff8000';
      extraProps.mixerAlpha = 255;
      extraProps.mixerShowAlphaBar = true;
      extraProps.mixerShowPalette = true;
      extraProps.mixerShowWangs = true;
    }
    if (type === ComponentType.DColorCube) {
      extraProps.cubeBaseColor = '#ff0000';
      extraProps.sliderX = 0.5;
      extraProps.sliderY = 0.5;
    }
    if (type === ComponentType.DColorPalette) {
      extraProps.paletteColors = '#ffffff,#bebebe,#ff0000,#ffa500,#ffff00,#00ff00,#00ffff,#0080ff,#0000ff,#800080,#ff00ff,#ffc0cb,#a52a2a,#000000';
      extraProps.paletteButtonSize = 16;
      extraProps.paletteNumRows = 2;
    }
    if (type === ComponentType.DSysButton) extraProps.sysButtonType = 'close';
    if (type === ComponentType.DHTML) {
      extraProps.htmlUrl = 'https://wiki.facepunch.com/gmod/';
      extraProps.htmlScrollbars = true;
    }
    if (type === ComponentType.DTree) {
      extraProps.treeNodes = 'Folder|icon16/folder.png\n  Subfolder|icon16/folder.png\n    Document.txt|icon16/page.png\n  Another\nOther root';
      extraProps.treeIndentSize = 16;
      extraProps.treeLineHeight = 17;
      extraProps.treeShowIcons = true;
    }
    if (type === ComponentType.DMenu) {
      extraProps.menuItems = 'Open|icon16/folder.png\nSave|icon16/disk.png\n---\nQuit|icon16/door.png';
      extraProps.menuShowIconColumn = true;
    }
    if (type === ComponentType.DMenuBar) {
      extraProps.menuBarItems = 'File: New, Open, Save, ---, Quit\nEdit: Undo, Redo, ---, Cut, Copy, Paste\nView: Toolbar, Status Bar\nHelp: About';
    }
    if (type === ComponentType.DGrid) {
      extraProps.gridCols = 4;
      extraProps.gridColWide = 50;
      extraProps.gridRowHeight = 50;
    }
    if (type === ComponentType.DIconLayout) {
      extraProps.iconSpaceX = 5;
      extraProps.iconSpaceY = 5;
      extraProps.iconBorder = 0;
      extraProps.iconLayoutDir = 'TOP';
    }
    if (type === ComponentType.DListView) {
      extraProps.listColumns = 'Name,Value';
      extraProps.listRows = 'Foo,42\nBar,7\nBaz,99';
      extraProps.listSortable = true;
    }
    if (type === ComponentType.DComboBox) {
      extraProps.comboChoices = 'Option A\nOption B\nOption C';
      extraProps.comboSortItems = true;
    }
    // Sensible defaults for the chunk-6 audit additions.
    if (type === ComponentType.DButton) extraProps.buttonEnabled = true;
    if (type === ComponentType.DTextEntry) extraProps.entryEditable = true;
    if (type === ComponentType.DPanel) extraProps.panelPaintBackground = true;
    if (type === ComponentType.DFrame) extraProps.framePaintBackground = true;

    const newElement: UIElement = {
      id,
      type,
      parentId,
      children: [],
      props: {
        x: parentId ? 20 : 100,
        y: parentId ? 20 : 100,
        w,
        h,
        text: type === ComponentType.DLabel ? 'Label'
            : type === ComponentType.DButton ? 'Button'
            : type === ComponentType.DFrame ? 'My Window'
            : type === ComponentType.DNumSlider ? 'Slider'
            : type === ComponentType.DCollapsibleCategory ? 'Category'
            : type === ComponentType.DRichText ? 'Rich text\ngoes here...'
            : type === ComponentType.DComboBox ? 'Option A'
            : liaDefinition?.defaultText,
        variableName: `${type.toLowerCase()}_${Math.floor(Math.random() * 1000)}`,
        color: type === ComponentType.DFrame ? '#333333' : undefined,
        textAlign: 'center',
        ...extraProps,
      }
    };

    const newElements = { ...currentState.elements, [id]: newElement };
    if (newElement.parentId && newElements[newElement.parentId]) {
      newElements[newElement.parentId] = {
        ...newElements[newElement.parentId],
        children: [...newElements[newElement.parentId].children, id]
      };
    }

    pushState({
      ...currentState,
      elements: newElements,
      rootId: getPrimaryRootId(newElements, currentState.rootId || id),
      selectedId: id,
      selectedIds: [id],
    });
  };

  const updateComponent = useCallback((id: string, props: Partial<UIElement['props']>) => {
    if (!currentState.elements[id]) return;

    const newState = {
      ...currentState,
      elements: {
        ...currentState.elements,
        [id]: { ...currentState.elements[id], props: { ...currentState.elements[id].props, ...props } }
      }
    };

    const newHistory = [...history];
    newHistory[historyIndex] = newState;
    setHistory(newHistory);
  }, [currentState, history, historyIndex]);

  // Apply multiple prop patches atomically. Required for multi-drag because
  // updateComponent reads `currentState` from closure — calling it in a loop
  // makes every call see the SAME stale base state, and each subsequent call
  // overwrites the previous one's mutation. patchMany builds the entire new
  // elements map in one go, then issues a single setHistory write.
  // Like updateComponent, this is in-place (no new undo entry).
  const patchMany = useCallback((patches: Array<{ id: string; props: Partial<UIElement['props']> }>) => {
    if (patches.length === 0) return;
    const newElements = { ...currentState.elements };
    for (const { id, props } of patches) {
      const existing = newElements[id];
      if (!existing) continue;
      newElements[id] = { ...existing, props: { ...existing.props, ...props } };
    }
    const newHistory = [...history];
    newHistory[historyIndex] = { ...currentState, elements: newElements };
    setHistory(newHistory);
  }, [currentState, history, historyIndex]);

  const updateMethods = (id: string, methods: Record<string, string>) => {
      updateComponent(id, { methods });
  };

  const reparentComponent = useCallback((id: string, newParentId: string | null) => {
    const el = currentState.elements[id];
    if (!el || id === newParentId || el.parentId === newParentId) return;

    const newParent = newParentId ? currentState.elements[newParentId] : null;
    if (newParentId && (!newParent || !canAcceptChildren(newParent.type))) return;

    const descendants = getDescendantIds(currentState.elements, id);
    if (newParentId && descendants.has(newParentId)) return;

    const absolute = getAbsolutePosition(currentState.elements, id);
    const parentAbsolute = newParentId ? getAbsolutePosition(currentState.elements, newParentId) : { x: 0, y: 0 };
    const oldParentId = el.parentId;
    const newElements = { ...currentState.elements };

    if (oldParentId && newElements[oldParentId]) {
      newElements[oldParentId] = {
        ...newElements[oldParentId],
        children: newElements[oldParentId].children.filter(childId => childId !== id)
      };
    }

    if (newParentId && newElements[newParentId]) {
      newElements[newParentId] = {
        ...newElements[newParentId],
        children: [...newElements[newParentId].children.filter(childId => childId !== id), id]
      };
    }

    newElements[id] = {
      ...el,
      parentId: newParentId,
      props: {
        ...el.props,
        x: absolute.x - parentAbsolute.x,
        y: absolute.y - parentAbsolute.y
      }
    };

    pushState({
      ...currentState,
      elements: newElements,
      rootId: getPrimaryRootId(newElements, currentState.rootId)
    });
  }, [currentState, pushState]);

  // Wrap an element in a new DPanel parent. The wrapper takes over the element's
  // position/size; the element resets to (0,0) inside the wrapper.
  const groupElement = useCallback((id: string) => {
    const el = currentState.elements[id];
    if (!el) return;
    const oldParentId = el.parentId;
    const newId = Math.random().toString(36).substr(2, 9);
    const newPanel: UIElement = {
      id: newId,
      type: ComponentType.DPanel,
      parentId: oldParentId,
      children: [id],
      props: {
        x: el.props.x,
        y: el.props.y,
        w: el.props.w,
        h: el.props.h,
        variableName: `panel_group_${Math.floor(Math.random() * 1000)}`,
        panelPaintBackground: false,
      }
    };
    const newElements = { ...currentState.elements };
    newElements[newId] = newPanel;
    newElements[id] = { ...el, parentId: newId, props: { ...el.props, x: 0, y: 0 } };
    if (oldParentId && newElements[oldParentId]) {
      newElements[oldParentId] = {
        ...newElements[oldParentId],
        children: newElements[oldParentId].children.map(cid => cid === id ? newId : cid)
      };
    }
    pushState({
      ...currentState,
      elements: newElements,
      rootId: getPrimaryRootId(newElements, currentState.rootId === id ? newId : currentState.rootId),
      selectedId: newId,
      selectedIds: [newId]
    });
  }, [currentState, pushState]);

  // Reverse of group: move this element's children up to the grandparent
  // (preserving their visual position) and delete this element.
  const ungroupElement = useCallback((id: string) => {
    const el = currentState.elements[id];
    if (!el) return;
    if (el.children.length === 0) {
      alert("Element has no children to ungroup.");
      return;
    }
    const parentId = el.parentId;
    const newElements = { ...currentState.elements };
    for (const cid of el.children) {
      const child = newElements[cid];
      if (!child) continue;
      newElements[cid] = {
        ...child,
        parentId,
        props: {
          ...child.props,
          x: child.props.x + el.props.x,
          y: child.props.y + el.props.y,
        }
      };
    }
    if (parentId && newElements[parentId]) {
      newElements[parentId] = {
        ...newElements[parentId],
        children: newElements[parentId].children.flatMap(cid => cid === id ? el.children : [cid])
      };
    }
    delete newElements[id];
    pushState({
      ...currentState,
      elements: newElements,
      rootId: getPrimaryRootId(newElements, currentState.rootId === id ? el.children[0] || null : currentState.rootId),
      selectedId: el.children[0] || null,
      selectedIds: el.children[0] ? [el.children[0]] : []
    });
  }, [currentState, pushState]);

  // Compute the bounding box of the children (in the element's local coords),
  // resize this element to fit it, and shift children so they keep visual position.
  const shrinkToFitContents = useCallback((id: string) => {
    const el = currentState.elements[id];
    if (!el || el.children.length === 0) return;
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    for (const cid of el.children) {
      const c = currentState.elements[cid];
      if (!c) continue;
      minX = Math.min(minX, c.props.x);
      minY = Math.min(minY, c.props.y);
      maxX = Math.max(maxX, c.props.x + c.props.w);
      maxY = Math.max(maxY, c.props.y + c.props.h);
    }
    if (!isFinite(minX)) return;
    const newElements = { ...currentState.elements };
    newElements[id] = {
      ...el,
      props: {
        ...el.props,
        x: el.props.x + minX,
        y: el.props.y + minY,
        w: maxX - minX,
        h: maxY - minY,
      }
    };
    for (const cid of el.children) {
      const c = currentState.elements[cid];
      if (!c) continue;
      newElements[cid] = { ...c, props: { ...c.props, x: c.props.x - minX, y: c.props.y - minY } };
    }
    pushState({ ...currentState, elements: newElements });
  }, [currentState, pushState]);

  // Move element to its grandparent, preserving the visual (absolute) position.
  // Disabled when parent is the root frame (no grandparent to move to).
  const unparentElement = useCallback((id: string) => {
    const el = currentState.elements[id];
    if (!el || !el.parentId) return;
    const parent = currentState.elements[el.parentId];
    if (!parent) return;
    const newParentId = parent.parentId;
    const newElements = { ...currentState.elements };
    newElements[id] = {
      ...el,
      parentId: newParentId,
      props: { ...el.props, x: el.props.x + parent.props.x, y: el.props.y + parent.props.y }
    };
    newElements[parent.id] = {
      ...newElements[parent.id],
      children: newElements[parent.id].children.filter(cid => cid !== id)
    };
    if (newParentId && newElements[newParentId]) {
      newElements[newParentId] = {
        ...newElements[newParentId],
        children: [...newElements[newParentId].children.filter(cid => cid !== id), id]
      };
    }
    pushState({
      ...currentState,
      elements: newElements,
      rootId: getPrimaryRootId(newElements, currentState.rootId)
    });
  }, [currentState, pushState]);

  const duplicateElement = useCallback(() => {
    if (!currentState.selectedId || !currentState.elements[currentState.selectedId]) return;
    const originalEl = currentState.elements[currentState.selectedId];

    const newElements = { ...currentState.elements };
    
    // Recursive clone
    const clone = (id: string, parentId: string | null): string => {
        const el = currentState.elements[id];
        const newId = Math.random().toString(36).substr(2, 9);
        const newEl = {
            ...el,
            id: newId,
            parentId,
            children: [],
            props: {
                ...el.props,
                x: parentId === el.parentId ? el.props.x + viewState.gridSize : el.props.x,
                y: parentId === el.parentId ? el.props.y + viewState.gridSize : el.props.y,
                variableName: el.props.variableName + '_copy'
            }
        };
        newElements[newId] = newEl;
        if (el.children) {
            newEl.children = el.children.map(cid => clone(cid, newId));
        }
        return newId;
    };

    const newRootId = clone(currentState.selectedId, originalEl.parentId);

    if (originalEl.parentId && newElements[originalEl.parentId]) {
        newElements[originalEl.parentId].children.push(newRootId);
    }

    pushState({
        ...currentState,
        elements: newElements,
        rootId: getPrimaryRootId(newElements, currentState.rootId),
        selectedId: newRootId,
        selectedIds: [newRootId]
    });

  }, [currentState, viewState.gridSize, pushState]);

  // Single-select. Replaces any existing multi-selection.
  // Selection changes are in-place patches (not undoable) by design.
  const selectComponent = useCallback((id: string | null) => {
    const newHistory = [...history];
    newHistory[historyIndex] = { ...currentState, selectedId: id, selectedIds: id ? [id] : [] };
    setHistory(newHistory);
  }, [history, historyIndex, currentState]);

  // Toggle membership of `id` in the multi-selection. Used by Ctrl+Click.
  // The toggled element becomes primary if it was newly added; if removed,
  // the next item in the remaining set becomes primary (or null if empty).
  const toggleSelection = useCallback((id: string) => {
    const isInSelection = currentState.selectedIds.includes(id);
    const newSelectedIds = isInSelection
      ? currentState.selectedIds.filter(s => s !== id)
      : [...currentState.selectedIds, id];
    const newPrimary = isInSelection
      ? (newSelectedIds[newSelectedIds.length - 1] ?? null)
      : id;
    const newHistory = [...history];
    newHistory[historyIndex] = { ...currentState, selectedId: newPrimary, selectedIds: newSelectedIds };
    setHistory(newHistory);
  }, [history, historyIndex, currentState]);

  // Replace the whole selection with `ids`. Primary becomes the LAST id (most-recent
  // semantics — for "select children" the deepest is most-recent; for "select parents"
  // the root is most-recent). Caller can pre-order the array to control the primary.
  const selectMany = useCallback((ids: string[]) => {
    const dedup = Array.from(new Set(ids)).filter(id => currentState.elements[id]);
    const newPrimary = dedup.length > 0 ? dedup[dedup.length - 1] : null;
    const newHistory = [...history];
    newHistory[historyIndex] = { ...currentState, selectedId: newPrimary, selectedIds: dedup };
    setHistory(newHistory);
  }, [history, historyIndex, currentState]);

  const deleteComponent = (id: string) => {
    deleteMany([id]);
  };

  // Bulk-delete a set of elements (and their descendants). Used by the keyboard
  // Delete shortcut on multi-selection and the context menu Delete when >1 selected.
  // Skips elements already removed transitively (a parent + child both selected:
  // delete parent, child goes with it).
  const deleteMany = (ids: string[]) => {
    if (ids.length === 0) return;
    const toDelete = new Set<string>();
    const collectIds = (currId: string) => {
      if (toDelete.has(currId)) return;
      const el = currentState.elements[currId];
      if (!el) return;
      toDelete.add(currId);
      el.children.forEach(collectIds);
    };
    ids.forEach(collectIds);

    const newElements = { ...currentState.elements };
    // Strip each victim from its parent's children list (if parent survives)
    for (const did of toDelete) {
      const el = currentState.elements[did];
      if (el?.parentId && !toDelete.has(el.parentId) && newElements[el.parentId]) {
        newElements[el.parentId] = {
          ...newElements[el.parentId],
          children: newElements[el.parentId].children.filter(cid => cid !== did),
        };
      }
    }
    toDelete.forEach(did => delete newElements[did]);

    const preferredRootId = currentState.rootId && !toDelete.has(currentState.rootId) ? currentState.rootId : null;

    pushState({
      ...currentState,
      elements: newElements,
      rootId: getPrimaryRootId(newElements, preferredRootId),
      selectedId: null,
      selectedIds: [],
    });
  };

  const clearCanvas = () => {
    if(confirm("Clear everything?")) pushState(initialState);
  };

  // Keyboard Shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
        // Undo/Redo
        if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
            e.preventDefault();
            e.shiftKey ? redo() : undo();
        }
        if ((e.ctrlKey || e.metaKey) && e.key === 'y') {
            e.preventDefault();
            redo();
        }
        // Duplicate
        if ((e.ctrlKey || e.metaKey) && e.key === 'd') {
            e.preventDefault();
            duplicateElement();
        }
        // Save
        if ((e.ctrlKey || e.metaKey) && e.key === 's') {
            e.preventDefault();
            handleSave();
        }
        // Open
        if ((e.ctrlKey || e.metaKey) && e.key === 'o') {
            e.preventDefault();
            handleOpenClick();
        }
        // Delete (bulk-aware — wipes the entire multi-selection)
        if (e.key === 'Delete' && currentState.selectedIds.length > 0) {
            deleteMany(currentState.selectedIds);
        }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [historyIndex, history, currentState, duplicateElement, handleSave, handleOpenClick]);

  return (
    <div className="flex flex-col h-screen w-screen bg-neutral-950 text-white font-sans selection:bg-blue-500/30">
      <MenuBar
        onNew={handleNew}
        onOpen={handleOpenClick}
        onSave={handleSave}
        onSaveAs={handleSaveAs}
        onImport={handleImportClick}
        onExport={handleExport}
        onUndo={undo}
        onRedo={redo}
        onDelete={() => currentState.selectedIds.length > 0 && deleteMany(currentState.selectedIds)}
        onDuplicate={duplicateElement}
        onClearEverything={clearCanvas}
        canUndo={historyIndex > 0}
        canRedo={historyIndex < history.length - 1}
        hasSelection={!!currentState.selectedId}
      />

      <input 
        type="file" 
        accept=".json" 
        ref={openFileRef} 
        onChange={handleFileOpen} 
        className="hidden" 
      />
      <input 
        type="file" 
        accept=".lua,.txt" 
        ref={importLuaRef} 
        onChange={handleLuaImport} 
        className="hidden" 
      />

      {/* Secondary Toolbar (History, Grid, Methods) */}
      <div className="h-10 bg-neutral-900 border-b border-neutral-800 flex items-center px-4 justify-between shrink-0">
         <div className="flex items-center space-x-2">
            <button onClick={undo} disabled={historyIndex === 0} className="p-1.5 text-neutral-400 hover:text-white disabled:opacity-30 rounded hover:bg-neutral-800" title="Undo (Ctrl+Z)"><Undo2 className="w-4 h-4" /></button>
            <button onClick={redo} disabled={historyIndex === history.length - 1} className="p-1.5 text-neutral-400 hover:text-white disabled:opacity-30 rounded hover:bg-neutral-800" title="Redo (Ctrl+Y)"><Redo2 className="w-4 h-4" /></button>
            <div className="w-px h-4 bg-neutral-700 mx-2"></div>
            <div className="flex items-center gap-2">
                <Grid className="w-4 h-4 text-neutral-500" />
                <span className="text-xs text-neutral-500">Grid Size:</span>
                <input 
                    type="number" 
                    value={viewState.gridSize} 
                    onChange={(e) => setViewState({...viewState, gridSize: Math.max(1, parseInt(e.target.value) || 10)})}
                    className="w-12 bg-neutral-800 border border-neutral-700 rounded px-1 py-0.5 text-xs text-white"
                />
            </div>
            
            <div className="w-px h-4 bg-neutral-700 mx-2"></div>
            
            <button 
                onClick={() => setIsMethodsMenuOpen(true)}
                disabled={!currentState.selectedId}
                className="flex items-center gap-2 px-3 py-1 rounded bg-neutral-800 hover:bg-neutral-700 text-neutral-300 hover:text-white transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
            >
                <ScrollText className="w-3.5 h-3.5" />
                <span className="text-xs font-medium">Methods</span>
            </button>
         </div>
         <div className="flex items-center gap-3">
            <label className="flex items-center gap-2 text-xs text-neutral-500">
              <span>Lilia Theme Preview</span>
              <select
                value={liaThemeId}
                onChange={(e) => setLiaThemeId(e.target.value)}
                className="bg-neutral-800 border border-neutral-700 rounded px-2 py-1 text-xs text-neutral-200 focus:outline-none focus:border-blue-500"
              >
                {LIA_THEMES.map(theme => <option key={theme.id} value={theme.id}>{theme.name}</option>)}
              </select>
            </label>
            <span className="text-xs text-neutral-500">{currentFileName} {historyIndex === history.length - 1 ? '(Saved)' : '(Modified)'}</span>
         </div>
      </div>

      <div className="flex flex-1 overflow-hidden relative">
        <Sidebar onAddComponent={addComponent} />

        {/* Tree Graph Panel — hierarchical view of every element on the canvas. */}
        <TreeGraphPanel
          elements={currentState.elements}
          selectedId={currentState.selectedId}
          selectedIds={currentState.selectedIds}
          onSelect={selectComponent}
          onToggleSelection={toggleSelection}
          onDelete={deleteComponent}
          onReparent={reparentComponent}
        />

        {/* Middle Column: Canvas + Lua Output */}
        <div className="flex-1 flex flex-col min-w-0 bg-[#151515] relative">
            <Canvas
                state={currentState}
                viewState={viewState}
                onSelect={selectComponent}
                onToggleSelection={toggleSelection}
                onSelectMany={selectMany}
                onUpdateElement={updateComponent}
                onPatchMany={patchMany}
                onViewChange={setViewState}
                onDeleteElement={deleteComponent}
                onDeleteMany={deleteMany}
                onReparent={reparentComponent}
                onGroup={groupElement}
                onUngroup={ungroupElement}
                onShrinkToFit={shrinkToFitContents}
                onUnparent={unparentElement}
                onDuplicate={duplicateElement}
                liaThemeId={liaThemeId}
            />
            
            {/* Lua Output Panel */}
            <div className={`border-t border-neutral-800 bg-[#1e1e1e] flex flex-col shrink-0 transition-all duration-300 z-10 ${isOutputCollapsed ? 'h-9' : 'h-64'}`}>
                <div 
                    className="h-9 border-b border-neutral-800 bg-neutral-900 flex items-center justify-between px-3 cursor-pointer select-none hover:bg-neutral-800/80 transition-colors"
                    onClick={() => setIsOutputCollapsed(!isOutputCollapsed)}
                >
                    <div className="flex items-center text-neutral-400 gap-2">
                         <div className={`transition-transform duration-300 ${isOutputCollapsed ? '-rotate-90' : 'rotate-0'}`}>
                            <ChevronDown className="w-3.5 h-3.5" />
                         </div>
                        <Terminal className="w-3.5 h-3.5" />
                        <span className="text-[10px] font-bold uppercase">Lua Output</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <button 
                            onClick={(e) => { e.stopPropagation(); navigator.clipboard.writeText(generatedCode); }} 
                            className="text-neutral-500 hover:text-white flex items-center gap-1.5 px-2 py-1 rounded hover:bg-neutral-800 transition-colors"
                            title="Copy to Clipboard"
                        >
                            <Copy className="w-3.5 h-3.5" /><span className="text-[10px]">Copy</span>
                        </button>
                    </div>
                </div>
                
                <div className={`flex-1 overflow-auto p-3 bg-[#1e1e1e] ${isOutputCollapsed ? 'hidden' : 'block'}`}>
                    <pre className="text-[11px] font-mono text-green-400/90 whitespace-pre-wrap break-all leading-relaxed">{generatedCode}</pre>
                </div>
            </div>
        </div>
        
        {/* Right Column: Properties */}
        <div className="flex flex-col border-l border-neutral-800 w-80 shrink-0 bg-neutral-900">
             <div className="flex-1 flex flex-col min-h-0">
                <PropertiesPanel 
                    selectedElement={currentState.selectedId ? currentState.elements[currentState.selectedId] : null}
                    allElements={currentState.elements}
                    onChange={(id, p) => {
                         if (!currentState.elements[id]) return;
                         pushState({
                           ...currentState,
                           elements: {
                             ...currentState.elements,
                             [id]: { ...currentState.elements[id], props: { ...currentState.elements[id].props, ...p } }
                           }
                         });
                    }}
                    onReparent={reparentComponent}
                    onDelete={deleteComponent}
                />
             </div>
        </div>
      </div>

      {currentState.selectedId && currentState.elements[currentState.selectedId] && (
          <MethodsMenu
            element={currentState.elements[currentState.selectedId]}
            isOpen={isMethodsMenuOpen}
            onClose={() => setIsMethodsMenuOpen(false)}
            onSave={updateMethods}
          />
      )}

    </div>
  );
};

export default App;