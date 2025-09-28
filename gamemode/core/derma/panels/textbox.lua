local PANEL = {}
local color_accept = Color(35, 103, 51)
function PANEL:Init()
    self.title = ""
    self.description = ""
    self.callback = nil
    self:SetSize(300, 134)
    self:Center()
    self:MakePopup()
    self:DockPadding(12, 30, 12, 12)
    local entry = vgui.Create("liaEntry", self)
    entry:Dock(TOP)
    entry.OnEnter = function() self:Apply() end
    self.entry = entry
    local btn_accept = vgui.Create("liaButton", self)
    btn_accept:Dock(BOTTOM)
    btn_accept:SetTall(30)
    btn_accept:SetText(L("apply"))
    btn_accept:SetColorHover(color_accept)
    btn_accept.DoClick = function()
        surface.PlaySound('garrysmod/ui_click.wav')
        self:Apply()
    end

    self.btn_accept = btn_accept
end

function PANEL:Apply()
    if self.callback then self.callback(self.entry:GetValue()) end
    self:Remove()
end

function PANEL:SetTitle(title)
    self.title = title
end

function PANEL:GetTitle()
    return self.title
end

function PANEL:SetDescription(desc)
    self.description = desc
    if IsValid(self.entry) then self.entry:SetTitle(desc) end
end

function PANEL:GetDescription()
    return self.description
end

function PANEL:GetValue()
    if IsValid(self.entry) then return self.entry:GetValue() end
    return ""
end

function PANEL:OnCallback(callback)
    self.callback = callback
end

function PANEL:Paint(_, _)
end

vgui.Register("liaTextBox", PANEL, "liaFrame")
