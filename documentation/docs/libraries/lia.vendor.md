# Vendor Library

This page documents vendor-related helpers.

---

## Overview

The vendor library stores item presets and rarity colours for use with in-game vendor NPCs. Presets allow vendors to be configured quickly with predefined items while rarities customise item name colours in the vendor menu. The library also exposes a client-side `lia.vendor.editor` table containing functions that send edits to the server.

---

### lia.vendor.addRarities

**Purpose**

Registers a new rarity colour that can be referenced by name.

**Parameters**

* `name` (*string*): Identifier for the rarity.
* `color` (*Color*): Colour to display in menus.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.addRarities("epic", Color(165, 105, 189))
```

---

### lia.vendor.addPreset

**Purpose**

Defines a reusable vendor preset of items.

**Parameters**

* `name` (*string*): Preset name.
* `items` (*table*): Map of item unique IDs to price/stock tables.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.addPreset("medical", {
    medkit = {price = 100, stock = 5},
    bandage = {price = 20, stock = 20}
})
```

---

### lia.vendor.getPreset

**Purpose**

Fetches a preset by name.

**Parameters**

* `name` (*string*): Name of the preset.

**Realm**

`Shared`

**Returns**

* *table | nil*: The preset table or `nil` if not found.

**Example Usage**

```lua
local preset = lia.vendor.getPreset("medical")
if preset then
    PrintTable(preset)
end
```

---
### lia.vendor.editor.name

**Purpose**

Sets the name displayed above a vendor.

**Parameters**

* `name` (*string*): New vendor name.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.name("Medic")
```

---
### lia.vendor.editor.mode

**Purpose**

Changes how the vendor handles a specific item.

**Parameters**

* `itemType` (*string*): Item unique ID.
* `mode` (*number | nil*): Trade mode constant or `nil`.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.mode("medkit", VENDOR_SELLONLY)
```

---
### lia.vendor.editor.price

**Purpose**

Sets the buy or sell price for an item.

**Parameters**

* `itemType` (*string*): Item unique ID.
* `price` (*number | nil*): Price in currency or `nil`.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.price("bandage", 20)
```

---
### lia.vendor.editor.flag

**Purpose**

Restricts vendor access to characters with a flag.

**Parameters**

* `flag` (*string*): Single-character permission flag.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.flag("t")
```

---
### lia.vendor.editor.stockDisable

**Purpose**

Removes the stock limit for an item.

**Parameters**

* `itemType` (*string*): Item unique ID.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.stockDisable("medkit")
```

---
### lia.vendor.editor.welcome

**Purpose**

Changes the vendor's welcome message.

**Parameters**

* `message` (*string*): Text shown when players open the vendor.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.welcome("Hello there!")
```

---
### lia.vendor.editor.stockMax

**Purpose**

Sets the maximum stock for an item.

**Parameters**

* `itemType` (*string*): Item unique ID.
* `value` (*number*): Maximum quantity.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.stockMax("medkit", 10)
```

---
### lia.vendor.editor.stock

**Purpose**

Manually sets the current stock for an item.

**Parameters**

* `itemType` (*string*): Item unique ID.
* `value` (*number*): Current quantity.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.stock("medkit", 5)
```

---
### lia.vendor.editor.faction

**Purpose**

Allows or disallows a faction from using the vendor.

**Parameters**

* `factionID` (*number*): Faction index.
* `allowed` (*boolean*): `true` to allow, `false` to remove.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.faction(1, true)
```

---
### lia.vendor.editor.class

**Purpose**

Allows or disallows a class from using the vendor.

**Parameters**

* `classID` (*number*): Class index.
* `allowed` (*boolean*): `true` to allow, `false` to remove.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.class(2, true)
```

---
### lia.vendor.editor.model

**Purpose**

Updates the vendor's model.

**Parameters**

* `model` (*string*): Model path.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.model("models/alyx.mdl")
```

---
### lia.vendor.editor.skin

**Purpose**

Changes the vendor's skin index.

**Parameters**

* `skin` (*number*): Skin ID.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.skin(1)
```

---
### lia.vendor.editor.bodygroup

**Purpose**

Sets a bodygroup on the vendor model.

**Parameters**

* `index` (*number*): Bodygroup slot.
* `value` (*number*): Value to apply.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.bodygroup(2, 3)
```

---
### lia.vendor.editor.useMoney

**Purpose**

Toggles whether the vendor uses a money pool.

**Parameters**

* `useMoney` (*boolean*): `true` to enable, `false` to disable.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.useMoney(true)
```

---
### lia.vendor.editor.money

**Purpose**

Sets the vendor's available money.

**Parameters**

* `value` (*number*): Amount of currency.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.money(500)
```

---
### lia.vendor.editor.scale

**Purpose**

Adjusts the price multiplier for selling items.

**Parameters**

* `scale` (*number*): Multiplier applied to sell prices.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.scale(0.5)
```

---
### lia.vendor.editor.preset

**Purpose**

Applies a saved item preset to the vendor.

**Parameters**

* `name` (*string*): Preset name.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.vendor.editor.preset("medical")
```

---
