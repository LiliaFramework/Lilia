AdminStickIsOpen = false
local MODULE = MODULE
MODULE.xpos = MODULE.xpos or 20
MODULE.ypos = MODULE.ypos or 20
function OpenPlayerModelUI(target)
    AdminStickIsOpen = true
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Change Playermodel")
    frame:SetSize(450, 300)
    frame:Center()
    function frame:OnClose()
        frame:Remove()
        AdminStickIsOpen = false
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local wrapper = vgui.Create("DIconLayout", scroll)
    wrapper:Dock(FILL)
    local edit = vgui.Create("DTextEntry", frame)
    edit:Dock(BOTTOM)
    edit:SetText(target:GetModel())
    local button = vgui.Create("DButton", frame)
    button:SetText("Change")
    button:Dock(TOP)
    function button:DoClick()
        local txt = edit:GetValue()
        RunConsoleCommand("say", "/charsetmodel " .. target:SteamID() .. " " .. txt)
        frame:Remove()
        AdminStickIsOpen = false
    end

    for name, model in SortedPairs(player_manager.AllValidModels()) do
        local icon = wrapper:Add("SpawnIcon")
        icon:SetModel(model)
        icon:SetSize(64, 64)
        icon:SetTooltip(name)
        icon.playermodel = name
        icon.model_path = model
        icon.DoClick = function(self) edit:SetValue(self.model_path) end
    end

    frame:MakePopup()
end

local function OpenReasonUI(target, cmd)
    AdminStickIsOpen = true
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Reason for " .. cmd)
    frame:SetSize(300, 150)
    frame:Center()
    function frame:OnClose()
        frame:Remove()
        AdminStickIsOpen = false
    end

    local edit = vgui.Create("DTextEntry", frame)
    edit:Dock(FILL)
    edit:SetMultiline(true)
    edit:SetPlaceholderText("Reason")
    local timeedit
    if cmd == "banid" then
        local time = vgui.Create("DNumSlider", frame)
        time:Dock(TOP)
        time:SetText("Length (days)")
        time:SetMin(0)
        time:SetMax(365)
        time:SetDecimals(0)
        timeedit = time
    end

    local button = vgui.Create("DButton", frame)
    button:Dock(BOTTOM)
    button:SetText("Change")
    function button:DoClick()
        local txt = edit:GetValue()
        if cmd == "banid" then
            local time = timeedit:GetValue() * 60 * 24
            RunConsoleCommand("sam", cmd, target:SteamID(), time, txt)
        else
            RunConsoleCommand("sam", cmd, target:SteamID(), txt)
        end

        frame:Remove()
        AdminStickIsOpen = false
    end

    frame:MakePopup()
end

