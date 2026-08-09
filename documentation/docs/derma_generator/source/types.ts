
export enum ComponentType {
  DFrame = 'DFrame',
  DButton = 'DButton',
  DLabel = 'DLabel',
  DTextEntry = 'DTextEntry',
  DPanel = 'DPanel',
  DCheckBox = 'DCheckBox',
  DComboBox = 'DComboBox',
  DListView = 'DListView',
  DPropertySheet = 'DPropertySheet',
  DScrollPanel = 'DScrollPanel',
  DImage = 'DImage',
  DColorMixer = 'DColorMixer',
  DSlider = 'DSlider',
  DNumSlider = 'DNumSlider',
  DCollapsibleCategory = 'DCollapsibleCategory',
  DTree = 'DTree',
  DColumnSheet = 'DColumnSheet',
  DIconLayout = 'DIconLayout',
  DGrid = 'DGrid',
  DMenu = 'DMenu',
  DMenuBar = 'DMenuBar',
  DHTML = 'DHTML',
  DBinder = 'DBinder',
  DColorCube = 'DColorCube',
  DColorPalette = 'DColorPalette',
  DForm = 'DForm',
  DImageButton = 'DImageButton',
  DModelPanel = 'DModelPanel',
  DNotify = 'DNotify',
  DProgress = 'DProgress',
  DRichText = 'DRichText',
  DSysButton = 'DSysButton',
  DTooltip = 'DTooltip',
  DVerticalDivider = 'DVerticalDivider',
  DHorizontalDivider = 'DHorizontalDivider',
  DNumberWang = 'DNumberWang',
  DBevel = 'DBevel',
  DTab = 'DTab',
  liaFrame = 'liaFrame',
  liaSlider = 'liaSlider',
  liaSlideBox = 'liaSlideBox',
  liaButton = 'liaButton',
  liaHugeButton = 'liaHugeButton',
  liaBigButton = 'liaBigButton',
  liaMediumButton = 'liaMediumButton',
  liaSmallButton = 'liaSmallButton',
  liaMiniButton = 'liaMiniButton',
  liaNoBGButton = 'liaNoBGButton',
  liaCustomFontButton = 'liaCustomFontButton',
  liaCheckbox = 'liaCheckbox',
  liaComboBox = 'liaComboBox',
  liaEntry = 'liaEntry',
  liaProgressBar = 'liaProgressBar',
  liaHeaderPanel = 'liaHeaderPanel',
  liaScrollPanel = 'liaScrollPanel',
  liaHorizontalScroll = 'liaHorizontalScroll',
  liaHorizontalScrollBar = 'liaHorizontalScrollBar',
  liaSheet = 'liaSheet',
  liaTable = 'liaTable',
  liaTabs = 'liaTabs',
  liaTabButton = 'liaTabButton',
  liaModelPanel = 'liaModelPanel',
  liaSpawnIcon = 'liaSpawnIcon',
  CircularAvatar = 'CircularAvatar',
  liaNotice = 'liaNotice',
  liaNoticePanel = 'liaNoticePanel',
  liaVoicePanel = 'liaVoicePanel',
  liaLockCircle = 'liaLockCircle',
  liaDermaMenu = 'liaDermaMenu'
}

export interface ComponentProps {
  x: number;
  y: number;
  w: number;
  h: number;
  text?: string;
  color?: string; // Hex string
  checked?: boolean;
  variableName: string;
  
  // State
  visible?: boolean;
  enabled?: boolean;

  // Appearance
  tooltip?: string;
  textAlign?: 'left' | 'center' | 'right';
  hoverColor?: string; // Hex string
  borderColor?: string; // Hex string
  borderWidth?: number;
  borderRadius?: number;
  opacity?: number; // 0-255

  // Enhanced Hover
  hoverOpacity?: number; // 0-255
  hoverBorderColor?: string;
  hoverBorderWidth?: number;

  // Text Shadow
  textShadow?: boolean;
  textShadowColor?: string;
  textShadowOffset?: number;

  // Layout (Parent)
  layoutMode?: 'none' | 'vertical' | 'horizontal';
  layoutSpacing?: number;
  layoutPadding?: number;

  // Layout (Child)
  autoLayoutBehavior?: 'fixed' | 'fill' | 'shrink';

