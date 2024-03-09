local MODULE = MODULE
local color = Color(52, 152, 219)
--  > Say
local log = MODULE:addCategory("Player Say", color)
hook.Add("PlayerSay", "Logger:log", function(client, txt, teamChat) log(("*%s* (%s) say &%s& %s"):format(client:GetName(), client:SteamID(), string.gsub(txt, "&", ""), teamChat and " in ?Team Chat?" or "")) end)
--  > Spawns/Deaths
local log = MODULE:addCategory("Player Spawns/Deaths", color)
hook.Add("PlayerInitialSpawn", "Logger:log", function(client) log(("*%s* (%s) first spawn"):format(client:GetName(), client:SteamID())) end)
hook.Add("PlayerSpawn", "Logger:log", function(client) log(("*%s* (%s) spawn"):format(client:GetName(), client:SteamID())) end)
hook.Add("PlayerDeath", "Logger:log", function(client, inf, atk)
    local _inf = IsValid(inf) and "using &" .. inf:GetClass() .. "&" or ""
    local _atk = not IsValid(atk) and "NULL" or atk:IsPlayer() and atk:GetName() or atk:GetClass()
    log(("*%s* (%s) die by ?%s? %s"):format(client:GetName(), client:SteamID(), _atk, _inf))
end)

--  > Hurt
local log = MODULE:addCategory("Player Hurt", color)
hook.Add("PlayerHurt", "Logger:log", function(client, atk, hp, dmg)
    local _atk = atk:IsPlayer() and atk:GetName() or atk:GetClass()
    log(("*%s* (%s) toke &%d& damage from ?%s? and left !%s! HP"):format(client:GetName(), client:SteamID(), dmg, _atk, hp))
end)

--  > Connect/Disconnect
local log = MODULE:addCategory("Player Connect/Disconnect", color)
gameevent.Listen("player_connect")
hook.Add("player_connect", "Logger:log", function(data) log(("*%s* (%s) is connecting with IP : &%s&"):format(data.name, data.networkid, data.address or "none")) end)
hook.Add("PlayerAuthed", "Logger:log", function(client, steamid) log(("*%s* is authed as &%s&"):format(client:GetName(), steamid)) end)
gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "Logger:log", function(data) log(("*%s* (%s) is disconnecting for &%s&"):format(data.name, data.networkid, data.reason)) end)
--  > Vehicle
local log = MODULE:addCategory("Player Vehicle", color)
hook.Add("PlayerEnteredVehicle", "Logger:log", function(client, veh)
    local class = veh.GetVehicleClass and veh:GetVehicleClass() or veh:GetClass()
    log(("*%s* (%s) has entered in ?%s?"):format(client:GetName(), client:SteamID(), class))
end)

hook.Add("PlayerLeaveVehicle", "Logger:log", function(client, veh)
    local class = veh.GetVehicleClass and veh:GetVehicleClass() or veh:GetClass()
    log(("*%s* (%s) has left of ?%s?"):format(client:GetName(), client:SteamID(), class))
end)

--  > Weapon
local log = MODULE:addCategory("Player Weapon", color)
hook.Add("PlayerSwitchWeapon", "Logger:log", function(client, old_weapon, new_weapon) log(("*%s* (%s) has switched weapon from ?%s? to ?%s?"):format(client:GetName(), client:SteamID(), IsValid(old_weapon) and old_weapon:GetClass() or "NULL", IsValid(new_weapon) and new_weapon:GetClass() or "NULL")) end)
hook.Add("WeaponEquip", "Logger:log", function(weapon, client) log(("*%s* (%s) has equiped a ?%s? weapon"):format(client:GetName(), client:SteamID(), weapon:GetClass())) end)
hook.Add("PlayerDroppedWeapon", "Logger:log", function(client, weapon)
    if not client:IsPlayer() then --  for some reasons this hook can be called for NPCs
        return
    end

    log(("*%s* (%s) has dropped a ?%s? weapon"):format(client:GetName(), client:SteamID(), weapon:GetClass()))
end)

