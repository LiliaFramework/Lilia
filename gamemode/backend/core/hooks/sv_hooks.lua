-------------------------------------------------------------------------------------------------------
lia.config.JumpCooldown = 0.8
-------------------------------------------------------------------------------------------------------
function GM:EntityNetworkedVarChanged(entity, varName, oldVal, newVal)
    if varName == "Model" and entity.SetModel then hook.Run("PlayerModelChanged", entity, newVal) end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerUse(client, entity)
    if client:getNetVar("restricted") then return false end
    if entity:isDoor() then
        local result = hook.Run("CanPlayerUseDoor", client, entity)
        if result == false then
            return false
        else
            result = hook.Run("PlayerUseDoor", client, entity)
            if result ~= nil then return result end
        end
    end
    return true
end

--------------------------------------------------------------------------------------------------------
function GM:KeyPress(client, key)
    if key == IN_USE then
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local entity = util.TraceLine(data).Entity
        if IsValid(entity) and entity:isDoor() or entity:IsPlayer() then hook.Run("PlayerUse", client, entity) end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:KeyRelease(client, key)
    if key == IN_RELOAD then timer.Remove("liaToggleRaise" .. client:SteamID()) end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerLoadedChar(client, character, lastChar)
    local data = character:getData("pclass")
    local class = data and lia.class.list[data]
    if class and data then
        local oldClass = character:GetClass()
        if client:Team() == class.faction then
            timer.Simple(
                .3,
                function()
                    character:setClass(class.index)
                    hook.Run("OnPlayerJoinClass", client, class.index, oldClass)
                end
            )
        end
    end

    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.updateTable(
        {
            _lastJoinTime = timeStamp
        },
        nil,
        "characters",
        "_id = " .. character:getID()
    )

    if lastChar then
        local charEnts = lastChar:getVar("charEnts") or {}
        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then v:Remove() end
        end

        lastChar:setVar("charEnts", nil)
    end

    if character then
        for _, v in pairs(lia.class.list) do
            if (v.faction == client:Team()) and v.isDefault then
                character:setClass(v.index)
                break
            end
        end
    end

    if IsValid(client.liaRagdoll) then
        client.liaRagdoll.liaNoReset = true
        client.liaRagdoll.liaIgnoreDelete = true
        client.liaRagdoll:Remove()
    end

    for _, ply in ipairs(player.GetAll()) do
        hook.Run("CreateSalaryTimer", ply)
    end

    local loginTime = os.time()
    character:setData("loginTime", loginTime)
    hook.Run("PlayerLoadout", client)
end

--------------------------------------------------------------------------------------------------------
function GM:CharacterLoaded(id)
    local character = lia.char.loaded[id]
    if character then
        local client = character:getPlayer()
        if IsValid(client) then
            local uniqueID = "liaSaveChar" .. client:SteamID()
            timer.Create(
                uniqueID,
                300,
                0,
                function()
                    if IsValid(client) and client:getChar() then
                        client:getChar():save()
                    else
                        timer.Remove(uniqueID)
                    end
                end
            )
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSay(client, message)
    local chatType, message, anonymous = lia.chat.parse(client, message, true)
    if (chatType == "ic") and lia.command.parse(client, message) then return "" end
    lia.chat.send(client, chatType, message, anonymous)
    hook.Run("PostPlayerSay", client, message, chatType, anonymous)
    return ""
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerDisconnected(client)
end

--------------------------------------------------------------------------------------------------------
function GM:InitPostEntity()
    local doors = ents.FindByClass("prop_door_rotating")
    for _, v in ipairs(doors) do
        local parent = v:GetOwner()
        if IsValid(parent) then
            v.liaPartner = parent
            parent.liaPartner = v
        else
            for _, v2 in ipairs(doors) do
                if v2:GetOwner() == v then
                    v2.liaPartner = v
                    v.liaPartner = v2
                    break
                end
            end
        end
    end

    lia.faction.formatModelData()
    timer.Simple(2, function() lia.entityDataLoaded = true end)
    lia.db.waitForTablesToLoad():next(
        function()
            hook.Run("LoadData")
            hook.Run("PostLoadData")
        end
    )
end

--------------------------------------------------------------------------------------------------------
function GM:ShutDown()
    if hook.Run("ShouldDataBeSaved") == false then return end
    lia.shuttingDown = true
    hook.Run("SaveData")
    for _, v in ipairs(player.GetAll()) do
        v:saveLiliaData()
        if v:getChar() then v:getChar():save() end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:InitializedSchema()
    local persistString = GetConVar("sbox_persist"):GetString()
    if persistString == "" or string.StartWith(persistString, "lia_") then
        local newValue = "lia_" .. SCHEMA.folder
        game.ConsoleCommand("sbox_persist " .. newValue .. "\n")
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerCanHearPlayersVoice(listener, speaker)
    local allowVoice = lia.config.AllowVoice
    if not allowVoice or not speaker:getChar() or not speaker:getNetVar("voiceRange", 2) then return false, false end
    local speakerRange = speaker:getNetVar("voiceRange", 2)
    local rangeSquared = (lia.config.Ranges[speakerRange] or 0) * (lia.config.Ranges[speakerRange] or 0)
    if listener:GetPos():DistToSqr(speaker:GetPos()) < rangeSquared then return true, true end
    return false, false
