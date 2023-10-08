--------------------------------------------------------------------------------------------------------
local oldCalcSeqOverride
--------------------------------------------------------------------------------------------------------
lia.anim.DefaultTposingFixer = {
    ["models/police.mdl"] = "metrocop",
    ["models/combine_super_soldier.mdl"] = "overwatch",
    ["models/combine_soldier_prisonGuard.mdl"] = "overwatch",
    ["models/combine_soldier.mdl"] = "overwatch",
    ["models/vortigaunt.mdl"] = "vort",
    ["models/vortigaunt_blue.mdl"] = "vort",
    ["models/vortigaunt_doctor.mdl"] = "vort",
    ["models/vortigaunt_slave.mdl"] = "vort",
    ["models/alyx.mdl"] = "citizen_female",
    ["models/mossman.mdl"] = "citizen_female",
}
--------------------------------------------------------------------------------------------------------
function GM:InitializedConfig()
    if CLIENT then self:ClientInitializedConfig() end
    for tpose, animtype in pairs(lia.anim.DefaultTposingFixer) do
        lia.anim.setModelClass(tpose, animtype)
    end

    for customtpose, _ in pairs(lia.config.PlayerModelTposingFixer) do
        lia.anim.setModelClass(customtpose, "player")
    end

    hook.Run("InitializedModules")
end

--------------------------------------------------------------------------------------------------------
function GM:RegisterCamiPermissions()
    for _, PrivilegeInfo in pairs(lia.config.CAMIPrivileges) do
        local privilegeData = {
            Name = PrivilegeInfo.Name,
            MinAccess = PrivilegeInfo.MinAccess,
            Description = PrivilegeInfo.Description
        }

        if not CAMI.GetPrivilege(PrivilegeInfo.Name) then CAMI.RegisterPrivilege(privilegeData) end
    end

    for _, wep in pairs(weapons.GetList()) do
        if wep.ClassName == "gmod_tool" then
            for ToolName, TOOL in pairs(wep.Tool) do
                if not ToolName then continue end
                local privilege = "Lilia - Management - Access Tool " .. ToolName:gsub("^%l", string.upper)
                if not CAMI.GetPrivilege(privilege) then
                    local privilegeInfo = {
                        Name = privilege,
                        MinAccess = "admin",
                        Description = "Allows access to " .. ToolName:gsub("^%l", string.upper)
                    }

                    CAMI.RegisterPrivilege(privilegeInfo)
                end
            end
        end
    end

    for name, _ in pairs(properties.List) do
        local privilege = "Lilia - Management - Access Tool " .. name:gsub("^%l", string.upper)
        if not CAMI.GetPrivilege(privilege) then
            local privilegeInfo = {
                Name = privilege,
                MinAccess = "admin",
                Description = "Allows access to Entity Property " .. name:gsub("^%l", string.upper)
            }

            CAMI.RegisterPrivilege(privilegeInfo)
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:TranslateActivity(client, act)
    local model = string.lower(client.GetModel(client))
    local class = lia.anim.getModelClass(model) or "player"
    local weapon = client.GetActiveWeapon(client)
    if class == "player" then
        if not lia.config.WepAlwaysRaised and IsValid(weapon) and (client.isWepRaised and not client.isWepRaised(client)) and client:OnGround() then
            if string.find(model, "zombie") then
                local tree = lia.anim.zombie
                if string.find(model, "fast") then tree = lia.anim.fastZombie end
                if tree[act] then return tree[act] end
            end

            local holdType = IsValid(weapon) and (weapon.HoldType or weapon.GetHoldType(weapon)) or "normal"
            holdType = lia.anim.PlayerHoldtypeTranslator[holdType] or "passive"
            local tree = lia.anim.player[holdType]
            if tree and tree[act] then
                if type(tree[act]) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(tree[act])
                    return
                else
                    return tree[act]
                end
            end
        end
        return self.BaseClass.TranslateActivity(self.BaseClass, client, act)
    end

    local tree = lia.anim[class]
    if tree then
        local subClass = "normal"
        if client.InVehicle(client) then
            local vehicle = client.GetVehicle(client)
            local class = vehicle:isChair() and "chair" or vehicle:GetClass()
            if tree.vehicle and tree.vehicle[class] then
                local act = tree.vehicle[class][1]
                local fixvec = tree.vehicle[class][2]
                if fixvec then client:SetLocalPos(Vector(16.5438, -0.1642, -20.5493)) end
                if type(act) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(client, act)
                    return
                else
                    return act
                end
            else
                act = tree.normal[ACT_MP_CROUCH_IDLE][1]
                if type(act) == "string" then client.CalcSeqOverride = client:LookupSequence(act) end
                return
            end
        elseif client.OnGround(client) then
            client.ManipulateBonePosition(client, 0, vector_origin)
            if IsValid(weapon) then
                subClass = weapon.HoldType or weapon.GetHoldType(weapon)
                subClass = lia.anim.HoldtypeTranslator[subClass] or subClass
            end

            if tree[subClass] and tree[subClass][act] then
                local index = (not client.isWepRaised or client:isWepRaised()) and 2 or 1
                local act2 = tree[subClass][act][index]
                if type(act2) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(client, act2)
                    return
                end
                return act2
            end
        elseif tree.glide then
            return tree.glide
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:DoAnimationEvent(client, event, data)
    local class = lia.anim.getModelClass(client:GetModel())
    if class == "player" then
        return self.BaseClass:DoAnimationEvent(client, event, data)
    else
        local weapon = client:GetActiveWeapon()
        if IsValid(weapon) then
            local holdType = weapon.HoldType or weapon:GetHoldType()
            holdType = lia.anim.HoldtypeTranslator[holdType] or holdType
            local animation = lia.anim[class][holdType]
            if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
                return ACT_VM_PRIMARYATTACK
            elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
                return ACT_VM_SECONDARYATTACK
            elseif event == PLAYERANIMEVENT_RELOAD then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.reload or ACT_GESTURE_RELOAD_SMG1, true)
                return ACT_INVALID
            elseif event == PLAYERANIMEVENT_JUMP then
                client.m_bJumping = true
                client.m_bFistJumpFrame = true
                client.m_flJumpStartTime = CurTime()
                client:AnimRestartMainSequence()
                return ACT_INVALID
            elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
                client:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
                return ACT_INVALID
            end
        end
    end
    return ACT_INVALID
