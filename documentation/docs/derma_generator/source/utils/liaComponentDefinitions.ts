import { ComponentProps, ComponentType } from '../types';
import type { MethodSignature } from './componentDefinitions';

export type LiaOptionInput = 'string' | 'number' | 'boolean' | 'color' | 'textarea' | 'select';

export interface LiaOptionDefinition {
  key: string;
  label: string;
  input: LiaOptionInput;
  defaultValue: string | number | boolean;
  min?: number;
  max?: number;
  step?: number;
  placeholder?: string;
  choices?: Array<{ label: string; value: string | number | boolean }>;
}

export interface LiaRepeaterDefinition {
  key: string;
  format: 'comboItems' | 'dermaMenuItems';
  finalizeMethod?: string;
}

export interface LiaSetterDefinition {
  method: string;
  keys: string[];
  source?: 'liaOptions' | 'props';
  alwaysEmit?: boolean;
  kind?: 'method' | 'assign' | 'memberMethod';
  target?: string;
  rawKeys?: string[];
}

export interface LiaComponentDefinition {
  type: ComponentType;
  description: string;
  base: string;
  size: { w: number; h: number };
  defaultText?: string;
  defaultOptions?: Record<string, string | number | boolean>;
  options: LiaOptionDefinition[];
  setters: LiaSetterDefinition[];
  methods: MethodSignature[];
  repeaters?: LiaRepeaterDefinition[];
  root?: boolean;
  container?: boolean;
  preview: 'frame' | 'slider' | 'slidebox' | 'button' | 'checkbox' | 'combobox' | 'entry' | 'progress' | 'header' | 'scroll' | 'horizontalScroll' | 'horizontalScrollBar' | 'sheet' | 'table' | 'tabs' | 'tabButton' | 'model' | 'spawnIcon' | 'avatar' | 'notice' | 'noticePanel' | 'voice' | 'lockCircle' | 'dermaMenu';
}

const commonFrameMethods: MethodSignature[] = [
  { name: 'SetAlphaBackground', args: ['is_alpha'] },
  { name: 'SetTitle', args: ['title'] },
  { name: 'SetCenterTitle', args: ['center_title'] },
  { name: 'ShowAnimation', args: [] },
  { name: 'DisableCloseBtn', args: [] },
  { name: 'ShowCloseButton', args: ['show'] },
  { name: 'SetSizable', args: ['sizable'] },
  { name: 'SetDeleteOnClose', args: ['deleteOnClose'] },
  { name: 'SetScreenLock', args: ['locked'] },
  { name: 'SetBackgroundBlur', args: ['enable'] },
  { name: 'SetMinWidth', args: ['width'] },
  { name: 'SetMinHeight', args: ['height'] },
  { name: 'SetIcon', args: ['iconPath'] },
  { name: 'SetDraggable', args: ['is_draggable'] },
  { name: 'LiteMode', args: [] },
  { name: 'Notify', args: ['text', 'duration', 'col'] },
  { name: 'EnsureVisible', args: [] },
  { name: 'Center', args: [] },
  { name: 'Close', args: [] },
  { name: 'OnClose', args: [] },
  { name: 'GetBackgroundBlur', args: [] },
  { name: 'GetDeleteOnClose', args: [] },
  { name: 'GetDraggable', args: [] },
  { name: 'GetIsMenu', args: [] },
  { name: 'SetIsMenu', args: [] },
  { name: 'GetMinHeight', args: [] },
  { name: 'GetMinWidth', args: [] },
  { name: 'GetSizable', args: [] },
  { name: 'GetPaintShadow', args: [] },
  { name: 'SetPaintShadow', args: [] },
  { name: 'GetScreenLock', args: [] },
  { name: 'GetTitle', args: [] },
  { name: 'GetIcon', args: [] },
  { name: 'GetCloseButtonVisible', args: [] },
  { name: 'IsActive', args: [] },
];

const sliderMethods: MethodSignature[] = [
  { name: 'CreateConVarSyncTimer', args: [] },
  { name: 'SetRange', args: ['min_value', 'max_value', 'decimals'] },
  { name: 'SetConvar', args: ['convar'] },
  { name: 'SetValue', args: ['val', 'fromConVar'] },
  { name: 'GetValue', args: [] },
  { name: 'UpdateSliderByCursorPos', args: ['x'] },
  { name: 'OnValueChanged', args: ['value'] },
];

const slideBoxMethods: MethodSignature[] = [
  ...sliderMethods,
  { name: 'SetText', args: ['text'] },
];

const liaButtonMethods: MethodSignature[] = [
  { name: 'SetHover', args: ['is_hover'] },
  { name: 'SetFont', args: ['font'] },
  { name: 'SetRadius', args: ['rad'] },
  { name: 'SetIcon', args: ['icon', 'icon_size'] },
  { name: 'SetTxt', args: ['text'] },
  { name: 'SetText', args: ['text'] },
  { name: 'GetText', args: [] },
  { name: 'SetColor', args: ['col'] },
  { name: 'SetColorHover', args: ['col'] },
  { name: 'SetTextColor', args: ['col'] },
  { name: 'PaintButton', args: ['baseColor', 'hoverColor'] },
  { name: 'SetGradient', args: ['is_grad'] },
  { name: 'SetRipple', args: ['enable'] },
  { name: 'DoClick', args: [] },
];

const variantButtonMethods: MethodSignature[] = [
  { name: 'SetFont', args: ['font'] },
  { name: 'GetFont', args: [] },
  { name: 'SetTextColor', args: ['col'] },
  { name: 'SetSelected', args: ['state'] },
  { name: 'IsSelected', args: [] },
  { name: 'SetShowLine', args: ['show'] },
  { name: 'GetShowLine', args: [] },
  { name: 'DoClick', args: [] },
];

const modelPanelMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetModel', args: ['model'] },
  { name: 'SetFOV', args: ['fov'] },
  { name: 'LayoutEntity', args: [] },
  { name: 'PreDrawModel', args: ['ent'] },
  { name: 'PostDrawModel', args: ['ent'] },
  { name: 'OnMousePressed', args: [] },
  { name: 'fitFOV', args: [] },
];

const spawnIconMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetModel', args: ['model', 'skin'] },
  { name: 'setHidden', args: ['hidden'] },
  { name: 'LayoutEntity', args: [] },
  { name: 'OnMousePressed', args: [] },
  { name: 'UpdateVisuals', args: [] },
];


const voicePanelMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'Setup', args: ['client'] },
  { name: 'UpdateText', args: [] },
  { name: 'UpdateTooltip', args: [] },
  { name: 'PerformLayout', args: ['w', 'h'] },
  { name: 'Paint', args: ['w', 'h'] },
  { name: 'Think', args: [] },
  { name: 'FadeOut', args: ['anim', 'delta'] },
];

const lockCircleMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'Start', args: ['text', 'duration', 'options'] },
  { name: 'Think', args: [] },
  { name: 'OnRemove', args: [] },
  { name: 'Paint', args: [] },
];

const dermaMenuMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'Paint', args: ['w', 'h'] },
  { name: 'AddOption', args: ['text', 'func', 'icon', 'optData'] },
  { name: 'AddSpacer', args: [] },
  { name: 'SetDeferredBuild', args: ['builder'] },
  { name: 'AppendDeferredBuild', args: ['builder'] },
  { name: 'RunDeferredBuild', args: [] },
  { name: 'AddSubMenu', args: ['text', 'func', 'icon'] },
  { name: 'AddSubMenuSeparator', args: [] },
  { name: 'CloseAllSubMenus', args: [] },
  { name: 'GetAllSubMenus', args: [] },
  { name: 'UpdateSize', args: [] },
  { name: 'Open', args: ['x', 'y', 'skipanimation', 'ownerpanel'] },
  { name: 'CloseMenu', args: [] },
  { name: 'GetOpenSubMenu', args: [] },
  { name: 'GetDeleteSelf', args: [] },
  { name: 'SetDeleteSelf', args: ['deleteSelf'] },
  { name: 'SetMaxHeight', args: ['height'] },
  { name: 'AddCVar', args: ['name', 'convar', 'on', 'off', 'funcFunction'] },
  { name: 'AddPanel', args: ['pnl'] },
  { name: 'GetChild', args: ['childIndex'] },
  { name: 'ChildCount', args: [] },
  { name: 'GetDrawBorder', args: [] },
  { name: 'GetDrawColumn', args: [] },
  { name: 'GetMinimumWidth', args: [] },
  { name: 'ClearHighlights', args: [] },
  { name: 'Hide', args: [] },
  { name: 'HighlightItem', args: ['item'] },
  { name: 'OptionSelected', args: ['option'] },
  { name: 'OptionSelectedInternal', args: ['option'] },
  { name: 'SetDrawBorder', args: ['bool'] },
  { name: 'SetDrawColumn', args: ['drawColumn'] },
  { name: 'SetMinimumWidth', args: ['minWidth'] },
  { name: 'SetOpenSubMenu', args: ['item'] },
  { name: 'AddItem', args: ['pnl'] },
  { name: 'GetCanvas', args: [] },
  { name: 'GetPadding', args: [] },
  { name: 'GetVBar', args: [] },
  { name: 'InnerWidth', args: [] },
  { name: 'PerformLayoutInternal', args: [] },
  { name: 'Rebuild', args: [] },
  { name: 'ScrollToChild', args: ['panel'] },
  { name: 'SetCanvas', args: ['canvas'] },
  { name: 'SetPadding', args: ['left', 'top', 'right', 'bottom'] },
  { name: 'Clear', args: [] },
  { name: 'Close', args: [] },
];

const circularAvatarMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'GetBase', args: [] },
  { name: 'PushMask', args: ['mask'] },
  { name: 'PopMask', args: [] },
  { name: 'OnSizeChanged', args: ['w', 'h'] },
  { name: 'Paint', args: ['w', 'h'] },
  { name: 'SetPlayer', args: ['pl', 'size'] },
];

const noticeMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'RecalcSize', args: [] },
  { name: 'SetText', args: ['text'] },
  { name: 'SetType', args: ['type'] },
  { name: 'Think', args: [] },
  { name: 'Paint', args: ['w', 'h'] },
];

const noticePanelMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'CalcWidth', args: ['padding'] },
  { name: 'Paint', args: ['w', 'h'] },
];

const checkboxMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetTxt', args: ['text'] },
  { name: 'SetValue', args: ['val'] },
  { name: 'SetChecked', args: ['val'] },
  { name: 'GetChecked', args: [] },
  { name: 'IsChecked', args: [] },
  { name: 'Toggle', args: [] },
  { name: 'IsEditing', args: [] },
  { name: 'GetBool', args: [] },
  { name: 'SetConvar', args: ['convar'] },
  { name: 'SetDescription', args: ['desc'] },
  { name: 'Paint', args: ['w', 'h'] },
  { name: 'DoClick', args: [] },
  { name: 'OnChange', args: ['value'] },
];

const comboBoxMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'AddChoice', args: ['text', 'data', 'tooltip'] },
  { name: 'AddSpacer', args: ['text'] },
  { name: 'SetValue', args: ['val'] },
  { name: 'ChooseOption', args: ['text', 'index'] },
  { name: 'ChooseOptionID', args: ['index'] },
  { name: 'ChooseOptionData', args: ['data'] },
  { name: 'GetValue', args: [] },
  { name: 'SetPlaceholder', args: ['text'] },
  { name: 'Clear', args: [] },
  { name: 'OpenMenu', args: [] },
  { name: 'CloseMenu', args: [] },
  { name: 'OnRemove', args: [] },
  { name: 'GetOptionData', args: ['index'] },
  { name: 'GetOptionText', args: ['index'] },
  { name: 'GetOptionTextByData', args: ['data'] },
  { name: 'SetConVar', args: ['cvar'] },
  { name: 'GetSelectedID', args: [] },
  { name: 'GetSelectedData', args: [] },
  { name: 'CheckConVarChanges', args: [] },
  { name: 'GetSelectedText', args: [] },
  { name: 'GetSelected', args: [] },
  { name: 'GetSortItems', args: [] },
  { name: 'SetSortItems', args: ['sort'] },
  { name: 'RemoveChoice', args: ['indexOrValue'] },
  { name: 'IsMenuOpen', args: [] },
  { name: 'SetFont', args: ['font'] },
  { name: 'RefreshDropdown', args: [] },
  { name: 'AutoSize', args: [] },
  { name: 'FinishAddingOptions', args: [] },
  { name: 'SetTall', args: ['tall', 'internal'] },
  { name: 'RecalculateSize', args: [] },
  { name: 'PostInit', args: [] },
  { name: 'SetTextColor', args: ['color'] },
  { name: 'GetTextColor', args: [] },
  { name: 'OnSelect', args: ['index', 'text', 'data'] },
  { name: 'OnMenuOpened', args: [] },
];

const entryMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetTitle', args: ['title'] },
  { name: 'SetPlaceholder', args: ['placeholder'] },
  { name: 'SetPlaceholderText', args: ['placeholder'] },
  { name: 'SetValue', args: ['value'] },
  { name: 'SetText', args: ['value'] },
  { name: 'GetValue', args: [] },
  { name: 'SelectAll', args: [] },
  { name: 'SetFont', args: ['font'] },
  { name: 'SetNumeric', args: ['isNumeric'] },
  { name: 'AllowInput', args: ['callback'] },
  { name: 'SetTextColor', args: ['color'] },
  { name: 'GetAutoComplete', args: [] },
  { name: 'GetCursorColor', args: [] },
  { name: 'GetDisabled', args: [] },
  { name: 'GetPaintBackground', args: [] },
  { name: 'GetDrawBorder', args: [] },
  { name: 'GetEnterAllowed', args: [] },
  { name: 'GetFloat', args: [] },
  { name: 'GetHighlightColor', args: [] },
  { name: 'GetHistoryEnabled', args: [] },
  { name: 'GetInt', args: [] },
  { name: 'GetNumeric', args: [] },
  { name: 'GetPlaceholderColor', args: [] },
  { name: 'GetPlaceholderText', args: [] },
  { name: 'GetTabbingDisabled', args: [] },
  { name: 'GetTextColor', args: [] },
  { name: 'GetUpdateOnType', args: [] },
  { name: 'IsEditing', args: [] },
  { name: 'SetCursorColor', args: ['color'] },
  { name: 'SetDisabled', args: ['disabled'] },
  { name: 'SetPaintBackground', args: ['paintBackground'] },
  { name: 'SetDrawBorder', args: ['drawBorder'] },
  { name: 'SetEditable', args: ['editable'] },
  { name: 'SetEnterAllowed', args: ['allowed'] },
  { name: 'SetHighlightColor', args: ['color'] },
  { name: 'SetHistoryEnabled', args: ['enabled'] },
  { name: 'SetPlaceholderColor', args: ['color'] },
  { name: 'SetTabbingDisabled', args: ['disabled'] },
  { name: 'SetUpdateOnType', args: ['update'] },
  { name: 'SetMultiline', args: ['multiline'] },
  { name: 'SetContentAlignment', args: ['align'] },
  { name: 'OnChange', args: [] },
  { name: 'OnGetFocus', args: [] },
  { name: 'OnKeyCode', args: ['code'] },
  { name: 'AddHistory', args: ['value'] },
  { name: 'CheckNumeric', args: [] },
  { name: 'OpenAutoComplete', args: [] },
  { name: 'UpdateConvarValue', args: [] },
  { name: 'UpdateFromHistory', args: [] },
  { name: 'UpdateFromMenu', args: [] },
  { name: 'OnValueChange', args: ['value'] },
  { name: 'OnTextChanged', args: ['value'] },
];

const progressBarMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'GetFraction', args: [] },
  { name: 'SetFraction', args: ['fraction'] },
  { name: 'SetProgress', args: ['startTime', 'endTime'] },
  { name: 'SetText', args: ['text'] },
  { name: 'SetBarColor', args: ['color'] },
  { name: 'SetAsActionBar', args: ['isAction'] },
  { name: 'Paint', args: ['w', 'h'] },
];

const headerPanelMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetLineColor', args: ['color'] },
  { name: 'SetLineWidth', args: ['width'] },
  { name: 'Paint', args: ['w', 'h'] },
];

const scrollPanelMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
];

const horizontalScrollMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetPadding', args: ['padding'] },
  { name: 'GetPadding', args: [] },
  { name: 'GetCanvas', args: [] },
  { name: 'AddItem', args: ['item'] },
  { name: 'OnChildAdded', args: ['child'] },
  { name: 'SizeToContents', args: [] },
  { name: 'GetHBar', args: [] },
  { name: 'OnMouseWheeled', args: ['delta'] },
  { name: 'OnHScroll', args: ['offset'] },
  { name: 'ScrollToChild', args: ['child'] },
  { name: 'PerformLayout', args: [] },
  { name: 'Clear', args: [] },
];

const horizontalScrollBarMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetScroll', args: ['offset'] },
  { name: 'SetHideButtons', args: ['hide'] },
  { name: 'GetHideButtons', args: [] },
  { name: 'OnCursorMoved', args: [] },
  { name: 'Grip', args: [] },
  { name: 'PerformLayout', args: [] },
];

const sheetMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetPlaceholderText', args: ['text'] },
  { name: 'PerformLayout', args: [] },
  { name: 'SetSpacing', args: ['y'] },
  { name: 'SetPadding', args: ['padding'] },
  { name: 'Clear', args: [] },
  { name: 'AddRow', args: ['builder'] },
  { name: 'AddPanelRow', args: ['widget', 'opts'] },
  { name: 'AddTextRow', args: ['data'] },
  { name: 'AddSubsheetRow', args: ['cfg'] },
  { name: 'AddPreviewRow', args: ['data'] },
  { name: 'AddListViewRow', args: ['cfg'] },
  { name: 'AddIconLayoutRow', args: ['cfg'] },
  { name: 'RegisterCustomFilter', args: ['row', 'fn'] },
  { name: 'Refresh', args: [] },
];

const tableMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'AddColumn', args: ['name', 'width', 'align', 'sortable'] },
  { name: 'AddItem', args: ['...'] },
  { name: 'AddLine', args: ['...'] },
  { name: 'AddRow', args: ['...'] },
  { name: 'CreateHeader', args: [] },
  { name: 'CalculateColumnWidths', args: [] },
  { name: 'RebuildRows', args: [] },
  { name: 'RecalculateColumnWidths', args: [] },
  { name: 'SetAction', args: ['func'] },
  { name: 'SetRightClickAction', args: ['func'] },
  { name: 'AddMenuOption', args: ['text', 'callback', 'icon', 'shouldShow'] },
  { name: 'RemoveMenuOption', args: ['text'] },
  { name: 'ClearMenuOptions', args: [] },
  { name: 'Clear', args: [] },
  { name: 'ClearSelection', args: [] },
  { name: 'ClearLines', args: [] },
  { name: 'GetSelectedRow', args: [] },
  { name: 'GetRowCount', args: [] },
  { name: 'RemoveRow', args: ['index'] },
  { name: 'GetLine', args: ['id'] },
  { name: 'OnSizeChanged', args: [] },
  { name: 'SetMinHeight', args: ['height'] },
  { name: 'Paint', args: ['w', 'h'] },
  { name: 'DoDoubleClick', args: ['lineID', 'line'] },
  { name: 'OnRowRightClick', args: ['rowIndex', 'line'] },
  { name: 'OnRowSelected', args: ['rowIndex', 'rowData'] },
  { name: 'OnClickLine', args: ['line', 'isSelected'] },
  { name: 'OnRequestResize', args: ['panel', 'iWidth', 'iHeight'] },
  { name: 'ColumnWidth', args: ['i'] },
  { name: 'DataLayout', args: [] },
  { name: 'DisableScrollbar', args: [] },
  { name: 'FixColumnsLayout', args: [] },
  { name: 'GetCanvas', args: [] },
  { name: 'GetDataHeight', args: [] },
  { name: 'GetDirty', args: [] },
  { name: 'GetHeaderHeight', args: [] },
  { name: 'GetHideHeaders', args: [] },
  { name: 'GetInnerTall', args: [] },
  { name: 'GetMultiSelect', args: [] },
  { name: 'GetSortable', args: [] },
  { name: 'GetSortedID', args: [] },
  { name: 'RemoveLine', args: ['lineID'] },
  { name: 'SortByColumn', args: ['columnIndex', 'desc'] },
  { name: 'SortByColumns', args: ['...'] },
  { name: 'SetDataHeight', args: ['height'] },
  { name: 'SetDirty', args: ['dirty'] },
  { name: 'SetHeaderHeight', args: ['height'] },
  { name: 'SetHideHeaders', args: ['hide'] },
  { name: 'SetMultiSelect', args: ['multi'] },
  { name: 'SetSortable', args: ['sortable'] },
  { name: 'CreateRow', args: ['rowIndex', 'rowData'] },
  { name: 'SetBatchMode', args: ['enabled'] },
  { name: 'CommitBatch', args: [] },
  { name: 'ForceCommit', args: [] },
  { name: 'EnsureCommitted', args: [] },
  { name: 'AddItemsBatch', args: ['itemsArray', 'mapperFunc', 'filterFunc'] },
];

const tabsMethods: MethodSignature[] = [
  { name: 'EnsurePanels', args: [] },
  { name: 'Init', args: [] },
  { name: 'SetTabStyle', args: ['style'] },
  { name: 'SetTabHeight', args: ['height'] },
  { name: 'SetIndicatorHeight', args: ['height'] },
  { name: 'AddTab', args: ['name', 'pan', 'icon', 'callback'] },
  { name: 'AddSheet', args: ['label', 'panel', 'material'] },
  { name: 'CreateNavigationButtons', args: [] },
  { name: 'ScrollTabs', args: ['direction'] },
  { name: 'UpdateTabVisibility', args: [] },
  { name: 'OnMouseWheeled', args: ['delta'] },
  { name: 'OnSizeChanged', args: [] },
  { name: 'Rebuild', args: [] },
  { name: 'PerformLayout', args: [] },
  { name: 'UpdateActiveTabVisual', args: [] },
  { name: 'SetActiveTab', args: ['tab'] },
  { name: 'GetActiveTab', args: [] },
  { name: 'CloseTab', args: ['tab'] },
  { name: 'SortTabsAlphabetically', args: [] },
  { name: 'SetTabOrder', args: ['order'] },
  { name: 'ApplyTabOrdering', args: [] },
  { name: 'SetFadeTime', args: [] },
  { name: 'SetShowIcons', args: [] },
  { name: 'Clear', args: [] },
];

const tabButtonMethods: MethodSignature[] = [
  { name: 'Init', args: [] },
  { name: 'SetText', args: ['text'] },
  { name: 'GetText', args: [] },
  { name: 'OnMousePressed', args: ['keyCode'] },
  { name: 'OnMouseReleased', args: [] },
  { name: 'OnCursorEntered', args: [] },
  { name: 'OnCursorExited', args: [] },
  { name: 'DoClick', args: [] },
  { name: 'SetDoClick', args: ['callback'] },
  { name: 'OnRemove', args: [] },
  { name: 'SetIcon', args: ['icon'] },
  { name: 'GetIcon', args: [] },
  { name: 'SetActive', args: ['state'] },
  { name: 'IsActive', args: [] },
  { name: 'SetIndicatorHeight', args: ['height'] },
  { name: 'Paint', args: ['w', 'h'] },
];

const modelPanelOptions: LiaOptionDefinition[] = [
  { key: 'model', label: 'Model Path', input: 'string', defaultValue: 'models/player/kleiner.mdl', placeholder: 'models/player/kleiner.mdl' },
  { key: 'fov', label: 'FOV', input: 'number', defaultValue: 50, min: 1, max: 179, step: 1 },
  { key: 'brightness', label: 'Brightness', input: 'number', defaultValue: 1, min: 0, max: 4, step: 0.05 },
  { key: 'copyLocalSequence', label: 'Copy Local Player Sequence', input: 'boolean', defaultValue: false },
  { key: 'enableHook', label: 'Enable DrawLiliaModelView Hook', input: 'boolean', defaultValue: false },
];

