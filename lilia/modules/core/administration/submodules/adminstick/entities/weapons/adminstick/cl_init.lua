local MODULE = MODULE
function SWEP:PrimaryAttack()
  local target = self:GetTarget()
  if IsValid(target) then MODULE:OpenAdminStickUI(target) end
end

function SWEP:SecondaryAttack()
  if not IsFirstTimePredicted() then return end
  local target = self:GetTarget()
  if IsValid(target) and target:IsPlayer() and target ~= LocalPlayer() then
    local cmd = target:IsFrozen() and (sam and "sam unfreeze" or ulx and "ulx unfreeze") or sam and "sam freeze" or ulx and "ulx freeze"
    LocalPlayer():ConCommand(cmd .. " " .. target:SteamID())
  else
    lia.notices.notify("You cannot freeze this!")
  end
end

function SWEP:GetTarget()
  local localPlayer = LocalPlayer()
  local target = IsValid(localPlayer.AdminStickTarget) and localPlayer.AdminStickTarget or localPlayer:GetEyeTrace().Entity
  return target
end

function SWEP:DrawHUD()
  local x, y = ScrW() / 2, ScrH() / 2
  local target = IsValid(LocalPlayer().AdminStickTarget) and LocalPlayer().AdminStickTarget or LocalPlayer():GetEyeTrace().Entity
  local crossColor = Color(255, 0, 0)
  local information = {}
  if IsValid(target) then
    if not target:IsPlayer() and target:IsVehicle() and IsValid(target:GetDriver()) then target = target:GetDriver() end
    if target:IsPlayer() then
      crossColor = Color(0, 255, 0)
      information = {IsValid(LocalPlayer().AdminStickTarget) and "Player (Selected with Reload)" or "Player", "Nickname: " .. target:Nick(), "Steam Name: " .. (target.SteamName and target:SteamName() or target:Name()), "Steam ID: " .. target:SteamID(), "Health: " .. target:Health(), "Armor: " .. target:Armor(), "Usergroup: " .. target:GetUserGroup()}
      if target:getChar() then
        local char = target:getChar()
        local faction = lia.faction.indices[target:Team()]
        table.Add(information, {"Character Name: " .. char:getName(), "Character Faction: " .. faction.name})
      else
        table.insert(information, "No Loaded Character")
      end
    elseif target:IsWorld() then
      if not LocalPlayer().NextRequestInfo or SysTime() >= LocalPlayer().NextRequestInfo then LocalPlayer().NextRequestInfo = SysTime() + 1 end
      information = {"Entity", "Class: " .. target:GetClass(), "Model: " .. target:GetModel(), "Position: " .. tostring(target:GetPos()), "Angles: " .. tostring(target:GetAngles()), "Owner: " .. tostring(target:GetCreator():Nick() or "Unknown"), "EntityID: " .. target:EntIndex()}
      crossColor = Color(255, 255, 0)
    else
      if not LocalPlayer().NextRequestInfo or SysTime() >= LocalPlayer().NextRequestInfo then LocalPlayer().NextRequestInfo = SysTime() + 1 end
      information = {"Entity", "Class: " .. target:GetClass(), "Model: " .. target:GetModel(), "Position: " .. tostring(target:GetPos()), "Angles: " .. tostring(target:GetAngles()), "Owner: " .. tostring(IsValid(target:GetCreator()) and target:GetCreator():Nick() or "Unowned"), "EntityID: " .. target:EntIndex()}
      crossColor = Color(255, 255, 0)
    end
  end

  local length = 20
  local thickness = 1
  surface.SetDrawColor(crossColor)
  surface.DrawRect(x - length / 2, y - thickness / 2, length, thickness)
  surface.DrawRect(x - thickness / 2, y - length / 2, thickness, length)
  local startPosX, startPosY = ScrW() / 2 + 10, ScrH() / 2 + 10
  local buffer = 0
  for _, v in pairs(information) do
    surface.SetFont("DebugFixed")
    surface.SetTextColor(color_black)
    surface.SetTextPos(startPosX + 1, startPosY + buffer + 1)
    surface.DrawText(v)
    surface.SetTextColor(crossColor)
    surface.SetTextPos(startPosX, startPosY + buffer)
    surface.DrawText(v)
    local _, t_h = surface.GetTextSize(v)
    buffer = buffer + t_h
  end
end

function SWEP:Reload()
  if self.NextReload and self.NextReload > SysTime() then return end
  self.NextReload = SysTime() + 0.5
  local client = LocalPlayer()
  if client:KeyDown(IN_SPEED) then MODULE:OpenAdminStickUI(client) end
end
