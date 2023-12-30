------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local PANEL = {}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:SetTitle(L("thirdpersonConfig"))
    self:SetSize(300, 140)
    self:Center()
    self:MakePopup()
    self.list = self:Add("DPanel")
    self.list:Dock(FILL)
    self.list:DockMargin(0, 0, 0, 0)
    local cfgheight = self.list:Add("DNumSlider")
    cfgheight:Dock(TOP)
    cfgheight:SetText("Height") -- Set the text above the slider
    cfgheight:SetMin(0) -- Set the minimum number you can slide to
    cfgheight:SetMax(30) -- Set the maximum number you can slide to
    cfgheight:SetDecimals(0) -- Decimal places - zero for whole number
    cfgheight:SetConVar("lia_tp_vertical") -- Changes the ConVar when you slide
    cfgheight:DockMargin(10, 0, 0, 5)
    local cfghorizontal = self.list:Add("DNumSlider")
    cfghorizontal:Dock(TOP)
    cfghorizontal:SetText("Horizontal") -- Set the text above the slider
    cfghorizontal:SetMin(-30) -- Set the minimum number you can slide to
    cfghorizontal:SetMax(30) -- Set the maximum number you can slide to
    cfghorizontal:SetDecimals(0) -- Decimal places - zero for whole number
    cfghorizontal:SetConVar("lia_tp_horizontal") -- Changes the ConVar when you slide
    cfghorizontal:DockMargin(10, 0, 0, 5)
    local cfgdist = self.list:Add("DNumSlider")
    cfgdist:Dock(TOP)
    cfgdist:SetText("Distance") -- Set the text above the slider
    cfgdist:SetMin(0) -- Set the minimum number you can slide to
    cfgdist:SetMax(100) -- Set the maximum number you can slide to
    cfgdist:SetDecimals(0) -- Decimal places - zero for whole number
    cfgdist:SetConVar("lia_tp_distance") -- Changes the ConVar when you slide
    cfgdist:DockMargin(10, 0, 0, 5)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vgui.Register("liaTPConfig", PANEL, "DFrame")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------