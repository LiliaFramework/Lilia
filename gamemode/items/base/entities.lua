ITEM.name = "entitiesName"
ITEM.model = ""
ITEM.desc = "entitiesDesc"
ITEM.category = "entities"
ITEM.entityid = ""
ITEM.functions.Place = {
    name = "placeDownEntity",
    onRun = function(item)
        local client = item.player
        if not IsValid(item.entity) then
            local data = {}
            data.start = client:GetShootPos()
            data.endpos = data.start + client:GetAimVector() * 96
            data.filter = client
            local entity = ents.Create(item.entityid)
            entity:SetPos(data.endpos)
            entity:Spawn()
        else
            local entity = ents.Create(item.entityid)
            entity:SetPos(item.entity:GetPos())
            entity:Spawn()
            item:remove()
        end
        return true
    end,
}