  // Effects
  hoverScale?: number; // Multiplier, e.g. 1.1

  // Image
  imageUrl?: string;
  imageColor?: string; // Tint color
  keepAspect?: boolean;

  // Font
  fontFamily?: string;
  fontSize?: number;
  fontWeight?: number;

  // Model Panel
  modelPath?: string;
  modelFov?: number;

  // DFrame Specifics
  titleBarColor?: string;
  draggable?: boolean;
  sizable?: boolean;
  showCloseButton?: boolean;
  deleteOnClose?: boolean;
  framePaintBackground?: boolean;
  frameBackgroundBlur?: boolean;
  frameIcon?: string;
  
  // DNumSlider Specifics
  min?: number;
  max?: number;
  decimals?: number;
  value?: number;

  // DIconLayout Specifics
  spaceX?: number;
  spaceY?: number;

  // DCollapsibleCategory Specifics
  expanded?: boolean;
  headerHeight?: number;

  // DProgress
  progressFraction?: number;

  // DSlider / DColorCube (2D handle position 0..1)
  sliderX?: number;
  sliderY?: number;

  // DNumSlider / DNumberWang (numeric range)
  sliderMin?: number;
  sliderMax?: number;
  sliderValue?: number;
  sliderDecimals?: number;
  numberInterval?: number;

  // DImageButton
  imageStretchToFit?: boolean;
  imageKeepAspect?: boolean;

  // DRichText
  richScrollbar?: boolean;

  // DBinder
  binderKey?: string;

  // DVerticalDivider / DHorizontalDivider
  dividerTopHeight?: number;
  dividerHeight?: number;

  // DColorMixer
  mixerColor?: string;
  mixerAlpha?: number;
  mixerShowAlphaBar?: boolean;
  mixerShowPalette?: boolean;
  mixerShowWangs?: boolean;
  mixerLabel?: string;

  // DColorCube
  cubeBaseColor?: string;

  // DColorPalette
  paletteColors?: string;
  paletteButtonSize?: number;
  paletteNumRows?: number;

  // DSysButton
  sysButtonType?: 'close' | 'minim' | 'maxim' | 'newwin';

  // DHTML
  htmlUrl?: string;
  htmlScrollbars?: boolean;
  htmlContent?: string;

  // DTree
  treeNodes?: string;
  treeIndentSize?: number;
  treeLineHeight?: number;
  treeShowIcons?: boolean;

  // DMenu / DMenuBar
  menuItems?: string;
  menuShowIconColumn?: boolean;
  menuBarItems?: string;

  // DGrid
  gridCols?: number;
  gridColWide?: number;
  gridRowHeight?: number;

  // DIconLayout
  iconSpaceX?: number;
  iconSpaceY?: number;
  iconBorder?: number;
  iconLayoutDir?: 'LEFT' | 'TOP';

  // DListView
  listColumns?: string;
  listRows?: string;
  listSortable?: boolean;
  listHideHeaders?: boolean;

  // DComboBox
  comboChoices?: string;
  comboSortItems?: boolean;

  // Per-type enabled/editable/paint flags (chunk-6 audit additions)
  buttonEnabled?: boolean;
  buttonConsoleCommand?: string;
  buttonIcon?: string;
  entryEditable?: boolean;
  entryTextColor?: string;
  entryMultiline?: boolean;
  entryPlaceholderText?: string;
  labelTextColor?: string;
  panelPaintBackground?: boolean;
  panelDisabled?: boolean;
  sliderLockX?: number;
  sliderLockY?: number;

  // Editor-only flag — locked elements can't be moved/resized/deleted
  locked?: boolean;

  // Logic
  liaOptions?: Record<string, string | number | boolean>;

  methods?: Record<string, string>; // methodName -> code body
}

export interface UIElement {
  id: string;
  type: ComponentType;
  props: ComponentProps;
  parentId: string | null;
  children: string[];
}

export interface EditorState {
  elements: Record<string, UIElement>;
  rootId: string | null;
  selectedId: string | null;
  selectedIds: string[];
  canvasWidth: number;
  canvasHeight: number;
}

export interface ViewState {
  zoom: number;
  panX: number;
  panY: number;
  gridSize: number;
  showGrid: boolean;
}