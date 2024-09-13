AdminStickIsOpen = false

local function OnPrivilegeRegistered(privilege)
    local permission = privilege.Name
    serverguard.permission:Add(permission)
end

local function RegisterPrivileges()
    if CAMI then
        for _, v in pairs(CAMI.GetPrivileges()) do
            OnPrivilegeRegistered(v)
        end
    end
end

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
    if target:IsPlayer() then
        local name = AdminMenu:AddOption("Name: " .. target:Name() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:Name() .. " to Clipboard!")
            SetClipboardText(target:Name())
            AdminStickIsOpen = false
        end)

        name:SetIcon("icon16/information.png")
        local charid = AdminMenu:AddOption("CharID: " .. target:getChar():getID() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied CharID: " .. target:getChar():getID() .. " to Clipboard!")
            SetClipboardText(target:getChar():getID())
            AdminStickIsOpen = false
        end)

        charid:SetIcon("icon16/information.png")
        local steamid = AdminMenu:AddOption("SteamID: " .. target:SteamID() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID() .. " to Clipboard!")
            SetClipboardText(target:SteamID())
            AdminStickIsOpen = false
        end)

        steamid:SetIcon("icon16/information.png")
        local steamid64 = AdminMenu:AddOption("SteamID64: " .. target:SteamID64() .. " (left click to copy)", function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID64() .. " to Clipboard!")
            SetClipboardText(target:SteamID64())
            AdminStickIsOpen = false
        end)

        steamid64:SetIcon("icon16/information.png")
        local playerInfo = AdminMenu:AddSubMenu("Administration")
        if sam then
            if target:IsFrozen() then
                local unfreeze = playerInfo:AddOption("Unfreeze", function()
                    RunConsoleCommand("sam", "unfreeze", target:SteamID())
                    AdminStickIsOpen = false
                end)

                unfreeze:SetIcon("icon16/disconnect.png")
            else
                local freeze = playerInfo:AddOption("Freeze", function()
                    if LocalPlayer() == target then
                        lia.notices.notify("You can't freeze yourself!")
                        return false
                    end

                    RunConsoleCommand("sam", "freeze", target:SteamID())
                    AdminStickIsOpen = false
                end)

                freeze:SetIcon("icon16/connect.png")
            end

            local ban = playerInfo:AddOption("Ban", function() OpenReasonUI(target, "banid", 0) end)
            ban:SetIcon("icon16/cancel.png")
            local kick = playerInfo:AddOption("Kick", function() OpenReasonUI(target, "kick", 0) end)
            kick:SetIcon("icon16/delete.png")
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
        if sam then
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
        end

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

        local listflags = flags:AddOption("List Flags", function()
            LocalPlayer():ConCommand('say /flaglist "' .. target:SteamID() .. '"')
            AdminStickIsOpen = false
        end)

        listflags:SetIcon("icon16/find.png")
        local blacklist = flags:AddOption("Give/Take PET Flags", function()
            LocalPlayer():ConCommand('say /flagpet "' .. target:SteamID() .. '"')
            AdminStickIsOpen = false
        end)

        blacklist:SetIcon("icon16/cross.png")
    end

    hook.Run("AdminStickMenuAdd", AdminMenu, target)
    function AdminMenu:OnClose()
        AdminStickIsOpen = false
    end

    AdminMenu:Open()
    AdminMenu:Center()
end

RegisterPrivileges()