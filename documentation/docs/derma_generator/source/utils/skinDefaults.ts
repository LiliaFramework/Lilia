// Derma default-skin colors. Sourced from `garrysmod/lua/skins/default.lua`
// (the colors a vanilla DPanel / DButton / etc. paints itself when the user
// hasn't supplied a custom Paint or a color override).
//
// Used so the editor preview matches what the user sees in-game with no
// customization. Each value can still be overridden by the user via the
// element's `color` prop — these defaults only apply when nothing is set.
//
// Light values match the default Derma skin which is XP/Vista-flavored
// light gray. Most production Derma UIs override Paint to go dark, but the
// vanilla appearance is light, and the editor should reflect that.

import { ComponentType, UIElement } from '../types';

export const SKIN_DEFAULTS = {
  panel:        '#f0f0f0',  // DPanel / DScrollPanel / DTab default body
  collapsible:  '#f0f0f0',  // DCollapsibleCategory body
  form:         '#ffffff',  // DForm body
  buttonNormal: '#dcdcdc',  // DButton resting bg
  buttonHover:  '#e8e8e8',  // DButton hover bg
  buttonDisabled: '#cccccc',
  frame:        '#323232',  // DFrame body — dark by default in our editor
  bevel:        '#2a2a2a',
} as const;

/**
 * Walks up the parent chain looking for the first parent with a meaningful
 * background color (either a user-set `color` prop or a known type default).
 * Returns `null` if no parent has a defined bg (e.g. an orphan element).
 *
 * `panelPaintBackground === false` on a DPanel makes it transparent — in that
 * case we keep walking up.
 */
export function getEffectiveParentBg(
  el: UIElement,
  elements: Record<string, UIElement>,
): string | null {
  let curr = el.parentId ? elements[el.parentId] : undefined;
  while (curr) {
    // User-set color always wins
    if (curr.props.color) return curr.props.color;

    // Per-type defaults
    switch (curr.type) {
      case ComponentType.DFrame:
        if (curr.props.framePaintBackground === false) break;
        return SKIN_DEFAULTS.frame;
      case ComponentType.DPanel:
        if (curr.props.panelPaintBackground === false) break; // transparent — keep walking
        return SKIN_DEFAULTS.panel;
      case ComponentType.DScrollPanel:          return SKIN_DEFAULTS.panel;
      case ComponentType.DTab:                  return SKIN_DEFAULTS.panel;
      case ComponentType.DBevel:                return SKIN_DEFAULTS.bevel;
      case ComponentType.DForm:                 return SKIN_DEFAULTS.form;
      case ComponentType.DCollapsibleCategory:  return SKIN_DEFAULTS.collapsible;
      case ComponentType.DPropertySheet:        return SKIN_DEFAULTS.panel;
      case ComponentType.DColumnSheet:          return SKIN_DEFAULTS.panel;
      // Other container types (DGrid, DIconLayout, DVerticalDivider) are usually
      // transparent / parent-driven — walk up.
    }

    curr = curr.parentId ? elements[curr.parentId] : undefined;
  }
  return null;
}

/**
 * Picks black or white text given a hex background, based on perceived
 * luminance. Threshold ~0.55 keeps mid-grays leaning toward dark text
 * (matches Source's tendency).
 */
export function getReadableTextColor(bgHex: string): string {
  if (!bgHex || bgHex.length < 7) return '#ffffff';
  const r = parseInt(bgHex.slice(1, 3), 16);
  const g = parseInt(bgHex.slice(3, 5), 16);
  const b = parseInt(bgHex.slice(5, 7), 16);
  if (Number.isNaN(r) || Number.isNaN(g) || Number.isNaN(b)) return '#ffffff';
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
  return luminance > 0.55 ? '#000000' : '#ffffff';
}
