---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isObserving()
    if self:GetMoveType() == MOVETYPE_NOCLIP and not self:InVehicle() then
        return true
    else
        return false
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isOutside()
    local trace = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() + self:GetUp() * 9999999999,
        filter = self
    })
    return trace.HitSky
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:IsNoClipping()
    return self:GetMoveType() == MOVETYPE_NOCLIP
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:IsStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:AddMoney(amount)
    local character = self:getChar()
    if not character then return end
    local currentMoney = character:getMoney()
    local maxMoneyLimit = lia.config.MoneyLimit or 0
    if hook.Run("WalletLimit", self) ~= nil then maxMoneyLimit = hook.Run("WalletLimit", self) end
    if maxMoneyLimit > 0 then
        local totalMoney = currentMoney + amount
        if totalMoney > maxMoneyLimit then
            local remainingMoney = totalMoney - maxMoneyLimit
            character:giveMoney(maxMoneyLimit)
            local money = lia.currency.spawn(self:getItemDropPos(), remainingMoney)
            money.client = self
            money.charID = character:getID()
        else
            character:giveMoney(amount)
        end
    else
        character:giveMoney(amount)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isNearPlayer(radius, entity)
    local squaredRadius = radius * radius
    local squaredDistance = self:GetPos():DistToSqr(entity:GetPos())
    return squaredDistance <= squaredRadius
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:entitiesNearPlayer(radius, playerOnly)
    local nearbyEntities = {}
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if playerOnly and not v:IsPlayer() then continue end
        table.insert(nearbyEntities, v)
    end
    return nearbyEntities
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isUser()
    return self:IsUserGroup("user")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isStaff()
    return CAMI.PlayerHasAccess(self, "UserGroups - Staff Group", nil) or self:IsSuperAdmin()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isVIP()
    return CAMI.PlayerHasAccess(self, "UserGroups - VIP Group", nil)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:getItemWeapon()
    local character = self:getChar()
    local inv = character:getInv()
    local items = inv:getItems()
    local weapon = self:GetActiveWeapon()
    if not IsValid(weapon) then return false end
    for _, v in pairs(items) do
        if v.class then
            if v.class == weapon:GetClass() then
                if v:getData("equip", false) then
                    return weapon, v
                else
                    return false
                end
            end
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:TakeMoney(amt)
    local character = self:getChar()
    if character then character:giveMoney(-amt) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:addMoney(amount)
    local character = self:getChar()
    if not character then return end
    local currentMoney = character:getMoney()
    local maxMoneyLimit = lia.config.MoneyLimit or 0
    if hook.Run("WalletLimit", self) ~= nil then maxMoneyLimit = hook.Run("WalletLimit", self) end
    if maxMoneyLimit > 0 then
        local totalMoney = currentMoney + amount
        if totalMoney > maxMoneyLimit then
            local remainingMoney = totalMoney - maxMoneyLimit
            character:giveMoney(maxMoneyLimit)
            local money = lia.currency.spawn(self:getItemDropPos(), remainingMoney)
            money.client = self
            money.charID = character:getID()
        else
            character:giveMoney(amount)
        end
    else
        character:giveMoney(amount)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:takeMoney(amt)
    local character = self:getChar()
    if character then character:giveMoney(-amt) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:GetMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:CanAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isRunning()
    return FindMetaTable("Vector").Length2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:isFemale()
    local model = self:GetModel():lower()
    return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        local liaData = self:getLiliaData("whitelists", {})
        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
    end
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:GetTracedEntity()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * 96
    data.filter = self
    local target = util.TraceLine(data).Entity
    return target
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:GetTrace()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * 200
    data.filter = {self, self}
    data.mins = -Vector(4, 4, 4)
    data.maxs = Vector(4, 4, 4)
    local trace = util.TraceHull(data)
    return trace
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:getClassData()
    local character = self:getChar()
    if character then
        local class = character:getClass()
        if class then
            local classData = lia.class.list[class]
            return classData
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:HasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:MeetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:HasSkillLevel(skill, level) then return false end
    end
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function playerMeta:RequestString(title, subTitle, callback, default)
    local time = math.floor(os.time())
    self.StrReqs = self.StrReqs or {}
    self.StrReqs[time] = callback
    net.Start("StringRequest")
    net.WriteUInt(time, 32)
    net.WriteString(title)
    net.WriteString(subTitle)
    net.WriteString(default)
    net.Send(self)
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
