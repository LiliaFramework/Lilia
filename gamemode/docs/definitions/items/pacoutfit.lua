--[[
    PAC Outfit Item Definition

    PAC outfit item system for the Lilia framework.

    PAC outfit items are wearable items that use PAC (Player Accessory Creator) for visual effects.
    They require the PAC addon and provide visual indicators when equipped.

    PLACEMENT:
    - Place in: ModuleFolder/items/pacoutfit/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/pacoutfit/ItemHere.lua (for schema-specific items)

    USAGE:
    - PAC outfit items are equipped by using them
    - They add PAC3 parts to the player
    - Items remain in inventory when equipped
    - Can be unequipped to remove PAC3 parts
    - Requires PAC3 addon to function properly
]]
--[[
    if not pac then return end
    Purpose: Prevents loading if PAC addon is not available
    When Called: During item definition
    Example Usage:
        ```lua
        if not pac then return end
        ```
]]
if not pac then return end
--[[
    ITEM.name
    Purpose: Sets the display name of the PAC outfit item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.name = "Hat"
        ```
]]
ITEM.name = "pacoutfitName"
--[[
    ITEM.desc
    Purpose: Sets the description of the PAC outfit item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.desc = "A stylish hat"
        ```
]]
ITEM.desc = "pacoutfitDesc"
--[[
    ITEM.category
    Purpose: Sets the category for the PAC outfit item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.category = "outfit"
        ```
]]
ITEM.category = "outfit"
--[[
    ITEM.model
    Purpose: Sets the 3D model for the PAC outfit item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.model = "models/Gibs/HGIBS.mdl"
        ```
]]
ITEM.model = "models/Gibs/HGIBS.mdl"
--[[
    ITEM.width
    Purpose: Sets the inventory width of the PAC outfit item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.width = 1  -- Takes 1 slot width
        ```
]]
ITEM.width = 1
--[[
    ITEM.height
    Purpose: Sets the inventory height of the PAC outfit item
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.height = 1  -- Takes 1 slot height
        ```
]]
ITEM.height = 1
--[[
    ITEM.outfitCategory
    Purpose: Sets the outfit category for conflict checking
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.outfitCategory = "hat"  -- Prevents multiple items of same category
        ```
]]
ITEM.outfitCategory = "hat"
--[[
    ITEM.pacData
    Purpose: Sets the PAC data for the outfit
    When Called: During item definition
    Example Usage:
        ```lua
        ITEM.pacData = {}  -- PAC attachment data
        ```
]]
ITEM.pacData = {}
--[[
    ITEM:paintOver(item, w, h)
    Purpose: Custom paint function to show equipped status
    When Called: When rendering the item in inventory (CLIENT only)
    Example Usage:
        ```lua
        function ITEM:paintOver(item, w, h)
            if item:getData("equip") then
                surface.SetDrawColor(110, 255, 110, 100)
                surface.DrawRect(w - 14, h - 14, 8, 8)
            end
        end
        ```
]]
--[[
    ITEM:removePart(client)
    Purpose: Removes the PAC part from the player
    When Called: When unequipping the PAC outfit
    Example Usage:
        ```lua
        function ITEM:removePart(client)
            local char = client:getChar()
            self:setData("equip", false)
            if client.removePart then client:removePart(self.uniqueID) end
            -- Remove attribute boosts
        end
        ```
]]
--[[
    ITEM:onCanBeTransfered(_, newInventory)
    Purpose: Prevents transfer of equipped PAC outfits
    When Called: When attempting to transfer the item
    Example Usage:
        ```lua
        function ITEM:onCanBeTransfered(_, newInventory)
            if newInventory and self:getData("equip") then return false end
            return true
        end
        ```
]]
--[[
    ITEM:onLoadout()
    Purpose: Handles PAC outfit loading on player spawn
    When Called: When player spawns with equipped PAC outfit
    Example Usage:
        ```lua
        function ITEM:onLoadout()
            if self:getData("equip") and self.player.addPart then self.player:addPart(self.uniqueID) end
        end
        ```
]]
--[[
    ITEM:onRemoved()
    Purpose: Handles PAC outfit removal when item is removed
    When Called: When item is removed from inventory
    Example Usage:
        ```lua
        function ITEM:onRemoved()
            local inv = lia.item.inventories[self.invID]
            local receiver = inv.getReceiver and inv:getReceiver()
            if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") then self:removePart(receiver) end
        end
        ```
]]
--[[
    ITEM:hook("drop", function(item) ... end)
    Purpose: Handles PAC outfit removal when item is dropped
    When Called: When item is dropped
    Example Usage:
        ```lua
        ITEM:hook("drop", function(item)
            local client = item.player
            if item:getData("equip") then item:removePart(client) end
        end)
        ```
]]
--[[
Example Item:

```lua
-- Basic item identification
ITEM.name = "Hat"                               -- Display name shown to players
ITEM.desc = "A stylish hat"                     -- Description text
ITEM.category = "outfit"                        -- Category for inventory sorting
ITEM.model = "models/Gibs/HGIBS.mdl"            -- 3D model for the item
ITEM.width = 1                                  -- Inventory width (1 slot)
ITEM.height = 1                                 -- Inventory height (1 slot)
ITEM.outfitCategory = "hat"                     -- Outfit category for conflict checking
```
]]
