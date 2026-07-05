ITEM.name = "outfit"
--[[
    Hooks:
        CanOutfitChangeModel(Item item)

    Purpose:
        Determines whether equipping or unequipping an outfit may change the character's model, skin, and bodygroups.

    Category:
        Items

    Parameters:
        item (Item)
            The outfit item being equipped or removed.

    Returns:
        boolean|nil
            Return false to stop the outfit from changing the player's appearance data. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanOutfitChangeModel", "liaExampleCanOutfitChangeModel", function(item)
            if item.outfitCategory == "uniform" then
                return true
            end
        end)
        ```

    Realm:
        Server
]]
ITEM.desc = "outfitDesc"
ITEM.category = "outfit"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "model"
ITEM.pacData = {}
ITEM.isOutfit = true
function ITEM:getOutfitSkin()
    if isnumber(self.newSkin) then return self.newSkin end
    if isnumber(self.skin) then return self.skin end
end

function ITEM:getOutfitBodygroups()
    if istable(self.bodyGroups) then return self.bodyGroups end
    if istable(self.bodygroups) then return self.bodygroups end
    return nil
end

function ITEM:getReplacementData(model)
    local currentModel = isstring(model) and model:lower() or ""
    local data = {
        model = nil,
        skin = self:getOutfitSkin(),
        bodygroups = self:getOutfitBodygroups()
    }

    if isfunction(self.onGetReplacement) then
        data.model = self:onGetReplacement()
        return data
    end

    if isstring(self.replacement) then
        data.model = self.replacement
        return data
    end

    if not istable(self.replacements) then
        if self.replacements ~= nil then data.model = tostring(self.replacements) end
        return data
    end

    local replacementEntry = currentModel ~= "" and self.replacements[currentModel] or nil
    if istable(replacementEntry) then
        data.model = replacementEntry.replacement or replacementEntry.model
        if isnumber(replacementEntry.newSkin) then
            data.skin = replacementEntry.newSkin
        elseif isnumber(replacementEntry.skin) then
            data.skin = replacementEntry.skin
        end

        if istable(replacementEntry.bodyGroups) then
            data.bodygroups = replacementEntry.bodyGroups
        elseif istable(replacementEntry.bodygroups) then
            data.bodygroups = replacementEntry.bodygroups
        end
        return data
    end

    if #self.replacements == 2 and isstring(self.replacements[1]) then
        data.model = currentModel:gsub(self.replacements[1], self.replacements[2]):lower()
        return data
    end

    for _, v in ipairs(self.replacements) do
        if istable(v) and isstring(v[1]) and isstring(v[2]) then data.model = currentModel:gsub(v[1], v[2]) end
    end
    return data
end

if CLIENT then
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
    local outfitBodygroups = self:getData("appliedBodygroups", self:getOutfitBodygroups() or {})
    self:setData("equip", nil)
    if hook.Run("CanOutfitChangeModel", self) ~= false then
        character:setModel(self:getData("oldMdl", character:getModel()))
        self:setData("oldMdl", nil)
        client:SetSkin(self:getData("oldSkin", character:getSkin()))
        self:setData("oldSkin", nil)
        local oldGroups = character:getData("oldGroups", {})
        for k in pairs(outfitBodygroups) do
            local index = lia.util.resolveBodygroupIndex(client, k)
            if index ~= nil then
                client:SetBodygroup(index, oldGroups[index] or 0)
                oldGroups[index] = nil
                local groups = lia.util.normalizeBodygroups(character.vars.bodygroups)
                if groups[index] then
                    groups[index] = nil
                    character:setBodygroups(groups)
                end
            end
        end

        character:setData("oldGroups", oldGroups)
    end

    self:setData("appliedBodygroups", nil)
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
        local replacementData = item:getReplacementData(item.player:GetModel())
        local outfitSkin = replacementData.skin
        local outfitBodygroups = replacementData.bodygroups
        local items = character:getInv():getItems()
        for _, other in pairs(items) do
            if item ~= other and item.outfitCategory == other.outfitCategory and other:getData("equip") then
                item.player:notifyErrorLocalized("sameOutfitCategory")
                return false
            end
        end

        item:setData("equip", true)
        if hook.Run("CanOutfitChangeModel", item) ~= false then
            if isstring(replacementData.model) and replacementData.model ~= "" then
                item:setData("oldMdl", item.player:GetModel())
                character:setModel(replacementData.model)
            end

            if isnumber(outfitSkin) then
                item:setData("oldSkin", item.player:GetSkin())
                character:setSkin(outfitSkin)
                item.player:SetSkin(outfitSkin)
            end

            if istable(outfitBodygroups) then
                local oldGroups = character:getData("oldGroups", {})
                local groups = {}
                for k, value in pairs(outfitBodygroups) do
                    local index = lia.util.resolveBodygroupIndex(item.player, k)
                    if index ~= nil then
                        local currentVal = item.player:GetBodygroup(index)
                        oldGroups[index] = currentVal
                        groups[index] = value
                    end
                end

                character:setData("oldGroups", oldGroups)
                item:setData("oldGroups", oldGroups)
                local newGroups = lia.util.normalizeBodygroups(character.vars.bodygroups)
                for index, value in pairs(groups) do
                    newGroups[index] = value
                end

                item:setData("appliedBodygroups", outfitBodygroups)
                lia.util.applyBodygroups(item.player, groups)
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