end

--------------------------------------------------------------------------------------------------------
function GM:PrePlayerLoadedChar(client, character, lastChar)
    client:SetBodyGroups("000000000")
    client:SetSkin(0)
end

--------------------------------------------------------------------------------------------------------
function GM:CharacterPreSave(character)
    local client = character:getPlayer()
    if not character:getInv() then return end
    for _, v in pairs(character:getInv():getItems()) do
        if v.onSave then v:call("onSave", client) end
    end
end

--------------------------------------------------------------------------------------------------------
local defaultAngleData = {
    ["models/items/car_battery01.mdl"] = Angle(-15, 180, 0),
    ["models/props_junk/harpoon002a.mdl"] = Angle(0, 0, 0),
    ["models/props_junk/propane_tank001a.mdl"] = Angle(-90, 0, 0),
}

function GM:GetPreferredCarryAngles(entity)
    if entity.preferedAngle then return entity.preferedAngle end
    local class = entity:GetClass()
    if class == "lia_item" then
        local itemTable = entity:getItemTable()
        if itemTable then
            local preferedAngle = itemTable.preferedAngle
            if preferedAngle then return preferedAngle end
        end
    elseif class == "prop_physics" then
        local model = entity:GetModel():lower()
        return defaultAngleData[model]
    end
end

--------------------------------------------------------------------------------------------------------
function GM:CreateDefaultInventory(character)
    local charID = character:getID()
    if lia.inventory.types["grid"] then
        return         lia.inventory.instance(
            "grid",
            {
                char = charID
            }
        )
    end
end

--------------------------------------------------------------------------------------------------------
function GM:LiliaTablesLoaded()
    local ignore = function()end
    lia.db.query("ALTER TABLE lia_players ADD COLUMN _firstJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE lia_players ADD COLUMN _lastJoin DATETIME"):catch(ignore)
    lia.db.query("ALTER TABLE lia_items ADD COLUMN _quantity INTEGER"):catch(ignore)
end

--------------------------------------------------------------------------------------------------------
function GM:CreateSalaryTimer(client)
    if lia.config.SalaryOverride then return end
    local character = client:getChar()
    if not character then return end
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    local pay = hook.Run("GetSalaryAmount", client, faction, class) or (class and class.pay) or (faction and faction.pay) or nil
    local limit = hook.Run("GetSalaryLimit", client, faction, class) or (class and class.payLimit) or (faction and faction.playLimit) or nil
    if not pay then return end
    local timerID = "liaSalary" .. client:SteamID()
    local timerFunc = timer.Exists(timerID) and timer.Adjust or timer.Create
    local delay = lia.config.SalaryInterval
    timerFunc(
        timerID,
        delay,
        0,
        function()
            if not IsValid(client) or client:getChar() ~= character then
                timer.Remove(timerID)
                return
            end

            if limit and character:getMoney() >= limit then return end
            character:giveMoney(pay)
            client:notifyLocalized("salary", lia.currency.get(pay))
        end
    )
end

--------------------------------------------------------------------------------------------------------
local last_jump_time = 0
--------------------------------------------------------------------------------------------------------
function GM:SetupMove(client, mv, cmd)
    if client:OnGround() and mv:KeyPressed(IN_JUMP) then
        local cur_time = CurTime()
        if cur_time - last_jump_time < lia.config.JumpCooldown then
            mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
        else
            last_jump_time = cur_time
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerThrowPunch(ply, trace)
    local ent = trace.Entity
    if not ent:IsPlayer() then return end
    if ply:IsSuperAdmin() and IsValid(ent) and ply:Team() == FACTION_STAFF then
        ply:ConsumeStamina(ent:getChar():GetMaxStamina())
        ent:EmitSound("weapons/crowbar/crowbar_impact" .. math.random(1, 2) .. ".wav", 70)
        ply:setRagdolled(true, 10)
    end
end

--------------------------------------------------------------------------------------------------------
function GM:OnCharFallover(client, entity, bFallenOver)
    if IsValid(entity) then
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
        entity:SetCustomCollisionCheck(false)
    end
end

--------------------------------------------------------------------------------------------------------
if lia.config.AutoWorkshopDownloader then
    for i = 1, #workshop_items do
        resource.AddWorkshop(engine.GetAddons()[i].wsid)
    end
end
--------------------------------------------------------------------------------------------------------