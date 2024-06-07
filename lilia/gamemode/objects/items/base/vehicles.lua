ITEM.name = "Entities Base"
ITEM.model = ""
ITEM.desc = ""
ITEM.category = "Vehicles"
ITEM.vehicleid = ""
ITEM.shouldRemove = true
ITEM.vehicleCooldown = 0
ITEM.functions.Place = {
    onRun = function(item)
        local client = item.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local vehicle = ents.Create(item.vehicleid)
        vehicle:SetPos(data.endpos)
        vehicle:Spawn()
        cliemt:SetNW2Bool("ItemCooldown_" .. item.uniqueID, true)
        timer.Create(client:SteamID64() .. "_" .. item.uniqueID .. "_cooldown", item.vehicleCooldown, 1, function() cliemt:SetNW2Bool("ItemCooldown_" .. item.uniqueID, false) end)
        return item.shouldRemove
    end,
    onCanRun = function(item)
        local client = item.player
        return not IsValid(item.entity) and not client:GetNW2Bool("ItemCooldown_" .. item.uniqueID, false)
    end
}