const spawnIconOptions: LiaOptionDefinition[] = [
  { key: 'model', label: 'Model Path', input: 'string', defaultValue: 'models/player/kleiner.mdl', placeholder: 'models/player/kleiner.mdl' },
  { key: 'skin', label: 'Skin', input: 'number', defaultValue: 0, min: 0, step: 1 },
  { key: 'hidden', label: 'Hidden / Blacked Out', input: 'boolean', defaultValue: false },
];


const voicePanelOptions: LiaOptionDefinition[] = [
  { key: 'client', label: 'Client Lua Expression', input: 'string', defaultValue: 'LocalPlayer()', placeholder: 'LocalPlayer()' },
  { key: 'voiceLevel', label: 'Voice Level', input: 'number', defaultValue: 0.7, min: 0, max: 1, step: 0.05 },
  { key: 'voiceType', label: 'Voice Type Preview', input: 'select', defaultValue: 'talking', choices: [
    { label: 'Whispering', value: 'whispering' },
    { label: 'Talking', value: 'talking' },
    { label: 'Yelling', value: 'yelling' },
  ] },
];

const lockCircleOptions: LiaOptionDefinition[] = [
  { key: 'duration', label: 'Duration', input: 'number', defaultValue: 8, min: 0.01, step: 0.1 },
  { key: 'uppercase', label: 'Uppercase Text', input: 'boolean', defaultValue: true },
  { key: 'holdTime', label: 'Hold Time', input: 'number', defaultValue: 1, min: 0, step: 0.1 },
  { key: 'color', label: 'Progress Color Lua Expression', input: 'string', defaultValue: '', placeholder: 'lia.color.theme.accent' },
  { key: 'background', label: 'Background Color Lua Expression', input: 'string', defaultValue: '', placeholder: 'Color(25, 28, 35, 180)' },
  { key: 'textColor', label: 'Text Color Lua Expression', input: 'string', defaultValue: '', placeholder: 'color_white' },
  { key: 'percentFont', label: 'Percent Font', input: 'string', defaultValue: 'LiliaFont.24b' },
  { key: 'labelFont', label: 'Label Font', input: 'string', defaultValue: 'LiliaFont.18b' },
  { key: 'radius', label: 'Radius Lua Expression', input: 'string', defaultValue: '', placeholder: '48' },
  { key: 'thickness', label: 'Thickness Lua Expression', input: 'string', defaultValue: '', placeholder: '12' },
  { key: 'startAngle', label: 'Start Angle', input: 'number', defaultValue: -90, step: 1 },
  { key: 'position', label: 'Position Lua Expression', input: 'string', defaultValue: '', placeholder: '{x = ScrW() * 0.5, y = ScrH() * 0.8}' },
];

const dermaMenuOptions: LiaOptionDefinition[] = [
  { key: 'items', label: 'Menu Items', input: 'textarea', defaultValue: 'Primary action|icon16/accept.png\nSecondary action|icon16/information.png\n#spacer\nSubmenu|icon16/folder.png', placeholder: 'Label|icon16/path.png\n#spacer' },
  { key: 'deleteSelf', label: 'Delete Self On Close', input: 'boolean', defaultValue: true },
  { key: 'maxHeight', label: 'Maximum Height Lua Value', input: 'string', defaultValue: '', placeholder: '300' },
  { key: 'drawBorder', label: 'Draw Border', input: 'boolean', defaultValue: false },
  { key: 'drawColumn', label: 'Draw Icon Column', input: 'boolean', defaultValue: false },
  { key: 'minimumWidth', label: 'Minimum Width', input: 'number', defaultValue: 120, min: 0, step: 1 },
  { key: 'padding', label: 'Padding', input: 'number', defaultValue: 6, min: 0, step: 1 },
];

const circularAvatarOptions: LiaOptionDefinition[] = [
  { key: 'player', label: 'Player Lua Expression', input: 'string', defaultValue: 'LocalPlayer()', placeholder: 'LocalPlayer()' },
  { key: 'avatarSize', label: 'Avatar Resolution', input: 'number', defaultValue: 128, min: 16, max: 2048, step: 1 },
];

const noticeOptions: LiaOptionDefinition[] = [
  {
    key: 'type',
    label: 'Notification Type',
    input: 'select',
    defaultValue: 'default',
    choices: [
      { label: 'Default', value: 'default' },
      { label: 'Info', value: 'info' },
      { label: 'Error', value: 'error' },
      { label: 'Success', value: 'success' },
      { label: 'Warning', value: 'warning' },
      { label: 'Money', value: 'money' },
      { label: 'Admin', value: 'admin' },
    ],
  },
  { key: 'targetY', label: 'Target Y', input: 'number', defaultValue: 80, step: 1 },
];

const noticePanelOptions: LiaOptionDefinition[] = [
  { key: 'calcPadding', label: 'Calculated Width Padding', input: 'number', defaultValue: 80, min: 0, step: 1 },
  { key: 'padding', label: 'Padding Field', input: 'number', defaultValue: 80, min: 0, step: 1 },
  { key: 'start', label: 'Start Time Lua Expression', input: 'string', defaultValue: 'CurTime()', placeholder: 'CurTime()' },
  { key: 'endTime', label: 'End Time Lua Expression', input: 'string', defaultValue: 'CurTime() + 8', placeholder: 'CurTime() + 8' },
];

const checkboxOptions: LiaOptionDefinition[] = [
  { key: 'checked', label: 'Checked', input: 'boolean', defaultValue: false },
  { key: 'convar', label: 'ConVar', input: 'string', defaultValue: '', placeholder: 'optional_convar' },
  { key: 'description', label: 'Description / Tooltip', input: 'string', defaultValue: '', placeholder: 'Optional tooltip text' },
];

const comboBoxOptions: LiaOptionDefinition[] = [
  { key: 'items', label: 'Choices / Spacers', input: 'textarea', defaultValue: '', placeholder: 'Label|data|tooltip\n#spacer|Section\nAnother Choice|2' },
  { key: 'selected', label: 'Selected Value', input: 'string', defaultValue: '', placeholder: 'Optional selected label' },
  { key: 'placeholder', label: 'Placeholder', input: 'string', defaultValue: 'Select an option' },
  { key: 'convar', label: 'ConVar', input: 'string', defaultValue: '', placeholder: 'optional_convar' },
  { key: 'sortItems', label: 'Sort Items', input: 'boolean', defaultValue: false },
  { key: 'font', label: 'Font', input: 'string', defaultValue: 'LiliaFont.18' },
  { key: 'textColor', label: 'Text Color', input: 'color', defaultValue: '#e1eeee' },
];

const entryOptions: LiaOptionDefinition[] = [
  { key: 'title', label: 'Title', input: 'string', defaultValue: '', placeholder: 'Optional title' },
  { key: 'placeholder', label: 'Placeholder', input: 'string', defaultValue: 'Enter text' },
  { key: 'font', label: 'Font', input: 'string', defaultValue: 'LiliaFont.18' },
  { key: 'numeric', label: 'Numeric Only', input: 'boolean', defaultValue: false },
  { key: 'textColor', label: 'Text Color', input: 'color', defaultValue: '#e1eeee' },
  { key: 'cursorColor', label: 'Cursor Color', input: 'color', defaultValue: '#64c8c8' },
  { key: 'disabled', label: 'Disabled', input: 'boolean', defaultValue: false },
  { key: 'paintBackground', label: 'Paint Background', input: 'boolean', defaultValue: false },
  { key: 'drawBorder', label: 'Draw Native Border', input: 'boolean', defaultValue: false },
  { key: 'editable', label: 'Editable', input: 'boolean', defaultValue: true },
  { key: 'enterAllowed', label: 'Enter Allowed', input: 'boolean', defaultValue: true },
  { key: 'highlightColor', label: 'Highlight Color', input: 'color', defaultValue: '#407878' },
  { key: 'historyEnabled', label: 'History Enabled', input: 'boolean', defaultValue: false },
  { key: 'placeholderColor', label: 'Placeholder Color', input: 'color', defaultValue: '#c8c8c8' },
  { key: 'tabbingDisabled', label: 'Tabbing Disabled', input: 'boolean', defaultValue: false },
  { key: 'updateOnType', label: 'Update On Type', input: 'boolean', defaultValue: false },
  { key: 'multiline', label: 'Multiline', input: 'boolean', defaultValue: false },
  {
    key: 'contentAlignment',
    label: 'Content Alignment',
    input: 'select',
    defaultValue: 0,
    choices: [
      { label: 'Left', value: 0 },
      { label: 'Center', value: 5 },
    ],
  },
];

