local data = {}
local cols = {
    header = Color(54, 58, 64),
    body = Color(72, 77, 84),
    close = Color(35, 37, 41),
    button = Color(55, 57, 61, 150),
    white = Color(255, 255, 255),
    shadow = Color(0, 0, 0, 150),
    accepted = Color(50, 168, 84, 255),
}

function MODULE:LoadFonts()
    surface.CreateFont("Roboto.20", {
        font = "Roboto",
        size = 20,
    })

    surface.CreateFont("Roboto.15", {
        font = "Roboto",
        size = 15,
    })

    surface.CreateFont("Roboto.22", {
        font = "Roboto",
        size = 22,
    })
end

local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0
    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)
        if totalWidth >= remainingWidth then
            remainingWidth = maxWidth
            return "\n" .. char
        end
        return char
    end)
    return text, totalWidth
end

local function textWrap(text, font, maxWidth)
    local totalWidth = 0
    surface.SetFont(font)
    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
        local char = string.sub(word, 1, 1)
        if char == "\n" or char == "\t" then totalWidth = 0 end
        local wordlen = surface.GetTextSize(word)
        totalWidth = totalWidth + wordlen
        if wordlen >= maxWidth then
            local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
            totalWidth = splitPoint
            return splitWord
        elseif totalWidth < maxWidth then
            return word
        end

        if char == ' ' then
            totalWidth = wordlen - spaceWidth
            return '\n' .. string.sub(word, 2)
        end

        totalWidth = wordlen
        return '\n' .. word
    end)
    return text
end

