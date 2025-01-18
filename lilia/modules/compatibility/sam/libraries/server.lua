local playerMeta = FindMetaTable("Player")
function MODULE:PlayerSpawnProp(client)
  if not playerMeta.GetLimit then return end
  local limit = client:GetLimit("props")
  if limit < 0 then return end
  local props = client:GetCount("props") + 1
  if client:getLiliaData("extraProps") then
    if props > limit + 50 then
      client:LimitHit("props")
      return false
    end
  else
    if props > limit then
      client:LimitHit("props")
      return false
    end
  end
end

function MODULE:PlayerCheckLimit(client, name)
  if not playerMeta.GetLimit then return end
  if name == "props" then
    if client:isStaffOnDuty() then return true end
    if client:GetLimit("props") < 0 then return end
    if client:getLiliaData("extraProps") then
      local limit = client:GetLimit("props") + 50
      local props = client:GetCount("props")
      if props <= limit + 50 then return true end
    end
  end
end

function MODULE:PlayerSpawnRagdoll(client)
  if not playerMeta.GetLimit then return end
  local limit = client:GetLimit("ragdolls")
  if limit < 0 then return end
  local ragdolls = client:GetCount("ragdolls") + 1
  if ragdolls > limit then
    client:LimitHit("ragdolls")
    return false
  end
end

sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Blinds the Players"):OnExecute(function(client, targets)
  for i = 1, #targets do
    local target = targets[i]
    net.Start("sam_blind")
    net.WriteBool(true)
    net.Send(target)
  end

  if not sam.is_command_silent then
    client:sam_send_message("{A} Blinded {T}", {
      A = client,
      T = targets
    })
  end
end):End()

sam.command.new("unblind"):SetPermission("blind", "superadmin"):AddArg("player"):Help("Unblinds the Players"):OnExecute(function(client, targets)
  for i = 1, #targets do
    local target = targets[i]
    net.Start("sam_blind")
    net.WriteBool(false)
    net.Send(target)
  end

  if not sam.is_command_silent then
    client:sam_send_message("{A} Un-Blinded {T}", {
      A = client,
      T = targets
    })
  end
end):End()

util.AddNetworkString("sam_blind")
function MODULE:InitializedModules()
  hook.Remove("PlayerSay", "SAM.Chat.Asay")
end
