local PANEL = {}
function PANEL:Init()
    local vbar = self:GetVBar()
    vbar:SetWide(6)
    vbar:SetHideButtons(true)
    vbar.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(32):Color(lia.color.theme.focus_panel):Draw()
        self.pnlCanvas:DockPadding(0, 0, m_bNoSizing and 0 or 6, 0)
    end

    vbar.btnGrip._ShadowLerp = 0
    vbar.btnGrip.Paint = function(s, w, h)
        s._ShadowLerp = Lerp(FrameTime() * 10, s._ShadowLerp, vbar.Dragging and 7 or 0)
        lia.derma.rect(0, 0, w, h):Rad(32):Color(Color(25, 28, 35, 170)):Shadow(s._ShadowLerp, 20):Draw()
        lia.derma.rect(0, 0, w, h):Rad(32):Color(Color(25, 28, 35, 170)):Draw()
        lia.derma.rect(0, 0, w, h):Rad(32):Color(ColorAlpha(lia.color.theme.theme or Color(116, 185, 255), 160)):Outline(1):Draw()
    end
end

vgui.Register("liaScrollPanel", PANEL, "DScrollPanel")
