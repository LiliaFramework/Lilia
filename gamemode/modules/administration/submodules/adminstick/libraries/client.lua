local MODULE = MODULE
AdminStickIsOpen = false
local playerInfoLabel = L("player") .. " " .. L("information")
local giveFlagsLabel = L("give") .. " " .. L("flags")
local takeFlagsLabel = L("take") .. " " .. L("flags")
MODULE.adminStickCategories = MODULE.adminStickCategories or {
    moderation = {
        name = L("adminStickCategoryModeration"),
        icon = "icon16/shield.png",
        subcategories = {
            moderationTools = {
                name = L("adminStickSubCategoryModerationTools"),
                icon = "icon16/wrench.png"
            },
            warnings = {
                name = "Warnings",
                icon = "icon16/error.png"
            },
            misc = {
                name = "Miscellaneous",
                icon = "icon16/application_view_tile.png"
            }
        }
    },
    characterManagement = {
        name = L("adminStickCategoryCharacterManagement"),
        icon = "icon16/user_gray.png",
        subcategories = {
            attributes = {
                name = L("adminStickSubCategoryAttributes"),
                icon = "icon16/chart_line.png"
            },
            factions = {
                name = L("adminStickSubCategoryFactions"),
                icon = "icon16/group.png"
            },
            classes = {
                name = L("adminStickSubCategoryClasses"),
                icon = "icon16/user.png"
            },
            whitelists = {
                name = L("adminStickSubCategoryWhitelists"),
                icon = "icon16/group_add.png"
            },
            items = {
                name = L("items"),
                icon = "icon16/box.png"
            },
            adminStickSubCategoryBans = {
                name = L("adminStickSubCategoryBans"),
                icon = "icon16/lock.png"
            },
            adminStickSubCategorySetInfos = {
                name = L("adminStickSubCategorySetInfos"),
                icon = "icon16/pencil.png"
            },
            adminStickSubCategoryGetInfos = {
                name = L("adminStickSubCategoryGetInfos"),
                icon = "icon16/magnifier.png"
            }
        }
    },
    flagManagement = {
        name = L("adminStickCategoryFlagManagement"),
        icon = "icon16/flag_blue.png",
        subcategories = {
            characterFlags = {
                name = L("adminStickSubCategoryCharacterFlags"),
                icon = "icon16/flag_green.png"
            },
            playerFlags = {
                name = L("adminStickSubCategoryPlayerFlags"),
                icon = "icon16/flag_orange.png"
            }
        }
    },
    doorManagement = {
        name = L("adminStickCategoryDoorManagement"),
        icon = "icon16/door.png",
        subcategories = {
            doorActions = {
                name = L("adminStickSubCategoryDoorActions"),
                icon = "icon16/arrow_switch.png"
            },
            doorSettings = {
                name = L("adminStickSubCategoryDoorSettings"),
                icon = "icon16/cog.png"
            },
            doorMaintenance = {
                name = L("adminStickSubCategoryDoorMaintenance"),
                icon = "icon16/wrench.png"
            },
            doorInformation = {
                name = L("adminStickSubCategoryDoorInformation"),
                icon = "icon16/information.png"
            }
        }
    },
    playerInformation = {
        name = L("adminStickCategoryPlayerInformation"),
        icon = "icon16/information.png"
    },
    teleportation = {
        name = L("adminStickCategoryTeleportation"),
        icon = "icon16/arrow_right.png"
    },
    utility = {
        name = L("adminStickCategoryUtility"),
        icon = "icon16/application_view_tile.png",
        subcategories = {
            commands = {
                name = L("adminStickSubCategoryCommands"),
                icon = "icon16/page.png"
            },
            items = {
                name = "Items",
                icon = "icon16/box.png"
            },
            ooc = {
                name = "Out of Character",
                icon = "icon16/comment.png"
            }
        }
    },
    administration = {
        name = L("adminStickCategoryAdministration"),
        icon = "icon16/lock.png",
        subcategories = {
            server = {
                name = "Server",
                icon = "icon16/cog.png"
            },
            permissions = {
                name = "Permissions",
                icon = "icon16/key.png"
            }
        }
    }
}

