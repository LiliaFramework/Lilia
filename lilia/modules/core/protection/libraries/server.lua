local MODULE = MODULE
function MODULE:PlayerAuthed(client, steamid)
    local steamID64 = util.SteamIDTo64(steamid)
    local OwnerSteamID64 = client:OwnerSteamID64()
    local SteamName = client:steamName()
    local SteamID = client:SteamID()
    if self.AltsDisabled and OwnerSteamID64 ~= steamID64 then
        client:Kick("Sorry! We do not allow family-shared accounts in this server!")
        self:NotifyAdmin(SteamName .. " (" .. SteamID .. ") kicked for family sharing.")
    elseif WhitelistCore and table.HasValue(WhitelistCore.BlacklistedSteamID64, OwnerSteamID64) then
        client:Ban("You are using an account whose family share is blacklisted from this server!")
        self:NotifyAdmin(SteamName .. " (" .. SteamID .. ") was banned for family sharing ALTing when blacklisting.")
    end
end

function MODULE:PlayerSay(client, message)
    local hasIPAddress = string.match(message, "%d+%.%d+%.%d+%.%d+(:%d*)?")
    local hasBadWords = string.find(string.upper(message), string.upper("clone")) and string.find(string.upper(message), string.upper("nutscript"))
    if hasIPAddress then
        self:ApplyPunishment(client, "Typing IP addresses in chat", true, false)
        return ""
    elseif hasBadWords then
        return ""
    end
end

function MODULE:PlayerLeaveVehicle(_, entity)
    if entity:GetClass() == "prop_vehicle_prisoner_pod" then
        local sName = "PodFix_" .. entity:EntIndex()
        hook.Add("Think", sName, function()
            if entity:IsValid() then
                if entity:GetInternalVariable("m_bEnterAnimOn") then
                    hook.Remove("Think", sName)
                elseif not entity:GetInternalVariable("m_bExitAnimOn") then
                    entity:AddEFlags(EFL_NO_THINK_FUNCTION)
                    hook.Remove("Think", sName)
                end
            else
                hook.Remove("Think", sName)
            end
        end)
    end
end

function MODULE:OnEntityCreated(entity)
    local class = entity:GetClass():lower():Trim()
    if self.AntiMapBackdoor then
        if class == "lua_run" then
            function entity:AcceptInput()
                return true
            end

            function entity:RunCode()
                return true
            end

            timer.Simple(0, function() entity:Remove() end)
        end

        if class == "point_servercommand" then timer.Simple(0, function() entity:Remove() end) end
    end

    if class == "prop_vehicle_prisoner_pod" then entity:AddEFlags(EFL_NO_THINK_FUNCTION) end
end

function MODULE:EntityTakeDamage(entity, dmgInfo)
    local inflictor = dmgInfo:GetInflictor()
    local attacker = dmgInfo:GetAttacker()
    local validClient = IsValid(entity) and entity:IsPlayer()
    local attackerIsHuman = attacker:IsPlayer()
    local notSameAttackerAsEnt = attacker ~= entity
    local isFallDamage = dmgInfo:IsFallDamage()
    local infIsProp = inflictor and IsValid(inflictor) and inflictor:isProp()
    if not (IsValid(attacker) and validClient) or isFallDamage then return end
    if infIsProp then dmgInfo:SetDamage(0) end
    if notSameAttackerAsEnt then
        if attackerIsHuman and attacker:GetNW2Bool("IsActing", false) then return true end
        if self.CharacterSwitchCooldown and (not self.SwitchCooldownOnAllEntities and attackerIsHuman) or self.SwitchCooldownOnAllEntities then entity.LastDamaged = CurTime() end
        if self.CarRagdoll and (IsValid(inflictor) and inflictor:isSimfphysCar()) and not entity:InVehicle() then
            dmgInfo:ScaleDamage(0)
            if not entity:hasRagdoll() then entity:setRagdolled(true, 5) end
        end
    end
end

function MODULE:CanPlayerSwitchChar(client, character)
    if not client:isStaffOnDuty() then
        if self.OnDamageCharacterSwitchCooldown and client.LastDamaged and client.LastDamaged > CurTime() - self.OnDamageCharacterSwitchCooldownTimer then return false, "You took damage too recently to switch characters!" end
        if self.CharacterSwitchCooldown and (character:getData("loginTime", 0) + self.CharacterSwitchCooldownTimer) > os.time() then return false, "You are on cooldown!" end
    end
end

