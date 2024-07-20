local PANEL = {}
local waits = {}
local w, h = ScrW(), ScrH()
function PANEL:Init()
    self:SetSize(w, h)
    self:Center()
    self:MoveToFront()
    self:SetAlpha(0)
    self:AlphaTo(255, 1.2)
    local function wait(s, f)
        table.insert(waits, {SysTime() + s, function() if IsValid(self) then f() end end})
    end

    wait(3.33, function()
        http.Fetch("http://api.steampowered.com/ISteamApps/GetServersAtAddress/v0001?addr=" .. game.GetIPAddress(), function(json)
            if not IsValid(self) then return end
            local data = util.JSONToTable(json)
            if not data["response"]["servers"] or not data["response"]["servers"][0] then
                self.ServerIsOff = true
                self:DoLamar()
            else
                self.ServerIsOff = false
            end
        end, function()
            if not IsValid(self) then return end
            self.ServerIsOff = false
        end)
    end)
end

function PANEL:DoLamar()
    local function wait(s, f)
        table.insert(waits, {SysTime() + s, function() if IsValid(self) then f() end end})
    end

    local function doAnim()
        self.lamar = vgui.Create("liaModelPanel", self)
        self.lamar:Dock(FILL)
        self.lamar:SetFOV(90)
        self.lamar:SetModel("models/lamarr.mdl")
        self.lamar:SetAnimated(true)
        function self.lamar:LayoutEntity(entity)
            entity:FrameAdvance()
            return
        end

        local badcarb = self.lamar:GetEntity():LookupSequence("lamarr_crow")
        self.lamar:GetEntity():ResetSequence(badcarb)
        local pos = Vector(120, 50, 50)
        self.lamar:SetCamPos(pos)
        self.lamar:SetLookAt(pos + Vector(-10, -70, -10))
    end

    local function doPostText()
        self.backsoon = vgui.Create("DLabel", self)
        self.backsoon:SetText("We'll be back soon!")
        self.backsoon:SetFont("liaTitleFont")
        self.backsoon:SizeToContents()
        self.backsoon:Center()
        self.backsoon:SetAlpha(0)
        self.backsoon:AlphaTo(200, 8)
        timer.Simple(8, function() if IsValid(self) then self.backsoon:AlphaTo(0, 10) end end)
    end

    local r = 1
    wait(r, function() wait(2.5, doPostText) end)
end

function PANEL:Think()
    self:MoveToFront()
    for v, k in pairs(waits) do
        if k ~= nil and k[1] < SysTime() then
            k[2]()
            waits[v] = nil
        end
    end
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 200))
end

function PANEL:PaintOver()
    draw.DrawText(":( Connection lost", "liaTitleFont", w / 2, 10, color_white, TEXT_ALIGN_CENTER)
    if self.ServerIsOff == nil then
        draw.DrawText("Checking server status...", "liaBigFont", w / 2, 130, color_white, TEXT_ALIGN_CENTER)
        return
    end

    if self.ServerIsOff then
        draw.DrawText("The server has gone offline. Try reconnecting in a few minutes.", "liaBigFont", w / 2, 130, color_white, TEXT_ALIGN_CENTER)
    else
        draw.DrawText("You've lost connection to the server. Try reconnecting in a few minutes.", "liaBigFont", w / 2, 130, color_white, TEXT_ALIGN_CENTER)
        draw.DrawText("Check your router or internet connection.", "liaBigFont", w / 2, h + 160, color_white, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("liaCrashScreen", PANEL, "DPanel")