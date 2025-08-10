ITEM.name = "entitiesName"
ITEM.model = ""
ITEM.desc = "entitiesDesc"
ITEM.category = "entities"
ITEM.entityid = ""
ITEM.functions.Place = {
    name = "placeDownEntity",
    onRun = function(item)
        local client = item.player
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local entity = ents.Create(item.entityid)
        entity:SetPos(data.endpos)
        entity:Spawn()
        local physObj = entity:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(true)
            physObj:Wake()
        end
        return true
    end,
    onCanRun = function(item) return not IsValid(item.entity) end
}