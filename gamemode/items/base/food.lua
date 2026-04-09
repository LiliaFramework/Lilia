ITEM.name = "foodName"
ITEM.desc = "foodDesc"
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.health = 0
ITEM.armor = 0
ITEM.stamina = 0
ITEM.hunger = 0
ITEM.thirst = 0
ITEM.useSound = "npc/barnacle/barnacle_crunch2.wav"
ITEM.trash = nil
ITEM.pack = nil
ITEM.isDrink = false
local function GiveItemOrSpawn(client, uniqueID, amount)
    if not uniqueID or amount <= 0 then return end
    local character = client:getChar()
    local inventory = character and character:getInv()
    for _ = 1, amount do
        if inventory and inventory:add(uniqueID) then continue end
        lia.item.spawn(uniqueID, client:getItemDropPos())
    end
end

local function ApplyFoodEffects(item, client)
    if not IsValid(client) then return false end
    if item.health > 0 then
        local newHealth = math.min(client:Health() + item.health, client:GetMaxHealth())
        client:SetHealth(newHealth)
    end

    if item.armor > 0 then
        local maxArmor = client.GetMaxArmor and client:GetMaxArmor() or 100
        client:SetArmor(math.min(client:Armor() + item.armor, maxArmor))
    end

    if item.stamina > 0 and client.restoreStamina then client:restoreStamina(item.stamina) end
    if item.hunger ~= 0 and client.addHunger then client:addHunger(item.hunger) end
    if item.thirst ~= 0 then
        if client.addThirst then
            client:addThirst(item.thirst)
        elseif client.addThrist then
            client:addThrist(item.thirst)
        end
    end

    client:EmitSound(item.useSound or (item.isDrink and "ambient/water/drip3.wav" or "npc/barnacle/barnacle_crunch2.wav"))
    local trash = item.trash
    if isstring(trash) and trash ~= "" then GiveItemOrSpawn(client, trash, 1) end
    return true
end

ITEM.functions.consume = {
    name = "consume",
    tip = "useTip",
    icon = "icon16/cup.png",
    onRun = function(item)
        local client = item.player
        if not ApplyFoodEffects(item, client) then return false end
    end,
    onCanRun = function(item) return not IsValid(item.entity) end
}

ITEM.functions.unpack = {
    name = "unpack",
    tip = "Open",
    icon = "icon16/box_open.png",
    onRun = function(item)
        local client = item.player
        local character = IsValid(client) and client:getChar()
        if not character then return false end
        if not istable(item.pack) or table.IsEmpty(item.pack) then return false end
        for uniqueID, amount in pairs(item.pack) do
            amount = math.max(tonumber(amount) or 0, 0)
            if amount <= 0 then continue end
            if uniqueID == "money" or uniqueID == "cash" or uniqueID == "token" or uniqueID == "tokens" then
                character:giveMoney(amount)
            else
                GiveItemOrSpawn(client, uniqueID, amount)
            end
        end

        client:EmitSound("physics/cardboard/cardboard_box_impact_soft2.wav", 50)
    end,
    onCanRun = function(item) return not IsValid(item.entity) and istable(item.pack) and not table.IsEmpty(item.pack) end
}
