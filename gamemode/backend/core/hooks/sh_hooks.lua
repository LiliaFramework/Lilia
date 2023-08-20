--------------------------------------------------------------------------------------------------------
local oldCalcSeqOverride
lia.config.CharacterSwitchCooldownTimer = 5
lia.config.CharacterSwitchCooldown = true
lia.config.AutoRegen = false
lia.config.HealingAmount = 10
lia.config.HealingTimer = 60
lia.config.PermaClass = true
lia.config.MapCleanerEnabled = true
lia.config.ItemCleanupTime = 7200
lia.config.MapCleanupTime = 21600
--------------------------------------------------------------------------------------------------------
function GM:TranslateActivity(client, act)
    local model = string.lower(client.GetModel(client))
    local class = lia.anim.getModelClass(model) or "player"
    local weapon = client.GetActiveWeapon(client)

    if class == "player" then
        if not lia.config.WepAlwaysRaised and IsValid(weapon) and (client.isWepRaised and not client.isWepRaised(client)) and client:OnGround() then
            if string.find(model, "zombie") then
                local tree = lia.anim.zombie

                if string.find(model, "fast") then
                    tree = lia.anim.fastZombie
                end

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

                if fixvec then
                    client:SetLocalPos(Vector(16.5438, -0.1642, -20.5493))
                end

                if type(act) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(client, act)

                    return
                else
                    return act
                end
            else
                act = tree.normal[ACT_MP_CROUCH_IDLE][1]

                if type(act) == "string" then
                    client.CalcSeqOverride = client:LookupSequence(act)
                end

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
    client.CalcIdeal = ACT_MP_STAND_IDLE
    oldCalcSeqOverride = client.CalcSeqOverride
    client.CalcSeqOverride = -1
    local animClass = lia.anim.getModelClass(client:GetModel())

    if animClass ~= "player" then
        client:SetPoseParameter("move_yaw", math.NormalizeAngle(FindMetaTable("Vector").Angle(velocity)[2] - client:EyeAngles()[2]))
    end

    if self:HandlePlayerLanding(client, velocity, client.m_bWasOnGround) or self:HandlePlayerNoClipping(client, velocity) or self:HandlePlayerDriving(client) or self:HandlePlayerVaulting(client, velocity) or (usingPlayerAnims and self:HandlePlayerJumping(client, velocity)) or self:HandlePlayerSwimming(client, velocity) or self:HandlePlayerDucking(client, velocity) then
    else
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

    if CLIENT then
        client:SetIK(false)
    end

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
function GM:CanPlayerUseChar(client, character)
    if client:getChar() and client:getChar():getID() == character:getID() then return false, "You are already using this character!" end
    if client.LastDamaged and client.LastDamaged > CurTime() - 120 and character:getFaction() ~= FACTION_STAFF and client:getChar() then return false, "You took damage too recently to switch characters!" end
    if client:getNetVar("restricted") then return false, "You can't change characters while tied!" end

    if lia.config.CharacterSwitchCooldown and client:getChar() then
        if (client:getChar():getData("loginTime", 0) + lia.config.CharacterSwitchCooldownTimer) > os.time() then return false, "You are on cooldown!" end
        if not client:Alive() then return false, "You are dead!" end
    end

    local faction = lia.faction.indices[character:getFaction()]
    if faction and hook.Run("CheckFactionLimitReached", faction, character, client) then return false, "@limitFaction" end

    if character and character:getData("banned", false) then
        if isnumber(banned) and banned < os.time() then return end

        return false, "@charBanned"
    end
end
--------------------------------------------------------------------------------------------------------
function GM:CheckFactionLimitReached(faction, character, client)
    if isfunction(faction.onCheckLimitReached) then return faction:onCheckLimitReached(character, client) end
    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit

    if faction.limit < 1 then
        maxPlayers = math.Round(#player.GetAll() * faction.limit)
    end

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

    if char and lia.config.PermaClass then
        char:setData("pclass", class)
    end

    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]

    if info.onSet then
        info:onSet(client)
    end

    if info2 and info2.onLeave then
        info2:onLeave(client)
    end

    netstream.Start(nil, "classUpdate", client)
end
--------------------------------------------------------------------------------------------------------
function GM:Think()
    if not self.nextThink then
        self.nextThink = 0
    end

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
    if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
        constraint.RemoveAll(ent)
    end
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
function GM:InitializedModules()
    if SERVER then
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

        if ulx or ULib then
            MsgC(Color(255, 0, 0), ULXPSAString .. "\n")
        end

        if TalkModes then
            timer.Simple(2, function()
                MsgC(Color(255, 0, 0), TalkModesPSAString)
            end)
        end

        if nut then
            timer.Simple(2, function()
                MsgC(Color(255, 0, 0), NutscriptPSAString)
            end)
        end

        if lia.config.MapCleanerEnabled then
            timer.Create("clearWorldItemsWarning", lia.config.ItemCleanupTime - (60 * 10), 0, function()
                net.Start("worlditem_cleanup_inbound")
                net.Broadcast()

                for i, v in pairs(player.GetAll()) do
                    v:notify("World items will be cleared in 10 Minutes!")
                end
            end)

            timer.Create("clearWorldItemsWarningFinal", lia.config.ItemCleanupTime - 60, 0, function()
                net.Start("worlditem_cleanup_inbound_final")
                net.Broadcast()

                for i, v in pairs(player.GetAll()) do
                    v:notify("World items will be cleared in 60 Seconds!")
                end
            end)

            timer.Create("clearWorldItems", lia.config.ItemCleanupTime, 0, function()
                for i, v in pairs(ents.FindByClass("lia_item")) do
                    v:Remove()
                end
            end)

            timer.Create("mapCleanupWarning", lia.config.MapCleanupTime - (60 * 10), 0, function()
                net.Start("map_cleanup_inbound")
                net.Broadcast()

                for i, v in pairs(player.GetAll()) do
                    v:notify("World items will be cleared in 10 Minutes!")
                end
            end)

            timer.Create("mapCleanupWarningFinal", lia.config.MapCleanupTime - 60, 0, function()
                net.Start("worlditem_cleanup_inbound_final")
                net.Broadcast()

                for i, v in pairs(player.GetAll()) do
                    v:notify("World items will be cleared in 60 Seconds!")
                end
            end)

            timer.Create("AutomaticMapCleanup", lia.config.MapCleanupTime, 0, function()
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
            end)
        end

        timer.Simple(3, function()
            RunConsoleCommand("ai_serverragdolls", "1")
        end)
    end

    self:InitializedExtras()
