VoicePanels = {}
local ICON_MAP = {
    [L("whispering")] = "whispertalk.png",
    [L("yelling")] = "yelltalk.png",
    [L("talking")] = "normaltalk.png"
}

local PANEL = {}
function PANEL:Init()
    self:SetSize(280, 40)
    self:DockPadding(4, 4, 4, 4)
    self:DockMargin(2, 2, 2, 2)
    self:Dock(BOTTOM)
    self.Icon = vgui.Create("DImage", self)
    self.Icon:Dock(LEFT)
    self.Icon:DockMargin(8, 0, 8, 0)
    self.Icon:SetSize(32, 32)
    self.LabelName = vgui.Create("DLabel", self)
    self.LabelName:Dock(FILL)
    self.LabelName:SetFont("LiliaFont.20")
    self.LabelName:SetTextColor(color_white)
end

function PANEL:Setup(client)
    self.client = client
    self.name = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client) or client:Nick()
    self.LabelName:SetText(self.name)
    self:UpdateIcon()
    self:SetAlpha(255)
end

function PANEL:UpdateIcon()
    local vt = self.client:getNetVar("VoiceType", L("talking"))
    local img = ICON_MAP[vt] or "normaltalk.png"
    self.Icon:SetImage(img)
end

function PANEL:Paint(w, h)
    if not IsValid(self.client) then return end
    local themeAccent = lia.color.theme.theme
    -- Exact replication of adminstick drawBoxWithText styling
    local backgroundColor = Color(0, 0, 0, 150)
    local borderColor = themeAccent
    local borderRadius = 8
    local borderThickness = 2
    -- Draw background box like adminstick
    lia.derma.rect(0, 0, w, h):Color(backgroundColor):Rad(borderRadius):Draw()
    -- Draw border like adminstick
    if borderThickness > 0 then lia.derma.rect(0, 0, w, h):Color(borderColor):Rad(borderRadius):Outline(borderThickness):Draw() end
end

function PANEL:Think()
    if not IsValid(self.client) then return end
    if self.LabelName:GetText() ~= self.name then self.LabelName:SetText(self.name) end
    self:UpdateIcon()
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

    self:SetAlpha(255 - 255 * delta * 2)
end

vgui.Register("liaVoicePanel", PANEL, "DPanel")
local function CreateVoicePanelList()
    if IsValid(g_VoicePanelList) then g_VoicePanelList:Remove() end
    for _, pnl in pairs(VoicePanels) do
        if IsValid(pnl) then pnl:Remove() end
    end

    g_VoicePanelList = vgui.Create("DPanel")
    g_VoicePanelList:ParentToHUD()
    g_VoicePanelList:SetSize(270, ScrH() - 200)
    g_VoicePanelList:SetPos(ScrW() - 320, 100)
    g_VoicePanelList:SetPaintBackground(false)
end

timer.Create("VoiceClean", 1, 0, function()
    for client in pairs(VoicePanels) do
        if not IsValid(client) then hook.Run("PlayerEndVoice", client) end
    end
end)

hook.Add("InitPostEntity", "liaVoiceInitPostEntity", CreateVoicePanelList)
hook.Add("OnReloaded", "liaVoiceOnReloaded", CreateVoicePanelList)
