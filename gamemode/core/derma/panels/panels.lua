local function PaintPanel(self, w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

local function PaintFrame(self, w, h)
    if not self.LaidOut then
        local btn = self.btnClose
        if btn and btn:IsValid() then
            btn:SetPos(w - 16, 4)
            btn:SetSize(24, 24)
            btn:SetFont("marlett")
            btn:SetText("r")
            btn:SetTextColor(Color(255, 255, 255))
            btn:PerformLayout()
        end

        self.LaidOut = true
    end

    lia.util.drawBlur(self, 10)
    surface.SetDrawColor(45, 45, 45, 200)
    surface.DrawRect(0, 0, w, h)
end

local BlurredDFrame = {}
function BlurredDFrame:Init()
    self:SetTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:MakePopup()
end

function BlurredDFrame:PerformLayout()
    DFrame.PerformLayout(self)
    if IsValid(self.btnClose) then self.btnClose:SetZPos(1000) end
end

function BlurredDFrame:Paint(w, h)
    PaintFrame(self, w, h)
end

vgui.Register("BlurredDFrame", BlurredDFrame, "DFrame")
local TransparentDFrame = {}
function TransparentDFrame:Init()
    self:SetTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:MakePopup()
end

function TransparentDFrame:PerformLayout()
    DFrame.PerformLayout(self)
    if IsValid(self.btnClose) then self.btnClose:SetZPos(1000) end
end

function TransparentDFrame:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("SemiTransparentDFrame", TransparentDFrame, "DFrame")
local SimplePanel = {}
function SimplePanel:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("SemiTransparentDPanel", SimplePanel, "DPanel")