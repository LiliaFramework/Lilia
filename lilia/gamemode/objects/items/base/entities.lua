--- Structure of Entity Item Base.
-- @items Entities

--- This table defines the default structure of the entity item base.
-- @realm shared
-- @table Configuration
-- @field name Name of the item | **string**
-- @field desc Description of the item | **string**
-- @field model Model path of the item | **string**
-- @field width Width of the item | **number**
-- @field height Height of the item | **number**
-- @field category Category of the item | **string**
-- @field entityid The entity to be spawned | **string**
-- @field shouldRemove Whether or not the item should be removed after the usage | **bool**
-- @field entityCooldown The cooldown that the item has before being reusable | **number**

ITEM.name = "Entities Base"
ITEM.model = ""
ITEM.desc = ""
ITEM.category = "Entities"
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
        local entity = ents.Create(item.entityid)
        entity:SetPos(data.endpos)
        entity:Spawn()
        cliemt:SetNW2Bool("ItemCooldown_" .. item.uniqueID, true)
        timer.Create(client:SteamID64() .. "_" .. item.uniqueID .. "_cooldown", item.entityCooldown, 1, function() cliemt:SetNW2Bool("ItemCooldown_" .. item.uniqueID, false) end)
        return item.shouldRemove
    end,
    onCanRun = function(item)
        local client = item.player
        return not IsValid(item.entity) and not client:GetNW2Bool("ItemCooldown_" .. item.uniqueID, false)
    end
}