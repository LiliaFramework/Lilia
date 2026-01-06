--[[
    Folder: Definitions
    File:  outfit.md
]]
--[[
    Outfit Item Definition

    Outfit item system for the Lilia framework.
]]
--[[
    Outfit items are wearable items that can change player appearance, models, skins, bodygroups,
    and provide attribute boosts. They support PAC integration and visual indicators.

    PLACEMENT:
    - Place in: ModuleFolder/items/outfit/ItemHere.lua (for module-specific items)
    - Place in: SchemaFolder/items/outfit/ItemHere.lua (for schema-specific items)

    USAGE:
    - Outfit items are equipped by using them
    - They change the player's model and appearance
    - Items remain in inventory when equipped
    - Can be unequipped to restore original appearance
    - Outfit categories prevent conflicts between items
]]
--[[
    Purpose:
        Sets the display name shown to players

    Example Usage:
        ```lua
        -- Set the outfit name
        ITEM.name = "Police Uniform"
        ```
]]
ITEM.name = "outfit"
--[[
    Purpose:
        Sets the description text shown to players

    Example Usage:
        ```lua
        -- Set the outfit description
        ITEM.desc = "Standard police officer uniform with vest"
        ```
]]
ITEM.desc = "outfitDesc"
--[[
    Purpose:
        Sets the category for inventory sorting

    Example Usage:
        ```lua
        -- Set inventory category
        ITEM.category = "outfit"
        ```
]]
ITEM.category = "outfit"
--[[
    Purpose:
        Sets the 3D model used for the item

    Example Usage:
        ```lua
        -- Set the outfit model
        ITEM.model = "models/props_c17/BriefCase001a.mdl"
        ```
]]
ITEM.model = "models/props_c17/BriefCase001a.mdl"
--[[
    Purpose:
        Sets the inventory width in slots

    Example Usage:
        ```lua
        -- Set inventory width
        ITEM.width = 1
        ```
]]
ITEM.width = 1
--[[
    Purpose:
        Sets the inventory height in slots

    Example Usage:
        ```lua
        -- Set inventory height
        ITEM.height = 1
        ```
]]
ITEM.height = 1
--[[
    Purpose:
        Sets the category to prevent conflicting outfits

    Example Usage:
        ```lua
        -- Set outfit category to prevent conflicts
        ITEM.outfitCategory = "model"
        ```
]]
ITEM.outfitCategory = "model"
--[[
    Purpose:
        Defines PAC3 outfit data for visual effects

    Example Usage:
        ```lua
        -- Define PAC3 outfit parts (optional)
        ITEM.pacData = {}
        ```
]]
ITEM.pacData = {}
--[[
    Purpose:
        Marks this item as an outfit

    Example Usage:
        ```lua
        -- Mark as outfit item
        ITEM.isOutfit = true
        ```
]]
ITEM.isOutfit = true
if CLIENT then
    --[[
        Purpose:
            Draws a green indicator square on equipped outfits in the inventory

        When Called:
            Called in function ITEM:paintOver

        Parameters:
            item - The item instance being drawn
            w - Width of the item slot
            h - Height of the item slot

        Returns:
            nil

        Realm:
            Client

        Example Usage:

        Low Complexity:
            ```lua
            -- Automatically called when rendering equipped outfit in inventory
            -- Shows green square in bottom-right corner when equipped
            ```
    ]]
    function ITEM:paintOver(item, w, h)
        if item:getData("equip") then
            surface.SetDrawColor(110, 255, 110, 100)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
else
    ITEM.visualData = {
        model = {},
        skin = {},
        bodygroups = {}
    }
end

function ITEM:removeOutfit(client)
    local character = client:getChar()
    self:setData("equip", nil)
    if hook.Run("CanOutfitChangeModel", self) ~= false then
        character:setModel(self:getData("oldMdl", character:getModel()))
        self:setData("oldMdl", nil)
        client:SetSkin(self:getData("oldSkin", character:getSkin()))
        self:setData("oldSkin", nil)
        local oldGroups = character:getData("oldGroups", {})
        for k in pairs(self.bodyGroups or {}) do
            local index = client:FindBodygroupByName(k)
            if index > -1 then
                client:SetBodygroup(index, oldGroups[index] or 0)
                oldGroups[index] = nil
                local groups = character:getBodygroups()
                if groups[index] then
                    groups[index] = nil
                    character:setBodygroups(groups)
                end
            end
        end

        character:setData("oldGroups", oldGroups)
    end

    if self.pacData and client.removePart then client:removePart(self.uniqueID) end
    if self.attribBoosts then
        for k, _ in pairs(self.attribBoosts) do
            character:removeBoost(self.uniqueID, k)
        end
    end

    if isnumber(self.armor) then client:SetArmor(math.max(client:Armor() - self.armor, 0)) end
    self:getOwner():SetupHands()
    self:call("onTakeOff", client)
