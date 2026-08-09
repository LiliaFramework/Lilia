// Mapping of in-game Derma / Source-engine font names to web-renderable
// approximations for the editor preview. Sourced from:
//   - garrysmod/lua/derma/init.lua (DermaDefault, DermaDefaultBold, DermaLarge)
//   - Source engine clientscheme.res defaults for the rest (Tahoma / Verdana /
//     Trebuchet at game-typical sizes)
//
// Each `family` is a CSS font-family stack starting with the in-game-native
// face (Tahoma on Windows, DejaVu Sans on Linux/macOS — both common system
// fonts), then web-safe fallbacks. The browser picks the first one available,
// so users on any OS get a recognizable approximation of the in-game look.

export interface ResolvedFont {
  family: string;
  size: number;   // px
  weight: number;
}

const DERMA_FONTS: Record<string, ResolvedFont> = {
  // Derma core — explicitly defined in init.lua. The Linux/macOS sizes (14)
  // differ from Windows (13); we use the Linux size since DejaVu Sans is the
  // primary face in the stack.
  DermaDefault:        { family: '"DejaVu Sans", "Tahoma", "Helvetica Neue", sans-serif', size: 14, weight: 500 },
  DermaDefaultBold:    { family: '"DejaVu Sans", "Tahoma", "Helvetica Neue", sans-serif', size: 14, weight: 800 },
  DermaLarge:          { family: '"Roboto", "Tahoma", "Helvetica Neue", sans-serif',       size: 32, weight: 500 },

  // Source engine UI fonts that Derma exposes by name. Sizes / weights match
  // the in-game `clientscheme.res` defaults at typical resolutions.
  // ChatFont in gmod's clientscheme.res is Verdana 16 (not 14). Confirmed by
  // matching to the in-game "Login here"-style button text size.
  ChatFont:            { family: '"Verdana", "DejaVu Sans", sans-serif',                   size: 16, weight: 400 },
  Default:             { family: '"Tahoma", "DejaVu Sans", sans-serif',                    size: 11, weight: 400 },
  DefaultSmall:        { family: '"Tahoma", "DejaVu Sans", sans-serif',                    size: 9,  weight: 400 },
  DefaultVerySmall:    { family: '"Tahoma", "DejaVu Sans", sans-serif',                    size: 7,  weight: 400 },
  DefaultFixed:        { family: '"Lucida Console", "DejaVu Sans Mono", monospace',        size: 10, weight: 400 },
  DefaultFixedDropShadow: { family: '"Lucida Console", "DejaVu Sans Mono", monospace',     size: 10, weight: 400 },
  Trebuchet18:         { family: '"Trebuchet MS", "DejaVu Sans", sans-serif',              size: 18, weight: 500 },
  Trebuchet24:         { family: '"Trebuchet MS", "DejaVu Sans", sans-serif',              size: 24, weight: 500 },
  HudHintTextLarge:    { family: '"Verdana", "DejaVu Sans", sans-serif',                   size: 16, weight: 700 },
  HudHintTextSmall:    { family: '"Verdana", "DejaVu Sans", sans-serif',                   size: 12, weight: 400 },
  HudSelectionText:    { family: '"Trebuchet MS", "DejaVu Sans", sans-serif',              size: 12, weight: 400 },
  TargetID:            { family: '"Tahoma", "DejaVu Sans", sans-serif',                    size: 22, weight: 700 },
  TargetIDSmall:       { family: '"Tahoma", "DejaVu Sans", sans-serif',                    size: 12, weight: 400 },
  BudgetLabel:         { family: '"Tahoma", "DejaVu Sans", sans-serif',                    size: 11, weight: 400 },
  CenterPrintText:     { family: '"Trebuchet MS", "DejaVu Sans", sans-serif',              size: 22, weight: 500 },
  CloseCaption_Normal: { family: '"Tahoma", "DejaVu Sans", sans-serif',                    size: 16, weight: 400 },
  MenuLarge:           { family: '"Trebuchet MS", "DejaVu Sans", sans-serif',              size: 18, weight: 500 },

  // Convenience: the "Standard" option in the dropdown. Pure Arial, no Derma flavor.
  Arial:               { family: 'Arial, sans-serif',                                      size: 13, weight: 400 },
};

// The set of font NAMES that already exist in-game and should NOT be re-created
// via surface.CreateFont in the generated Lua. Anything outside this set that
// the user picks in the editor will get an autogen `surface.CreateFont` call.
export const STANDARD_DERMA_FONTS: ReadonlySet<string> = new Set(Object.keys(DERMA_FONTS));

// Names exposed in the PropertiesPanel font dropdown.
export const DERMA_FONT_NAMES: ReadonlyArray<string> = Object.keys(DERMA_FONTS);

/**
 * Map a Derma font name to a renderable {family, size, weight}.
 *
 * `overrideSize` / `overrideWeight` come from the user's per-element
 * fontSize/fontWeight props. Treated as "apply override" only when truthy
 * (matches the existing convention where 0/undefined means "use the default").
 *
 * Unknown font names fall through with the literal name as the first family
 * candidate — this lets users type a custom font face the editor doesn't
 * know about, and the browser will use it if it's installed.
 */
export function resolveDermaFont(
  name?: string,
  overrideSize?: number,
  overrideWeight?: number,
): ResolvedFont {
  const base = name ? DERMA_FONTS[name] : undefined;
  if (base) {
    return {
      family: base.family,
      size: overrideSize && overrideSize > 0 ? overrideSize : base.size,
      weight: overrideWeight && overrideWeight > 0 ? overrideWeight : base.weight,
    };
  }
  // Unknown / blank name — fall back to the universal Derma default with
  // the literal name (if any) prepended as the preferred face.
  return {
    family: name
      ? `"${name}", "DejaVu Sans", "Tahoma", sans-serif`
      : '"DejaVu Sans", "Tahoma", "Helvetica Neue", sans-serif',
    size: overrideSize && overrideSize > 0 ? overrideSize : 13,
    weight: overrideWeight && overrideWeight > 0 ? overrideWeight : 400,
  };
}
