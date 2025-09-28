# Vendor Panels Library

A comprehensive collection of panels for managing vendor shops, item transactions, and administrative vendor controls within the Lilia framework.

---

## Overview

The vendor panel library provides all the necessary components for creating and managing vendor interfaces, from basic shop displays to advanced administrative tools. These panels handle item pricing, faction restrictions, inventory management, and transaction processing, integrating seamlessly with Lilia's vendor and economy systems.

---

### Vendor

**Purpose**

Main vendor window that lists items the NPC will buy or sell. Provides buttons for transactions and updates when the player's inventory changes.

**When Called**

This panel is called when:
- Interacting with vendor NPCs
- Displaying shop inventories
- Managing buy/sell transactions
- Providing commercial interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendor interface
local vendor = vgui.Create("Vendor")
vendor:SetSize(500, 400)
vendor:Center()
vendor:MakePopup()

-- Usually triggered by NPC interaction
-- Access through framework systems
if lia.gui.vendor and IsValid(lia.gui.vendor) then
    lia.gui.vendor:RefreshVendor()
end
```

---

### VendorItem

**Purpose**

Panel representing an individual item within the vendor list. Shows price information and handles clicks for buying or selling.

**When Called**

This panel is called when:
- Displaying individual vendor items
- Managing item pricing displays
- Handling item transactions
- Providing item selection in vendor interfaces

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Usually created by vendor systems
-- No manual creation needed - part of vendor framework

-- Custom vendor item for advanced shop systems
local vendorItem = vgui.Create("VendorItem")
vendorItem:SetupItem(itemTable, sellPrice, buyPrice)
vendorItem.DoClick = function()
    -- Custom transaction handling
    print("Item clicked for transaction")
end
```

---

### VendorEditor

**Purpose**

Administrative window for editing a vendor's inventory and settings, including item prices and faction permissions.

**When Called**

This panel is called when:
- Editing vendor inventory
- Managing vendor settings
- Configuring item prices
- Setting up vendor permissions

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendor editor
local vendorEditor = vgui.Create("VendorEditor")
vendorEditor:SetSize(600, 500)
vendorEditor:Center()
vendorEditor:MakePopup()

-- Load vendor data for editing
vendorEditor:LoadVendor(vendorEntity)
vendorEditor:RefreshInventoryList()
```

---

### VendorFactionEditor

**Purpose**

Secondary editor for selecting which factions and player classes can trade with the vendor.

**When Called**

This panel is called when:
- Configuring vendor faction access
- Managing class-based trading permissions
- Setting up vendor restrictions
- Controlling vendor accessibility

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendor faction editor
local factionEditor = vgui.Create("VendorFactionEditor")
factionEditor:SetSize(400, 300)
factionEditor:Center()
factionEditor:MakePopup()

-- Configure faction access
factionEditor:LoadFactions()
factionEditor:SetupPermissionControls()
```

---

### VendorBodygroupEditor

**Purpose**

Window for adjusting a vendor's bodygroups and skin.

**When Called**

This panel is called when:
- Customizing vendor appearance
- Adjusting vendor bodygroups
- Managing vendor visual settings
- Configuring vendor skin options

**Parameters**

*This panel does not require parameters during creation.*

**Returns**

*This panel does not return values.*

**Realm**

Client.

**Example Usage**

```lua
-- Create a vendor bodygroup editor
local bodygroupEditor = vgui.Create("VendorBodygroupEditor")
bodygroupEditor:SetSize(400, 300)
bodygroupEditor:Center()
bodygroupEditor:MakePopup()

-- Load vendor model for editing
bodygroupEditor:LoadVendorModel(vendorEntity)
bodygroupEditor:SetupBodygroupControls()
```

---
