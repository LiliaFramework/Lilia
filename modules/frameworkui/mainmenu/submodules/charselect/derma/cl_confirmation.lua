﻿local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.charConfirm) then lia.gui.charConfirm:Remove() end
    lia.gui.charConfirm = self
    self:SetAlpha(0)
    self:AlphaTo(255, 0.5 * 2)
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self.content = self:Add("DPanel")
    self.content:SetSize(ScrW(), 256)
    self.content:CenterVertical()
    self.content.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
    end

    self.title = self.content:Add("DLabel")
    self.title:SetText(L("Are you sure?"):upper())
    self.title:SetFont("liaCharButtonFont")
    self.title:SetTextColor(color_white)
    self.title:SizeToContents()
    self.title:CenterHorizontal()
    self.title.y = 64
    self.message = self.content:Add("DLabel")
    self.message:SetFont("liaCharSubTitleFont")
    self.message:SetTextColor(color_white)
    self.message:SetSize(ScrW(), 32)
    self.message:CenterVertical()
    self.message:SetContentAlignment(5)
    local SPACING = 16
    local confirmText, cancelText = L("yes"):upper(), L("no"):upper()
    surface.SetFont("liaCharSmallButtonFont")
    local confirmWidth = surface.GetTextSize(confirmText) + SPACING
    local cancelWidth = surface.GetTextSize(cancelText) + SPACING
    self.confirm = self.content:Add("DButton")
    self.confirm:SetFont("liaCharSmallButtonFont")
    self.confirm:SetText(confirmText)
    self.confirm:SetPaintBackground(false)
    self.confirm:SetSize(confirmWidth, 32)
    self.confirm.OnCursorEntered = function() lia.gui.character:hoverSound() end
    self.confirm.OnCursorEntered = function(cancel)
        cancel.BaseClass.OnCursorEntered(cancel)
        lia.gui.character:hoverSound()
    end

    self.confirm:SetPos(ScrW() * 0.5 - (self.confirm:GetWide() + SPACING), self.message.y + 64)
    self.confirm.DoClick = function()
        lia.gui.character:clickSound()
        if isfunction(self.onConfirmCallback) then self.onConfirmCallback() end
        self:Remove()
    end

    self.cancel = self.content:Add("DButton")
    self.cancel:SetFont("liaCharSmallButtonFont")
    self.cancel:SetText(cancelText)
    self.cancel:SetPaintBackground(false)
    self.cancel:SetSize(cancelWidth, 32)
    self.cancel.OnCursorEntered = function(cancel)
        cancel.BaseClass.OnCursorEntered(cancel)
        lia.gui.character:hoverSound()
    end

    self.cancel:SetPos(ScrW() * 0.5 + SPACING, self.message.y + 64)
    self.cancel.DoClick = function()
        lia.gui.character:clickSound()
        if isfunction(self.onCancelCallback) then self.onCancelCallback() end
        self:Remove()
    end

    timer.Simple(0.5 * 0.5, function() lia.gui.character:warningSound() end)
end

function PANEL:OnMousePressed()
    self:Remove()
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:setTitle(title)
    self.title:SetText(title)
    self.title:SizeToContentsX()
    self.title:CenterHorizontal()
    return self
end

function PANEL:setMessage(message)
    self.message:SetText(message:upper())
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