MODULE.adminStickCategoryOrder = MODULE.adminStickCategoryOrder or {"playerInformation", "moderation", "characterManagement", "flagManagement", "doorManagement", "teleportation", "utility", "administration"}
function MODULE:addAdminStickCategory(key, data, index)
    self.adminStickCategories = self.adminStickCategories or {}
    self.adminStickCategories[key] = data
    self.adminStickCategoryOrder = self.adminStickCategoryOrder or {}
    if index then
        table.insert(self.adminStickCategoryOrder, index, key)
    else
        table.insert(self.adminStickCategoryOrder, key)
    end
end

function MODULE:addAdminStickSubCategory(catKey, subKey, data)
    self.adminStickCategories = self.adminStickCategories or {}
    local category = self.adminStickCategories[catKey]
    if not category then return end
    category.subcategories = category.subcategories or {}
    category.subcategories[subKey] = data
end

local subMenuIcons = {
    moderationTools = "icon16/wrench.png",
    warnings = "icon16/error.png",
    misc = "icon16/application_view_tile.png",
    [playerInfoLabel] = "icon16/information.png",
    characterManagement = "icon16/user_gray.png",
    flagManagement = "icon16/flag_blue.png",
    attributes = "icon16/chart_line.png",
    charFlagsTitle = "icon16/flag_green.png",
    playerFlagsTitle = "icon16/flag_orange.png",
    giveFlagsLabel = "icon16/flag_blue.png",
    takeFlagsLabel = "icon16/flag_red.png",
    doorManagement = "icon16/door.png",
    doorActions = "icon16/arrow_switch.png",
    doorSettings = "icon16/cog.png",
    doorMaintenance = "icon16/wrench.png",
    doorInformation = "icon16/information.png",
    administration = "icon16/lock.png",
    items = "icon16/box.png",
    ooc = "icon16/comment.png",
    adminStickSubCategoryBans = "icon16/lock.png",
    adminStickSubCategoryGetInfos = "icon16/magnifier.png",
    adminStickSubCategorySetInfos = "icon16/pencil.png",
    setFactionTitle = "icon16/group.png",
    adminStickSetClassName = "icon16/user.png",
    adminStickFactionWhitelistName = "icon16/group_add.png",
    adminStickUnwhitelistName = "icon16/group_delete.png",
    adminStickClassWhitelistName = "icon16/user_add.png",
    adminStickClassUnwhitelistName = "icon16/user_delete.png",
    server = "icon16/cog.png",
    permissions = "icon16/key.png",
}

local function GetSubMenuIcon(name)
    if subMenuIcons[name] then return subMenuIcons[name] end
    local baseKey = name:match("^([^%(]+)") or name
    baseKey = baseKey:gsub("^%s*(.-)%s*$", "%1")
    if subMenuIcons[baseKey] then return subMenuIcons[baseKey] end
    if subMenuIcons[L(name)] then return subMenuIcons[L(name)] end
    local setFactionLocalized = L("setFactionTitle", ""):match("^([^%(]+)") or L("setFactionTitle", "")
    setFactionLocalized = setFactionLocalized:gsub("^%s*(.-)%s*$", "%1")
    if name:find(setFactionLocalized, 1, true) == 1 then return subMenuIcons["setFactionTitle"] end
    if name:find("Set Faction", 1, true) == 1 then return subMenuIcons["setFactionTitle"] end
    if name:lower() == "misc" or name:lower() == "miscellaneous" then return "icon16/application_view_tile.png" end
    if name:lower() == "items" then return "icon16/box.png" end
    if name:lower() == "ooc" or name:lower():find("out of character") then return "icon16/comment.png" end
    if name:lower() == "warnings" then return "icon16/error.png" end
    if name:lower() == "commands" then return "icon16/page.png" end
    return "icon16/page.png"
end

