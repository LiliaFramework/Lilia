--------------------------------------------------------------------------------------------------------
ITEM.name = "Radio"
ITEM.desc = "Radio to use to talk to other people"
ITEM.uniqueID = "radio"
ITEM.model = "models/gibs/shield_scanner_gib1.mdl"
ITEM.category = "Tools"
--------------------------------------------------------------------------------------------------------
ITEM.functions.enable = {
    name = "Turn On",
    icon = "icon16/connect.png",
    onRun = function(item)
        local client = item.player
        local items = client:getChar():getInv():getItems()
        client.RadioCount = client.RadioCount or {}
        for k, v in pairs(items) do
            if v.id ~= item.id then
                if v.uniqueID == item.uniqueID and v:getData("enabled") then
                    client:notify("You already have a radio equipped!")

                    return false
                end
            end
        end

        item:setData("enabled", true)
        client:EmitSound("buttons/combine_button1.wav", 50, 170)

        return false
    end,
    onCanRun = function(item)
        if item.entity then return false end
        if not item:getData("enabled") then return true end

        return false
    end
}
--------------------------------------------------------------------------------------------------------
ITEM.functions.disable = {
    name = "Turn Off",
    icon = "icon16/disconnect.png",
    onRun = function(item)
        local client = item.player
        item:setData("enabled", false)
        client:EmitSound("buttons/combine_button1.wav", 50, 170)

        return false
    end,
    onCanRun = function(item)
        if item.entity then return false end
        if item:getData("enabled") then return true end

        return false
    end
}
--------------------------------------------------------------------------------------------------------
ITEM.functions.changeFreq = {
    name = "Change Frequency",
    icon = "icon16/transmit_blue.png",
    onRun = function(item)
        netstream.Start(item.player, "radioAdjust", item:getData("freq", 000, 0), item.id)

        return false
    end,
    onCanRun = function(item)
        if item.entity then return false end
        if item:getData("enabled") then return true end

        return false
    end
}
--------------------------------------------------------------------------------------------------------
function ITEM:getDesc()
    local str
    if not self.entity or not IsValid(self.entity) then
        str = "A Pager that allows you to send a signal to other characters in distance.\nPower: %s\nFrequency: %s"

        return Format(str, self:getData("enabled") and "On" or "Off", self:getData("freq", 000.0))
    else
        local data = self.entity:getData()
        str = "A Functional Pager. Power: %s Frequency: %s"

        return Format(str, self.entity:getData("enabled") and "On" or "Off", self.entity:getData("freq", 000.0))
    end
end
--------------------------------------------------------------------------------------------------------
if CLIENT then
    function ITEM:paintOver(item, w, h)
        if item:getData("enabled") then
            surface.SetDrawColor(110, 255, 110, 100)
        else
            surface.SetDrawColor(255, 110, 110, 100)
        end

        surface.DrawRect(w - 14, h - 14, 8, 8)
    end
end
--------------------------------------------------------------------------------------------------------