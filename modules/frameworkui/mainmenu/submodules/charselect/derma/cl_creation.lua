local PANEL = {}
function PANEL:configureSteps()
    self:addStep(vgui.Create("liaCharacterFaction"))
    self:addStep(vgui.Create("liaCharacterBiography"))
    hook.Run("ConfigureCharacterCreationSteps", self)
    local keys = table.GetKeys(self.steps)
    table.sort(keys, function(a, b) return a < b end)
    local copy = table.Copy(self.steps)
    self.steps = {}
    for newKey, oldKey in pairs(keys) do
        self.steps[newKey] = copy[oldKey]
    end
end

function PANEL:updateModel()
    local faction = lia.faction.indices[self.context.faction]
    if not faction then return end
    local info = faction.models[self.context.model or 1]
    local mdl, skin, groups
    if istable(info) then
        mdl, skin, groups = unpack(info)
    else
        mdl, skin, groups = info, 0, {}
    end

    self.model:SetModel(mdl)
    self.model:fitFOV()
    local entity = self.model:GetEntity()
    if not IsValid(entity) then return end
    entity:SetupBones()
    entity:SetSkin(skin)
    if istable(groups) then
        for id, val in pairs(groups) do
            entity:SetBodygroup(id, val)
        end
    else
        entity:SetBodyGroups(groups)
    end

    if self.context.skin then entity:SetSkin(self.context.skin) end
    if istable(self.context.groups) then
        for id, val in pairs(self.context.groups) do
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

    if #valid == 0 then return false, "You are unable to join any factions" end
    self.validFactions = valid
    local maxChars = hook.Run("GetMaxPlayerChar", LocalPlayer()) or lia.config.get("MaxCharacters", 5)
    if lia.characters and #lia.characters >= maxChars then return false, "You have reached the maximum number of characters" end
    local ok, reason = hook.Run("ShouldMenuButtonShow", "create")
    if ok == false then return false, reason end
    return true
end

function PANEL:onFinish()
    if self.creating then return end
    self.content:SetVisible(false)
    self.buttons:SetVisible(false)
    self:showMessage("creating")
    self.creating = true
    local function finishResponse()
        timer.Remove("liaFailedToCreate")
        if not IsValid(self) then return end
        self.creating = false
        self.content:SetVisible(true)
        self.buttons:SetVisible(true)
        self:showMessage()
    end

    local function failResponse(err)
        finishResponse()
        self:showError(err)
    end

    MainMenu:createCharacter(self.context):next(function()
        finishResponse()
        hook.Run("ResetCharacterPanel")
    end, failResponse)

    timer.Create("liaFailedToCreate", 60, 1, function()
        if not IsValid(self) or not self.creating then return end
        failResponse("unknownError")
    end)
end

function PANEL:showError(msg, ...)
    if IsValid(self.error) then self.error:Remove() end
    if not msg or msg == "" then return end
    msg = L(msg, ...)
    assert(IsValid(self.content), "no step is available")
    self.error = self.content:Add("DLabel")
    self.error:SetFont("liaCharSubTitleFont")
    self.error:SetText(msg)
    self.error:SetTextColor(color_white)
    self.error:Dock(TOP)
    self.error:SetTall(32)
    self.error:DockMargin(0, 0, 0, 8)
    self.error:SetContentAlignment(5)
    self.error.Paint = function(box, w, h)
        lia.util.drawBlur(box)
        surface.SetDrawColor(255, 0, 0, 50)
        surface.DrawRect(0, 0, w, h)
    end

    self.error:SetAlpha(0)
    self.error:AlphaTo(255, 0.5)
    lia.gui.character:warningSound()
end

function PANEL:showMessage(msg, ...)
    if not msg or msg == "" then
        if IsValid(self.message) then self.message:Remove() end
        return
    end

    msg = L(msg, ...):upper()
    if IsValid(self.message) then self.message:SetText(msg) end
    self.message = self:Add("DLabel")
    self.message:SetFont("liaCharButtonFont")
    self.message:SetTextColor(lia.gui.character.color)
    self.message:Dock(FILL)
    self.message:SetContentAlignment(5)
    self.message:SetText(msg)
