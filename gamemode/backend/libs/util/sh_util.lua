--------------------------------------------------------------------------------------------------------
lia.util.cachedMaterials = lia.util.cachedMaterials or {}
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

    for _, v in ipairs(player.GetAll()) do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

--------------------------------------------------------------------------------------------------------
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
    for _, v in ipairs(player.GetAll()) do
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
function lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
    delay = delay or 0
    spacing = spacing or 0.1
    for _, v in ipairs(sounds) do
        local postSet, preSet = 0, 0
        if istable(v) then
            postSet, preSet = v[2] or 0, v[3] or 0
            v = v[1]
        end

        local length = SoundDuration(SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/" .. v)
        delay = delay + preSet
        timer.Simple(
            delay,
            function()
                if IsValid(entity) then
                    entity:EmitSound(v, volume, pitch)
                end
            end
        )

        delay = delay + length + postSet + spacing
    end

    return delay
end

--------------------------------------------------------------------------------------------------------
function lia.util.stringMatches(a, b)
    if a and b then
        local a2, b2 = a:lower(), b:lower()
        if a == b then return true end
        if a2 == b2 then return true end
        if a:find(b) then return true end
        if a2:find(b2) then return true end
    end

    return false
end
--------------------------------------------------------------------------------------------------------