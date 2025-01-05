local PANEL = {}
local function PaintBackground(panel, w, h)
    if panel.blank then
        surface.SetDrawColor(30, 30, 30, 150)
        surface.DrawRect(0, 0, w, h)
    end

    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-u"))
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawTexturedRect(0, 0, w, h * 1.2)
end

local function CreateLiaButton(parent, text, description, callback)
    local btn = parent:Add("DButton")
    btn:SetText("")
    btn:SetSize(100, 40)
    btn:SetPos(0, 0)
    btn.text_color = color_white
    btn.text = text
    btn.description = description or "No description"
    btn.selected = false
    btn.Paint = function(me, w, h)
        local hovered = me:IsHovered()
        me.text_color = lia.color.LerpColor(0.2, me.text_color, hovered and Color(200, 200, 200) or color_white)
        draw.SimpleText(me.text:upper(), "liaMediumFont", w * 0.5, h * 0.5, me.text_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if hovered then
            local underlineWidth = w * 0.4
            local underlineX = (w - underlineWidth) * 0.5
            local underlineY = h - 4
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
        end
    end

    btn.DoClick = function(me)
        if parent.selectedButton and parent.selectedButton ~= me and parent.selectedButton.selected then parent.selectedButton.selected = false end
        parent.selectedButton = me
        if IsValid(parent.selectedDescription) then parent.selectedDescription:SetText(me.description) end
        if callback and isfunction(callback) then callback() end
    end

    btn.OnCursorEntered = function(cancel) cancel.BaseClass.OnCursorEntered(cancel) end
    return btn
end

function PANEL:Init()
    if IsValid(lia.gui.charConfirm) then lia.gui.charConfirm:Remove() end
    lia.gui.charConfirm = self
    self:SetAlpha(0)
    self:AlphaTo(255, lia.gui.character.ANIM_SPEED * 2)
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self.content = self:Add("DPanel")
    self.content:SetSize(ScrW() * 0.4, 256)
    self.content:Center()
    self.content.Paint = function(panel, w, h) PaintBackground(panel, w, h) end
    self.title = self.content:Add("DLabel")
    self.title:SetText(L("ARE YOU SURE?"))
    self.title:SetFont("liaCharButtonFont")
    self.title:SetTextColor(color_white)
    self.title:SizeToContents()
    self.title:CenterHorizontal()
    self.title:SetPos(self.title:GetX(), 40)
    self.message = self.content:Add("DLabel")
    self.message:SetFont("liaCharSubTitleFont")
    self.message:SetTextColor(color_white)
    self.message:SetSize(self.content:GetWide() * 0.8, 32)
    self.message:CenterHorizontal()
    self.message:SetPos((self.content:GetWide() - self.message:GetWide()) / 2, self.title:GetY() + 40)
    self.message:SetContentAlignment(5)
    self.message:SetText("")
    self.buttonsContainer = self.content:Add("DPanel")
    self.buttonsContainer:SetSize(self.content:GetWide(), 60)
    self.buttonsContainer:SetPos(0, self.content:GetTall() - 80)
    self.buttonsContainer.Paint = function() end
    CreateLiaButton(self.buttonsContainer, "YES", "Confirm the action", function()
        if isfunction(self.onConfirmCallback) then self.onConfirmCallback() end
        self:Remove()
    end)

    CreateLiaButton(self.buttonsContainer, "NO", "Cancel the action", function()
        if isfunction(self.onCancelCallback) then self.onCancelCallback() end
        self:Remove()
    end)

    local confirmBtn = self.buttonsContainer:GetChildren()[1]
    confirmBtn:SetPos(self.content:GetWide() * 0.25 - confirmBtn:GetWide() / 2, 10)
    local cancelBtn = self.buttonsContainer:GetChildren()[2]
    cancelBtn:SetPos(self.content:GetWide() * 0.75 - cancelBtn:GetWide() / 2, 10)
    timer.Simple(lia.gui.character.ANIM_SPEED * 0.5, function() if IsValid(self) then lia.gui.character:warningSound() end end)
end

function PANEL:OnMousePressed()
    self:Remove()
end

function PANEL:Paint(w, h)
    local client = LocalPlayer()
    if not client:getChar() then lia.util.drawBlur(self) end
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:setTitle(title)
    self.title:SetText(title)
    self.title:SizeToContentsX()
    self.title:CenterHorizontal()
    self.title:SetPos(self.title:GetX(), 40)
    return self
end

function PANEL:setMessage(message)
    self.message:SetText(message:upper())
    self.message:SizeToContentsX()
    self.message:CenterHorizontal()
    self.message:SetPos((self.content:GetWide() - self.message:GetWide()) / 2, self.title:GetY() + 40)
    return self
end

function PANEL:onConfirm(callback)
    self.onConfirmCallback = callback
    return self
end

function PANEL:onCancel(callback)
    self.onCancelCallback = callback
    return self
end

vgui.Register("liaCharacterConfirm", PANEL, "EditablePanel")
