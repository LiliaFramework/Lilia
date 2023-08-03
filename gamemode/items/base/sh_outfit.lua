ITEM.name = "Outfit"
ITEM.desc = "A Outfit Base."
ITEM.category = "Outfit"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "model"
ITEM.pacData = {}
ITEM.isOutfit = true

--[[
-- This will change a player's skin after changing the model.
-- Keep in mind it starts at 0.
ITEM.newSkin = 1

-- This will change a certain part of the model.
ITEM.replacements = {"group01", "group02"}

-- This will change the player's model completely.
ITEM.replacements = "models/manhack.mdl"

-- This will have multiple replacements.
ITEM.replacements = {
	{"male", "female"},
	{"group01", "group02"}
}

-- This will apply body groups.
ITEM.bodyGroups = {
	["blade"] = 1,
	["bladeblur"] = 1
}

ITEM.armor = 25 -- How much armor to add/remove upon wearing/removing.

-- You can also use PAC (if installed) to setup an outfit. Go to your outfit's
-- file in your GMod's data folder. Copy the contents.
ITEM.pacData = {
	-- PASTE CONTENT HERE>
}
]]
if CLIENT then
    function ITEM:paintOver(item, w, h)
        if item:getData("equip") then
            surface.SetDrawColor(110, 255, 110, 100)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
end

if SERVER then
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
        client:SetSkin(self:getData("oldSkin", character:getData("skin", 0)))
        self:setData("oldSkin", nil)
        local oldGroups = character:getData("oldGroups", {})

        for k in pairs(self.bodyGroups or {}) do
            local index = client:FindBodygroupByName(k)

            if index > -1 then
                client:SetBodygroup(index, oldGroups[index] or 0)
                oldGroups[index] = nil
                local groups = character:getData("groups", {})

                if groups[index] then
                    groups[index] = nil
                    character:setData("groups", groups)
                end
            end
        end

        character:setData("oldGroups", oldGroups)
    end

    if self.pacData and client.removePart then
        client:removePart(self.uniqueID)
    end

    if self.attribBoosts then
        for k, _ in pairs(self.attribBoosts) do
            character:removeBoost(self.uniqueID, k)
        end
    end

    if isnumber(self.armor) then
        client:SetArmor(math.max(client:Armor() - self.armor, 0))
    end

    self:call("onTakeOff", client)
end

function ITEM:wearOutfit(client, isForLoadout)
    if isnumber(self.armor) then
        client:SetArmor(client:Armor() + self.armor)
    end

    if self.pacData and client.addPart then
        client:addPart(self.uniqueID)
    end

    self:call("onWear", client, nil, isForLoadout)
end

ITEM:hook("drop", function(item)
    if item:getData("equip") then
        item:removeOutfit(item.player)
    end
end)

ITEM.functions.EquipUn = {
    name = "Unequip",
    tip = "equipTip",
    icon = "icon16/cross.png",
    onRun = function(item)
        item:removeOutfit(item.player)

        return false
    end,
    onCanRun = function(item)
        return not IsValid(item.entity) and item:getData("equip") == true
    end
}

ITEM.functions.Equip = {
    name = "Equip",
    tip = "equipTip",
    icon = "icon16/tick.png",
    onRun = function(item)
        local char = item.player:getChar()
        local items = char:getInv():getItems()

        for _, other in pairs(items) do
            if item ~= other and item.outfitCategory == other.outfitCategory and other:getData("equip") then
                item.player:notifyLocalized("sameOutfitCategory")

                return false
            end
        end

        item:setData("equip", true)

        if hook.Run("CanOutfitChangeModel", item) ~= false then
            if isfunction(item.onGetReplacement) then
                char:setModel(item:onGetReplacement())
                item:setData("oldMdl", item.player:GetModel())
            elseif item.replacement or item.replacements then
                if istable(item.replacements) then
                    if #item.replacements == 2 and isstring(item.replacements[1]) then
                        local newModel = item.player:GetModel():lower():gsub(item.replacement[1], item.replacements[2]):lower()
                        char:setModel(newModel)
                    else
                        for _, v in ipairs(item.replacements) do
                            char:setModel(item.player:GetModel():gsub(v[1], v[2]))
                        end
                    end
                else
                    char:setModel(tostring(item.replacement or item.replacements))
                end

                item:setData("oldMdl", item.player:GetModel())
            end

            if isnumber(item.newSkin) then
                item:setData("oldSkin", item.player:GetSkin())
                char:setData("skin", item.newSkin)
                item.player:SetSkin(item.newSkin)
            end

            if istable(item.bodyGroups) then
                local oldGroups = char:getData("oldGroups", {})
                local groups = {}

                for k, value in pairs(item.bodyGroups) do
                    local index = item.player:FindBodygroupByName(k)

                    if index > -1 then
                        oldGroups[index] = item.player:GetBodygroup(index)
                        groups[index] = value
                    end
                end

                char:setData("oldGroups", oldGroups)
                item:setData("oldGroups", oldGroups)
                local newGroups = char:getData("groups", {})

                for index, value in pairs(groups) do
                    newGroups[index] = value
                    item.player:SetBodygroup(index, value)
                end

                if table.Count(newGroups) > 0 then
                    char:setData("groups", newGroups)
                end
            end
        end

        if istable(item.attribBoosts) then
            for attribute, boost in pairs(item.attribBoosts) do
                char:addBoost(item.uniqueID, attribute, boost)
            end
        end

        item:wearOutfit(item.player, false)

        return false
    end,
    onCanRun = function(item)
        return not IsValid(item.entity) and item:getData("equip") ~= true
    end
}

function ITEM:onCanBeTransfered(oldInventory, newInventory)
    if newInventory and self:getData("equip") then return false end

    return true
end

function ITEM:onLoadout()
    if self:getData("equip") then
        self:wearOutfit(self.player, true)
    end
end

function ITEM:onRemoved()
    if (IsValid(receiver) and receiver:IsPlayer()) and self:getData("equip") then
        self:removeOutfit(receiver)
    end
end

function ITEM:onWear(isFirstTime)
end

function ITEM:onTakeOff()
end