end

--------------------------------------------------------------------------------------------------------
function GM:EntityEmitSound(data)
    if data.Entity.liaIsMuted then return false end
end

--------------------------------------------------------------------------------------------------------
function GM:HandlePlayerLanding(client, velocity, wasOnGround)
    if client:IsNoClipping() then return end
    if client:IsOnGround() and not wasOnGround then
        local length = (client.lastVelocity or velocity):LengthSqr()
        local animClass = lia.anim.getModelClass(client:GetModel())
        if animClass ~= "player" and length < 100000 then return end
        client:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
        return true
    end
end

--------------------------------------------------------------------------------------------------------
function GM:CalcMainActivity(client, velocity)
    if not IsValid(client) or client == NULL then return end
    local Length2D = velocity:Length2D()
    if client:GetActiveWeapon() and client:GetActiveWeapon():IsValid() and client:GetActiveWeapon():GetClass() == "lia_keys" then
        if Length2D > 100 or (Length2D > 0 and client:Crouching()) or not client:OnGround() then
            client:GetActiveWeapon():SetHoldType("normal")
        else
            client:GetActiveWeapon():SetHoldType("passive")
        end
    end

    if client:GetActiveWeapon() and client:GetActiveWeapon():IsValid() and client:GetActiveWeapon():GetClass() == "lia_hands" then
        if not client:isWepRaised() then
            if Length2D > 100 or (Length2D > 0 and client:Crouching()) or not client:OnGround() then client:GetActiveWeapon():SetHoldType("normal") end
        else
            client:GetActiveWeapon():SetHoldType("fist")
        end
    end

    client.CalcIdeal = ACT_MP_STAND_IDLE
    oldCalcSeqOverride = client.CalcSeqOverride
    client.CalcSeqOverride = -1
    local animClass = lia.anim.getModelClass(client:GetModel())
    if animClass ~= "player" then client:SetPoseParameter("move_yaw", math.NormalizeAngle(FindMetaTable("Vector").Angle(velocity)[2] - client:EyeAngles()[2])) end
    if not self:HandlePlayerLanding(client, velocity, client.m_bWasOnGround) and not self:HandlePlayerNoClipping(client, velocity) and not self:HandlePlayerDriving(client) and not self:HandlePlayerVaulting(client, velocity) and (usingPlayerAnims or not self:HandlePlayerJumping(client, velocity)) and not self:HandlePlayerSwimming(client, velocity) and not self:HandlePlayerDucking(client, velocity) then
        local len2D = velocity:Length2DSqr()
        if len2D > 22500 then
            client.CalcIdeal = ACT_MP_RUN
        elseif len2D > 0.25 then
            client.CalcIdeal = ACT_MP_WALK
        end
    end

    client.m_bWasOnGround = client:IsOnGround()
    client.m_bWasNoclipping = client:IsNoClipping() and not client:InVehicle()
    client.lastVelocity = velocity
    if CLIENT then client:SetIK(false) end
    return client.CalcIdeal, client.liaForceSeq or oldCalcSeqOverride