end

function ITEM:wearOutfit(client, isForLoadout)
    if isnumber(self.armor) then client:SetArmor(client:Armor() + self.armor) end
    if self.pacData and client.addPart then client:addPart(self.uniqueID) end
    self:getOwner():SetupHands()
    self:call("onWear", client, nil, isForLoadout)
end

ITEM.functions.Unequip = {
    name = "unequip",
    tip = "equipTip",
    icon = "icon16/cross.png",
    onRun = function(item)
        item:removeOutfit(item.player)
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and item:getData("equip", false) end
}

ITEM.functions.Equip = {
    name = "equip",
    tip = "equipTip",
    icon = "icon16/tick.png",
    onRun = function(item)
        local character = item.player:getChar()
        local items = character:getInv():getItems()
        for _, other in pairs(items) do
            if item ~= other and item.outfitCategory == other.outfitCategory and other:getData("equip") then
                item.player:notifyErrorLocalized("sameOutfitCategory")
                return false
            end
        end

        item:setData("equip", true)
        if hook.Run("CanOutfitChangeModel", item) ~= false then
            if isfunction(item.onGetReplacement) then
                character:setModel(item:onGetReplacement())
                item:setData("oldMdl", item.player:GetModel())
            elseif item.replacement or item.replacements then
                if istable(item.replacements) then
                    item:setData("oldMdl", item.player:GetModel())
                    if #item.replacements == 2 and isstring(item.replacements[1]) then
                        local newModel = item.player:GetModel():lower():gsub(item.replacement[1], item.replacements[2]):lower()
                        character:setModel(newModel)
                    else
                        for _, v in ipairs(item.replacements) do
                            character:setModel(item.player:GetModel():gsub(v[1], v[2]))
                        end
                    end
                else
                    item:setData("oldMdl", item.player:GetModel())
                    character:setModel(tostring(item.replacement or item.replacements))
                end
            end

            if isnumber(item.newSkin) then
                item:setData("oldSkin", item.player:GetSkin())
                character:setSkin(item.newSkin)
                item.player:SetSkin(item.newSkin)
            end

            if istable(item.bodyGroups) then
                local oldGroups = character:getData("oldGroups", {})
                local groups = {}
                for k, value in pairs(item.bodyGroups) do
                    local index = item.player:FindBodygroupByName(k)
                    if index > -1 then
                        oldGroups[index] = item.player:GetBodygroup(index)
                        groups[index] = value
                    end
                end

                character:setData("oldGroups", oldGroups)
                item:setData("oldGroups", oldGroups)
                local newGroups = character:getBodygroups()
                for index, value in pairs(groups) do
                    newGroups[index] = value
                    item.player:SetBodygroup(index, value)
                end

                if table.Count(newGroups) > 0 then character:setBodygroups(newGroups) end
            end
        end

        if istable(item.attribBoosts) then
            for attribute, boost in pairs(item.attribBoosts) do
                character:addBoost(item.uniqueID, attribute, boost)
            end
        end

        item:wearOutfit(item.player, false)
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and item:getData("equip") ~= true end
}

function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
    return true
end

function ITEM:onLoadout()
    if self:getData("equip") then self:wearOutfit(self.player, true) end
end

function ITEM:onRemoved()
    if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") then self:removeOutfit(receiver) end
end

ITEM:hook("drop", function(item) if item:getData("equip") then item:removeOutfit(item.player) end end)
--[[
Example Item:

```lua
-- Basic item identification
    ITEM.name = "Police Uniform"                 -- Display name shown to players
    ITEM.desc = "Standard police officer uniform with vest"  -- Description text
    ITEM.category = "outfit"                     -- Category for inventory sorting
    ITEM.model = "models/props_c17/BriefCase001a.mdl"  -- 3D model for the item
    ITEM.width = 1                               -- Inventory width (1 slot)
    ITEM.height = 1                              -- Inventory height (1 slot)
    ITEM.outfitCategory = "model"                -- Category to prevent conflicting outfits
    ITEM.pacData = {}                            -- PAC3 outfit data (empty for basic model replacement)
    ITEM.isOutfit = true                         -- Marks this as an outfit item
    ITEM.replacement = "models/player/police.mdl" -- Model to replace player's model with
    ITEM.attribBoosts = {                        -- Attribute bonuses when equipped
        ["endurance"] = 5,                        -- +5 endurance attribute
        ["luck"] = -2                             -- -2 luck attribute
    }
```
]]
