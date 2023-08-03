--------------------------------------------------------------------------------------------------------
function lia.util.isSteamID(value)
    if string.match(value, "STEAM_(%d+):(%d+):(%d+)") then return true end

    return false
end

--------------------------------------------------------------------------------------------------------
function lia.util.findPlayer(identifier, allowPatterns)
    if lia.util.isSteamID(identifier) then return player.GetBySteamID(identifier) end

    if not allowPatterns then
        identifier = string.PatternSafe(identifier)
    end

    for k, v in ipairs(player.GetAll()) do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

function lia.util.gridVector(vec, gridSize)
    if gridSize <= 0 then
        gridSize = 1
    end

    for i = 1, 3 do
        vec[i] = vec[i] / gridSize
        vec[i] = math.Round(vec[i])
        vec[i] = vec[i] * gridSize
    end

    return vec
end

--------------------------------------------------------------------------------------------------------
function lia.util.getAllChar()
    local charTable = {}

    for k, v in ipairs(player.GetAll()) do
        if v:getChar() then
            table.insert(charTable, v:getChar():getID())
        end
    end

    return charTable
end

--------------------------------------------------------------------------------------------------------
function lia.util.getMaterial(materialPath)
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath)

    return lia.util.cachedMaterials[materialPath]
end
--------------------------------------------------------------------------------------------------------