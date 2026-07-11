if not ArcCWInstalled then return end
ITEM.name = "arccwAttachment"
ITEM.desc = "arccwAttachmentDesc"
ITEM.category = "attachments"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.att = ""
if CLIENT then
    function ITEM:paintOver(item, w, h)
        if item:getData("equip") then
            local markerY = h - 10
            local markerW = math.max(w - 12, 10)
            draw.RoundedBox(2, 6, markerY, markerW, 4, Color(105, 231, 170, 235))
            draw.RoundedBox(2, 6, markerY - 4, markerW, 2, Color(105, 231, 170, 90))
        end
    end
end

function ITEM:removeAttachment(client)
    if ArcCW:PlayerTakeAtt(client, self.att, 1) then
        self:setData("equip", nil)
        ArcCW:PlayerSendAttInv(client)
        return true
    end
    return false
end

function ITEM:addAttachment(client)
    ArcCW:PlayerGiveAtt(client, self.att, 1)
    ArcCW:PlayerSendAttInv(client)
end

local function unEquip(item)
    if not item:getData("equip") then return end
    if not item:removeAttachment(item.player) then item:setData("equip", nil) end
end

ITEM:hook("transfer", unEquip)
ITEM:hook("drop", unEquip)
ITEM.functions.Unequip = {
    name = "unequip",
    tip = "unequipThisItem",
    icon = "icon16/cross.png",
    onRun = function(item)
        if item:removeAttachment(item.player) then
            item.player:notifySuccessLocalized("attachmentUnequipped")
        else
            item.player:notifyErrorLocalized("attachmentUnequipFailed")
        end
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and item:getData("equip") == true end
}

ITEM.functions.Equip = {
    name = "equip",
    tip = "equipThisItem",
    icon = "icon16/tick.png",
    onRun = function(item)
        item:setData("equip", true)
        item:addAttachment(item.player)
        item.player:notifySuccessLocalized("attachmentEquipped")
        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) and item:getData("equip") ~= true end
}

function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
    return true
end

function ITEM:onLoadout()
    if self:getData("equip") then self:addAttachment(self.player) end
end

function ITEM:onRemoved()
    if IsValid(receiver) and receiver:IsPlayer() and self:getData("equip") and not self:removeAttachment(receiver) then self:setData("equip", nil) end
end