function MODULE:OnPlayerDropWeapon(_, _, entity)
    local physObject = entity:GetPhysicsObject()
    if physObject then physObject:EnableMotion() end
    timer.Simple(self.TimeUntilDroppedSWEPRemoved, function() if entity and entity:IsValid() then entity:Remove() end end)
end

function MODULE:OnPlayerHitGround(client)
    local vel = client:GetVelocity()
    client:SetVelocity(Vector(-(vel.x * 0.45), -(vel.y * 0.45), 0))
end

function MODULE:ShouldCollide(ent1, ent2)
    if table.HasValue(self.BlockedCollideEntities, ent1:GetClass()) and table.HasValue(self.BlockedCollideEntities, ent2:GetClass()) then return false end
end

function MODULE:PlayerEnteredVehicle(_, entity)
    if entity:GetClass() == "prop_vehicle_prisoner_pod" then entity:RemoveEFlags(EFL_NO_THINK_FUNCTION) end
end

function MODULE:NotifyAdmin(notification)
    for _, admin in player.Iterator() do
        if IsValid(admin) and CAMI.PlayerHasAccess(admin, "Staff Permissions - Can See Alting Notifications", nil) then admin:chatNotify(notification) end
    end
end

function MODULE:OnPhysgunPickup(_, entity)
    if (entity:isProp() or entity:isItem()) and entity:GetCollisionGroup() == COLLISION_GROUP_NONE then entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR) end
end

function MODULE:PhysgunDrop(_, entity)
    if entity:isProp() and entity:isItem() then timer.Simple(5, function() if IsValid(entity) and entity:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then entity:SetCollisionGroup(COLLISION_GROUP_NONE) end end) end
end

function MODULE:ApplyPunishment(client, infraction, kick, ban, time)
    local bantime = time or 0
    if kick then client:Kick("Kicked for " .. infraction .. ".") end
    if ban then client:Ban(bantime, "Banned for " .. infraction .. ".") end
end

function MODULE:PlayerSpawnProp(client, model)
    local isBlacklistedProp = table.HasValue(self.BlackListedProps, model)
    if isBlacklistedProp and not CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Blacklisted Props", nil) then return false end
    if IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_tool" then
        local toolobj = client:GetActiveWeapon():GetToolObject()
        if not isbool(toolobj) and (client.AdvDupe2 and client.AdvDupe2.Entities) or (client.CurrentDupe and client.CurrentDupe.Entities) or toolobj.Entities then return true end
    end
end

function MODULE:PlayerSpawnObject(client)
    if IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_tool" then
        local toolobj = client:GetActiveWeapon():GetToolObject()
        if not isbool(toolobj) and (client.AdvDupe2 and client.AdvDupe2.Entities) or (client.CurrentDupe and client.CurrentDupe.Entities) or toolobj.Entities then return true end
    end
end

function MODULE:PlayerSpawnedNPC(_, entity)
    if self.NPCsDropWeapons then entity:SetKeyValue("spawnflags", "8192") end
end

function MODULE:CanTool(client, _, tool)
    local toolobj = client:GetActiveWeapon():GetToolObject()
    local entity = client:GetTracedEntity()
    if IsValid(entity) then
        local entClass = entity:GetClass()
        if tool == "remover" then
            if table.HasValue(self.RemoverBlockedEntities, entClass) then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove Blocked Entities", nil)
            elseif entity:IsWorld() then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove World Entities", nil)
            end
        end

        if (tool == "permaall" or tool == "permaprops" or tool == "blacklistandremove") and (string.StartsWith(entClass, "lia_") or table.HasValue(self.CanNotPermaProp, entClass) or entity.IsLeonNPC) then return false end
        if (tool == "adv_duplicator" or tool == "advdupe2" or tool == "duplicator" or tool == "blacklistandremove") and (table.HasValue(self.DuplicatorBlackList, entClass) or entity.NoDuplicate) then return false end
        if tool == "weld" and entClass == "sent_ball" then return false end
    end

    if tool == "duplicator" and client.CurrentDupe and not self:CheckDuplicationScale(client, client.CurrentDupe.Entities) then return false end
    if tool == "advdupe2" and client.AdvDupe2 and not self:CheckDuplicationScale(client, client.AdvDupe2.Entities) then return false end
    if tool == "adv_duplicator" and not isbool(toolobj) and toolobj.Entities and not self:CheckDuplicationScale(client, toolobj.Entities) then return false end
    if tool == "button" and not table.HasValue(self.ButtonList, client:GetInfo("button_model")) then
        client:ConCommand("button_model models/maxofs2d/button_05.mdl")
        client:ConCommand("button_model")
        return false
    end
end

