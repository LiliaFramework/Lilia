local PANEL = {}
function PANEL:Init()
  self.btnClose:Hide()
  self.close = self:Add("DButton")
  self.close:SetSize(50, 25)
  self.close:SetText("x")
  self.close:SetColor(color_white)
  function self.close.PerformLayout(this, w)
    this:SetPos(self:GetWide() - w)
  end

  function self.close:Paint(w, h)
    if self:IsHovered() then
      draw.RoundedBoxEx(4, 0, 0, w, h, Color(235, 85, 85), false, true)
    else
      draw.RoundedBoxEx(4, 0, 0, w, h, Color(225, 75, 75), false, true)
    end
  end

  function self.close.DoClick()
    self:Remove()
  end

  self.lblTitle:Hide()
  self.title = self:Add("DLabel")
  self.title:SetFont("WB_Small")
  self.title:SetColor(color_white)
  function self.title.PerformLayout(this, _, h)
    this:SetText(self.lblTitle:GetText())
    this:SizeToContents()
    this:SetPos(0, 25 / 2 - h / 2)
    this:CenterHorizontal()
  end

  self:SetAlpha(0)
  timer.Simple(0.05, function()
    local x, y = self:GetPos()
    self:SetPos(x + 50, y + 50)
    self:MoveTo(x, y, 0.3, 0, -1)
    self:AlphaTo(255, 0.3, 0.15)
  end)
end

function PANEL:GetWorkPanel()
  local wp = self:Add("DPanel")
  wp:SetSize(self:GetWide(), self:GetTall() - self.close:GetTall())
  wp:SetPos(0, self.close:GetTall())
  wp.noPaint = false
  function wp:Paint(w, h)
    if not self.noPaint then
      surface.SetDrawColor(53, 53, 53, 200)
      surface.DrawRect(0, 0, w, h)
    end
  end
  return wp
end

function PANEL:OnKeyCodePressed(key)
  if key == KEY_F1 then self:Remove() end
end

function PANEL:Paint(w, h)
  lia.util.drawBlur(self, 4)
  draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 230))
end

vgui.Register("WolfFrame", PANEL, "DFrame")
