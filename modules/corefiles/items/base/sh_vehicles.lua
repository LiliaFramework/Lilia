--------------------------------------------------------------------------------------------------------
ITEM.name = "Vehicles Base"
ITEM.model = ""
ITEM.description = ""
ITEM.category = "Vehicles"
ITEM.vehicleid = ""

--------------------------------------------------------------------------------------------------------
ITEM.functions.Place = {
    onRun = function(itemTable)
        local client = itemTable.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local ent = ents.Create(itemTable.vehicleid)
        ent:SetPos(data.endpos)
        ent:Spawn()
    end
}
--------------------------------------------------------------------------------------------------------