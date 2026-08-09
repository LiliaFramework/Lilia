import { ComponentType } from "../types";
import { getLiaMethods } from './liaComponentDefinitions';

export interface MethodSignature {
  name: string;
  args: string[];
  description?: string;
}

const COMMON_PANEL_METHODS: MethodSignature[] = [
  { name: 'Paint', args: ['self', 'w', 'h'], description: 'Called when the panel is drawn.' },
  { name: 'PaintOver', args: ['self', 'w', 'h'], description: 'Called after the panel and its children are drawn.' },
  { name: 'Think', args: ['self'], description: 'Called every frame.' },
  { name: 'PerformLayout', args: ['self', 'w', 'h'], description: 'Called when the panel needs to layout its children.' },
  { name: 'Init', args: ['self'], description: 'Called when the panel is initialized.' },
  { name: 'OnRemove', args: ['self'], description: 'Called when the panel is removed.' },
  { name: 'OnCursorEntered', args: ['self'], description: 'Called when the cursor enters the panel.' },
  { name: 'OnCursorExited', args: ['self'], description: 'Called when the cursor leaves the panel.' },
  { name: 'OnMousePressed', args: ['self', 'keyCode'], description: 'Called when a mouse button is pressed.' },
  { name: 'OnMouseReleased', args: ['self', 'keyCode'], description: 'Called when a mouse button is released.' },
  { name: 'OnMouseDoubleClick', args: ['self', 'keyCode'], description: 'Called when a mouse button is double clicked.' },
  { name: 'OnDragDrop', args: ['self', 'data'], description: 'Called when a drag and drop operation finishes on this panel.' },
  { name: 'SetKeyboardInput', args: ['self', 'b'], description: 'Sets whether keyboard input is enabled.' },
  { name: 'OnDraw', args: ['self', 'w', 'h'], description: 'Custom draw function.' },
  { name: 'OnPaint', args: ['self', 'w', 'h'], description: 'Alternative paint hook.' },
  { name: 'GetSize', args: ['self'], description: 'Returns the width and height of the panel.' },
  { name: 'GetWide', args: ['self'], description: 'Returns the width of the panel.' },
  { name: 'SetSize', args: ['self', 'w', 'h'], description: 'Sets the size of the panel.' },
  { name: 'SetPos', args: ['self', 'x', 'y'], description: 'Sets the position of the panel.' },
  { name: 'SetText', args: ['self', 'text'], description: 'Sets the text of the panel.' },
  { name: 'SetVisible', args: ['self', 'visible'], description: 'Sets the visibility of the panel.' },
  { name: 'SetEnabled', args: ['self', 'enabled'], description: 'Sets whether the panel is enabled.' },
];

const COMPONENT_METHODS: Partial<Record<ComponentType, MethodSignature[]>> = {
  [ComponentType.DFrame]: [
    { name: 'OnClose', args: ['self'], description: 'Called when the frame is closed.' },
    { name: 'Close', args: ['self'], description: 'Closes the frame.' },
  ],
  [ComponentType.DButton]: [
    { name: 'DoClick', args: ['self'], description: 'Called when the button is left-clicked.' },
    { name: 'DoRightClick', args: ['self'], description: 'Called when the button is right-clicked.' },
    { name: 'DoMiddleClick', args: ['self'], description: 'Called when the button is middle-clicked.' },
  ],
  [ComponentType.DTextEntry]: [
    { name: 'OnEnter', args: ['self'], description: 'Called when Enter is pressed.' },
    { name: 'OnChange', args: ['self'], description: 'Called when the text changes.' },
    { name: 'OnGetFocus', args: ['self'], description: 'Called when the element gains focus.' },
    { name: 'OnLoseFocus', args: ['self'], description: 'Called when the element loses focus.' },
    { name: 'AllowInput', args: ['self', 'char'], description: 'Return true to allow input, false to block.' },
  ],
  [ComponentType.DCheckBox]: [
    { name: 'OnChange', args: ['self', 'bVal'], description: 'Called when the checkbox state changes.' },
    { name: 'SetChecked', args: ['self', 'checked'], description: 'Sets the checked state.' },
  ],
  [ComponentType.DComboBox]: [
    { name: 'OnSelect', args: ['self', 'index', 'value', 'data'], description: 'Called when an option is selected.' },
  ],
  [ComponentType.DListView]: [
    { name: 'OnRowSelected', args: ['self', 'rowIndex', 'row'], description: 'Called when a row is selected.' },
    { name: 'OnRowRightClick', args: ['self', 'rowIndex', 'row'], description: 'Called when a row is right-clicked.' },
    { name: 'DoDoubleClick', args: ['self', 'rowIndex', 'row'], description: 'Called when a row is double-clicked.' },
    { name: 'OnClickLine', args: ['self', 'line', 'isSelected'], description: 'Called when a line is clicked.' },
  ],
  [ComponentType.DColorMixer]: [
    { name: 'ValueChanged', args: ['self', 'color'], description: 'Called when the color changes.' },
  ],
  [ComponentType.DNumSlider]: [
    { name: 'OnValueChanged', args: ['self', 'value'], description: 'Called when the slider value changes.' },
  ],
};

