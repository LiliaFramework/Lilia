--- Structure of Ammunition Item Base.
-- @items Ammunition

--- This table defines the default structure of the ammo item base.
-- @realm shared
-- @table Configuration
-- @field name Name of the item | **string**
-- @field desc Description of the item | **string**
-- @field model Model path of the item | **string**
-- @field width Width of the item | **number**
-- @field height Height of the item | **number**
-- @field category Category of the item | **string**
-- @field health Amount of health given to a player| **number**

ITEM.name = "Aid Items"
ITEM.desc = "Heals you bruh."
ITEM.model = "models/weapons/w_package.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.health = 0
ITEM.functions.use = {
    name = "Use",
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
    name = "Target",
    sound = "items/medshot4.wav",
    onRun = function(item)
        local client = item.player
        if IsValid(client) then
            local target = client:GetEyeTrace().Entity
            if IsValid(target) and target:IsPlayer() and target:Alive() then
                local newHealth = math.min(target:Health() + item.health, target:GetMaxHealth())
                target:SetHealth(newHealth)
            else
                client:notify("Target not valid! You must be looking at a living player!")
            end
        end
    end,
    onCanRun = function(item)
        local client = item.player
        local target = client:GetEyeTrace().Entity
        return not IsValid(item.entity) and IsValid(target)
    end
}