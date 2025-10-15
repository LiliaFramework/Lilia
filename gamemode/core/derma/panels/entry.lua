local PANEL = {}
function PANEL:Init()
    self.title = nil
    self.placeholder = L("enterText")
    self:SetTall(26)
    self.action = function() end
    local font = "LiliaFont.18"
    self.textEntry = vgui.Create("DTextEntry", self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText("")
    self.textEntry.OnEnter = function() self.action(self:GetValue()) end
    self.textEntry.OnLoseFocus = function() self.action(self:GetValue()) end
    self.textEntry.OnValueChange = function(_, value) if self.OnValueChange then self:OnValueChange(value) end end
    self.textEntry.OnTextChanged = function()
        local value = self:GetValue()
        if self.OnTextChanged then self:OnTextChanged(value) end
    end

    self._text_offset = 0
    self.panelColor = lia.color.theme.panel[1]
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        if not s._shadowLerp then s._shadowLerp = 5 end
        local target = s:IsEditing() and 10 or 5
        s._shadowLerp = Lerp(FrameTime() * 10, s._shadowLerp, target)

        -- background and base panel fill
        lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(s._shadowLerp, 20):Draw()
        lia.derma.rect(0, 0, w, h):Rad(16):Color(self.panelColor):Shape(lia.derma.SHAPE_IOS):Draw()

        -- hover/focus feedback
        s._hoverFrac = Lerp(FrameTime() * 10, s._hoverFrac or 0, s:IsHovered() and 1 or 0)
        s._focusFrac = Lerp(FrameTime() * 10, s._focusFrac or 0, (s:IsEditing() or s:HasFocus()) and 1 or 0)

        if s._hoverFrac > 0 then
            local hov = lia.color.theme.button_hovered or Color(255, 255, 255)
            lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(hov.r, hov.g, hov.b, math.floor(s._hoverFrac * 90))):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        if s._focusFrac > 0 then
            local ac = lia.color.theme.theme or lia.color.theme.accent or color_white
            lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(ac.r, ac.g, ac.b, math.floor(s._focusFrac * 255))):Shape(lia.derma.SHAPE_IOS):Outline(2):Draw()
        end

        -- text / placeholder
        local value = self:GetValue()
        local padding = 6

        if value == "" then
            surface.SetFont(font)
            local phColor = lia.color.theme.gray
            draw.SimpleText(self.placeholder or "", font, padding, h * 0.5, phColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        -- draw actual text, selection highlight and caret on top
        local textCol = lia.color.theme.text_entry or lia.color.theme.text or color_white
        local selBase = lia.color.theme.theme or lia.color.theme.accent or Color(100, 100, 255)
        local selCol = Color(selBase.r, selBase.g, selBase.b, 60)
        local caretCol = lia.color.theme.theme or lia.color.theme.accent or textCol
        s:DrawTextEntryText(textCol, selCol, caretCol)
    end
end

function PANEL:SetTitle(title)
    self.title = title
    self:SetTall(52)
    self.titlePanel = vgui.Create("DPanel", self)
    self.titlePanel:Dock(TOP)
    self.titlePanel:DockMargin(0, 0, 0, 6)
    self.titlePanel:SetTall(18)
    self.titlePanel.Paint = function() draw.SimpleText(self.title, "LiliaFont.18", 0, 0, lia.color.theme.text_entry or lia.color.theme.text) end
end

function PANEL:SetPlaceholder(placeholder)
    self.placeholder = placeholder
end

function PANEL:SetPlaceholderText(placeholder)
    self.placeholder = placeholder
end

function PANEL:SetValue(value)
    self.textEntry:SetText(value or "")
end

function PANEL:SetText(value)
    self:SetValue(value)
end

function PANEL:GetValue()
    return self.textEntry:GetText()
end

function PANEL:SelectAll()
    if self.textEntry.SelectAllText then self.textEntry:SelectAllText(true) end
end

function PANEL:SetFont(font)
    self.textEntry:SetFont(font)
end

function PANEL:SetNumeric(isNumeric)
    if self.textEntry.SetNumeric then self.textEntry:SetNumeric(isNumeric) end
end

function PANEL:AllowInput(callback)
    if isfunction(callback) then
        self.textEntry.AllowInput = function(_, char) return callback(self, char) end
    else
        self.textEntry.AllowInput = nil
    end
end

function PANEL:SetTextColor(color)
    if IsValid(self.textEntry) then self.textEntry:SetTextColor(color) end
end

vgui.Register("liaEntry", PANEL, "EditablePanel")