function MODULE:OpenAdminStickUI(target)
    AdminStickIsOpen = true
    local AdminMenu = DermaMenu()
    AdminMenu:Center()
    AdminMenu:MakePopup()
    if target:IsPlayer() then
        local name = AdminMenu:AddOption("Name: " .. target:Name() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:Name() .. " to Clipboard!")
            SetClipboardText(target:Name())
            AdminStickIsOpen = false
        end)

        name:SetIcon("icon16/page_copy.png")
        local charid = AdminMenu:AddOption("CharID: " .. target:getChar():getID() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied CharID: " .. target:getChar():getID() .. " to Clipboard!")
            SetClipboardText(target:getChar():getID())
            AdminStickIsOpen = false
        end)

        charid:SetIcon("icon16/page_copy.png")
        local steamid = AdminMenu:AddOption("SteamID: " .. target:SteamID() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID() .. " to Clipboard!")
            SetClipboardText(target:SteamID())
            AdminStickIsOpen = false
        end)

        steamid:SetIcon("icon16/page_copy.png")
        local steamid64 = AdminMenu:AddOption("SteamID64: " .. target:SteamID64() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID64() .. " to Clipboard!")
            SetClipboardText(target:SteamID64())
            AdminStickIsOpen = false
        end)

        steamid64:SetIcon("icon16/page_copy.png")
        local playerInfo = AdminMenu:AddSubMenu("Administration")
        if target:IsFrozen() then
            local unfreeze = playerInfo:AddOption("Unfreeze", function()
                RunConsoleCommand("sam", "unfreeze", target:SteamID())
                AdminStickIsOpen = false
            end)

            unfreeze:SetIcon("icon16/unlock.png")
        else
            local freeze = playerInfo:AddOption("Freeze", function()
                if LocalPlayer() == target then
                    lia.notices.notify("You can't freeze yourself!")
                    return false
                end

                RunConsoleCommand("sam", "freeze", target:SteamID())
                AdminStickIsOpen = false
            end)

            freeze:SetIcon("icon16/lock.png")
            local ban = playerInfo:AddOption("Ban", function() OpenReasonUI(target, "banid", 0) end)
            ban:SetIcon("icon16/exclamation.png")
            local kick = playerInfo:AddOption("Kick", function() OpenReasonUI(target, "kick", 0) end)
            kick:SetIcon("icon16/door.png")
            local gag = playerInfo:AddOption("Gag", function()
                RunConsoleCommand("sam", "gag", target:SteamID())
                AdminStickIsOpen = false
            end)

            gag:SetIcon("icon16/sound_mute.png")
            local ungag = playerInfo:AddOption("Ungag", function()
                RunConsoleCommand("sam", "ungag", target:SteamID())
                AdminStickIsOpen = false
            end)

            ungag:SetIcon("icon16/sound_low.png")
            local mute = playerInfo:AddOption("Mute", function()
                RunConsoleCommand("sam", "mute", target:SteamID())
                AdminStickIsOpen = false
            end)

            mute:SetIcon("icon16/sound_delete.png")
            local unmute = playerInfo:AddOption("Unmute", function()
                RunConsoleCommand("sam", "unmute", target:SteamID())
                AdminStickIsOpen = false
            end)

            unmute:SetIcon("icon16/sound_add.png")
            local slay = playerInfo:AddOption("Slay", function()
                RunConsoleCommand("sam", "slay", target:SteamID())
                AdminStickIsOpen = false
            end)

            slay:SetIcon("icon16/bomb.png")
            local respawn = playerInfo:AddOption("Respawn", function()
                RunConsoleCommand("sam", "respawn", target:SteamID())
                AdminStickIsOpen = false
            end)

            respawn:SetIcon("icon16/arrow_refresh.png")
            local jail = playerInfo:AddOption("Jail", function()
                RunConsoleCommand("sam", "jail", target:SteamID())
                AdminStickIsOpen = false
            end)

            jail:SetIcon("icon16/lock.png")
            local ignite = playerInfo:AddOption("Ignite", function()
                RunConsoleCommand("sam", "ignite", target:SteamID())
                AdminStickIsOpen = false
            end)

            ignite:SetIcon("icon16/fire.png")
            local blind = playerInfo:AddOption("Blind", function()
                RunConsoleCommand("sam", "blind", target:SteamID())
                AdminStickIsOpen = false
            end)

            blind:SetIcon("icon16/eye.png")
            local unblind = playerInfo:AddOption("Unblind", function()
                RunConsoleCommand("sam", "unblind", target:SteamID())
                AdminStickIsOpen = false
            end)

            unblind:SetIcon("icon16/eye.png")
        end

        local characterInfo = AdminMenu:AddSubMenu("Character")
        for _, fac in pairs(lia.faction.teams) do
            if fac.index == target:getChar():getFaction() then
                local faction = characterInfo:AddSubMenu("Set Faction (" .. fac.name .. ")")
                for _, v in pairs(lia.faction.teams) do
                    faction:AddOption(v.name, function()
                        LocalPlayer():ConCommand('say /plytransfer "' .. target:SteamID() .. '" "' .. v.name .. '"')
                        AdminStickIsOpen = false
                    end)
                end
            end
        end

        local setClass = characterInfo:AddSubMenu("Set Class")
        for _, class in ipairs(lia.class.list) do
            if class.faction == target:getChar():getFaction() then
                local classOption = setClass:AddOption(class.name, function()
                    LocalPlayer():ConCommand('say /setclass "' .. target:SteamID() .. '" "' .. class.name .. '"')
                    AdminStickIsOpen = false
                end)

                classOption:SetIcon("icon16/user.png")
            end
        end

        local desc = characterInfo:AddOption("Change Name", function()
            RunConsoleCommand("say", "/charsetname " .. target:SteamID())
            AdminStickIsOpen = false
        end)

        desc:SetIcon("icon16/user_gray.png")
        local desc4 = characterInfo:AddOption("Change Description", function()
            RunConsoleCommand("say", "/charsetdesc " .. target:SteamID())
            AdminStickIsOpen = false
        end)

        desc4:SetIcon("icon16/user_green.png")
        local desc3 = characterInfo:AddOption("Change Playermodel", function() OpenPlayerModelUI(target) end)
        desc3:SetIcon("icon16/user_suit.png")
        local charkick = characterInfo:AddOption("Kick From Character", function()
            LocalPlayer():ConCommand('say /charkick "' .. target:SteamID() .. '"')
            AdminStickIsOpen = false
        end)

        charkick:SetIcon("icon16/lightning_delete.png")
        local teleport = AdminMenu:AddSubMenu("Teleportation")
        local gotoo = teleport:AddOption("Goto", function()
            if LocalPlayer() == target then
                lia.notices.notify("You can't goto yourself!")
                return false
            end

            RunConsoleCommand("sam", "goto", target:SteamID())
            AdminStickIsOpen = false
        end)

        gotoo:SetIcon("icon16/arrow_right.png")
        local bring = teleport:AddOption("Bring", function()
            if LocalPlayer() == target then
                lia.notices.notify("You can't bring yourself!")
                return false
            end

            RunConsoleCommand("sam", "bring", target:SteamID())
            AdminStickIsOpen = false
        end)

        bring:SetIcon("icon16/arrow_down.png")
        local returnf = teleport:AddOption("Return", function()
            RunConsoleCommand("sam", "return", target:SteamID())
            AdminStickIsOpen = false
        end)

        returnf:SetIcon("icon16/arrow_redo.png")
        local flags = AdminMenu:AddSubMenu("Flags")
        local giveFlagsSubMenu = flags:AddSubMenu("Give Flags")
        for flag, _ in pairs(lia.flag.list) do
            if not target:getChar():hasFlags(flag) then
                local giveFlag = giveFlagsSubMenu:AddOption("Give Flag " .. flag, function()
                    LocalPlayer():ConCommand('say /giveflag "' .. target:SteamID() .. '" "' .. flag .. '"')
                    AdminStickIsOpen = false
                end)

                giveFlag:SetIcon("icon16/flag_blue.png")
            end
        end

        local takeFlagsSubMenu = flags:AddSubMenu("Take Flags")
        for flag, _ in pairs(lia.flag.list) do
            if target:getChar():hasFlags(flag) then
                local takeFlag = takeFlagsSubMenu:AddOption("Take Flag " .. flag, function()
                    LocalPlayer():ConCommand('say /takeflag "' .. target:SteamID() .. '" "' .. flag .. '"')
                    AdminStickIsOpen = false
                end)

                takeFlag:SetIcon("icon16/flag_red.png")
            end
        end

        local listFlags = flags:AddOption("List Flags", function()
            RunConsoleCommand("say", "/checkflags " .. target:SteamID())
            AdminStickIsOpen = false
        end)

        listFlags:SetIcon("icon16/find.png")
        local flagpet = flags:AddOption("Give/Take PET Flags", function() LocalPlayer():ConCommand('say /flagpet "' .. target:SteamID() .. '"') end)
        flagpet:SetIcon("icon16/find.png")
    end

    function AdminMenu:OnClose()
        AdminStickIsOpen = false
    end

    AdminMenu:Open()
