--------------------------------------------------------------------------------------------------------------------------
ITEM.name = "Entities Base"
ITEM.model = ""
ITEM.description = ""
ITEM.category = "Entities"
ITEM.entityid = ""
--------------------------------------------------------------------------------------------------------------------------
ITEM.functions.Place = {
    onRun = function(itemTable)
        local client = itemTable.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local ent = ents.Create(itemTable.entityid)
        ent:SetPos(data.endpos)
        ent:Spawn()
    end
}
--------------------------------------------------------------------------------------------------------------------------