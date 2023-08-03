--------------------------------------------------------------------------------------------------------
local entityMeta = FindMetaTable("Entity")
local ChairCache = {}
--------------------------------------------------------------------------------------------------------
function lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
    delay = delay or 0
    spacing = spacing or 0.1

    for k, v in ipairs(sounds) do
        local postSet, preSet = 0, 0

        if istable(v) then
            postSet, preSet = v[2] or 0, v[3] or 0
            v = v[1]
        end

        local length = SoundDuration(SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/" .. v)
        delay = delay + preSet

        timer.Simple(delay, function()
            if IsValid(entity) then
                entity:EmitSound(v, volume, pitch)
            end
        end)

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
function entityMeta:isChair()
    return ChairCache[self:GetModel()]
end
--------------------------------------------------------------------------------------------------------
for k, v in pairs(list.Get("Vehicles")) do
    if v.Category == "Chairs" then
        ChairCache[v.Model] = true
    end
end
--------------------------------------------------------------------------------------------------------