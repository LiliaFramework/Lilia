local PANEL = {}
local COLORS = {
    background = Color(0, 0, 0, 100),
    border = Color(120, 120, 120, 255),
    button = Color(70, 130, 180, 255),
    buttonHovered = Color(100, 160, 210, 255),
    buttonActive = Color(50, 110, 160, 255),
    text = Color(255, 255, 255, 255),
    success = Color(60, 179, 113, 200),
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
    local faction = lia.faction.indices[self.context.faction]
    assert(faction, "invalid faction when updating model")
    local modelInfo = faction.models[self.context.model or 1]
    assert(modelInfo, "faction " .. faction.name .. " has no models!")
    local model, skin, groups
    if istable(modelInfo) then
        model, skin, groups = unpack(modelInfo)
    else
        model, skin, groups = modelInfo, 0, {}
    end

    self.model:SetModel(model)
    local entity = self.model:GetEntity()
    if not IsValid(entity) then return end
    entity:SetSkin(skin)
    if istable(groups) then
        for group, value in pairs(groups) do
            entity:SetBodygroup(group, value)
        end
    elseif isstring(groups) then
        entity:SetBodyGroups(groups)
    end

    if self.context.skin then entity:SetSkin(self.context.skin) end
    if self.context.groups then
        for group, value in pairs(self.context.groups or {}) do
            entity:SetBodygroup(group, value)
        end
    end

    if faction.material then entity:SetMaterial(faction.material) end
end

function PANEL:canCreateCharacter()
    local validFactions = {}
    for _, v in pairs(lia.faction.teams) do
        if lia.faction.hasWhitelist(v.index) then validFactions[#validFactions + 1] = v.index end
    end

    if #validFactions == 0 then return false, "You are unable to join any factions" end
    self.validFactions = validFactions
    local maxChars = hook.Run("GetMaxPlayerChar", LocalPlayer()) or lia.config.MaxCharacters
    if lia.characters and #lia.characters >= maxChars then return false, "You have reached the maximum number of characters" end
    local canCreate, reason = hook.Run("ShouldMenuButtonShow", "create")
    if canCreate == false then return false, reason end
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

function PANEL:showError(message, ...)
    if IsValid(self.error) then self.error:Remove() end
    if not message or message == "" then return end
    message = L(message, ...)
    assert(IsValid(self.content), "no step is available")
    self.error = self.content:Add("DLabel")
    self.error:SetFont("liaMenuButtonFont")
    self.error:SetText(message)
    self.error:SetTextColor(color_white)
    self.error:Dock(TOP)
    self.error:SetTall(32)
    self.error:DockMargin(0, 0, 0, 8)
    self.error:SetContentAlignment(5)
    self.error.Paint = function(box) lia.util.drawBlur(box) end
    self.error:SetAlpha(0)
    self.error:AlphaTo(255, self.ANIM_SPEED)
    lia.gui.character:warningSound()
end

function PANEL:showMessage(message, ...)
    if not message or message == "" then
        if IsValid(self.message) then self.message:Remove() end
        return
    end

    message = L(message, ...):upper()
    if IsValid(self.message) then
        self.message:SetText(message)
    else
        self.message = self:Add("DLabel")
        self.message:SetFont("liaCharButtonFont")
        self.message:SetTextColor(COLORS.text)
        self.message:Dock(TOP)
        self.message:SetContentAlignment(5)
        self.message:SetTall(32)
    end

    self.message:SetText(message)
end

function PANEL:addStep(step, priority)
    assert(IsValid(step), "Invalid panel for step")
    assert(step.isCharCreateStep, "Panel must inherit liaCharacterCreateStep")
    if isnumber(priority) then
        table.insert(self.steps, math.min(priority, #self.steps + 1), step)
    else
        self.steps[#self.steps + 1] = step
    end

    step:SetParent(self.stepsContainer)
end

function PANEL:nextStep()
    local lastStep = self.curStep
    local curStep = self.steps[lastStep]
    if IsValid(curStep) then
        local res = {curStep:validate()}
        if res[1] == false then return self:showError(unpack(res, 2)) end
    end

    self:showError()
    self.curStep = self.curStep + 1
    local nextStep = self.steps[self.curStep]
    while IsValid(nextStep) and nextStep:shouldSkip() do
        self.curStep = self.curStep + 1
        nextStep:onSkip()
        nextStep = self.steps[self.curStep]
    end

    if not IsValid(nextStep) then
        self.curStep = lastStep
        return self:onFinish()
    end

    self:onStepChanged(curStep, nextStep)
end

function PANEL:previousStep()
    local curStep = self.steps[self.curStep]
    local newStep = self.curStep - 1
    local prevStep = self.steps[newStep]
    while IsValid(prevStep) and prevStep:shouldSkip() do
        prevStep:onSkip()
        newStep = newStep - 1
        prevStep = self.steps[newStep]
    end

    if not IsValid(prevStep) then return end
    self.curStep = newStep
    self:onStepChanged(curStep, prevStep)
end

function PANEL:reset()
    self.context = {}
    local curStep = self.steps[self.curStep]
    if IsValid(curStep) then
        curStep:SetVisible(false)
        curStep:onHide()
    end

    self.curStep = 0
    if #self.steps == 0 then return self:showError("No character creation steps have been set up") end
    self:nextStep()
end

function PANEL:getPreviousStep()
    local step = self.curStep - 1
    while IsValid(self.steps[step]) do
        if not self.steps[step]:shouldSkip() then return self.steps[step] end
        step = step - 1
    end
    return nil
end

function PANEL:onStepChanged(oldStep, newStep)
    local ANIM_SPEED = self.ANIM_SPEED
    local shouldFinish = self.curStep > #self.steps
    local nextStepText = L(shouldFinish and "finish" or "next"):upper()
    local shouldSwitchNextText = nextStepText ~= self.next:GetText()
    self.prev:AlphaTo(255, ANIM_SPEED)
    if shouldSwitchNextText then
        self.next:AlphaTo(0, ANIM_SPEED, 0, function()
            self.next:SizeToContentsX(ANIM_SPEED)
            self.next:AlphaTo(255, ANIM_SPEED)
        end)
    end

    local function showNewStep()
        newStep:SetAlpha(0)
        newStep:SetVisible(true)
        newStep:onDisplay()
        newStep:InvalidateChildren(true)
        newStep:AlphaTo(255, ANIM_SPEED)
    end

    if IsValid(oldStep) then
        oldStep:AlphaTo(0, ANIM_SPEED, 0, function()
            oldStep:SetVisible(false)
            oldStep:onHide()
            showNewStep()
        end)
    else
        showNewStep()
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(COLORS.background)
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
    self.model:SetWide(ScrW() * 0.25)
    self.model:Dock(RIGHT)
    self.model:SetModel("models/error.mdl")
    self.model.oldSetModel = self.model.SetModel
    self.model.SetModel = function(model, ...)
        model:oldSetModel(...)
        model:fitFOV()
    end

    self.model.Think = function()
        local rotateLeft = input.IsKeyDown(KEY_A)
        local rotateRight = input.IsKeyDown(KEY_D)
        if rotateLeft then
            self.rotationAngle = self.rotationAngle - self.rotationSpeed
        elseif rotateRight then
            self.rotationAngle = self.rotationAngle + self.rotationSpeed
        end

        if IsValid(self.model) and IsValid(self.model.Entity) then
            local Angles = Angle(0, self.rotationAngle, 0)
            self.model.Entity:SetAngles(Angles)
        end
    end

    self.model.PaintOver = function(_, w, h)
        local leftRotateKey = "A"
        local rightRotateKey = "D"
        local str = string.format("[%s] Rotate Left | [%s] Rotate Right", leftRotateKey, rightRotateKey)
        lia.util.drawText(str, w / 2, h - 16, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end

    self.stepsContainer = self.content:Add("DPanel")
    self.stepsContainer:Dock(FILL)
    self.stepsContainer:SetPaintBackground(false)
    self.buttons = self:Add("DPanel")
    self.buttons:Dock(BOTTOM)
    self.buttons:SetTall(60)
    self.buttons:SetPaintBackground(false)
    local buttonWidth = ScrW() / 3
    self.prev = self.buttons:Add("DButton")
    self.prev:SetText("")
    self.prev:Dock(LEFT)
    self.prev:SetWide(buttonWidth)
    self.prev.Paint = function(_, w, h)
        surface.SetDrawColor(Color(0, 0, 0, 255))
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(L("back"):upper(), "liaMediumFont", w / 2, h / 2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.prev.DoClick = function() self:previousStep() end
    self.cancel = self.buttons:Add("DButton")
    self.cancel:SetText("")
    self.cancel:Dock(LEFT)
    self.cancel:SetWide(buttonWidth)
    self.cancel.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(L("cancel"):upper(), "liaMediumFont", w / 2, h / 2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.cancel.DoClick = function() self:reset() end
    self.next = self.buttons:Add("DButton")
    self.next:SetText("")
    self.next:Dock(FILL)
    self.next.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(L("next"):upper(), "liaMediumFont", w / 2, h / 2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.next.DoClick = function() self:nextStep() end
    self:configureSteps()
    if #self.steps == 0 then return self:showError("No character creation steps have been set up") end
    self:nextStep()
end

vgui.Register("liaCharacterCreation", PANEL, "EditablePanel")