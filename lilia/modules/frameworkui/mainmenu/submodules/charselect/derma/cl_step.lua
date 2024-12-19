local PANEL = {}
PANEL.isCharCreateStep = true
function PANEL:Init()
    self:Dock(FILL)
    self:SetPaintBackground(false)
    self:SetVisible(false)
end

function PANEL:onDisplay()
end

function PANEL:next()
    lia.gui.charCreate:nextStep()
end

function PANEL:previous()
    lia.gui.charCreate:previousStep()
end

function PANEL:validateCharVar(name)
    local client = LocalPlayer()
    local charVar = lia.char.vars[name]
    assert(charVar, "invalid character variable " .. tostring(name))
    if isfunction(charVar.onValidate) then return charVar.onValidate(self:getContext(name), self:getContext(), client) end
    return true
end

function PANEL:validate()
    return true
end

function PANEL:setContext(key, value)
    lia.gui.charCreate.context[key] = value
end

function PANEL:clearContext()
    lia.gui.charCreate.context = {}
end

function PANEL:getContext(key, default)
    if key == nil then return lia.gui.charCreate.context end
    local value = lia.gui.charCreate.context[key]
    if value == nil then return default end
    return value
end

function PANEL:getModelPanel()
    return lia.gui.charCreate.model
end

function PANEL:updateModelPanel()
    lia.gui.charCreate:updateModel()
end

function PANEL:shouldSkip()
    return false
end

function PANEL:onSkip()
end

function PANEL:addLabel(text)
    local label = self:Add("DLabel")
    label:SetFont("liaCharButtonFont")
    label:SetText(L(text):upper())
    label:SizeToContents()
    label:Dock(TOP)
    return label
end

function PANEL:onHide()
end

vgui.Register("liaCharacterCreateStep", PANEL, "DScrollPanel")
