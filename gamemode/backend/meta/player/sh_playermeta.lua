--------------------------------------------------------------------------------------------------------
local SCHEMA = SCHEMA
--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
function playerMeta:isObserving()
    if self:GetMoveType() == MOVETYPE_NOCLIP and not self:InVehicle() then
        return true
    else
        return false
    end
end
--------------------------------------------------------------------------------------------------------
function playerMeta:EndChatter()
    timer.Simple(
        1,
        function()
            if not listener:IsValid() or not listener:Alive() or hook.Run("ShouldRadioBeep", listener) == false then return false end
            listener:EmitSound("npc/metropolice/vo/off" .. math.random(1, 3) .. ".wav", math.random(60, 70), math.random(80, 120))
        end
    )
end
--------------------------------------------------------------------------------------------------------
function playerMeta:IsNoClipping()
    return self:GetMoveType() == MOVETYPE_NOCLIP
end
--------------------------------------------------------------------------------------------------------
function playerMeta:IsStuck()
    return util.TraceEntity(
        {
            start = self:GetPos(),
            endpos = self:GetPos(),
            filter = self
        }, self
    ).StartSolid
end
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
function playerMeta:isRunning()
    return FindMetaTable("Vector").Length2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
end
--------------------------------------------------------------------------------------------------------
function playerMeta:isFemale()
    local model = self:GetModel():lower()

    return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
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
function playerMeta:SelectWeapon(class)
    if not self:HasWeapon(class) then return end
    self.doWeaponSwitch = self:GetWeapon(class)
end
--------------------------------------------------------------------------------------------------------
function playerMeta:HasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)

    return currentLevel >= level
end
--------------------------------------------------------------------------------------------------------
function playerMeta:MeetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:HasSkillLevel(skill, level) then return false end
    end

    return true
end
--------------------------------------------------------------------------------------------------------
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity

    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end
--------------------------------------------------------------------------------------------------------