--  > Sandbox Logs
local log = MODULE:addCategory("Player Spawned Entities", color)
hook.Add("PlayerSpawnedProp", "Logger:log", function(client, _, ent) log(("*%s* (%s) has spawned ?%s? : &%s&"):format(client:GetName(), client:SteamID(), ent:GetClass(), ent:GetModel())) end)
hook.Add("PlayerSpawnedRagdoll", "Logger:log", function(client, _, ent) log(("*%s* (%s) has spawned ?%s? : &%s&"):format(client:GetName(), client:SteamID(), ent:GetClass(), ent:GetModel())) end)
hook.Add("PlayerSpawnedVehicle", "Logger:log", function(client, ent)
    local class = ent.GetVehicleClass and ent:GetVehicleClass() or ent:GetClass() -- check if func exists cause of SCars
    log(("*%s* (%s) has spawned ?%s? : &%s&"):format(client:GetName(), client:SteamID(), class, ent:GetModel()))
end)

hook.Add("PlayerSpawnedNPC", "Logger:log", function(client, ent) log(("*%s* (%s) has spawned ?%s?"):format(client:GetName(), client:SteamID(), ent:GetClass())) end)
hook.Add("PlayerSpawnedSENT", "Logger:log", function(client, ent) log(("*%s* (%s) has spawned ?%s?"):format(client:GetName(), client:SteamID(), ent:GetClass())) end)
hook.Add("PlayerSpawnedSWEP", "Logger:log", function(client, ent) log(("*%s* (%s) has spawned ?%s?"):format(client:GetName(), client:SteamID(), ent:GetClass())) end)
hook.Add("PlayerGiveSWEP", "Logger:log", function(client, class) log(("*%s* (%s) has given ?%s?"):format(client:GetName(), client:SteamID(), class)) end)
MODULE:addCategory("Entity Created/Removed", Color(155, 89, 182))
MODULE:addCategory("Entity Sound", Color(155, 89, 182))
hook.Add("OnEntityCreated", "Logger:log", function(ent) log(("Entity %s has been created"):format(ent:GetClass())) end)
hook.Add("EntityRemoved", "Logger:log", function(ent) log(("Entity %s has been removed"):format(ent:GetClass())) end)
hook.Add("EntityEmitSound", "Logger:log", function(data)
    local ent = data.Entity
    local entityName = (IsValid(ent) and ent:IsPlayer()) and ent:GetName() or ent:GetClass()
    log(("Entity %s has played sound: %s"):format(entityName, data.SoundName))
end)