const progressBarOptions: LiaOptionDefinition[] = [
  { key: 'fraction', label: 'Fraction', input: 'number', defaultValue: 0.5, min: 0, max: 1, step: 0.01 },
  { key: 'barColor', label: 'Bar Color', input: 'color', defaultValue: '#2dbdaa' },
  { key: 'actionBar', label: 'Action Bar Mode', input: 'boolean', defaultValue: false },
];

const headerPanelOptions: LiaOptionDefinition[] = [
  { key: 'lineColor', label: 'Line Color', input: 'color', defaultValue: '#2dbdaa' },
  { key: 'lineWidth', label: 'Line Width', input: 'number', defaultValue: 1, min: 0, step: 1 },
];

const horizontalScrollOptions: LiaOptionDefinition[] = [
  { key: 'padding', label: 'Padding', input: 'number', defaultValue: 0, min: 0, step: 1 },
];

const horizontalScrollBarOptions: LiaOptionDefinition[] = [
  { key: 'scroll', label: 'Scroll Offset', input: 'number', defaultValue: 0, min: 0, step: 1 },
  { key: 'hideButtons', label: 'Hide Arrow Buttons', input: 'boolean', defaultValue: false },
];

const sheetOptions: LiaOptionDefinition[] = [
  { key: 'placeholderText', label: 'Search Placeholder', input: 'string', defaultValue: '', placeholder: 'Search...' },
  { key: 'spacing', label: 'Row Spacing', input: 'number', defaultValue: 8, min: 0, step: 1 },
  { key: 'padding', label: 'Row Padding', input: 'number', defaultValue: 10, min: 0, step: 1 },
];

const tableOptions: LiaOptionDefinition[] = [
  { key: 'headerHeight', label: 'Header Height', input: 'number', defaultValue: 36, min: 0, step: 1 },
  { key: 'dataHeight', label: 'Data Height Override', input: 'number', defaultValue: 0, min: 0, step: 1 },
  { key: 'hideHeaders', label: 'Hide Headers', input: 'boolean', defaultValue: false },
  { key: 'multiSelect', label: 'Multi Select', input: 'boolean', defaultValue: false },
  { key: 'sortable', label: 'Columns Sortable', input: 'boolean', defaultValue: true },
  { key: 'minHeight', label: 'Minimum Height', input: 'number', defaultValue: 0, min: 0, step: 1 },
  { key: 'dirty', label: 'Dirty State', input: 'boolean', defaultValue: false },
  { key: 'batchMode', label: 'Batch Mode', input: 'boolean', defaultValue: true },
];

const tabsOptions: LiaOptionDefinition[] = [
  {
    key: 'tabStyle',
    label: 'Tab Style',
    input: 'select',
    defaultValue: 'modern',
    choices: [
      { label: 'Modern', value: 'modern' },
      { label: 'Classic', value: 'classic' },
    ],
  },
  { key: 'tabHeight', label: 'Tab Height', input: 'number', defaultValue: 38, min: 1, step: 1 },
  { key: 'indicatorHeight', label: 'Indicator Height', input: 'number', defaultValue: 2, min: 0, step: 1 },
];

const tabButtonOptions: LiaOptionDefinition[] = [
  { key: 'icon', label: 'Icon Material', input: 'string', defaultValue: '', placeholder: 'icon16/application.png' },
  { key: 'active', label: 'Active', input: 'boolean', defaultValue: false },
  { key: 'indicatorHeight', label: 'Indicator Height', input: 'number', defaultValue: 2, min: 0, step: 1 },
];

const frameOptions: LiaOptionDefinition[] = [
  { key: 'alphaBackground', label: 'Alpha Background', input: 'boolean', defaultValue: true },
  { key: 'centerTitle', label: 'Centered Subtitle', input: 'string', defaultValue: '', placeholder: 'Optional centered subtitle' },
  { key: 'showCloseButton', label: 'Show Close Button', input: 'boolean', defaultValue: true },
  { key: 'sizable', label: 'Sizable', input: 'boolean', defaultValue: false },
  { key: 'deleteOnClose', label: 'Delete On Close', input: 'boolean', defaultValue: true },
  { key: 'screenLock', label: 'Screen Lock', input: 'boolean', defaultValue: false },
  { key: 'backgroundBlur', label: 'Background Blur', input: 'boolean', defaultValue: false },
  { key: 'minWidth', label: 'Minimum Width', input: 'number', defaultValue: 120, min: 0, step: 1 },
  { key: 'minHeight', label: 'Minimum Height', input: 'number', defaultValue: 80, min: 0, step: 1 },
  { key: 'icon', label: 'Icon Material', input: 'string', defaultValue: '', placeholder: 'icon16/application.png' },
  { key: 'draggable', label: 'Draggable', input: 'boolean', defaultValue: true },
  { key: 'liteMode', label: 'Lite Mode', input: 'boolean', defaultValue: false },
];

const sliderOptions: LiaOptionDefinition[] = [
  { key: 'min', label: 'Minimum', input: 'number', defaultValue: 0, step: 0.01 },
  { key: 'max', label: 'Maximum', input: 'number', defaultValue: 1, step: 0.01 },
  { key: 'decimals', label: 'Decimals', input: 'number', defaultValue: 0, min: 0, max: 8, step: 1 },
  { key: 'value', label: 'Value', input: 'number', defaultValue: 0, step: 0.01 },
  { key: 'convar', label: 'ConVar', input: 'string', defaultValue: '', placeholder: 'optional_convar' },
];

const liaButtonOptions: LiaOptionDefinition[] = [
  { key: 'hoverEnabled', label: 'Hover Enabled', input: 'boolean', defaultValue: true },
  { key: 'font', label: 'Font', input: 'string', defaultValue: 'LiliaFont.18' },
  { key: 'radius', label: 'Radius', input: 'number', defaultValue: 12, min: 0, step: 1 },
  { key: 'icon', label: 'Icon Material', input: 'string', defaultValue: '', placeholder: 'icon16/star.png' },
  { key: 'iconSize', label: 'Icon Size', input: 'number', defaultValue: 16, min: 0, step: 1 },
  { key: 'baseColor', label: 'Base Color', input: 'color', defaultValue: '#0d1e23' },
  { key: 'hoverColor', label: 'Hover Color', input: 'color', defaultValue: '#102228' },
  { key: 'textColor', label: 'Text Color', input: 'color', defaultValue: '#e1eeee' },
  { key: 'gradient', label: 'Gradient', input: 'boolean', defaultValue: false },
  { key: 'ripple', label: 'Ripple', input: 'boolean', defaultValue: false },
];

const makeVariant = (
  type: ComponentType,
  description: string,
  font: string,
  h: number,
  noBackground = false,
): LiaComponentDefinition => ({
  type,
  description,
  base: 'DButton',
  size: { w: 220, h },
  defaultText: type,
  defaultOptions: {
    font,
    selected: false,
    showLine: false,
    textColor: '#e1eeee',
    noBackground,
  },
  options: [
    { key: 'font', label: 'Font', input: 'string', defaultValue: font },
    { key: 'selected', label: 'Selected', input: 'boolean', defaultValue: false },
    { key: 'showLine', label: 'Show Selection Line', input: 'boolean', defaultValue: false },
    { key: 'textColor', label: 'Text Color', input: 'color', defaultValue: '#e1eeee' },
  ],
  setters: [
    { method: 'SetText', keys: ['text'], source: 'props', alwaysEmit: true },
    { method: 'SetFont', keys: ['font'] },
    { method: 'SetSelected', keys: ['selected'] },
    { method: 'SetShowLine', keys: ['showLine'] },
    { method: 'SetTextColor', keys: ['textColor'] },
  ],
  methods: variantButtonMethods,
  preview: 'button',
});