net.Receive("NetTicket", function()
    if LocalPlayer():isStaffOnDuty() or LocalPlayer():IsSuperAdmin() then
        local ply = net.ReadEntity()
        local content = net.ReadString()
        local id = net.ReadInt(8)
        local width, height = ScrW(), ScrH()
        local frame_width, frame_height = width * 0.2, height * 0.15
        local frame = vgui.Create("DFrame")
        frame:SetSize(frame_width, frame_height)
        frame:SetPos(-frame_width, 10)
        frame:MoveTo(10, 10, 0.5, 0)
        frame:SetTitle("")
        frame:SetDraggable(false)
        frame:ShowCloseButton(false)
        frame.Paint = function(_, w, h)
            if data[ply] == nil then
                frame:Remove()
                return
            end

            if frame.accepted then
                DisableClipping(true)
                draw.RoundedBox(10, -2, -2, w + 4, h + 4, cols.accepted)
                DisableClipping(false)
            end

            draw.RoundedBox(10, 0, 0, w, h, cols.body)
            draw.RoundedBoxEx(10, 0, 0, w, frame_height * 0.2, cols.header, true, true, false, false)
            draw.RoundedBox(0, 0, frame_height * 0.2, w, 2, cols.shadow)
            draw.SimpleText(ply:Nick(), "Roboto.20", 10, (frame_height * 0.2) / 2, cols.white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        hook.Add("Think", "ShowPanelStuff", function()
            if not IsValid(frame) then
                hook.Remove("Think", "ShowPanelStuff")
                return
            end

            if data[ply] == nil then
                frame:Remove()
                hook.Remove("Think", "ShowPanelStuff")
                return
            end

            if data[ply].claimer ~= nil and data[ply].claimer ~= LocalPlayer() then
                frame:Hide()
            else
                frame:Show()
            end
        end)

        local text_body = vgui.Create("DPanel", frame)
        text_body:SetSize(frame_width - 20, frame_height * 0.5)
        text_body:SetPos(10, frame_height * 0.2 + 10)
        text_body.Paint = function() end
        local text_font = "liaSmallFont"
        local text_label = vgui.Create("DLabel", text_body)
        text_label:SetTextColor(cols.white)
        text_label:SetFont(text_font)
        local wrappedText = textWrap(content, text_font, text_body:GetWide())
        text_label:SetText(wrappedText)
        text_label:SizeToContents()
        local close = vgui.Create("DButton", frame)
        close:SetSize(24, 24)
        close:SetText("")
        close:SetPos(frame_width - 34, 8)
        close.Paint = function(_, w, h)
            draw.RoundedBox(12, 0, 0, w, h, cols.close)
            draw.SimpleText("X", "Roboto.20", w / 2, h / 2, cols.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        close.DoClick = function()
            if frame.accepted then
                LocalPlayer():ChatPrint("Please close or cancel the ticket.")
                return
            end

            frame:MoveTo(-(frame:GetWide() + frame:GetX()), frame:GetY(), 0.5, 0, -1, function() frame:Remove() end)
        end

        local container = vgui.Create("DPanel", frame)
        container:SetPos(0, frame_height - 70)
        container:SetSize(frame_width, 60)
        container:DockPadding(10, 10, 10, 10)
        container.Paint = function() end
        local accept_but = vgui.Create("DButton", container)
        accept_but:SetSize(100, 40)
        accept_but:SetText(frame.accepted and "Close" or "Accept")
        accept_but:SetPos(10, 10)
        accept_but.Paint = function(_, w, h)
            local color = frame.accepted and cols.accepted or Color(50, 100, 200, 255)
            draw.RoundedBox(5, 0, 0, w, h, color)
        end

        accept_but.DoClick = function()
            if accept_but:GetText() == "Close" then
                frame:MoveTo(-(frame:GetWide() + frame:GetX()), frame:GetY(), 0.5, 0, -1, function()
                    frame:Remove()
                    data[id] = nil
                    net.Start("UpdateTicketStatus")
                    net.WriteBool(false)
                    net.SendToServer()
                    net.Start("TicketSync")
                    net.WriteTable(data)
                    net.SendToServer()
                end)

                LocalPlayer():ChatPrint("You have closed " .. ply:Nick() .. "'s ticket.")
                return
            end

            data[ply].claimer = LocalPlayer()
            frame.accepted = true
            accept_but:SetText("Close")
            LocalPlayer():ChatPrint("You have accepted " .. ply:Nick() .. "'s ticket.")
            net.Start("UpdateTicketStatus")
            net.WriteBool(true)
            net.SendToServer()
            net.Start("TicketSync")
            net.WriteTable(data)
            net.SendToServer()
        end

        local ignore_but = vgui.Create("DButton", container)
        ignore_but:SetSize(100, 40)
        ignore_but:SetText("Ignore")
        ignore_but:SetPos(120, 10)
        ignore_but.Paint = function(_, w, h)
            local color = ignore_but:GetText() == "Cancel" and Color(200, 50, 50, 255) or Color(150, 150, 150, 255)
            draw.RoundedBox(5, 0, 0, w, h, color)
        end

        ignore_but.DoClick = function()
            if ignore_but:GetText() == "Cancel" then
                data[ply].claimer = nil
                frame.accepted = false
                ignore_but:SetText("Ignore")
                LocalPlayer():ChatPrint("You are no longer taking " .. ply:Nick() .. "'s ticket.")
                net.Start("UpdateTicketStatus")
                net.WriteBool(false)
                net.SendToServer()
                net.Start("TicketSync")
                net.WriteTable(data)
                net.SendToServer()
                return
            end

            frame:MoveTo(-(frame:GetWide() + frame:GetX()), frame:GetY(), 0.5, 0, -1, function() frame:Remove() end)
        end

        local actions_but = vgui.Create("DButton", container)
        actions_but:SetSize(100, 40)
        actions_but:SetText("Actions")
        actions_but:SetPos(230, 10)
        actions_but.Paint = function(_, w, h) draw.RoundedBox(5, 0, 0, w, h, Color(100, 100, 200, 255)) end
        actions_but.DoClick = function()
            local actions_menu = DermaMenu(actions_but)
            actions_menu:SetPos(input.GetCursorPos())
            local steamidbut = actions_menu:AddOption("Copy SteamID", function()
                SetClipboardText(tostring(ply:SteamID()))
                LocalPlayer():ChatPrint("You copied " .. ply:Nick() .. "'s SteamID.")
            end)

            steamidbut:SetIcon("icon16/page_copy.png")
            actions_menu:AddSpacer()
            local bringbut = actions_menu:AddOption("Bring", function() LocalPlayer():ConCommand("sam bring " .. ply:Nick()) end)
            bringbut:SetIcon("icon16/arrow_left.png")
            local gotobut = actions_menu:AddOption("Goto", function() LocalPlayer():ConCommand("sam goto " .. ply:Nick()) end)
            gotobut:SetIcon("icon16/arrow_right.png")
            local returnbut = actions_menu:AddOption("Return", function() LocalPlayer():ConCommand("sam return") end)
            returnbut:SetIcon("icon16/arrow_refresh.png")
        end
    end
end)

lia.command.add("ticket", {
    adminOnly = false,
    onRun = function() end
})

net.Receive("TicketSync", function() data = net.ReadTable() end)