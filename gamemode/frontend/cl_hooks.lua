--------------------------------------------------------------------------------------------------------
hook.Add(
    "TooltipInitialize",
    "liaItemTooltip",
    function(self, panel)
        if panel.liaToolTip or panel.itemID then
            self.markupObject = lia.markup.parse(self:GetText(), ScrW() * .15)
            self:SetText("")
            self:SetWide(math.max(ScrW() * .15, 200) + 12)
            self:SetHeight(self.markupObject:getHeight() + 12)
            self:SetAlpha(0)
            self:AlphaTo(255, 0.2, 0)
            self.isItemTooltip = true
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "TooltipPaint",
    "liaItemTooltip",
    function(self, w, h)
        if self.isItemTooltip then
            lia.util.drawBlur(self, 2, 2)
            surface.SetDrawColor(0, 0, 0, 230)
            surface.DrawRect(0, 0, w, h)
            if self.markupObject then
                self.markupObject:draw(12 * 0.5, 12 * 0.5 + 2)
            end

            return true
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "TooltipLayout",
    "liaItemTooltip",
    function(self)
        if self.isItemTooltip then return true end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "StartChat",
    "StartChatTyping",
    function()
        net.Start("liaTypeStatus")
        net.WriteBool(false)
        net.SendToServer()
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "FinishChat",
    "FinishChatTyping",
    function()
        net.Start("liaTypeStatus")
        net.WriteBool(true)
        net.SendToServer()
    end
)
--------------------------------------------------------------------------------------------------------
concommand.Add(
    "vgui_cleanup",
    function()
        for k, v in pairs(vgui.GetWorldPanel():GetChildren()) do
            if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then
                v:Remove()
            end
        end
    end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)"
)
--------------------------------------------------------------------------------------------------------