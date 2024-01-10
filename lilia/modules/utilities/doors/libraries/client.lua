
local toScreen = FindMetaTable("Vector").ToScreen

function DoorsCore:ShouldDrawEntityInfo(entity)
    if IsValid(entity) and entity.isDoor(entity) and not entity.getNetVar(entity, "disabled") then return true end
end


function DoorsCore:DrawEntityInfo(entity, alpha)
    if entity.isDoor(entity) and not entity:getNetVar("hidden") then
        local position = toScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)))
        local x, y = position.x, position.y
        local owner = entity.GetDTEntity(entity, 0)
        local name = entity.getNetVar(entity, "title", entity.getNetVar(entity, "name", IsValid(owner) and L"dTitleOwned" or L"dTitle"))
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
            lia.util.drawText(entity.getNetVar(entity, "noSell") and L"dIsNotOwnable" or L"dIsOwnable", x, y + 16, ColorAlpha(color_white, alpha), 1, 1)
        end
    end
end

