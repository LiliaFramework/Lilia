local VoicePanels = {}
local function ClearVoicePanels()
    for client, pnl in pairs(VoicePanels) do
        if IsValid(pnl) then pnl:Remove() end
        VoicePanels[client] = nil
    end
end

local function GetThemeAccent()
    local theme = lia.color and lia.color.theme or {}
    return theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
end

local function GetVoiceColor(voiceType)
    if voiceType == "yelling" then return Color(235, 130, 38) end
    if voiceType == "whispering" then return Color(190, 130, 245) end
    return GetThemeAccent()
end

local function GetVoiceIndicatorText(voiceType)
    return L("youAre") .. " " .. L(voiceType or "talking")
end

local function DrawGlassPanel(x, y, w, h, radius, background, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(background):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
end

local function DrawVoiceLines(x, y, voiceType, level, alpha)
    local color = GetVoiceColor(voiceType)
    local bars = 6
    local barW = 5
    local gap = 5
    local maxH = 28
    local active = math.Clamp(math.ceil((level or 0) * bars), 1, bars)
    for i = 1, bars do
        local frac = i / bars
        local barH = math.floor(8 + maxH * frac)
        local barX = x + (i - 1) * (barW + gap)
        local barY = y + math.floor((maxH + 8 - barH) * 0.5)
        local drawColor = i <= active and Color(color.r, color.g, color.b, alpha or 230) or Color(120, 145, 145, 45)
        lia.derma.rect(barX, barY, barW, barH):Rad(3):Color(drawColor):Shape(lia.derma.SHAPE_IOS):Draw()
    end
end

local PANEL = {}
function PANEL:Init()
    self:SetSize(310, 58)
    self:DockPadding(18, 8, 18, 8)
    self:DockMargin(0, 0, 0, 8)
    self:Dock(BOTTOM)
    self.cachedVoiceType = "talking"
    self.voiceLevel = 0
    self.LabelName = vgui.Create("DLabel", self)
    self.LabelName:SetFont("LiliaFont.22")
    self.LabelName:SetTextColor(Color(242, 247, 247))
    self.LabelName:SetContentAlignment(4)
    self.LabelMode = vgui.Create("DLabel", self)
    self.LabelMode:SetFont("LiliaFont.17")
    self.LabelMode:SetContentAlignment(4)
end

function PANEL:Setup(client)
    self.client = client
    self.name = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client) or client:Nick()
    self.cachedVoiceType = IsValid(client) and client:getLocalVar("VoiceType", "talking") or "talking"
    self:SetAlpha(255)
    self:UpdateText()
    self:UpdateTooltip()
end

function PANEL:UpdateText()
    local voiceType = self.cachedVoiceType or "talking"
    self.LabelName:SetText(self.name or L("unknown"))
    self.LabelMode:SetText(L(voiceType))
    self.LabelMode:SetTextColor(GetVoiceColor(voiceType))
end

