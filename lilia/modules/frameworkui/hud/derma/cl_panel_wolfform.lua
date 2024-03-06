
local PANEL = {}

function PANEL:Init()
    self.list = self:Add("DIconLayout")
    function self.list.Think(this)
        this:SizeToContentsY()
        this:SetWide(self:GetWide())
        this:SetPos(0, self:GetTall() / 2 - this:GetTall() / 2)
        this:ReArrange()
    end

    function self.list:ReArrange()
        local children = self:GetChildren()
        for k, v in pairs(children) do
            if #children % 2 ~= 0 then
                if k == #children then
                    v:SetWide(self:GetWide())
                else
                    v:SetWide(self:GetWide() / 2)
                end
            else
                v:SetWide(self:GetWide() / 2)
            end
        end
    end

    local function getEntryPanel()
        local fep = self.list:Add("DPanel")
        fep:SetSize(self.list:GetWide() / 2, 35)
        function fep:Paint(_, _)
        end
        return fep
    end

    local function defaultLayout(panel)
        local parent = panel:GetParent()
        local ogPL = panel.PerformLayout
        function PANEL:PerformLayout(w, h)
            ogPL(self, w, h)
            self:SetSize(parent:GetWide() * 0.95, 30)
            self:Center()
        end
    end

    function self:AddTextEntry(placeholder)
        local fep = getEntryPanel()
        local fe = fep:Add("DTextEntry")
        fe:SetPlaceholder(placeholder)
        defaultLayout(fe)
        function fe:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(230, 230, 230))
            self:DrawTextEntryText(color_black, Color(200, 200, 200), color_black)
        end

        self.list:ReArrange()
        return fe
    end

    function self:AddComboBox()
        local ep = getEntryPanel()
        local fe = ep:Add("DComboBox")
        function fe:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(230, 230, 230))
        end

        defaultLayout(fe)
        return fe
    end
end


vgui.Register("WolfForm", PANEL, "DScrollPanel")

