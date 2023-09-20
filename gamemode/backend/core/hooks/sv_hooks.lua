-------------------------------------------------------------------------------------------------------
local last_jump_time = 0
-------------------------------------------------------------------------------------------------------
local defaultAngleData = {
    ["models/items/car_battery01.mdl"] = Angle(-15, 180, 0),
    ["models/props_junk/harpoon002a.mdl"] = Angle(0, 0, 0),
    ["models/props_junk/propane_tank001a.mdl"] = Angle(-90, 0, 0),
}
-------------------------------------------------------------------------------------------------------
function GM:InitializedExtrasServer()
    if ArcCW then
        RunConsoleCommand("arccw_override_crosshair_off", "0")
    end
    self:OptimizeSeats()
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("Think", "CheckSchedules")
    hook.Remove("LoadGModSave", "LoadGModSave")
    local timers = {"CheckHookTimes", "HostnameThink"}
    for i = 1, #timers do
        local t = timers[i]
        if timer.Exists(t) then
            timer.Remove(t)
        end
    end

    hook.Add(
        "OnEntityCreated",
        "-",
        function(m)
            if m:IsWidget() then
                hook.Add(
                    "PlayerTick",
                    "GODisableEntWidgets2",
                    function(m, n)
                        widgets.PlayerTick(m, n)
                    end
                )

                hook.Remove("OnEntityCreated", "WidgetInit")
            end
        end
    )

    for k, v in pairs(ents.GetAll()) do
        if lia.config.EntitiesToBeRemoved[v:GetClass()] then
            v:Remove()
        end
    end

    timer.Simple(
        3,
        function()
            RunConsoleCommand("ai_serverragdolls", "1")
        end
    )
end
-------------------------------------------------------------------------------------------------------
function GM:OptimizeSeats()
    local EFL_NO_THINK_FUNCTION = EFL_NO_THINK_FUNCTION
    local loop, nicoSeats, nicoEnabled
    hook.Add(
        "OnEntityCreated",
        "nicoSeat",
        function(seat)
            if seat:GetClass() == "prop_vehicle_prisoner_pod" then
                seat:AddEFlags(EFL_NO_THINK_FUNCTION)
                seat.nicoSeat = true
            end
        end
    )

    hook.Add(
        "Think",
        "nicoSeat",
        function()
            if not nicoSeats or not nicoSeats[loop] then
                loop = 1
                nicoSeats = {}
                for _, seat in ipairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
                    if seat.nicoSeat then
                        table.insert(nicoSeats, seat)
                    end
                end
            end

            while nicoSeats[loop] and not IsValid(nicoSeats[loop]) do
                loop = loop + 1
            end

            local seat = nicoSeats[loop]
            if nicoEnabled ~= seat and IsValid(nicoEnabled) then
                local saved = nicoEnabled:GetSaveTable()
                if not saved["m_bEnterAnimOn"] and not saved["m_bExitAnimOn"] then
                    nicoEnabled:AddEFlags(EFL_NO_THINK_FUNCTION)
                    nicoEnabled = nil
                end
            end

            if IsValid(seat) then
                seat:RemoveEFlags(EFL_NO_THINK_FUNCTION)
                nicoEnabled = seat
            end

            loop = loop + 1
        end
    )

    local function nicoSeatAction(ply, seat)
        if IsValid(seat) and seat.nicoSeat then
            table.insert(nicoSeats, loop, seat)
        end
    end

    hook.Add("PlayerEnteredVehicle", "nicoSeat", nicoSeatAction)
    hook.Add("PlayerLeaveVehicle", "nicoSeat", nicoSeatAction)
end
-------------------------------------------------------------------------------------------------------
function GM:EntityNetworkedVarChanged(entity, varName, oldVal, newVal)
    if varName == "Model" and entity.SetModel then
        hook.Run("PlayerModelChanged", entity, newVal)
    end
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerUse(client, entity)
    if simfphys and simfphys.IsCar(entity) and lia.config.TimeToEnterVehicle > 0 then
        if entity.IsLocked then return end
        client:setAction(
            "Entering Vehicle...",
            lia.config.TimeToEnterVehicle,
            function()
                entity:SetPassenger(client)
            end
        )
    end

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
function GM:KeyRelease(client, key)
    if key == IN_RELOAD then
        timer.Remove("liaToggleRaise" .. client:SteamID())
    end
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerLoadedChar(client, character, lastChar)
    local identifier = "RemoveMatSpecular" .. client:SteamID()
    local data = character:getData("pclass")
    local class = data and lia.class.list[data]
    if timer.Exists(identifier) then
        timer.Remove(identifier)
    end

    timer.Create(
        identifier,
        30,
        0,
        function()
            if not IsValid(player) or not character then return end
            if not player:Alive() then return end
            RunConsoleCommand("mat_specular", 0)
        end
    )

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
        }, nil, "characters", "_id = " .. character:getID()
    )

    if lastChar then
        local charEnts = lastChar:getVar("charEnts") or {}
        for _, v in ipairs(charEnts) do
            if v and IsValid(v) then
                v:Remove()
            end
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
function GM:ShutDown()
    if hook.Run("ShouldDataBeSaved") == false then return end
    lia.shuttingDown = true
    hook.Run("SaveData")
    for _, v in ipairs(player.GetAll()) do
        v:saveLiliaData()
        if v:getChar() then
            v:getChar():save()
        end
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
    if not speaker:Alive() then return false end
    if not listener:Alive() then return false end
    if not speaker:getChar() then return false end
    if not allowVoice then return false end
    if speaker:getChar():getData('VoiceBan') then return false end
    if not speaker:getNetVar("VoiceType", "Talking") then return false, false end
    local speakerRange = speaker:getNetVar("VoiceType", "Talking")
    local rangeSquared = (lia.config.TalkRanges[speakerRange] or 0) * (lia.config.TalkRanges[speakerRange] or 0)
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
        if v.onSave then
            v:call("onSave", client)
        end
    end
