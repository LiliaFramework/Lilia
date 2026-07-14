local PANEL = {}
function PANEL:Init()
    local vbar = self:GetVBar()
    vbar:SetWide(6)
    vbar:SetHideButtons(true)
    vbar.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 8)
        surface.DrawRect(0, 0, w, h)
        self.pnlCanvas:DockPadding(0, 0, m_bNoSizing and 0 or 6, 0)
    end

    vbar.btnGrip.Paint = function(_, w, h)
        local theme = lia.color.theme or {}
        local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
        lia.derma.rect(0, 0, w, h):Rad(3):Color(accent):Shape(lia.derma.SHAPE_IOS):Draw()
    end
end

vgui.Register("liaScrollPanel", PANEL, "DScrollPanel")
