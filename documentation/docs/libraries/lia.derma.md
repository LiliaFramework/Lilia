# Derma Library

Advanced UI rendering and interaction system for the Lilia framework.

---

## Overview

The derma library provides comprehensive UI rendering and interaction functionality for the Lilia framework.

It handles advanced drawing operations including rounded rectangles, circles, shadows, blur effects, and

gradients using custom shaders. The library offers a fluent API for creating complex UI elements with

smooth animations, color pickers, player selectors, and various input dialogs. It includes utility

functions for text rendering with shadows and outlines, entity text display, and menu positioning.

The library operates primarily on the client side and provides both low-level drawing functions and

high-level UI components for creating modern, visually appealing interfaces.

---

### dermaMenu

**Purpose**

Creates a context menu at the current mouse cursor position

**When Called**

When right-clicking or when a context menu is needed

---

### colorPicker

**Purpose**

Opens a color picker dialog for selecting colors

**When Called**

When user needs to select a color from a visual picker interface

---

### radialMenu

**Purpose**

Creates a radial menu interface with circular option selection

**When Called**

When user needs to select from multiple options in a circular menu format

---

### playerSelector

**Purpose**

Opens a player selection dialog showing all connected players

**When Called**

When user needs to select a player from a list

---

### textBox

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

---

### lia.newFlag

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

---

### lia.normalizeCornerRadii

**Purpose**

Opens a text input dialog for user text entry

**When Called**

When user needs to input text through a dialog

---

### draw

**Purpose**

Draws a rounded rectangle with specified parameters

**When Called**

When rendering UI elements that need rounded corners

---

### drawOutlined

**Purpose**

Draws a rounded rectangle with an outline border

**When Called**

When rendering UI elements that need outlined rounded corners

---

### drawTexture

**Purpose**

Draws a rounded rectangle with a texture applied

**When Called**

When rendering UI elements that need textured rounded backgrounds

---

### drawMaterial

**Purpose**

Draws a rounded rectangle with a material applied

**When Called**

When rendering UI elements that need material-based rounded backgrounds

---

### drawCircle

**Purpose**

Draws a filled circle with specified parameters

**When Called**

When rendering circular UI elements like buttons or indicators

---

### drawCircleOutlined

**Purpose**

Draws a circle with an outline border

**When Called**

When rendering circular UI elements that need outlined borders

---

### drawCircleTexture

**Purpose**

Draws a circle with a texture applied

**When Called**

When rendering circular UI elements that need textured backgrounds

---

### drawCircleMaterial

**Purpose**

Draws a circle with a material applied

**When Called**

When rendering circular UI elements that need material-based backgrounds

---

### drawBlur

**Purpose**

Draws a blurred rounded rectangle using custom shaders

**When Called**

When rendering UI elements that need blur effects

---

### drawShadowsEx

**Purpose**

Draws shadows for rounded rectangles with extensive customization

**When Called**

When rendering UI elements that need shadow effects

---

### drawShadows

**Purpose**

Draws shadows for rounded rectangles with uniform corner radius

**When Called**

When rendering UI elements that need shadow effects with same corner radius

---

### drawShadowsOutlined

**Purpose**

Draws outlined shadows for rounded rectangles with uniform corner radius

**When Called**

When rendering UI elements that need outlined shadow effects

---

### rect

**Purpose**

Creates a fluent rectangle drawing object for chained operations

**When Called**

When creating complex UI elements with multiple drawing operations

---

### circle

**Purpose**

Creates a fluent circle drawing object for chained operations

**When Called**

When creating complex circular UI elements with multiple drawing operations

---

### setFlag

**Purpose**

Creates a fluent circle drawing object for chained operations

**When Called**

When creating complex circular UI elements with multiple drawing operations

---

### setDefaultShape

**Purpose**

Creates a fluent circle drawing object for chained operations

**When Called**

When creating complex circular UI elements with multiple drawing operations

---

### shadowText

**Purpose**

Draws text with a shadow effect for better readability

**When Called**

When rendering text that needs to stand out against backgrounds

---

### drawTextOutlined

**Purpose**

Draws text with an outline border for better visibility

**When Called**

When rendering text that needs to stand out with outline effects

---

### drawTip

**Purpose**

Draws a tooltip-style speech bubble with text

**When Called**

When rendering tooltips or help text in speech bubble format

---

### drawText

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

---

### drawBoxWithText

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

---

### drawSurfaceTexture

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

---

### skinFunc

**Purpose**

Draws text with automatic shadow effect for better readability

**When Called**

When rendering text that needs consistent shadow styling

---

### approachExp

**Purpose**

Performs exponential interpolation between current and target values

**When Called**

When smooth animation transitions are needed

---

### easeOutCubic

**Purpose**

Applies cubic ease-out easing function to a normalized time value

**When Called**

When smooth deceleration animations are needed

---

### easeInOutCubic

**Purpose**

Applies cubic ease-in-out easing function to a normalized time value

**When Called**

When smooth acceleration and deceleration animations are needed

---

### animateAppearance

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

---

### clampMenuPosition

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

---

### drawGradient

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

---

### wrapText

**Purpose**

Animates panel appearance with scaling and fade effects

**When Called**

When panels need smooth entrance animations

---

### drawBlur

**Purpose**

Draws blur effect behind a panel using screen space effects

**When Called**

When rendering panel backgrounds that need blur effects

---

### drawBlackBlur

**Purpose**

Draws blur effect behind a panel using screen space effects

**When Called**

When rendering panel backgrounds that need blur effects

---

### drawBlurAt

**Purpose**

Draws blur effect at specific screen coordinates

**When Called**

When rendering blur effects at specific screen positions

---

### requestArguments

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

---

### createTableUI

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

---

### openOptionsMenu

**Purpose**

Creates a dialog for requesting multiple arguments from the user

**When Called**

When user input is needed for multiple fields with different types

---

### drawEntText

**Purpose**

Draws text above entities in 3D space with distance-based scaling

**When Called**

When rendering entity labels or information in 3D space

---

### requestDropdown

**Purpose**

Creates a dropdown selection dialog for user choice

**When Called**

When user needs to select from a list of options

---

### requestString

**Purpose**

Creates a text input dialog for user string entry

**When Called**

When user needs to input text through a dialog

---

### requestOptions

**Purpose**

Creates a multi-select dialog for choosing multiple options

**When Called**

When user needs to select multiple options from a list

---

### requestBinaryQuestion

**Purpose**

Creates a yes/no confirmation dialog

**When Called**

When user confirmation is needed for an action

---

### lia.description

**Purpose**

Creates a dialog with multiple action buttons

**When Called**

When user needs to choose from multiple actions

---

### requestButtons

**Purpose**

Creates a dialog with multiple action buttons

**When Called**

When user needs to choose from multiple actions

---

