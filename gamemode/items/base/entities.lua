ITEM.name = "entitiesName"
ITEM.model = ""
ITEM.desc = "entitiesDesc"
ITEM.category = "entities"
ITEM.entityid = ""
ITEM.functions.Place = {
    name = "placeDownEntity",
    onRun = function(item)
        local client = item.player
        local entity = ents.Create(item.entityid)
        local pos = IsValid(item.entity) and item.entity:GetPos() or client:getItemDropPos()
        entity:SetPos(pos)
        entity:Spawn()
        item:remove()
        return true
    end,
}