export const getMethodsForComponent = (type: ComponentType): MethodSignature[] => {
  const specific = [...(COMPONENT_METHODS[type] || []), ...getLiaMethods(type)];
  const methods = [...COMMON_PANEL_METHODS, ...specific];
  const unique = new Map(methods.map(method => [method.name, method]));
  return Array.from(unique.values()).sort((a, b) => a.name.localeCompare(b.name));
};

const WIKI_BASE = 'https://wiki.facepunch.com/gmod/';

const WIKI_SLUGS: Partial<Record<ComponentType, string>> = {
  [ComponentType.DFrame]: 'DFrame',
  [ComponentType.DPanel]: 'DPanel',
  [ComponentType.DButton]: 'DButton',
  [ComponentType.DLabel]: 'DLabel',
  [ComponentType.DTextEntry]: 'DTextEntry',
  [ComponentType.DCheckBox]: 'DCheckBox',
  [ComponentType.DComboBox]: 'DComboBox',
  [ComponentType.DListView]: 'DListView',
  [ComponentType.DGrid]: 'DGrid',
  [ComponentType.DImage]: 'DImage',
  [ComponentType.DPropertySheet]: 'DPropertySheet',
  [ComponentType.DTab]: 'DTab',
  [ComponentType.DForm]: 'DForm',
  [ComponentType.DModelPanel]: 'DModelPanel',
  [ComponentType.DIconLayout]: 'DIconLayout',
  [ComponentType.DTree]: 'DTree',
  [ComponentType.DCollapsibleCategory]: 'DCollapsibleCategory',
  [ComponentType.DNumSlider]: 'DNumSlider',
  [ComponentType.DVerticalDivider]: 'DVerticalDivider',
  [ComponentType.DHorizontalDivider]: 'DHorizontalDivider',
  [ComponentType.DMenuBar]: 'DMenuBar',
  [ComponentType.DMenu]: 'DMenu',
  [ComponentType.DHTML]: 'DHTML',
  [ComponentType.DBinder]: 'DBinder',
  [ComponentType.DColorCube]: 'DColorCube',
  [ComponentType.DColorPalette]: 'DColorPalette',
  [ComponentType.DColorMixer]: 'DColorMixer',
  [ComponentType.DSlider]: 'DSlider',
  [ComponentType.DImageButton]: 'DImageButton',
  [ComponentType.DNotify]: 'DNotify',
  [ComponentType.DProgress]: 'DProgress',
  [ComponentType.DRichText]: 'DRichText',
  [ComponentType.DSysButton]: 'DSysButton',
  [ComponentType.DTooltip]: 'DTooltip',
  [ComponentType.DNumberWang]: 'DNumberWang',
  [ComponentType.DBevel]: 'DBevel',
  [ComponentType.DScrollPanel]: 'DScrollPanel',
  [ComponentType.DColumnSheet]: 'DColumnSheet',
};

export const getGmodWikiUrl = (type: ComponentType): string | null => {
  const slug = WIKI_SLUGS[type];
  return slug ? `${WIKI_BASE}${slug}` : null;
};