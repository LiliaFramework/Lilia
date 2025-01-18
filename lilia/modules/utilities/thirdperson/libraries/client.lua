local MODULE = MODULE
local MAT_GLASS2 = 45
local MaxValues = {
  height = 30,
  horizontal = 30,
  distance = 100
}

local NotSolidTextures = {
  ["TOOLS/TOOLSNODRAW"] = true,
  ["METAL/METALBAR001C"] = true,
  ["METAL/METALGATE001A"] = true,
  ["METAL/METALGATE004A"] = true,
  ["METAL/METALGRATE011A"] = true,
  ["METAL/METALGRATE016A"] = true,
  ["METAL/METALCOMBINEGRATE001A"] = true,
  ["maps/rp_city3/glass/combinepodglass001a_12539_462_-284"] = true
}

local NotSolidModels = {
  ["models/props_wasteland/exterior_fence002c.mdl"] = true,
  ["models/props_wasteland/exterior_fence002b.mdl"] = true,
  ["models/props_wasteland/exterior_fence003a.mdl"] = true,
  ["models/props_wasteland/exterior_fence001b.mdl"] = true
}

local NotSolidMatTypes = {
  [MAT_GLASS] = true,
  [MAT_GLASS2] = true
}

local playerMeta = FindMetaTable("Player")
local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng, diff, fm, sm
local ThirdPerson = CreateClientConVar("tp_enabled", 0, true)
local ClassicThirdPerson = CreateClientConVar("tp_classic", "0", true)
local ThirdPersonVerticalView = CreateClientConVar("tp_vertical", 10, true)
local ThirdPersonViewDistance = CreateClientConVar("tp_distance", 50, true)
local ThirdPersonHorizontalView = CreateClientConVar("tp_horizontal", 0, true)
crouchFactor = 0
function MODULE:SetupQuickMenuCategories(panel)
  panel:addCategory("Third Person")
end

function MODULE:SetupQuickMenu(menu)
  if self.ThirdPersonEnabled then
    menu:addCheck(L("thirdpersonToggle"), function(_, state)
      if state then
        RunConsoleCommand("tp_enabled", "1")
      else
        RunConsoleCommand("tp_enabled", "0")
      end

      hook.Run("thirdPersonToggled", ThirdPerson:GetBool())
    end, ThirdPerson:GetBool(), "Third Person")

    menu:addCheck(L("thirdpersonClassic"), function(_, state)
      if state then
        RunConsoleCommand("tp_classic", "1")
      else
        RunConsoleCommand("tp_classic", "0")
      end
    end, ClassicThirdPerson:GetBool(), "Third Person")

    menu:addSlider("Height", function(_, value) RunConsoleCommand("tp_vertical", tostring(value)) end, GetConVar("tp_vertical"):GetFloat(), 0, MaxValues.height, 0, "Third Person")
    menu:addSlider("Horizontal", function(_, value) RunConsoleCommand("tp_horizontal", tostring(value)) end, GetConVar("tp_horizontal"):GetFloat(), -MaxValues.horizontal, MaxValues.horizontal, 0, "Third Person")
    menu:addSlider("Distance", function(_, value) RunConsoleCommand("tp_distance", tostring(value)) end, GetConVar("tp_distance"):GetFloat(), 0, MaxValues.distance, 0, "Third Person")
  end
end

function MODULE:CalcView(client)
  ft = FrameTime()
  if client:CanOverrideView() and client:GetViewEntity() == client then
    if client:OnGround() and client:KeyDown(IN_DUCK) or client:Crouching() then
      crouchFactor = Lerp(ft * 5, crouchFactor, 1)
    else
      crouchFactor = Lerp(ft * 5, crouchFactor, 0)
    end

    curAng = client.camAng or Angle(0, 0, 0)
    view = {}
    traceData = {}
    traceData.start = client:GetPos() + client:GetViewOffset() + curAng:Up() * math.Clamp(ThirdPersonVerticalView:GetInt(), 0, MaxValues.height) + curAng:Right() * math.Clamp(ThirdPersonHorizontalView:GetInt(), -MaxValues.horizontal, MaxValues.horizontal) - client:GetViewOffsetDucked() * .5 * crouchFactor
    traceData.endpos = traceData.start - curAng:Forward() * math.Clamp(ThirdPersonViewDistance:GetInt(), 0, MaxValues.distance)
    traceData.filter = client
    view.origin = util.TraceLine(traceData).HitPos
    aimOrigin = view.origin
    view.angles = curAng + client:GetViewPunchAngles()
    traceData2 = {}
    traceData2.start = aimOrigin
    traceData2.endpos = aimOrigin + curAng:Forward() * 65535
    traceData2.filter = client
    if ClassicThirdPerson:GetBool() or client.isWepRaised and client:isWepRaised() or client:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and client:GetVelocity():Length() >= 10 then client:SetEyeAngles((util.TraceLine(traceData2).HitPos - client:GetShootPos()):Angle()) end
    return view
  end
