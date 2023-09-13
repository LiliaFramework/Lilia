--------------------------------------------------------------------------------------------------------
local PANEL = {}
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self.number = 0
    self:SetWide(70)
    local up = self:Add("DButton")
    up:SetFont("Marlett")
    up:SetText("t")
    up:Dock(TOP)
    up:DockMargin(2, 2, 2, 2)
    up.DoClick = function(this)
        self.number = (self.number + 1) % 10
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    local down = self:Add("DButton")
    down:SetFont("Marlett")
    down:SetText("u")
    down:Dock(BOTTOM)
    down:DockMargin(2, 2, 2, 2)
    down.DoClick = function(this)
        self.number = (self.number - 1) % 10
        surface.PlaySound("buttons/lightswitch2.wav")
    end

    local number = self:Add("Panel")
    number:Dock(FILL)
    number.Paint = function(this, w, h)
        draw.SimpleText(self.number, "liaDialFont", w / 2, h / 2, color_white, 1, 1)
    end
end
--------------------------------------------------------------------------------------------------------
vgui.Register("liaRadioDial", PANEL, "DPanel")
--------------------------------------------------------------------------------------------------------
PANEL = {}
--------------------------------------------------------------------------------------------------------
function PANEL:Init()
    self:SetTitle(L("radioFreq"))
    self:SetSize(330, 220)
    self:Center()
    self:MakePopup()
    self.submit = self:Add("DButton")
    self.submit:Dock(BOTTOM)
    self.submit:DockMargin(0, 5, 0, 0)
    self.submit:SetTall(25)
    self.submit:SetText(L("radioSubmit"))
    self.submit.DoClick = function()
        local str = ""
        for i = 1, 5 do
            if i ~= 4 then
                str = str .. tostring(self.dial[i].number or 0)
            else
                str = str .. "."
            end
        end

        netstream.Start("radioAdjust", str, self.itemID)
        self:Close()
    end

    self.dial = {}
    for i = 1, 5 do
        if i ~= 4 then
            self.dial[i] = self:Add("liaRadioDial")
            self.dial[i]:Dock(LEFT)
            if i ~= 3 then
                self.dial[i]:DockMargin(0, 0, 5, 0)
            end
        else
            local dot = self:Add("Panel")
            dot:Dock(LEFT)
            dot:SetWide(30)
            dot.Paint = function(this, w, h)
                draw.SimpleText(".", "liaDialFont", w / 2, h - 10, color_white, 1, 4)
            end
        end
    end
end
--------------------------------------------------------------------------------------------------------
function PANEL:Think()
    self:MoveToFront()
end
--------------------------------------------------------------------------------------------------------
vgui.Register("liaRadioMenu", PANEL, "DFrame")
--------------------------------------------------------------------------------------------------------