end

function PANEL:addStep(step, priority)
    assert(IsValid(step), "Invalid panel for step")
    assert(step.isCharCreateStep, "Panel must inherit liaCharacterCreateStep")
    if isnumber(priority) then
        table.insert(self.steps, priority, step)
    else
        self.steps[#self.steps + 1] = step
    end

    step:SetParent(self.content)
end

function PANEL:nextStep()
    local last = self.curStep
    local cur = self.steps[last]
    if IsValid(cur) then
        local ok, err = cur:validate()
        if ok == false then return self:showError(err) end
    end

    self:showError()
    self.curStep = self.curStep + 1
    local next = self.steps[self.curStep]
    while IsValid(next) and next:shouldSkip() do
        self.curStep = self.curStep + 1
        next:onSkip()
        next = self.steps[self.curStep]
    end

    if not IsValid(next) then
        self.curStep = last
        return self:onFinish()
    end

    self:onStepChanged(cur, next)
end

function PANEL:previousStep()
    local cur = self.curStep - 1
    local prev = self.steps[cur]
    while IsValid(prev) and prev:shouldSkip() do
        prev:onSkip()
        cur = cur - 1
        prev = self.steps[cur]
    end

    if not IsValid(prev) then return end
    self.curStep = cur
    self:onStepChanged(self.steps[self.curStep + 1], prev)
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
    local text = L(finish and "finish" or "next"):upper()
    if IsValid(self:getPreviousStep()) then
        self.prev:AlphaTo(255, 0.5)
    else
        self.prev:AlphaTo(0, 0.5)
    end

    if text ~= self.next:GetText() then self.next:AlphaTo(0, 0.5) end
    local function showStep()
        newStep:SetAlpha(0)
        newStep:SetVisible(true)
        newStep:onDisplay()
        newStep:InvalidateChildren(true)
        newStep:AlphaTo(255, 0.5)
        if text ~= self.next:GetText() then
            self.next:SetAlpha(0)
            self.next:SetText(text)
            self.next:SizeToContentsX()
        end

        self.next:AlphaTo(255, 0.5)
    end

    if IsValid(oldStep) then
        oldStep:AlphaTo(0, 0.5, 0, function()
            self:showError()
            oldStep:SetVisible(false)
            oldStep:onHide()
            showStep()
        end)
    else
        showStep()
    end
end

function PANEL:Init()
    self:Dock(FILL)
    local can, reason = self:canCreateCharacter()
    if not can then return self:showMessage(reason) end
    lia.gui.charCreate = self
    local margin = 0
    if ScrW() > 1280 then
        margin = ScrW() * 0.15
    elseif ScrW() > 720 then
        margin = ScrW() * 0.075
    end

    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(margin, 64, margin, 0)
    self.content:SetPaintBackground(false)
    self.model = self.content:Add("liaModelPanel")
    self.model:SetWide(ScrW() * 0.25)
    self.model:Dock(LEFT)
    self.model:SetModel("models/error.mdl")
    self.model:fitFOV()
    self.buttons = self:Add("DPanel")
    self.buttons:Dock(BOTTOM)
    self.buttons:SetTall(48)
    self.buttons:SetPaintBackground(false)
    self.prev = self.buttons:Add("liaCharacterTabButton")
    self.prev:SetText(L("back"):upper())
    self.prev:Dock(LEFT)
    self.prev:SizeToContents()
    self.prev.DoClick = function() self:previousStep() end
    self.prev:SetAlpha(0)
    self.next = self.buttons:Add("liaCharacterTabButton")
    self.next:SetText(L("next"):upper())
    self.next:Dock(RIGHT)
    self.next:SizeToContents()
    self.next.DoClick = function() self:nextStep() end
    self.steps = {}
    self.curStep = 0
    self.context = {}
    self:configureSteps()
    if #self.steps == 0 then return self:showError("No character creation steps have been set up") end
    self:nextStep()
    timer.Simple(0.5, function() hook.Run("ModifyCharacterModel", self.model:GetEntity()) end)
end

vgui.Register("liaCharacterCreation", PANEL, "EditablePanel")