local function GetOrCreateSubMenu(parent, name, store, category, subcategory)
    local fullName = name
    if category and subcategory then
        fullName = category .. "_" .. subcategory .. "_" .. name
    elseif category then
        fullName = category .. "_" .. name
    end

    if not store[fullName] then
        local menu, panel = parent:AddSubMenu(L(name))
        local icon = GetSubMenuIcon(name)
        if icon then panel:SetIcon(icon) end
        store[fullName] = menu
    end
    return store[fullName]
end

local function GetOrCreateCategoryMenu(parent, categoryKey, store)
    local category = MODULE.adminStickCategories[categoryKey]
    if not category then return parent end
    if not store[categoryKey] then
        local menu, panel = parent:AddSubMenu(category.name)
        if category.icon then panel:SetIcon(category.icon) end
        store[categoryKey] = menu
    end
    return store[categoryKey]
end

local function GetOrCreateSubCategoryMenu(parent, categoryKey, subcategoryKey, store)
    local category = MODULE.adminStickCategories[categoryKey]
    if not category or not category.subcategories or not category.subcategories[subcategoryKey] then return parent end
    local count = 0
    for _ in pairs(category.subcategories) do
        count = count + 1
        if count > 1 then break end
    end

    if count <= 1 then return parent end
    local subcategory = category.subcategories[subcategoryKey]
    local fullKey = categoryKey .. "_" .. subcategoryKey
    if not store[fullKey] then
        local menu, panel = parent:AddSubMenu(subcategory.name)
        if subcategory.icon then panel:SetIcon(subcategory.icon) end
        store[fullKey] = menu
    end
    return store[fullKey]
end

