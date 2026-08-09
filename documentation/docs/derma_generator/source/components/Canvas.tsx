import React, { useRef, useState, useEffect } from 'react';
import { EditorState, UIElement, ComponentType, ViewState } from '../types';
import { resolveDermaFont } from '../utils/dermaFonts';
import { SKIN_DEFAULTS, getEffectiveParentBg, getReadableTextColor } from '../utils/skinDefaults';
import { getGmodWikiUrl } from '../utils/componentDefinitions';
import { getLiaDefinition, isContainerType, isRootFrameType } from '../utils/liaComponentDefinitions';
import { canAcceptChildren, getDescendantIds, getTopLevelIds } from '../utils/hierarchy';
import { getLiaTheme } from '../utils/liaThemes';
import { ZoomIn, ZoomOut, Grid as GridIcon, ImageOff, Cuboid, X, Lock, LockOpen, Maximize2, Globe, Trash2, Settings2, Group, Ungroup, Minimize2, Link as LinkIcon, Unlink, ChevronRight, Copy as CopyIcon, Check, Square, Type as TypeIcon } from 'lucide-react';

// Component types whose visible text can be edited inline by double-clicking.
const TEXT_EDITABLE_TYPES = new Set<ComponentType>([
  ComponentType.DLabel,
  ComponentType.DButton,
  ComponentType.DTextEntry,
  ComponentType.DCheckBox,
  ComponentType.DComboBox,
  ComponentType.DFrame,
  ComponentType.DForm,
  ComponentType.DNumSlider, // editable label
  ComponentType.DCollapsibleCategory, // editable header
  ComponentType.liaFrame,
  ComponentType.liaSlideBox,
  ComponentType.liaButton,
  ComponentType.liaHugeButton,
  ComponentType.liaBigButton,
  ComponentType.liaMediumButton,
  ComponentType.liaSmallButton,
  ComponentType.liaMiniButton,
  ComponentType.liaNoBGButton,
  ComponentType.liaCustomFontButton,
  ComponentType.liaNotice,
  ComponentType.liaNoticePanel,
  ComponentType.liaLockCircle,
]);

interface CanvasProps {
  state: EditorState;
  viewState: ViewState;
  onSelect: (id: string | null) => void;
  onToggleSelection?: (id: string) => void;
  onSelectMany?: (ids: string[]) => void;
  onUpdateElement: (id: string, updates: Partial<UIElement['props']>) => void;
  onPatchMany?: (patches: Array<{ id: string; props: Partial<UIElement['props']> }>) => void;
  onViewChange: (newView: ViewState) => void;
  onDeleteElement?: (id: string) => void;
  onDeleteMany?: (ids: string[]) => void;
  onReparent?: (id: string, newParentId: string | null) => void;
  onGroup?: (id: string) => void;
  onUngroup?: (id: string) => void;
  onShrinkToFit?: (id: string) => void;
  onUnparent?: (id: string) => void;
  onDuplicate?: () => void;
  liaThemeId: string;
}

