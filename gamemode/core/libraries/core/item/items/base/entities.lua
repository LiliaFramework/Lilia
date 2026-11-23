ITEM.name = "Entities Base"
ITEM.model = ""
ITEM.desc = "A Base Entity"
ITEM.category = "Entities"
ITEM.entityid = ""
ITEM.functions.Place = {
    name = "Place",
    onRun = function(item)
        local entity = ents.Create(item.entityid)
        entity:SetPos(IsValid(item.entity) and item.entity:GetPos() or item.player:getItemDropPos())
        entity:Spawn()
        item:remove()
        return true
    end,
}
