--- Structure of Simfphys Item Base.
-- @items Simfphys

--- This table defines the default structure of the simfphys item base.
-- @realm shared
-- @table Configuration
-- @field name Name of the item | **string**
-- @field desc Description of the item | **string**
-- @field model Model path of the item | **string**
-- @field width Width of the item | **number**
-- @field height Height of the item | **number**
-- @field category Category of the item | **string**
-- @field vehicleid The simfphys vehicle to be spawned | **string**
-- @field shouldRemove Whether or not the item should be removed after the usage | **bool**
-- @field vehicleCooldown The cooldown that the item has before being reusable | **number**

ITEM.name = "Simfphys Vehicle Base"
ITEM.model = ""
ITEM.desc = ""
ITEM.category = "Vehicle"
ITEM.entityid = ""
ITEM.shouldRemove = true
ITEM.entityCooldown = 0
ITEM.functions.Place = {
    onRun = function(item)
        local client = item.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        simfphys.SpawnVehicleSimple(item.vehicleid, Vector(data.endpos), Angle(1, 1, 1))
        cliemt:SetNW2Bool("ItemCooldown_" .. item.uniqueID, true)
        timer.Create(client:SteamID64() .. "_" .. item.uniqueID .. "_cooldown", item.entityCooldown, 1, function() cliemt:SetNW2Bool("ItemCooldown_" .. item.uniqueID, false) end)
        return item.shouldRemove
    end,
    onCanRun = function(item)
        local client = item.player
        return not IsValid(item.entity) and not client:GetNW2Bool("ItemCooldown_" .. item.uniqueID, false)
    end
}