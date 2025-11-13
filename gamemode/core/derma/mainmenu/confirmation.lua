local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.charConfirm) then lia.gui.charConfirm:Remove() end
    lia.gui.charConfirm = self
    self.pad, self.btnH = 10, 25
    self:SetSize(400, 200)
    self:MakePopup()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self.titleLabel = self:Add("DLabel")
    self.titleLabel:SetFont("LiliaFont.17")
    self.titleLabel:SetTextColor(color_white)
    self.titleLabel:SetText(L("areYouSure"):upper())
    self.titleLabel:SetContentAlignment(5)
    self.messageLabel = self:Add("DLabel")
    self.messageLabel:SetFont("LiliaFont.14")
    self.messageLabel:SetTextColor(color_white)
    self.messageLabel:SetWrap(true)
    self.messageLabel:SetContentAlignment(5)
    self.confirmButton = self:Add("liaSmallButton")
    self.confirmButton:SetFont("LiliaFont.17")
    self.confirmButton:SetText(L("yes"):upper())
    self.confirmButton:SetPaintBackground(false)
    self.confirmButton:SetContentAlignment(5)
    function self.confirmButton:OnCursorEntered()
        self.BaseClass.OnCursorEntered(self)
        if lia.gui.character and isfunction(lia.gui.character.hoverSound) then lia.gui.character:hoverSound() end
    end

    self.confirmButton.DoClick = function()
        if lia.gui.character and isfunction(lia.gui.character.clickSound) then lia.gui.character:clickSound() end
        if isfunction(self.onConfirmCallback) then self.onConfirmCallback() end
        self:Remove()
    end

    self.cancelButton = self:Add("liaSmallButton")
    self.cancelButton:SetFont("LiliaFont.17")
    self.cancelButton:SetText(L("no"):upper())
    self.cancelButton:SetPaintBackground(false)
    self.cancelButton:SetContentAlignment(5)
    function self.cancelButton:OnCursorEntered()
        self.BaseClass.OnCursorEntered(self)
        if lia.gui.character and isfunction(lia.gui.character.hoverSound) then lia.gui.character:hoverSound() end
    end

    self.cancelButton.DoClick = function()
        if lia.gui.character and isfunction(lia.gui.character.clickSound) then lia.gui.character:clickSound() end
        if isfunction(self.onCancelCallback) then self.onCancelCallback() end
        self:Remove()
    end

    timer.Simple(0.25, function() if lia.gui.character and isfunction(lia.gui.character.warningSound) then lia.gui.character:warningSound() end end)
    self:Center()
end

function PANEL:PerformLayout(w, h)
    DFrame.PerformLayout(self, w, h)
    local pad, btnH = self.pad, self.btnH
    self.titleLabel:SizeToContents()
    self.titleLabel:SetPos((w - self.titleLabel:GetWide()) * 0.5, pad * 2)
    local titleBottom = pad * 2 + self.titleLabel:GetTall()
    local availH = h - titleBottom - pad * 2 - btnH
    self.messageLabel:SetSize(w - pad * 2, availH)
    self.messageLabel:InvalidateLayout(true)
    self.messageLabel:SizeToContentsY()
    self.messageLabel:SetPos((w - self.messageLabel:GetWide()) * 0.5, titleBottom + (availH - self.messageLabel:GetTall()) * 0.5)
    local btnW = (w - pad * 3) * 0.5
    self.confirmButton:SetSize(btnW, btnH)
    self.confirmButton:SetPos(pad, h - pad - btnH)
    self.cancelButton:SetSize(btnW, btnH)
    self.cancelButton:SetPos(pad * 2 + btnW, h - pad - btnH)
end

function PANEL:setMessage(text)
    self.messageLabel:SetText(text:upper())
    self:InvalidateLayout()
    return self
end

function PANEL:onConfirm(cb)
    self.onConfirmCallback = cb
    return self
end

function PANEL:onCancel(cb)
    self.onCancelCallback = cb
    return self
end

vgui.Register("liaCharacterConfirm", PANEL, "liaSemiTransparentDFrame")
