local PANEL = {}
function PANEL:configureSteps()
    self:addStep(vgui.Create("liaCharacterBiography"))
    self:addStep(vgui.Create("liaCharacterModel"))
    hook.Run("ConfigureCharacterCreationSteps", self)
    local keys = table.GetKeys(self.steps)
    table.sort(keys)
    local ordered = {}
    for i, k in ipairs(keys) do
        ordered[i] = self.steps[k]
    end

    self.steps = ordered
end

function PANEL:updateModel()
    if not IsValid(self.model) then return end
    local faction = lia.faction.indices[self.context.faction]
    if not faction then return end
    local info = faction.models[self.context.model or 1]
    local mdl, skin, groups = info, 0, {}
    if istable(info) then mdl, skin, groups = info[1], info[2], info[3] end
    self.model:SetModel(mdl)
    self.model:fitFOV()
    local entity = self.model:GetEntity()
    if not IsValid(entity) then return end
    entity:SetupBones()
    entity:SetSkin(self.context.skin or skin)
    local finalGroups = istable(self.context.groups) and self.context.groups or istable(groups) and groups
    if finalGroups then
        for id, val in pairs(finalGroups) do
            entity:SetBodygroup(id, val)
        end
    end

    hook.Run("ModifyCharacterModel", entity)
end

function PANEL:canCreateCharacter()
    local valid = {}
    for _, team in pairs(lia.faction.teams) do
        if lia.faction.hasWhitelist(team.index) then valid[#valid + 1] = team.index end
    end

    if #valid == 0 then return false, L("unableToJoinFactions") end
    self.validFactions = valid
    local maxChars = hook.Run("GetMaxPlayerChar", LocalPlayer()) or lia.config.get("MaxCharacters", 5)
    if lia.characters and #lia.characters >= maxChars then return false, L("maxCharactersReached") end
    local ok, reason = hook.Run("ShouldMenuButtonShow", "create")
    if ok == false then return false, reason end
    return true
end

function PANEL:onFinish()
    if self.creating then return end
    for _, step in ipairs(self.steps) do
        if IsValid(step) and step.updateContext then step:updateContext() end
    end

    self.content:SetVisible(false)
    self.buttons:SetVisible(false)
    self:showMessage("creating")
    self.creating = true
    local function finish()
        timer.Remove("liaFailedToCreate")
        if not IsValid(self) then return end
        self.creating = false
        self.content:SetVisible(true)
        self.buttons:SetVisible(true)
        self:showMessage()
    end

    local function fail(err)
        finish()
        self:showError(err)
    end

    lia.module.get("mainmenu"):CreateCharacter(self.context):next(function(charID)
        finish()
        hook.Run("ResetCharacterPanel")
        -- Auto-switch  tothe newly created character
        lia.module.get("mainmenu"):ChooseCharacter(charID):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyErrorLocalized(err) end end)
    end, fail)

    timer.Create("liaFailedToCreate", 60, 1, function()
        if not IsValid(self) or not self.creating then return end
        fail(L("unknownError"))
    end)
end

function PANEL:showError(msg, ...)
    if IsValid(self.error) then self.error:Remove() end
    if not msg or msg == "" then return end
    assert(IsValid(self.content), L("noStepAvailable"))
    local err = self.content:Add("DLabel")
    err:SetFont("LiliaFont.18")
    err:SetText(L(msg, ...))
    err:SetTextColor(color_white)
    err:Dock(TOP)
    err:SetTall(32)
    err:DockMargin(0, 0, 0, 8)
    err:SetContentAlignment(5)
    err.Paint = function(box, w, h)
        lia.util.drawBlur(box)
        surface.SetDrawColor(255, 0, 0, 50)
        surface.DrawRect(0, 0, w, h)
    end

    err:SetAlpha(0)
    err:AlphaTo(255, 0.5)
    lia.gui.character:warningSound()
    self.error = err
end

function PANEL:showMessage(msg, ...)
    if not msg or msg == "" then
        if IsValid(self.message) then self.message:Remove() end
        return
    end

    if IsValid(self.message) then self.message:SetText(L(msg, ...):upper()) end
    local lbl = self:Add("DLabel")
    lbl:SetFont("LiliaFont.16")
    lbl:SetTextColor(lia.gui.character.color)
    lbl:Dock(FILL)
    lbl:SetContentAlignment(5)
    lbl:SetText(L(msg, ...):upper())
    self.message = lbl
end

