local MODULE = MODULE
MODULE.xpos = MODULE.xpos or 20
MODULE.ypos = MODULE.ypos or 20
AdminStickIsOpen = false
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
            if sam then
                RunConsoleCommand("sam", cmd, target:SteamID(), time, txt)
            else
                RunConsoleCommand("ulx", cmd, target:SteamID(), time, txt)
            end

            if sam then
                RunConsoleCommand("sam", cmd, target:SteamID(), txt)
            else
                RunConsoleCommand("ulx", cmd, target:SteamID(), txt)
            end
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
    if IsValid(target) then
        if IsValid(target) and target:IsPlayer() then
            local nameOption = AdminMenu:AddOption("Name: " .. target:Name() .. " (copy)", function()
                LocalPlayer():ChatPrint("Copied " .. target:Name() .. " to Clipboard!")
                SetClipboardText(target:Name())
                AdminStickIsOpen = false
            end)

            nameOption:SetIcon("icon16/page_copy.png")
            local charIDOption = AdminMenu:AddOption("CharID: " .. target:getChar():getID() .. " (copy)", function()
                LocalPlayer():ChatPrint("Copied CharID: " .. target:getChar():getID() .. " to Clipboard!")
                SetClipboardText(target:getChar():getID())
                AdminStickIsOpen = false
            end)

            charIDOption:SetIcon("icon16/page_copy.png")
            local steamIDOption = AdminMenu:AddOption("SteamID: " .. target:SteamID() .. " (copy)", function()
                LocalPlayer():ChatPrint("Copied " .. target:SteamID() .. " to Clipboard!")
                SetClipboardText(target:SteamID())
                AdminStickIsOpen = false
            end)

            steamIDOption:SetIcon("icon16/page_copy.png")
            local steamID64Option = AdminMenu:AddOption("SteamID64: " .. target:SteamID64() .. " (copy)", function()
                LocalPlayer():ChatPrint("Copied " .. target:SteamID64() .. " to Clipboard!")
                SetClipboardText(target:SteamID64())
                AdminStickIsOpen = false
            end)

            steamID64Option:SetIcon("icon16/page_copy.png")
            local moderationMenu = AdminMenu:AddSubMenu("Moderation Tools")
            if target:IsFrozen() then
                local unfreeze = moderationMenu:AddOption("Unfreeze", function()
                    if sam then
                        RunConsoleCommand("sam", "unfreeze", target:SteamID())
                    else
                        RunConsoleCommand("ulx", "unfreeze", target:SteamID())
                    end

                    AdminStickIsOpen = false
                end)

                unfreeze:SetIcon("icon16/unlock.png")
            else
                local freeze = moderationMenu:AddOption("Freeze", function()
                    if LocalPlayer() == target then
                        lia.notices.notify("You can't freeze yourself!")
                        return false
                    end

                    if sam then
                        RunConsoleCommand("sam", "freeze", target:SteamID())
                    else
                        RunConsoleCommand("ulx", "freeze", target:SteamID())
                    end

                    AdminStickIsOpen = false
                end)

                freeze:SetIcon("icon16/lock.png")
            end

            local ban = moderationMenu:AddOption("Ban", function() OpenReasonUI(target, "banid", 0) end)
            ban:SetIcon("icon16/exclamation.png")
            local kick = moderationMenu:AddOption("Kick", function() OpenReasonUI(target, "kick", 0) end)
            kick:SetIcon("icon16/door.png")
            local gag = moderationMenu:AddOption("Gag", function()
                if sam then
                    RunConsoleCommand("sam", "gag", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "gag", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            gag:SetIcon("icon16/sound_mute.png")
            local ungag = moderationMenu:AddOption("Ungag", function()
                if sam then
                    RunConsoleCommand("sam", "ungag", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "ungag", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            ungag:SetIcon("icon16/sound_low.png")
            local mute = moderationMenu:AddOption("Mute", function()
                if sam then
                    RunConsoleCommand("sam", "mute", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "mute", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            mute:SetIcon("icon16/sound_delete.png")
            local unmute = moderationMenu:AddOption("Unmute", function()
                if sam then
                    RunConsoleCommand("sam", "unmute", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "unmute", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            unmute:SetIcon("icon16/sound_add.png")
            local slay = moderationMenu:AddOption("Slay", function()
                if sam then
                    RunConsoleCommand("sam", "slay", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "slay", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            slay:SetIcon("icon16/bomb.png")
            local respawn = moderationMenu:AddOption("Respawn", function()
                if sam then
                    RunConsoleCommand("sam", "respawn", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "respawn", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            respawn:SetIcon("icon16/arrow_refresh.png")
            local jail = moderationMenu:AddOption("Jail", function()
                if sam then
                    RunConsoleCommand("sam", "jail", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "jail", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            jail:SetIcon("icon16/lock.png")
            local ignite = moderationMenu:AddOption("Ignite", function()
                if sam then
                    RunConsoleCommand("sam", "ignite", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "ignite", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            ignite:SetIcon("icon16/fire.png")
            local blind = moderationMenu:AddOption("Blind", function()
                if sam then
                    RunConsoleCommand("sam", "blind", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "blind", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            blind:SetIcon("icon16/eye.png")
            local unblind = moderationMenu:AddOption("Unblind", function()
                if sam then
                    RunConsoleCommand("sam", "unblind", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "unblind", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            unblind:SetIcon("icon16/eye.png")
            local freezeAllProps = moderationMenu:AddOption("Freeze All Props", function()
                LocalPlayer():ConCommand("say /freezeallprops " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            freezeAllProps:SetIcon("icon16/anchor.png")
            local charBan = moderationMenu:AddOption("Char Ban", function()
                LocalPlayer():ConCommand("say /charban " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            charBan:SetIcon("icon16/user_gray.png")
            local forceSay = moderationMenu:AddOption("Force Say", function()
                Derma_StringRequest("Force Say", "Enter the message for the player to say:", "", function(msg)
                    LocalPlayer():ConCommand("say /forcesay " .. target:SteamID() .. " " .. msg)
                    AdminStickIsOpen = false
                end)
            end)

            forceSay:SetIcon("icon16/comments.png")
            local characterMenu = AdminMenu:AddSubMenu("Character Management")
            for _, fac in pairs(lia.faction.teams) do
                if fac.index == target:getChar():getFaction() then
                    local factionMenu = characterMenu:AddSubMenu("Set Faction (" .. fac.name .. ")")
                    for _, v in pairs(lia.faction.teams) do
                        factionMenu:AddOption(v.name, function()
                            LocalPlayer():ConCommand('say /plytransfer "' .. target:SteamID() .. '" "' .. v.name .. '"')
                            AdminStickIsOpen = false
                        end)
                    end
                end
            end

            if #lia.faction.getClasses(target:getChar():getFaction()) > 1 then
                local classMenu = characterMenu:AddSubMenu("Set Class")
                for _, class in ipairs(lia.faction.getClasses(target:getChar():getFaction())) do
                    local classOption = classMenu:AddOption(class.name, function()
                        LocalPlayer():ConCommand('say /setclass "' .. target:SteamID() .. '" "' .. class.name .. '"')
                        AdminStickIsOpen = false
                    end)

                    classOption:SetIcon("icon16/user.png")
                end
            end

            local changeName = characterMenu:AddOption("Change Name", function()
                RunConsoleCommand("say", "/charsetname " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            changeName:SetIcon("icon16/user_gray.png")
            local changeDesc = characterMenu:AddOption("Change Description", function()
                RunConsoleCommand("say", "/charsetdesc " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            changeDesc:SetIcon("icon16/user_green.png")
            local changeModel = characterMenu:AddOption("Change Playermodel", function()
                OpenPlayerModelUI(target)
                AdminStickIsOpen = false
            end)

            changeModel:SetIcon("icon16/user_suit.png")
            local charkick = characterMenu:AddOption("Kick From Character", function()
                LocalPlayer():ConCommand('say /charkick "' .. target:SteamID() .. '"')
                AdminStickIsOpen = false
            end)

            charkick:SetIcon("icon16/lightning_delete.png")
            local inventoryMenu = characterMenu:AddSubMenu("Inventory & Economy")
            local returnItems = inventoryMenu:AddOption("Return Lost Items", function()
                LocalPlayer():ConCommand("say /returnitems " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            returnItems:SetIcon("icon16/box.png")
            local clearInv = inventoryMenu:AddOption("Clear Inventory", function()
                LocalPlayer():ConCommand("say /clearinv " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            clearInv:SetIcon("icon16/bin.png")
            local checkMoney = inventoryMenu:AddOption("Check Money", function()
                LocalPlayer():ConCommand("say /checkmoney " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            checkMoney:SetIcon("icon16/money.png")
            local setMoney = inventoryMenu:AddOption("Set Money", function()
                Derma_StringRequest("Set Money", "Enter amount of money:", "", function(amount)
                    LocalPlayer():ConCommand("say /charsetmoney " .. target:SteamID() .. " " .. amount)
                    AdminStickIsOpen = false
                end)
            end)

            setMoney:SetIcon("icon16/money.png")
            local addMoney = inventoryMenu:AddOption("Add Money", function()
                Derma_StringRequest("Add Money", "Enter amount of money to add:", "", function(amount)
                    LocalPlayer():ConCommand("say /charaddmoney " .. target:SteamID() .. " " .. amount)
                    AdminStickIsOpen = false
                end)
            end)

            addMoney:SetIcon("icon16/money_add.png")
            local appearanceMenu = characterMenu:AddSubMenu("Appearance")
            local listBodyGroups = appearanceMenu:AddOption("List Bodygroups", function()
                LocalPlayer():ConCommand("say /listbodygroups " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            listBodyGroups:SetIcon("icon16/user_suit.png")
            local getModel = appearanceMenu:AddOption("Get Model", function()
                LocalPlayer():ConCommand("say /chargetmodel " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            getModel:SetIcon("icon16/user.png")
            local setBodyGroup = appearanceMenu:AddOption("Set Bodygroup", function()
                Derma_StringRequest("Set Bodygroup", "Enter bodygroup name and value (e.g., head 1):", "", function(input)
                    local bName, bValue = input:match("([^%s]+)%s+(%d+)")
                    if bName and bValue then
                        LocalPlayer():ConCommand("say /charsetbodygroup " .. target:SteamID() .. " " .. bName .. " " .. bValue)
                    else
                        LocalPlayer():ChatPrint("Invalid format. Use: <bodyGroupName> <value>")
                    end

                    AdminStickIsOpen = false
                end)
            end)

            setBodyGroup:SetIcon("icon16/user_suit.png")
            local setSkin = appearanceMenu:AddOption("Set Skin", function()
                Derma_StringRequest("Set Skin", "Enter skin index:", "", function(skin)
                    LocalPlayer():ConCommand("say /charsetskin " .. target:SteamID() .. " " .. skin)
                    AdminStickIsOpen = false
                end)
            end)

            setSkin:SetIcon("icon16/color_wheel.png")
            local attributesMenu = characterMenu:AddSubMenu("Attributes & Stats")
            local setSpeed = attributesMenu:AddOption("Set Speed", function()
                Derma_StringRequest("Set Speed", "Enter new speed:", "", function(speed)
                    LocalPlayer():ConCommand("say /charsetspeed " .. target:SteamID() .. " " .. speed)
                    AdminStickIsOpen = false
                end)
            end)

            setSpeed:SetIcon("icon16/flag_blue.png")
            local setDesc = attributesMenu:AddOption("Set Description", function()
                Derma_StringRequest("Set Description", "Enter new description:", "", function(desc)
                    LocalPlayer():ConCommand("say /charsetdesc " .. target:SteamID() .. " " .. desc)
                    AdminStickIsOpen = false
                end)
            end)

            setDesc:SetIcon("icon16/comment_edit.png")
            local setName = attributesMenu:AddOption("Set Name", function()
                Derma_StringRequest("Set Name", "Enter new character name:", "", function(newName)
                    LocalPlayer():ConCommand("say /charsetname " .. target:SteamID() .. " " .. newName)
                    AdminStickIsOpen = false
                end)
            end)

            setName:SetIcon("icon16/user_edit.png")
            local setScale = attributesMenu:AddOption("Set Scale", function()
                Derma_StringRequest("Set Scale", "Enter scale value (e.g., 1):", "", function(scale)
                    LocalPlayer():ConCommand("say /charsetscale " .. target:SteamID() .. " " .. scale)
                    AdminStickIsOpen = false
                end)
            end)

            setScale:SetIcon("icon16/arrow_in.png")
            local setJump = attributesMenu:AddOption("Set Jump Power", function()
                Derma_StringRequest("Set Jump Power", "Enter jump power:", "", function(power)
                    LocalPlayer():ConCommand("say /charsetjump " .. target:SteamID() .. " " .. power)
                    AdminStickIsOpen = false
                end)
            end)

            setJump:SetIcon("icon16/arrow_up.png")
            local setAttrib = attributesMenu:AddOption("Set Attribute", function()
                Derma_StringRequest("Set Attribute", "Enter attribute name and level (e.g. strength 10):", "", function(input)
                    local attribName, attribLevel = input:match("([^%s]+)%s+(%d+)")
                    if attribName and attribLevel then
                        LocalPlayer():ConCommand("say /charsetattrib " .. target:SteamID() .. " " .. attribName .. " " .. attribLevel)
                    else
                        LocalPlayer():ChatPrint("Invalid format. Use: <attribname> <level>")
                    end

                    AdminStickIsOpen = false
                end)
            end)

            setAttrib:SetIcon("icon16/chart_bar_edit.png")
            local addAttrib = attributesMenu:AddOption("Add Attribute", function()
                Derma_StringRequest("Add Attribute", "Enter attribute name and amount (e.g. strength 5):", "", function(input)
                    local attribName, attribAmt = input:match("([^%s]+)%s+(%d+)")
                    if attribName and attribAmt then
                        LocalPlayer():ConCommand("say /charaddattrib " .. target:SteamID() .. " " .. attribName .. " " .. attribAmt)
                    else
                        LocalPlayer():ChatPrint("Invalid format. Use: <attribname> <amount>")
                    end

                    AdminStickIsOpen = false
                end)
            end)

            addAttrib:SetIcon("icon16/chart_bar_add.png")
            local pkMenu = characterMenu:AddSubMenu("PK Management")
            local pkToggle = pkMenu:AddOption("Toggle PK", function()
                LocalPlayer():ConCommand("say /pktoggle " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            pkToggle:SetIcon("icon16/user_red.png")
            local forcePK = pkMenu:AddOption("Force PK", function()
                LocalPlayer():ConCommand("say /charPK " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            forcePK:SetIcon("icon16/user_red.png")
            local teleportationMenu = AdminMenu:AddSubMenu("Teleportation")
            local gotoo = teleportationMenu:AddOption("Goto", function()
                if LocalPlayer() == target then
                    lia.notices.notify("You can't goto yourself!")
                    return false
                end

                if sam then
                    RunConsoleCommand("sam", "goto", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "goto", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            gotoo:SetIcon("icon16/arrow_right.png")
            local bring = teleportationMenu:AddOption("Bring", function()
                if LocalPlayer() == target then
                    lia.notices.notify("You can't bring yourself!")
                    return false
                end

                if sam then
                    RunConsoleCommand("sam", "bring", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "bring", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            bring:SetIcon("icon16/arrow_down.png")
            local returnf = teleportationMenu:AddOption("Return", function()
                if sam then
                    RunConsoleCommand("sam", "return", target:SteamID())
                elseif ulx then
                    RunConsoleCommand("ulx", "return", target:SteamID())
                end

                AdminStickIsOpen = false
            end)

            returnf:SetIcon("icon16/arrow_redo.png")
            local returnDeath = teleportationMenu:AddOption("Return to Death Position", function()
                LocalPlayer():ConCommand("say /return")
                AdminStickIsOpen = false
            end)

            returnDeath:SetIcon("icon16/arrow_undo.png")
            local flagsMenu = AdminMenu:AddSubMenu("Flags Management")
            local giveFlagsSubMenu = flagsMenu:AddSubMenu("Give Flags")
            for flag, _ in pairs(lia.flag.list) do
                if not target:getChar():hasFlags(flag) then
                    local giveFlag = giveFlagsSubMenu:AddOption("Give Flag " .. flag, function()
                        LocalPlayer():ConCommand('say /giveflag "' .. target:SteamID() .. '" "' .. flag .. '"')
                        AdminStickIsOpen = false
                    end)

                    giveFlag:SetIcon("icon16/flag_blue.png")
                end
            end

            local takeFlagsSubMenu = flagsMenu:AddSubMenu("Take Flags")
            for flag, _ in pairs(lia.flag.list) do
                if target:getChar():hasFlags(flag) then
                    local takeFlag = takeFlagsSubMenu:AddOption("Take Flag " .. flag, function()
                        LocalPlayer():ConCommand('say /takeflag "' .. target:SteamID() .. '" "' .. flag .. '"')
                        AdminStickIsOpen = false
                    end)

                    takeFlag:SetIcon("icon16/flag_red.png")
                end
            end

            local listFlags = flagsMenu:AddOption("List Flags", function()
                RunConsoleCommand("say", "/checkflags " .. target:SteamID())
                AdminStickIsOpen = false
            end)

            listFlags:SetIcon("icon16/find.png")
            local flagpet = flagsMenu:AddOption("Give/Take PET Flags", function()
                LocalPlayer():ConCommand('say /flagpet "' .. target:SteamID() .. '"')
                AdminStickIsOpen = false
            end)

            flagpet:SetIcon("icon16/find.png")
            if target:IsBot() then
                local botOption = AdminMenu:AddOption("Make Bot Say", function()
                    Derma_StringRequest("Make Bot Say", "Enter the message:", "", function(input)
                        LocalPlayer():ConCommand("say /botsay " .. target:Nick() .. " " .. input)
                        AdminStickIsOpen = false
                    end)
                end)

                botOption:SetIcon("icon16/comment.png")
            end
        elseif target:isDoor() then
            AdminMenu:AddOption("Toggle Door Hidden", function()
                LocalPlayer():ConCommand('say /doortogglehidden')
                AdminStickIsOpen = false
            end):SetIcon("icon16/eye.png")

            AdminMenu:AddOption("Toggle Door Ownable", function()
                LocalPlayer():ConCommand('say /doortoggleownable')
                AdminStickIsOpen = false
            end):SetIcon("icon16/house.png")

            AdminMenu:AddOption("Set Door Title", function()
                Derma_StringRequest("Set Door Title", "Enter the title for this door:", "", function(text)
                    if text and text ~= "" then LocalPlayer():ConCommand('say /doorsettitle "' .. text .. '"') end
                    AdminStickIsOpen = false
                end)
            end):SetIcon("icon16/tag.png")

            local factionsAssignedRaw = target:getNetVar("factions", "[]")
            local factionsAssigned = util.JSONToTable(factionsAssignedRaw) or {}
            local addFactionMenu = AdminMenu:AddSubMenu("Add Faction to Door")
            for _, faction in pairs(lia.faction.teams) do
                if not factionsAssigned[faction.index] then
                    addFactionMenu:AddOption(faction.name, function()
                        LocalPlayer():ConCommand('say /dooraddfaction "' .. faction.uniqueID .. '"')
                        AdminStickIsOpen = false
                    end)
                end
            end

            if table.Count(factionsAssigned) > 0 then
                local removeFactionMenu = AdminMenu:AddSubMenu("Remove Faction from Door")
                for id, _ in pairs(factionsAssigned) do
                    for _, faction in pairs(lia.faction.teams) do
                        if faction.index == id then
                            removeFactionMenu:AddOption(faction.name, function()
                                LocalPlayer():ConCommand('say /doorremovefaction "' .. faction.uniqueID .. '"')
                                AdminStickIsOpen = false
                            end)
                        end
                    end
                end
            else
                AdminMenu:AddOption("No factions assigned to this door"):SetEnabled(false)
            end

            AdminMenu:AddOption("View Door Info", function()
                LocalPlayer():ConCommand('say /doorinfo')
                AdminStickIsOpen = false
            end):SetIcon("icon16/information.png")

            AdminMenu:AddOption("Force Lock Door", function()
                LocalPlayer():ConCommand('say /doorforcelock')
                AdminStickIsOpen = false
            end):SetIcon("icon16/lock.png")

            AdminMenu:AddOption("Force Unlock Door", function()
                LocalPlayer():ConCommand('say /doorforceunlock')
                AdminStickIsOpen = false
            end):SetIcon("icon16/lock_open.png")

            AdminMenu:AddOption("Reset Door Data", function()
                LocalPlayer():ConCommand('say /doorresetdata')
                AdminStickIsOpen = false
            end):SetIcon("icon16/arrow_refresh.png")

            AdminMenu:AddOption("Set Door Parent", function()
                LocalPlayer():ConCommand('say /doorsetparent')
                AdminStickIsOpen = false
            end):SetIcon("icon16/link.png")

            AdminMenu:AddOption("Set Door Child", function()
                LocalPlayer():ConCommand('say /doorsetchild')
                AdminStickIsOpen = false
            end):SetIcon("icon16/link_add.png")

            AdminMenu:AddOption("Remove Child Link", function()
                LocalPlayer():ConCommand('say /doorremovechild')
                AdminStickIsOpen = false
            end):SetIcon("icon16/link_break.png")

            AdminMenu:AddOption("Set Door Class", function()
                Derma_StringRequest("Set Door Class", "Enter a class name:", "", function(text)
                    LocalPlayer():ConCommand('say /doorsetclass ' .. text)
                    AdminStickIsOpen = false
                end)
            end):SetIcon("icon16/user_suit.png")

            AdminMenu:AddOption("Save Doors", function()
                LocalPlayer():ConCommand('say /savedoors')
                AdminStickIsOpen = false
            end):SetIcon("icon16/disk.png")
        elseif target:GetClass() == "lia_vendor" then
            AdminMenu:AddOption("Restock Vendor", function()
                LocalPlayer():ConCommand("say /restockvendor")
                AdminStickIsOpen = false
            end):SetIcon("icon16/arrow_refresh.png")

            AdminMenu:AddOption("Restock Vendor Money", function()
                Derma_StringRequest("Restock Vendor Money", "Enter amount:", "", function(amount)
                    LocalPlayer():ConCommand("say /restockvendormoney " .. amount)
                    AdminStickIsOpen = false
                end)
            end):SetIcon("icon16/money_add.png")
        elseif target:GetClass() ~= "worldspawn" then
            local entityOption = AdminMenu:AddOption("Get Entity Name", function()
                LocalPlayer():ConCommand("say /entityInfo")
                AdminStickIsOpen = false
            end)

            entityOption:SetIcon("icon16/eye.png")
        end
    end

    function AdminMenu:OnClose()
        AdminStickIsOpen = false
    end

    AdminMenu:Open()
end

function MODULE:LoadFonts()
    surface.CreateFont("ticketsystem", {
        font = "Railway",
        size = 15,
        weight = 400
    })
end

function MODULE:TicketFrame(requester, message, claimed)
    if not TicketFrames then TicketFrames = {} end
    local mat_lightning = Material("icon16/lightning_go.png")
    local mat_arrow = Material("icon16/arrow_left.png")
    local mat_link = Material("icon16/link.png")
    local mat_case = Material("icon16/briefcase.png")
    if not IsValid(requester) or not requester:IsPlayer() then return end
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then
            local txt = v:GetChildren()[5]
            txt:AppendText("\n" .. message)
            txt:GotoTextEnd()
            timer.Remove("ticketsystem-" .. requester:SteamID64())
            timer.Create("ticketsystem-" .. requester:SteamID64(), self.Autoclose, 1, function() if IsValid(v) then v:Remove() end end)
            surface.PlaySound("ui/hint.wav")
            return
        end
    end

    local xpos = self.xpos
    local ypos = self.ypos
    local w, h = 300, 120
    local frm = vgui.Create("DFrame")
    frm:SetSize(w, h)
    frm:SetPos(xpos, ypos)
    frm.idiot = requester
    function frm:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 230))
    end

    frm.lblTitle:SetColor(Color(255, 255, 255))
    frm.lblTitle:SetFont("ticketsystem")
    frm.lblTitle:SetContentAlignment(7)
    if claimed and IsValid(claimed) and claimed:IsPlayer() then
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
    msg:SetVerticalScrollbarEnabled(false)
    function msg:PerformLayout()
        self:SetFontInternal("DermaDefault")
    end

    msg:AppendText(message)
    local function createButton(text, material, position, clickFunc)
        local btn = vgui.Create("DButton", frm)
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

    createButton("Goto", mat_lightning, 20 * 1, function()
        if sam then
            RunConsoleCommand("sam", "goto", requester:SteamID())
        elseif ulx then
            RunConsoleCommand("ulx", "goto", target:SteamID())
        end
    end)

    createButton("Return", mat_arrow, 20 * 2, function()
        if sam then
            RunConsoleCommand("sam", "return", requester:SteamID())
        elseif ulx then
            RunConsoleCommand("ulx", "return", target:SteamID())
        end
    end)

    createButton("Freeze", mat_link, 20 * 3, function()
        if sam then
            RunConsoleCommand("sam", "freeze", requester:SteamID())
        elseif ulx then
            RunConsoleCommand("ulx", "freeze", target:SteamID())
        end
    end)

    createButton("Bring", mat_arrow, 20 * 4, function()
        if sam then
            RunConsoleCommand("sam", "bring", requester:SteamID())
        elseif ulx then
            RunConsoleCommand("ulx", "bring", target:SteamID())
        end
    end)

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
    frm:SetPos(xpos, ypos + (130 * #TicketFrames))
    frm:MoveTo(xpos, ypos + (130 * #TicketFrames), 0.2, 0, 1, function() surface.PlaySound("garrysmod/balloon_pop_cute.wav") end)
    function frm:OnRemove()
        if TicketFrames then
            table.RemoveByValue(TicketFrames, frm)
            for k, v in ipairs(TicketFrames) do
                v:MoveTo(xpos, ypos + (130 * (k - 1)), 0.1, 0, 1, function() end)
            end
        end

        if IsValid(requester) and timer.Exists("ticketsystem-" .. requester:SteamID64()) then timer.Remove("ticketsystem-" .. requester:SteamID64()) end
    end

    table.insert(TicketFrames, frm)
    timer.Create("ticketsystem-" .. requester:SteamID64(), self.Autoclose, 1, function() if IsValid(frm) then frm:Remove() end end)
end

CreateClientConVar("cl_ticketsystem_closeclaimed", 0, true, false)
CreateClientConVar("cl_ticketsystem_dutymode", 0, true, false)