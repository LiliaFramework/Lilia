-- Main Character Creation Panel
local PANEL = {}
local COLORS = {
  background = Color(0, 0, 0, 100),
  border = Color(255, 255, 255, 10),
  text = Color(255, 255, 255),
  errorBg = Color(180, 0, 0, 80),
}

PANEL.ANIM_SPEED = 0.3
PANEL.FADE_SPEED = 1.5
function PANEL:configureSteps()
  self:addStep(vgui.Create("liaCharacterFaction"))
  self:addStep(vgui.Create("liaCharacterModel"))
  self:addStep(vgui.Create("liaCharacterBiography"))
  hook.Run("ConfigureCharacterCreationSteps", self)
end

function PANEL:updateModel()
  local f = lia.faction.indices[self.context.faction]
  if not f then return end
  local m = f.models[self.context.model or 1]
  if not m then return end
  local mdl, sk, gr
  if istable(m) then
    mdl, sk, gr = unpack(m)
  else
    mdl, sk, gr = m, 0, {}
  end

  self.model:SetModel(mdl)
  local e = self.model:GetEntity()
  if not IsValid(e) then return end
  e:SetSkin(sk)
  if istable(gr) then
    for g, v in pairs(gr) do
      e:SetBodygroup(g, v)
    end
  elseif isstring(gr) then
    e:SetBodyGroups(gr)
  end

  if self.context.skin then e:SetSkin(self.context.skin) end
  if self.context.groups then
    for g, v in pairs(self.context.groups) do
      e:SetBodygroup(g, v)
    end
  end

  if f.material then e:SetMaterial(f.material) end
end

