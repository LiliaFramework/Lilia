AdminStick = AdminStick or {}
AdminStick.IsOpen = false

local function OpenPlayerModelUI(target)
    AdminStick.IsOpen = true
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Change Playermodel")
    frame:SetSize(450, 300)
    frame:Center()

    function frame:OnClose()
        frame:Remove()
        AdminStick.IsOpen = false
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
        AdminStick.IsOpen = false
    end

    for name, model in SortedPairs(player_manager.AllValidModels()) do
        local icon = wrapper:Add("SpawnIcon")
        icon:SetModel(model)
        icon:SetSize(64, 64)
        icon:SetTooltip(name)
        icon.playermodel = name
        icon.model_path = model

        --icon:Dock(LEFT)
        icon.DoClick = function(self)
            edit:SetValue(self.model_path)
        end
    end

    frame:MakePopup()
end

local function OpenReasonUI(target, cmd, time)
    AdminStick.IsOpen = true
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Reason for " .. cmd)
    frame:SetSize(300, 150)
    frame:Center()

    function frame:OnClose()
        frame:Remove()
        AdminStick.IsOpen = false
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
        AdminStick.IsOpen = false
    end

    frame:MakePopup()
end

function AdminStick:OpenAdminStickUI(isright, target)
    isright = isright or false
    AdminStick.IsOpen = true
    AdminStick.AdminMenu = DermaMenu()
    local AdminMenu = AdminStick.AdminMenu

    if target:IsPlayer() then
        local name = AdminMenu:AddOption("Name: " .. target:Name() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:Name() .. " to Clipboard!")
            SetClipboardText(target:Name())
            AdminStick.IsOpen = false
        end)

        name:SetIcon("icon16/information.png")

        local charid = AdminMenu:AddOption("CharID: " .. target:getChar():getID() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied CharID: " .. target:getChar():getID() .. " to Clipboard!")
            SetClipboardText(target:getChar():getID())
            AdminStick.IsOpen = false
        end)

        charid:SetIcon("icon16/information.png")

        local steamid = AdminMenu:AddOption("SteamID: " .. target:SteamID() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID() .. " to Clipboard!")
            SetClipboardText(target:SteamID())
            AdminStick.IsOpen = false
        end)

        steamid:SetIcon("icon16/information.png")

        local steamid64 = AdminMenu:AddOption("SteamID64: " .. target:SteamID64() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID64() .. " to Clipboard!")
            SetClipboardText(target:SteamID64())
            AdminStick.IsOpen = false
        end)

        steamid64:SetIcon("icon16/information.png")
        --[[
        local spectate = AdminMenu:AddOption("Spectate: " .. target:Nick(), function()
            net.Start("FSpectateTarget")
            net.WriteEntity(target)
            net.SendToServer()
            AdminStick.IsOpen = false
        end)

        spectate:SetIcon("icon16/eye.png")]]
        -------------------------------------------------------------------------------------------------------------
        local playerInfo = AdminMenu:AddSubMenu("Administration")

        local notes = playerInfo:AddOption("View Notes", function()
            RunConsoleCommand("say", "/adminnotes " .. target:SteamID())
            AdminStick.IsOpen = false
        end)

        notes:SetIcon("icon16/application_form_magnify.png")

        if target:IsFrozen() then
            local unfreeze = playerInfo:AddOption("Unfreeze", function()
                RunConsoleCommand("sam", "unfreeze", target:SteamID())
                AdminStick.IsOpen = false
            end)

            unfreeze:SetIcon("icon16/disconnect.png")
        else
            local freeze = playerInfo:AddOption("Freeze", function()
                if LocalPlayer() == target then
                    nut.util.notify("You can't freeze yourself!")

                    return false
                end

                RunConsoleCommand("sam", "freeze", target:SteamID())
                AdminStick.IsOpen = false
            end)

            freeze:SetIcon("icon16/connect.png")
        end

        local ban = playerInfo:AddOption("Ban", function()
            OpenReasonUI(target, "banid", 0)
        end)

        ban:SetIcon("icon16/cancel.png")

        local kick = playerInfo:AddOption("Kick", function()
            OpenReasonUI(target, "kick", 0)
        end)

        kick:SetIcon("icon16/delete.png")

        local gag = playerInfo:AddOption("Gag", function()
            RunConsoleCommand("sam", "gag", target:SteamID())
            AdminStick.IsOpen = false
        end)

        gag:SetIcon("icon16/sound_mute.png")

        local ungag = playerInfo:AddOption("Ungag", function()
            RunConsoleCommand("sam", "ungag", target:SteamID())
            AdminStick.IsOpen = false
        end)

        ungag:SetIcon("icon16/sound_low.png")

        local mute = playerInfo:AddOption("Mute", function()
            RunConsoleCommand("sam", "mute", target:SteamID())
            AdminStick.IsOpen = false
        end)

        mute:SetIcon("icon16/sound_delete.png")

        local unmute = playerInfo:AddOption("Unmute", function()
            RunConsoleCommand("sam", "unmute", target:SteamID())
            AdminStick.IsOpen = false
        end)

        unmute:SetIcon("icon16/sound_add.png")
        -------------------------------------------------------------------------------------------------------------
        local characterInfo = AdminMenu:AddSubMenu("Character")

        local charlist = characterInfo:AddOption("View All Characters", function()
            RunConsoleCommand("say", "/charlist " .. target:SteamID())
            AdminStick.IsOpen = false
        end)

        charlist:SetIcon("icon16/folder_user.png")

        local search = characterInfo:AddOption("Search Inventory", function()
            RunConsoleCommand("say", "/admincharsearch " .. target:SteamID())
            AdminStick.IsOpen = false
        end)

        search:SetIcon("icon16/briefcase.png")

        for i, fac in pairs(nut.faction.teams) do
            if fac.index == target:getChar():getFaction() then
                local faction = characterInfo:AddSubMenu("Set Faction (" .. fac.name .. ")")

                for i, v in pairs(nut.faction.teams) do
                    faction:AddOption(v.name, function()
                        LocalPlayer():ConCommand('say /plytransfer "' .. target:SteamID() .. '" "' .. v.name .. '"')
                        AdminStick.IsOpen = false
                    end)
                end
            end
        end

        local desc = characterInfo:AddOption("Change Name", function()
            RunConsoleCommand("say", "/charsetname " .. target:SteamID())
            AdminStick.IsOpen = false
        end)

        desc:SetIcon("icon16/user_gray.png")

        local checkinventory = characterInfo:AddOption("Search Inventory", function()
            RunConsoleCommand("say", "/checkinventory " .. target:SteamID())
            AdminStick.IsOpen = false
        end)

        checkinventory:SetIcon("icon16/user_gray.png")

        local desc4 = characterInfo:AddOption("Change Description", function()
            RunConsoleCommand("say", "/charsetdesc " .. target:SteamID())
            AdminStick.IsOpen = false
        end)

        desc4:SetIcon("icon16/user_green.png")

        local desc3 = characterInfo:AddOption("Change Playermodel", function()
            OpenPlayerModelUI(target)
        end)

        desc3:SetIcon("icon16/user_suit.png")

        local desc2 = characterInfo:AddOption("Change Target Name", function()
            LocalPlayer():ConCommand('say /namechange "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        desc2:SetIcon("icon16/user_comment.png")

        local pk = characterInfo:AddOption("Character Ban (PK)", function()
            LocalPlayer():ConCommand('say /CharPK "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        pk:SetIcon("icon16/lightning.png")

        local charkick = characterInfo:AddOption("Kick From Character", function()
            LocalPlayer():ConCommand('say /charkick "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        charkick:SetIcon("icon16/lightning_delete.png")
        -------------------------------------------------------------------------------------------------------------
        local PayGrades = characterInfo:AddSubMenu("Set PayGrades")

        if not PLUGIN.CitizenFactions[target:Team()] then
            local pagrade1 = PayGrades:AddOption("Enlisted", function()
                RunConsoleCommand("say", "/setpaygrade " .. target:SteamID() .. " 1")
                AdminStick.IsOpen = false
            end)

            pagrade1:SetIcon("icon16/application_form_magnify.png")

            local pagrade2 = PayGrades:AddOption("Non-Commissioned Officer", function()
                RunConsoleCommand("say", "/setpaygrade " .. target:SteamID() .. " 2")
                AdminStick.IsOpen = false
            end)

            pagrade2:SetIcon("icon16/application_form_magnify.png")

            local pagrade3 = PayGrades:AddOption("Commissioned Officer", function()
                RunConsoleCommand("say", "/setpaygrade " .. target:SteamID() .. " 3")
                AdminStick.IsOpen = false
            end)

            pagrade3:SetIcon("icon16/application_form_magnify.png")

            local pagrade4 = PayGrades:AddOption("General Officer", function()
                RunConsoleCommand("say", "/setpaygrade " .. target:SteamID() .. " 4")
                AdminStick.IsOpen = false
            end)

            pagrade4:SetIcon("icon16/application_form_magnify.png")

            local pagrade5 = PayGrades:AddOption("National High Command", function()
                RunConsoleCommand("say", "/setpaygrade " .. target:SteamID() .. " 5")
                AdminStick.IsOpen = false
            end)

            pagrade5:SetIcon("icon16/application_form_magnify.png")
        end

        -------------------------------------------------------------------------------------------------------------
        local teleport = AdminMenu:AddSubMenu("Teleportation")

        local gotoo = teleport:AddOption("Goto", function()
            if LocalPlayer() == target then
                nut.util.notify("You can't goto yourself!")

                return false
            end

            RunConsoleCommand("sam", "goto", target:SteamID())
            AdminStick.IsOpen = false
        end)

        gotoo:SetIcon("icon16/arrow_right.png")

        local bring = teleport:AddOption("Bring", function()
            if LocalPlayer() == target then
                nut.util.notify("You can't bring yourself!")

                return false
            end

            RunConsoleCommand("sam", "bring", target:SteamID())
            AdminStick.IsOpen = false
        end)

        bring:SetIcon("icon16/arrow_down.png")

        local returnf = teleport:AddOption("Return", function()
            RunConsoleCommand("sam", "return", target:SteamID())
            AdminStick.IsOpen = false
        end)

        returnf:SetIcon("icon16/arrow_redo.png")
        -------------------------------------------------------------------------------------------------------------
        local flags = AdminMenu:AddSubMenu("Flags")

        local listflags = flags:AddOption("List Flags", function()
            LocalPlayer():ConCommand('say /flags "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        listflags:SetIcon("icon16/find.png")

        local blacklist = flags:AddOption("Give/Take PET Flags", function()
            LocalPlayer():ConCommand('say /flagpet "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        blacklist:SetIcon("icon16/cross.png")

        local flagbank = flags:AddOption("Give/Take Banker Flags", function()
            LocalPlayer():ConCommand('say /flagbank "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        flagbank:SetIcon("icon16/flag_blue.png")

        local flagpd = flags:AddOption("Give/Take Medal Flags", function()
            LocalPlayer():ConCommand('say /flagmedal "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        flagpd:SetIcon("icon16/flag_blue.png")

        --[[
        local flagtier = flags:AddOption("Give/Take Tier Flags", function()
            LocalPlayer():ConCommand('say /flagtier "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        flagtier:SetIcon("icon16/flag_blue.png")]]
        local flagbr = flags:AddOption("Give/Take Broadcast Flags", function()
            LocalPlayer():ConCommand('say /flagbroadcast "' .. target:SteamID() .. '"')
            AdminStick.IsOpen = false
        end)

        flagbr:SetIcon("icon16/flag_blue.png")
        -------------------------------------------------------------------------------------------------------------
    elseif target:isDoor() then
        local doortitle = AdminMenu:AddOption("Set Door Title", function()
            LocalPlayer():ConCommand('say /doorsettitle')
            AdminStick.IsOpen = false
        end)

        doortitle:SetIcon("icon16/door.png")

        if target:getNetVar("hidden") == nil or target:getNetVar("hidden") == false then
            local doorhide = AdminMenu:AddOption("Make Door Hidden", function()
                LocalPlayer():ConCommand('say /doorsethidden')
                AdminStick.IsOpen = false
            end)

            doorhide:SetIcon("icon16/door.png")
        elseif target:getNetVar("hidden") == true then
            local doorhide1 = AdminMenu:AddOption("Make Door Visible", function()
                LocalPlayer():ConCommand('say /doorsethidden 0')
                AdminStick.IsOpen = false
            end)

            doorhide1:SetIcon("icon16/door.png")
        end

        if target:getNetVar("noSell") == true then
            local ownable = AdminMenu:AddOption("Make Door Ownable", function()
                LocalPlayer():ConCommand('say /doorsetownable')
                AdminStick.IsOpen = false
            end)

            ownable:SetIcon("icon16/door_in.png")
        elseif target:getNetVar("noSell") == nil then
            local unownable = AdminMenu:AddOption("Make Door Unownable", function()
                LocalPlayer():ConCommand('say /doorsetunownable')
                AdminStick.IsOpen = false
            end)

            unownable:SetIcon("icon16/door_in.png")
        end

        local addfaction = AdminMenu:AddSubMenu("Add Faction To Door")

        for i, v in pairs(nut.faction.teams) do
            local factions = string.Split(target:getNetVar("faction", ""), ",")
            if table.HasValue(factions, tostring(v.uniqueID)) then continue end

            addfaction:AddOption(v.name, function()
                LocalPlayer():ConCommand('say /dooraddfaction "' .. v.name .. '"')
                AdminStick.IsOpen = false
            end)
        end

        if target:getNetVar("faction") ~= nil then
            local removefaction = AdminMenu:AddSubMenu("Remove Faction From Door")

            for i, v in pairs(nut.faction.teams) do
                local factions = string.Split(target:getNetVar("faction", ""), ",")
                if not table.HasValue(factions, tostring(v.uniqueID)) then continue end

                removefaction:AddOption(v.name, function()
                    LocalPlayer():ConCommand('say /doorremovefaction "' .. v.name .. '"')
                    AdminStick.IsOpen = false
                end)
            end

            local removeallfaction = AdminMenu:AddOption("Clear Factions From Door", function()
                LocalPlayer():ConCommand('say /doorremovefaction')
                AdminStick.IsOpen = false
            end)
        end

        if target:getNetVar("owner", 0) > 0 then
            local removeowner = AdminMenu:AddOption("Clear Owner From Door", function()
                LocalPlayer():ConCommand('say /doorsetpermaowner')
                AdminStick.IsOpen = false
            end)
        end

        if target:GetClass() == "nut_storage" then
            if target:getNetVar("locked") then
                local removelock = AdminMenu:AddOption("Remove Lock", function()
                    LocalPlayer():ConCommand('say /storagelock')
                    AdminStick.IsOpen = false
                end)

                removelock:SetIcon("icon16/lock_open.png")
            end

            local lock = AdminMenu:AddOption("Edit Password", function()
                AdminStick.IsOpen = false

                Derma_StringRequest('Edit Password', 'Enter Storage Password', '', function(text)
                    LocalPlayer():ConCommand("say /storagelock " .. text)
                end)
            end)

            lock:SetIcon("icon16/lock_edit.png")
        end
    end

    function AdminMenu:OnClose()
        AdminStick.IsOpen = false
    end

    AdminMenu:Open()
    AdminMenu:Center()
end

net.Receive("namechange", function()
    local entity = net.ReadEntity()

    if LocalPlayer():IsAdmin() then
        Derma_StringRequest("Change Name", "Change this player name.", "", function(text)
            net.Start("nameupdate")
            net.WriteString(text)
            net.WriteEntity(LocalPlayer())
            net.WriteEntity(entity)
            net.SendToServer()
        end, function(text) end)
    end
end)