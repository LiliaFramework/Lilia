local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
function MODULE:ShouldDrawEntityInfo(entity)
    if entity:isDoor() then return true end
    if entity:getNetVar("disabled", false) then return end
end

function MODULE:DrawEntityInfo(entity, alpha)
    if entity:isDoor() then
        local position = toScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)))
        local x, y = position.x, position.y
        local owner = entity.GetDTEntity(entity, 0)
        local name = entity.getNetVar(entity, "title", entity.getNetVar(entity, "name", IsValid(owner) and L"DoorTitleOwned" or L"DoorTitle"))
        local factions = entity.getNetVar(entity, "factions")
        lia.util.drawText(name, x, y, ColorAlpha(color_white, alpha), 1, 1)
        if IsValid(owner) then
            lia.util.drawText(L("dOwnedBy", owner.Name(owner)), x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
        elseif factions ~= "[]" and factions ~= nil then
            local facs = util.JSONToTable(factions)
            local count = 1
            for id, _ in pairs(facs) do
                local info = lia.faction.indices[id]
                lia.util.drawText(info.name, x, y + (16 * count), info.color, 1, 1)
                count = count + 1
            end
        else
            lia.util.drawText(entity.getNetVar(entity, "noSell") and L"DoorIsNotOwnable" or L"DoorIsOwnable", x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
        end
    end
end