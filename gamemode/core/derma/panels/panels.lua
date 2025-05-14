local cacheKeys, cache, len = {}, {}, 0
local function PaintPanel(_, w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(1, 1, w - 2, h - 2)
end

local function PaintFrame(pnl, w, h)
    if not pnl.LaidOut then
        local btn = pnl.btnClose
        if btn and btn:IsValid() then
            btn:SetPos(w - 16, 4)
            btn:SetSize(24, 24)
            btn:SetFont("marlett")
            btn:SetText("r")
            btn:SetTextColor(Color(255, 255, 255))
            btn:PerformLayout()
        end

        pnl.LaidOut = true
    end

    lia.util.drawBlur(pnl, 10)
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
timer.Create("derma_convar_fix", 0.5, 0, function()
    if len == 0 then return end
    local name
    for i = 1, len do
        name = cache[i]
        RunConsoleCommand(name, cacheKeys[name])
        cacheKeys[name] = nil
        cache[i] = nil
    end

    len = 0
end)

function Derma_SetCvar_Safe(name, value)
    if not cacheKeys[name] then
        cacheKeys[name] = tostring(value)
        len = len + 1
        cache[len] = name
    else
        timer.Adjust("derma_convar_fix", 0.5)
        cacheKeys[name] = tostring(value)
    end
end

function Derma_Install_Convar_Functions(PANEL)
    function PANEL:SetConVar(strConVar)
        self.m_strConVar = strConVar
    end

    function PANEL:ConVarChanged(strNewValue)
        local cvar = self.m_strConVar
        if not cvar or string.len(cvar) < 2 then return end
        Derma_SetCvar_Safe(cvar, strNewValue)
    end

    function PANEL:ConVarStringThink()
        local cvar = self.m_strConVar
        if not cvar or string.len(cvar) < 2 then return end
        local strValue = GetConVarString(cvar)
        if self.m_strConVarValue == strValue then return end
        self.m_strConVarValue = strValue
        self:SetValue(strValue)
    end

    function PANEL:ConVarNumberThink()
        local cvar = self.m_strConVar
        if not cvar or string.len(cvar) < 2 then return end
        local numValue = GetConVarNumber(cvar)
        if numValue ~= numValue then return end
        if self.m_strConVarValue == numValue then return end
        self.m_strConVarValue = numValue
        self:SetValue(numValue)
    end
end