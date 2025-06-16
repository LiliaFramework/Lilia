local MODULE = MODULE
local function isWithinRange(client, entity)
    if not IsValid(client) or not IsValid(entity) then return false end
    return entity:GetPos():DistToSqr(client:GetPos()) < 250 * 250
end

function MODULE:checkInteractionPossibilities()
    local client = LocalPlayer()
    local ent = client:getTracedEntity()
    if not IsValid(ent) or not ent:IsPlayer() then return false end
    for _, opt in pairs(self.Interactions) do
        if opt.shouldShow(client, ent) then return true end
    end
    return false
end

local function openMenu(options, isInteraction, titleText, closeKey, netMsg)
    local client, ent = LocalPlayer(), LocalPlayer():getTracedEntity()
    local visible = {}
    for name, opt in pairs(options) do
        if isInteraction then
            if IsValid(ent) and ent:IsPlayer() and opt.shouldShow(client, ent) and isWithinRange(client, ent) then
                visible[#visible + 1] = {
                    name = name,
                    opt = opt
                }
            end
        else
            if opt.shouldShow(client) then
                visible[#visible + 1] = {
                    name = name,
                    opt = opt
                }
            end
        end
    end

    if #visible == 0 then return end
    local frameW, baseH = 300, 25 * #visible + 100
    local maxH = isInteraction and baseH or math.min(baseH, 150)
    local frameH = maxH * 2
    local titleH, titleY, gap = isInteraction and 32 or 12, 16, 15
    local padding = ScrW() * 0.15
    local xPos, yPos = ScrW() - frameW - padding, (ScrH() - frameH) / 2
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:SetPos(xPos, yPos)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.05)
    frame.Think = function(self) if not input.IsKeyDown(closeKey) then self:Close() end end
    frame.Paint = function(self, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 200)) end
    timer.Remove("InteractionMenu_Frame_Timer")
    timer.Create("InteractionMenu_Frame_Timer", 30, 1, function() if IsValid(frame) then frame:Close() end end)
    local title = frame:Add("DLabel")
    title:SetPos(0, titleY)
    title:SetSize(frameW, titleH)
    title:SetText(titleText)
    title:SetFont("liaSmallFont")
    title:SetColor(color_white)
    title:SetContentAlignment(5)
    local scroll = frame:Add("DScrollPanel")
    scroll:SetPos(0, titleH + titleY + gap)
    scroll:SetSize(frameW, frameH - titleH - titleY - gap)
    scroll.Paint = function(self, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 150)) end
    local layout = scroll:Add("DIconLayout")
    layout:Dock(FILL)
    layout:SetSpaceY(12)
    for i, item in ipairs(visible) do
        local btn = layout:Add("DButton")
        btn:Dock(TOP)
        btn:SetTall(25)
        btn:DockMargin(10, 0, 10, i == #visible and 20 or 12)
        btn:SetText(item.name)
        btn:SetFont("liaSmallFont")
        btn:SetTextColor(color_white)
        btn.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 150))
            end
        end

        btn.DoClick = function()
            frame:AlphaTo(0, 0.05, 0, function() if IsValid(frame) then frame:Close() end end)
            if isInteraction then
                item.opt.onRun(client, ent)
            else
                item.opt.onRun(client)
            end

            if item.opt.runServer then
                net.Start(netMsg)
                net.WriteString(item.name)
                net.SendToServer()
            end
        end
    end

    MODULE.Menu = frame
end

lia.keybind.add(KEY_TAB, "Interaction Menu", function()
    local client = LocalPlayer()
    if not client:getChar() or not MODULE:checkInteractionPossibilities() then return end
    if IsValid(MODULE.Menu) then
        MODULE.Menu:Close()
        MODULE.Menu = nil
    end

    openMenu(MODULE.Interactions, true, "Player Interactions", lia.keybind.get("Interaction Menu", KEY_TAB), "RunOption")
end)

lia.keybind.add(KEY_G, "Personal Actions", function()
    if IsValid(MODULE.Menu) then
        MODULE.Menu:Close()
        MODULE.Menu = nil
    end

    openMenu(MODULE.Actions, false, "Actions Menu", lia.keybind.get("Personal Actions", KEY_G), "RunLocalOption")
end)