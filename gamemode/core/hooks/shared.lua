local GM = GM or GAMEMODE
function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    local client = character:getPlayer()
    if varName == "model" then hook.Run("PlayerModelChanged", client, newVar) end
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

function GM:GetModelGender(model)
    local isFemale = model:find("alyx") or model:find("mossman") or model:find("female")
    return isFemale and "female" or "male"
end

function GM:GetAttributeLimits(client, attribute)
    local attribTable = attribute and lia.attribs.list[attribute]
    return {
        max = istable(attribTable) and isnumber(attribTable.maxValue) and attribTable.maxValue or lia.config.get("MaxAttributePoints"),
        startingMax = istable(attribTable) and isnumber(attribTable.startingMax) and attribTable.startingMax or lia.config.get("MaxStartingAttributes"),
        startingPoints = lia.config.get("StartingAttributePoints", 30)
    }
end
