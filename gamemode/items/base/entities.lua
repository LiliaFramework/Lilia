ITEM.name = "entitiesName"
ITEM.model = ""
ITEM.desc = "entitiesDesc"
ITEM.category = "entities"
ITEM.entityid = ""
ITEM.functions.Place = {
    name = "placeDownEntity",
    onRun = function(item)
        local entity = ents.Create(item.entityid)
        entity:SetPos(IsValid(item.entity) and item.entity:GetPos() or item.player:getItemDropPos())
        entity:Spawn()
        item:remove()
        return true
    end,
}
