local panelMeta = FindMetaTable("Panel")
function panelMeta:liaListenForInventoryChanges(inventory)
    assert(inventory, "No inventory has been set!")
    local id = inventory:getID()
    self:liaDeleteInventoryHooks(id)
    _LIA_INV_PANEL_ID = (_LIA_INV_PANEL_ID or 0) + 1
    local hookID = "liaInventoryListener" .. _LIA_INV_PANEL_ID
    self.liaHookID = self.liaHookID or {}
    self.liaHookID[id] = hookID
    self.liaToRemoveHooks = self.liaToRemoveHooks or {}
    self.liaToRemoveHooks[id] = {}
    local function listenForInventoryChange(name, panelHook)
        panelHook = panelHook or name
        hook.Add(name, hookID, function(inventory, ...)
            if not IsValid(self) then return end
            if not isfunction(self[panelHook]) then return end
            local args = {...}
            args[#args + 1] = inventory
            self[panelHook](self, unpack(args))
            if name == "InventoryDeleted" and self.deleteInventoryHooks then self:deleteInventoryHooks(id) end
        end)

        table.insert(self.liaToRemoveHooks[id], name)
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

function panelMeta:SetScaledPos(x, y)
    self:SetPos(ScreenScale(x), ScreenScaleH(y))
end

function panelMeta:SetScaledSize(w, h)
    self:SetSize(ScreenScale(w), ScreenScaleH(h))
end