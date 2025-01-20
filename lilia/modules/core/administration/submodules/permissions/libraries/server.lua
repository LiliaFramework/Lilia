local GM = GM or GAMEMODE
local resetCalled = 0
function GM:PlayerSpawnEffect(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Effects") or client:getChar():hasFlags("L")
end

function GM:PlayerSpawnNPC(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn NPCs") or client:getChar():hasFlags("n")
end

function GM:PlayerSpawnProp(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Props") or client:getChar():hasFlags("e")
end

function GM:PlayerSpawnRagdoll(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Ragdolls") or client:getChar():hasFlags("r")
end

function GM:PlayerSpawnSENT(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SENTs") or client:getChar():hasFlags("E")
end

function GM:PlayerSpawnSWEP(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("z")
end

function GM:PlayerSpawnVehicle(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn Cars") or client:getChar():hasFlags("C")
end

function GM:PlayerGiveSWEP(client)
  return client:IsSuperAdmin() or client:isStaffOnDuty() or client:hasPrivilege("Spawn Permissions - Can Spawn SWEPs") or client:getChar():hasFlags("W")
end

function GM:PlayerNoClip(client)
  return not client:isStaffOnDuty() and client:hasPrivilege("Staff Permissions - No Clip Outside Staff Character") or client:IsSuperAdmin() or client:isStaffOnDuty()
end

function GM:OnPhysgunReload(_, client)
  return client:IsSuperAdmin() or client:hasPrivilege("Staff Permissions - Can Physgun Reload")
end

function GM:CanTool(client, _, tool)
  local DisallowedTools = {
    rope = true,
    light = true,
    lamp = true,
    dynamite = true,
    physprop = true,
    faceposer = true,
    stacker = true,
  }

  local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
  if DisallowedTools[tool] and not client:IsSuperAdmin() then return false end
  if client:IsSuperAdmin() or (client:isStaffOnDuty() or client:getChar():hasFlags("t")) and client:hasPrivilege(privilege) then return true end
  return false
end

function GM:CanProperty(client, property, entity)
  if entity:GetCreator() == client and (property == "remover" or property == "collision") then return true end
  if client:IsSuperAdmin() or client:hasPrivilege("Staff Permissions - Access Property " .. property:gsub("^%l", string.upper)) and client:isStaffOnDuty() then return true end
  return false
end

function GM:PlayerSpawnObject(client)
  if client:IsSuperAdmin() then return true end
  if not client.NextSpawn then client.NextSpawn = CurTime() end
  if client:hasPrivilege("Spawn Permissions - No Spawn Delay") then return true end
  if client.NextSpawn >= CurTime() then
    client:notify("You can't spawn props that fast!")
    return false
  end

  client.NextSpawn = CurTime() + 0.75
  return true
end

function GM:PhysgunPickup(client, entity)
  if client:IsSuperAdmin() then return true end
  if entity:GetCreator() == client and (entity:isProp() or entity:isItem()) then return true end
  if client:hasPrivilege("Staff Permissions - Physgun Pickup") then
    if entity:IsVehicle() then
      return client:hasPrivilege("Staff Permissions - Physgun Pickup on Vehicles")
    elseif entity:IsPlayer() then
      return not entity:hasPrivilege("Staff Permissions - Can't be Grabbed with PhysGun") and client:hasPrivilege("Staff Permissions - Can Grab Players")
    elseif entity:IsWorld() or entity:CreatedByMap() then
      return client:hasPrivilege("Staff Permissions - Can Grab World Props")
    end
    return true
  end
  return false
end

function GM:PlayerSpawnedNPC(client, entity)
  entity:SetCreator(client)
end

function GM:PlayerSpawnedEffect(client, _, entity)
  entity:SetCreator(client)
end

function GM:PlayerSpawnedProp(client, _, entity)
  entity:SetCreator(client)
end

function GM:PlayerSpawnedRagdoll(client, _, entity)
  entity:SetCreator(client)
end

function GM:PlayerSpawnedSENT(client, entity)
  entity:SetCreator(client)
end

function GM:PlayerSpawnedSWEP(client, entity)
  entity:SetCreator(client)
end

function GM:PlayerSpawnedVehicle(client, entity)
  entity:SetCreator(client)
end

concommand.Add("kickbots", function()
  for _, bot in player.Iterator() do
    if bot:IsBot() then bot:Kick("All bots kicked") end
  end
end)

concommand.Add("stopsoundall", function(client)
  if client:IsSuperAdmin() then
    for _, v in player.Iterator() do
      v:ConCommand("stopsound")
    end
  else
    client:notify("You must be a Super Admin to forcefully stopsound everyone!")
  end
end)

concommand.Add("lia_recreatedb", function(client)
  if not IsValid(client) then
    if resetCalled < RealTime() then
      resetCalled = RealTime() + 3
      MsgC(Color(255, 0, 0), "[Lilia] TO CONFIRM DATABASE RESET, RUN 'lia_recreatedb' AGAIN in 3 SECONDS.\n")
    else
      resetCalled = 0
      MsgC(Color(255, 0, 0), "[Lilia] DATABASE WIPE IN PROGRESS.\n")
      hook.Run("OnWipeTables")
      lia.db.wipeTables(lia.db.loadTables)
    end
  end
end)