end
--------------------------------------------------------------------------------------------------------
function GM:InitPostEntity()
    local ip, port = game.GetIPAddress():match("([^:]+):(%d+)")

    if ip == lia.config.DevServerIP and port == lia.config.DevServerPort then
        DEV = true
    else
        DEV = false
    end

    if DEV then
        print("This is a Development Server!")
    else
        print("This is a Main Server!")
    end

    if CLIENT then
        lia.joinTime = RealTime() - 0.9716
        lia.faction.formatModelData()

        if system.IsWindows() and not system.HasFocus() then
            system.FlashWindow()
        end
    else
        if StormFox2 then
            RunConsoleCommand('sf_time_speed', 1)
            RunConsoleCommand('sf_addnight_temp', 4)
            RunConsoleCommand('sf_windmove_props', 0)
            RunConsoleCommand('sf_windmove_props_break', 0)
            RunConsoleCommand('sf_windmove_props_unfreeze', 0)
            RunConsoleCommand('sf_windmove_props_unweld', 0)
            RunConsoleCommand('sf_windmove_props_makedebris', 0)
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
        
        for _, v in ipairs( ents.FindByClass('prop_door_rotating') ) do
            if IsValid(v) and v:IsDoor() then
                v:DrawShadow(false) -- we need this?
            end
        end

        lia.faction.formatModelData()

        timer.Simple(2, function()
            lia.entityDataLoaded = true
        end)

        lia.db.waitForTablesToLoad():next(function()
            hook.Run("LoadData")
            hook.Run("PostLoadData")
        end)
    end
end
--------------------------------------------------------------------------------------------------------
function GM:InitializedExtras()
    if CLIENT then
        hook.Remove("StartChat", "StartChatIndicator")
        hook.Remove("FinishChat", "EndChatIndicator")
        hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
        hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
        hook.Remove("player_disconnect", "DarkRP_ChatIndicator")
        RunConsoleCommand("gmod_mcore_test", "1")
        RunConsoleCommand("r_shadows", "0")
        RunConsoleCommand("cl_detaildist", "0")
        RunConsoleCommand("cl_threaded_client_leaf_system", "1")
        RunConsoleCommand("cl_threaded_bone_setup", "2")
        RunConsoleCommand("r_threaded_renderables", "1")
        RunConsoleCommand("r_threaded_particles", "1")
        RunConsoleCommand("r_queued_ropes", "1")
        RunConsoleCommand("r_queued_decals", "1")
        RunConsoleCommand("r_queued_post_processing", "1")
        RunConsoleCommand("r_threaded_client_shadow_manager", "1")
        RunConsoleCommand("studio_queue_mode", "1")
        RunConsoleCommand("mat_queue_mode", "-2")
        RunConsoleCommand("fps_max", "0")
        RunConsoleCommand("fov_desired", "100")
        RunConsoleCommand("mat_specular", "0")
        RunConsoleCommand("r_drawmodeldecals", "0")
        RunConsoleCommand("r_lod", "-1")
        RunConsoleCommand("lia_cheapblur", "1")
        hook.Remove("RenderScene", "RenderSuperDoF")
        hook.Remove("RenderScene", "RenderStereoscopy")
        hook.Remove("Think", "DOFThink")
        hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
        hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
        hook.Remove("PreRender", "PreRenderFrameBlend")
        hook.Remove("PostRender", "RenderFrameBlend")
        hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
        hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
        hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
        hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
        hook.Remove("PostDrawEffects", "RenderWidgets")
        hook.Remove("PlayerTick", "TickWidgets")
        hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
        hook.Remove("RenderScene", "RenderStereoscopy")
        hook.Remove("LoadGModSave", "LoadGModSave")
        hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
        hook.Remove("RenderScreenspaceEffects", "RenderBloom")
        hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
        hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
        hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
        hook.Remove("RenderScreenspaceEffects", "RenderSobel")
        hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
        hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
        hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
        hook.Remove("RenderScene", "RenderSuperDoF")
        hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
        hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
        hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
        hook.Remove("PostRender", "RenderFrameBlend")
        hook.Remove("PreRender", "PreRenderFrameBlend")
        hook.Remove("Think", "DOFThink")
        hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
        hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
        hook.Remove("PostDrawEffects", "RenderWidgets")
        hook.Remove("PostDrawEffects", "RenderHalos")
        timer.Remove("HostnameThink")
        timer.Remove("CheckHookTimes")
    end

    if nut then
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
end
--------------------------------------------------------------------------------------------------------
function GM:simfphysPhysicsCollide()
    return true
end
--------------------------------------------------------------------------------------------------------