local PANEL = {}

function PANEL:Init()
    self.title = self:addLabel("Welcome")
    self.desc = self:Add("DTextEntry")
    self.desc:DockMargin(0, 8, 0, 0)
    self.desc:SetSize(ScrW() * 0.35, ScrH() * 0.7)
    self.desc:SetPos(0, 50)
    self.desc:SetFont("liaCharSubTitleFont")
    self.desc:SetTextColor(Color(255, 255, 255))
    self.desc:SetPaintBackground(false)
    self.desc:SetWrap(true)
    self.desc:SetMultiline(true)
end

function PANEL:onDisplay()
    self.desc:SetText(PLUGIN.GamemodeInformation)

    self.desc.AllowInput = function()
        return true
    end

    self.desc:SetEnabled(false)
end

vgui.Register("liaStartInfo", PANEL, "liaCharacterCreateStep")