function MODULE:CanProperty(client, property, entity)
    if (property == "persist") or (property == "drive") or (property == "bonemanipulate") then
        client:notify("This is disabled to avoid issues with Lilia's Core Features")
        return false
    end

    if entity:IsWorld() and IsValid(entity) then return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Property World Entities", nil) end
    if table.HasValue(self.RemoverBlockedEntities, entity:GetClass()) or table.HasValue(self.RestrictedEnts, entity:GetClass()) then return CAMI.PlayerHasAccess(client, "Staff Permissions - Use Entity Properties on Blocked Entities", nil) end
end

function MODULE:PhysgunPickup(client, entity)
    if (CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup", nil) or client:isStaffOnDuty()) and table.HasValue(self.RestrictedEnts, entity:GetClass()) then return CAMI.PlayerHasAccess(client, "Staff Permissions - Physgun Pickup on Restricted Entities", nil) end
end

function MODULE:OnPhysgunFreeze(_, physObj, entity, client)
    if not IsValid(physObj) or not IsValid(entity) then return false end
    if not physObj:IsMoveable() or entity:GetUnFreezable() then return false end
    physObj:EnableMotion(false)
    if entity:GetClass() == "prop_vehicle_jeep" then
        local objects = entity:GetPhysicsObjectCount()
        for i = 0, objects - 1 do
            local physObjNum = entity:GetPhysicsObjectNum(i)
            if IsValid(physObjNum) then physObjNum:EnableMotion(false) end
        end
    end

    if IsValid(client) then
        client:AddFrozenPhysicsObject(entity, physObj)
        client:SendHint("PhysgunUnfreeze", 0.3)
        client:SuppressHint("PhysgunFreeze")
    end

    if self.PassableOnFreeze then
        entity:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    else
        entity:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
    return true
end

function MODULE:PlayerSpawnVehicle(client, _, name)
    local delay = self.PlayerSpawnVehicleDelay
    if table.HasValue(self.RestrictedVehicles, name) and not CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Restricted Cars", nil) then
        client:notify("You can't spawn this vehicle since it's restricted!")
        return false
    end

    if not CAMI.PlayerHasAccess(client, "Spawn Permissions - No Car Spawn Delay", nil) then client.NextVehicleSpawn = SysTime() + delay end
end

function MODULE:CheckDuplicationScale(client, entities)
    for _, v in pairs(entities) do
        if v.ModelScale and v.ModelScale > 10 then
            client:notify("A model within this duplication exceeds the size limit!")
            print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
            return false
        end

        v.ModelScale = 1
    end
    return true
end

function MODULE:PlayerNoClip(client, state)
    if (not client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Staff Permissions - No Clip Outside Staff Character", nil)) or client:isStaffOnDuty() then
        if state then
            client:SetNoDraw(true)
            client:SetNotSolid(true)
            client:DrawWorldModel(false)
            client:DrawShadow(false)
            client:SetNoTarget(true)
            client.liaObsData = {client:GetPos(), client:EyeAngles()}
            hook.Run("OnPlayerObserve", client, state)
        else
            if client.liaObsData then
                if client:GetInfoNum("lia_obstpback", 0) > 0 then
                    local position, angles = client.liaObsData[1], client.liaObsData[2]
                    timer.Simple(0, function()
                        client:SetPos(position)
                        client:SetEyeAngles(angles)
                        client:SetVelocity(Vector(0, 0, 0))
                    end)
                end

                client.liaObsData = nil
            end

            client:SetNoDraw(false)
            client:SetNotSolid(false)
            client:DrawWorldModel(true)
            client:DrawShadow(true)
            client:SetNoTarget(false)
            hook.Run("OnPlayerObserve", client, state)
        end
    end
end

function net.Incoming(length, client)
    local i = net.ReadHeader()
    local strName = util.NetworkIDToString(i)
    if not strName then
        lia.log.add(client, "invalidNet")
        return
    end

    local func = net.Receivers[strName:lower()]
    if not func then
        lia.log.add(client, "invalidNet")
        return
    end

    length = length - 16
    func(length, client)
end

MODULE.crun = MODULE.crun or concommand.Run
function concommand.Run(client, cmd, args, argStr)
    if not IsValid(client) then return MODULE.crun(client, cmd, args, argStr) end
    if not cmd then return MODULE.crun(client, cmd, args, argStr) end
    if cmd == "act" then
        client:SetNW2Bool("IsActing", true)
        timer.Create("ActingExploit_" .. client:SteamID(), MODULE.ActExploitTimer, 1, function() client:SetNW2Bool("IsActing", false) end)
    end
    return MODULE.crun(client, cmd, args, argStr)
end