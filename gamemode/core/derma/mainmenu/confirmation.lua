local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.charConfirm) then lia.gui.charConfirm:Remove() end
    lia.gui.charConfirm = self
    local w, h = 400, 140
    self:SetSize(w, h)
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:MakePopup()
    self.Paint = function(_, fw, fh)
        lia.util.drawBlur(_)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, fw, fh)
    end

    self.title = self:Add("DLabel")
    self.title:SetFont("liaBigFont")
    self.title:SetText(L("areYouSure"):upper())
    self.title:SetTextColor(color_white)
    self.title:SizeToContents()
    self.title:CenterHorizontal()
    self.title:SetY(10)
    self.message = self:Add("DLabel")
    self.message:SetFont("liaSmallFont")
    self.message:SetTextColor(color_white)
    self.message:SetSize(w - 20, 20)
    self.message:SetPos(10, 40)
    self.message:SetContentAlignment(5)
    local confirmText, cancelText = L("yes"):upper(), L("no"):upper()
    local cw = surface.GetTextSize(confirmText)
    local aw = surface.GetTextSize(cancelText)
    local padding = 40
    local btnW = math.max(cw, aw) + padding
    local btnH = 30
    local spacing = 20
    local startX = (w - (btnW * 2 + spacing)) * 0.5
    local btnY = h - btnH - 15
    self.confirm = self:Add("liaSmallButton")
    self.confirm:SetText(confirmText)
    self.confirm:SetPaintBackground(false)
    self.confirm:SetSize(btnW, btnH)
    self.confirm:SetPos(startX, btnY)
    self.confirm:SetContentAlignment(5)
    self.confirm.OnCursorEntered = function(btn)
        btn.BaseClass.OnCursorEntered(btn)
        lia.gui.character:hoverSound()
    end

    self.confirm.DoClick = function()
        lia.gui.character:clickSound()
        if isfunction(self.onConfirmCallback) then self.onConfirmCallback() end
        self:Remove()
    end

    self.cancel = self:Add("liaSmallButton")
    self.cancel:SetText(cancelText)
    self.cancel:SetPaintBackground(false)
    self.cancel:SetSize(btnW, btnH)
    self.cancel:SetPos(startX + btnW + spacing, btnY)
    self.cancel:SetContentAlignment(5)
    self.cancel.OnCursorEntered = function(btn)
        btn.BaseClass.OnCursorEntered(btn)
        lia.gui.character:hoverSound()
    end

    self.cancel.DoClick = function()
        lia.gui.character:clickSound()
        if isfunction(self.onCancelCallback) then self.onCancelCallback() end
        self:Remove()
    end

    timer.Simple(0.25, function() lia.gui.character:warningSound() end)
end

function PANEL:setTitle(t)
    self.title:SetText(t)
    self.title:SizeToContentsX()
    self.title:CenterHorizontal()
    return self
end

function PANEL:setMessage(m)
    self.message:SetText(m:upper())
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

vgui.Register("liaCharacterConfirm", PANEL, "SemiTransparentDFrame")
