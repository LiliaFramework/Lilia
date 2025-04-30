local MODULE = MODULE
local ScrH = ScrH()
ActionInteractionMenu = nil
InteractionMenu = nil
function MODULE:OpenPIM()
    if IsValid(ActionInteractionMenu) then
        ActionInteractionMenu:Close()
        ActionInteractionMenu = nil
    end

    if IsValid(InteractionMenu) then
        InteractionMenu:Close()
        InteractionMenu = nil
    end

    local client = LocalPlayer()
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 120)
    frame:SetPos(0, ScrH / 2 - frame:GetTall() / 2)
    frame:CenterHorizontal(0.7)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.05)
    function frame:Paint(w, h)
        lia.util.drawBlur(self, 4)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
    end

    function frame:Think()
        local interactionKey = lia.keybind.get("Interaction Menu", KEY_TAB)
        if not input.IsKeyDown(interactionKey) then self:Close() end
    end

    timer.Remove("PIM_Frame_Timer")
    timer.Create("PIM_Frame_Timer", 30, 1, function() if frame and IsValid(frame) then frame:Close() end end)
    frame.title = frame:Add("DLabel")
    frame.title:SetText("Player Interactions")
    frame.title:SetFont("liaSmallFont")
    frame.title:SetColor(color_white)
    frame.title:SetSize(frame:GetWide(), 25)
    frame.title:SetContentAlignment(5)
    frame.title:SetPos(0, 25 / 2 - frame.title:GetTall() / 2)
    frame.title:CenterHorizontal()
    function frame.title:PaintOver(w, h)
        surface.SetDrawColor(Color(60, 60, 60))
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    frame.scroll = frame:Add("DScrollPanel")
    frame.scroll:SetSize(frame:GetWide(), 25 * table.Count(self.Options))
    frame.scroll:SetPos(0, 25)
    frame.list = frame.scroll:Add("DIconLayout")
    frame.list:SetSize(frame.scroll:GetSize())
    local visibleOptionsCount = 0
    local traceEnt = client:getTracedEntity()
    for name, opt in pairs(self.Options) do
        if opt.shouldShow(client, traceEnt) and traceEnt:IsPlayer() and self:CheckDistance(client, traceEnt) then
            visibleOptionsCount = visibleOptionsCount + 1
            local p = frame.list:Add("DButton")
            p:SetText(name)
            p:SetFont("liaSmallFont")
            p:SetColor(color_white)
            p:SetSize(frame.list:GetWide(), 25)
            function p:Paint(w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
                else
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 75))
                end
            end

            function p:DoClick()
                frame:AlphaTo(0, 0.05, 0, function() if frame and IsValid(frame) then frame:Close() end end)
                opt.onRun(client, traceEnt)
                if opt.runServer then
                    net.Start("PIMRunOption")
                    net.WriteString(name)
                    net.SendToServer()
                end
            end
        end
    end

    local jh = 25 * visibleOptionsCount
    frame.scroll:SetTall(jh)
    frame:SetTall(jh + 45)
    frame:CenterVertical()
    InteractionMenu = frame
end

function MODULE:OpenLocalPIM()
    if IsValid(InteractionMenu) then
        InteractionMenu:Close()
        InteractionMenu = nil
    end

    if IsValid(ActionInteractionMenu) then
        ActionInteractionMenu:Close()
        ActionInteractionMenu = nil
    end

    local client = LocalPlayer()
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 120)
    frame:SetPos(0, ScrH / 2 - frame:GetTall() / 2)
    frame:CenterHorizontal(0.7)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.05)
    function frame:Paint(w, h)
        lia.util.drawBlur(self, 4)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
    end

    function frame:Think()
        local personalKey = lia.keybind.get("Personal Actions", KEY_G)
        if not input.IsKeyDown(personalKey) then self:Close() end
    end

    timer.Remove("PIM_Frame_Timer")
    timer.Create("PIM_Frame_Timer", 30, 1, function() if frame and IsValid(frame) then frame:Close() end end)
    frame.title = frame:Add("DLabel")
    frame.title:SetText("Actions Menu")
    frame.title:SetFont("liaSmallFont")
    frame.title:SetColor(color_white)
    frame.title:SetSize(frame:GetWide(), 25)
    frame.title:SetContentAlignment(5)
    frame.title:SetPos(0, 25 / 2 - frame.title:GetTall() / 2)
    frame.title:CenterHorizontal()
    function frame.title:PaintOver(w, h)
        surface.SetDrawColor(Color(60, 60, 60))
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    frame.scroll = frame:Add("DScrollPanel")
    frame.scroll:SetSize(frame:GetWide(), 25 * table.Count(self.SelfOptions))
    frame.scroll:SetPos(0, 25)
    frame.list = frame.scroll:Add("DIconLayout")
    frame.list:SetSize(frame.scroll:GetSize())
    local visibleOptionsCount = 0
    for name, opt in pairs(self.SelfOptions) do
        if opt.shouldShow(client) then
            visibleOptionsCount = visibleOptionsCount + 1
            local p = frame.list:Add("DButton")
            p:SetText(name)
            p:SetFont("liaSmallFont")
            p:SetColor(color_white)
            p:SetSize(frame.list:GetWide(), 25)
            function p:Paint(w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
                else
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 75))
                end
            end

            function p:DoClick()
                frame:AlphaTo(0, 0.05, 0, function() if frame and IsValid(frame) then frame:Close() end end)
                opt.onRun(client)
                if opt.runServer then
                    net.Start("PIMRunLocalOption")
                    net.WriteString(name)
                    net.SendToServer()
                end
            end
        end
    end

    local jh = 25 * visibleOptionsCount
    frame.scroll:SetTall(jh)
    frame:SetTall(jh + 45)
    frame:CenterVertical()
    ActionInteractionMenu = frame
end

lia.keybind.add(KEY_TAB, "Interaction Menu", function()
    local client = LocalPlayer()
    if client:getChar() and hook.Run("CheckInteractionPossibilities") then MODULE:OpenPIM() end
end)

lia.keybind.add(KEY_G, "Personal Actions", function() MODULE:OpenLocalPIM() end)