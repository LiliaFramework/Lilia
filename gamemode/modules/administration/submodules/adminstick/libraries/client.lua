local MODULE = MODULE
AdminStickIsOpen = false
local playerInfoLabel = L("player") .. " " .. L("information")
local giveFlagsLabel = L("give") .. " " .. L("flags")
local takeFlagsLabel = L("take") .. " " .. L("flags")
local subMenuIcons = {
    moderationTools = "icon16/wrench.png",
    [playerInfoLabel] = "icon16/information.png",
    characterManagement = "icon16/user_gray.png",
    attributes = "icon16/chart_line.png",
    flagsManagement = "icon16/flag_blue.png",
    charFlagsTitle = "icon16/flag_green.png",
    playerFlagsTitle = "icon16/flag_orange.png",
    [giveFlagsLabel] = "icon16/flag_blue.png",
    [takeFlagsLabel] = "icon16/flag_red.png",
    doorManagement = "icon16/door.png",
    doorActions = "icon16/arrow_switch.png",
    doorSettings = "icon16/cog.png",
    doorMaintenance = "icon16/wrench.png",
    doorInformation = "icon16/information.png",
    items = "icon16/box.png",
    misc = "icon16/application_view_tile.png",
    ooc = "icon16/comment.png",
    warnings = "icon16/error.png",
    adminStickSubCategoryBans = "icon16/lock.png",
    adminStickSubCategoryGetInfos = "icon16/magnifier.png",
    adminStickSubCategorySetInfos = "icon16/pencil.png",
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

local function RunAdminCommand(cmd, tgt, dur, reason)
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
                RunAdminCommand("ban", tgt, len, txt)
            end
        elseif cmd == "kick" then
            if id ~= "" then RunAdminCommand("kick", tgt, nil, txt) end
        end

        fr:Remove()
        AdminStickIsOpen = false
    end

    fr:MakePopup()
end

local function HandleModerationOption(opt, tgt)
    if opt.name == L("ban") then
        OpenReasonUI(tgt, "banid")
    elseif opt.name == L("kick") then
        OpenReasonUI(tgt, "kick")
    else
        RunAdminCommand(opt.cmd, tgt)
    end

    AdminStickIsOpen = false
end

local function IncludeAdminMenu(tgt, menu, stores)
    local cl = LocalPlayer()
    if not (cl:hasPrivilege(L("useAdminStick")) or cl:isStaffOnDuty()) then return end
    local mod = GetOrCreateSubMenu(menu, "moderationTools", stores)
    local tp = {
        {
            name = L("bring"),
            cmd = "bring",
            icon = "icon16/arrow_down.png"
        },
        {
            name = L("goTo"),
            cmd = "goto",
            icon = "icon16/arrow_right.png"
        },
        {
            name = L("returnText"),
            cmd = "return",
            icon = "icon16/arrow_redo.png"
        },
        {
            name = L("respawn"),
            cmd = "respawn",
            icon = "icon16/arrow_refresh.png"
        }
    }

    local mods = {
        {
            action = {
                name = L("blind"),
                cmd = "blind",
                icon = "icon16/eye.png"
            },
            inverse = {
                name = L("unblind"),
                cmd = "unblind",
                icon = "icon16/eye.png"
            }
        },
        {
            action = {
                name = L("freeze"),
                cmd = "freeze",
                icon = "icon16/lock.png"
            },
            inverse = {
                name = L("unfreeze"),
                cmd = "unfreeze",
                icon = "icon16/accept.png"
            }
        },
        {
            action = {
                name = L("gag"),
                cmd = "gag",
                icon = "icon16/sound_mute.png"
            },
            inverse = {
                name = L("ungag"),
                cmd = "ungag",
                icon = "icon16/sound_low.png"
            }
        },
        {
            action = {
                name = L("mute"),
                cmd = "mute",
                icon = "icon16/sound_delete.png"
            },
            inverse = {
                name = L("unmute"),
                cmd = "unmute",
                icon = "icon16/sound_add.png"
            }
        },
        {
            name = L("ignite"),
            cmd = "ignite",
            icon = "icon16/fire.png"
        },
        {
            name = L("jail"),
            cmd = "jail",
            icon = "icon16/lock.png"
        },
        {
            name = L("slay"),
            cmd = "slay",
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
            cl:notifyLocalized("adminStickExecutedCommand", o.cmd .. " " .. QuoteArgs(GetIdentifier(tgt)))
            RunAdminCommand(o.cmd, tgt)
            AdminStickIsOpen = false
        end):SetIcon(o.icon)
    end
end

local function IncludeCharacterManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    local canFaction = cl:hasPrivilege(L("manageTransfers"))
    local canClass = cl:hasPrivilege(L("manageClasses"))
    local canWhitelist = cl:hasPrivilege(L("manageWhitelists"))
    local charMenu = GetOrCreateSubMenu(menu, "characterManagement", stores)
    local char = tgt:getChar()
    if char then
        local facID = char:getFaction()
        local curName
        if facID then
            if canFaction then
                local facOptions = {}
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
                    local fm = GetOrCreateSubMenu(charMenu, L("setFactionTitle", curName or L("unknown")), stores)
                    for _, o in ipairs(facOptions) do
                        fm:AddOption(L(o.name), function()
                            cl:ConCommand(o.cmd)
                            AdminStickIsOpen = false
                        end):SetIcon("icon16/group.png")
                    end
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
                local cm = GetOrCreateSubMenu(charMenu, "adminStickSetClassName", stores)
                for _, o in ipairs(cls) do
                    cm:AddOption(L(o.name), function()
                        cl:ConCommand(o.cmd)
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/user.png")
                end
            end

            if canWhitelist then
                local facAdd, facRemove = {}, {}
                for _, v in pairs(lia.faction.teams) do
                    if not v.isDefault then
                        if not tgt:hasWhitelist(v.index) then
                            table.insert(facAdd, {
                                name = v.name,
                                cmd = 'say /plywhitelist ' .. QuoteArgs(GetIdentifier(tgt), v.name)
                            })
                        else
                            table.insert(facRemove, {
                                name = v.name,
                                cmd = 'say /plyunwhitelist ' .. QuoteArgs(GetIdentifier(tgt), v.name)
                            })
                        end
                    end
                end

                table.sort(facAdd, function(a, b) return a.name < b.name end)
                table.sort(facRemove, function(a, b) return a.name < b.name end)
                local fw = GetOrCreateSubMenu(charMenu, "adminStickFactionWhitelistName", stores)
                for _, o in ipairs(facAdd) do
                    fw:AddOption(L(o.name), function()
                        cl:ConCommand(o.cmd)
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/group_add.png")
                end

                local fu = GetOrCreateSubMenu(charMenu, "adminStickUnwhitelistName", stores)
                for _, o in ipairs(facRemove) do
                    fu:AddOption(L(o.name), function()
                        cl:ConCommand(o.cmd)
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/group_delete.png")
                end

                if classes and #classes > 0 then
                    local cw, cu = {}, {}
                    for _, c in ipairs(classes) do
                        if lia.class.hasWhitelist(c.index) then
                            if not tgt:hasClassWhitelist(c.index) then
                                table.insert(cw, {
                                    name = c.name,
                                    cmd = 'say /classwhitelist ' .. QuoteArgs(GetIdentifier(tgt), c.uniqueID)
                                })
                            else
                                table.insert(cu, {
                                    name = c.name,
                                    cmd = 'say /classunwhitelist ' .. QuoteArgs(GetIdentifier(tgt), c.uniqueID)
                                })
                            end
                        end
                    end

                    table.sort(cw, function(a, b) return a.name < b.name end)
                    table.sort(cu, function(a, b) return a.name < b.name end)
                    local cwm = GetOrCreateSubMenu(charMenu, "adminStickClassWhitelistName", stores)
                    for _, o in ipairs(cw) do
                        cwm:AddOption(L(o.name), function()
                            cl:ConCommand(o.cmd)
                            AdminStickIsOpen = false
                        end):SetIcon("icon16/user_add.png")
                    end

                    local cum = GetOrCreateSubMenu(charMenu, "adminStickClassUnwhitelistName", stores)
                    for _, o in ipairs(cu) do
                        cum:AddOption(L(o.name), function()
                            cl:ConCommand(o.cmd)
                            AdminStickIsOpen = false
                        end):SetIcon("icon16/user_delete.png")
                    end
                end
            end
        end
    end

    if cl:hasPrivilege(L("manageCharacterInformation")) then
        charMenu:AddOption(L("changePlayerModel"), function()
            OpenPlayerModelUI(tgt)
            AdminStickIsOpen = false
        end):SetIcon("icon16/user_suit.png")
    end
end

local function IncludeFlagManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    if not cl:hasPrivilege(L("manageFlags")) then return end
    local charMenu = GetOrCreateSubMenu(menu, "characterManagement", stores)
    local fm = GetOrCreateSubMenu(charMenu, "flagsManagement", stores)
    local cf = GetOrCreateSubMenu(fm, "charFlagsTitle", stores)
    local cGive = GetOrCreateSubMenu(cf, giveFlagsLabel, stores)
    local cTake = GetOrCreateSubMenu(cf, takeFlagsLabel, stores)
    local charObj = tgt:getChar()
    local toGive, toTake = {}, {}
    for fl in pairs(lia.flag.list) do
        if not charObj or not charObj:hasFlags(fl) then
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
        cGive:AddOption(L(f.name), function()
            cl:ConCommand(f.cmd)
            AdminStickIsOpen = false
        end):SetIcon(f.icon)
    end

    for _, f in ipairs(toTake) do
        cTake:AddOption(L(f.name), function()
            cl:ConCommand(f.cmd)
            AdminStickIsOpen = false
        end):SetIcon(f.icon)
    end

    cf:AddOption(L("modifyCharFlags"), function()
        local currentFlags = charObj and charObj:getFlags() or ""
        Derma_StringRequest(L("modifyCharFlags"), L("modifyFlagsDesc"), currentFlags, function(text)
            text = string.gsub(text or "", "%s", "")
            net.Start("liaModifyFlags")
            net.WriteString(tgt:SteamID())
            net.WriteString(text)
            net.WriteBool(false)
            net.SendToServer()
        end)

        AdminStickIsOpen = false
    end):SetIcon("icon16/flag_orange.png")

    local pf = GetOrCreateSubMenu(fm, "playerFlagsTitle", stores)
    local pGive = GetOrCreateSubMenu(pf, giveFlagsLabel, stores)
    local pTake = GetOrCreateSubMenu(pf, takeFlagsLabel, stores)
    local toGiveP, toTakeP = {}, {}
    for fl in pairs(lia.flag.list) do
        if not tgt:hasPlayerFlags(fl) then
            table.insert(toGiveP, {
                name = L("giveFlagFormat", fl),
                cmd = 'say /pflaggive ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_blue.png"
            })
        else
            table.insert(toTakeP, {
                name = L("takeFlagFormat", fl),
                cmd = 'say /pflagtake ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_red.png"
            })
        end
    end

    table.sort(toGiveP, function(a, b) return a.name < b.name end)
    table.sort(toTakeP, function(a, b) return a.name < b.name end)
    for _, f in ipairs(toGiveP) do
        pGive:AddOption(L(f.name), function()
            cl:ConCommand(f.cmd)
            AdminStickIsOpen = false
        end):SetIcon(f.icon)
    end

    for _, f in ipairs(toTakeP) do
        pTake:AddOption(L(f.name), function()
            cl:ConCommand(f.cmd)
            AdminStickIsOpen = false
        end):SetIcon(f.icon)
    end

    pf:AddOption(L("modifyPlayerFlags"), function()
        local currentFlags = tgt:getPlayerFlags()
        Derma_StringRequest(L("modifyPlayerFlags"), L("modifyFlagsDesc"), currentFlags, function(text)
            text = string.gsub(text or "", "%s", "")
            net.Start("liaModifyFlags")
            net.WriteString(tgt:SteamID())
            net.WriteString(text)
            net.WriteBool(true)
            net.SendToServer()
        end)

        AdminStickIsOpen = false
    end):SetIcon("icon16/flag_orange.png")
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
                        cl:notifyLocalized("copiedCharID", tgt:getChar():getID())
                        SetClipboardText(tgt:getChar():getID())
                    end

                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", tgt:Name()),
                cmd = function()
                    cl:notifyLocalized("copiedToClipboard", tgt:Name(), L("name"))
                    SetClipboardText(tgt:Name())
                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", tgt:SteamID()),
                cmd = function()
                    cl:notifyLocalized("copiedToClipboard", tgt:Name(), L("steamID"))
                    SetClipboardText(tgt:SteamID())
                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
        }

        table.sort(info, function(a, b) return a.name < b.name end)
        local pi = GetOrCreateSubMenu(menu, playerInfoLabel, stores)
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
                if tc == L("door") and tgt:isDoor() or tc == tgtClass then
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