function PANEL:canCreateCharacter()
  local t = {}
  for _, v in pairs(lia.faction.teams) do
    if lia.faction.hasWhitelist(v.index) then t[#t + 1] = v.index end
  end

  if #t == 0 then return false, "You are unable to join any factions" end
  self.validFactions = t
  local mx = hook.Run("GetMaxPlayerChar", LocalPlayer()) or lia.config.MaxCharacters
  if lia.characters and #lia.characters >= mx then return false, "You have reached the maximum number of characters" end
  local c, r = hook.Run("ShouldMenuButtonShow", "create")
  if c == false then return false, r end
  return true
end

function PANEL:onFinish()
  if self.creating then return end
  self.content:SetVisible(false)
  self.buttons:SetVisible(false)
  self:showMessage("creating")
  self.creating = true
  local function onResponse()
    timer.Remove("liaFailedToCreate")
    if not IsValid(self) then return end
    self.creating = false
    self.content:SetVisible(true)
    self.buttons:SetVisible(true)
    self:showMessage()
  end

  local function onFail(err)
    onResponse()
    self:showError(err)
  end

  MainMenu:createCharacter(self.context):next(function()
    onResponse()
    if IsValid(lia.gui.character) then lia.gui.character:showContent() end
  end, onFail)

  timer.Create("liaFailedToCreate", 60, 1, function()
    if not IsValid(self) or not self.creating then return end
    onFail("unknownError")
  end)
end

function PANEL:showError(m, ...)
  if IsValid(self.error) then self.error:Remove() end
  if not m or m == "" then return end
  local s = L(m, ...)
  if not IsValid(self.content) then return end
  self.error = self.content:Add("DLabel")
  self.error:SetFont("liaMediumFont")
  self.error:SetText(s)
  self.error:SetTextColor(COLORS.text)
  self.error:Dock(TOP)
  self.error:SetTall(32)
  self.error:DockMargin(0, 0, 0, 8)
  self.error:SetContentAlignment(5)
  self.error.Paint = function(bx, w, h)
    lia.util.drawBlur(bx, 2, 2)
    draw.RoundedBox(4, 0, 0, w, h, COLORS.errorBg)
  end

  self.error:SetAlpha(0)
  self.error:AlphaTo(255, self.ANIM_SPEED)
  lia.gui.character:warningSound()
end

function PANEL:showMessage(m, ...)
  if not m or m == "" then
    if IsValid(self.message) then self.message:Remove() end
    return
  end

  local s = L(m, ...):upper()
  if IsValid(self.message) then
    self.message:SetText(s)
  else
    self.message = self:Add("DLabel")
    self.message:SetFont("liaMediumFont")
    self.message:SetTextColor(COLORS.text)
    self.message:Dock(TOP)
    self.message:SetContentAlignment(5)
    self.message:SetTall(32)
  end

  self.message:SetText(s)
end

function PANEL:addStep(st, pr)
  if not IsValid(st) then return end
  if not st.isCharCreateStep then return end
  if isnumber(pr) then
    table.insert(self.steps, math.min(pr, #self.steps + 1), st)
  else
    self.steps[#self.steps + 1] = st
  end

  st:SetParent(self.stepsContainer)
end

function PANEL:nextStep()
  local o = self.curStep
  local c = self.steps[o]
  if IsValid(c) then
    local r = {c:validate()}
    if r[1] == false then return self:showError(unpack(r, 2)) end
  end

  self:showError()
  self.curStep = self.curStep + 1
  local n = self.steps[self.curStep]
  while IsValid(n) and n:shouldSkip() do
    self.curStep = self.curStep + 1
    n:onSkip()
    n = self.steps[self.curStep]
  end

  if not IsValid(n) then
    self.curStep = o
    return self:onFinish()
  end

  self:onStepChanged(c, n)
end

function PANEL:previousStep()
  local c = self.steps[self.curStep]
  local i = self.curStep - 1
  local p = self.steps[i]
  while IsValid(p) and p:shouldSkip() do
    p:onSkip()
    i = i - 1
    p = self.steps[i]
  end

  if not IsValid(p) then return end
  self.curStep = i
  self:onStepChanged(c, p)
end

function PANEL:reset()
  self.context = {}
  local c = self.steps[self.curStep]
  if IsValid(c) then
    c:SetVisible(false)
    c:onHide()
  end

  self.curStep = 0
  if #self.steps == 0 then return self:showError("No character creation steps have been set up") end
  self:nextStep()
end

function PANEL:getPreviousStep()
  local s = self.curStep - 1
  while IsValid(self.steps[s]) do
    if not self.steps[s]:shouldSkip() then return self.steps[s] end
    s = s - 1
  end
end

function PANEL:onStepChanged(o, n)
  local x = self.ANIM_SPEED
  if self.curStep > 1 then
    self.prev:AlphaTo(255, x)
  else
    self.prev:AlphaTo(100, x)
  end

  self.next:SetText("")
  n:SetAlpha(0)
  n:SetVisible(true)
  n:onDisplay()
  n:InvalidateChildren(true)
  n:AlphaTo(255, x)
  if IsValid(o) then
    o:AlphaTo(0, x, 0, function()
      o:SetVisible(false)
      o:onHide()
    end)
  end
end

function PANEL:Paint(w, h)
  lia.util.drawBlur(self, 3, 6)
  surface.SetDrawColor(0, 0, 0, 160)
  surface.DrawRect(0, 0, w, h)
  surface.SetDrawColor(COLORS.border)
  surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:Init()
  self:Dock(FILL)
  self.rotationAngle = 45
  self.rotationSpeed = 0.5
  local canCreate, reason = self:canCreateCharacter()
  if not canCreate then return self:showMessage(reason) end
  lia.gui.charCreate = self
  self.steps = {}
  self.curStep = 0
  self.context = {}
  self.content = self:Add("DPanel")
  self.content:Dock(FILL)
  self.content:DockMargin(50, 50, 50, 100)
  self.content:SetPaintBackground(false)
  self.model = self.content:Add("liaModelPanel")
  self.model:Dock(RIGHT)
  self.model:SetWide(ScrW() * 0.25)
  self.model:SetModel("models/error.mdl")
  self.model.oldSetModel = self.model.SetModel
  self.model.SetModel = function(mdlpnl, ...)
    mdlpnl:oldSetModel(...)
    mdlpnl:fitFOV()
  end

  self.stepsContainer = self.content:Add("DPanel")
  self.stepsContainer:Dock(FILL)
  self.stepsContainer:SetPaintBackground(false)
  self.buttons = self:Add("DPanel")
  self.buttons:Dock(BOTTOM)
  self.buttons:SetTall(60)
  self.buttons:DockMargin(16, 0, 16, 16)
  self.buttons.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 80)) end
  self.prev = self.buttons:Add("DButton")
  self.prev:Dock(LEFT)
  self.prev:SetText("")
  self.prev:SetWide(math.max(100, ScrW() * 0.2))
  self.prev:DockMargin(4, 4, 4, 4)
  self.prev:SetAlpha(100)
  self.prev.Paint = function(btn, w, h)
    local hovered = btn:IsHovered()
    draw.SimpleText(L("back"):upper(), "liaMediumFont", w / 2, h / 2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if hovered then
      local uw = w * 0.4
      local ux = (w - uw) * 0.5
      local uy = h - 4
      surface.SetDrawColor(255, 255, 255, 80)
      surface.DrawRect(ux, uy, uw, 2)
    end
  end

  self.prev.DoClick = function() self:previousStep() end
  self.cancel = self.buttons:Add("DButton")
  self.cancel:Dock(LEFT)
  self.cancel:SetText("")
  self.cancel:SetWide(math.max(100, ScrW() * 0.2))
  self.cancel:DockMargin(4, 4, 4, 4)
  self.cancel.Paint = function(btn, w, h)
    local hovered = btn:IsHovered()
    draw.SimpleText(L("cancel"):upper(), "liaMediumFont", w / 2, h / 2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if hovered then
      local uw = w * 0.4
      local ux = (w - uw) * 0.5
      local uy = h - 4
      surface.SetDrawColor(255, 255, 255, 80)
      surface.DrawRect(ux, uy, uw, 2)
    end
  end

  self.cancel.DoClick = function() self:reset() end
  self.next = self.buttons:Add("DButton")
  self.next:Dock(FILL)
  self.next:SetText("")
  self.next:DockMargin(4, 4, 4, 4)
  self.next.Paint = function(btn, w, h)
    local hovered = btn:IsHovered()
    local isFinished = self.curStep >= #self.steps
    local text = L(isFinished and "finish" or "next"):upper()
    draw.SimpleText(text, "liaMediumFont", w / 2, h / 2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if hovered then
      local uw = w * 0.4
      local ux = (w - uw) * 0.5
      local uy = h - 4
      surface.SetDrawColor(255, 255, 255, 80)
      surface.DrawRect(ux, uy, uw, 2)
    end
  end

  self.next.DoClick = function() self:nextStep() end
  self:configureSteps()
  if #self.steps == 0 then return self:showError("No character creation steps have been set up") end
  self:nextStep()
end

vgui.Register("liaCharacterCreation", PANEL, "EditablePanel")