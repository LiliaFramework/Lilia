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
        local value = self:GetValue() or ""
        if self.OnTextChanged then self:OnTextChanged(value) end
    end

    self._text_offset = 0
    self.panelColor = lia.color.theme.panel[1]
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        if not s._shadowLerp then s._shadowLerp = 5 end
        local target = s:IsEditing() and 10 or 5
        s._shadowLerp = Lerp(FrameTime() * 10, s._shadowLerp, target)
        lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(s._shadowLerp, 20):Draw()
        lia.derma.rect(0, 0, w, h):Rad(16):Color(self.panelColor):Shape(lia.derma.SHAPE_IOS):Draw()
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

        local value = self:GetValue()
        local padding = 6
        if value == "" then
            surface.SetFont(font)
            local phColor = lia.color.theme.gray
            draw.SimpleText(self.placeholder or "", font, padding, h * 0.5, phColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

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

function PANEL:GetAutoComplete()
    if self.textEntry.GetAutoComplete then return self.textEntry:GetAutoComplete() end
end

function PANEL:GetCursorColor()
    if self.textEntry.GetCursorColor then return self.textEntry:GetCursorColor() end
end

function PANEL:GetDisabled()
    if self.textEntry.GetDisabled then return self.textEntry:GetDisabled() end
end

function PANEL:GetPaintBackground()
    if self.textEntry.GetPaintBackground then return self.textEntry:GetPaintBackground() end
end

function PANEL:GetDrawBorder()
    if self.textEntry.GetDrawBorder then return self.textEntry:GetDrawBorder() end
end

function PANEL:GetEnterAllowed()
    if self.textEntry.GetEnterAllowed then return self.textEntry:GetEnterAllowed() end
end

function PANEL:GetFloat()
    if self.textEntry.GetFloat then return self.textEntry:GetFloat() end
end

function PANEL:GetHighlightColor()
    if self.textEntry.GetHighlightColor then return self.textEntry:GetHighlightColor() end
end

function PANEL:GetHistoryEnabled()
    if self.textEntry.GetHistoryEnabled then return self.textEntry:GetHistoryEnabled() end
end

function PANEL:GetInt()
    if self.textEntry.GetInt then return self.textEntry:GetInt() end
end

function PANEL:GetNumeric()
    if self.textEntry.GetNumeric then return self.textEntry:GetNumeric() end
end

function PANEL:GetPaintBackground()
    if self.textEntry.GetPaintBackgroundEnabled then return self.textEntry:GetPaintBackgroundEnabled() end
end

function PANEL:GetPlaceholderColor()
    if self.textEntry.GetPlaceholderColor then return self.textEntry:GetPlaceholderColor() end
end

function PANEL:GetPlaceholderText()
    return self.placeholder
end

function PANEL:GetTabbingDisabled()
    if self.textEntry.GetTabbingDisabled then return self.textEntry:GetTabbingDisabled() end
end

function PANEL:GetTextColor()
    if self.textEntry.GetTextColor then return self.textEntry:GetTextColor() end
end

function PANEL:GetUpdateOnType()
    if self.textEntry.GetUpdateOnType then return self.textEntry:GetUpdateOnType() end
end

function PANEL:IsEditing()
    if self.textEntry.IsEditing then return self.textEntry:IsEditing() end
end

function PANEL:SetCursorColor(color)
    if self.textEntry.SetCursorColor then self.textEntry:SetCursorColor(color) end
end

function PANEL:SetDisabled(disabled)
    if self.textEntry.SetDisabled then self.textEntry:SetDisabled(disabled) end
end

function PANEL:SetPaintBackground(drawBackground)
    if self.textEntry.SetPaintBackground then self.textEntry:SetPaintBackground(drawBackground) end
end

function PANEL:SetDrawBorder(drawBorder)
    if self.textEntry.SetDrawBorder then self.textEntry:SetDrawBorder(drawBorder) end
end

function PANEL:SetEditable(editable)
    if self.textEntry.SetEditable then self.textEntry:SetEditable(editable) end
end

function PANEL:SetEnterAllowed(allowed)
    if self.textEntry.SetEnterAllowed then self.textEntry:SetEnterAllowed(allowed) end
end

function PANEL:SetHighlightColor(color)
    if self.textEntry.SetHighlightColor then self.textEntry:SetHighlightColor(color) end
end

function PANEL:SetHistoryEnabled(enabled)
    if self.textEntry.SetHistoryEnabled then self.textEntry:SetHistoryEnabled(enabled) end
end

function PANEL:SetNumeric(numeric)
    if self.textEntry.SetNumeric then self.textEntry:SetNumeric(numeric) end
end

function PANEL:SetPaintBackground(paintBackground)
    if self.textEntry.SetPaintBackgroundEnabled then self.textEntry:SetPaintBackgroundEnabled(paintBackground) end
end

function PANEL:SetPlaceholderColor(color)
    if self.textEntry.SetPlaceholderColor then self.textEntry:SetPlaceholderColor(color) end
end

function PANEL:SetPlaceholderText(placeholder)
    self.placeholder = placeholder
end

function PANEL:SetTabbingDisabled(disabled)
    if self.textEntry.SetTabbingDisabled then self.textEntry:SetTabbingDisabled(disabled) end
end

function PANEL:SetTextColor(color)
    if IsValid(self.textEntry) then self.textEntry:SetTextColor(color) end
end

function PANEL:SetUpdateOnType(update)
    if self.textEntry.SetUpdateOnType then self.textEntry:SetUpdateOnType(update) end
end

function PANEL:SetMultiline(multiline)
    if self.textEntry.SetMultiline then self.textEntry:SetMultiline(multiline) end
end

function PANEL:OnChange()
    if self.textEntry.OnChange then self.textEntry:OnChange() end
end

function PANEL:OnGetFocus()
    if self.textEntry.OnGetFocus then self.textEntry:OnGetFocus() end
end

function PANEL:OnKeyCode(code)
    if self.textEntry.OnKeyCode then self.textEntry:OnKeyCode(code) end
end

function PANEL:AddHistory(value)
    if self.textEntry.AddHistory then self.textEntry:AddHistory(value) end
end

function PANEL:CheckNumeric()
    if self.textEntry.CheckNumeric then return self.textEntry:CheckNumeric() end
end

function PANEL:OpenAutoComplete()
    if self.textEntry.OpenAutoComplete then self.textEntry:OpenAutoComplete() end
end

function PANEL:UpdateConvarValue()
    if self.textEntry.UpdateConvarValue then self.textEntry:UpdateConvarValue() end
end

function PANEL:UpdateFromHistory()
    if self.textEntry.UpdateFromHistory then self.textEntry:UpdateFromHistory() end
end

function PANEL:UpdateFromMenu()
    if self.textEntry.UpdateFromMenu then self.textEntry:UpdateFromMenu() end
end

vgui.Register("liaEntry", PANEL, "EditablePanel")
