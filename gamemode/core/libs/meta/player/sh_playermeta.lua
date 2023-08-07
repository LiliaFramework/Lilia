--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
playerMeta.steamName = playerMeta.steamName or playerMeta.Name
playerMeta.SteamName = playerMeta.steamName

--------------------------------------------------------------------------------------------------------
function playerMeta:AddMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:TakeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:addMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:takeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end

--------------------------------------------------------------------------------------------------------
function playerMeta:canAfford(amount)
    local char = self:getChar()

    return char and char:hasMoney(amount)
end

--------------------------------------------------------------------------------------------------------
function playerMeta:GetMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end

--------------------------------------------------------------------------------------------------------
function playerMeta:CanAfford(amount)
    local char = self:getChar()

    return char and char:hasMoney(amount)
end

--------------------------------------------------------------------------------------------------------
function playerMeta:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    netstream.Start(self:GetPos(), "liaSyncGesture", self, a, b, c)
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getPlayTime()
    local diff = os.time(lia.util.dateToNumber(lia.lastJoin)) - os.time(lia.util.dateToNumber(lia.firstJoin))

    return diff + (RealTime() - lia.joinTime or 0)
end

--------------------------------------------------------------------------------------------------------
function playerMeta:isRunning()
    return FindMetaTable("Vector").Length2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
end

--------------------------------------------------------------------------------------------------------
function playerMeta:isFemale()
    local model = self:GetModel():lower()

    return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
end

--------------------------------------------------------------------------------------------------------
function playerMeta:GetItemDropPos()
    self:getItemDropPos()
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getItemDropPos()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = self:GetShootPos() + self:GetAimVector() * 86
    data.filter = self
    local trace = util.TraceLine(data)
    data.start = trace.HitPos
    data.endpos = data.start + trace.HitNormal * 46
    data.filter = {}
    trace = util.TraceLine(data)

    return trace.HitPos
end

--------------------------------------------------------------------------------------------------------
function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]

    if data then
        if data.isDefault then return true end
        local liaData = self:getLiliaData("whitelists", {})

        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
    end

    return false
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getItems()
    local char = self:getChar()

    if char then
        local inv = char:getInv()
        if inv then return inv:getItems() end
    end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getClass()
    local char = self:getChar()
    if char then return char:getClass() end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getClassData()
    local char = self:getChar()

    if char then
        local class = char:getClass()

        if class then
            local classData = lia.class.list[class]

            return classData
        end
    end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getChar()
    return lia.char.loaded[self.getNetVar(self, "char")]
end

function playerMeta:Name()
    local character = self.getChar(self)

    return character and character.getName(character) or self.steamName(self)
end

--------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------
function playerMeta:leaveSequence()
    hook.Run("OnPlayerLeaveSequence", self)
    netstream.Start(nil, "seqSet", self)
    self:SetMoveType(MOVETYPE_WALK)
    self.liaForceSeq = nil

    if self.liaSeqCallback then
        self:liaSeqCallback()
    end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:SelectWeapon(class)
    if not self:HasWeapon(class) then return end
    self.doWeaponSwitch = self:GetWeapon(class)
end

--------------------------------------------------------------------------------------------------------
lia.util.include("meta/player/sv_playermeta.lua")
lia.util.include("meta/player/cl_playermeta.lua")
--------------------------------------------------------------------------------------------------------
playerMeta.Nick = playerMeta.Name
playerMeta.GetName = playerMeta.Name