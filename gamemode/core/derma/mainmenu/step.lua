local PANEL = {}
PANEL.isCharCreateStep = true
function PANEL:Init()
    self:Dock(FILL)
    self:SetPaintBackground(false)
    self:SetVisible(false)
    -- Store reference to parent character creation panel
    self.charCreatePanel = nil
    -- Find the parent character creation panel
    local parent = self:GetParent()
    while parent do
        if parent.isCharCreatePanel then
            self.charCreatePanel = parent
            break
        end
        parent = parent:GetParent()
    end
end

function PANEL:onDisplay()
end

function PANEL:next()
    if self.charCreatePanel then
        self.charCreatePanel:nextStep()
    end
end

function PANEL:previous()
    if self.charCreatePanel then
        self.charCreatePanel:previousStep()
    end
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
    if self.charCreatePanel then
        self.charCreatePanel.context[k] = v
    end
end

function PANEL:clearContext()
    if self.charCreatePanel then
        self.charCreatePanel.context = {}
    end
end

function PANEL:getContext(k, d)
    if not self.charCreatePanel then return d end
    local ctx = self.charCreatePanel.context
    if k == nil then return ctx end
    local v = ctx[k]
    return v == nil and d or v
end

function PANEL:getModelPanel()
    if self.charCreatePanel then
        return self.charCreatePanel.model
    end
end

function PANEL:updateModelPanel()
    if self.charCreatePanel then
        self.charCreatePanel:updateModel()
    end
end

function PANEL:shouldSkip()
    return false
end

function PANEL:onSkip()
end

function PANEL:addLabel(text)
    local lbl = self:Add("liaText")
    lbl:SetFont("liaCharButtonFont")
    lbl:SetText(L(text):upper())
    lbl:SizeToContents()
    lbl:Dock(TOP)
    return lbl
end

function PANEL:onHide()
end

vgui.Register("liaCharacterCreateStep", PANEL, "liaScrollPanel")
