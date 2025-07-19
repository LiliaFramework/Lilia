local MODULE = MODULE
AdminStickIsOpen = false
local subMenuIcons = {
    moderationTools = "icon16/wrench.png",
    playerInformation = "icon16/information.png",
    characterManagement = "icon16/user_gray.png",
    flagsManagement = "icon16/flag_blue.png",
    giveFlagsMenu = "icon16/flag_blue.png",
    takeFlagsMenu = "icon16/flag_red.png",
}

local function GetOrCreateSubMenu(parent, name, store)
    if not store[name] then
        local menu, panel = parent:AddSubMenu(L(name))
        if subMenuIcons[name] then panel:SetIcon(subMenuIcons[name]) end
        store[name] = menu
    end
    return store[name]
end

local function GetIdentifier(ent)
    if not IsValid(ent) or not ent:IsPlayer() then return "" end
    if ent:IsBot() then return ent:Name() end
    return ent:SteamID()
end

local function QuoteArgs(...)
    local args = {}
    for _, v in ipairs({...}) do
        args[#args + 1] = string.format("'%s'", tostring(v))
    end
    return table.concat(args, " ")
end

local function RunAdminCommand(cmd, tgt, dur, reason, fallback)
    local cl = LocalPlayer()
    local victim = IsValid(tgt) and tgt:IsPlayer() and (tgt:IsBot() and tgt:Name() or tgt:SteamID()) or tgt
    hook.Run("RunAdminSystemCommand", cmd, cl, victim, dur, reason)
end

local function OpenPlayerModelUI(tgt)
    AdminStickIsOpen = true
    local fr = vgui.Create("DFrame")
    fr:SetTitle(L("changePlayerModel"))
    fr:SetSize(450, 300)
    fr:Center()
    function fr:OnClose()
        fr:Remove()
        AdminStickIsOpen = false
    end

    local sc = vgui.Create("DScrollPanel", fr)
    sc:Dock(FILL)
    local wr = vgui.Create("DIconLayout", sc)
    wr:Dock(FILL)
    local ed = vgui.Create("DTextEntry", fr)
    ed:Dock(BOTTOM)
    ed:SetText(tgt:GetModel())
    local bt = vgui.Create("DButton", fr)
    bt:SetText(L("change"))
    bt:Dock(TOP)
    function bt:DoClick()
        local txt = ed:GetValue()
        local id = GetIdentifier(tgt)
        if id ~= "" then RunConsoleCommand("say", "/charsetmodel " .. QuoteArgs(id, txt)) end
        fr:Remove()
        AdminStickIsOpen = false
    end

    local modList = {}
    for n, m in SortedPairs(player_manager.AllValidModels()) do
        table.insert(modList, {
            name = n,
            mdl = m
        })
    end

    table.sort(modList, function(a, b) return a.name < b.name end)
    for _, md in ipairs(modList) do
        local ic = wr:Add("SpawnIcon")
        ic:SetModel(md.mdl)
        ic:SetSize(64, 64)
        ic:SetTooltip(md.name)
        ic.model_path = md.mdl
        ic.DoClick = function() ed:SetValue(ic.model_path) end
    end

    fr:MakePopup()
end

local function OpenReasonUI(tgt, cmd)
    AdminStickIsOpen = true
    local fr = vgui.Create("DFrame")
    fr:SetTitle(L("reasonFor", cmd))
    fr:SetSize(300, 150)
    fr:Center()
    function fr:OnClose()
        fr:Remove()
        AdminStickIsOpen = false
    end

    local ed = vgui.Create("DTextEntry", fr)
    ed:Dock(FILL)
    ed:SetMultiline(true)
    ed:SetPlaceholderText(L("reason"))
    local ts
    if cmd == "banid" then
        ts = vgui.Create("DNumSlider", fr)
        ts:Dock(TOP)
        ts:SetText(L("lengthInDays"))
        ts:SetMin(0)
        ts:SetMax(365)
        ts:SetDecimals(0)
    end

    local bt = vgui.Create("DButton", fr)
    bt:Dock(BOTTOM)
    bt:SetText(L("change"))
    function bt:DoClick()
        local txt = ed:GetValue()
        local id = GetIdentifier(tgt)
        if cmd == "banid" then
            if id ~= "" then
                local len = ts and ts:GetValue() * 60 * 24 or 0
                RunAdminCommand("ban", tgt, len, txt, "!banid " .. QuoteArgs(id, len, txt))
            end
        elseif cmd == "kick" then
            if id ~= "" then RunAdminCommand("kick", tgt, nil, txt, "!kick " .. QuoteArgs(id, txt)) end
        end

        fr:Remove()
        AdminStickIsOpen = false
    end

    fr:MakePopup()
end

local function HandleModerationOption(opt, tgt)
    if opt.name == "Ban" then
        OpenReasonUI(tgt, "banid")
    elseif opt.name == "Kick" then
        OpenReasonUI(tgt, "kick")
    else
        local cmdName = opt.cmd:match("!([^%s]+)")
        RunAdminCommand(cmdName, tgt, nil, nil, opt.cmd)
    end

    AdminStickIsOpen = false
end

local function IncludeAdminMenu(tgt, menu, stores)
    local cl = LocalPlayer()
    if cl:GetUserGroup() == "user" then return end
    local mod = GetOrCreateSubMenu(menu, "moderationTools", stores)
    local tp = {
        {
            name = "Bring",
            cmd = "!bring " .. QuoteArgs(GetIdentifier(tgt)),
            icon = "icon16/arrow_down.png"
        },
        {
            name = "Goto",
            cmd = "!goto " .. QuoteArgs(GetIdentifier(tgt)),
            icon = "icon16/arrow_right.png"
        },
        {
            name = "Return",
            cmd = "!return " .. QuoteArgs(GetIdentifier(tgt)),
            icon = "icon16/arrow_redo.png"
        },
        {
            name = "Respawn",
            cmd = "!respawn " .. QuoteArgs(GetIdentifier(tgt)),
            icon = "icon16/arrow_refresh.png"
        }
    }

    local mods = {
        {
            action = {
                name = "Blind",
                cmd = "!blind " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/eye.png"
            },
            inverse = {
                name = "Unblind",
                cmd = "!unblind " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/eye.png"
            }
        },
        {
            action = {
                name = "Freeze",
                cmd = "!freeze " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/lock.png"
            },
            inverse = {
                name = "Unfreeze",
                cmd = "!unfreeze " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/accept.png"
            }
        },
        {
            action = {
                name = "Gag",
                cmd = "!gag " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/sound_mute.png"
            },
            inverse = {
                name = "Ungag",
                cmd = "!ungag " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/sound_low.png"
            }
        },
        {
            action = {
                name = "Mute",
                cmd = "!mute " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/sound_delete.png"
            },
            inverse = {
                name = "Unmute",
                cmd = "!unmute " .. QuoteArgs(GetIdentifier(tgt)),
                icon = "icon16/sound_add.png"
            }
        },
        {
            name = "Ignite",
            cmd = "!ignite " .. QuoteArgs(GetIdentifier(tgt)),
            icon = "icon16/fire.png"
        },
        {
            name = "Jail",
            cmd = "!jail " .. QuoteArgs(GetIdentifier(tgt)),
            icon = "icon16/lock.png"
        },
        {
            name = "Slay",
            cmd = "!slay " .. QuoteArgs(GetIdentifier(tgt)),
            icon = "icon16/bomb.png"
        }
    }

    table.sort(mods, function(a, b)
        local na = a.action and a.action.name or a.name
        local nb = b.action and b.action.name or b.name
        return na < nb
    end)

    table.sort(tp, function(a, b) return a.name < b.name end)
    for _, p in ipairs(mods) do
        if p.action then
            mod:AddOption(L(p.action.name), function() HandleModerationOption(p.action, tgt) end):SetIcon(p.action.icon)
            if p.inverse then mod:AddOption(L(p.inverse.name), function() HandleModerationOption(p.inverse, tgt) end):SetIcon(p.inverse.icon) end
        else
            mod:AddOption(L(p.name), function() HandleModerationOption(p, tgt) end):SetIcon(p.icon)
        end
    end

    for _, o in ipairs(tp) do
        mod:AddOption(L(o.name), function()
            cl:ChatPrint(L("adminStickExecutedCommand", o.cmd))
            local cmdName = o.cmd:match("!([^%s]+)")
            RunAdminCommand(cmdName, tgt, nil, nil, o.cmd)
            AdminStickIsOpen = false
        end):SetIcon(o.icon)
    end
end

local function IncludeCharacterManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    local canFaction = cl:hasPrivilege("Commands - Manage Transfers")
    local canClass = cl:hasPrivilege("Commands - Manage Classes")
    local charMenu = GetOrCreateSubMenu(menu, "characterManagement", stores)
    local char = tgt:getChar()
    if char and canFaction then
        local facID = char:getFaction()
        local curName = L("unknown")
        local facOptions = {}
        if facID then
            for _, f in pairs(lia.faction.teams) do
                if f.index == facID then
                    curName = f.name
                    for _, v in pairs(lia.faction.teams) do
                        table.insert(facOptions, {
                            name = v.name,
                            cmd = 'say /plytransfer ' .. QuoteArgs(GetIdentifier(tgt), v.name)
                        })
                    end

                    break
                end
            end

            table.sort(facOptions, function(a, b) return a.name < b.name end)
            if #facOptions > 0 then
                local fm = GetOrCreateSubMenu(charMenu, L("setFactionTitle", curName), stores)
                for _, o in ipairs(facOptions) do
                    fm:AddOption(L(o.name), function()
                        cl:ConCommand(o.cmd)
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/group.png")
                end
            end

            local classes = lia.faction.getClasses and lia.faction.getClasses(facID) or {}
            if classes and #classes > 1 and canClass then
                local cls = {}
                for _, c in ipairs(classes) do
                    table.insert(cls, {
                        name = c.name,
                        cmd = 'say /setclass ' .. QuoteArgs(GetIdentifier(tgt), c.uniqueID)
                    })
                end

                table.sort(cls, function(a, b) return a.name < b.name end)
                local cm = GetOrCreateSubMenu(charMenu, "Set Class", stores)
                for _, o in ipairs(cls) do
                    cm:AddOption(L(o.name), function()
                        cl:ConCommand(o.cmd)
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/user.png")
                end
            end
        end
    end

    if cl:hasPrivilege("Commands - Manage Character Information") then
        charMenu:AddOption(L("changePlayerModel"), function()
            OpenPlayerModelUI(tgt)
            AdminStickIsOpen = false
        end):SetIcon("icon16/user_suit.png")
    end
end

local function IncludeFlagManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    if not cl:hasPrivilege("Commands - Manage Flags") then return end
    local charMenu = GetOrCreateSubMenu(menu, "characterManagement", stores)
    local fm = GetOrCreateSubMenu(charMenu, "flagsManagement", stores)
    local give = GetOrCreateSubMenu(fm, "giveFlagsMenu", stores)
    local take = GetOrCreateSubMenu(fm, "takeFlagsMenu", stores)
    local toGive, toTake = {}, {}
    for fl in pairs(lia.flag.list) do
        if not tgt:getChar():hasFlags(fl) then
            table.insert(toGive, {
                name = L("giveFlagFormat", fl),
                cmd = 'say /giveflag ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_blue.png"
            })
        else
            table.insert(toTake, {
                name = L("takeFlagFormat", fl),
                cmd = 'say /takeflag ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_red.png"
            })
        end
    end

    table.sort(toGive, function(a, b) return a.name < b.name end)
    table.sort(toTake, function(a, b) return a.name < b.name end)
    for _, f in ipairs(toGive) do
        give:AddOption(L(f.name), function()
            cl:ConCommand(f.cmd)
            AdminStickIsOpen = false
        end):SetIcon(f.icon)
    end

    for _, f in ipairs(toTake) do
        take:AddOption(L(f.name), function()
            cl:ConCommand(f.cmd)
            AdminStickIsOpen = false
        end):SetIcon(f.icon)
    end
end

local function AddCommandToMenu(menu, data, key, tgt, name, stores)
    local cl = LocalPlayer()
    local can = lia.command.hasAccess(cl, key, data)
    if not can then return end
    local cat = data.AdminStick.Category
    local sub = data.AdminStick.SubCategory
    local m = menu
    if cat then m = GetOrCreateSubMenu(menu, cat, stores) end
    if sub then m = GetOrCreateSubMenu(m, sub, stores) end
    local ic = data.AdminStick.Icon or "icon16/page.png"
    m:AddOption(L(name), function()
        local id = GetIdentifier(tgt)
        local cmd = "say /" .. key
        if id ~= "" then cmd = cmd .. " " .. QuoteArgs(id) end
        cl:ConCommand(cmd)
        AdminStickIsOpen = false
    end):SetIcon(ic)
end

local function hasAdminStickTargetClass(class)
    for _, c in pairs(lia.command.list) do
        if istable(c.AdminStick) and c.AdminStick.TargetClass == class then return true end
    end
    return false
end

function MODULE:OpenAdminStickUI(tgt)
    local cl = LocalPlayer()
    if not IsValid(tgt) or not tgt:isDoor() and not tgt:IsPlayer() and not hasAdminStickTargetClass(tgt:GetClass()) then return end
    AdminStickIsOpen = true
    local menu = DermaMenu()
    menu:Center()
    menu:MakePopup()
    local stores = {}
    if tgt:IsPlayer() then
        local info = {
            {
                name = L("charIDCopyFormat", tgt:getChar() and tgt:getChar():getID() or L("na")),
                cmd = function()
                    if tgt:getChar() then
                        cl:ChatPrint(L("copiedCharID", tgt:getChar():getID()))
                        SetClipboardText(tgt:getChar():getID())
                    end

                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", tgt:Name()),
                cmd = function()
                    cl:ChatPrint(L("copiedToClipboard", tgt:Name(), "Name"))
                    SetClipboardText(tgt:Name())
                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", tgt:SteamID()),
                cmd = function()
                    cl:ChatPrint(L("copiedToClipboard", tgt:Name(), "SteamID"))
                    SetClipboardText(tgt:SteamID())
                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamID64CopyFormat", tgt:SteamID64()),
                cmd = function()
                    cl:ChatPrint(L("copiedToClipboard", tgt:Name(), "SteamID64"))
                    SetClipboardText(tgt:SteamID64())
                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            }
        }

        table.sort(info, function(a, b) return a.name < b.name end)
        local pi = GetOrCreateSubMenu(menu, "playerInformation", stores)
        for _, o in ipairs(info) do
            pi:AddOption(L(o.name), o.cmd):SetIcon(o.icon)
        end

        IncludeAdminMenu(tgt, menu, stores)
        IncludeCharacterManagement(tgt, menu, stores)
        IncludeFlagManagement(tgt, menu, stores)
    end

    local tgtClass = tgt:GetClass()
    local cmds = {}
    for k, v in pairs(lia.command.list) do
        if v.AdminStick and istable(v.AdminStick) then
            local tc = v.AdminStick.TargetClass
            if tc then
                if tc == "Door" and tgt:isDoor() or tc == tgtClass then
                    table.insert(cmds, {
                        name = v.AdminStick.Name or k,
                        data = v,
                        key = k
                    })
                end
            else
                if tgt:IsPlayer() then
                    table.insert(cmds, {
                        name = v.AdminStick.Name or k,
                        data = v,
                        key = k
                    })
                end
            end
        end
    end

    table.sort(cmds, function(a, b) return a.name < b.name end)
    for _, c in ipairs(cmds) do
        AddCommandToMenu(menu, c.data, c.key, tgt, c.name, stores)
    end

    hook.Run("PopulateAdminStick", menu, tgt)
    function menu:OnRemove()
        cl.AdminStickTarget = nil
        AdminStickIsOpen = false
    end

    menu:Open()
end