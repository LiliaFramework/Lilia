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
    self._text_offset = 0
    self.panelColor = lia.color.theme.panel[1]
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        if not s._shadowLerp then s._shadowLerp = 5 end
        local target = s:IsEditing() and 10 or 5
        s._shadowLerp = Lerp(FrameTime() * 10, s._shadowLerp, target)
        lia.derma.rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.derma.SHAPE_IOS):Shadow(s._shadowLerp, 20):Draw()
        lia.derma.rect(0, 0, w, h):Rad(16):Color(self.panelColor):Shape(lia.derma.SHAPE_IOS):Draw()
        local value = self:GetValue()
        surface.SetFont(font)
        local padding = 6
        local available_w = w - padding * 2
        local caret = #value
        local before_caret = string.sub(value, 1, caret)
        local caret_x = surface.GetTextSize(before_caret)
        local text_w = surface.GetTextSize(value)
        local desired_offset = 0
        if caret_x > available_w then desired_offset = caret_x - available_w end
        if text_w - desired_offset < available_w then desired_offset = math.max(0, text_w - available_w) end
        self._text_offset = Lerp(FrameTime() * 15, self._text_offset or 0, desired_offset)
        local text = self.placeholder
        local col = lia.color.theme.gray
        if value ~= "" then
            text = value
            col = lia.color.theme.text_entry or lia.color.theme.text
        end
        draw.SimpleText(text, font, padding - self._text_offset, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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