local panelMeta = FindMetaTable("Panel")
--[[
    liaListenForInventoryChanges

    Purpose:
        Sets up hooks to listen for changes in the given inventory and calls corresponding panel methods when changes occur.
        Automatically removes hooks when the inventory is deleted or when requested.

    Parameters:
        inventory (Inventory) - The inventory object to listen for changes on.

    Returns:
        nil

    Realm:
        Shared.

    Example Usage:
        -- Listen for changes on an inventory and update the panel accordingly
        panel:liaListenForInventoryChanges(inventory)
]]
function panelMeta:liaListenForInventoryChanges(inventory)
    assert(inventory, L("noInventorySet"))
    local id = inventory:getID()
    self:liaDeleteInventoryHooks(id)
    _LIA_INV_PANEL_ID = (_LIA_INV_PANEL_ID or 0) + 1
    local hookID = "liaInventoryListener" .. _LIA_INV_PANEL_ID
    self.liaHookID = self.liaHookID or {}
    self.liaHookID[id] = hookID
    self.liaToRemoveHooks = self.liaToRemoveHooks or {}
    self.liaToRemoveHooks[id] = {}
    local function listenForInventoryChange(eventName, panelHookName)
        panelHookName = panelHookName or eventName
        hook.Add(eventName, hookID, function(inv, ...)
            if not IsValid(self) then return end
            if not isfunction(self[panelHookName]) then return end
            local args = {...}
            args[#args + 1] = inv
            self[panelHookName](self, unpack(args))
            if eventName == "InventoryDeleted" then self:liaDeleteInventoryHooks(id) end
        end)

        table.insert(self.liaToRemoveHooks[id], eventName)
    end

    listenForInventoryChange("InventoryInitialized")
    listenForInventoryChange("InventoryDeleted")
    listenForInventoryChange("InventoryDataChanged")
    listenForInventoryChange("InventoryItemAdded")
    listenForInventoryChange("InventoryItemRemoved")
    hook.Add("ItemDataChanged", hookID, function(item, key, oldValue, newValue)
        if not IsValid(self) or not inventory.items[item:getID()] then return end
        if not isfunction(self.InventoryItemDataChanged) then return end
        self:InventoryItemDataChanged(item, key, oldValue, newValue, inventory)
    end)

    table.insert(self.liaToRemoveHooks[id], "ItemDataChanged")
end

--[[
    liaDeleteInventoryHooks

    Purpose:
        Removes all hooks associated with inventory changes for the given inventory ID.
        If no ID is provided, removes all inventory hooks associated with this panel.

    Parameters:
        id (number, optional) - The inventory ID to remove hooks for. If nil, removes all hooks.

    Returns:
        nil

    Realm:
        Shared.

    Example Usage:
        -- Remove hooks for a specific inventory
        panel:liaDeleteInventoryHooks(inventoryID)

        -- Remove all inventory hooks for this panel
        panel:liaDeleteInventoryHooks()
]]
function panelMeta:liaDeleteInventoryHooks(id)
    if not self.liaHookID then return end
    if id == nil then
        for invID, hookIDs in pairs(self.liaToRemoveHooks) do
            for i = 1, #hookIDs do
                if IsValid(self.liaHookID) then hook.Remove(hookIDs[i], self.liaHookID) end
            end

            self.liaToRemoveHooks[invID] = nil
        end
        return
    end

    if not self.liaHookID[id] then return end
    for i = 1, #self.liaToRemoveHooks[id] do
        hook.Remove(self.liaToRemoveHooks[id][i], self.liaHookID[id])
    end

    self.liaToRemoveHooks[id] = nil
end

--[[
    SetScaledPos

    Purpose:
        Sets the position of the panel using scaled screen coordinates for resolution independence.

    Parameters:
        x (number) - The X position (unscaled).
        y (number) - The Y position (unscaled).

    Returns:
        nil

    Realm:
        Shared.

    Example Usage:
        -- Set the panel's position to (10, 20) in scaled screen units
        panel:SetScaledPos(10, 20)
]]
function panelMeta:SetScaledPos(x, y)
    self:SetPos(ScreenScale(x), ScreenScaleH(y))
end

--[[
    SetScaledSize

    Purpose:
        Sets the size of the panel using scaled screen dimensions for resolution independence.

    Parameters:
        w (number) - The width (unscaled).
        h (number) - The height (unscaled).

    Returns:
        nil

    Realm:
        Shared.

    Example Usage:
        -- Set the panel's size to 100x50 in scaled screen units
        panel:SetScaledSize(100, 50)
]]
function panelMeta:SetScaledSize(w, h)
    self:SetSize(ScreenScale(w), ScreenScaleH(h))
end
