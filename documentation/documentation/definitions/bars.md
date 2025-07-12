# Bar Fields

This document lists the standard keys used when defining HUD bars with `lia.bar.add` or retrieving them through `lia.bar.get`.

---

## Overview

Each bar represents a progress value such as health, armor, or stamina. The bar table stores callbacks and display information used by the HUD renderer.

---

## Field Summary

| Field | Type | Description |
| --- | --- | --- |
| `getValue` | `function` | Returns the bar’s progress as a fraction. |
| `color` | `Color` | Bar fill colour. |
| `priority` | `number` | Draw order; lower priorities draw first. |
| `identifier` | `string` \| `nil` | Unique identifier, if provided. |
| `visible` | `boolean` \| `nil` | Set to `true` to force the bar to remain visible. |
| `lifeTime` | `number` | Internal timer used for fading; managed automatically. |

---
