﻿ITEM.name = "Entities Base"
ITEM.model = ""
ITEM.description = ""
ITEM.category = "Entities"
ITEM.entityid = ""
ITEM.functions.Place = {
    onRun = function(itemTable)
        local client = itemTable.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local entity = ents.Create(itemTable.entityid)
        entity:SetPos(data.endpos)
        entity:Spawn()
    end
}