export const LIA_COMPONENT_DEFINITIONS: Partial<Record<ComponentType, LiaComponentDefinition>> = {
  [ComponentType.liaFrame]: {
    type: ComponentType.liaFrame,
    description: 'Lilia window frame with custom title bar, sizing, blur, close behavior, icon support, and lite mode.',
    base: 'EditablePanel',
    size: { w: 600, h: 400 },
    defaultText: 'Lilia Window',
    defaultOptions: Object.fromEntries(frameOptions.map(option => [option.key, option.defaultValue])),
    options: frameOptions,
    setters: [
      { method: 'SetTitle', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetAlphaBackground', keys: ['alphaBackground'] },
      { method: 'SetCenterTitle', keys: ['centerTitle'] },
      { method: 'ShowCloseButton', keys: ['showCloseButton'] },
      { method: 'SetSizable', keys: ['sizable'] },
      { method: 'SetDeleteOnClose', keys: ['deleteOnClose'] },
      { method: 'SetScreenLock', keys: ['screenLock'] },
      { method: 'SetBackgroundBlur', keys: ['backgroundBlur'] },
      { method: 'SetMinWidth', keys: ['minWidth'] },
      { method: 'SetMinHeight', keys: ['minHeight'] },
      { method: 'SetIcon', keys: ['icon'] },
      { method: 'SetDraggable', keys: ['draggable'] },
      { method: 'LiteMode', keys: ['liteMode'] },
    ],
    methods: commonFrameMethods,
    root: true,
    container: true,
    preview: 'frame',
  },
  [ComponentType.liaSlider]: {
    type: ComponentType.liaSlider,
    description: 'Lilia numeric slider with range, decimal precision, value, and optional ConVar synchronization.',
    base: 'Panel',
    size: { w: 220, h: 20 },
    defaultOptions: Object.fromEntries(sliderOptions.map(option => [option.key, option.defaultValue])),
    options: sliderOptions,
    setters: [
      { method: 'SetRange', keys: ['min', 'max', 'decimals'], alwaysEmit: true },
      { method: 'SetValue', keys: ['value'], alwaysEmit: true },
      { method: 'SetConvar', keys: ['convar'] },
    ],
    methods: sliderMethods,
    preview: 'slider',
  },
  [ComponentType.liaSlideBox]: {
    type: ComponentType.liaSlideBox,
    description: 'Lilia labeled slider box with range, precision, value, and optional ConVar synchronization.',
    base: 'Panel',
    size: { w: 260, h: 60 },
    defaultText: 'Slider',
    defaultOptions: Object.fromEntries(sliderOptions.map(option => [option.key, option.defaultValue])),
    options: sliderOptions,
    setters: [
      { method: 'SetText', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetRange', keys: ['min', 'max', 'decimals'], alwaysEmit: true },
      { method: 'SetValue', keys: ['value'], alwaysEmit: true },
      { method: 'SetConvar', keys: ['convar'] },
    ],
    methods: slideBoxMethods,
    preview: 'slidebox',
  },
  [ComponentType.liaButton]: {
    type: ComponentType.liaButton,
    description: 'Primary Lilia button with radius, icon, colors, hover behavior, gradient, and ripple controls.',
    base: 'Button',
    size: { w: 180, h: 36 },
    defaultText: 'Button',
    defaultOptions: Object.fromEntries(liaButtonOptions.map(option => [option.key, option.defaultValue])),
    options: liaButtonOptions,
    setters: [
      { method: 'SetText', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetHover', keys: ['hoverEnabled'] },
      { method: 'SetFont', keys: ['font'] },
      { method: 'SetRadius', keys: ['radius'] },
      { method: 'SetIcon', keys: ['icon', 'iconSize'] },
      { method: 'SetColor', keys: ['baseColor'] },
      { method: 'SetColorHover', keys: ['hoverColor'] },
      { method: 'SetTextColor', keys: ['textColor'] },
      { method: 'SetGradient', keys: ['gradient'] },
      { method: 'SetRipple', keys: ['ripple'] },
    ],
    methods: liaButtonMethods,
    preview: 'button',
  },
  [ComponentType.liaHugeButton]: makeVariant(ComponentType.liaHugeButton, 'Lilia extra-large text button using LiliaFont.72.', 'LiliaFont.72', 88),
  [ComponentType.liaBigButton]: makeVariant(ComponentType.liaBigButton, 'Lilia large text button using LiliaFont.36.', 'LiliaFont.36', 58),
  [ComponentType.liaMediumButton]: makeVariant(ComponentType.liaMediumButton, 'Lilia medium text button using LiliaFont.25.', 'LiliaFont.25', 46),
  [ComponentType.liaSmallButton]: makeVariant(ComponentType.liaSmallButton, 'Lilia small text button using LiliaFont.17.', 'LiliaFont.17', 34),
  [ComponentType.liaMiniButton]: makeVariant(ComponentType.liaMiniButton, 'Lilia compact text button using LiliaFont.14.', 'LiliaFont.14', 28),
  [ComponentType.liaNoBGButton]: makeVariant(ComponentType.liaNoBGButton, 'Lilia large button variant without the standard background shell.', 'LiliaFont.36', 52, true),
  [ComponentType.liaCustomFontButton]: makeVariant(ComponentType.liaCustomFontButton, 'Lilia button variant intended for custom font selection.', 'LiliaFont.17', 36),
  [ComponentType.liaCheckbox]: {
    type: ComponentType.liaCheckbox,
    description: 'Lilia animated toggle checkbox with text, checked state, ConVar binding, tooltip description, and change callback support.',
    base: 'Panel',
    size: { w: 160, h: 28 },
    defaultText: 'Checkbox',
    defaultOptions: Object.fromEntries(checkboxOptions.map(option => [option.key, option.defaultValue])),
    options: checkboxOptions,
    setters: [
      { method: 'SetTxt', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetChecked', keys: ['checked'], alwaysEmit: true },
      { method: 'SetConvar', keys: ['convar'] },
      { method: 'SetDescription', keys: ['description'] },
    ],
    methods: checkboxMethods,
    preview: 'checkbox',
  },
  [ComponentType.liaComboBox]: {
    type: ComponentType.liaComboBox,
    description: 'Lilia themed dropdown with repeatable choices and spacers, selected value, placeholder, ConVar binding, sorting, font, and text color.',
    base: 'Panel',
    size: { w: 200, h: 32 },
    defaultOptions: Object.fromEntries(comboBoxOptions.map(option => [option.key, option.defaultValue])),
    options: comboBoxOptions,
    setters: [
      { method: 'SetValue', keys: ['selected'] },
      { method: 'SetPlaceholder', keys: ['placeholder'], alwaysEmit: true },
      { method: 'SetConVar', keys: ['convar'] },
      { method: 'SetSortItems', keys: ['sortItems'], alwaysEmit: true },
      { method: 'SetFont', keys: ['font'], alwaysEmit: true },
      { method: 'SetTextColor', keys: ['textColor'], alwaysEmit: true },
    ],
    repeaters: [{ key: 'items', format: 'comboItems', finalizeMethod: 'FinishAddingOptions' }],
    methods: comboBoxMethods,
    preview: 'combobox',
  },
  [ComponentType.liaEntry]: {
    type: ComponentType.liaEntry,
    description: 'Lilia text entry wrapper with title, placeholder, font, numeric/editing controls, native text-entry flags, colors, multiline mode, and alignment.',
    base: 'EditablePanel',
    size: { w: 240, h: 32 },
    defaultText: '',
    defaultOptions: Object.fromEntries(entryOptions.map(option => [option.key, option.defaultValue])),
    options: entryOptions,
    setters: [
      { method: 'SetValue', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetTitle', keys: ['title'] },
      { method: 'SetPlaceholderText', keys: ['placeholder'], alwaysEmit: true },
      { method: 'SetFont', keys: ['font'], alwaysEmit: true },
      { method: 'SetNumeric', keys: ['numeric'], alwaysEmit: true },
      { method: 'SetTextColor', keys: ['textColor'], alwaysEmit: true },
      { method: 'SetCursorColor', keys: ['cursorColor'], alwaysEmit: true },
      { method: 'SetDisabled', keys: ['disabled'], alwaysEmit: true },
      { method: 'SetPaintBackground', keys: ['paintBackground'], alwaysEmit: true },
      { method: 'SetDrawBorder', keys: ['drawBorder'], alwaysEmit: true },
      { method: 'SetEditable', keys: ['editable'], alwaysEmit: true },
      { method: 'SetEnterAllowed', keys: ['enterAllowed'], alwaysEmit: true },
      { method: 'SetHighlightColor', keys: ['highlightColor'], alwaysEmit: true },
      { method: 'SetHistoryEnabled', keys: ['historyEnabled'], alwaysEmit: true },
      { method: 'SetPlaceholderColor', keys: ['placeholderColor'], alwaysEmit: true },
      { method: 'SetTabbingDisabled', keys: ['tabbingDisabled'], alwaysEmit: true },
      { method: 'SetUpdateOnType', keys: ['updateOnType'], alwaysEmit: true },
      { method: 'SetMultiline', keys: ['multiline'], alwaysEmit: true },
      { method: 'SetContentAlignment', keys: ['contentAlignment'], alwaysEmit: true },
    ],
    methods: entryMethods,
    preview: 'entry',
  },
  [ComponentType.liaProgressBar]: {
    type: ComponentType.liaProgressBar,
    description: 'Lilia progress bar with manual fraction, label text, themed fill color, and action-bar presentation mode.',
    base: 'DPanel',
    size: { w: 260, h: 40 },
    defaultText: 'Progress',
    defaultOptions: Object.fromEntries(progressBarOptions.map(option => [option.key, option.defaultValue])),
    options: progressBarOptions,
    setters: [
      { method: 'SetText', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetFraction', keys: ['fraction'], alwaysEmit: true },
      { method: 'SetBarColor', keys: ['barColor'], alwaysEmit: true },
      { method: 'SetAsActionBar', keys: ['actionBar'], alwaysEmit: true },
    ],
    methods: progressBarMethods,
    preview: 'progress',
  },
  [ComponentType.liaHeaderPanel]: {
    type: ComponentType.liaHeaderPanel,
    description: 'Lilia header/divider panel with configurable line color and line width.',
    base: 'Panel',
    size: { w: 260, h: 24 },
    defaultOptions: Object.fromEntries(headerPanelOptions.map(option => [option.key, option.defaultValue])),
    options: headerPanelOptions,
    setters: [
      { method: 'SetLineColor', keys: ['lineColor'], alwaysEmit: true },
      { method: 'SetLineWidth', keys: ['lineWidth'], alwaysEmit: true },
    ],
    methods: headerPanelMethods,
    container: true,
    preview: 'header',
  },

  [ComponentType.liaScrollPanel]: {
    type: ComponentType.liaScrollPanel,
    description: 'Lilia themed DScrollPanel with a narrow custom vertical scrollbar and themed grip.',
    base: 'DScrollPanel',
    size: { w: 260, h: 180 },
    defaultOptions: {},
    options: [],
    setters: [],
    methods: scrollPanelMethods,
    container: true,
    preview: 'scroll',
  },
  [ComponentType.liaHorizontalScroll]: {
    type: ComponentType.liaHorizontalScroll,
    description: 'Lilia horizontal scrolling container with an internal canvas, mouse-wheel forwarding, child scrolling, and configurable padding.',
    base: 'DPanel',
    size: { w: 320, h: 120 },
    defaultOptions: Object.fromEntries(horizontalScrollOptions.map(option => [option.key, option.defaultValue])),
    options: horizontalScrollOptions,
    setters: [
      { method: 'SetPadding', keys: ['padding'], alwaysEmit: true },
    ],
    methods: horizontalScrollMethods,
    container: true,
    preview: 'horizontalScroll',
  },
  [ComponentType.liaHorizontalScrollBar]: {
    type: ComponentType.liaHorizontalScrollBar,
    description: 'Lilia horizontal scrollbar derived from DVScrollBar with horizontal grip movement, scroll offset control, and optional arrow buttons.',
    base: 'DVScrollBar',
    size: { w: 260, h: 16 },
    defaultOptions: Object.fromEntries(horizontalScrollBarOptions.map(option => [option.key, option.defaultValue])),
    options: horizontalScrollBarOptions,
    setters: [
      { method: 'SetHideButtons', keys: ['hideButtons'], alwaysEmit: true },
      { method: 'SetScroll', keys: ['scroll'], alwaysEmit: true },
    ],
    methods: horizontalScrollBarMethods,
    preview: 'horizontalScrollBar',
  },
  [ComponentType.liaSheet]: {
    type: ComponentType.liaSheet,
    description: 'Lilia searchable settings sheet with configurable row spacing/padding and helpers for text, panels, subsheets, previews, list views, and icon layouts.',
    base: 'DPanel',
    size: { w: 420, h: 320 },
    defaultOptions: Object.fromEntries(sheetOptions.map(option => [option.key, option.defaultValue])),
    options: sheetOptions,
    setters: [
      { method: 'SetPlaceholderText', keys: ['placeholderText'], alwaysEmit: true },
      { method: 'SetSpacing', keys: ['spacing'], alwaysEmit: true },
      { method: 'SetPadding', keys: ['padding'], alwaysEmit: true },
    ],
    methods: sheetMethods,
    preview: 'sheet',
  },
  [ComponentType.liaTable]: {
    type: ComponentType.liaTable,
    description: 'Lilia data table with sortable columns, selection, custom row actions, context-menu options, batch insertion, and layout/query helpers.',
    base: 'Panel',
    size: { w: 520, h: 300 },
    defaultOptions: Object.fromEntries(tableOptions.map(option => [option.key, option.defaultValue])),
    options: tableOptions,
    setters: [
      { method: 'SetHeaderHeight', keys: ['headerHeight'], alwaysEmit: true },
      { method: 'SetDataHeight', keys: ['dataHeight'] },
      { method: 'SetHideHeaders', keys: ['hideHeaders'], alwaysEmit: true },
      { method: 'SetMultiSelect', keys: ['multiSelect'], alwaysEmit: true },
      { method: 'SetSortable', keys: ['sortable'], alwaysEmit: true },
      { method: 'SetMinHeight', keys: ['minHeight'] },
      { method: 'SetDirty', keys: ['dirty'], alwaysEmit: true },
      { method: 'SetBatchMode', keys: ['batchMode'], alwaysEmit: true },
    ],
    methods: tableMethods,
    preview: 'table',
  },
  [ComponentType.liaTabs]: {
    type: ComponentType.liaTabs,
    description: 'Lilia tab manager supporting modern/classic layouts, tab sizing, indicator sizing, navigation, active-tab control, ordering, closing, and sorting.',
    base: 'Panel',
    size: { w: 520, h: 320 },
    defaultOptions: Object.fromEntries(tabsOptions.map(option => [option.key, option.defaultValue])),
    options: tabsOptions,
    setters: [
      { method: 'SetTabStyle', keys: ['tabStyle'], alwaysEmit: true },
      { method: 'SetTabHeight', keys: ['tabHeight'], alwaysEmit: true },
      { method: 'SetIndicatorHeight', keys: ['indicatorHeight'], alwaysEmit: true },
    ],
    methods: tabsMethods,
    preview: 'tabs',
  },
  [ComponentType.liaTabButton]: {
    type: ComponentType.liaTabButton,
    description: 'Lilia tab button with text, optional material icon, active state, indicator height, and click callback support.',
    base: 'DPanel',
    size: { w: 120, h: 34 },
    defaultText: 'Tab',
    defaultOptions: Object.fromEntries(tabButtonOptions.map(option => [option.key, option.defaultValue])),
    options: tabButtonOptions,
    setters: [
      { method: 'SetText', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetIcon', keys: ['icon'] },
      { method: 'SetActive', keys: ['active'], alwaysEmit: true },
      { method: 'SetIndicatorHeight', keys: ['indicatorHeight'], alwaysEmit: true },
    ],
    methods: tabButtonMethods,
    preview: 'tabButton',
  },
  [ComponentType.liaModelPanel]: {
    type: ComponentType.liaModelPanel,
    description: 'Lilia DModelPanel with idle-sequence setup, head tracking, configurable model/FOV/brightness, local-sequence copying, draw-hook support, and automatic FOV fitting.',
    base: 'DModelPanel',
    size: { w: 320, h: 380 },
    defaultOptions: Object.fromEntries(modelPanelOptions.map(option => [option.key, option.defaultValue])),
    options: modelPanelOptions,
    setters: [
      { method: 'SetModel', keys: ['model'], alwaysEmit: true },
      { method: 'SetFOV', keys: ['fov'], alwaysEmit: true },
      { method: 'brightness', keys: ['brightness'], kind: 'assign', target: 'brightness', alwaysEmit: true },
      { method: 'copyLocalSequence', keys: ['copyLocalSequence'], kind: 'assign', target: 'copyLocalSequence', alwaysEmit: true },
      { method: 'enableHook', keys: ['enableHook'], kind: 'assign', target: 'enableHook', alwaysEmit: true },
    ],
    methods: modelPanelMethods,
    preview: 'model',
  },
  [ComponentType.liaSpawnIcon]: {
    type: ComponentType.liaSpawnIcon,
    description: 'Lilia spawn icon model preview with automatic model framing, skin selection, item visual updates, directional lighting, and hidden/blackout mode.',
    base: 'DModelPanel',
    size: { w: 180, h: 180 },
    defaultOptions: Object.fromEntries(spawnIconOptions.map(option => [option.key, option.defaultValue])),
    options: spawnIconOptions,
    setters: [
      { method: 'SetModel', keys: ['model', 'skin'], alwaysEmit: true },
      { method: 'setHidden', keys: ['hidden'], alwaysEmit: true },
    ],
    methods: spawnIconMethods,
    preview: 'spawnIcon',
  },
  [ComponentType.CircularAvatar]: {
    type: ComponentType.CircularAvatar,
    description: 'Circular masked AvatarImage wrapper with direct access to the underlying avatar and configurable player/resolution.',
    base: 'Panel',
    size: { w: 128, h: 128 },
    defaultOptions: Object.fromEntries(circularAvatarOptions.map(option => [option.key, option.defaultValue])),
    options: circularAvatarOptions,
    setters: [
      { method: 'SetPlayer', keys: ['player', 'avatarSize'], rawKeys: ['player'], alwaysEmit: true },
    ],
    methods: circularAvatarMethods,
    preview: 'avatar',
  },
  [ComponentType.liaNotice]: {
    type: ComponentType.liaNotice,
    description: 'Animated Lilia notification with automatic text sizing, notification type/icon/color selection, slide/fade behavior, and target stack position.',
    base: 'DPanel',
    size: { w: 320, h: 48 },
    defaultText: 'Notification',
    defaultOptions: Object.fromEntries(noticeOptions.map(option => [option.key, option.defaultValue])),
    options: noticeOptions,
    setters: [
      { method: 'SetText', keys: ['text'], source: 'props', alwaysEmit: true },
      { method: 'SetType', keys: ['type'], alwaysEmit: true },
      { method: 'targetY', keys: ['targetY'], kind: 'assign', target: 'targetY', alwaysEmit: true },
    ],
    methods: noticeMethods,
    preview: 'notice',
  },
  [ComponentType.liaNoticePanel]: {
    type: ComponentType.liaNoticePanel,
    description: 'Timed Lilia notice panel with centered label, blur/theme paint, calculated label width, and start/end progress fill fields.',
    base: 'DPanel',
    size: { w: 400, h: 60 },
    defaultText: 'Timed Notice',
    defaultOptions: Object.fromEntries(noticePanelOptions.map(option => [option.key, option.defaultValue])),
    options: noticePanelOptions,
    setters: [
      { method: 'SetText', keys: ['text'], source: 'props', kind: 'memberMethod', target: 'text', alwaysEmit: true },
      { method: 'CalcWidth', keys: ['calcPadding'], alwaysEmit: true },
      { method: 'padding', keys: ['padding'], kind: 'assign', target: 'padding', alwaysEmit: true },
      { method: 'start', keys: ['start'], kind: 'assign', target: 'start', rawKeys: ['start'], alwaysEmit: true },
      { method: 'endTime', keys: ['endTime'], kind: 'assign', target: 'endTime', rawKeys: ['endTime'], alwaysEmit: true },
    ],
    methods: noticePanelMethods,
    preview: 'noticePanel',
  },
  [ComponentType.liaVoicePanel]: {
    type: ComponentType.liaVoicePanel,
    description: 'Lilia voice indicator with player setup, live voice-level bars, voice-mode text/color updates, tooltip details, and fade-out behavior.',
    base: 'DPanel',
    size: { w: 310, h: 58 },
    defaultOptions: Object.fromEntries(voicePanelOptions.map(option => [option.key, option.defaultValue])),
    options: voicePanelOptions,
    setters: [
      { method: 'Setup', keys: ['client'], rawKeys: ['client'], alwaysEmit: true },
      { method: 'voiceLevel', keys: ['voiceLevel'], kind: 'assign', target: 'voiceLevel', alwaysEmit: true },
      { method: 'cachedVoiceType', keys: ['voiceType'], kind: 'assign', target: 'cachedVoiceType', alwaysEmit: true },
    ],
    methods: voicePanelMethods,
    preview: 'voice',
  },
  [ComponentType.liaLockCircle]: {
    type: ComponentType.liaLockCircle,
    description: 'Full-screen timed circular action indicator with configurable text, duration, hold time, colors, fonts, geometry, angle, and position.',
    base: 'EditablePanel',
    size: { w: 260, h: 220 },
    defaultText: 'Testing',
    defaultOptions: Object.fromEntries(lockCircleOptions.map(option => [option.key, option.defaultValue])),
    options: lockCircleOptions,
    setters: [],
    methods: lockCircleMethods,
    preview: 'lockCircle',
  },
  [ComponentType.liaDermaMenu]: {
    type: ComponentType.liaDermaMenu,
    description: 'Lilia context menu with options, spacers, submenus, deferred building, scrolling, keyboard navigation, sizing, highlighting, CVar helpers, and close behavior.',
    base: 'DPanel',
    size: { w: 220, h: 170 },
    defaultOptions: Object.fromEntries(dermaMenuOptions.map(option => [option.key, option.defaultValue])),
    options: dermaMenuOptions,
    setters: [
      { method: 'SetDeleteSelf', keys: ['deleteSelf'], alwaysEmit: true },
      { method: 'SetMaxHeight', keys: ['maxHeight'], rawKeys: ['maxHeight'] },
      { method: 'SetDrawBorder', keys: ['drawBorder'], alwaysEmit: true },
      { method: 'SetDrawColumn', keys: ['drawColumn'], alwaysEmit: true },
      { method: 'SetMinimumWidth', keys: ['minimumWidth'], alwaysEmit: true },
      { method: 'SetPadding', keys: ['padding'], alwaysEmit: true },
    ],
    methods: dermaMenuMethods,
    repeaters: [{ key: 'items', format: 'dermaMenuItems' }],
    preview: 'dermaMenu',
  },
};

export const getLiaDefinition = (type: ComponentType) => LIA_COMPONENT_DEFINITIONS[type] || null;

export const isLiaComponent = (type: ComponentType) => Boolean(getLiaDefinition(type));

export const isRootFrameType = (type: ComponentType) => type === ComponentType.DFrame || getLiaDefinition(type)?.root === true;

export const isContainerType = (type: ComponentType) => Boolean(getLiaDefinition(type)?.container);

export const getLiaDefaultProps = (type: ComponentType): Partial<ComponentProps> => {
  const definition = getLiaDefinition(type);
  if (!definition) return {};
  return {
    text: definition.defaultText,
    liaOptions: definition.defaultOptions ? { ...definition.defaultOptions } : {},
  };
};

export const getLiaMethods = (type: ComponentType): MethodSignature[] => getLiaDefinition(type)?.methods || [];
