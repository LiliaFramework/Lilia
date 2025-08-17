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
    local var = lia.char.vars[name]
    assert(var, L("invalidCharVar", tostring(name)))
    return isfunction(var.onValidate) and var.onValidate(self:getContext(name), self:getContext(), LocalPlayer()) or true
end

function PANEL:validate()
    return true
end

function PANEL:setContext(k, v)
    lia.gui.charCreate.context[k] = v
end

function PANEL:clearContext()
    lia.gui.charCreate.context = {}
end

function PANEL:getContext(k, d)
    local ctx = lia.gui.charCreate.context
    if k == nil then return ctx end
    local v = ctx[k]
    return v == nil and d or v
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
    local lbl = self:Add("DLabel")
    lbl:SetFont("liaCharButtonFont")
    lbl:SetText(L(text):upper())
    lbl:SizeToContents()
    lbl:Dock(TOP)
    return lbl
end

function PANEL:onHide()
end

vgui.Register("liaCharacterCreateStep", PANEL, "DScrollPanel")