--  > Server Logs
local log = MODULE:addCategory("Server General", Color(230, 126, 34))
hook.Add("PostCleanupMap", "Logger:log", function() log("Map has been clean up") end)
hook.Add("ShutDown", "Logger:log", function() log("Server is shutting down") end)
hook.Add("InitPostEntity", "Logger:log", function() log("Server is up") end)
--  > DarkRP Logs
if DarkRP then
    local color = Color(231, 76, 60)
    --  > Name
    local log = MODULE:addCategory("DarkRP Name", color)
    hook.Add("onPlayerChangedName", "Logger:log", function(client, old, new) log(("*%s* (%s) has changed his name to ~%s~"):format(old, client:SteamID(), new)) end)
    --  > Laws
    local log = MODULE:addCategory("DarkRP Laws", color)
    hook.Add("addLaw", "Logger:log", function(n, law) log(("Law &%d& has been added : ~%s~"):format(n, law)) end)
    hook.Add("removeLaw", "Logger:log", function(n, law) log(("Law &%d& has been removed : ~%s~"):format(n, law)) end)
    hook.Add("resetLaws", "Logger:log", function(client) log(("Laws has been reseted by *%s*"):format(client:GetName())) end)
    --  > Lottery
    local log = MODULE:addCategory("DarkRP Lottery", color)
    hook.Add("lotteryStarted", "Logger:log", function(client, price) log(("Lottery with &%d&$ to pay has been started by *%s* (%s)"):format(price, client:GetName(), client:SteamID())) end)
    hook.Add("lotteryEnded", "Logger:log", function(ptp, client, money) log(("Lottery with &%d& participants has ended and *%s* (%s) won ~%d~$"):format(#ptp, client:GetName(), client:SteamID(), money)) end)
    hook.Add("playerEnteredLottery", "Logger:log", function(client) log(("*%s* (%s) entered in the current lottery"):format(client:GetName(), client:SteamID())) end)
    --  > Teams
    local log = MODULE:addCategory("DarkRP Teams", color)
    hook.Add("OnPlayerChangedTeam", "Logger:log", function(client, old, new) log(("*%s* (%s) get from &%s& to ~%s~"):format(client:GetName(), client:SteamID(), team.GetName(old), team.GetName(new))) end)
    hook.Add("demoteTeam", "Logger:log", function(client) log(("*%s* (%s) has been demoted"):format(client:GetName(), client:SteamID())) end)
    --  > Hitman
    local log = MODULE:addCategory("DarkRP Hitman", color)
    hook.Add("onHitAccepted", "Logger:log", function(hit, trg, buy) log(("*%s* has accepted to kill *%s*, ordered by *%s*"):format(hit:GetName(), trg:GetName(), buy:GetName())) end)
    hook.Add("onHitCompleted", "Logger:log", function(hit, trg, buy) log(("*%s* has killed *%s*, ordered by *%s*"):format(hit:GetName(), trg:GetName(), buy:GetName())) end)
    hook.Add("onHitCompleted", "Logger:log", function(hit, trg, reason) log(("*%s* has failed to kill *%s* : *%s*"):format(hit:GetName(), trg:GetName(), reason)) end)
    --  > Doors
    local log = MODULE:addCategory("DarkRP Doors", color)
    hook.Add("lockpickStarted", "Logger:log", function(client, ent)
        local _ent = ent.GetVehicleClass and ent:GetVehicleClass() or ent:GetClass()
        log(("*%s* has started to lockpick ?%s?"):format(client:GetName(), _ent))
    end)

    hook.Add("onLockpickCompleted", "Logger:log", function(client, bool, ent)
        local _ent = ent.GetVehicleClass and ent:GetVehicleClass() or ent:GetClass()
        local lockpick = bool and "lockpicked" or "failed to lockpick"
        log(("*%s* has %s ?%s?"):format(client:GetName(), lockpick, _ent))
    end)

    hook.Add("onHitCompleted", "Logger:log", function(hit, trg, reason) log(("*%s* has failed to kill *%s* : *%s*"):format(hit:GetName(), trg:GetName(), reason)) end)
    --  > Money
    local log = MODULE:addCategory("DarkRP Money", color)
    hook.Add("playerGaveMoney", "Logger:log", function(client, trg, amount) log(("*%s* (%s) has given &%d&$ to *%s*"):format(client:GetName(), client:SteamID(), amount, trg:GetName())) end)
    hook.Add("playerDroppedMoney", "Logger:log", function(client, amount) log(("*%s* (%s) has dropped &%d&$"):format(client:GetName(), client:SteamID(), amount)) end)
    hook.Add("playerDroppedCheque", "Logger:log", function(client, trg, amount) log(("*%s* (%s) has dropped a cheque to *%s* of &%d&$"):format(client:GetName(), client:SteamID(), trg:GetName(), amount)) end)
    hook.Add("playerPickedUpMoney", "Logger:log", function(client, amount) log(("*%s* (%s) has picked up &%d&$"):format(client:GetName(), client:SteamID(), amount)) end)
    hook.Add("playerPickedUpCheque", "Logger:log", function(client, trg, amount, bool)
        local pick = bool and "succesfully picked" or "failed to pick"
        log(("*%s* (%s) has %s up a cheque to *%s* of &%d&$"):format(client:GetName(), client:SteamID(), pick, trg:GetName(), amount))
    end)

    hook.Add("playerGetSalary", "Logger:log", function(client, amount) log(("*%s* (%s) has got his salary of &%d&$ as ~%s~"):format(client:GetName(), client:SteamID(), amount, team.GetName(client:Team()))) end)
    hook.Add("onPropertyTax", "Logger:log", function(client, tax) log(("*%s* (%s) has paid &%d&$ of tax"):format(client:GetName(), client:SteamID(), tax)) end)
    --  > Arrest
    local log = MODULE:addCategory("DarkRP Arrest", color)
    hook.Add("playerArrested", "Logger:log", function(client, time, actor) log(("*%s* (%s) has been arrested by *%s* (%s) for &%d&s"):format(client:GetName(), client:SteamID(), actor:GetName(), actor:SteamID(), time)) end)
    hook.Add("playerUnArrested", "Logger:log", function(client, actor)
        if IsValid(actor) then
            log(("*%s* (%s) has been unarrested by *%s* (%s)"):format(client:GetName(), client:SteamID(), actor:GetName(), actor:SteamID()))
        else
            log(("*%s* (%s) has been unarrested by time"):format(client:GetName(), client:SteamID()))
        end
    end)
end
