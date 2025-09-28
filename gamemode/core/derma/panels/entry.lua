local PANEL = {}
function PANEL:Init()
    self.title = nil
    self.placeholder = ""
    self:SetTall(26)
    self.action = function() end
    local font = "Fated.18"
    self.textEntry = vgui.Create("liaEntry", self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText("")
    self.textEntry.OnCloseFocus = function() self.action(self:GetValue()) end
    self._text_offset = 0
    self._shadowLerp = 5
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        local ft = FrameTime()
        if lia.config.get("uiDepthEnabled", true) then
            local target = s:IsEditing() and 10 or 5
            self._shadowLerp = lia.util.approachExp(self._shadowLerp, target, 12, ft)
            lia.rndx().Rect(0, 0, w, h):Rad(16):Color(lia.color.theme.window_shadow):Shape(lia.rndx.SHAPE_IOS):Shadow(self._shadowLerp, 20):Draw()
        end

        lia.rndx().Rect(0, 0, w, h):Rad(16):Color(lia.color.theme.focus_panel):Shape(lia.rndx.SHAPE_IOS):Draw()
        local value = self:GetValue() or ''
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
        self._text_offset = lia.util.approachExp(self._text_offset or 0, desired_offset, 24, ft)
        local text = self.placeholder
        local col = lia.color.theme.gray
        if value ~= '' then
            text = value
            col = lia.color.theme.text
        end

        draw.SimpleText(text, font, padding - self._text_offset, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:SetTitle(title)
    self.title = title
    self:SetTall(52)
    if IsValid(self.titlePanel) then self.titlePanel:Remove() end
    self.titlePanel = vgui.Create("liaBasePanel", self)
    self.titlePanel:Dock(TOP)
    self.titlePanel:DockMargin(0, 0, 0, 6)
    self.titlePanel:SetTall(18)
    self.titlePanel.Paint = function(_, w, h) draw.SimpleText(self.title, "Fated.18", 0, 0, lia.color.theme.text) end
end

function PANEL:SetPlaceholder(placeholder)
    self.placeholder = placeholder
end

function PANEL:GetValue()
    return self.textEntry:GetText()
end

function PANEL:SetValue(value)
    self.textEntry:SetText(value or '')
end

function PANEL:SetAction(func)
    self.action = func or function() end
end

function PANEL:OnEnter()
    self.action(self:GetValue())
end

function PANEL:SetPlaceholderText(text)
    self:SetPlaceholder(text)
end

function PANEL:GetPlaceholderText()
    return self.placeholder
end

function PANEL:SetPlaceholderColor(color)
    self.placeholderColor = color
end

function PANEL:GetPlaceholderColor()
    return self.placeholderColor or lia.color.theme.gray
end

vgui.Register("liaEntry", PANEL, "EditablePanel")