end

function MODULE:TicketFrame(requester, message, claimed)
    if not TicketFrames then TicketFrames = {} end
    local mat_lightning = Material("icon16/lightning_go.png")
    local mat_arrow = Material("icon16/arrow_left.png")
    local mat_link = Material("icon16/link.png")
    local mat_case = Material("icon16/briefcase.png")
    if not requester:IsValid() or not requester:IsPlayer() then return end
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then
            local txt = v:GetChildren()[5]
            txt:AppendText("\n" .. message)
            txt:GotoTextEnd()
            timer.Remove("ticketsystem-" .. requester:SteamID64())
            timer.Create("ticketsystem-" .. requester:SteamID64(), self.Autoclose, 1, function() if v:IsValid() then v:Remove() end end)
            surface.PlaySound("ui/hint.wav")
            return
        end
    end

    local w, h = 300, 120
    local frm = vgui.Create("DFrame")
    frm:SetSize(w, h)
    frm:SetPos(self.xpos, self.ypos)
    frm.idiot = requester
    function frm:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 230))
    end

    frm.lblTitle:SetColor(Color(255, 255, 255))
    frm.lblTitle:SetFont("ticketsystem")
    frm.lblTitle:SetContentAlignment(7)
    if claimed and claimed:IsValid() and claimed:IsPlayer() then
        frm:SetTitle(requester:Nick() .. " - Claimed by " .. claimed:Nick())
        if claimed == LocalPlayer() then
            function frm:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 230))
                draw.RoundedBox(0, 2, 2, w - 4, 16, Color(38, 166, 91))
            end
        else
            function frm:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 230))
                draw.RoundedBox(0, 2, 2, w - 4, 16, Color(207, 0, 15))
            end
        end
    else
        frm:SetTitle(requester:Nick())
    end

    local msg = vgui.Create("RichText", frm)
    msg:SetPos(10, 30)
    msg:SetSize(190, h - 35)
    msg:SetContentAlignment(7)
    msg:InsertColorChange(255, 255, 255, 255)
    msg:SetVerticalScrollbarEnabled(false)
    function msg:PerformLayout()
        self:SetFontInternal("DermaDefault")
    end

    msg:AppendText(message)
    local function createButton(text, material, position, clickFunc)
        local btn = vgui.Create("DButton", frm)
        if not btn then print("Error: Failed to create button.") end
        btn:SetPos(215, position)
        btn:SetSize(83, 18)
        btn:SetText("          " .. text)
        btn:SetColor(Color(255, 255, 255))
        btn:SetContentAlignment(4)
        btn.DoClick = clickFunc
        btn.Paint = function(self, w, h)
            if self.Depressed or self.m_bSelected then
                draw.RoundedBox(1, 0, 0, w, h, Color(255, 50, 50, 255))
            elseif self.Hovered then
                draw.RoundedBox(1, 0, 0, w, h, Color(205, 30, 30, 255))
            else
                draw.RoundedBox(1, 0, 0, w, h, Color(80, 80, 80, 255))
            end

            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(material)
            surface.DrawTexturedRect(5, 1, 16, 16)
        end
        return btn
    end

    createButton("Goto", mat_lightning, 20 * 1, function() RunConsoleCommand("sam", "goto", requester:SteamID()) end)
    createButton("Return", mat_arrow, 20 * 2, function() RunConsoleCommand("sam", "return", requester:SteamID()) end)
    createButton("Freeze", mat_link, 20 * 3, function() RunConsoleCommand("sam", "freeze", requester:SteamID()) end)
    createButton("Bring", mat_arrow, 20 * 4, function() RunConsoleCommand("sam", "bring", requester:SteamID()) end)
    local shouldClose = false
    local claimButton
    claimButton = createButton("Claim case", mat_case, 20 * 5, function()
        if not shouldClose then
            if frm.lblTitle:GetText():lower():find("claimed") then
                chat.AddText(Color(255, 150, 0), "[ERROR] Case has already been claimed")
                surface.PlaySound("common/wpn_denyselect.wav")
            else
                net.Start("TicketSystemClaim")
                net.WriteEntity(requester)
                net.SendToServer()
                shouldClose = true
                claimButton:SetText("          Close case")
            end
        else
            net.Start("TicketSystemClose")
            net.WriteEntity(requester)
            net.SendToServer()
        end
    end)

    if not claimButton then print("Error: claimButton is nil.") end
    local closeButton = vgui.Create("DButton", frm)
    closeButton:SetText("×")
    closeButton:SetTooltip("Close")
    closeButton:SetColor(Color(255, 255, 255))
    closeButton:SetPos(w - 18, 2)
    closeButton:SetSize(16, 16)
    function closeButton:Paint()
    end

    closeButton.DoClick = function() frm:Close() end
    frm:ShowCloseButton(false)
    frm:SetPos(self.xpos, self.ypos + (130 * #TicketFrames))
    frm:MoveTo(self.xpos, self.ypos + (130 * #TicketFrames), 0.2, 0, 1, function() surface.PlaySound("garrysmod/balloon_pop_cute.wav") end)
    function frm:OnRemove()
        if TicketFrames then
            table.RemoveByValue(TicketFrames, frm)
            for k, v in ipairs(TicketFrames) do
                v:MoveTo(self.xpos, self.ypos + (130 * (k - 1)), 0.1, 0, 1, function() end)
            end
        end

        if requester and requester:IsValid() and requester:IsPlayer() and timer.Exists("ticketsystem-" .. requester:SteamID64()) then timer.Remove("ticketsystem-" .. requester:SteamID64()) end
    end

    table.insert(TicketFrames, frm)
    timer.Create("ticketsystem-" .. requester:SteamID64(), self.Autoclose, 1, function() if frm:IsValid() then frm:Remove() end end)
end

function MODULE:LoadFonts()
    surface.CreateFont("ticketsystem", {
        font = "Railway",
        size = 15,
        weight = 400
    })
end

CreateClientConVar("cl_ticketsystem_closeclaimed", 0, true, false)
CreateClientConVar("cl_ticketsystem_dutymode", 0, true, false)