end

function MODULE:CreateMove(cmd)
  local client = LocalPlayer()
  if client:CanOverrideView() and client:GetMoveType() ~= MOVETYPE_NOCLIP and client:GetViewEntity() == client then
    fm = cmd:GetForwardMove()
    sm = cmd:GetSideMove()
    diff = (client:EyeAngles() - (client.camAng or Angle(0, 0, 0)))[2] or 0
    diff = diff / 90
    cmd:SetForwardMove(fm + sm * diff)
    cmd:SetSideMove(sm + fm * diff)
    return false
  end
end

function MODULE:InputMouseApply(_, x, y)
  local client = LocalPlayer()
  if not client.camAng then client.camAng = Angle(0, 0, 0) end
  if client:CanOverrideView() and client:GetViewEntity() == client then
    client.camAng.p = math.Clamp(math.NormalizeAngle(client.camAng.p + y / 50), -85, 85)
    client.camAng.y = math.NormalizeAngle(client.camAng.y - x / 50)
    return true
  end
end

function MODULE:PlayerButtonDown(_, button)
  if button == KEY_F4 and IsFirstTimePredicted() then
    local ThirdPersonIsEnabled = ThirdPerson:GetInt() == 1
    ThirdPerson:SetInt(ThirdPersonIsEnabled and 0 or 1)
    hook.Run("thirdPersonToggled", ThirdPerson:GetBool())
  end
end

function MODULE:ShouldDrawLocalPlayer()
  local client = LocalPlayer()
  if client:GetViewEntity() == client and client:CanOverrideView() then return true end
end

function MODULE:EntityEmitSound(data)
  local steps = {".stepleft", ".stepright"}
  local ThirdPersonIsEnabled = ThirdPerson:GetInt() == 1
  if ThirdPersonIsEnabled then
    if not IsValid(data.Entity) and not data.Entity:IsPlayer() then return end
    local sName = data.OriginalSoundName
    if sName:find(steps[1]) or sName:find(steps[2]) then return false end
  end
end

function MODULE:PrePlayerDraw(drawnClient)
  local client = LocalPlayer()
  local clientPos = client:GetShootPos()
  local onlinePlayers = player.GetAll()
  local isInVehicle = client:hasValidVehicle()
  if not drawnClient:IsDormant() and client:GetMoveType() ~= MOVETYPE_NOCLIP and client:CanOverrideView() and not isInVehicle then
    local bBoneHit = false
    for i = 0, drawnClient:GetBoneCount() - 1 do
      local bonePos = drawnClient:GetBonePosition(i)
      local traceLine = util.TraceLine({
        start = clientPos,
        endpos = bonePos,
        filter = onlinePlayers,
        mask = MASK_SHOT_HULL
      })

      local entity = traceLine.Entity
      if traceLine.HitPos == bonePos then
        bBoneHit = true
        break
      elseif NotSolidMatTypes[traceLine.MatType] or NotSolidTextures[traceLine.HitTexture] or IsValid(entity) and (entity:GetClass() == "prop_dynamic" or entity:GetClass() == "prop_physics") and NotSolidModels[entity:GetModel()] then
        local traceLine2 = util.TraceLine({
          start = bonePos,
          endpos = clientPos,
          filter = onlinePlayers,
          mask = MASK_SHOT_HULL
        })

        if traceLine.Entity == traceLine2.Entity then
          bBoneHit = true
          break
        end
      end
    end

    if not bBoneHit then
      if not drawnClient.IsHidden then
        drawnClient:DrawShadow(false)
        drawnClient.IsHidden = true
      end
      return true
    elseif drawnClient.IsHidden then
      drawnClient:DrawShadow(true)
      drawnClient.IsHidden = false
    end
  elseif drawnClient.IsHidden then
    drawnClient:DrawShadow(true)
    drawnClient.IsHidden = false
  end
end

function playerMeta:CanOverrideView()
  local ragdoll = Entity(self:getLocalVar("ragdoll", 0))
  local isInVehicle = self:hasValidVehicle()
  if IsValid(lia.gui.char) then return false end
  if isInVehicle then return false end
  if hook.Run("ShouldDisableThirdperson", self) == true then return false end
  return ThirdPerson:GetBool() and MODULE.ThirdPersonEnabled and IsValid(self) and self:getChar() and not IsValid(ragdoll)
end

function playerMeta:IsInThirdPerson()
  local thirdPersonEnabled = MODULE.ThirdPersonEnabled
  local tpEnabledConVar = GetConVar("tp_enabled")
  local tpEnabled = tpEnabledConVar:GetBool()
  return tpEnabled and thirdPersonEnabled
end

concommand.Add("tp_toggle", function()
  ThirdPerson:SetInt(ThirdPerson:GetInt() == 0 and 1 or 0)
  hook.Run("thirdPersonToggled", ThirdPerson:GetBool())
end)