function PANEL:addStep(step, priority)
    assert(IsValid(step), L("invalidPanelForStep"))
    assert(step.isCharCreateStep, L("panelMustInherit"))
    if isnumber(priority) then
        table.insert(self.steps, priority, step)
    else
        self.steps[#self.steps + 1] = step
    end

    step:SetParent(self.content)
end

function PANEL:nextStep()
    local prevIdx = self.curStep
    local cur = self.steps[prevIdx]
    if IsValid(cur) then
        local ok, err = cur:validate()
        if ok == false then return self:showError(err) end
    end

    self:showError()
    self.curStep = prevIdx + 1
    local nxt = self.steps[self.curStep]
    while IsValid(nxt) and nxt:shouldSkip() do
        self.curStep = self.curStep + 1
        nxt:onSkip()
        nxt = self.steps[self.curStep]
    end

    if not IsValid(nxt) then
        self.curStep = prevIdx
        return self:onFinish()
    end

    self:onStepChanged(cur, nxt)
end

function PANEL:previousStep()
    local idx = self.curStep - 1
    local prev = self.steps[idx]
    while IsValid(prev) and prev:shouldSkip() do
        prev:onSkip()
        idx = idx - 1
        prev = self.steps[idx]
    end

    if not IsValid(prev) then return end
    self.curStep = idx
    self:onStepChanged(self.steps[idx + 1], prev)
end

function PANEL:getPreviousStep()
    local idx = self.curStep - 1
    while IsValid(self.steps[idx]) do
        if not self.steps[idx]:shouldSkip() then return self.steps[idx] end
        idx = idx - 1
    end
end

function PANEL:onStepChanged(oldStep, newStep)
    local finish = self.curStep == #self.steps
    local key = finish and "finish" or "next"
    if IsValid(newStep) then
        local panelName = newStep:GetName()
        local shouldShowModel = panelName == "liaCharacterModel"
        if IsValid(self.model) then self.model:SetVisible(shouldShowModel) end
    end

    if IsValid(self:getPreviousStep()) then
        self.prev:AlphaTo(255, 0.5)
    else
        self.prev:AlphaTo(0, 0.5)
    end

    local function sizeButton(btn, txt)
        btn:SetText(txt)
        surface.SetFont(btn:GetFont())
        local w = select(1, surface.GetTextSize(txt))
        btn:SetWide(w + 40)
    end

    if L(key):upper() ~= self.next:GetText() then self.next:AlphaTo(0, 0.5) end
    local function show()
        newStep:SetVisible(true)
        newStep:SetAlpha(0)
        newStep:onDisplay()
        newStep:InvalidateChildren(true)
        newStep:AlphaTo(255, 0.5)
        if L(key):upper() ~= self.next:GetText() then
            self.next:SetAlpha(0)
            sizeButton(self.next, L(key):upper())
        end

        self.next:AlphaTo(255, 0.5)
    end

    if IsValid(oldStep) then
        oldStep:AlphaTo(0, 0.5, 0, function()
            self:showError()
            oldStep:SetVisible(false)
            oldStep:onHide()
            show()
        end)
    else
        show()
    end
end

function PANEL:Init()
    self:Dock(FILL)
    local ok, reason = self:canCreateCharacter()
    if not ok then return self:showMessage(reason) end
    lia.gui.charCreate = self
    local margin = ScrW() > 1280 and ScrW() * 0.15 or ScrW() > 720 and ScrW() * 0.075 or 0
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(margin, 64, margin, 0)
    self.content:SetPaintBackground(false)
    self.model = self.content:Add("liaModelPanel")
    if not IsValid(self.model) then return self:showError("Failed to create model panel") end
    self.model:SetWide(ScrW() * 0.25)
    self.model:Dock(LEFT)
    self.model:SetModel("models/error.mdl")
    self.model:fitFOV()
    self.model:SetVisible(false)
    self.buttons = self:Add("DPanel")
    self.buttons:Dock(BOTTOM)
    self.buttons:SetTall(48)
    self.buttons:SetPaintBackground(false)
    local function sizeButton(btn, text)
        btn:SetText(text)
        local font = btn:GetFont()
        surface.SetFont(font)
        local textW, _ = surface.GetTextSize(text)
        local padding = 20
        btn:SetWide(textW + padding * 2)
    end

    self.prev = self.buttons:Add("liaMediumButton")
    sizeButton(self.prev, L("back"):upper())
    self.prev:Dock(LEFT)
    self.prev.DoClick = function() self:previousStep() end
    self.prev:SetAlpha(0)
    self.next = self.buttons:Add("liaMediumButton")
    sizeButton(self.next, L("next"):upper())
    self.next:Dock(RIGHT)
    self.next.DoClick = function() self:nextStep() end
    self.steps = {}
    self.curStep = 0
    self.context = {}
    self:configureSteps()
    if #self.steps == 0 then return self:showError("noCharacterSteps") end
    self:nextStep()
    timer.Simple(0.5, function() if IsValid(self) and IsValid(self.model) then hook.Run("ModifyCharacterModel", self.model:GetEntity()) end end)
end

vgui.Register("liaCharacterCreation", PANEL, "EditablePanel")