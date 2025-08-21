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
    local fadeSpeed = 0.05
    local frameW = 400
    local entryH = 30
    local baseH = entryH * #visible + 140
    local frameH = isInteraction and baseH or math.min(baseH, ScrH() * 0.6)
    local titleH = isInteraction and 36 or 16
    local titleY = 12
    local gap = 24
    local padding = ScrW() * 0.15
    local xPos = ScrW() - frameW - padding
    local yPos = (ScrH() - frameH) / 2
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:SetPos(xPos, yPos)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    hook.Run("InteractionMenuOpened", frame)
    local oldOnRemove = frame.OnRemove
    function frame:OnRemove()
        if oldOnRemove then oldOnRemove(self) end
        MODULE.Menu = nil
        hook.Run("InteractionMenuClosed")
    end

    frame:SetAlpha(0)
    frame:AlphaTo(255, fadeSpeed)
    function frame:Paint(w, h)
        lia.util.drawBlur(self, 4)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
    end

    function frame:Think()
        if not input.IsKeyDown(closeKey) then self:Close() end
    end

    timer.Remove("InteractionMenu_Frame_Timer")
    timer.Create("InteractionMenu_Frame_Timer", 30, 1, function() if IsValid(frame) then frame:Close() end end)
    local title = frame:Add("DLabel")
    title:SetPos(0, titleY)
    title:SetSize(frameW, titleH)
    title:SetText(titleText)
    title:SetFont("liaSmallFont")
    title:SetColor(color_white)
    title:SetContentAlignment(5)
    function title:PaintOver()
        surface.SetDrawColor(Color(60, 60, 60))
    end

    local scroll = frame:Add("DScrollPanel")
    scroll:SetPos(0, titleH + titleY + gap)
    scroll:SetSize(frameW, frameH - titleH - titleY - gap)
    local layout = scroll:Add("DIconLayout")
    layout:Dock(FILL)
    layout:SetSpaceY(14)
    for i, entry in ipairs(visible) do
        local btn = layout:Add("DButton")
        btn:Dock(TOP)
        btn:SetTall(entryH)
        btn:DockMargin(15, 0, 15, i == #visible and 25 or 14)
        btn:SetText(L(entry.name))
        btn:SetFont("liaSmallFont")
        btn:SetTextColor(color_white)
        function btn:Paint(w, h)
            if self:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 160))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 100))
            end
        end

        btn.DoClick = function()
            frame:AlphaTo(0, fadeSpeed, 0, function() if IsValid(frame) then frame:Close() end end)
            if isInteraction then
                local target = ent:IsBot() and client or ent
                entry.opt.onRun(client, target)
            else
                entry.opt.onRun(client)
            end

            if entry.opt.runServer then
                net.Start(netMsg)
                net.WriteString(entry.name)
                if isInteraction then net.WriteEntity(ent) end
                net.SendToServer()
            end
        end
    end

    MODULE.Menu = frame
end

lia.keybind.add(KEY_TAB, "interactionMenu", function()
    local client = LocalPlayer()
    if not client:getChar() or not MODULE:checkInteractionPossibilities() then return end
    if IsValid(MODULE.Menu) then
        MODULE.Menu:Close()
        MODULE.Menu = nil
    end

    openMenu(MODULE.Interactions, true, "playerInteractions", lia.keybind.get(L("interactionMenu"), KEY_TAB), "RunOption")
end)

lia.keybind.add(KEY_G, "personalActions", function()
    if IsValid(MODULE.Menu) then
        MODULE.Menu:Close()
        MODULE.Menu = nil
    end

    openMenu(MODULE.Actions, false, "actionsMenu", lia.keybind.get(L("personalActions"), KEY_G), "RunLocalOption")
end)

lia.keybind.add(KEY_V, "quickTakeItem", function()
    local client = LocalPlayer()
    if not client:getChar() then return end
    local entity = client:getTracedEntity()
    if IsValid(entity) and entity:isItem() then
        if entity:GetPos():Distance(client:GetPos()) > 96 then return end
        local itemTable = entity:getItemTable()
        if itemTable and itemTable.functions and itemTable.functions.take and itemTable.functions.take.onCanRun and itemTable.functions.take.onCanRun(itemTable) then
            net.Start("invAct")
            net.WriteString("take")
            net.WriteType(entity)
            net.SendToServer()
        end
    end
end)