function PANEL:UpdateTooltip()
    if not IsValid(self.client) then return end
    local voiceType = self.cachedVoiceType or "talking"
    local displayName = self.name or L("unknown")
    local voiceRanges = {
        whispering = lia.config.get("WhisperRange", 70),
        talking = lia.config.get("TalkRange", 280),
        yelling = lia.config.get("YellRange", 840)
    }

    local lines = {}
    lines[#lines + 1] = "<font=LiliaFont.16b>" .. displayName .. "</font>"
    lines[#lines + 1] = "<font=LiliaFont.16>" .. GetVoiceIndicatorText(voiceType) .. "</font>"
    local range = voiceRanges[voiceType]
    if range then lines[#lines + 1] = "<font=LiliaFont.16>" .. L("voiceRange") .. ": " .. range .. " units</font>" end
    self:SetTooltip(table.concat(lines, "\n"))
end

function PANEL:PerformLayout(w, h)
    self.LabelName:SetPos(18, 7)
    self.LabelName:SetSize(w - 112, 25)
    self.LabelMode:SetPos(18, 31)
    self.LabelMode:SetSize(w - 112, 20)
end

function PANEL:Paint(w, h)
    if not IsValid(self.client) then return end
    local accent = GetVoiceColor(self.cachedVoiceType)
    local baseAccent = GetThemeAccent()
    lia.util.drawBlur(self, 4, 2)
    DrawGlassPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(baseAccent.r, baseAccent.g, baseAccent.b, 95))
    surface.SetDrawColor(accent.r, accent.g, accent.b, 230)
    surface.DrawRect(0, 9, 3, h - 18)
    surface.SetDrawColor(255, 255, 255, 7)
    surface.DrawRect(1, 1, w - 2, 1)
    DrawVoiceLines(w - 78, 12, self.cachedVoiceType, self.voiceLevel, 230)
end

function PANEL:Think()
    if not IsValid(self.client) then return end
    local name = hook.Run("ShouldAllowScoreboardOverride", self.client, "name") and hook.Run("GetDisplayedName", self.client) or self.client:Nick()
    if self.name ~= name then
        self.name = name
        self:UpdateText()
    end

    local targetLevel = 1
    if isfunction(self.client.VoiceVolume) then targetLevel = math.Clamp(self.client:VoiceVolume() or 0, 0, 1) end
    if targetLevel <= 0 and self.client:IsSpeaking() then targetLevel = 0.35 end
    self.voiceLevel = Lerp(FrameTime() * 12, self.voiceLevel or 0, targetLevel)
    if not self.nextVoiceCheck or CurTime() >= self.nextVoiceCheck then
        self.nextVoiceCheck = CurTime() + 0.1
        local voiceType = self.client:getLocalVar("VoiceType", "talking")
        if voiceType ~= self.cachedVoiceType then
            self.cachedVoiceType = voiceType
            self:UpdateText()
            self:UpdateTooltip()
        end
    end

    if self.fadeAnim then self.fadeAnim:Run() end
end

function PANEL:FadeOut(anim, delta)
    if anim.Finished then
        if IsValid(VoicePanels[self.client]) then
            VoicePanels[self.client]:Remove()
            VoicePanels[self.client] = nil
        end
        return
    end

    self:SetAlpha(math.Clamp(255 - 255 * delta, 0, 255))
end

vgui.Register("liaVoicePanel", PANEL, "DPanel")
local function CreateVoicePanelList()
    ClearVoicePanels()
    if IsValid(g_VoicePanelList) then g_VoicePanelList:Remove() end
    g_VoicePanelList = vgui.Create("DPanel")
    g_VoicePanelList:ParentToHUD()
    g_VoicePanelList:SetSize(318, ScrH() - 130)
    g_VoicePanelList:SetPos(ScrW() - 344, 90)
    g_VoicePanelList:SetPaintBackground(false)
end

timer.Remove("VoiceClean")
timer.Create("VoiceClean", 1, 0, function()
    for client in pairs(VoicePanels) do
        if not IsValid(client) then hook.Run("PlayerEndVoice", client) end
    end
end)

hook.Add("InitPostEntity", "liaVoiceInitPostEntity", CreateVoicePanelList)
hook.Add("OnReloaded", "liaVoiceOnReloaded", CreateVoicePanelList)
hook.Add("OnScreenSizeChanged", "liaVoiceOnScreenSizeChanged", function()
    timer.Simple(0, function()
        if not IsValid(g_VoicePanelList) then return end
        g_VoicePanelList:SetSize(318, ScrH() - 130)
        g_VoicePanelList:SetPos(ScrW() - 344, 90)
    end)
end)

function GM:PlayerStartVoice(client)
    if not IsValid(g_VoicePanelList) or not lia.config.get("IsVoiceEnabled", true) then return end
    hook.Run("PlayerEndVoice", client)
    local pnl = VoicePanels[client]
    if IsValid(pnl) then
        if pnl.fadeAnim then
            pnl.fadeAnim:Stop()
            pnl.fadeAnim = nil
        end

        pnl:SetAlpha(255)
        return
    end

    if not IsValid(client) then return end
    pnl = g_VoicePanelList:Add("liaVoicePanel")
    pnl:Setup(client)
    VoicePanels[client] = pnl
end

function GM:PlayerEndVoice(client)
    local pnl = VoicePanels[client]
    if IsValid(pnl) and not pnl.fadeAnim then
        pnl.fadeAnim = Derma_Anim("FadeOut", pnl, pnl.FadeOut)
        pnl.fadeAnim:Start(0.35)
    end
end

function GM:VoiceToggled(enabled)
    if not IsValid(g_VoicePanelList) then return end
    if not enabled then
        for client, pnl in pairs(VoicePanels) do
            if IsValid(pnl) then pnl:Remove() end
            VoicePanels[client] = nil
        end
    end
end
