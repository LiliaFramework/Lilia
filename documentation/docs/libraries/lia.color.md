# Color Library

Comprehensive color and theme management system for the Lilia framework.

---

## Overview

The color library provides comprehensive functionality for managing colors and themes

in the Lilia framework. It handles color registration, theme management, color

manipulation, and smooth theme transitions. The library operates primarily on the

client side, with theme registration available on both server and client. It includes

predefined color names, theme switching capabilities, color adjustment functions,

and smooth animated transitions between themes. The library ensures consistent

color usage across the entire gamemode interface and provides tools for creating

custom themes and color schemes.

---

### register

**Purpose**

Registers a named color for use throughout the gamemode

**When Called**

When defining custom colors or extending the color palette

---

### adjust

**Purpose**

Adjusts color values by adding offsets to each channel

**When Called**

When creating color variations or adjusting existing colors

---

### darken

**Purpose**

Darkens a color by multiplying RGB values by a factor

**When Called**

When creating darker variations of colors for shadows or depth

---

### getCurrentTheme

**Purpose**

Gets the current active theme name in lowercase

**When Called**

When checking which theme is currently active

---

### getCurrentThemeName

**Purpose**

Gets the current active theme name with proper capitalization

**When Called**

When displaying theme name to users or for configuration

---

### getMainColor

**Purpose**

Gets the main color from the current theme

**When Called**

When needing the primary accent color for UI elements

---

### applyTheme

**Purpose**

Applies a theme to the interface with optional smooth transition

**When Called**

When switching themes or initializing the color system

---

### isTransitionActive

**Purpose**

Checks if a theme transition animation is currently active

**When Called**

When checking transition state before starting new transitions

---

### testThemeTransition

**Purpose**

Tests a theme transition by applying it with animation

**When Called**

When previewing theme changes or testing transitions

---

### startThemeTransition

**Purpose**

Starts a smooth animated transition to a new theme

**When Called**

When applying themes with transition animation enabled

---

### isColor

**Purpose**

Checks if a value is a valid color object

**When Called**

When validating color data or processing theme transitions

---

### returnMainAdjustedColors

**Purpose**

Returns a set of adjusted colors based on the main theme color

**When Called**

When creating UI color schemes or theme-based color palettes

---

### lerp

**Purpose**

Interpolates between two colors using frame time for smooth transitions

**When Called**

During theme transitions to smoothly blend between colors

---

### lia.Color

**Purpose**

Interpolates between two colors using frame time for smooth transitions

**When Called**

During theme transitions to smoothly blend between colors

---

### registerTheme

**Purpose**

Registers a new theme with color definitions

**When Called**

When creating custom themes or extending the theme system

---

### getAllThemes

**Purpose**

Gets a list of all available theme names

**When Called**

When building theme selection menus or validating theme names

---

