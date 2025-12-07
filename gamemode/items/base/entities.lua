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
            client:notifyError("You must place the entity down first!")
            return false
        end

        local entity = ents.Create(item.entityid)
        entity:SetPos(item.entity:GetPos())
        entity:Spawn()
        item:remove()
        return true
    end,
}