end

--------------------------------------------------------------------------------------------------------
function GM:OnCharVarChanged(char, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for k, v in pairs(lia.char.varHooks[varName]) do
            v(char, oldVar, newVar)
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:GetDefaultCharName(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.onGetDefaultName then return info:onGetDefaultName(client) end
end

--------------------------------------------------------------------------------------------------------
function GM:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.onGetDefaultDesc then return info:onGetDefaultDesc(client) end
end

--------------------------------------------------------------------------------------------------------
function GM:CheckFactionLimitReached(faction, character, client)
    if isfunction(faction.onCheckLimitReached) then return faction:onCheckLimitReached(character, client) end
    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit
    if faction.limit < 1 then maxPlayers = math.Round(#player.GetAll() * faction.limit) end
    return team.NumPlayers(faction.index) >= maxPlayers
end

--------------------------------------------------------------------------------------------------------
function GM:Move(client, moveData)
    local char = client:getChar()
    if char then
        if client:getNetVar("actAng") then
            moveData:SetForwardSpeed(0)
            moveData:SetSideSpeed(0)
        end

        if client:GetMoveType() == MOVETYPE_WALK and moveData:KeyDown(IN_WALK) then
            local mf, ms = 0, 0
            local speed = client:GetWalkSpeed()
            local ratio = lia.config.WalkRatio
            if moveData:KeyDown(IN_FORWARD) then
                mf = ratio
            elseif moveData:KeyDown(IN_BACK) then
                mf = -ratio
            end

            if moveData:KeyDown(IN_MOVELEFT) then
                ms = -ratio
            elseif moveData:KeyDown(IN_MOVERIGHT) then
                ms = ratio
            end

            moveData:SetForwardSpeed(mf * speed)
            moveData:SetSideSpeed(ms * speed)
        end
    end
end

--------------------------------------------------------------------------------------------------------
function GM:CanItemBeTransfered(itemObject, curInv, inventory)
    if itemObject.onCanBeTransfered then
        local itemHook = itemObject:onCanBeTransfered(curInv, inventory)
        return itemHook ~= false
    end
end

--------------------------------------------------------------------------------------------------------
function GM:OnPlayerJoinClass(client, class, oldClass)
    local char = client:getChar()
    if char and lia.config.PermaClass then char:setData("pclass", class) end
    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]
    if info.onSet then info:onSet(client) end
    if info2 and info2.onLeave then info2:onLeave(client) end
    netstream.Start(nil, "classUpdate", client)
end

--------------------------------------------------------------------------------------------------------
function GM:Think()
    if not self.nextThink then self.nextThink = 0 end
    if self.nextThink < CurTime() then
        local players = player.GetAll()
        for k, v in pairs(players) do
            local hp = v:Health()
            local maxhp = v:GetMaxHealth()
            if hp < maxhp and lia.config.AutoRegen then
                local newHP = hp + lia.config.HealingAmount
                v:SetHealth(math.Clamp(newHP, 0, maxhp))
            end
        end

        self.nextThink = CurTime() + lia.config.HealingTimer
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PropBreak(attacker, ent)
    if IsValid(ent) and ent:GetPhysicsObject():IsValid() then constraint.RemoveAll(ent) end
end

--------------------------------------------------------------------------------------------------------
function GM:OnPickupMoney(client, moneyEntity)
    if moneyEntity and moneyEntity:IsValid() then
        local amount = moneyEntity:getAmount()
        client:getChar():giveMoney(amount)
        client:notifyLocalized("moneyTaken", lia.currency.get(amount))
    end
end

--------------------------------------------------------------------------------------------------------
function GM:ModelFixer(model, animtype)
    if not animtype then
        lia.anim.setModelClass(model, "player")
    else
        lia.anim.setModelClass(model, animtype)
    end
end

--------------------------------------------------------------------------------------------------------
function GM:InitializedModules()
    if SERVER then
        if lia.config.MapCleanerEnabled then self:CallMapCleanerInit() end
        self:InitalizedWorkshopDownloader()
        self:InitializedExtrasServer()
    else
        self:InitializedExtrasClient()
    end

    self:RegisterCamiPermissions()
    self:InitializedExtrasShared()
end

--------------------------------------------------------------------------------------------------------
function GM:InitPostEntity()
    if CLIENT then
        self:ClientPostInit()
    else
        self:ServerPostInit()
    end
end

--------------------------------------------------------------------------------------------------------
function GM:InitializedExtrasShared()
    RunConsoleCommand("sv_simfphys_gib_lifetime", "0")
    RunConsoleCommand("sv_simfphys_fuel", "0")
    RunConsoleCommand("sv_simfphys_teampassenger", "0")
    RunConsoleCommand("sv_simfphys_traction_snow", "1")
    RunConsoleCommand("sv_simfphys_damagemultiplicator", "100")
end

--------------------------------------------------------------------------------------------------------
function GM:simfphysPhysicsCollide()
    return true
end

--------------------------------------------------------------------------------------------------------
function GM:DevelopmentServerLoader()
    --[[
    This allows you to make reduced cooldowns or certain scenarios only happen on the Dev server. Example:
    
    function GM:PlayerSpawn(ply)
        if not ply:getChar() then return end -- If the character isn't loaded, the function won't run
    
        -- will load after the default spawn
        timer.Simple(0.5, function()
            -- if it detects it is the Dev Server, the HP will be set to 69420, otherwise, it will be 100
            if DEV then
                ply:SetMaxHealth(69420)
                ply:SetHealth(69420)
            else
                ply:SetMaxHealth(100)
                ply:SetHealth(100)
            end
        end)
    end
--]]
    if lia.config.DevServer then
        print("This is a Development Server!")
    else
        print("This is a Main Server!")
    end
end

--------------------------------------------------------------------------------------------------------
function GM:PSALoader()
    local TalkModesPSAString = "Please Remove Talk Modes. Our framework has such built in by default."
    local NutscriptPSAString = "Please Port Any NutScript Plugins You May Be Using. Nutscript is Known for Being Exxploitable and Regardless Of The Compatibility, WE DO NOT Advice Nutscript Plugins. Our framework was built with Lilia Plugins in mind and most Performance will be adquired like that."
    local ULXPSAString = [[
            /*------------------------------------------------------------
            
            PUBLIC SERVICE ANNOUNCEMENT FOR LILIA SERVER OWNERS
            
            There is a ENOURMOUS performance issue with ULX Admin mod.
            Lilia Development Team found ULX is the main issue
            that make the server freeze when player count is higher
            than 20-30. The duration of freeze will be increased as you get
            more players on your server.
            
            If you're planning to open big server with ULX/ULib, Lilia
            Development Team does not recommend your plan. Server Performance
            Issues with ULX/Ulib on your server will be ignored and we're
            going to consider that you're taking the risk of ULX/Ulib's
            critical performance issue.
            
            Lilia 1.2 only displays this message when you have ULX or
            ULib on your server.
            
                                           -Lilia Development Team
            
            */------------------------------------------------------------]]
    if ulx or ULib then MsgC(Color(255, 0, 0), ULXPSAString .. "\n") end
    if TalkModes then timer.Simple(2, function() MsgC(Color(255, 0, 0), TalkModesPSAString) end) end
    if nut then
        if CLIENT then
            nut = lia or {
                util = {},
                gui = {},
                meta = {}
            }
        else
            nut = lia or {
                util = {},
                meta = {}
            }
        end

        timer.Simple(2, function() MsgC(Color(255, 0, 0), NutscriptPSAString) end)
    end
end

--------------------------------------------------------------------------------------------------------
function GM:IsValidTarget(target)
    return IsValid(target) and target:IsPlayer() and target:getChar()
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then
            return true
        elseif bind:find("use") and pressed then
            local entity = client:GetTracedEntity()
            if IsValid(entity) and (entity:GetClass() == "lia_item" or entity.hasMenu == true) then hook.Run("ItemShowEntityMenu", entity) end
        end
    elseif bind:find("jump") then
        if SERVER then lia.command.send("chargetup") end
    end
end
--------------------------------------------------------------------------------------------------------