end
--------------------------------------------------------------------------------------------------------
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
        return lia.inventory.instance(
            "grid",
            {
                char = charID
            }
        )
    end
end
--------------------------------------------------------------------------------------------------------
function GM:LiliaTablesLoaded()
    local ignore = function()
        print("")
    end

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
    local ent = ply:GetTracedEntity()
    if not ent:IsPlayer() then return end
    if not CAMI.PlayerHasAccess(ply, "Lilia - Management - One Punch Man", nil) then return end
    if IsValid(ent) and ply:Team() == FACTION_STAFF then
        ply:ConsumeStamina(ent:getChar():GetMaxStamina())
        ent:EmitSound("weapons/crowbar/crowbar_impact" .. math.random(1, 2) .. ".wav", 70)
        ply:setRagdolled(true, 10)
    end
end
--------------------------------------------------------------------------------------------------------
function GM:OnCharFallover(client, entity, bFallenOver)
    bFallenOver = bFallenOver or false
    if IsValid(entity) then
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
        entity:SetCustomCollisionCheck(false)
    end

    client:setNetVar("fallingover", bFallenOver)
end
--------------------------------------------------------------------------------------------------------
function GM:CallMapCleanerInit()
    timer.Create(
        "clearWorldItemsWarning",
        lia.config.ItemCleanupTime - (60 * 10),
        0,
        function()
            net.Start("worlditem_cleanup_inbound")
            net.Broadcast()
            for i, v in pairs(player.GetAll()) do
                v:notify("World items will be cleared in 10 Minutes!")
            end
        end
    )

    timer.Create(
        "clearWorldItemsWarningFinal",
        lia.config.ItemCleanupTime - 60,
        0,
        function()
            net.Start("worlditem_cleanup_inbound_final")
            net.Broadcast()
            for i, v in pairs(player.GetAll()) do
                v:notify("World items will be cleared in 60 Seconds!")
            end
        end
    )

    timer.Create(
        "clearWorldItems",
        lia.config.ItemCleanupTime,
        0,
        function()
            for i, v in pairs(ents.FindByClass("lia_item")) do
                v:Remove()
            end
        end
    )

    timer.Create(
        "mapCleanupWarning",
        lia.config.MapCleanupTime - (60 * 10),
        0,
        function()
            net.Start("map_cleanup_inbound")
            net.Broadcast()
            for i, v in pairs(player.GetAll()) do
                v:notify("World items will be cleared in 10 Minutes!")
            end
        end
    )

    timer.Create(
        "mapCleanupWarningFinal",
        lia.config.MapCleanupTime - 60,
        0,
        function()
            net.Start("worlditem_cleanup_inbound_final")
            net.Broadcast()
            for i, v in pairs(player.GetAll()) do
                v:notify("World items will be cleared in 60 Seconds!")
            end
        end
    )

    timer.Create(
        "AutomaticMapCleanup",
        lia.config.MapCleanupTime,
        0,
        function()
            net.Start("cleanup_inbound")
            net.Broadcast()
            for i, v in pairs(ents.GetAll()) do
                if v:IsNPC() then
                    v:Remove()
                end
            end

            for i, v in pairs(ents.FindByClass("lia_item")) do
                v:Remove()
            end

            for i, v in pairs(ents.FindByClass("prop_physics")) do
                v:Remove()
            end
        end
    )
end
--------------------------------------------------------------------------------------------------------
function GM:InitalizedWorkshopDownloader()
    if workshop_items then
        for i = 1, #workshop_items do
            resource.AddWorkshop(engine.GetAddons()[i].wsid)
        end
    end
end
--------------------------------------------------------------------------------------------------------
function GM:ServerPostInit()
    if StormFox2 then
        RunConsoleCommand("sf_time_speed", 1)
        RunConsoleCommand("sf_addnight_temp", 4)
        RunConsoleCommand("sf_windmove_props", 0)
        RunConsoleCommand("sf_windmove_props_break", 0)
        RunConsoleCommand("sf_windmove_props_unfreeze", 0)
        RunConsoleCommand("sf_windmove_props_unweld", 0)
        RunConsoleCommand("sf_windmove_props_makedebris", 0)
    end

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

    for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
        if IsValid(v) and v:isDoor() then
            v:DrawShadow(false)
        end
    end

    lia.faction.formatModelData()
    timer.Simple(
        2,
        function()
            lia.entityDataLoaded = true
        end
    )

    lia.db.waitForTablesToLoad():next(
        function()
            hook.Run("LoadData")
            hook.Run("PostLoadData")
        end
    )
end
--------------------------------------------------------------------------------------------------------
function GM:KeyPress(client, key)
    local entity = client:GetEyeTrace().Entity
    if not IsValid(entity) then return end
    if entity:isDoor() and entity:IsPlayer() and key == IN_USE then
        hook.Run("PlayerUse", client, entity)
    end
end
--------------------------------------------------------------------------------------------------------