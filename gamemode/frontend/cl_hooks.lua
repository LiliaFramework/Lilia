--------------------------------------------------------------------------------------------------------
local data = {}
local offset1, offset2, offset3, alpha, y
lia.config.VersionEnabled = lia.config.VersionEnabled or false
lia.config.version = lia.config.version or "1.0"
--------------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "FrontendHooks", function()
    local ply = LocalPlayer()
    local ourPos = ply:GetPos()
    local time = RealTime() * 5
    data.start = ply:EyePos()
    data.filter = ply
    lia.bar.drawAll()

    if lia.config.VersionEnabled and lia.config.version then
        local w, h = 45, 45
        surface.SetFont("liaSmallChatFont")
        surface.SetTextPos(5, ScrH() - 20, w, h)
        surface.DrawText("Server Current Version: " .. lia.config.version)
    end

    if lia.config.BranchWarning and BRANCH ~= "x86-64" then
        draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    for k, v in ipairs(player.GetAll()) do
        if v ~= ply and v:getNetVar("typing") and v:GetMoveType() == MOVETYPE_WALK then
            data.endpos = v:EyePos()
            if util.TraceLine(data).Entity ~= v then continue end
            local position = v:GetPos()
            alpha = (1 - (ourPos:DistToSqr(position) / 65536)) * 255
            if alpha <= 0 then continue end
            local screen = (position + (v:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80))):ToScreen()
            offset1 = math.sin(time + 2) * alpha
            offset2 = math.sin(time + 1) * alpha
            offset3 = math.sin(time) * alpha
            y = screen.y - 20
            lia.util.drawText("•", screen.x - 8, y, ColorAlpha(Color(250, 250, 250), offset1), 1, 1, "liaChatFont", offset1)
            lia.util.drawText("•", screen.x, y, ColorAlpha(Color(250, 250, 250), offset2), 1, 1, "liaChatFont", offset2)
            lia.util.drawText("•", screen.x + 8, y, ColorAlpha(Color(250, 250, 250), offset3), 1, 1, "liaChatFont", offset3)
        end
    end
end)

--------------------------------------------------------------------------------------------------------
hook.Add("TooltipInitialize", "liaItemTooltip", function(self, panel)
    if panel.liaToolTip or panel.itemID then
        self.markupObject = lia.markup.parse(self:GetText(), ScrW() * .15)
        self:SetText("")
        self:SetWide(math.max(ScrW() * .15, 200) + 12)
        self:SetHeight(self.markupObject:getHeight() + 12)
        self:SetAlpha(0)
        self:AlphaTo(255, 0.2, 0)
        self.isItemTooltip = true
    end
end)

--------------------------------------------------------------------------------------------------------
hook.Add("TooltipPaint", "liaItemTooltip", function(self, w, h)
    if self.isItemTooltip then
        lia.util.drawBlur(self, 2, 2)
        surface.SetDrawColor(0, 0, 0, 230)
        surface.DrawRect(0, 0, w, h)

        if self.markupObject then
            self.markupObject:draw(12 * 0.5, 12 * 0.5 + 2)
        end

        return true
    end
end)

--------------------------------------------------------------------------------------------------------
hook.Add("TooltipLayout", "liaItemTooltip", function(self)
    if self.isItemTooltip then return true end
end)

--------------------------------------------------------------------------------------------------------
hook.Add("StartChat", "StartChatTyping", function()
    net.Start("liaTypeStatus")
    net.WriteBool(false)
    net.SendToServer()
end)

--------------------------------------------------------------------------------------------------------
hook.Add("FinishChat", "FinishChatTyping", function()
    net.Start("liaTypeStatus")
    net.WriteBool(true)
    net.SendToServer()
end)

--------------------------------------------------------------------------------------------------------
hook.Add("ShowHelp", "DisableShowHelp", function()
    return false
end)

--------------------------------------------------------------------------------------------------------
hook.Add("BuildHelpMenu", "liaCreditsList", function(tabs)
    tabs["Credits"] = function()
        if helpPanel then
            local credits = helpPanel:Add("liaCreditsList")
            credits:Dock(TOP)
            credits:DockMargin(ScrW * 0.1, 0, ScrW * 0.1, 0)
        end

        return ""
    end
end)
--------------------------------------------------------------------------------------------------------