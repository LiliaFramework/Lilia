local MODULE = MODULE
MODULE.crun = MODULE.crun or concommand.Run
function MODULE:ApplyPunishment(client, infraction, kick, ban, time)
    local bantime = time or 0
    if kick then client:Kick("Kicked for " .. infraction .. ".") end
    if ban then client:Ban(bantime, "Banned for " .. infraction .. ".") end
end

function MODULE:PlayerAuthed(client, steamid)
    local steamID64 = util.SteamIDTo64(steamid)
    local OwnerSteamID64 = client:OwnerSteamID64()
    local SteamName = client:steamName()
    local SteamID = client:SteamID()
    if self.FamilySharingEnabled and OwnerSteamID64 ~= steamID64 then
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
    if class == "lua_run" then
        function entity:AcceptInput()
            return true
        end

        function entity:RunCode()
            return true
        end

        timer.Simple(0, function() entity:Remove() end)
    elseif class == "point_servercommand" then
        timer.Simple(0, function() entity:Remove() end)
    elseif class == "prop_vehicle_prisoner_pod" then
        entity:AddEFlags(EFL_NO_THINK_FUNCTION)
    end
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
    for _, admin in ipairs(player.GetAll()) do
        if IsValid(admin) and CAMI.PlayerHasAccess(admin, "Staff Permissions - Can See Family Sharing Notifications", nil) then admin:chatNotify(notification) end
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

    if not MODULE.DefaultNets[strName] then
        lia.log.add(client, "net", strName)
        return
    end

    length = length - 16
    func(length, client)
end

function concommand.Run(client, cmd, args, argStr)
    if not IsValid(client) then return MODULE.crun(client, cmd, args, argStr) end
    if not cmd then return MODULE.crun(client, cmd, args, argStr) end
    if cmd == "act" then
        client:SetNW2Bool("IsActing", true)
        timer.Create("ActingExploit_" .. client:SteamID(), MODULE.ActExploitTimer, 1, function() client:SetNW2Bool("IsActing", false) end)
    end
    return MODULE.crun(client, cmd, args, argStr)
end