const Canvas: React.FC<CanvasProps> = ({ state, viewState, onSelect, onToggleSelection, onSelectMany, onUpdateElement, onPatchMany, onViewChange, onDeleteElement, onDeleteMany, onReparent, onGroup, onUngroup, onShrinkToFit, onUnparent, onDuplicate, liaThemeId }) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [isPanning, setIsPanning] = useState(false);
  const [lastMousePos, setLastMousePos] = useState({ x: 0, y: 0 });
  const [hoveredId, setHoveredId] = useState<string | null>(null);
  const [editingId, setEditingId] = useState<string | null>(null);
  // Holds start-of-drag snapshot for the group bounding-box resize. Using a ref
  // (not state) so mousemove handlers don't trigger re-renders on every frame.
  const groupResizeDragRef = useRef<{
    startMouseX: number;
    startMouseY: number;
    // Props-space bounding box at drag start (parent-relative coords, same system as el.props.x/y).
    startBounds: { px: number; py: number; w: number; h: number };
    // Per-element snapshot in props space.
    startElements: Map<string, { x: number; y: number; w: number; h: number }>;
    dir: string;
  } | null>(null);
  // Context menu: when non-null, an absolutely-positioned menu is shown.
  const [contextMenu, setContextMenu] = useState<{ x: number; y: number; elementId: string; submenu: 'parent' | null } | null>(null);
  const liaTheme = getLiaTheme(liaThemeId).palette;

  const snap = (val: number) => {
      if (!viewState.showGrid) return val;
      const s = viewState.gridSize;
      return Math.round(val / s) * s;
  };

  // An element is effectively locked if it OR any ancestor has props.locked === true.
  // This walks the parent chain so locking a DFrame freezes its whole subtree.
  const isEffectivelyLocked = (id: string): boolean => {
    let curr: UIElement | undefined = state.elements[id];
    while (curr) {
      if (curr.props.locked) return true;
      curr = curr.parentId ? state.elements[curr.parentId] : undefined;
    }
    return false;
  };

  // Usable inner area of a parent element, returned as {x, y, w, h} so callers
  // can both POSITION and SIZE children to fit the chrome-free area.
  //
  // In actual gmod, child positions like :SetPos(5,5) are relative to the
  // parent's TOP-LEFT (including any title bar / header), so the editor honors
  // raw coords as-is in renderElement. The chrome offsets here are only used by
  // "Fill Parent" — that action smartly snaps a child below the title bar so
  // the user gets the obviously-intended result.
  const getInnerArea = (parent: UIElement): { x: number; y: number; w: number; h: number } => {
    const { w, h } = parent.props;
    switch (parent.type) {
      case ComponentType.DFrame:          return { x: 0, y: 24, w, h: Math.max(0, h - 24) };
      case ComponentType.liaFrame:        return { x: 0, y: 46, w, h: Math.max(0, h - 46) };
      case ComponentType.DPropertySheet:  return { x: 4, y: 28, w: Math.max(0, w - 8), h: Math.max(0, h - 32) };
      case ComponentType.DForm:           return { x: 4, y: 28, w: Math.max(0, w - 8), h: Math.max(0, h - 32) };
      case ComponentType.DCollapsibleCategory: {
        const headerH = parent.props.headerHeight ?? 20;
        return { x: 0, y: headerH, w, h: Math.max(0, h - headerH) };
      }
      default:                             return { x: 0, y: 0, w, h };
    }
  };

  const fillParent = (id: string) => {
    const el = state.elements[id];
    if (!el || !el.parentId) return;
    const parent = state.elements[el.parentId];
    if (!parent) return;
    const { x, y, w, h } = getInnerArea(parent);
    onUpdateElement(id, { x, y, w, h });
  };

  const toggleLock = (id: string) => {
    const el = state.elements[id];
    if (!el) return;
    onUpdateElement(id, { locked: !el.props.locked });
  };

  // Renders the text of an element either as a static <span> or, when this
  // element is being edited (double-click), as an inline <input> that mirrors
  // the span's classes/styles so the visual stays consistent.
  // Commits on Enter or blur; Escape cancels without persisting.
  const editableText = (
    el: UIElement,
    text: string,
    className: string,
    style: React.CSSProperties,
  ) => {
    if (editingId !== el.id) {
      return <span className={className} style={style}>{text}</span>;
    }
    return (
      <input
        autoFocus
        defaultValue={text}
        className={className}
        style={{
          ...style,
          background: 'rgba(59,130,246,0.18)',
          outline: '1px solid #3b82f6',
          outlineOffset: '-1px',
          color: (style as any).color || 'inherit',
          // Behave well in either flex or block parents: take available space
          // but yield to siblings (close button, dropdown arrow, etc).
          flex: '1 1 auto',
          minWidth: 0,
          width: 'auto',
          padding: 0,
          margin: 0,
          border: 'none',
        }}
        onMouseDown={(e) => e.stopPropagation()}
        onClick={(e) => e.stopPropagation()}
        onDoubleClick={(e) => e.stopPropagation()}
        onFocus={(e) => e.currentTarget.select()}
        onBlur={(e) => {
          onUpdateElement(el.id, { text: e.currentTarget.value });
          setEditingId(null);
        }}
        onKeyDown={(e) => {
          if (e.key === 'Enter') {
            e.preventDefault();
            (e.currentTarget as HTMLInputElement).blur();
          } else if (e.key === 'Escape') {
            e.preventDefault();
            setEditingId(null);
          }
          e.stopPropagation();
        }}
      />
    );
  };

  const handleWheel = (e: React.WheelEvent) => {
    if (e.ctrlKey) {
        e.preventDefault();
        const zoomDelta = -e.deltaY * 0.001;
        const newZoom = Math.min(Math.max(0.1, viewState.zoom + zoomDelta), 5);
        onViewChange({ ...viewState, zoom: newZoom });
    } else {
        onViewChange({ 
            ...viewState, 
            panX: viewState.panX - e.deltaX, 
            panY: viewState.panY - e.deltaY 
        });
    }
  };

  const startPan = (e: React.MouseEvent) => {
    if (e.button === 1 || (e.button === 0 && e.altKey)) {
        setIsPanning(true);
        setLastMousePos({ x: e.clientX, y: e.clientY });
        e.stopPropagation();
    } else if (e.button === 0 && e.target === containerRef.current) {
        onSelect(null);
    }
  };

  // Dismiss the context menu on any outside click or Escape.
  useEffect(() => {
    if (!contextMenu) return;
    const onDown = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (!target.closest('[data-context-menu]')) setContextMenu(null);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setContextMenu(null);
    };
    window.addEventListener('mousedown', onDown);
    window.addEventListener('keydown', onKey);
    return () => {
      window.removeEventListener('mousedown', onDown);
      window.removeEventListener('keydown', onKey);
    };
  }, [contextMenu]);

  useEffect(() => {
    const handleGlobalMouseMove = (e: MouseEvent) => {
        if (isPanning) {
            const dx = e.clientX - lastMousePos.x;
            const dy = e.clientY - lastMousePos.y;
            onViewChange({
                ...viewState,
                panX: viewState.panX + dx,
                panY: viewState.panY + dy
            });
            setLastMousePos({ x: e.clientX, y: e.clientY });
        }
    };

    const handleGlobalMouseUp = () => {
        setIsPanning(false);
    };

    if (isPanning) {
        window.addEventListener('mousemove', handleGlobalMouseMove);
        window.addEventListener('mouseup', handleGlobalMouseUp);
    }
    return () => {
        window.removeEventListener('mousemove', handleGlobalMouseMove);
        window.removeEventListener('mouseup', handleGlobalMouseUp);
    };
  }, [isPanning, lastMousePos, viewState, onViewChange]);

  const renderResizeHandles = (el: UIElement) => {
      // Don't show handles if element is in an auto-layout container
      const parent = el.parentId ? state.elements[el.parentId] : null;
      if (parent && parent.props.layoutMode && parent.props.layoutMode !== 'none') return null;
      // Don't show handles if locked (self or via ancestor) — locking forbids resize.
      if (isEffectivelyLocked(el.id)) return null;

      const handles = ['n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw'];
      const size = 8 / viewState.zoom;
      
      const onResizeStart = (e: React.MouseEvent, dir: string) => {
          e.stopPropagation();
          const startX = e.clientX;
          const startY = e.clientY;
          const startProps = { ...el.props };

          const handleResizeMove = (moveEvent: MouseEvent) => {
              const dx = (moveEvent.clientX - startX) / viewState.zoom;
              const dy = (moveEvent.clientY - startY) / viewState.zoom;
              
              const newProps = { ...startProps };

              if (dir.includes('e')) newProps.w = Math.max(10, startProps.w + dx);
              if (dir.includes('s')) newProps.h = Math.max(10, startProps.h + dy);
              if (dir.includes('w')) {
                  const delta = Math.min(startProps.w - 10, dx);
                  newProps.x = startProps.x + delta;
                  newProps.w = startProps.w - delta;
              }
              if (dir.includes('n')) {
                  const delta = Math.min(startProps.h - 10, dy);
                  newProps.y = startProps.y + delta;
                  newProps.h = startProps.h - delta;
              }

              newProps.x = snap(newProps.x);
              newProps.y = snap(newProps.y);
              newProps.w = snap(newProps.w);
              newProps.h = snap(newProps.h);

              onUpdateElement(el.id, newProps);
          };

          const handleResizeUp = () => {
              document.removeEventListener('mousemove', handleResizeMove);
              document.removeEventListener('mouseup', handleResizeUp);
          };

          document.addEventListener('mousemove', handleResizeMove);
          document.addEventListener('mouseup', handleResizeUp);
      };

      return handles.map(dir => {
          const style: React.CSSProperties = {
              position: 'absolute',
              width: size,
              height: size,
              backgroundColor: '#3b82f6',
              border: '1px solid white',
              zIndex: 50,
              pointerEvents: 'auto'
          };
          
          if (dir === 'n') { style.top = -size/2; style.left = '50%'; style.transform = 'translateX(-50%)'; style.cursor = 'ns-resize'; }
          if (dir === 's') { style.bottom = -size/2; style.left = '50%'; style.transform = 'translateX(-50%)'; style.cursor = 'ns-resize'; }
          if (dir === 'w') { style.left = -size/2; style.top = '50%'; style.transform = 'translateY(-50%)'; style.cursor = 'ew-resize'; }
          if (dir === 'e') { style.right = -size/2; style.top = '50%'; style.transform = 'translateY(-50%)'; style.cursor = 'ew-resize'; }
          if (dir === 'nw') { style.top = -size/2; style.left = -size/2; style.cursor = 'nwse-resize'; }
          if (dir === 'ne') { style.top = -size/2; style.right = -size/2; style.cursor = 'nesw-resize'; }
          if (dir === 'sw') { style.bottom = -size/2; style.left = -size/2; style.cursor = 'nesw-resize'; }
          if (dir === 'se') { style.bottom = -size/2; style.right = -size/2; style.cursor = 'nwse-resize'; }

          return <div key={dir} style={style} onMouseDown={(e) => onResizeStart(e, dir)} />;
      });
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Multi-select group bounding box
  // ─────────────────────────────────────────────────────────────────────────

  interface GroupBounds {
    // Absolute canvas coords — used to position the overlay div.
    x: number; y: number; w: number; h: number;
    // Props-space origin — used for resize math (parent-relative, same as el.props.x/y).
    px: number; py: number;
    ids: string[];
  }

  // Walk the parent chain to get an element's position in root canvas space.
  // Does NOT account for CSS chrome offsets (DFrame title bar, etc.) — those are
  // visual-only and don't affect props coordinates.
  const getAbsoluteCanvasPos = (id: string): { x: number; y: number } => {
    const el = state.elements[id];
    if (!el) return { x: 0, y: 0 };
    if (!el.parentId) return { x: el.props.x, y: el.props.y };
    const p = getAbsoluteCanvasPos(el.parentId);
    return { x: p.x + el.props.x, y: p.y + el.props.y };
  };

  const computeGroupBounds = (): GroupBounds | null => {
    if (state.selectedIds.length < 2) return null;

    // Filter to elements that can participate in a group resize.
    const eligible = state.selectedIds.filter(id => {
      const el = state.elements[id];
      if (!el) return false;
      if (isEffectivelyLocked(id)) return false;
      const parent = el.parentId ? state.elements[el.parentId] : null;
      if (parent?.props.layoutMode && parent.props.layoutMode !== 'none') return false;
      if (parent?.type === ComponentType.DIconLayout) return false;
      return true;
    });

    if (eligible.length < 2) return null;

    // All must share the same parent so coordinates are in the same space.
    const parentSet = new Set(eligible.map(id => state.elements[id].parentId));
    if (parentSet.size > 1) return null;

    // Compute props-space bounding box (parent-relative coords).
    let minPX = Infinity, minPY = Infinity, maxPX = -Infinity, maxPY = -Infinity;
    for (const id of eligible) {
      const { x, y, w, h } = state.elements[id].props;
      minPX = Math.min(minPX, x);
      minPY = Math.min(minPY, y);
      maxPX = Math.max(maxPX, x + w);
      maxPY = Math.max(maxPY, y + h);
    }

    // Convert origin to absolute canvas space for rendering.
    const firstAbs = getAbsoluteCanvasPos(eligible[0]);
    const firstProps = state.elements[eligible[0]].props;
    const parentAbsX = firstAbs.x - firstProps.x;
    const parentAbsY = firstAbs.y - firstProps.y;

    return {
      x: minPX + parentAbsX,
      y: minPY + parentAbsY,
      w: maxPX - minPX,
      h: maxPY - minPY,
      px: minPX,
      py: minPY,
      ids: eligible,
    };
  };

  // Declared here, assigned just before the return so renderElement can read it via closure.
  let groupBounds: GroupBounds | null = null;

  const renderVGUIContent = (el: UIElement, isSelected: boolean) => {
      const baseText = "font-sans text-[11px] select-none";
      const isHovered = hoveredId === el.id;

      // Dynamic styles based on props
      const bgColor = (isHovered && el.props.hoverColor) ? el.props.hoverColor : el.props.color;
      const borderColor = (isHovered && el.props.hoverBorderColor) ? el.props.hoverBorderColor : el.props.borderColor;
      const opacity = (isHovered && el.props.hoverOpacity !== undefined) ? el.props.hoverOpacity / 255 : (el.props.opacity !== undefined ? el.props.opacity / 255 : 1);
      
      const textShadowStyle = (el.props.textShadow && el.props.textShadowColor) 
          ? `${el.props.textShadowOffset || 1}px ${el.props.textShadowOffset || 1}px 0px ${el.props.textShadowColor}`
          : undefined;

      // Resolve the Derma font name to a real CSS font-family + default size + weight.
      // The user's per-element fontSize/fontWeight overrides apply when truthy.
      const resolvedFont = resolveDermaFont(el.props.fontFamily, el.props.fontSize, el.props.fontWeight);

      const commonStyle: React.CSSProperties = {
          backgroundColor: bgColor,
          borderColor: borderColor || 'transparent',
          borderWidth: el.props.borderWidth ? `${el.props.borderWidth}px` : '0px',
          borderStyle: (el.props.borderWidth && el.props.borderWidth > 0) ? 'solid' : 'none',
          borderRadius: el.props.borderRadius ? `${el.props.borderRadius}px` : '0px',
          justifyContent: el.props.textAlign === 'center' ? 'center' : el.props.textAlign === 'right' ? 'flex-end' : 'flex-start',
          opacity: opacity,
          fontFamily: resolvedFont.family,
          fontSize: `${resolvedFont.size}px`,
          fontWeight: resolvedFont.weight,
          textShadow: textShadowStyle,
      };

      const titleBarStyle: React.CSSProperties = {
          fontFamily: resolvedFont.family,
          fontSize: `${resolvedFont.size}px`,
          fontWeight: resolvedFont.weight,
      };

      const liaDefinition = getLiaDefinition(el.type);
      if (liaDefinition) {
          const options = el.props.liaOptions || {};
          const option = <T extends string | number | boolean>(key: string, fallback: T): T => (options[key] as T | undefined) ?? fallback;
          const themedColor = (key: string, fallback: string) => {
              const definition = liaDefinition.options.find(item => item.key === key);
              const current = options[key];
              return current === undefined || current === definition?.defaultValue ? fallback : String(current);
          };
          const panelPrimary = liaTheme.panel[0] || liaTheme.background;
          const panelSecondary = liaTheme.panel[1] || liaTheme.button;
          const panelAccent = liaTheme.panel[2] || liaTheme.accent;
          if (liaDefinition.preview === 'frame') {
              const liteMode = option('liteMode', false);
              const centerTitle = option('centerTitle', '');
              const showCloseButton = option('showCloseButton', true);
              const icon = option('icon', '');
              return (
                  <div className="w-full h-full overflow-hidden rounded-xl shadow-2xl" style={{ backgroundColor: liaTheme.background_alpha, border: `1px solid ${liaTheme.accent}` }}>
                      {!liteMode && (
                          <div className="h-[46px] flex items-center px-3 gap-2 border-b" style={{ backgroundColor: liaTheme.header, borderColor: liaTheme.focus_panel, color: liaTheme.text }}>
                              {icon && <div className="w-4 h-4 rounded-sm opacity-70" style={{ backgroundColor: liaTheme.accent }} title={icon} />}
                              {editableText(el, el.props.text || 'Lilia Window', `${baseText} font-semibold`, { ...titleBarStyle, color: liaTheme.text })}
                              {centerTitle && <span className="absolute left-1/2 -translate-x-1/2 text-[10px]" style={{ color: liaTheme.header_text }}>{centerTitle}</span>}
                              {showCloseButton && <span className="ml-auto text-xs" style={{ color: liaTheme.text }}>×</span>}
                          </div>
                      )}
                  </div>
              );
          }
          if (liaDefinition.preview === 'slider' || liaDefinition.preview === 'slidebox') {
              const min = Number(option('min', 0));
              const max = Number(option('max', 1));
              const value = Number(option('value', 0));
              const ratio = max === min ? 0 : Math.max(0, Math.min(1, (value - min) / (max - min)));
              return (
                  <div className="w-full h-full flex flex-col justify-center px-4 gap-2 bg-transparent">
                      {liaDefinition.preview === 'slidebox' && (
                          <div className="flex items-center justify-between text-[11px]" style={{ color: liaTheme.text }}>
                              {editableText(el, el.props.text || 'Slider', `${baseText}`, { color: liaTheme.text })}
                              <span style={{ color: liaTheme.accent }}>{value}</span>
                          </div>
                      )}
                      <div className="relative h-2 rounded-full border" style={{ backgroundColor: liaTheme.focus_panel, borderColor: liaTheme.category }}>
                          <div className="absolute inset-y-0 left-0 rounded-full opacity-70" style={{ width: `${ratio * 100}%`, backgroundColor: liaTheme.accent }} />
                          <div className="absolute top-1/2 w-3.5 h-3.5 rounded-full border-2 -translate-x-1/2 -translate-y-1/2" style={{ left: `${ratio * 100}%`, backgroundColor: liaTheme.text, borderColor: liaTheme.accent }} />
                      </div>
                      {liaDefinition.preview === 'slidebox' && <div className="flex justify-between text-[9px]" style={{ color: liaTheme.gray }}><span>{min}</span><span>{max}</span></div>}
                  </div>
              );
          }
          if (liaDefinition.preview === 'button') {
              const radius = Number(option('radius', 12));
              const baseColor = themedColor('baseColor', liaTheme.button);
              const textColor = themedColor('textColor', liaTheme.text);
              const noBackground = Boolean(option('noBackground', false));
              const selected = Boolean(option('selected', false));
              const showLine = Boolean(option('showLine', false));
              const icon = String(option('icon', ''));
              const iconSize = Number(option('iconSize', 16));
              return (
                  <div
                      className="relative w-full h-full flex items-center justify-center border overflow-hidden"
                      style={{ borderRadius: `${radius}px`, backgroundColor: noBackground ? 'transparent' : baseColor, color: textColor, borderColor: liaTheme.accent }}
                  >
                      {selected && !noBackground && <div className="absolute inset-0 opacity-20" style={{ backgroundColor: liaTheme.accent }} />}
                      {selected && showLine && <div className="absolute left-0 top-2 bottom-2 w-[3px]" style={{ backgroundColor: liaTheme.accent }} />}
                      <div className="relative flex items-center gap-2 px-2">
                          {icon && <span className="inline-block rounded-sm opacity-60" style={{ width: iconSize, height: iconSize, backgroundColor: liaTheme.accent }} title={icon} />}
                          {editableText(el, el.props.text || 'Button', `${baseText} text-current`, { fontSize: `${Math.max(10, Math.min(22, el.props.h * 0.38))}px` })}
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'checkbox') {
              const checked = Boolean(option('checked', false));
              return (
                  <div className="w-full h-full flex items-center justify-between gap-3 px-2" style={{ color: liaTheme.text }}>
                      {editableText(el, el.props.text || 'Checkbox', `${baseText}`, { color: liaTheme.text })}
                      <div className="relative w-[52px] h-[20px] rounded-full border shrink-0" style={{ backgroundColor: liaTheme.toggle, borderColor: liaTheme.category }}>
                          <div
                              className="absolute top-1/2 w-4 h-4 rounded-full border border-white/20 -translate-y-1/2 transition-all"
                              style={{ left: checked ? '32px' : '2px', backgroundColor: checked ? liaTheme.accent : liaTheme.gray }}
                          />
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'combobox') {
              const selected = String(option('selected', ''));
              const placeholder = String(option('placeholder', 'Select an option'));
              const textColor = themedColor('textColor', liaTheme.text);
              return (
                  <div className="w-full h-full flex items-center px-3 rounded-md border" style={{ color: textColor, backgroundColor: liaTheme.background_panelpopup, borderColor: liaTheme.category }}>
                      <span className={`${baseText} truncate`}>{selected || placeholder}</span>
                      <span className="ml-auto text-[10px]" style={{ color: liaTheme.accent }}>▼</span>
                  </div>
              );
          }
          if (liaDefinition.preview === 'entry') {
              const title = String(option('title', ''));
              const placeholder = String(option('placeholder', 'Enter text'));
              const textColor = themedColor('textColor', liaTheme.text);
              const disabled = Boolean(option('disabled', false));
              const centered = Number(option('contentAlignment', 0)) === 5;
              return (
                  <div className={`w-full h-full flex flex-col ${title ? 'gap-1' : ''}`} style={{ opacity: disabled ? 0.55 : 1 }}>
                      {title && <div className="text-[10px] truncate" style={{ color: liaTheme.header_text }}>{title}</div>}
                      <div className="flex-1 min-h-[26px] rounded-lg border flex items-center px-2 overflow-hidden" style={{ color: textColor, justifyContent: centered ? 'center' : 'flex-start', backgroundColor: liaTheme.focus_panel, borderColor: liaTheme.category }}>
                          {editableText(el, el.props.text || placeholder, `${baseText} truncate ${el.props.text ? '' : 'text-slate-500'}`, {})}
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'progress') {
              const fraction = Math.max(0, Math.min(1, Number(option('fraction', 0.5))));
              const barColor = themedColor('barColor', liaTheme.accent);
              const actionBar = Boolean(option('actionBar', false));
              return (
                  <div className={`w-full h-full flex flex-col justify-center ${actionBar ? 'rounded-md px-3 py-2 gap-2' : 'px-2'}`} style={{ backgroundColor: actionBar ? liaTheme.background_panelpopup : 'transparent', color: liaTheme.text }}>
                      {actionBar && el.props.text && <div className="text-center text-[10px] text-slate-200 truncate">{el.props.text}</div>}
                      <div className={`${actionBar ? 'h-8' : 'h-[22px]'} w-full rounded-md overflow-hidden`} style={{ backgroundColor: liaTheme.focus_panel }}>
                          <div className="h-full rounded-md" style={{ width: `${fraction * 100}%`, backgroundColor: barColor }} />
                      </div>
                      {!actionBar && el.props.text && <div className="absolute inset-0 flex items-center justify-center text-[10px] text-slate-100 pointer-events-none">{el.props.text}</div>}
                  </div>
              );
          }
          if (liaDefinition.preview === 'header') {
              const lineColor = themedColor('lineColor', liaTheme.accent);
              const lineWidth = Math.max(0, Number(option('lineWidth', 1)));
              return (
                  <div className="relative w-full h-full">
                      <div className="absolute left-1 right-1 bottom-0" style={{ height: `${lineWidth}px`, backgroundColor: lineColor }} />
                  </div>
              );
          }
          if (liaDefinition.preview === 'scroll') {
              return (
                  <div className="relative w-full h-full overflow-hidden border" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.focus_panel }}>
                      <div className="absolute top-1 right-0 bottom-1 w-[6px]" style={{ backgroundColor: liaTheme.focus_panel }}>
                          <div className="absolute top-2 left-0 right-0 h-1/3 rounded-full opacity-70" style={{ backgroundColor: liaTheme.accent }} />
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'horizontalScroll') {
              const padding = Math.max(0, Number(option('padding', 0)));
              return (
                  <div className="relative w-full h-full overflow-hidden border" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.focus_panel }}>
                      <div className="absolute left-0 right-0 top-0 bottom-[16px] flex items-center gap-2 overflow-hidden" style={{ padding: `${padding}px` }}>
                          <div className="h-2/3 min-w-[84px] rounded-md bg-white/[0.05] border border-white/10" />
                          <div className="h-2/3 min-w-[84px] rounded-md bg-white/[0.05] border border-white/10" />
                          <div className="h-2/3 min-w-[84px] rounded-md bg-white/[0.05] border border-white/10" />
                      </div>
                      <div className="absolute left-0 right-0 bottom-0 h-[16px] border-t" style={{ backgroundColor: liaTheme.focus_panel, borderColor: liaTheme.category }}>
                          <div className="absolute left-4 right-4 top-[5px] h-[6px] rounded-full opacity-60" style={{ backgroundColor: liaTheme.accent }} />
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'horizontalScrollBar') {
              const hideButtons = Boolean(option('hideButtons', false));
              const scroll = Math.max(0, Number(option('scroll', 0)));
              const offset = Math.min(70, scroll % 71);
              return (
                  <div className="relative w-full h-full border" style={{ backgroundColor: liaTheme.focus_panel, borderColor: liaTheme.category }}>
                      {!hideButtons && <span className="absolute left-1 top-1/2 -translate-y-1/2 text-[8px] text-slate-400">◀</span>}
                      <div className="absolute top-[3px] bottom-[3px] rounded-full opacity-60" style={{ backgroundColor: liaTheme.accent, left: `${hideButtons ? 2 + offset * 0.3 : 16 + offset * 0.25}%`, width: '24%' }} />
                      {!hideButtons && <span className="absolute right-1 top-1/2 -translate-y-1/2 text-[8px] text-slate-400">▶</span>}
                  </div>
              );
          }
          if (liaDefinition.preview === 'sheet') {
              const placeholder = String(option('placeholderText', '')) || 'Search...';
              const spacing = Math.max(0, Number(option('spacing', 8)));
              const padding = Math.max(0, Number(option('padding', 10)));
              return (
                  <div className="w-full h-full p-2 border overflow-hidden" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.focus_panel }}>
                      <div className="h-8 rounded-lg border px-2 flex items-center text-[10px]" style={{ backgroundColor: liaTheme.focus_panel, borderColor: liaTheme.category, color: liaTheme.gray }}>{placeholder}</div>
                      <div className="mt-2 overflow-hidden" style={{ padding: `${Math.min(padding, 16)}px` }}>
                          {[0, 1, 2].map(row => (
                              <div key={row} className="rounded-lg border px-3 py-2" style={{ marginBottom: row < 2 ? `${Math.min(spacing, 16)}px` : 0, backgroundColor: panelPrimary, borderColor: panelSecondary }}>
                                  <div className="h-2 w-1/3 rounded opacity-60" style={{ backgroundColor: panelAccent }} />
                                  <div className="h-1.5 w-2/3 rounded mt-2 opacity-35" style={{ backgroundColor: liaTheme.gray }} />
                              </div>
                          ))}
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'table') {
              const headerHeight = Math.max(16, Number(option('headerHeight', 36)));
              const hideHeaders = Boolean(option('hideHeaders', false));
              const multiSelect = Boolean(option('multiSelect', false));
              return (
                  <div className="w-full h-full overflow-hidden rounded-xl border" style={{ backgroundColor: liaTheme.background_panelpopup, borderColor: liaTheme.focus_panel }}>
                      {!hideHeaders && (
                          <div className="grid grid-cols-3 border-b border-cyan-400/30 bg-white/[0.03]" style={{ height: `${Math.min(headerHeight, Math.max(16, el.props.h * 0.3))}px` }}>
                              {['Column A', 'Column B', 'Column C'].map(label => <div key={label} className="flex items-center px-2 text-[9px] text-slate-300 border-r last:border-r-0 border-white/5">{label}</div>)}
                          </div>
                      )}
                      {[0, 1, 2, 3].map(row => (
                          <div key={row} className="grid grid-cols-3 h-8 border-b border-white/5" style={{ backgroundColor: row === 1 ? liaTheme.hover : 'transparent' }}>
                              <div className="px-2 flex items-center text-[9px] text-slate-400">Row {row + 1}</div>
                              <div className="px-2 flex items-center text-[9px] text-slate-500">{multiSelect && row < 2 ? 'Selected' : 'Value'}</div>
                              <div className="px-2 flex items-center text-[9px] text-slate-500">Data</div>
                          </div>
                      ))}
                  </div>
              );
          }
          if (liaDefinition.preview === 'tabs') {
              const style = String(option('tabStyle', 'modern'));
              const tabHeight = Math.max(20, Number(option('tabHeight', 38)));
              const indicatorHeight = Math.max(0, Number(option('indicatorHeight', 2)));
              if (style === 'classic') {
                  return (
                      <div className="w-full h-full flex border overflow-hidden" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.focus_panel }}>
                          <div className="w-[30%] border-r border-white/5 p-1 space-y-1">
                              {['General', 'Appearance', 'Advanced'].map((label, index) => (
                                  <div key={label} className={`px-2 flex items-center text-[9px] rounded ${index === 0 ? 'bg-white/[0.08] text-slate-100' : 'text-slate-500'}`} style={{ height: `${Math.min(tabHeight, 40)}px` }}>{label}</div>
                              ))}
                          </div>
                          <div className="flex-1 m-2 rounded bg-white/[0.02] border border-white/5" />
                      </div>
                  );
              }
              return (
                  <div className="w-full h-full border overflow-hidden" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.focus_panel }}>
                      <div className="flex gap-1 px-1 border-b border-white/5" style={{ height: `${Math.min(tabHeight, 48)}px` }}>
                          {['General', 'Appearance', 'Advanced'].map((label, index) => (
                              <div key={label} className={`relative flex-1 min-w-0 flex items-center justify-center text-[9px] rounded-t ${index === 0 ? 'bg-white/[0.06] text-slate-100' : 'text-slate-500'}`}>
                                  {label}
                                  {index === 0 && <div className="absolute left-2 right-2 bottom-0" style={{ backgroundColor: liaTheme.accent, height: `${Math.min(indicatorHeight, 6)}px` }} />}
                              </div>
                          ))}
                      </div>
                      <div className="m-2 h-[calc(100%-3rem)] rounded bg-white/[0.02] border border-white/5" />
                  </div>
              );
          }
          if (liaDefinition.preview === 'tabButton') {
              const icon = String(option('icon', ''));
              const active = Boolean(option('active', false));
              const indicatorHeight = Math.max(0, Number(option('indicatorHeight', 2)));
              return (
                  <div className="relative w-full h-full flex items-center justify-center gap-2 rounded-lg" style={{ backgroundColor: active ? liaTheme.hover : 'transparent', color: active ? liaTheme.text : liaTheme.gray }}>
                      {icon && <div className="w-4 h-4 rounded-sm bg-slate-400/50" title={icon} />}
                      {editableText(el, el.props.text || 'Tab', `${baseText}`, { color: active ? liaTheme.text : liaTheme.gray })}
                      {active && <div className="absolute left-2 right-2 bottom-0" style={{ backgroundColor: liaTheme.accent, height: `${Math.min(indicatorHeight, 6)}px` }} />}
                  </div>
              );
          }
          if (liaDefinition.preview === 'model') {
              const model = String(option('model', 'models/player/kleiner.mdl'));
              const brightness = Math.max(0, Number(option('brightness', 1)));
              const copySequence = Boolean(option('copyLocalSequence', false));
              return (
                  <div className="relative w-full h-full overflow-hidden rounded-lg border flex items-end justify-center" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.focus_panel }}>
                      <div className="absolute top-2 left-2 right-2 flex justify-between text-[8px] text-slate-500"><span className="truncate">{model}</span><span>{copySequence ? 'SEQ' : 'IDLE'}</span></div>
                      <div className="relative h-[78%] w-[48%]" style={{ opacity: Math.min(1, 0.35 + brightness * 0.4) }}>
                          <div className="absolute left-1/2 top-0 -translate-x-1/2 w-[36%] aspect-square rounded-full bg-slate-400/55 border border-cyan-300/20" />
                          <div className="absolute left-[20%] right-[20%] top-[20%] bottom-[22%] rounded-[45%_45%_30%_30%] bg-slate-500/45 border border-cyan-300/10" />
                          <div className="absolute left-[4%] top-[25%] w-[18%] bottom-[30%] rounded-full bg-slate-500/35 rotate-6" />
                          <div className="absolute right-[4%] top-[25%] w-[18%] bottom-[30%] rounded-full bg-slate-500/35 -rotate-6" />
                          <div className="absolute left-[27%] bottom-0 w-[18%] h-[30%] rounded-full bg-slate-600/55" />
                          <div className="absolute right-[27%] bottom-0 w-[18%] h-[30%] rounded-full bg-slate-600/55" />
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'spawnIcon') {
              const hidden = Boolean(option('hidden', false));
              const model = String(option('model', 'models/player/kleiner.mdl'));
              return (
                  <div className="relative w-full h-full overflow-hidden rounded-md border flex items-center justify-center" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.focus_panel }}>
                      <div className="absolute top-1.5 left-1.5 right-1.5 text-[7px] text-slate-600 truncate">{model}</div>
                      <div className={`w-[46%] h-[62%] rounded-[45%_45%_35%_35%] border ${hidden ? 'bg-black border-slate-800' : 'bg-slate-500/45 border-cyan-300/20'}`}>
                          <div className={`w-[44%] aspect-square rounded-full mx-auto -mt-[22%] ${hidden ? 'bg-black' : 'bg-slate-400/60'}`} />
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'avatar') {
              return (
                  <div className="w-full h-full rounded-full overflow-hidden border-2 flex items-center justify-center" style={{ backgroundColor: liaTheme.background, borderColor: liaTheme.accent }}>
                      <div className="relative w-[72%] h-[72%]">
                          <div className="absolute left-1/2 top-0 -translate-x-1/2 w-[42%] aspect-square rounded-full bg-slate-400/65" />
                          <div className="absolute left-[12%] right-[12%] bottom-0 h-[52%] rounded-t-[50%] bg-slate-500/55" />
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'notice') {
              const type = String(option('type', 'default'));
              const accent = type === 'error' ? '#b43c3c' : type === 'success' ? '#3cb44b' : type === 'warning' ? '#b4963c' : type === 'money' ? '#329664' : type === 'admin' ? '#8c46b4' : type === 'info' ? '#4682b4' : liaTheme.accent;
              return (
                  <div className="relative w-full h-full overflow-hidden rounded-[10px] flex items-center px-3 gap-2 border" style={{ backgroundColor: liaTheme.background_panelpopup, borderColor: liaTheme.focus_panel, color: liaTheme.text }}>
                      <div className="absolute left-0 top-0 bottom-0 w-[5px]" style={{ backgroundColor: accent }} />
                      <div className="w-3 h-3 rounded-full ml-1 shrink-0" style={{ backgroundColor: accent }} />
                      {editableText(el, el.props.text || 'Notification', `${baseText} truncate`, { color: liaTheme.text })}
                      <span className="ml-auto text-[7px] uppercase text-slate-500">{type}</span>
                  </div>
              );
          }
          if (liaDefinition.preview === 'noticePanel') {
              return (
                  <div className="relative w-full h-full overflow-hidden border flex items-center justify-center" style={{ backgroundColor: liaTheme.background_alpha, borderColor: liaTheme.accent, color: liaTheme.text }}>
                      <div className="absolute left-0 top-0 bottom-0 w-[34%] opacity-25" style={{ backgroundColor: liaTheme.accent }} />
                      <div className="relative z-10 max-w-[90%] text-slate-100 text-center truncate">
                          {editableText(el, el.props.text || 'Timed Notice', `${baseText}`, { color: liaTheme.text })}
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'voice') {
              const voiceLevel = Math.max(0, Math.min(1, Number(option('voiceLevel', 0.7))));
              const voiceType = String(option('voiceType', 'talking'));
              const voiceColor = voiceType === 'yelling' ? '#eb8226' : voiceType === 'whispering' ? '#be82f5' : liaTheme.accent;
              const activeBars = Math.max(1, Math.ceil(voiceLevel * 6));
              return (
                  <div className="relative w-full h-full overflow-hidden rounded-lg border px-[18px] py-2" style={{ backgroundColor: liaTheme.background_panelpopup, borderColor: liaTheme.accent, color: liaTheme.text }}>
                      <div className="absolute left-0 top-[9px] bottom-[9px] w-[3px]" style={{ backgroundColor: voiceColor }} />
                      <div className="pr-[88px]">
                          <div className="text-[12px] font-semibold truncate" style={{ color: liaTheme.text }}>Local Player</div>
                          <div className="text-[10px] capitalize truncate" style={{ color: voiceColor }}>{voiceType}</div>
                      </div>
                      <div className="absolute right-[18px] top-1/2 -translate-y-1/2 h-[34px] flex items-center gap-[5px]">
                          {Array.from({ length: 6 }).map((_, index) => (
                              <div
                                  key={index}
                                  className="w-[5px] rounded-full"
                                  style={{
                                      height: `${10 + ((index + 1) / 6) * 24}px`,
                                      backgroundColor: index < activeBars ? voiceColor : liaTheme.gray,
                                      opacity: index < activeBars ? 0.95 : 0.25,
                                  }}
                              />
                          ))}
                      </div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'lockCircle') {
              const uppercase = Boolean(option('uppercase', true));
              const duration = Number(option('duration', 8));
              const holdTime = Number(option('holdTime', 1));
              const startAngle = Number(option('startAngle', -90));
              const progress = 0.68;
              const radius = Math.max(34, Math.min(el.props.w, el.props.h) * 0.27);
              const thickness = Math.max(8, radius * 0.24);
              const label = uppercase ? String(el.props.text || 'Testing').toUpperCase() : String(el.props.text || 'Testing');
              return (
                  <div className="relative w-full h-full flex flex-col items-center justify-center overflow-hidden" style={{ backgroundColor: liaTheme.background_alpha, color: liaTheme.text }}>
                      <div
                          className="relative rounded-full flex items-center justify-center"
                          style={{
                              width: `${radius * 2}px`,
                              height: `${radius * 2}px`,
                              background: `conic-gradient(from ${startAngle}deg, ${liaTheme.accent} 0deg ${360 * progress}deg, ${liaTheme.focus_panel} ${360 * progress}deg 360deg)`,
                          }}
                      >
                          <div className="rounded-full flex items-center justify-center font-bold" style={{ width: `${radius * 2 - thickness * 2}px`, height: `${radius * 2 - thickness * 2}px`, backgroundColor: liaTheme.background_panelpopup, color: liaTheme.text }}>
                              {Math.round(progress * 100)}%
                          </div>
                      </div>
                      <div className="mt-3 text-[10px] font-semibold tracking-wide max-w-[90%] truncate">{editableText(el, label, `${baseText}`, { color: liaTheme.text })}</div>
                      <div className="mt-1 text-[8px]" style={{ color: liaTheme.gray }}>{duration}s + {holdTime}s hold</div>
                  </div>
              );
          }
          if (liaDefinition.preview === 'dermaMenu') {
              const rawItems = String(option('items', ''));
              const minimumWidth = Math.max(120, Number(option('minimumWidth', 120)));
              const drawBorder = Boolean(option('drawBorder', false));
              const drawColumn = Boolean(option('drawColumn', false));
              const items = rawItems.split(/\r?\n/).map(line => line.trim()).filter(Boolean);
              return (
                  <div
                      className="w-full h-full overflow-hidden rounded-[14px] p-[7px] shadow-xl"
                      style={{
                          minWidth: `${Math.min(minimumWidth, el.props.w)}px`,
                          backgroundColor: liaTheme.background_panelpopup,
                          border: `1px solid ${drawBorder ? liaTheme.accent : liaTheme.focus_panel}`,
                          color: liaTheme.text,
                      }}
                  >
                      <div className="h-[2px] rounded-full mx-1 mb-1.5 opacity-70" style={{ backgroundColor: liaTheme.accent }} />
                      <div className="space-y-0.5">
                          {items.slice(0, 6).map((line, index) => {
                              if (line.toLowerCase().startsWith('#spacer')) return <div key={`${line}-${index}`} className="h-px my-1.5 mx-1" style={{ backgroundColor: liaTheme.focus_panel }} />;
                              const [label, icon] = line.split('|').map(part => part.trim());
                              return (
                                  <div key={`${line}-${index}`} className="h-[26px] rounded-md px-2 flex items-center gap-2 text-[10px]" style={{ backgroundColor: index === 0 ? liaTheme.hover : 'transparent', color: liaTheme.text }}>
                                      {(drawColumn || icon) && <div className="w-4 h-4 rounded-sm shrink-0 opacity-60" style={{ backgroundColor: icon ? liaTheme.accent : 'transparent' }} title={icon} />}
                                      <span className="truncate">{label}</span>
                                      {label.toLowerCase().includes('submenu') && <span className="ml-auto" style={{ color: liaTheme.header_text }}>▶</span>}
                                  </div>
                              );
                          })}
                      </div>
                  </div>
              );
          }
      }

      switch (el.type) {
          case ComponentType.DFrame: {
              const paintFrame = el.props.framePaintBackground !== false;
              const titleColor = el.props.titleBarColor || '#2a2a2a';
              const blurStyle: React.CSSProperties = el.props.frameBackgroundBlur
                  ? { boxShadow: '0 0 0 2px rgba(0,0,0,0.6), 0 8px 32px rgba(0,0,0,0.6)', backdropFilter: 'blur(2px)' }
                  : {};
              return (
                  <div
                      className="flex flex-col h-full w-full"
                      style={{
                          ...commonStyle,
                          backgroundColor: paintFrame ? (bgColor || '#323232') : 'transparent',
                          overflow: 'hidden',
                          boxShadow: paintFrame ? '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)' : undefined,
                          ...blurStyle
                      }}
                  >
                      <div
                        className={`h-6 flex items-center px-2 shrink-0 dframe-titlebar gap-1.5 ${paintFrame ? 'border-b border-black/40' : ''}`}
                        style={{ backgroundColor: paintFrame ? titleColor : 'transparent' }}
                      >
                          {el.props.frameIcon && (
                              <span
                                  className="inline-block bg-yellow-200 border border-yellow-600 shrink-0"
                                  style={{ width: 14, height: 14 }}
                                  title={el.props.frameIcon}
                              />
                          )}
                          {editableText(el, el.props.text || 'DFrame', `${baseText} text-white/90 font-bold`, titleBarStyle)}
                          <div className="ml-auto flex gap-1 opacity-60">
                              <div className="w-3 h-3 bg-white/10 rounded-sm hover:bg-white/20"></div>
                              {el.props.showCloseButton !== false && (
                                <div
                                    className="w-3 h-3 bg-white/10 rounded-sm hover:bg-red-500/80 cursor-pointer pointer-events-auto"
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        if (onDeleteElement) onDeleteElement(el.id);
                                    }}
                                    title="Close"
                                ></div>
                              )}
                          </div>
                      </div>
                      <div className="flex-1 relative overflow-hidden bg-transparent">
                          {/* Children area */}
                      </div>
                  </div>
              );
          }
          
          case ComponentType.DButton: {
              // Default Derma skin paints DButton light gray with dark text.
              // Custom `color` prop overrides bg; text color is auto-derived
              // from the resulting bg luminance so it stays readable across
              // both light defaults and user-set dark themes.
              const disabled = el.props.buttonEnabled === false;
              const buttonBg = bgColor
                  ?? (disabled ? SKIN_DEFAULTS.buttonDisabled
                              : (isHovered ? SKIN_DEFAULTS.buttonHover : SKIN_DEFAULTS.buttonNormal));
              const buttonText = getReadableTextColor(buttonBg);
              return (
                  <div
                      className="w-full h-full border border-black/50 flex items-center shadow-[inset_0_1px_0_rgba(255,255,255,0.1)] px-2 gap-1.5"
                      style={{
                          ...commonStyle,
                          backgroundColor: buttonBg,
                          opacity: disabled ? 0.5 : (commonStyle.opacity ?? 1),
                          cursor: disabled ? 'not-allowed' : 'pointer',
                      }}
                      title={el.props.buttonConsoleCommand ? `console: ${el.props.buttonConsoleCommand}` : undefined}
                  >
                      {el.props.buttonIcon && (
                          <span
                              className="inline-block bg-yellow-200 border border-yellow-600 shrink-0"
                              style={{ width: 14, height: 14 }}
                              title={el.props.buttonIcon}
                          />
                      )}
                      {editableText(el, el.props.text || 'Button', `${baseText} w-full text-center`, { ...commonStyle, color: buttonText })}
                  </div>
              );
          }
          
          case ComponentType.DTextEntry: {
              const textColor = el.props.entryTextColor || 'black';
              const isMulti = !!el.props.entryMultiline;
              const value = el.props.text || '';
              const placeholder = el.props.entryPlaceholderText || '';
              const showPlaceholder = !value && placeholder && editingId !== el.id;
              const showCursor = !value && !placeholder && editingId !== el.id && !isMulti;

              if (isMulti) {
                  // Multi-line preview: bounded text area, top-aligned, wraps text.
                  return (
                      <div
                          className="w-full h-full bg-white border border-neutral-400 shadow-inner overflow-hidden"
                          style={{ borderRadius: commonStyle.borderRadius }}
                      >
                          <div
                              style={{
                                  width: '100%',
                                  height: '100%',
                                  padding: '4px 6px',
                                  whiteSpace: 'pre-wrap',
                                  overflowY: 'auto',
                                  fontFamily: commonStyle.fontFamily,
                                  fontSize: commonStyle.fontSize,
                                  color: showPlaceholder ? '#999' : textColor,
                              }}
                          >
                              {showPlaceholder ? placeholder : (value || ' ')}
                          </div>
                      </div>
                  );
              }

              // Single-line (existing behavior + placeholder + textColor)
              return (
                  <div className="w-full h-full bg-white border border-neutral-400 flex items-center px-1.5 shadow-inner" style={{borderRadius: commonStyle.borderRadius}}>
                      {showPlaceholder ? (
                          <span className={`${baseText} truncate w-full`} style={{ color: '#999', fontFamily: commonStyle.fontFamily, fontSize: commonStyle.fontSize }}>{placeholder}</span>
                      ) : (
                          editableText(el, value, `${baseText} truncate w-full`, {...commonStyle, backgroundColor: 'transparent', borderWidth: 0, color: textColor})
                      )}
                      {showCursor && <div className="w-[1px] h-3 bg-black animate-pulse"></div>}
                  </div>
              );
          }
          
          case ComponentType.DCheckBox:
              return (
                  <div className="flex items-center gap-1.5 h-full" style={{opacity: commonStyle.opacity}}>
                      <div className="w-4 h-4 bg-white border border-neutral-400 flex items-center justify-center shadow-sm shrink-0">
                          {el.props.checked && <div className="w-2.5 h-2.5 bg-[#3399FF] shadow-sm"></div>}
                      </div>
                      {editableText(el, el.props.text || 'CheckBox', `${baseText} text-white`, {fontFamily: commonStyle.fontFamily, fontSize: commonStyle.fontSize, fontWeight: commonStyle.fontWeight})}
                  </div>
              );

          case ComponentType.DLabel:
               // Font is already resolved into commonStyle by resolveDermaFont above.
               // Text color: explicit `labelTextColor` wins; otherwise derive a
               // readable color from the parent's effective background. Falls
               // back to white only if there's no parent at all.
               {
                   const parentBg = getEffectiveParentBg(el, state.elements);
                   const labelColor = el.props.labelTextColor
                       ?? (parentBg ? getReadableTextColor(parentBg) : '#ffffff');
                   const labelStyle: React.CSSProperties = {
                       ...commonStyle,
                       color: labelColor,
                   };
                   return (
                       <div className="w-full h-full flex items-center" style={{ ...commonStyle, backgroundColor: 'transparent', border: 'none' }}>
                            {editableText(el, el.props.text || 'Label', baseText, labelStyle)}
                       </div>
                   );
               }
               
          case ComponentType.DImage:
              return (
                  <div className="w-full h-full overflow-hidden relative" style={commonStyle}>
                      {el.props.imageUrl ? (
                          <>
                            {/* Wrapper for tinting using blend mode */}
                            <div className="absolute inset-0 z-0" style={{ backgroundColor: el.props.imageColor || 'transparent' }}>
                                <img 
                                    src={el.props.imageUrl} 
                                    alt="DImage" 
                                    className="w-full h-full object-cover pointer-events-none" 
                                    style={{ mixBlendMode: el.props.imageColor ? 'multiply' : 'normal' }}
                                />
                            </div>
                          </>
                      ) : (
                          <div className="w-full h-full flex flex-col items-center justify-center bg-neutral-800 text-neutral-600 border border-dashed border-neutral-700">
                             <ImageOff className="w-6 h-6 mb-1 opacity-50" />
                             <span className="text-[9px]">No Image</span>
                          </div>
                      )}
                  </div>
              );
          
          case ComponentType.DModelPanel:
              return (
                  <div className="w-full h-full bg-[#1a1a1a] border border-neutral-700 flex flex-col items-center justify-center relative overflow-hidden" style={commonStyle}>
                       <Cuboid className="w-8 h-8 text-neutral-600 mb-2 opacity-50" />
                       <span className="text-[9px] text-neutral-500 font-mono text-center px-1 break-all">{el.props.modelPath || "No Model"}</span>
                       <div className="absolute top-1 right-1 text-[8px] text-neutral-600">3D</div>
                  </div>
              );
              
          case ComponentType.DForm:
              return (
                  <div className="w-full h-full bg-white flex flex-col border border-neutral-400 rounded-sm" style={commonStyle}>
                       <div className="bg-neutral-200 border-b border-neutral-300 px-2 py-1">
                           {editableText(el, el.props.text || 'Form', 'text-black text-[10px] font-bold', { color: 'black' })}
                       </div>
                       <div className="flex-1 bg-white p-1">
                           {/* Form content goes here */}
                       </div>
                  </div>
              );

          case ComponentType.DPanel: {
              // Default Derma skin paints DPanel light gray (#f0f0f0). Users
              // override via the `color` prop for dark themes.
              const paintBg = el.props.panelPaintBackground !== false;
              const disabled = el.props.panelDisabled === true;
              return (
                  <div
                    className="w-full h-full"
                    style={{
                      ...commonStyle,
                      backgroundColor: paintBg ? (bgColor || SKIN_DEFAULTS.panel) : 'transparent',
                      border: paintBg
                          ? (el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.3)')
                          : '1px dashed rgba(255,255,255,0.15)',
                      opacity: disabled ? 0.5 : (commonStyle.opacity ?? 1),
                    }}
                  />
              );
          }

          case ComponentType.DScrollPanel:
          case ComponentType.DTab:
          // DTab usually renders as a panel inside the sheet content area
              return (
                  <div
                    className="w-full h-full border border-black/30"
                    style={{ ...commonStyle, backgroundColor: bgColor || SKIN_DEFAULTS.panel }}
                  >
                  </div>
              );

          case ComponentType.DComboBox:
              return (
                  <div className="w-full h-full bg-[#505050] border border-black/50 flex items-center justify-between px-2 shadow-[inset_0_1px_0_rgba(255,255,255,0.1)]" style={commonStyle}>
                      {editableText(el, el.props.text || 'Select...', `${baseText} text-white`, {})}
                      <div className="w-0 h-0 border-l-[4px] border-l-transparent border-r-[4px] border-r-transparent border-t-[5px] border-t-white/80"></div>
                  </div>
              );
          
          case ComponentType.DPropertySheet:
              return (
                  <div className="w-full h-full bg-[#383838] flex flex-col" style={commonStyle}>
                      {/* Fake Tab Bar */}
                      <div className="flex px-1 pt-1 gap-1 overflow-hidden">
                          {/* Render fake tabs based on children DTabs */}
                          {el.children.map(childId => {
                               const child = state.elements[childId];
                               if (child.type === ComponentType.DTab) {
                                   return (
                                       <div key={childId} className="bg-[#f0f0f0] text-black text-[10px] px-2 py-0.5 rounded-t-sm border-t border-l border-r border-neutral-400 flex items-center gap-1">
                                           {child.props.imageUrl && <div className="w-3 h-3 bg-neutral-400 rounded-full" />}
                                           {child.props.text || "Tab"}
                                       </div>
                                   );
                               }
                               return null;
                          })}
                          {el.children.filter(c => state.elements[c].type === ComponentType.DTab).length === 0 && (
                              <div className="bg-[#f0f0f0] text-black text-[10px] px-2 py-0.5 rounded-t-sm border-t border-l border-r border-neutral-400 opacity-50">Empty Sheet</div>
                          )}
                      </div>
                      <div className="flex-1 bg-[#f0f0f0] border border-neutral-400 rounded-b-sm m-1 mt-0 relative p-1">
                          {/* Children area for sheet content */}
                      </div>
                  </div>
              );

          case ComponentType.DListView: {
              // Drive headers + rows from props instead of hardcoded placeholders.
              const cols = (el.props.listColumns ?? 'Name,Value').split(',').map(s => s.trim()).filter(Boolean);
              const rows = (el.props.listRows ?? '').split('\n').filter(l => l.trim().length > 0).map(line =>
                  line.split(',').map(s => s.trim())
              );
              const showHeaders = !el.props.listHideHeaders;
              return (
                  <div className="w-full h-full bg-white border border-neutral-400 flex flex-col shadow-inner overflow-hidden" style={{ ...commonStyle, backgroundColor: 'white' }}>
                      {/* Header */}
                      {showHeaders && (
                        <div className="h-5 bg-gradient-to-b from-[#f0f0f0] to-[#d0d0d0] border-b border-[#a0a0a0] flex shrink-0">
                            {cols.map((c, i) => (
                                <div key={i} className={`flex-1 ${i < cols.length - 1 ? 'border-r border-[#a0a0a0]' : ''} px-1 flex items-center`}>
                                    <span className="text-[10px] text-black/80 font-medium truncate">{c}</span>
                                </div>
                            ))}
                        </div>
                      )}
                      {/* Rows */}
                      <div className="flex-1 bg-white flex flex-col overflow-y-auto">
                          {rows.map((row, ri) => (
                              <div key={ri} className={`flex h-4 hover:bg-[#3399FF] hover:text-white text-black ${ri % 2 === 1 ? 'bg-[#f5f5f5]' : ''}`}>
                                  {cols.map((_, ci) => (
                                      <div key={ci} className="flex-1 px-1 flex items-center truncate text-[10px]">{row[ci] ?? ''}</div>
                                  ))}
                              </div>
                          ))}
                      </div>
                  </div>
              );
          }

          case ComponentType.DBevel:
              // Beveled panel: dark fill with chiseled inset lines (top-left shadow,
              // bottom-right highlight). Uses inset box-shadow to fake the chisel.
              return (
                  <div
                    className="w-full h-full"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || '#2a2a2a',
                      boxShadow: 'inset 1px 1px 0 rgba(0,0,0,0.6), inset -1px -1px 0 rgba(255,255,255,0.06)',
                    }}
                  />
              );

          case ComponentType.DProgress: {
              const frac = Math.max(0, Math.min(1, el.props.progressFraction ?? 0));
              const fillColor = el.props.color || '#3399FF';
              return (
                  <div
                    className="w-full h-full overflow-hidden"
                    style={{
                      ...commonStyle,
                      backgroundColor: '#1a1a1a',
                      border: '1px solid #000',
                      borderRadius: el.props.borderRadius ? `${el.props.borderRadius}px` : '2px',
                      boxShadow: 'inset 0 1px 2px rgba(0,0,0,0.6)',
                    }}
                  >
                    <div
                      style={{
                        width: `${frac * 100}%`,
                        height: '100%',
                        background: `linear-gradient(to bottom, ${fillColor}, ${fillColor}cc)`,
                        transition: 'width 0.15s ease-out',
                      }}
                    />
                  </div>
              );
          }

          case ComponentType.DSlider: {
              // 1D-horizontal default. If sliderLockY is set we treat as 1D-vertical.
              // Otherwise honor both axes.
              const sx = Math.max(0, Math.min(1, el.props.sliderLockX ?? el.props.sliderX ?? 0.5));
              const sy = Math.max(0, Math.min(1, el.props.sliderLockY ?? el.props.sliderY ?? 0.5));
              const knobSize = 12;
              return (
                  <div
                    className="w-full h-full relative"
                    style={{
                      ...commonStyle,
                      backgroundColor: '#1f1f1f',
                      border: '1px solid #000',
                      borderRadius: '2px',
                      boxShadow: 'inset 0 1px 2px rgba(0,0,0,0.6)',
                    }}
                  >
                    {/* Center track line */}
                    <div className="absolute left-1 right-1 top-1/2 h-px bg-neutral-700 -translate-y-1/2" />
                    {/* Knob */}
                    <div
                      style={{
                        position: 'absolute',
                        width: knobSize,
                        height: knobSize,
                        left: `calc(${sx * 100}% - ${sx * knobSize}px)`,
                        top: `calc(${sy * 100}% - ${sy * knobSize}px)`,
                        background: 'linear-gradient(to bottom, #707070, #4a4a4a)',
                        border: '1px solid #000',
                        borderRadius: '2px',
                        boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.15)',
                      }}
                    />
                  </div>
              );
          }

          case ComponentType.DNumSlider: {
              const min = el.props.sliderMin ?? 0;
              const max = el.props.sliderMax ?? 100;
              const val = el.props.sliderValue ?? min;
              const decimals = el.props.sliderDecimals ?? 0;
              const range = max - min;
              const frac = range > 0 ? Math.max(0, Math.min(1, (val - min) / range)) : 0;
              const knobSize = 10;
              return (
                  <div
                    className="w-full h-full flex items-center gap-1.5 px-1"
                    style={{ ...commonStyle, backgroundColor: 'transparent' }}
                  >
                    {/* Label */}
                    <div className="text-[11px] text-white text-right shrink-0" style={{ minWidth: 60, fontFamily: commonStyle.fontFamily, fontSize: commonStyle.fontSize }}>
                      {editableText(el, el.props.text || 'Slider', 'text-[11px] text-white', { fontFamily: commonStyle.fontFamily, fontSize: commonStyle.fontSize, textAlign: 'right' })}
                    </div>
                    {/* Track */}
                    <div className="relative flex-1 h-3 bg-[#1f1f1f] border border-black rounded-sm" style={{ boxShadow: 'inset 0 1px 2px rgba(0,0,0,0.6)' }}>
                      <div className="absolute left-1 right-1 top-1/2 h-px bg-neutral-700 -translate-y-1/2" />
                      <div
                        style={{
                          position: 'absolute',
                          width: knobSize,
                          height: knobSize,
                          left: `calc(${frac * 100}% - ${frac * knobSize}px)`,
                          top: '50%',
                          transform: 'translateY(-50%)',
                          background: 'linear-gradient(to bottom, #707070, #4a4a4a)',
                          border: '1px solid #000',
                          borderRadius: '2px',
                        }}
                      />
                    </div>
                    {/* Number entry */}
                    <div
                      className="bg-white border border-neutral-400 px-1 text-black text-[10px] text-center shrink-0"
                      style={{ minWidth: 40, lineHeight: '14px', fontFamily: 'monospace' }}
                    >
                      {val.toFixed(decimals)}
                    </div>
                  </div>
              );
          }

          case ComponentType.DImageButton: {
              const fitClass =
                el.props.imageKeepAspect ? 'object-contain' :
                (el.props.imageStretchToFit !== false) ? 'object-fill' :
                'object-none';
              return (
                  <div
                    className="w-full h-full overflow-hidden relative cursor-pointer"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || (isHovered ? '#3a3a3a' : '#2a2a2a'),
                      border: el.props.borderWidth ? commonStyle.border : '1px solid #000',
                      borderRadius: el.props.borderRadius ? `${el.props.borderRadius}px` : undefined,
                    }}
                  >
                    {el.props.imageUrl ? (
                      <div className="absolute inset-0" style={{ backgroundColor: el.props.imageColor || 'transparent' }}>
                        <img
                          src={el.props.imageUrl}
                          alt="DImageButton"
                          className={`w-full h-full ${fitClass} pointer-events-none`}
                          style={{ mixBlendMode: el.props.imageColor ? 'multiply' : 'normal' }}
                        />
                      </div>
                    ) : (
                      <div className="w-full h-full flex flex-col items-center justify-center bg-neutral-800 text-neutral-600 border border-dashed border-neutral-700">
                        <ImageOff className="w-5 h-5 mb-1 opacity-50" />
                        <span className="text-[9px]">No Image</span>
                      </div>
                    )}
                  </div>
              );
          }

          case ComponentType.DCollapsibleCategory: {
              const headerH = el.props.headerHeight ?? 20;
              const expanded = el.props.expanded !== false;
              return (
                  <div
                    className="w-full h-full overflow-hidden"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || '#2a2a2a',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.4)',
                    }}
                  >
                    {/* Header bar */}
                    <div
                      style={{
                        height: headerH,
                        background: 'linear-gradient(to bottom, #4a4a4a, #383838)',
                        borderBottom: '1px solid rgba(0,0,0,0.5)',
                        display: 'flex',
                        alignItems: 'center',
                        paddingLeft: 6,
                        paddingRight: 6,
                      }}
                    >
                      <div style={{ flex: 1, minWidth: 0 }}>
                        {editableText(el, el.props.text || 'Category', 'text-[11px] text-white font-bold', { fontFamily: commonStyle.fontFamily, fontSize: commonStyle.fontSize })}
                      </div>
                      <span className="text-[10px] text-white/70 select-none ml-1">{expanded ? '▼' : '▶'}</span>
                    </div>
                    {/* Content area marker (real children render in absolute children container) */}
                    {!expanded && (
                      <div className="w-full" style={{ height: `calc(100% - ${headerH}px)`, background: 'repeating-linear-gradient(45deg, transparent, transparent 8px, rgba(255,255,255,0.02) 8px, rgba(255,255,255,0.02) 16px)' }} />
                    )}
                  </div>
              );
          }

          case ComponentType.DRichText: {
              const showScroll = el.props.richScrollbar !== false;
              const lines = (el.props.text ?? '').split('\n');
              return (
                  <div
                    className="w-full h-full bg-white border border-neutral-400 shadow-inner"
                    style={{ ...commonStyle, backgroundColor: 'white', borderRadius: commonStyle.borderRadius }}
                  >
                    <div
                      style={{
                        width: '100%',
                        height: '100%',
                        padding: 4,
                        overflowY: showScroll ? 'auto' : 'hidden',
                        overflowX: 'hidden',
                        whiteSpace: 'pre-wrap',
                        color: 'black',
                        fontFamily: commonStyle.fontFamily || 'Arial, sans-serif',
                        fontSize: commonStyle.fontSize || '11px',
                        lineHeight: 1.3,
                      }}
                    >
                      {lines.map((line, i) => <div key={i}>{line || ' '}</div>)}
                    </div>
                  </div>
              );
          }

          case ComponentType.DBinder:
              // Looks like a DButton showing the bound key name.
              return (
                  <div
                    className="w-full h-full border border-black/50 flex items-center justify-center"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || (isHovered ? '#606060' : '#505050'),
                      boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.1)',
                    }}
                  >
                    <span className="text-[11px] text-white font-mono select-none" style={{ fontFamily: commonStyle.fontFamily, fontSize: commonStyle.fontSize }}>
                      {el.props.binderKey || 'NONE'}
                    </span>
                  </div>
              );

          case ComponentType.DNumberWang: {
              const min = el.props.sliderMin ?? 0;
              const max = el.props.sliderMax ?? 100;
              const val = Math.max(min, Math.min(max, el.props.sliderValue ?? 0));
              const decimals = el.props.sliderDecimals ?? 0;
              return (
                  <div
                    className="w-full h-full bg-white border border-neutral-400 flex items-stretch shadow-inner"
                    style={{ ...commonStyle, backgroundColor: 'white', borderRadius: commonStyle.borderRadius }}
                  >
                    <div className="flex-1 flex items-center px-1.5" style={{ minWidth: 0 }}>
                      <span className="text-[11px] text-black font-mono w-full" style={{ textAlign: 'left' }}>
                        {val.toFixed(decimals)}
                      </span>
                    </div>
                    {/* Up/Down stack */}
                    <div className="flex flex-col border-l border-neutral-400" style={{ width: 14 }}>
                      <div className="flex-1 flex items-center justify-center bg-neutral-200 border-b border-neutral-400 text-black text-[8px] leading-none select-none">▲</div>
                      <div className="flex-1 flex items-center justify-center bg-neutral-200 text-black text-[8px] leading-none select-none">▼</div>
                    </div>
                  </div>
              );
          }

          case ComponentType.DVerticalDivider: {
              const topH = el.props.dividerTopHeight ?? 100;
              const dh = el.props.dividerHeight ?? 4;
              return (
                  <div
                    className="w-full h-full overflow-hidden relative"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || '#252525',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.5)',
                    }}
                  >
                    {/* Top zone */}
                    <div className="absolute left-0 right-0 top-0" style={{ height: topH, background: 'rgba(255,255,255,0.025)' }}>
                      <span className="absolute top-1 left-1 text-[8px] text-neutral-600 font-mono uppercase tracking-wider">Top</span>
                    </div>
                    {/* Divider bar */}
                    <div
                      className="absolute left-0 right-0 cursor-ns-resize"
                      style={{
                        top: topH,
                        height: dh,
                        background: 'linear-gradient(to bottom, #5a5a5a, #3a3a3a)',
                        borderTop: '1px solid rgba(0,0,0,0.6)',
                        borderBottom: '1px solid rgba(0,0,0,0.6)',
                      }}
                    />
                    {/* Bottom zone */}
                    <div className="absolute left-0 right-0 bottom-0" style={{ top: topH + dh, background: 'rgba(255,255,255,0.025)' }}>
                      <span className="absolute top-1 left-1 text-[8px] text-neutral-600 font-mono uppercase tracking-wider">Bottom</span>
                    </div>
                  </div>
              );
          }

          case ComponentType.DColorMixer: {
              const showAlpha = el.props.mixerShowAlphaBar !== false;
              const showPalette = el.props.mixerShowPalette !== false;
              const showWangs = el.props.mixerShowWangs !== false;
              const c = el.props.mixerColor || '#ff8000';
              const a = el.props.mixerAlpha ?? 255;
              const r = parseInt(c.slice(1, 3), 16);
              const g = parseInt(c.slice(3, 5), 16);
              const b = parseInt(c.slice(5, 7), 16);
              return (
                  <div
                    className="w-full h-full overflow-hidden flex flex-col"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || '#2a2a2a',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.5)',
                      padding: 4,
                      gap: 4,
                    }}
                  >
                    {/* Top row: cube + alpha + wangs */}
                    <div className="flex gap-1" style={{ flex: showPalette ? '1 1 60%' : '1 1 100%', minHeight: 0 }}>
                      {/* Color cube area (sat × value gradient) */}
                      <div
                        className="relative"
                        style={{
                          flex: 1,
                          minWidth: 0,
                          background: `linear-gradient(to top, black, transparent), linear-gradient(to right, white, ${c})`,
                          border: '1px solid rgba(0,0,0,0.6)',
                        }}
                      >
                        {/* Crosshair indicator */}
                        <div className="absolute" style={{ left: '50%', top: '50%', width: 6, height: 6, transform: 'translate(-50%, -50%)', border: '1px solid white', borderRadius: '50%', boxShadow: '0 0 0 1px black' }} />
                      </div>
                      {showAlpha && (
                        <div
                          style={{
                            width: 10,
                            background: `linear-gradient(to bottom, ${c}, transparent), repeating-conic-gradient(#ccc 0 25%, white 0 50%) 50% / 6px 6px`,
                            border: '1px solid rgba(0,0,0,0.6)',
                          }}
                        />
                      )}
                      {showWangs && (
                        <div className="flex flex-col gap-0.5" style={{ width: 30 }}>
                          {[r, g, b, a].map((v, i) => (
                            <div key={i} className="bg-white border border-neutral-400 flex-1 flex items-center justify-center text-[8px] text-black font-mono" style={{ minHeight: 0 }}>
                              {v}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                    {/* Bottom row: palette swatches */}
                    {showPalette && (
                      <div className="flex flex-wrap gap-0.5" style={{ flex: '0 0 auto', maxHeight: 36 }}>
                        {['#ffffff','#ff0000','#ffa500','#ffff00','#00ff00','#00ffff','#0080ff','#0000ff','#800080','#ff00ff','#ffc0cb','#a52a2a','#808080','#000000'].map((sw, i) => (
                          <div key={i} style={{ width: 12, height: 12, background: sw, border: '1px solid rgba(0,0,0,0.4)' }} />
                        ))}
                      </div>
                    )}
                    {/* Optional label */}
                    {el.props.mixerLabel && (
                      <div className="text-[9px] text-neutral-300 text-center" style={{ flex: '0 0 auto' }}>{el.props.mixerLabel}</div>
                    )}
                  </div>
              );
          }

          case ComponentType.DColorCube: {
              const base = el.props.cubeBaseColor || '#ff0000';
              const sx = Math.max(0, Math.min(1, el.props.sliderX ?? 0.5));
              const sy = Math.max(0, Math.min(1, el.props.sliderY ?? 0.5));
              return (
                  <div
                    className="w-full h-full relative"
                    style={{
                      ...commonStyle,
                      background: `linear-gradient(to top, black, transparent), linear-gradient(to right, white, ${base})`,
                      border: el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.6)',
                    }}
                  >
                    {/* Crosshair */}
                    <div
                      style={{
                        position: 'absolute',
                        left: `${sx * 100}%`,
                        top: `${(1 - sy) * 100}%`,
                        width: 8, height: 8,
                        transform: 'translate(-50%, -50%)',
                        border: '1px solid white',
                        borderRadius: '50%',
                        boxShadow: '0 0 0 1px black',
                        pointerEvents: 'none',
                      }}
                    />
                  </div>
              );
          }

          case ComponentType.DColorPalette: {
              const swatchHex = (el.props.paletteColors || '').split(',').map(s => s.trim()).filter(Boolean);
              const size = el.props.paletteButtonSize ?? 16;
              return (
                  <div
                    className="w-full h-full overflow-hidden p-0.5"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || '#1a1a1a',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.4)',
                    }}
                  >
                    <div className="flex flex-wrap" style={{ gap: 2 }}>
                      {swatchHex.map((hex, i) => (
                        <div
                          key={i}
                          style={{
                            width: size,
                            height: size,
                            background: hex,
                            border: '1px solid rgba(0,0,0,0.5)',
                          }}
                          title={hex}
                        />
                      ))}
                    </div>
                  </div>
              );
          }

          case ComponentType.DSysButton: {
              const t = el.props.sysButtonType || 'close';
              const glyph = t === 'close' ? '✕' : t === 'minim' ? '–' : t === 'maxim' ? '□' : '↗';
              const hoverColor = t === 'close' ? '#dc2626' : '#606060';
              return (
                  <div
                    className="w-full h-full flex items-center justify-center select-none"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || (isHovered ? hoverColor : '#3a3a3a'),
                      border: el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.5)',
                      color: 'white',
                      fontSize: 10,
                      fontFamily: 'monospace',
                      lineHeight: 1,
                    }}
                  >
                    {glyph}
                  </div>
              );
          }

          case ComponentType.DHTML: {
              const url = el.props.htmlUrl || '';
              const hasContent = !!el.props.htmlContent;
              return (
                  <div
                    className="w-full h-full overflow-hidden flex flex-col"
                    style={{
                      ...commonStyle,
                      backgroundColor: '#1a1a1a',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid rgba(0,0,0,0.5)',
                    }}
                  >
                    {/* URL bar */}
                    <div
                      className="flex items-center px-1.5 gap-1.5 text-[9px] text-neutral-300 font-mono shrink-0"
                      style={{ height: 18, background: '#2a2a2a', borderBottom: '1px solid rgba(0,0,0,0.6)' }}
                    >
                      <Globe className="w-2.5 h-2.5 opacity-60 shrink-0" />
                      <span className="truncate" title={url || '(inline content)'}>
                        {url || (hasContent ? '(inline content)' : 'about:blank')}
                      </span>
                    </div>
                    {/* Body */}
                    <div className="flex-1 overflow-hidden bg-white text-black text-[10px] font-mono p-1.5" style={{ overflowY: el.props.htmlScrollbars !== false ? 'auto' : 'hidden' }}>
                      {hasContent ? (
                        <pre className="whitespace-pre-wrap break-all">{el.props.htmlContent}</pre>
                      ) : (
                        <div className="w-full h-full flex flex-col items-center justify-center text-neutral-500">
                          <Globe className="w-6 h-6 opacity-40 mb-1" />
                          <span className="text-[9px]">DHTML preview</span>
                        </div>
                      )}
                    </div>
                  </div>
              );
          }

          case ComponentType.DTree: {
              // Parse indented text into nested rows. Two-space indent = one level.
              const text = el.props.treeNodes ?? '';
              const showIcons = el.props.treeShowIcons !== false;
              const indent = el.props.treeIndentSize ?? 16;
              const lineH = el.props.treeLineHeight ?? 17;
              const rows = text.split('\n').filter(l => l.trim().length > 0).map((line, i) => {
                  const leading = line.length - line.trimStart().length;
                  const level = Math.floor(leading / 2);
                  const trimmed = line.trim();
                  const [label, icon] = trimmed.split('|').map(s => s.trim());
                  return { i, level, label, icon };
              });
              return (
                  <div
                    className="w-full h-full overflow-auto"
                    style={{
                      ...commonStyle,
                      backgroundColor: 'white',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid #999',
                    }}
                  >
                    {rows.map(r => (
                      <div
                        key={r.i}
                        className="flex items-center hover:bg-blue-100"
                        style={{
                          height: lineH,
                          paddingLeft: 4 + r.level * indent,
                          fontSize: 11,
                          color: 'black',
                        }}
                      >
                        <span className="text-neutral-500 mr-1 select-none" style={{ fontSize: 9 }}>▸</span>
                        {showIcons && (
                          <span className="inline-block bg-yellow-200 border border-yellow-600 mr-1 shrink-0" style={{ width: 12, height: 12 }} title={r.icon || 'icon16/page.png'} />
                        )}
                        <span className="truncate">{r.label}</span>
                      </div>
                    ))}
                  </div>
              );
          }

          case ComponentType.DMenu: {
              const text = el.props.menuItems ?? '';
              const showIconCol = el.props.menuShowIconColumn !== false;
              const items = text.split('\n').map((line, i) => {
                  const trimmed = line.trim();
                  if (trimmed === '---') return { i, spacer: true } as const;
                  const [label, icon] = trimmed.split('|').map(s => s.trim());
                  return { i, spacer: false, label, icon } as const;
              });
              return (
                  <div
                    className="w-full h-full overflow-hidden flex flex-col"
                    style={{
                      ...commonStyle,
                      backgroundColor: '#3a3a3a',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid #000',
                      padding: 1,
                    }}
                  >
                    {items.map(it => it.spacer ? (
                        <div key={it.i} className="bg-neutral-600 my-1" style={{ height: 1 }} />
                    ) : (
                        <div
                          key={it.i}
                          className="flex items-center hover:bg-blue-600/70 px-1 cursor-default select-none"
                          style={{ height: 18, fontSize: 11, color: 'white' }}
                        >
                          {showIconCol && (
                            <span className="inline-block bg-yellow-200 border border-yellow-600 mr-1.5 shrink-0" style={{ width: 12, height: 12 }} title={it.icon || ''} />
                          )}
                          <span className="truncate">{it.label}</span>
                        </div>
                    ))}
                  </div>
              );
          }

          case ComponentType.DMenuBar: {
              const text = el.props.menuBarItems ?? '';
              const menus = text.split('\n').filter(l => l.trim().length > 0).map((line, i) => {
                  const colon = line.indexOf(':');
                  const label = colon === -1 ? line.trim() : line.slice(0, colon).trim();
                  return { i, label };
              });
              return (
                  <div
                    className="w-full h-full flex items-stretch overflow-hidden"
                    style={{
                      ...commonStyle,
                      background: bgColor || 'linear-gradient(to bottom, #f0f0f0, #d0d0d0)',
                      border: el.props.borderWidth ? commonStyle.border : '1px solid #888',
                    }}
                  >
                    {menus.map(m => (
                      <div
                        key={m.i}
                        className="px-2 flex items-center text-[11px] hover:bg-blue-200 cursor-default select-none"
                        style={{ color: 'black' }}
                      >
                        {m.label}
                      </div>
                    ))}
                  </div>
              );
          }

          case ComponentType.DGrid:
              // Container: children are rendered by the children container (overridden in renderElement)
              return (
                  <div
                    className="w-full h-full"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || 'transparent',
                      border: el.props.borderWidth ? commonStyle.border : '1px dashed rgba(255,255,255,0.1)',
                    }}
                  />
              );

          case ComponentType.DIconLayout:
              // Container with auto-flow children
              return (
                  <div
                    className="w-full h-full"
                    style={{
                      ...commonStyle,
                      backgroundColor: bgColor || 'transparent',
                      border: el.props.borderWidth ? commonStyle.border : '1px dashed rgba(255,255,255,0.1)',
                    }}
                  />
              );

          case ComponentType.DColumnSheet:
              return (
                  <div className="w-full h-full bg-[#383838] flex flex-row" style={commonStyle}>
                      {/* Vertical tab strip on the LEFT */}
                      <div className="flex flex-col gap-1 p-1 shrink-0" style={{ width: 80, background: '#2a2a2a', borderRight: '1px solid rgba(0,0,0,0.5)' }}>
                          {el.children.map(childId => {
                              const child = state.elements[childId];
                              if (child?.type === ComponentType.DTab) {
                                  return (
                                      <div key={childId} className="flex flex-col items-center justify-center bg-[#4a4a4a] hover:bg-[#5a5a5a] border border-black/40 text-[10px] text-white py-1 px-1 cursor-default select-none">
                                          {child.props.imageUrl && <div className="w-3 h-3 bg-yellow-200 border border-yellow-600 mb-0.5" />}
                                          <span className="truncate w-full text-center">{child.props.text || 'Tab'}</span>
                                      </div>
                                  );
                              }
                              return null;
                          })}
                          {el.children.filter(c => state.elements[c]?.type === ComponentType.DTab).length === 0 && (
                              <div className="text-[9px] text-neutral-500 text-center opacity-60">Add DTab children</div>
                          )}
                      </div>
                      {/* Content area on the RIGHT — children render here via the children container */}
                      <div className="flex-1 bg-[#f0f0f0] border border-neutral-400 m-1" />
                  </div>
              );

          default:
              return (
                  <div className="w-full h-full bg-[#2a2a2a] border border-dashed border-neutral-600 flex items-center justify-center" style={{opacity: commonStyle.opacity}}>
                      <span className="text-[10px] text-neutral-500 font-mono">{el.type}</span>
                  </div>
              );
      }
  };

  const renderElement = (id: string) => {
    const el = state.elements[id];
    if (!el) return null;

    const isSelected = state.selectedId === id;
    // An element is in the multi-selection if it's part of selectedIds. The PRIMARY
    // (selectedId) gets the strong blue outline; secondary multi-selected elements
    // get a lighter dashed outline so the primary remains visually distinguishable.
    const isMultiSelected = state.selectedIds.includes(id) && !isSelected;
    const isHovered = hoveredId === id;
    const parent = el.parentId ? state.elements[el.parentId] : null;
    const isAutoLayout = parent?.props.layoutMode && parent.props.layoutMode !== 'none';
    
    // Check if element is a Tab inside a sheet container (DPropertySheet horizontal, DColumnSheet vertical).
    const isTabInSheet = el.type === ComponentType.DTab && (parent?.type === ComponentType.DPropertySheet || parent?.type === ComponentType.DColumnSheet);

    // Apply Scale Transform if Hovered
    const scale = (isHovered && el.props.hoverScale) ? el.props.hoverScale : 1;
    
    // Simulate Dock behavior:
    const layoutWidth = (isAutoLayout && parent?.props.layoutMode === 'vertical') ? '100%' : el.props.w;
    const layoutHeight = (isAutoLayout && parent?.props.layoutMode === 'horizontal') ? '100%' : el.props.h;

    // DForm header fix: Auto-layout usually, but we want it to look like a form
    // If it's DForm, children stack vertically by default in GMod (DForm inherits DCollapsibleCategory/Panel which layouts children)
    // We can force auto-layout visual for DForm children if we want, but user controls it via props.
    
    let finalStyle: React.CSSProperties = {
      position: (isAutoLayout || isTabInSheet) ? 'relative' : 'absolute',
      left: (isAutoLayout || isTabInSheet) ? undefined : el.props.x,
      top: (isAutoLayout || isTabInSheet) ? undefined : el.props.y,
      width: isTabInSheet ? '100%' : layoutWidth,
      height: isTabInSheet ? '100%' : layoutHeight,
      zIndex: isSelected ? 10 : 1,
      transform: scale !== 1 ? `scale(${scale})` : undefined,
      transition: 'transform 0.1s ease-out',
      transformOrigin: 'center center',
      flexShrink: 0 
    };
    
    // DPropertySheet Children Handling
    // If element is DPropertySheet, its children (DTabs) should be rendered inside the content area.
    // We override children container style for PropertySheet.
    if (el.type === ComponentType.DPropertySheet) {
        // We need to target the content area div which is the second child of the main render
        // But here we wrap children. 
        // We will just let them render in the flow of the container div we created in renderVGUIContent?
        // No, renderVGUIContent returns a specific structure.
        // We need to Portal them? Or just use CSS grid/absolute?
        // Simplest: renderVGUIContent renders the *frame*, this children loop renders the contents.
        // We use absolute positioning for children inside the padding area.
    }
    
    const lockedEffectively = isEffectivelyLocked(id);

    const handleMouseDown = (e: React.MouseEvent) => {
      e.stopPropagation();
      // Ctrl/Cmd+Click toggles multi-selection without starting a drag.
      // Note: e.altKey is reserved for canvas pan (see startPan), so we don't
      // intercept it here.
      if (e.ctrlKey || e.metaKey) {
        if (e.button === 0) onToggleSelection?.(id);
        return;
      }
      onSelect(id);

      if (isAutoLayout || isTabInSheet) return;
      // Locked (or has a locked ancestor) — selection still works, but drag is blocked.
      if (lockedEffectively) return;

      // If DFrame, check if we clicked the title bar for dragging
      if (isRootFrameType(el.type)) {
         // Get the click position relative to the element
         const rect = e.currentTarget.getBoundingClientRect();
         const relativeY = e.clientY - rect.top;

         const titleBarHeight = el.type === ComponentType.liaFrame ? 46 : 24;
         if (relativeY > titleBarHeight) {
             return; // Don't drag if not on title bar
         }
      }

      const startX = e.clientX;
      const startY = e.clientY;

      // Multi-drag: if the dragged element is part of a multi-selection, snapshot
      // the start position of EVERY selected element (skipping locked ones, since
      // those refuse moves anyway). Then on each move tick, apply the same delta
      // to every snapshotted element.
      const isMultiDrag = state.selectedIds.length > 1 && state.selectedIds.includes(id);
      const startPositions = new Map<string, { x: number; y: number }>();
      if (isMultiDrag) {
        for (const sid of state.selectedIds) {
          const sel = state.elements[sid];
          if (!sel) continue;
          if (isEffectivelyLocked(sid)) continue;
          // Skip elements whose parent uses auto-layout (their position is parent-controlled)
          const sp = sel.parentId ? state.elements[sel.parentId] : null;
          if (sp?.props.layoutMode && sp.props.layoutMode !== 'none') continue;
          startPositions.set(sid, { x: sel.props.x, y: sel.props.y });
        }
      } else {
        startPositions.set(id, { x: el.props.x, y: el.props.y });
      }

      const handleMouseMove = (moveEvent: MouseEvent) => {
        const dx = (moveEvent.clientX - startX) / viewState.zoom;
        const dy = (moveEvent.clientY - startY) / viewState.zoom;

        // Atomic batch: build all patches, apply in ONE state write so each
        // element's update doesn't get overwritten by stale-state from the next.
        if (startPositions.size > 1 && onPatchMany) {
          const patches: Array<{ id: string; props: Partial<UIElement['props']> }> = [];
          for (const [sid, start] of startPositions) {
            patches.push({ id: sid, props: { x: snap(start.x + dx), y: snap(start.y + dy) } });
          }
          onPatchMany(patches);
        } else {
          // Single-element drag — original codepath
          const start = startPositions.get(id);
          if (start) onUpdateElement(id, { x: snap(start.x + dx), y: snap(start.y + dy) });
        }
      };

      const handleMouseUp = () => {
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      };

      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    };

    // Calculate layout style for children container
    const childrenContainerStyle: React.CSSProperties = {
        position: 'relative',
        width: '100%',
        height: '100%',
        pointerEvents: 'auto',
        // Auto Layout Flexbox Logic
        display: el.props.layoutMode && el.props.layoutMode !== 'none' ? 'flex' : 'block',
        flexDirection: el.props.layoutMode === 'horizontal' ? 'row' : 'column',
        gap: el.props.layoutSpacing ? `${el.props.layoutSpacing}px` : undefined,
        padding: el.props.layoutPadding ? `${el.props.layoutPadding}px` : undefined,
        overflowY: el.type === ComponentType.DScrollPanel ? 'auto' : 'hidden',
        overflowX: 'hidden'
    };
    
    // DPropertySheet Children Handling
    if (el.type === ComponentType.DPropertySheet) {
        childrenContainerStyle.position = 'absolute';
        childrenContainerStyle.top = '24px'; // Below tab bar
        childrenContainerStyle.left = '4px';
        childrenContainerStyle.right = '4px';
        childrenContainerStyle.bottom = '4px';
        childrenContainerStyle.width = 'auto';
        childrenContainerStyle.height = 'auto';
        childrenContainerStyle.overflow = 'hidden';
    }

    // DColumnSheet Children Handling — content area is to the RIGHT of the 80px tab strip.
    if (el.type === ComponentType.DColumnSheet) {
        childrenContainerStyle.position = 'absolute';
        childrenContainerStyle.left = '84px';   // 80 strip + 4 margin
        childrenContainerStyle.top = '4px';
        childrenContainerStyle.right = '4px';
        childrenContainerStyle.bottom = '4px';
        childrenContainerStyle.width = 'auto';
        childrenContainerStyle.height = 'auto';
        childrenContainerStyle.overflow = 'hidden';
    }
    
    // DForm Children Handling
    if (el.type === ComponentType.DForm) {
        childrenContainerStyle.position = 'absolute';
        childrenContainerStyle.top = '24px'; // Below label
        childrenContainerStyle.left = '4px';
        childrenContainerStyle.right = '4px';
        childrenContainerStyle.bottom = '4px';
        childrenContainerStyle.width = 'auto';
        childrenContainerStyle.height = 'auto';
        // Force vertical layout for DForm typically
        childrenContainerStyle.display = 'flex';
        childrenContainerStyle.flexDirection = 'column';
        childrenContainerStyle.gap = '5px';
    }

    // DGrid: CSS grid with fixed cell size (gridColWide × gridRowHeight, gridCols columns)
    if (el.type === ComponentType.DGrid) {
        const cols = el.props.gridCols ?? 4;
        const cw = el.props.gridColWide ?? 50;
        const rh = el.props.gridRowHeight ?? 50;
        childrenContainerStyle.display = 'grid';
        childrenContainerStyle.gridTemplateColumns = `repeat(${cols}, ${cw}px)`;
        childrenContainerStyle.gridAutoRows = `${rh}px`;
        childrenContainerStyle.gap = '0px';
        delete (childrenContainerStyle as any).flexDirection;
    }

    // DIconLayout: flex-wrap with configurable spacing + outer border (padding)
    if (el.type === ComponentType.DIconLayout) {
        const sx = el.props.iconSpaceX ?? 5;
        const sy = el.props.iconSpaceY ?? 5;
        const border = el.props.iconBorder ?? 0;
        const dir = el.props.iconLayoutDir || 'TOP';
        childrenContainerStyle.display = 'flex';
        // LEFT = wrap horizontally (rows of items, wrapping when full)
        // TOP = wrap vertically (columns of items)
        childrenContainerStyle.flexDirection = dir === 'LEFT' ? 'row' : 'column';
        childrenContainerStyle.flexWrap = 'wrap';
        childrenContainerStyle.gap = `${sy}px ${sx}px`;
        childrenContainerStyle.padding = `${border}px`;
    }

    const handleDoubleClick = (e: React.MouseEvent) => {
      if (!TEXT_EDITABLE_TYPES.has(el.type)) return;
      e.stopPropagation();
      e.preventDefault();
      onSelect(id);
      setEditingId(id);
    };

    const handleContextMenu = (e: React.MouseEvent) => {
      // Right-click opens the context menu. Selection rules:
      //  - If the right-clicked element is already part of the multi-selection,
      //    PRESERVE the selection (so context-menu actions can apply to all).
      //  - Otherwise, select just this element (replacing any prior selection).
      e.stopPropagation();
      e.preventDefault();
      if (!state.selectedIds.includes(id)) {
        onSelect(id);
      }
      setContextMenu({ x: e.clientX, y: e.clientY, elementId: id, submenu: null });
    };

    return (
      <div
        key={id}
        style={finalStyle}
        onMouseDown={handleMouseDown}
        onDoubleClick={handleDoubleClick}
        onContextMenu={handleContextMenu}
        onMouseEnter={() => setHoveredId(id)}
        onMouseLeave={() => setHoveredId(null)}
        title={el.props.tooltip} // Native Tooltip
        className={`group select-none ${isSelected ? 'outline outline-2 outline-blue-500' : (isMultiSelected && !groupBounds) ? 'outline-dashed outline-2 outline-blue-400/70' : ''}`}
      >
        {renderVGUIContent(el, isSelected)}

        {/* Children container — fills the parent edge-to-edge so child x/y are
            measured from the parent's actual top-left, matching gmod's
            :SetPos(x, y) semantics. (A child at y=0 of a DFrame WILL overlap
            the title bar — that's what happens in-game.)
            DCollapsibleCategory still gates child visibility on its expanded state. */}
        {!(el.type === ComponentType.DCollapsibleCategory && el.props.expanded === false) && (
          <div className="absolute inset-0 pointer-events-none">
               <div style={childrenContainerStyle} className="custom-scrollbar">
                   {el.children.map(childId => renderElement(childId))}
               </div>
          </div>
        )}

        {isSelected && renderResizeHandles(el)}

        {isHovered && renderHoverToolbar(el, lockedEffectively)}
      </div>
    );
  };

  // ──────────────────────────────────────────────────────────────────────
  // Context menu (right-click)
  // ──────────────────────────────────────────────────────────────────────
  // Each menu item is { label, icon?, onClick?, disabled?, separator?, hasSubmenu? }.
  type CMenuItem = {
    label?: string;
    icon?: React.ReactNode;
    onClick?: () => void;
    disabled?: boolean;
    separator?: boolean;
    hasSubmenu?: boolean;
    onHover?: () => void;
    danger?: boolean;
    isHeader?: boolean;
  };

  // Helpers used by the new selection menu items.
  const collectDescendants = (rootId: string): string[] => {
    const out: string[] = [];
    const walk = (id: string) => {
      out.push(id);
      state.elements[id]?.children.forEach(walk);
    };
    walk(rootId);
    return out;
  };

  const collectAncestors = (id: string): string[] => {
    const out: string[] = [id];
    let curr = state.elements[id];
    while (curr && curr.parentId) {
      out.push(curr.parentId);
      curr = state.elements[curr.parentId];
    }
    return out;
  };

  const buildContextMenuItems = (el: UIElement): CMenuItem[] => {
    const lockedEff = isEffectivelyLocked(el.id);
    const parent = el.parentId ? state.elements[el.parentId] : null;
    const grandparent = parent?.parentId ? state.elements[parent.parentId] : null;

    // Bulk-aware: when the right-clicked element is in an active multi-selection
    // (>1 elements), Lock & Delete operate on the whole selection. Other actions
    // stay element-scoped because their semantics aren't well-defined for multi
    // (e.g. Stretch to Fit Parent — to which parent?).
    const selectedSet = state.selectedIds;
    const isInMulti = selectedSet.length > 1 && selectedSet.includes(el.id);
    const isSelected = selectedSet.includes(el.id);

    const items: CMenuItem[] = [];

    // Multi-selection header (informational, not clickable)
    if (isInMulti) {
      items.push({ isHeader: true, label: `${selectedSet.length} elements selected` });
      items.push({ separator: true });
    }

    // ── Element-specific actions (top of menu, before universals) ──
    const specifics = getElementSpecificMenuItems(el);
    if (specifics.length > 0) {
      items.push(...specifics, { separator: true });
    }

    // ── Selection actions (the 3 user-requested global items) ──
    items.push({
      label: isSelected ? 'Deselect' : 'Select',
      icon: <Check className="w-3 h-3" />,
      onClick: () => onToggleSelection?.(el.id),
    });
    items.push({
      label: 'Select All Children',
      icon: <ChevronRight className="w-3 h-3" />,
      onClick: () => onSelectMany?.(collectDescendants(el.id)),
      disabled: el.children.length === 0,
    });
    items.push({
      label: 'Select All Parents',
      icon: <ChevronRight className="w-3 h-3 rotate-180" />,
      onClick: () => onSelectMany?.(collectAncestors(el.id)),
      disabled: !el.parentId,
    });

    items.push({ separator: true });

    // ── Universal actions ──
    items.push({
      label: isInMulti
        ? (el.props.locked ? `Unlock (${selectedSet.length})` : `Lock (${selectedSet.length})`)
        : (el.props.locked ? 'Unlock' : 'Lock'),
      icon: el.props.locked ? <LockOpen className="w-3 h-3" /> : <Lock className="w-3 h-3" />,
      onClick: () => {
        if (isInMulti) {
          // Toggle each selected element's own locked state. We base the new value
          // on the right-clicked element so all targets land in the same state.
          const newLocked = !el.props.locked;
          for (const sid of selectedSet) onUpdateElement(sid, { locked: newLocked });
        } else {
          toggleLock(el.id);
        }
      },
    });

    items.push({
      label: 'Parent',
      icon: <LinkIcon className="w-3 h-3" />,
      hasSubmenu: true,
      onHover: () => setContextMenu(prev => prev ? { ...prev, submenu: 'parent' } : null),
    });
    items.push({
      label: 'Unparent',
      icon: <Unlink className="w-3 h-3" />,
      onClick: () => onUnparent?.(el.id),
      disabled: !el.parentId,
    });

    items.push({
      label: 'Group (wrap in DPanel)',
      icon: <Group className="w-3 h-3" />,
      onClick: () => onGroup?.(el.id),
    });
    items.push({
      label: 'Ungroup (move children up)',
      icon: <Ungroup className="w-3 h-3" />,
      onClick: () => onUngroup?.(el.id),
      disabled: el.children.length === 0,
    });

    items.push({
      label: 'Stretch to Fit Parent',
      icon: <Maximize2 className="w-3 h-3" />,
      onClick: () => fillParent(el.id),
      disabled: !el.parentId || lockedEff,
    });
    items.push({
      label: 'Shrink to Fit Contents',
      icon: <Minimize2 className="w-3 h-3" />,
      onClick: () => onShrinkToFit?.(el.id),
      disabled: el.children.length === 0 || lockedEff,
    });

    items.push({
      label: 'Edit Properties',
      icon: <Settings2 className="w-3 h-3" />,
      onClick: () => onSelect(el.id), // collapses any multi-selection too
    });

    // Global reference action — opens the element's Gmod Wiki page in a new tab.
    // URL strategy lives in utils/componentDefinitions.ts → getGmodWikiUrl.
    items.push({
      label: 'Gmod Wiki',
      icon: <Globe className="w-3 h-3" />,
      onClick: () => {
        const url = getGmodWikiUrl(el.type);
        if (url) window.open(url, '_blank', 'noopener,noreferrer');
      },
    });

    items.push({ separator: true });

    items.push({
      label: 'Duplicate',
      icon: <CopyIcon className="w-3 h-3" />,
      onClick: () => onDuplicate?.(),
    });

    items.push({
      label: isInMulti ? `Delete (${selectedSet.length})` : 'Delete',
      icon: <Trash2 className="w-3 h-3" />,
      onClick: () => {
        if (isInMulti) onDeleteMany?.(selectedSet);
        else onDeleteElement?.(el.id);
      },
      danger: true,
    });

    return items;
  };

  // Element-type-specific quick actions, surfaced at the top of the context menu.
  const getElementSpecificMenuItems = (el: UIElement): CMenuItem[] => {
    switch (el.type) {
      case ComponentType.DCheckBox:
        return [{
          label: el.props.checked ? 'Uncheck' : 'Check',
          icon: <Check className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { checked: !el.props.checked }),
        }];

      case ComponentType.DCollapsibleCategory:
        return [{
          label: el.props.expanded === false ? 'Expand' : 'Collapse',
          icon: <ChevronRight className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { expanded: el.props.expanded === false }),
        }];

      case ComponentType.DTextEntry:
        return [{
          label: el.props.entryMultiline ? 'Switch to Single-Line' : 'Switch to Multi-Line',
          icon: <TypeIcon className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { entryMultiline: !el.props.entryMultiline }),
        }];

      case ComponentType.DButton:
        return [{
          label: el.props.buttonEnabled === false ? 'Enable' : 'Disable',
          icon: <Square className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { buttonEnabled: el.props.buttonEnabled === false }),
        }];

      case ComponentType.DFrame:
        return [
          {
            label: el.props.framePaintBackground === false ? 'Enable Frame Paint' : 'Disable Frame Paint',
            icon: <Square className="w-3 h-3" />,
            onClick: () => onUpdateElement(el.id, { framePaintBackground: el.props.framePaintBackground === false }),
          },
          {
            label: el.props.showCloseButton === false ? 'Show Close Button' : 'Hide Close Button',
            icon: <X className="w-3 h-3" />,
            onClick: () => onUpdateElement(el.id, { showCloseButton: el.props.showCloseButton === false }),
          },
        ];

      case ComponentType.DImage:
      case ComponentType.DImageButton:
        return [{
          label: 'Clear Image',
          icon: <ImageOff className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { imageUrl: undefined }),
          disabled: !el.props.imageUrl,
        }];

      case ComponentType.DPanel:
        return [{
          label: el.props.panelPaintBackground === false ? 'Show Background' : 'Hide Background',
          icon: <Square className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { panelPaintBackground: el.props.panelPaintBackground === false }),
        }];

      case ComponentType.DSlider:
      case ComponentType.DColorCube:
        return [{
          label: 'Reset Knob to Center',
          icon: <Settings2 className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { sliderX: 0.5, sliderY: 0.5 }),
        }];

      case ComponentType.DNumSlider:
      case ComponentType.DNumberWang: {
        const min = el.props.sliderMin ?? 0;
        const max = el.props.sliderMax ?? 100;
        return [{
          label: 'Reset Value to Min',
          icon: <Settings2 className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { sliderValue: min }),
        }, {
          label: 'Reset Value to Max',
          icon: <Settings2 className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { sliderValue: max }),
        }];
      }

      case ComponentType.DProgress:
        return [{
          label: 'Reset Progress to 0',
          icon: <Settings2 className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { progressFraction: 0 }),
        }, {
          label: 'Set Progress to Full',
          icon: <Settings2 className="w-3 h-3" />,
          onClick: () => onUpdateElement(el.id, { progressFraction: 1 }),
        }];

      default:
        return [];
    }
  };

  const renderContextMenu = () => {
    if (!contextMenu) return null;
    const el = state.elements[contextMenu.elementId];
    if (!el) return null;
    const items = buildContextMenuItems(el);

    // Keep the menu inside the viewport (rough heuristic — assume ~250 wide × ~items*24 tall).
    const menuW = 220;
    const menuH = items.length * 26 + 8;
    const x = Math.min(contextMenu.x, window.innerWidth - menuW - 8);
    const y = Math.min(contextMenu.y, window.innerHeight - menuH - 8);

    const itemBaseStyle: React.CSSProperties = {
      padding: '5px 10px',
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      fontSize: 11,
      color: 'white',
      cursor: 'pointer',
      userSelect: 'none',
      borderRadius: 3,
    };

    return (
      <div
        data-context-menu
        style={{
          position: 'fixed', left: x, top: y, zIndex: 1000,
          background: '#262626',
          border: '1px solid #000',
          borderRadius: 6,
          boxShadow: '0 8px 24px rgba(0,0,0,0.6)',
          minWidth: menuW,
          padding: 4,
        }}
        onContextMenu={(e) => e.preventDefault()}
      >
        {items.map((item, i) => {
          if (item.separator) {
            return <div key={i} style={{ height: 1, background: '#3a3a3a', margin: '4px 2px' }} />;
          }
          if (item.isHeader) {
            return (
              <div key={i} style={{ padding: '4px 10px', fontSize: 10, fontWeight: 600, color: '#3b82f6', textTransform: 'uppercase', letterSpacing: 0.5, userSelect: 'none' }}>
                {item.label}
              </div>
            );
          }
          return (
            <div
              key={i}
              style={{
                ...itemBaseStyle,
                opacity: item.disabled ? 0.35 : 1,
                cursor: item.disabled ? 'not-allowed' : 'pointer',
                color: item.danger ? '#fca5a5' : 'white',
              }}
              onMouseEnter={(e) => {
                if (!item.disabled) {
                  (e.currentTarget as HTMLDivElement).style.background = item.danger ? '#7f1d1d' : '#3b82f6';
                }
                if (item.onHover) item.onHover();
                else if (!item.hasSubmenu) {
                  // Hovering a non-submenu item closes any open submenu
                  setContextMenu(prev => prev && prev.submenu ? { ...prev, submenu: null } : prev);
                }
              }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLDivElement).style.background = 'transparent'; }}
              onClick={() => {
                if (item.disabled || item.hasSubmenu) return;
                item.onClick?.();
                setContextMenu(null);
              }}
            >
              <span style={{ width: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: 0.85 }}>
                {item.icon}
              </span>
              <span style={{ flex: 1 }}>{item.label}</span>
              {item.hasSubmenu && <ChevronRight className="w-3 h-3 opacity-60" />}
            </div>
          );
        })}

        {/* Parent submenu (anchored to right of main menu) */}
        {contextMenu.submenu === 'parent' && renderParentSubmenu(el, x + menuW + 4, y)}
      </div>
    );
  };

  // Submenu listing valid parents the element can be reparented to.
  const renderParentSubmenu = (el: UIElement, x: number, y: number) => {
    const descendants = getDescendantIds(state.elements, el.id);
    descendants.add(el.id);

    const candidates = (Object.values(state.elements) as UIElement[])
      .filter(candidate => canAcceptChildren(candidate.type) && !descendants.has(candidate.id) && candidate.id !== el.parentId)
      .sort((a, b) => a.props.variableName.localeCompare(b.props.variableName));

    return (
      <div
        data-context-menu
        style={{
          position: 'fixed', left: x, top: y, zIndex: 1001,
          background: '#262626',
          border: '1px solid #000',
          borderRadius: 6,
          boxShadow: '0 8px 24px rgba(0,0,0,0.6)',
          minWidth: 180,
          maxHeight: 320,
          overflowY: 'auto',
          padding: 4,
        }}
      >
        <div
          style={{
            padding: '5px 10px',
            fontSize: 11,
            color: el.parentId ? 'white' : '#888',
            cursor: el.parentId ? 'pointer' : 'default',
            borderRadius: 3,
            display: 'flex',
            flexDirection: 'column',
            gap: 1,
          }}
          onMouseEnter={(e) => { if (el.parentId) (e.currentTarget as HTMLDivElement).style.background = '#3b82f6'; }}
          onMouseLeave={(e) => { (e.currentTarget as HTMLDivElement).style.background = 'transparent'; }}
          onClick={() => {
            if (!el.parentId) return;
            onReparent?.(el.id, null);
            setContextMenu(null);
          }}
        >
          <span style={{ fontFamily: 'monospace' }}>Top level</span>
          <span style={{ fontSize: 9, opacity: 0.6 }}>No parent</span>
        </div>
        {candidates.length === 0 && !el.parentId && (
          <div style={{ padding: '6px 10px', fontSize: 11, color: '#888' }}>(No other valid parents)</div>
        )}
        {candidates.map(p => (
          <div
            key={p.id}
            style={{
              padding: '5px 10px',
              fontSize: 11,
              color: 'white',
              cursor: 'pointer',
              borderRadius: 3,
              display: 'flex',
              flexDirection: 'column',
              gap: 1,
            }}
            onMouseEnter={(e) => { (e.currentTarget as HTMLDivElement).style.background = '#3b82f6'; }}
            onMouseLeave={(e) => { (e.currentTarget as HTMLDivElement).style.background = 'transparent'; }}
            onClick={() => {
              onReparent?.(el.id, p.id);
              setContextMenu(null);
            }}
          >
            <span style={{ fontFamily: 'monospace' }}>{p.props.variableName}</span>
            <span style={{ fontSize: 9, opacity: 0.6 }}>{p.type}</span>
          </div>
        ))}
      </div>
    );
  };

  // Floating action toolbar shown in the top-right of an element while hovered.
  // Each button uses stopPropagation on mousedown/click so it never triggers the
  // parent element's drag/select handlers.
  const renderHoverToolbar = (el: UIElement, lockedEffectively: boolean) => {
    // Scale the toolbar inversely with zoom so icons stay a constant pixel size
    // regardless of how zoomed in the canvas is.
    const z = viewState.zoom;
    const btnSize = 16 / z;
    const iconSize = 10 / z;
    const gap = 4 / z;
    const offset = 4 / z;

    const stop = (e: React.MouseEvent) => {
      e.stopPropagation();
      e.preventDefault();
    };

    const baseBtn: React.CSSProperties = {
      width: btnSize,
      height: btnSize,
      borderRadius: '50%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      border: `${1 / z}px solid rgba(0,0,0,0.6)`,
      boxShadow: `0 ${1 / z}px ${3 / z}px rgba(0,0,0,0.4)`,
      pointerEvents: 'auto',
      color: 'white',
    };

    const lockColor = lockedEffectively ? '#ef4444' : '#22c55e'; // red / green
    const LockIconComp = lockedEffectively ? Lock : LockOpen;
    const lockTitle = lockedEffectively
      ? (el.props.locked ? 'Unlock element' : 'Locked by parent')
      : 'Lock element (prevents move/resize, cascades to children)';

    return (
      <div
        style={{
          position: 'absolute',
          top: offset,
          right: offset,
          display: 'flex',
          gap,
          zIndex: 60,
          pointerEvents: 'auto',
        }}
        onMouseDown={stop}
        onDoubleClick={stop}
      >
        <button
          type="button"
          title="Delete element"
          style={{ ...baseBtn, background: '#ef4444' }}
          onMouseDown={stop}
          onClick={(e) => { stop(e); onDeleteElement?.(el.id); }}
        >
          <X style={{ width: iconSize, height: iconSize }} strokeWidth={3} />
        </button>
        <button
          type="button"
          title={lockTitle}
          style={{ ...baseBtn, background: lockColor }}
          onMouseDown={stop}
          onClick={(e) => { stop(e); toggleLock(el.id); }}
        >
          <LockIconComp style={{ width: iconSize, height: iconSize }} strokeWidth={2.5} />
        </button>
        <button
          type="button"
          title={el.parentId ? 'Fill parent' : 'No parent to fill'}
          disabled={!el.parentId || lockedEffectively}
          style={{
            ...baseBtn,
            background: '#3b82f6',
            opacity: (!el.parentId || lockedEffectively) ? 0.4 : 1,
            cursor: (!el.parentId || lockedEffectively) ? 'not-allowed' : 'pointer',
          }}
          onMouseDown={stop}
          onClick={(e) => { stop(e); if (el.parentId && !lockedEffectively) fillParent(el.id); }}
        >
          <Maximize2 style={{ width: iconSize, height: iconSize }} strokeWidth={2.5} />
        </button>
      </div>
    );
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Group bounding-box resize overlay
  // ─────────────────────────────────────────────────────────────────────────

  const renderMultiSelectBox = (bounds: GroupBounds) => {
    const z = viewState.zoom;
    const hs = 8 / z; // handle size in canvas units
    const dirs = ['n', 's', 'e', 'w', 'ne', 'nw', 'se', 'sw'] as const;
    const OUTSET = 4 / z; // gap between element edges and the overlay border

    const onHandleMouseDown = (e: React.MouseEvent, dir: string) => {
      e.stopPropagation();
      e.preventDefault();

      // Snapshot per-element start state in props space.
      const startElements = new Map<string, { x: number; y: number; w: number; h: number }>();
      for (const id of bounds.ids) {
        const el = state.elements[id];
        if (!el) continue;
        startElements.set(id, { x: el.props.x, y: el.props.y, w: el.props.w, h: el.props.h });
      }

      groupResizeDragRef.current = {
        startMouseX: e.clientX,
        startMouseY: e.clientY,
        startBounds: { px: bounds.px, py: bounds.py, w: bounds.w, h: bounds.h },
        startElements,
        dir,
      };

      const handleMouseMove = (mv: MouseEvent) => {
        const drag = groupResizeDragRef.current;
        if (!drag) return;
        const { startBounds: sb, startElements: se, dir: d } = drag;

        const rawDx = (mv.clientX - drag.startMouseX) / z;
        const rawDy = (mv.clientY - drag.startMouseY) / z;
        const isShift = mv.shiftKey;
        const isAlt   = mv.altKey;

        // ── Step 1: compute new bounding box in props space ──────────────
        let newPx = sb.px, newPy = sb.py, newW = sb.w, newH = sb.h;

        if (isAlt) {
          // Scale from center: both opposite edges move symmetrically.
          if (d.includes('e')) { newPx = sb.px - rawDx;  newW = Math.max(20, sb.w + rawDx * 2); }
          if (d.includes('w')) { newPx = sb.px + rawDx;  newW = Math.max(20, sb.w - rawDx * 2); }
          if (d.includes('s')) { newPy = sb.py - rawDy;  newH = Math.max(20, sb.h + rawDy * 2); }
          if (d.includes('n')) { newPy = sb.py + rawDy;  newH = Math.max(20, sb.h - rawDy * 2); }
        } else {
          // Standard: pin the opposite edge.
          if (d.includes('e')) newW = Math.max(10, sb.w + rawDx);
          if (d.includes('s')) newH = Math.max(10, sb.h + rawDy);
          if (d.includes('w')) { const δ = Math.min(sb.w - 10, rawDx); newPx = sb.px + δ; newW = sb.w - δ; }
          if (d.includes('n')) { const δ = Math.min(sb.h - 10, rawDy); newPy = sb.py + δ; newH = sb.h - δ; }
        }

        // ── Step 2: compute per-element patches ───────────────────────────
        const patches: Array<{ id: string; props: Partial<UIElement['props']> }> = [];

        if (isShift) {
          // Proportional: positions and sizes scale relative to the anchor corner (or center).
          const scaleX = newW / sb.w;
          const scaleY = newH / sb.h;
          const anchorPx = isAlt ? sb.px + sb.w / 2 : (d.includes('w') ? sb.px + sb.w : sb.px);
          const anchorPy = isAlt ? sb.py + sb.h / 2 : (d.includes('n') ? sb.py + sb.h : sb.py);

          for (const [id, start] of se) {
            patches.push({
              id,
              props: {
                x: snap(anchorPx + (start.x - anchorPx) * scaleX),
                y: snap(anchorPy + (start.y - anchorPy) * scaleY),
                w: snap(Math.max(10, start.w * scaleX)),
                h: snap(Math.max(10, start.h * scaleY)),
              },
            });
          }
        } else {
          // Uniform delta: each element's matching edges shift by the same raw pixel amount.
          for (const [id, start] of se) {
            const p: Partial<UIElement['props']> = {};
            if (isAlt) {
              if (d.includes('e')) { p.x = snap(start.x - rawDx); p.w = snap(Math.max(10, start.w + rawDx * 2)); }
              if (d.includes('w')) { p.x = snap(start.x + rawDx); p.w = snap(Math.max(10, start.w - rawDx * 2)); }
              if (d.includes('s')) { p.y = snap(start.y - rawDy); p.h = snap(Math.max(10, start.h + rawDy * 2)); }
              if (d.includes('n')) { p.y = snap(start.y + rawDy); p.h = snap(Math.max(10, start.h - rawDy * 2)); }
            } else {
              if (d.includes('e')) p.w = snap(Math.max(10, start.w + rawDx));
              if (d.includes('s')) p.h = snap(Math.max(10, start.h + rawDy));
              if (d.includes('w')) { const δ = Math.min(start.w - 10, rawDx); p.x = snap(start.x + δ); p.w = snap(start.w - δ); }
              if (d.includes('n')) { const δ = Math.min(start.h - 10, rawDy); p.y = snap(start.y + δ); p.h = snap(start.h - δ); }
            }
            if (Object.keys(p).length) patches.push({ id, props: p });
          }
        }

        if (patches.length) onPatchMany?.(patches);
      };

      const handleMouseUp = () => {
        groupResizeDragRef.current = null;
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      };

      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
    };

    const cursorMap: Record<string, string> = {
      n: 'ns-resize', s: 'ns-resize', e: 'ew-resize', w: 'ew-resize',
      ne: 'nesw-resize', sw: 'nesw-resize', nw: 'nwse-resize', se: 'nwse-resize',
    };

    const handleStyle = (dir: string): React.CSSProperties => {
      const base: React.CSSProperties = {
        position: 'absolute', width: hs, height: hs,
        backgroundColor: '#3b82f6', border: `${1 / z}px solid white`,
        zIndex: 200, pointerEvents: 'auto', cursor: cursorMap[dir] || 'pointer',
      };
      if (dir === 'n')  { base.top = -hs / 2; base.left = '50%'; base.transform = 'translateX(-50%)'; }
      if (dir === 's')  { base.bottom = -hs / 2; base.left = '50%'; base.transform = 'translateX(-50%)'; }
      if (dir === 'w')  { base.left = -hs / 2; base.top = '50%'; base.transform = 'translateY(-50%)'; }
      if (dir === 'e')  { base.right = -hs / 2; base.top = '50%'; base.transform = 'translateY(-50%)'; }
      if (dir === 'nw') { base.top = -hs / 2; base.left = -hs / 2; }
      if (dir === 'ne') { base.top = -hs / 2; base.right = -hs / 2; }
      if (dir === 'sw') { base.bottom = -hs / 2; base.left = -hs / 2; }
      if (dir === 'se') { base.bottom = -hs / 2; base.right = -hs / 2; }
      return base;
    };

    return (
      <div
        style={{
          position: 'absolute',
          left: bounds.x - OUTSET,
          top: bounds.y - OUTSET,
          width: bounds.w + OUTSET * 2,
          height: bounds.h + OUTSET * 2,
          border: `${1 / z}px dashed rgba(59,130,246,0.85)`,
          pointerEvents: 'none',
          zIndex: 150,
          boxSizing: 'border-box',
        }}
      >
        {dirs.map(dir => (
          <div key={dir} style={handleStyle(dir)} onMouseDown={(e) => onHandleMouseDown(e, dir)} />
        ))}
      </div>
    );
  };

  // Assign groupBounds now — renderElement (called during the return) reads this via closure.
  groupBounds = computeGroupBounds();

  return (
    <div className="flex-1 bg-[#151515] relative overflow-hidden flex flex-col">
       {/* Canvas Toolbar */}
       <div className="absolute top-4 right-4 z-20 flex flex-col gap-2 pointer-events-auto">
            <div className="bg-neutral-800/80 backdrop-blur border border-neutral-700 rounded-lg p-1 flex flex-col shadow-xl">
                <button onClick={() => onViewChange({...viewState, zoom: Math.min(5, viewState.zoom + 0.1)})} className="p-2 hover:bg-neutral-700 rounded text-neutral-300 hover:text-white transition-colors" title="Zoom In"><ZoomIn className="w-4 h-4" /></button>
                <button onClick={() => onViewChange({...viewState, zoom: Math.max(0.1, viewState.zoom - 0.1)})} className="p-2 hover:bg-neutral-700 rounded text-neutral-300 hover:text-white transition-colors" title="Zoom Out"><ZoomOut className="w-4 h-4" /></button>
                <button onClick={() => onViewChange({...viewState, showGrid: !viewState.showGrid})} className={`p-2 rounded transition-colors ${viewState.showGrid ? 'text-blue-400 bg-blue-900/20' : 'text-neutral-400 hover:text-white hover:bg-neutral-700'}`} title="Toggle Grid"><GridIcon className="w-4 h-4" /></button>
                <div className="h-px bg-neutral-700 my-1"></div>
                <button onClick={() => onViewChange({...viewState, zoom: 1, panX: 0, panY: 0})} className="p-2 hover:bg-neutral-700 rounded text-neutral-300 hover:text-white transition-colors text-xs font-bold" title="Reset View">1:1</button>
            </div>
       </div>

        <div
          ref={containerRef}
          className="flex-1 relative overflow-hidden"
          onWheel={handleWheel}
          onMouseDown={startPan}
          onContextMenu={(e) => { e.preventDefault(); setContextMenu(null); }}
          style={{
            cursor: isPanning ? 'grabbing' : 'default',
            backgroundImage: viewState.showGrid ? 'radial-gradient(#444 1px, transparent 1px)' : undefined,
            backgroundSize: `${viewState.gridSize * viewState.zoom}px ${viewState.gridSize * viewState.zoom}px`,
            backgroundPosition: `${viewState.panX}px ${viewState.panY}px`
          }}
        >
            <div 
                className="absolute transform-gpu origin-top-left"
                style={{
                    transform: `translate(${viewState.panX}px, ${viewState.panY}px) scale(${viewState.zoom})`,
                    width: '100%',
                    height: '100%'
                }}
            >
                {getTopLevelIds(state.elements).length > 0 ? getTopLevelIds(state.elements).map(id => renderElement(id)) : (
                    <div className="absolute inset-0 flex items-center justify-center pointer-events-none" style={{ transform: `scale(${1/viewState.zoom})` }}>
                        <div className="text-center text-neutral-600 bg-neutral-900/50 p-6 rounded-xl border border-neutral-800 backdrop-blur-sm">
                            <p className="text-xl font-bold mb-2">Empty Canvas</p>
                            <p className="text-sm">Add any component to start building your UI.</p>
                        </div>
                    </div>
                )}
                {groupBounds && renderMultiSelectBox(groupBounds)}
            </div>
        </div>
        
        <div className="h-6 bg-neutral-900 border-t border-neutral-800 flex items-center px-4 text-[10px] text-neutral-500 space-x-4 z-10">
            <span>Zoom: {Math.round(viewState.zoom * 100)}%</span>
            <span>Grid: {viewState.showGrid ? `${viewState.gridSize}px` : 'Off'}</span>
        </div>

        {/* Right-click context menu — rendered last so it overlays everything. */}
        {renderContextMenu()}
    </div>
  );
};

export default Canvas;