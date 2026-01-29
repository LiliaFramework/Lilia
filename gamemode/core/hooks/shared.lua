local GM = GM or GAMEMODE
function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

function GM:FindUseEntity(client, ent)
    return ent
end

function GM:MouthMoveAnimation()
    return nil
end

function GM:GrabEarAnimation()
    return nil
end

function GM:PreGamemodeLoaded()
    widgets.PlayerTick = function() end
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("PostDrawEffects", "RenderWidgets")
end

function GM:GetModelGender(model)
    local isFemale = model:find("alyx") or model:find("mossman") or model:find("female")
    return isFemale and "female" or "male"
end

function GM:GetAttributeMax(client, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.get("MaxAttributePoints") end
    if istable(attribTable) and isnumber(attribTable.maxValue) then return attribTable.maxValue end
    return lia.config.get("MaxAttributePoints")
end

function GM:GetAttributeStartingMax(client, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.get("MaxStartingAttributes") end
    if istable(attribTable) and isnumber(attribTable.startingMax) then return attribTable.startingMax end
    return lia.config.get("MaxStartingAttributes")
end

function GM:GetMaxStartingAttributePoints(client, default)
    return default or lia.config.get("StartingAttributePoints", 30)
end
