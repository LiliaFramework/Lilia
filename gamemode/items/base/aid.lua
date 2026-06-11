ITEM.name = "aidName"
ITEM.desc = "aidDesc"
ITEM.model = "models/weapons/w_package.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.health = 0
ITEM.armor = 0
ITEM.stamina = 0
ITEM.healTime = 0
ITEM.healInterval = 1
local function applyHealthOverTime(item, target)
    local totalHealth = math.max(math.floor(tonumber(item.health) or 0), 0)
    local healTime = math.max(tonumber(item.healTime) or 0, 0)
    if totalHealth <= 0 then return end
    if healTime <= 0 then
        target:SetHealth(math.min(target:Health() + totalHealth, target:GetMaxHealth()))
        return
    end

    local interval = math.max(tonumber(item.healInterval) or 1, 0.1)
    local ticks = math.max(math.ceil(healTime / interval), 1)
    local timerID = "liaAidHeal_" .. target:EntIndex() .. "_" .. tostring(item.id or item.uniqueID or "base") .. "_" .. tostring(math.floor(SysTime() * 1000))
    local healPerTick = math.floor(totalHealth / ticks)
    local remainder = totalHealth % ticks
    timer.Create(timerID, interval, ticks, function()
        if not IsValid(target) or not target:Alive() then
            timer.Remove(timerID)
            return
        end

        if target:Health() >= target:GetMaxHealth() then
            timer.Remove(timerID)
            return
        end

        local amount = healPerTick
        if remainder > 0 then
            amount = amount + 1
            remainder = remainder - 1
        end

        if amount > 0 then target:SetHealth(math.min(target:Health() + amount, target:GetMaxHealth())) end
    end)
end

local function applyAidEffects(item, target, staminaTarget)
    applyHealthOverTime(item, target)
    if item.armor > 0 then
        local newArmor = math.min(target:Armor() + item.armor, target:GetMaxArmor())
        target:SetArmor(newArmor)
    end

    if item.stamina > 0 and IsValid(staminaTarget) then staminaTarget:restoreStamina(item.stamina) end
end

ITEM.functions.use = {
    name = "use",
    sound = "items/medshot4.wav",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then applyAidEffects(item, client, client) end
    end
}

ITEM.functions.target = {
    name = "itemUseOnTarget",
    sound = "items/medshot4.wav",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            local target = client:getTracedEntity()
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                applyAidEffects(item, target, client)
                return true
            else
                client:notifyErrorLocalized("invalidTargetNeedLiving")
                return false
            end
        end
    end,
    onCanRun = function(item)
        local client = item.player
        local target = client:getTracedEntity()
        return not IsValid(item.entity) and IsValid(target)
    end
}