local function CreateOrganizedAdminStickMenu(tgt, stores)
    local menu = DermaMenu()
    local cl = LocalPlayer()
    local categoryOrder = MODULE.adminStickCategoryOrder or {}
    for _, categoryKey in ipairs(categoryOrder) do
        local category = MODULE.adminStickCategories[categoryKey]
        if category then
            local hasContent = false
            if categoryKey == "playerInformation" and tgt:IsPlayer() then
                hasContent = true
            elseif categoryKey == "moderation" and tgt:IsPlayer() and (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then
                hasContent = true
            elseif categoryKey == "characterManagement" and tgt:IsPlayer() and (cl:hasPrivilege("manageTransfers") or cl:hasPrivilege("manageClasses") or cl:hasPrivilege("manageWhitelists") or cl:hasPrivilege("manageCharacterInformation")) then
                hasContent = true
            elseif categoryKey == "flagManagement" and tgt:IsPlayer() and cl:hasPrivilege("manageFlags") then
                hasContent = true
            elseif categoryKey == "doorManagement" and tgt:isDoor() then
                hasContent = true
            elseif categoryKey == "teleportation" and tgt:IsPlayer() and (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then
                hasContent = true
            elseif categoryKey == "administration" and tgt:IsPlayer() then
                hasContent = true
            elseif categoryKey == "utility" and tgt:IsPlayer() then
                hasContent = true
            end

            if hasContent then GetOrCreateCategoryMenu(menu, categoryKey, stores) end
        end
    end
    return menu
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
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local modCategory = GetOrCreateCategoryMenu(menu, "moderation", stores)
    local modSubCategory = GetOrCreateSubCategoryMenu(modCategory, "moderation", "moderationTools", stores)
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

    for _, p in ipairs(mods) do
        if p.action then
            modSubCategory:AddOption(L(p.action.name), function() HandleModerationOption(p.action, tgt) end):SetIcon(p.action.icon)
            if p.inverse then modSubCategory:AddOption(L(p.inverse.name), function() HandleModerationOption(p.inverse, tgt) end):SetIcon(p.inverse.icon) end
        else
            modSubCategory:AddOption(L(p.name), function() HandleModerationOption(p, tgt) end):SetIcon(p.icon)
        end
    end
end

local function IncludeTeleportation(tgt, menu, stores)
    local cl = LocalPlayer()
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local tpCategory = GetOrCreateCategoryMenu(menu, "teleportation", stores)
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

    table.sort(tp, function(a, b) return a.name < b.name end)
    for _, o in ipairs(tp) do
        tpCategory:AddOption(L(o.name), function()
            RunAdminCommand(o.cmd, tgt)
            AdminStickIsOpen = false
        end):SetIcon(o.icon)
    end
end

local function IncludeUtility(tgt, menu, stores)
    local utilityCategory = GetOrCreateCategoryMenu(menu, "utility", stores)
    local commandsSubCategory = GetOrCreateSubCategoryMenu(utilityCategory, "utility", "commands", stores)
    local utilityCommands = {
        {
            name = L("noclip"),
            cmd = "noclip",
            icon = "icon16/shape_square.png"
        },
        {
            name = L("godmode"),
            cmd = "godmode",
            icon = "icon16/shield.png"
        },
        {
            name = L("spectate"),
            cmd = "spectate",
            icon = "icon16/eye.png"
        }
    }

    for _, cmd in ipairs(utilityCommands) do
        commandsSubCategory:AddOption(L(cmd.name), function()
            RunAdminCommand(cmd.cmd, tgt)
            AdminStickIsOpen = false
        end):SetIcon(cmd.icon)
    end
end

local function IncludeCharacterManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    local canFaction = cl:hasPrivilege("manageTransfers")
    local canClass = cl:hasPrivilege("manageClasses")
    local canWhitelist = cl:hasPrivilege("manageWhitelists")
    local charCategory = GetOrCreateCategoryMenu(menu, "characterManagement", stores)
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
                                cmd = 'say /plytransfer ' .. QuoteArgs(GetIdentifier(tgt), v.uniqueID)
                            })
                        end

                        break
                    end
                end

                table.sort(facOptions, function(a, b) return a.name < b.name end)
                if #facOptions > 0 then
                    local factionsSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "factions", stores)
                    local fm = GetOrCreateSubMenu(factionsSubCategory, L("setFactionTitle", curName or L("unknown")), stores)
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
                local classesSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "classes", stores)
                local cm = GetOrCreateSubMenu(classesSubCategory, "adminStickSetClassName", stores)
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
                                cmd = 'say /plywhitelist ' .. QuoteArgs(GetIdentifier(tgt), v.uniqueID)
                            })
                        else
                            table.insert(facRemove, {
                                name = v.name,
                                cmd = 'say /plyunwhitelist ' .. QuoteArgs(GetIdentifier(tgt), v.uniqueID)
                            })
                        end
                    end
                end

                table.sort(facAdd, function(a, b) return a.name < b.name end)
                table.sort(facRemove, function(a, b) return a.name < b.name end)
                local whitelistsSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "whitelists", stores)
                local fw = GetOrCreateSubMenu(whitelistsSubCategory, "adminStickFactionWhitelistName", stores)
                for _, o in ipairs(facAdd) do
                    fw:AddOption(L(o.name), function()
                        cl:ConCommand(o.cmd)
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/group_add.png")
                end

                local fu = GetOrCreateSubMenu(whitelistsSubCategory, "adminStickUnwhitelistName", stores)
                for _, o in ipairs(facRemove) do
                    fu:AddOption(L(o.name), function()
                        cl:ConCommand(o.cmd)
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/group_delete.png")
                end

                if classes and #classes > 0 then
                    local cw, cu = {}, {}
                    for _, c in ipairs(classes) do
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

                    table.sort(cw, function(a, b) return a.name < b.name end)
                    table.sort(cu, function(a, b) return a.name < b.name end)
                    local cwm = GetOrCreateSubMenu(whitelistsSubCategory, "adminStickClassWhitelistName", stores)
                    for _, o in ipairs(cw) do
                        cwm:AddOption(L(o.name), function()
                            cl:ConCommand(o.cmd)
                            AdminStickIsOpen = false
                        end):SetIcon("icon16/user_add.png")
                    end

                    local cum = GetOrCreateSubMenu(whitelistsSubCategory, "adminStickClassUnwhitelistName", stores)
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

    if cl:hasPrivilege("manageCharacterInformation") then
        local attributesSubCategory = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "attributes", stores)
        attributesSubCategory:AddOption(L("changePlayerModel"), function()
            OpenPlayerModelUI(tgt)
            AdminStickIsOpen = false
        end):SetIcon("icon16/user_suit.png")
    end
end

local function IncludeFlagManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    if not cl:hasPrivilege("manageFlags") then return end
    local flagCategory = GetOrCreateCategoryMenu(menu, "flagManagement", stores)
    local cf = GetOrCreateSubCategoryMenu(flagCategory, "flagManagement", "characterFlags", stores)
    local cGive = GetOrCreateSubMenu(cf, giveFlagsLabel, stores, "flagManagement", "characterFlags")
    local cTake = GetOrCreateSubMenu(cf, takeFlagsLabel, stores, "flagManagement", "characterFlags")
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

    cf:AddOption(L("giveAllCharFlags"), function()
        local allFlags = ""
        for fl in pairs(lia.flag.list) do
            allFlags = allFlags .. fl
        end

        if allFlags ~= "" then
            net.Start("liaModifyFlags")
            net.WriteString(tgt:SteamID())
            net.WriteString(allFlags)
            net.WriteBool(false)
            net.SendToServer()
        end

        AdminStickIsOpen = false
    end):SetIcon("icon16/flag_blue.png")

    cf:AddOption(L("takeAllCharFlags"), function()
        net.Start("liaModifyFlags")
        net.WriteString(tgt:SteamID())
        net.WriteString("")
        net.WriteBool(false)
        net.SendToServer()
        AdminStickIsOpen = false
    end):SetIcon("icon16/flag_red.png")

    cf:AddOption(L("listCharFlags"), function()
        local currentFlags = charObj and charObj:getFlags() or ""
        local flagList = ""
        if currentFlags ~= "" then
            for i = 1, #currentFlags do
                local flag = currentFlags:sub(i, i)
                flagList = flagList .. flag .. " "
            end

            flagList = string.Trim(flagList)
        end

        Derma_Message(L("currentCharFlags") .. ": " .. (flagList ~= "" and flagList or L("none")), L("charFlagsTitle"), L("ok"))
        AdminStickIsOpen = false
    end):SetIcon("icon16/information.png")

    local pf = GetOrCreateSubCategoryMenu(flagCategory, "flagManagement", "playerFlags", stores)
    local pGive = GetOrCreateSubMenu(pf, giveFlagsLabel, stores, "flagManagement", "playerFlags")
    local pTake = GetOrCreateSubMenu(pf, takeFlagsLabel, stores, "flagManagement", "playerFlags")
    local toGiveP, toTakeP = {}, {}
    for fl in pairs(lia.flag.list) do
        if not tgt:hasFlags(fl, "player") then
            table.insert(toGiveP, {
                name = L("giveFlagFormat", fl),
                cmd = 'say /pflaggive ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_blue.png",
            })
        else
            table.insert(toTakeP, {
                name = L("takeFlagFormat", fl),
                cmd = 'say /pflagtake ' .. QuoteArgs(GetIdentifier(tgt), fl),
                icon = "icon16/flag_red.png",
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
        local currentFlags = tgt:getFlags("player")
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

    pf:AddOption(L("giveAllPlayerFlags"), function()
        local allFlags = ""
        for fl in pairs(lia.flag.list) do
            allFlags = allFlags .. fl
        end

        if allFlags ~= "" then
            net.Start("liaModifyFlags")
            net.WriteString(tgt:SteamID())
            net.WriteString(allFlags)
            net.WriteBool(true)
            net.SendToServer()
        end

        AdminStickIsOpen = false
    end):SetIcon("icon16/flag_blue.png")

    pf:AddOption(L("takeAllPlayerFlags"), function()
        net.Start("liaModifyFlags")
        net.WriteString(tgt:SteamID())
        net.WriteString("")
        net.WriteBool(true)
        net.SendToServer()
        AdminStickIsOpen = false
    end):SetIcon("icon16/flag_red.png")

    pf:AddOption(L("listPlayerFlags"), function()
        local currentFlags = tgt:getFlags("player") or ""
        local flagList = ""
        if currentFlags ~= "" then
            for i = 1, #currentFlags do
                local flag = currentFlags:sub(i, i)
                flagList = flagList .. flag .. " "
            end

            flagList = string.Trim(flagList)
        end

        Derma_Message(L("currentPlayerFlags") .. ": " .. (flagList ~= "" and flagList or L("none")), L("playerFlagsTitle"), L("ok"))
        AdminStickIsOpen = false
    end):SetIcon("icon16/information.png")
end

local function AddCommandToMenu(menu, data, key, tgt, name, stores)
    local cl = LocalPlayer()
    local can = lia.command.hasAccess(cl, key, data)
    if not can then return end
    local cat = data.AdminStick.Category
    local sub = data.AdminStick.SubCategory
    local m = menu
    local categoryKey = nil
    local subcategoryKey = nil
    if cat == "characterManagement" then
        categoryKey = "characterManagement"
        if sub == "attributes" then
            subcategoryKey = "attributes"
        elseif sub == "factions" then
            subcategoryKey = "factions"
        elseif sub == "classes" then
            subcategoryKey = "classes"
        elseif sub == "whitelists" then
            subcategoryKey = "whitelists"
        elseif sub == "items" then
            subcategoryKey = "items"
        elseif sub == "adminStickSubCategoryBans" then
            subcategoryKey = "adminStickSubCategoryBans"
        elseif sub == "adminStickSubCategorySetInfos" then
            subcategoryKey = "adminStickSubCategorySetInfos"
        elseif sub == "adminStickSubCategoryGetInfos" then
            subcategoryKey = "adminStickSubCategoryGetInfos"
        end
    elseif cat == "flagManagement" then
        categoryKey = "flagManagement"
        if sub == "characterFlags" then
            subcategoryKey = "characterFlags"
        elseif sub == "playerFlags" then
            subcategoryKey = "playerFlags"
        end
    elseif cat == "doorManagement" then
        categoryKey = "doorManagement"
        if sub == "doorActions" then
            subcategoryKey = "doorActions"
        elseif sub == "doorSettings" then
            subcategoryKey = "doorSettings"
        elseif sub == "doorMaintenance" then
            subcategoryKey = "doorMaintenance"
        elseif sub == "doorInformation" then
            subcategoryKey = "doorInformation"
        end
    elseif cat == "moderation" then
        categoryKey = "moderation"
        if sub == "moderationTools" then
            subcategoryKey = "moderationTools"
        elseif sub == "warnings" then
            subcategoryKey = "warnings"
        elseif sub == "misc" then
            subcategoryKey = "misc"
        end
    elseif cat == "utility" then
        categoryKey = "utility"
        if sub == "commands" then
            subcategoryKey = "commands"
        elseif sub == "items" then
            subcategoryKey = "items"
        elseif sub == "ooc" then
            subcategoryKey = "ooc"
        end
    elseif cat == "administration" then
        categoryKey = "administration"
        if sub == "server" then
            subcategoryKey = "server"
        elseif sub == "permissions" then
            subcategoryKey = "permissions"
        end
    end

    if categoryKey then
        m = GetOrCreateCategoryMenu(menu, categoryKey, stores)
        if subcategoryKey then m = GetOrCreateSubCategoryMenu(m, categoryKey, subcategoryKey, stores) end
    else
        if cat then m = GetOrCreateSubMenu(menu, cat, stores) end
        if sub then m = GetOrCreateSubMenu(m, sub, stores) end
    end

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
    if not (cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()) then return end
    local tempMenu = DermaMenu()
    local stores = {}
    local hasOptions = false
    if tgt:IsPlayer() then
        local info = {
            {
                name = L("charIDCopyFormat", tgt:getChar() and tgt:getChar():getID() or L("na")),
                cmd = function() end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", tgt:Name()),
                cmd = function() end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", tgt:SteamID()),
                cmd = function() end,
                icon = "icon16/page_copy.png"
            },
        }

        if #info > 0 then hasOptions = true end
        if cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty() then hasOptions = true end
        if cl:hasPrivilege("manageTransfers") or cl:hasPrivilege("manageClasses") or cl:hasPrivilege("manageWhitelists") or cl:hasPrivilege("manageCharacterInformation") then hasOptions = true end
        if cl:hasPrivilege("manageFlags") then hasOptions = true end
    end

    local tgtClass = tgt:GetClass()
    local cmds = {}
    for k, v in pairs(lia.command.list) do
        if v.AdminStick and istable(v.AdminStick) then
            local tc = v.AdminStick.TargetClass
            if tc then
                if tc == "door" and tgt:isDoor() or tc == tgtClass then
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

    if #cmds > 0 then hasOptions = true end
    hook.Run("PopulateAdminStick", tempMenu, tgt)
    tempMenu:Remove()
    if not hasOptions then
        cl:notifyLocalized("adminStickNoOptions")
        return
    end

    AdminStickIsOpen = true
    local menu = CreateOrganizedAdminStickMenu(tgt, stores)
    menu:Center()
    menu:MakePopup()
    if tgt:IsPlayer() then
        local info = {
            {
                name = L("charIDCopyFormat", tgt:getChar() and tgt:getChar():getID() or L("na")),
                cmd = function()
                    if tgt:getChar() then
                        cl:notifyLocalized("adminStickCopiedCharID")
                        SetClipboardText(tgt:getChar():getID())
                    end

                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", tgt:Name()),
                cmd = function()
                    cl:notifyLocalized("adminStickCopiedToClipboard", L("name"))
                    SetClipboardText(tgt:Name())
                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", tgt:SteamID()),
                cmd = function()
                    cl:notifyLocalized("adminStickCopiedToClipboard", L("steamID"))
                    SetClipboardText(tgt:SteamID())
                    AdminStickIsOpen = false
                end,
                icon = "icon16/page_copy.png"
            },
        }

        table.sort(info, function(a, b) return a.name < b.name end)
        local infoCategory = GetOrCreateCategoryMenu(menu, "playerInformation", stores)
        local copyInfoSubCategory = GetOrCreateSubCategoryMenu(infoCategory, "playerInformation", "copyInfo", stores)
        for _, o in ipairs(info) do
            copyInfoSubCategory:AddOption(L(o.name), o.cmd):SetIcon(o.icon)
        end

        IncludeAdminMenu(tgt, menu, stores)
        IncludeCharacterManagement(tgt, menu, stores)
        IncludeFlagManagement(tgt, menu, stores)
        IncludeTeleportation(tgt, menu, stores)
        IncludeUtility(tgt, menu, stores)
    end

    table.sort(cmds, function(a, b) return a.name < b.name end)
    local categorizedCommands = {}
    local uncategorizedCommands = {}
    for _, c in ipairs(cmds) do
        if c.data.AdminStick and c.data.AdminStick.Category then
            if not categorizedCommands[c.data.AdminStick.Category] then categorizedCommands[c.data.AdminStick.Category] = {} end
            table.insert(categorizedCommands[c.data.AdminStick.Category], c)
        else
            table.insert(uncategorizedCommands, c)
        end
    end

    for _, commands in pairs(categorizedCommands) do
        for _, c in ipairs(commands) do
            AddCommandToMenu(menu, c.data, c.key, tgt, c.name, stores)
        end
    end

    if #uncategorizedCommands > 0 then
        local utilityCategory = GetOrCreateCategoryMenu(menu, "utility", stores)
        local commandsSubCategory = GetOrCreateSubCategoryMenu(utilityCategory, "utility", "commands", stores)
        for _, c in ipairs(uncategorizedCommands) do
            local ic = c.data.AdminStick and c.data.AdminStick.Icon or "icon16/page.png"
            commandsSubCategory:AddOption(L(c.name), function()
                local id = GetIdentifier(tgt)
                local cmd = "say /" .. c.key
                if id ~= "" then cmd = cmd .. " " .. QuoteArgs(id) end
                cl:ConCommand(cmd)
                AdminStickIsOpen = false
            end):SetIcon(ic)
        end
    end

    hook.Run("PopulateAdminStick", menu, tgt)
    function menu:OnRemove()
        cl.AdminStickTarget = nil
        AdminStickIsOpen = false
    end

    menu:Open()
end