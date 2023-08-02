local translations = {}

function lia.anim.setModelClass(model, class)
    if not lia.anim[class] then
        error("'" .. tostring(class) .. "' is not a valid animation class!")
    end

    translations[model:lower()] = class
end

local stringLower = string.lower
local stringFind = string.find

function lia.anim.getModelClass(model)
    model = stringLower(model)
    local class = translations[model]
    if class then return class end

    if model:find("/player") then
        class = "player"
    elseif stringFind(model, "female") then
        class = "citizen_female"
    else
        class = "citizen_male"
    end

    lia.anim.setModelClass(model, class)

    return class
end

do
    local playerMeta = FindMetaTable("Player")

    function playerMeta:forceSequence(sequence, callback, time, noFreeze)
        hook.Run("OnPlayerEnterSequence", self, sequence, callback, time, noFreeze)
        if not sequence then return netstream.Start(nil, "seqSet", self) end
        local sequence = self:LookupSequence(sequence)

        if sequence and sequence > 0 then
            time = time or self:SequenceDuration(sequence)
            self.liaSeqCallback = callback
            self.liaForceSeq = sequence

            if not noFreeze then
                self:SetMoveType(MOVETYPE_NONE)
            end

            if time > 0 then
                timer.Create("liaSeq" .. self:EntIndex(), time, 1, function()
                    if IsValid(self) then
                        self:leaveSequence()
                    end
                end)
            end

            netstream.Start(nil, "seqSet", self, sequence)

            return time
        end

        return false
    end
    for model, animtype in pairs(lia.anim.DefaultTposingFixer) do
        lia.anim.setModelClass(model, animtype)
       end
    for model, animtype in pairs(lia.anim.PlayerModelTposingFixer) do
        lia.anim.setModelClass(model, animtype)
    end
    function playerMeta:leaveSequence()
        hook.Run("OnPlayerLeaveSequence", self)
        netstream.Start(nil, "seqSet", self)
        self:SetMoveType(MOVETYPE_WALK)
        self.liaForceSeq = nil

        if self.liaSeqCallback then
            self:liaSeqCallback()
        end
    end

    if CLIENT then
        netstream.Hook("seqSet", function(entity, sequence)
            if IsValid(entity) then
                if not sequence then
                    entity.liaForceSeq = nil

                    return
                end

                entity:SetCycle(0)
                entity:SetPlaybackRate(1)
                entity.liaForceSeq = sequence
            end
        end)
    end
end