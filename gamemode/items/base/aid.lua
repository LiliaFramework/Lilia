ITEM.name = "aidName"
ITEM.desc = "aidDesc"
ITEM.model = "models/weapons/w_package.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.health = 0
ITEM.functions.use = {
    name = "use",
    sound = "items/medshot4.wav",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            local newHealth = math.min(client:Health() + item.health, client:GetMaxHealth())
            client:SetHealth(newHealth)
        end
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
                local newHealth = math.min(target:Health() + item.health, target:GetMaxHealth())
                target:SetHealth(newHealth)
            else
                client:notifyErrorLocalized("invalidTargetNeedLiving")
            end
        end
    end,
    onCanRun = function(item)
        local client = item.player
        local target = client:getTracedEntity()
        return not IsValid(item.entity) and IsValid(target)
    end
}