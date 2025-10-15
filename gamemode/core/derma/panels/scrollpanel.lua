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
        lia.derma.rect(0, 0, w, h):Rad(32):Color(lia.color.theme.theme):Shadow(s._ShadowLerp, 20):Draw()
        lia.derma.rect(0, 0, w, h):Rad(32):Color(lia.color.theme.theme):Draw()
    end
end

vgui.Register("liaScrollPanel", PANEL, "DScrollPanel")