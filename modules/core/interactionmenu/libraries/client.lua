local MODULE = MODULE
ActionInteractionMenu = nil
InteractionMenu = nil
function MODULE:OpenInteractionMenu()
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
    frame:SetPos(0, ScrH() / 2 - frame:GetTall() / 2)
    frame:CenterHorizontal(0.7)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.05)
    function frame:Think()
        local key = lia.keybind.get("Interaction Menu", KEY_TAB)
        if not input.IsKeyDown(key) then self:Close() end
    end

    timer.Remove("InteractionMenu_Frame_Timer")
    timer.Create("InteractionMenu_Frame_Timer", 30, 1, function() if frame and IsValid(frame) then frame:Close() end end)
    frame.title = frame:Add("DLabel")
    frame.title:SetText("Player Interactions")
    frame.title:SetFont("liaSmallFont")
    frame.title:SetColor(color_white)
    frame.title:SetSize(frame:GetWide(), 25)
    frame.title:SetContentAlignment(5)
    frame.title:SetPos(0, 12)
    frame.title:CenterHorizontal()
    frame.scroll = frame:Add("DScrollPanel")
    frame.scroll:SetSize(frame:GetWide(), 25 * table.Count(self.Options))
    frame.scroll:SetPos(0, 25)
    frame.list = frame.scroll:Add("DIconLayout")
    frame.list:SetSize(frame.scroll:GetSize())
    local count = 0
    local ent = client:getTracedEntity()
    for name, opt in pairs(self.Options) do
        if IsValid(ent) and ent:IsPlayer() and opt.shouldShow(client, ent) and self:CheckDistance(client, ent) then
            count = count + 1
            local btn = frame.list:Add("DButton")
            btn:SetText(name)
            btn:SetFont("liaSmallFont")
            btn:SetColor(color_white)
            btn:SetSize(frame.list:GetWide(), 25)
            function btn:Paint(w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
                else
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 75))
                end
            end

            function btn:DoClick()
                frame:AlphaTo(0, 0.05, 0, function() if frame and IsValid(frame) then frame:Close() end end)
                opt.onRun(client, ent)
                if opt.runServer then
                    net.Start("RunOption")
                    net.WriteString(name)
                    net.SendToServer()
                end
            end
        end
    end

    local height = 25 * count
    frame.scroll:SetTall(height)
    frame:SetTall(height + 45)
    frame:CenterVertical()
    InteractionMenu = frame
end

function MODULE:OpenActionMenu()
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
    frame:SetPos(0, ScrH() / 2 - frame:GetTall() / 2)
    frame:CenterHorizontal(0.7)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.05)
    function frame:Think()
        local key = lia.keybind.get("Personal Actions", KEY_G)
        if not input.IsKeyDown(key) then self:Close() end
    end

    timer.Remove("InteractionMenu_Frame_Timer")
    timer.Create("InteractionMenu_Frame_Timer", 30, 1, function() if frame and IsValid(frame) then frame:Close() end end)
    frame.title = frame:Add("DLabel")
    frame.title:SetText("Actions Menu")
    frame.title:SetFont("liaSmallFont")
    frame.title:SetColor(color_white)
    frame.title:SetSize(frame:GetWide(), 25)
    frame.title:SetContentAlignment(5)
    frame.title:SetPos(0, 12)
    frame.title:CenterHorizontal()
    frame.scroll = frame:Add("DScrollPanel")
    frame.scroll:SetSize(frame:GetWide(), 25 * table.Count(self.SelfOptions))
    frame.scroll:SetPos(0, 25)
    frame.list = frame.scroll:Add("DIconLayout")
    frame.list:SetSize(frame.scroll:GetSize())
    local count = 0
    for name, opt in pairs(self.SelfOptions) do
        if opt.shouldShow(client) then
            count = count + 1
            local btn = frame.list:Add("DButton")
            btn:SetText(name)
            btn:SetFont("liaSmallFont")
            btn:SetColor(color_white)
            btn:SetSize(frame.list:GetWide(), 25)
            function btn:Paint(w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
                else
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 75))
                end
            end

            function btn:DoClick()
                frame:AlphaTo(0, 0.05, 0, function() if frame and IsValid(frame) then frame:Close() end end)
                opt.onRun(client)
                if opt.runServer then
                    net.Start("RunLocalOption")
                    net.WriteString(name)
                    net.SendToServer()
                end
            end
        end
    end

    local height = 25 * count
    frame.scroll:SetTall(height)
    frame:SetTall(height + 45)
    frame:CenterVertical()
    ActionInteractionMenu = frame
end

lia.keybind.add(KEY_TAB, "Interaction Menu", function()
    local client = LocalPlayer()
    if client:getChar() and hook.Run("CheckInteractionPossibilities") then MODULE:OpenInteractionMenu() end
end)

lia.keybind.add(KEY_G, "Personal Actions", function() MODULE:OpenActionMenu() end)