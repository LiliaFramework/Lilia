local PANEL = FindMetaTable("Panel")

function PANEL:nutListenForInventoryChanges(inventory)
    self:liaListenForInventoryChanges(inventory)
end

-- Make it so the panel hooks below run when the inventory hooks do.
function PANEL:nutListenForInventoryChanges(inventory)
    self:liaListenForInventoryChanges(inventory)
end

function PANEL:liaListenForInventoryChanges(inventory)
    assert(inventory, "No inventory has been set!")
    local id = inventory:getID()
    -- Clean up old hooks
    self:liaDeleteInventoryHooks(id)
    _LIA_INV_PANEL_ID = (_LIA_INV_PANEL_ID or 0) + 1
    local hookID = "liaInventoryListener" .. _LIA_INV_PANEL_ID
    self.liaHookID = self.liaHookID or {}
    self.liaHookID[id] = hookID
    self.liaToRemoveHooks = self.liaToRemoveHooks or {}
    self.liaToRemoveHooks[id] = {}

    -- For each relevant inventory/item hook, add a listener that will
    -- trigger the associated panel hook.
    local function listenForInventoryChange(name, panelHook)
        panelHook = panelHook or name

        hook.Add(name, hookID, function(inventory, ...)
            if not IsValid(self) then return end
            if not isfunction(self[panelHook]) then return end

            local args = {...}

            args[#args + 1] = inventory
            self[panelHook](self, unpack(args))

            if name == "InventoryDeleted" and self.deleteInventoryHooks then
                self:deleteInventoryHooks(id)
            end
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

function PANEL:nutDeleteInventoryHooks(id)
    self:liaDeleteInventoryHooks(id)
end

-- Cleans up all the hooks created by listenForInventoryChanges()
function PANEL:liaDeleteInventoryHooks(id)
    -- If there are no hooks added, do nothing.
    if not self.liaHookID then return end

    -- If id is not set, delete all hooks.
    if id == nil then
        for invID, hookIDs in pairs(self.liaToRemoveHooks) do
            for i = 1, #hookIDs do
                if IsValid(self.liaHookID) then
                    hook.Remove(hookIDs[i], self.liaHookID)
                end
            end

            self.liaToRemoveHooks[invID] = nil
        end

        return
    end

    -- If id is set, delete the hooks corresponding to that ID.
    if not self.liaHookID[id] then return end

    for i = 1, #self.liaToRemoveHooks[id] do
        hook.Remove(self.liaToRemoveHooks[id][i], self.liaHookID[id])
    end

    self.liaToRemoveHooks[id] = nil
end

-- Make it so the panel hooks below run when the inventory hooks do.
function PANEL:ixListenForInventoryChanges(inventory)
    assert(inventory, "No inventory has been set!")
    local id = inventory:getID()
    -- Clean up old hooks
    self:liaDeleteInventoryHooks(id)
    _LIA_INV_PANEL_ID = (_LIA_INV_PANEL_ID or 0) + 1
    local hookID = "liaInventoryListener" .. _LIA_INV_PANEL_ID
    self.liaHookID = self.liaHookID or {}
    self.liaHookID[id] = hookID
    self.liaToRemoveHooks = self.liaToRemoveHooks or {}
    self.liaToRemoveHooks[id] = {}

    -- For each relevant inventory/item hook, add a listener that will
    -- trigger the associated panel hook.
    local function listenForInventoryChange(name, panelHook)
        panelHook = panelHook or name

        hook.Add(name, hookID, function(inventory, ...)
            if not IsValid(self) then return end
            if not isfunction(self[panelHook]) then return end

            local args = {...}

            args[#args + 1] = inventory
            self[panelHook](self, unpack(args))

            if name == "InventoryDeleted" and self.deleteInventoryHooks then
                self:deleteInventoryHooks(id)
            end
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

-- Cleans up all the hooks created by listenForInventoryChanges()
function PANEL:ixDeleteInventoryHooks(id)
    -- If there are no hooks added, do nothing.
    if not self.liaHookID then return end

    -- If id is not set, delete all hooks.
    if id == nil then
        for invID, hookIDs in pairs(self.liaToRemoveHooks) do
            for i = 1, #hookIDs do
                if IsValid(self.liaHookID) then
                    hook.Remove(hookIDs[i], self.liaHookID)
                end
            end

            self.liaToRemoveHooks[invID] = nil
        end

        return
    end

    -- If id is set, delete the hooks corresponding to that ID.
    if not self.liaHookID[id] then return end

    for i = 1, #self.liaToRemoveHooks[id] do
        hook.Remove(self.liaToRemoveHooks[id][i], self.liaHookID[id])
    end

    self.liaToRemoveHooks[id] = nil
end