local PANEL = {}

function PANEL:GetList(sx, sy)
    sx = sx or 1
    sy = sy or 1
    self.list = self:Add("DIconLayout")
    self.list:SetPos(sx, sy)
    self.list:SetSpaceX(sx)
    self.list:SetSpaceY(sy)
    self.list:SetWide(self:GetWide() - sx * 2, self:GetTall() - sy * 2)

    function self.list:AddTitleBar(txt)
        local title = self:Add("DLabel")
        title:SetText(txt)
        title:SetFont("WB_Small")
        title:SetColor(color_white)
        title:SetSize(self:GetWide(), 30)
        title:SetContentAlignment(5)
        title.noRemove = true

        function title:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40))
        end

        return title
    end

    function self.list:RemoveChildren()
        for k, v in pairs(self:GetChildren()) do
            if not v.noRemove then
                v:Remove()
            end
        end
    end

    return self.list
end

vgui.Register("WScrollList", PANEL, "DScrollPanel")
--TODO: Add scrollbar styling