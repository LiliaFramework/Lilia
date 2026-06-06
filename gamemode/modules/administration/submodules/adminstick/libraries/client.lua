local MODULE = MODULE
AdminStickIsOpen = false
AdminStickMenu = nil
AdminStickWarnings = {}
AdminStickMenuPositionCache = nil
AdminStickMenuOpenTime = 0
MODULE.adminStickCategories = MODULE.adminStickCategories or {}
MODULE.adminStickCategoryOrder = MODULE.adminStickCategoryOrder or {}
local playerInfoLabel = L("player") .. " " .. L("information")
local subMenuIcons = {
    moderationTools = "icon16/wrench.png",
    warnings = "icon16/error.png",
    misc = "icon16/application_view_tile.png",
    [playerInfoLabel] = "icon16/information.png",
    characterManagement = "icon16/user_gray.png",
    flagManagement = "icon16/flag_blue.png",
    attributes = "icon16/chart_line.png",
    charFlagsTitle = "icon16/flag_green.png",
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
    adminStickSubCategoryRanking = "icon16/user_green.png",
    Ranks = "icon16/user_green.png",
    server = "icon16/cog.png",
    permissions = "icon16/key.png",
}

local function hasAdminStickGeneratedLists(target)
    local lists = {}
    hook.Run("GetAdminStickLists", target, lists)
    for _, listData in ipairs(lists) do
        if listData and listData.name and listData.category and listData.subcategory and istable(listData.items) and next(listData.items) ~= nil then return true end
    end
    return false
end

local function beginAdminStickMenuBatch(menu)
    if not IsValid(menu) then return end
    local state = {
        menus = {},
        closed = false
    }

    local function attach(panel)
        if state.closed then return end
        if not IsValid(panel) or panel._liaAdminStickBatchState == state then return end
        panel._liaAdminStickBatchState = state
        panel._liaAdminStickOriginalUpdateSize = panel._liaAdminStickOriginalUpdateSize or panel.UpdateSize
        panel.UpdateSize = function(self) if self._liaAdminStickOriginalUpdateSize then self._liaAdminStickBatchDirty = true end end
        state.menus[#state.menus + 1] = panel
    end

    attach(menu)
    state.attach = attach
    return state
end

local function finishAdminStickMenuBatch(state)
    if not state or not state.menus then return end
    state.closed = true
    for _, panel in ipairs(state.menus) do
        if IsValid(panel) and panel._liaAdminStickOriginalUpdateSize then panel.UpdateSize = panel._liaAdminStickOriginalUpdateSize end
    end

    for i = #state.menus, 1, -1 do
        local panel = state.menus[i]
        if IsValid(panel) and panel._liaAdminStickOriginalUpdateSize and panel._liaAdminStickBatchDirty then
            panel:_liaAdminStickOriginalUpdateSize()
            panel._liaAdminStickBatchDirty = nil
        end

        if IsValid(panel) then panel._liaAdminStickBatchState = nil end
    end
end

local function appendDeferredMenuBuild(menu, builder)
    if not IsValid(menu) or not isfunction(builder) then return end
    if menu.AppendDeferredBuild then
        menu:AppendDeferredBuild(builder)
    else
        builder(menu)
    end
end

local function GetIdentifier(ent)
    if not IsValid(ent) or not ent:IsPlayer() then return "" end
    if ent:IsBot() then return ent:Name() end
    return ent:SteamID64()
end

local function QuoteArgs(...)
    local args = {}
    for _, v in ipairs({...}) do
        args[#args + 1] = string.format("'%s'", tostring(v))
    end
    return table.concat(args, " ")
end

local function GetIconForCategory(name)
    if subMenuIcons[name] then return subMenuIcons[name] end
    local baseKey = name:match("^([^%(]+)") or name
    baseKey = baseKey:gsub("^%s*(.-)%s*$", "%1")
    if subMenuIcons[baseKey] then return subMenuIcons[baseKey] end
    local nameLower = name:lower()
    local iconMappings = {
        ["moderation"] = "icon16/shield.png",
        ["admin"] = "icon16/shield.png",
        ["security"] = "icon16/shield.png",
        ["character"] = "icon16/user_gray.png",
        ["player"] = "icon16/user_gray.png",
        ["user"] = "icon16/user_gray.png",
        ["person"] = "icon16/user_gray.png",
        ["door"] = "icon16/door.png",
        ["building"] = "icon16/door.png",
        ["property"] = "icon16/door.png",
        ["house"] = "icon16/door.png",
        ["information"] = "icon16/information.png",
        ["info"] = "icon16/information.png",
        ["data"] = "icon16/information.png",
        ["knowledge"] = "icon16/information.png",
        ["details"] = "icon16/information.png",
        ["teleport"] = "icon16/arrow_right.png",
        ["move"] = "icon16/arrow_right.png",
        ["travel"] = "icon16/arrow_right.png",
        ["transport"] = "icon16/arrow_right.png",
        ["utility"] = "icon16/application_view_tile.png",
        ["tool"] = "icon16/application_view_tile.png",
        ["misc"] = "icon16/application_view_tile.png",
        ["miscellaneous"] = "icon16/application_view_tile.png",
        ["other"] = "icon16/application_view_tile.png",
        ["flag"] = "icon16/flag_green.png",
        ["permission"] = "icon16/flag_green.png",
        ["access"] = "icon16/flag_green.png",
        ["privilege"] = "icon16/flag_green.png",
        ["item"] = "icon16/box.png",
        ["inventory"] = "icon16/box.png",
        ["container"] = "icon16/box.png",
        ["storage"] = "icon16/box.png",
        ["ooc"] = "icon16/comment.png",
        ["chat"] = "icon16/comment.png",
        ["message"] = "icon16/comment.png",
        ["talk"] = "icon16/comment.png",
        ["communication"] = "icon16/comment.png",
        ["warning"] = "icon16/error.png",
        ["alert"] = "icon16/error.png",
        ["error"] = "icon16/error.png",
        ["caution"] = "icon16/error.png",
        ["command"] = "icon16/page.png",
        ["control"] = "icon16/page.png",
        ["manage"] = "icon16/page.png",
        ["setting"] = "icon16/page.png",
        ["attribute"] = "icon16/chart_line.png",
        ["stat"] = "icon16/chart_line.png",
        ["skill"] = "icon16/chart_line.png",
        ["level"] = "icon16/chart_line.png",
        ["faction"] = "icon16/group.png",
        ["guild"] = "icon16/group.png",
        ["team"] = "icon16/group.png",
        ["organization"] = "icon16/group.png",
        ["class"] = "icon16/user.png",
        ["role"] = "icon16/user.png",
        ["job"] = "icon16/user.png",
        ["profession"] = "icon16/user.png",
        ["whitelist"] = "icon16/group_add.png",
        ["approve"] = "icon16/group_add.png",
        ["accept"] = "icon16/group_add.png",
        ["allow"] = "icon16/group_add.png",
        ["ban"] = "icon16/lock.png",
        ["block"] = "icon16/lock.png",
        ["restrict"] = "icon16/lock.png",
        ["deny"] = "icon16/lock.png",
    }

    for keyword, icon in pairs(iconMappings) do
        if nameLower:find(keyword) then return icon end
    end

    local localizedExactMatches = {
        [L("adminStickCategoryModeration"):lower()] = "icon16/shield.png",
        [L("characterManagement"):lower()] = "icon16/user_gray.png",
        [L("doorManagement"):lower()] = "icon16/door.png",
        [L("playerinformation"):lower()] = "icon16/information.png",
        [L("adminStickCategoryTeleportation"):lower()] = "icon16/arrow_right.png",
        [L("adminStickCategoryUtility"):lower()] = "icon16/application_view_tile.png",
        [L("misc"):lower()] = "icon16/application_view_tile.png",
        [L("items"):lower()] = "icon16/box.png",
        [L("outOfCharacter"):lower()] = "icon16/comment.png",
        [L("warnsModuleName"):lower()] = "icon16/error.png",
    }

    if localizedExactMatches[nameLower] then return localizedExactMatches[nameLower] end
    if nameLower:find("management") or nameLower:find("admin") then return "icon16/cog.png" end
    if nameLower:find("stat") or nameLower:find("number") or nameLower:find("count") then return "icon16/chart_bar.png" end
    if nameLower:find("set") or nameLower:find("config") then return "icon16/cog.png" end
    if nameLower:find("get") or nameLower:find("view") or nameLower:find("show") then return "icon16/information.png" end
    if nameLower:find("list") or nameLower:find("all") then
        return "icon16/table.png"
    elseif nameLower:find("create") or nameLower:find("new") or nameLower:find("add") then
        return "icon16/add.png"
    elseif nameLower:find("delete") or nameLower:find("remove") then
        return "icon16/delete.png"
    elseif nameLower:find("edit") or nameLower:find("modify") then
        return "icon16/pencil.png"
    else
        return "icon16/page.png"
    end
end

local function formatAdminStickWords(key)
    local text = tostring(key or ""):gsub("_", " "):gsub("-", " ")
    text = text:gsub("(%l)(%u)", "%1 %2")
    text = text:gsub("%s+", " ")
    return string.Trim(text)
end

local function formatAdminStickPascal(key)
    local words = formatAdminStickWords(key)
    return words:gsub("(%a)([%w']*)", function(first, rest) return string.upper(first) .. string.lower(rest) end):gsub("%s+", "")
end

local function resolveAdminStickToken(candidates)
    for _, token in ipairs(candidates) do
        local resolved = lia.lang.resolveToken(token)
        if resolved and resolved ~= "" and resolved ~= token and resolved ~= token:sub(2) then return resolved end
    end
end

local function humanizeAdminStickKey(key)
    local words = formatAdminStickWords(key)
    return words:gsub("(%a)([%w']*)", function(first, rest) return string.upper(first) .. string.lower(rest) end)
end

local function getCategoryDisplayName(categoryKey)
    local pascalKey = formatAdminStickPascal(categoryKey)
    return resolveAdminStickToken({"@adminStickCategory" .. pascalKey, "@" .. tostring(categoryKey or "")}) or humanizeAdminStickKey(categoryKey)
end

local function getSubcategoryDisplayName(_, subcategoryKey)
    local pascalKey = formatAdminStickPascal(subcategoryKey)
    return resolveAdminStickToken({"@adminStickSubCategory" .. pascalKey, "@adminStickCategory" .. pascalKey, "@" .. tostring(subcategoryKey or "")}) or humanizeAdminStickKey(subcategoryKey)
end

local function findCategoryKeyByName(categories, displayName)
    for categoryKey, categoryData in pairs(categories or {}) do
        if categoryData and categoryData.name == displayName then return categoryKey end
    end
end

local function findSubcategoryKeyByName(categoryData, displayName)
    for subcategoryKey, subcategoryData in pairs(categoryData and categoryData.subcategories or {}) do
        if subcategoryData and subcategoryData.name == displayName then return subcategoryKey end
    end
end

local function ensureDynamicCategory(categories, orderedCategories, categoryKey)
    local displayName = getCategoryDisplayName(categoryKey)
    local existingKey = findCategoryKeyByName(categories, displayName)
    if existingKey then return existingKey, categories[existingKey] end
    categories[categoryKey] = {
        name = displayName,
        icon = GetIconForCategory(categoryKey),
        subcategories = {}
    }

    if orderedCategories then orderedCategories[#orderedCategories + 1] = categoryKey end
    return categoryKey, categories[categoryKey]
end

local function GenerateDynamicCategories()
    local categories = {}
    local orderedCategories = {}
    for _, cmdData in pairs(lia.command.list) do
        if cmdData and istable(cmdData) and cmdData.AdminStick and istable(cmdData.AdminStick) then
            local category = cmdData.AdminStick.Category
            local subcategory = cmdData.AdminStick.SubCategory
            if category then
                local canonicalCategoryKey, categoryData = ensureDynamicCategory(categories, orderedCategories, category)
                if subcategory then
                    local displayName = getSubcategoryDisplayName(canonicalCategoryKey, subcategory)
                    local existingSubcategoryKey = findSubcategoryKeyByName(categoryData, displayName)
                    if not existingSubcategoryKey then
                        categoryData.subcategories[subcategory] = {
                            name = displayName,
                            icon = GetIconForCategory(subcategory)
                        }
                    end
                end
            end
        end
    end
    return categories, orderedCategories
end

function MODULE:InitializedModules()
    local categories, categoryOrder = GenerateDynamicCategories()
    self.adminStickCategories = categories
    self.adminStickCategoryOrder = categoryOrder
end

local function GetOrCreateCategoryMenu(parent, categoryKey, store)
    if not parent or not IsValid(parent) then return end
    MODULE.adminStickCategories = MODULE.adminStickCategories or {}
    local displayName = getCategoryDisplayName(categoryKey)
    local canonicalCategoryKey = findCategoryKeyByName(MODULE.adminStickCategories, displayName) or categoryKey
    local category = MODULE.adminStickCategories[canonicalCategoryKey]
    if not category then
        MODULE.adminStickCategories[canonicalCategoryKey] = {
            name = displayName,
            icon = GetIconForCategory(categoryKey),
            subcategories = {}
        }

        category = MODULE.adminStickCategories[canonicalCategoryKey]
        if MODULE.adminStickCategoryOrder and not table.HasValue(MODULE.adminStickCategoryOrder, canonicalCategoryKey) then table.insert(MODULE.adminStickCategoryOrder, canonicalCategoryKey) end
    end

    if not store[canonicalCategoryKey] then
        local menu, option = parent:AddSubMenu(category.name, function() end)
        if category.icon and option then option:SetIcon(category.icon) end
        if IsValid(menu) then
            store[canonicalCategoryKey] = menu
            if store.__batchState and store.__batchState.attach then store.__batchState.attach(menu) end
        else
            return parent
        end
    end
    return store[canonicalCategoryKey] or parent
end

local function GetOrCreateSubCategoryMenu(parent, categoryKey, subcategoryKey, store)
    if not parent or not IsValid(parent) then return end
    MODULE.adminStickCategories = MODULE.adminStickCategories or {}
    local canonicalCategoryKey = findCategoryKeyByName(MODULE.adminStickCategories, getCategoryDisplayName(categoryKey)) or categoryKey
    local category = MODULE.adminStickCategories[canonicalCategoryKey]
    if not category then
        GetOrCreateCategoryMenu(parent, categoryKey, store)
        canonicalCategoryKey = findCategoryKeyByName(MODULE.adminStickCategories, getCategoryDisplayName(categoryKey)) or categoryKey
        category = MODULE.adminStickCategories[canonicalCategoryKey]
    end

    if not category then return parent end
    category.subcategories = category.subcategories or {}
    local displayName = getSubcategoryDisplayName(canonicalCategoryKey, subcategoryKey)
    local canonicalSubcategoryKey = findSubcategoryKeyByName(category, displayName) or subcategoryKey
    if not category.subcategories[canonicalSubcategoryKey] then
        category.subcategories[canonicalSubcategoryKey] = {
            name = displayName,
            icon = GetIconForCategory(subcategoryKey)
        }
    end

    local subcategory = category.subcategories[canonicalSubcategoryKey]
    local fullKey = canonicalCategoryKey .. "_" .. canonicalSubcategoryKey
    if not store[fullKey] then
        local menu, option = parent:AddSubMenu(subcategory.name, function() end)
        if subcategory.icon and option then option:SetIcon(subcategory.icon) end
        if IsValid(menu) then
            store[fullKey] = menu
            if store.__batchState and store.__batchState.attach then store.__batchState.attach(menu) end
        else
            return parent
        end
    end
    return store[fullKey] or parent
end

local function CreateOrganizedAdminStickMenu(tgt, stores, existingMenu)
    local menu = existingMenu or lia.derma.dermaMenu()
    if not IsValid(menu) then return menu end
    local cl = LocalPlayer()
    local categories, categoryOrder = GenerateDynamicCategories()
    MODULE.adminStickCategories = categories
    MODULE.adminStickCategoryOrder = categoryOrder
    for _, categoryKey in ipairs(categoryOrder) do
        local category = categories[categoryKey]
        if category then
            local hasContent
            local hasAlwaysSpawnAdminStick = cl:hasPrivilege("alwaysSpawnAdminStick")
            local isStaffOnDuty = cl:isStaffOnDuty()
            if categoryKey == "moderation" and tgt:IsPlayer() and (hasAlwaysSpawnAdminStick or isStaffOnDuty) then
                hasContent = true
            elseif categoryKey == "characterManagement" and tgt:IsPlayer() then
                hasContent = true
            elseif categoryKey == "flagManagement" and tgt:IsPlayer() and (hasAlwaysSpawnAdminStick or isStaffOnDuty) then
                hasContent = true
            elseif categoryKey == "doorManagement" and tgt:isDoor() then
                hasContent = true
            elseif categoryKey == "storageManagement" and tgt.isStorageEntity then
                hasContent = true
            elseif categoryKey == "utility" and tgt:IsPlayer() then
                hasContent = true
            else
                hasContent = false
            end

            if hasContent then GetOrCreateCategoryMenu(menu, categoryKey, stores) end
        end
    end

    if menu.UpdateSize then menu:UpdateSize() end
    return menu
end

local function RunAdminCommand(cmd, tgt, dur, reason)
    local victim = IsValid(tgt) and tgt:IsPlayer() and (tgt:IsBot() and tgt:Name() or tgt:SteamID()) or tgt
    lia.admin.execCommand(cmd, victim, dur, reason)
end

local function OpenPlayerModelUI(tgt)
    AdminStickIsOpen = true
    local fr = vgui.Create("liaFrame")
    fr:SetTitle(L("changePlayerModel"))
    fr:SetSize(1200, 800)
    fr:Center()
    function fr:OnClose()
        fr:Remove()
        LocalPlayer().AdminStickTarget = nil
        AdminStickIsOpen = false
    end

    local ed = vgui.Create("liaEntry", fr)
    ed:Dock(BOTTOM)
    ed:SetText(tgt:GetModel())
    local bt = vgui.Create("liaButton", fr)
    bt:SetText(L("change"))
    bt:Dock(TOP)
    function bt:DoClick()
        local txt = ed:GetValue()
        local id = GetIdentifier(tgt)
        if id ~= "" then RunConsoleCommand("say", "/charsetmodel " .. QuoteArgs(id, txt)) end
        fr:Remove()
        LocalPlayer().AdminStickTarget = nil
        AdminStickIsOpen = false
    end

    local sheet = fr:Add("liaTabs")
    sheet:Dock(FILL)
    local function populateModelGrid(wr, modList)
        wr:Clear()
        for _, md in ipairs(modList) do
            local ic = wr:Add("SpawnIcon")
            ic:SetModel(md.mdl)
            ic:SetSize(128, 128)
            ic:SetTooltip(md.name)
            ic.model_path = md.mdl
            ic.DoClick = function() ed:SetValue(ic.model_path) end
        end
    end

    local allPanel = sheet:Add("Panel")
    local allSc = allPanel:Add("liaScrollPanel")
    allSc:Dock(FILL)
    local allWr = allSc:Add("DIconLayout")
    allWr:Dock(FILL)
    local allModList = {}
    for n, m in SortedPairs(player_manager.AllValidModels()) do
        table.insert(allModList, {
            name = n,
            mdl = m
        })
    end

    hook.Run("AdminStickAddModels", allModList, tgt)
    table.sort(allModList, function(a, b) return a.name < b.name end)
    populateModelGrid(allWr, allModList)
    sheet:AddSheet(L("all"), allPanel)
    local factionPanel = sheet:Add("Panel")
    local factionSheet = factionPanel:Add("liaTabs")
    factionSheet:Dock(FILL)
    local function processFactionModel(modelData, defaultName, modList)
        if isstring(modelData) then
            table.insert(modList, {
                name = defaultName,
                mdl = modelData
            })
        elseif istable(modelData) then
            if modelData[1] and isstring(modelData[1]) then
                table.insert(modList, {
                    name = modelData[2] or defaultName,
                    mdl = modelData[1]
                })
            end
        end
    end

    local function processFactionModels(faction, modList)
        if not faction.models then return end
        local models = faction.models
        if istable(models) then
            local hasStringKeys = false
            for k, _ in pairs(models) do
                if isstring(k) then
                    hasStringKeys = true
                    break
                end
            end

            if hasStringKeys then
                for _, categoryModels in pairs(models) do
                    if istable(categoryModels) then
                        for _, modelData in ipairs(categoryModels) do
                            processFactionModel(modelData, faction.name or L("unknownFaction"), modList)
                        end
                    else
                        processFactionModel(categoryModels, faction.name or L("unknownFaction"), modList)
                    end
                end
            else
                if models.male or models.female then
                    if models.male then
                        for _, modelData in ipairs(models.male) do
                            processFactionModel(modelData, faction.name or L("unknownFaction"), modList)
                        end
                    end

                    if models.female then
                        for _, modelData in ipairs(models.female) do
                            processFactionModel(modelData, faction.name or L("unknownFaction"), modList)
                        end
                    end
                else
                    for _, modelData in ipairs(models) do
                        processFactionModel(modelData, faction.name or L("unknownFaction"), modList)
                    end
                end
            end
        else
            processFactionModel(models, faction.name or L("unknownFaction"), modList)
        end
    end

    for _, faction in pairs(lia.faction.teams or {}) do
        if faction.models then
            local factionSubPanel = factionSheet:Add("Panel")
            local factionSc = factionSubPanel:Add("liaScrollPanel")
            factionSc:Dock(FILL)
            local factionWr = factionSc:Add("DIconLayout")
            factionWr:Dock(FILL)
            local factionModList = {}
            processFactionModels(faction, factionModList)
            table.sort(factionModList, function(a, b) return a.name < b.name end)
            populateModelGrid(factionWr, factionModList)
            factionSheet:AddSheet(faction.name or L("unknownFaction"), factionSubPanel)
        end
    end

    sheet:AddSheet(L("faction"), factionPanel)
    local charObj = tgt:getChar()
    if charObj then
        local classIndex = charObj:getClass()
        if classIndex and classIndex ~= -1 and lia.class.list[classIndex] then
            local classPanel = sheet:Add("Panel")
            local classSheet = classPanel:Add("liaTabs")
            classSheet:Dock(FILL)
            local function processClassModel(modelData, className, modList)
                if istable(modelData) then
                    table.insert(modList, {
                        name = modelData[2] or className,
                        mdl = modelData[1]
                    })
                else
                    table.insert(modList, {
                        name = className,
                        mdl = modelData
                    })
                end
            end

            local function processClassModels(class, modList)
                if not class.model then return end
                local modelPath = class.model
                if istable(modelPath) then
                    if modelPath.male or modelPath.female then
                        if modelPath.male then
                            for _, modelData in ipairs(modelPath.male) do
                                processClassModel(modelData, class.name, modList)
                            end
                        end

                        if modelPath.female then
                            for _, modelData in ipairs(modelPath.female) do
                                processClassModel(modelData, class.name, modList)
                            end
                        end
                    else
                        for _, modelData in ipairs(modelPath) do
                            processClassModel(modelData, class.name, modList)
                        end
                    end
                elseif isstring(modelPath) then
                    table.insert(modList, {
                        name = class.name,
                        mdl = modelPath
                    })
                end
            end

            for _, class in pairs(lia.class.list or {}) do
                if class.model then
                    local classSubPanel = classSheet:Add("Panel")
                    local classSc = classSubPanel:Add("liaScrollPanel")
                    classSc:Dock(FILL)
                    local classWr = classSc:Add("DIconLayout")
                    classWr:Dock(FILL)
                    local classModList = {}
                    processClassModels(class, classModList)
                    table.sort(classModList, function(a, b) return a.name < b.name end)
                    populateModelGrid(classWr, classModList)
                    classSheet:AddSheet(class.name or L("unknownClass"), classSubPanel)
                end
            end

            sheet:AddSheet(L("class"), classPanel)
        end
    end

    fr:MakePopup()
end

local function OpenReasonUI(tgt, cmd)
    AdminStickIsOpen = true
    local argTypes = {}
    local defaults = {}
    argTypes[L("reason")] = "string"
    defaults[L("reason")] = ""
    if cmd == "banid" then
        argTypes[L("lengthInDays")] = "number"
        defaults[L("lengthInDays")] = 0
    end

    lia.derma.requestArguments(L("reasonFor", cmd), argTypes, function(success, data)
        if not success or not data then
            AdminStickIsOpen = false
            LocalPlayer().AdminStickTarget = nil
            return
        end

        local txt = data[L("reason")] or ""
        local id = GetIdentifier(tgt)
        if cmd == "banid" then
            if id ~= "" then
                local duration = tonumber(data[L("lengthInDays")]) or 0
                local len = duration * 60 * 24
                RunAdminCommand("ban", tgt, len, txt)
            end
        elseif cmd == "kick" then
            if id ~= "" then RunAdminCommand("kick", tgt, nil, txt) end
        end

        AdminStickIsOpen = false
        LocalPlayer().AdminStickTarget = nil
    end, defaults)
end

local function HandleModerationOption(opt, tgt)
    if opt.name == L("ban") then
        OpenReasonUI(tgt, "banid")
    elseif opt.name == L("kick") then
        OpenReasonUI(tgt, "kick")
    else
        RunAdminCommand(opt.cmd, tgt)
    end

    timer.Simple(0.1, function()
        LocalPlayer().AdminStickTarget = nil
        AdminStickIsOpen = false
    end)
end

local function IncludeAdminMenu(tgt, menu, stores)
    local cl = LocalPlayer()
    local hasAlwaysSpawnAdminStick = cl:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = cl:isStaffOnDuty()
    local permission = hasAlwaysSpawnAdminStick or isStaffOnDuty
    if not permission then return end
    local modCategory = GetOrCreateCategoryMenu(menu, "moderation", stores)
    if not modCategory then return end
    local modSubCategory = GetOrCreateSubCategoryMenu(modCategory, "moderation", "moderationTools", stores)
    if not modSubCategory then return end
    appendDeferredMenuBuild(modSubCategory, function(submenu)
        local mods = {}
        local isBlinded = timer.Exists("liaBlind" .. tgt:SteamID())
        if isBlinded then
            mods[#mods + 1] = {
                name = L("unblind"),
                cmd = "unblind",
                icon = "icon16/eye.png"
            }
        else
            mods[#mods + 1] = {
                name = L("blind"),
                cmd = "blind",
                icon = "icon16/eye.png"
            }
        end

        if tgt:IsFrozen() then
            mods[#mods + 1] = {
                name = L("unfreeze"),
                cmd = "unfreeze",
                icon = "icon16/accept.png"
            }
        else
            mods[#mods + 1] = {
                name = L("freeze"),
                cmd = "freeze",
                icon = "icon16/lock.png"
            }
        end

        if tgt:getLiliaData("liaGagged", false) then
            mods[#mods + 1] = {
                name = L("ungag"),
                cmd = "ungag",
                icon = "icon16/sound_low.png"
            }
        else
            mods[#mods + 1] = {
                name = L("gag"),
                cmd = "gag",
                icon = "icon16/sound_mute.png"
            }
        end

        if tgt:getChar() and tgt:getLiliaData("liaMuted", false) then
            mods[#mods + 1] = {
                name = L("unmute"),
                cmd = "unmute",
                icon = "icon16/sound_add.png"
            }
        else
            mods[#mods + 1] = {
                name = L("mute"),
                cmd = "mute",
                icon = "icon16/sound_delete.png"
            }
        end

        if tgt:IsOnFire() then
            mods[#mods + 1] = {
                name = L("extinguish"),
                cmd = "extinguish",
                icon = "icon16/fire_delete.png"
            }
        else
            mods[#mods + 1] = {
                name = L("ignite"),
                cmd = "ignite",
                icon = "icon16/fire.png"
            }
        end

        if tgt:isLocked() then
            mods[#mods + 1] = {
                name = L("unjail"),
                cmd = "unjail",
                icon = "icon16/lock_open.png"
            }
        else
            mods[#mods + 1] = {
                name = L("jail"),
                cmd = "jail",
                icon = "icon16/lock.png"
            }
        end

        mods[#mods + 1] = {
            name = L("slay"),
            cmd = "slay",
            icon = "icon16/bomb.png"
        }

        table.sort(mods, function(a, b)
            local na = a.action and a.action.name or a.name
            local nb = b.action and b.action.name or b.name
            return na < nb
        end)

        for _, p in ipairs(mods) do
            if p.action then
                submenu:AddOption(L(p.action.name), function() HandleModerationOption(p.action, tgt) end):SetIcon(p.action.icon)
                if p.inverse then submenu:AddOption(L(p.inverse.name), function() HandleModerationOption(p.inverse, tgt) end):SetIcon(p.inverse.icon) end
            else
                submenu:AddOption(L(p.name), function() HandleModerationOption(p, tgt) end):SetIcon(p.icon)
            end
        end

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
            submenu:AddOption(L(cmd.name), function()
                RunAdminCommand(cmd.cmd, tgt)
                timer.Simple(0.1, function()
                    LocalPlayer().AdminStickTarget = nil
                    AdminStickIsOpen = false
                end)
            end):SetIcon(cmd.icon)
        end
    end)
end

local function IncludeTeleportation(tgt, menu, stores)
    local cl = LocalPlayer()
    local hasAlwaysSpawnAdminStick = cl:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = cl:isStaffOnDuty()
    local permission = hasAlwaysSpawnAdminStick or isStaffOnDuty
    if not permission then return end
    local moderationCategory = GetOrCreateCategoryMenu(menu, "moderation", stores)
    if not moderationCategory then return end
    local tpCategory = GetOrCreateSubCategoryMenu(moderationCategory, "moderation", "teleportation", stores)
    appendDeferredMenuBuild(tpCategory, function(submenu)
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
            submenu:AddOption(L(o.name), function()
                RunAdminCommand(o.cmd, tgt)
                timer.Simple(0.1, function()
                    LocalPlayer().AdminStickTarget = nil
                    AdminStickIsOpen = false
                end)
            end):SetIcon(o.icon)
        end
    end)
end

local function IncludeCharacterManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    local charCategory = GetOrCreateCategoryMenu(menu, "characterManagement", stores)
    if not charCategory then return end
    local canManageCharacterInformation = cl:hasPrivilege("manageCharacterInformation")
    if canManageCharacterInformation then
        charCategory:AddOption(L("changePlayerModel"), function()
            OpenPlayerModelUI(tgt)
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/user_suit.png")
    end

    local canChangeBodygroups = cl:hasPrivilege("changeBodygroups")
    if canChangeBodygroups then
        charCategory:AddOption(L("adminStickEditCharBodygroupsName"), function()
            local id = GetIdentifier(tgt)
            if id ~= "" then RunConsoleCommand("say", "/chareditbodygroups " .. QuoteArgs(id)) end
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/user_gray.png")
    end
end

local function IncludeFlagManagement(tgt, menu, stores)
    local cl = LocalPlayer()
    local canManageFlags = cl:hasPrivilege("manageFlags")
    if not canManageFlags then return end
    local charCategory = GetOrCreateCategoryMenu(menu, "characterManagement", stores)
    if not charCategory then return end
    local cf = GetOrCreateSubCategoryMenu(charCategory, "characterManagement", "flags", stores)
    if not cf then return end
    appendDeferredMenuBuild(cf, function(submenu)
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
            submenu:AddOption(L(f.name), function()
                cl:ConCommand(f.cmd)
                timer.Simple(0.1, function() AdminStickIsOpen = false end)
            end):SetIcon(f.icon)
        end

        for _, f in ipairs(toTake) do
            submenu:AddOption(L(f.name), function()
                cl:ConCommand(f.cmd)
                timer.Simple(0.1, function() AdminStickIsOpen = false end)
            end):SetIcon(f.icon)
        end

        submenu:AddOption(L("modifyCharFlags"), function()
            local currentFlags = charObj and charObj:getFlags() or ""
            tgt:requestString("@modifyCharFlags", "@modifyFlagsDesc", function(text)
                if text == false then return end
                text = string.gsub(text or "", "%s", "")
                net.Start("liaModifyFlags")
                net.WriteString(tgt:SteamID())
                net.WriteString(text)
                net.WriteBool(false)
                net.SendToServer()
            end, currentFlags)

            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/flag_orange.png")

        submenu:AddOption(L("giveAllCharFlags"), function()
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

            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/flag_blue.png")

        submenu:AddOption(L("takeAllCharFlags"), function()
            net.Start("liaModifyFlags")
            net.WriteString(tgt:SteamID())
            net.WriteString("")
            net.WriteBool(false)
            net.SendToServer()
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/flag_red.png")

        submenu:AddOption(L("listCharFlags"), function()
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
            timer.Simple(0.1, function() AdminStickIsOpen = false end)
        end):SetIcon("icon16/information.png")
    end)
end

local function AddCommandToMenu(menu, data, key, tgt, name, stores)
    local cl = LocalPlayer()
    local can = lia.command.hasAccess(cl, key, data)
    if not can then return end
    local cat = data.AdminStick.Category
    local sub = data.AdminStick.SubCategory
    local m = menu
    if cat then m = GetOrCreateCategoryMenu(menu, cat, stores) end
    if cat and sub then m = GetOrCreateSubCategoryMenu(m, cat, sub, stores) end
    if IsValid(m) then
        appendDeferredMenuBuild(m, function(submenu)
            local ic = data.AdminStick.Icon or "icon16/page.png"
            local id = GetIdentifier(tgt)
            local baseCmd = "say /" .. key
            if id ~= "" then baseCmd = baseCmd .. " " .. QuoteArgs(id) end
            if key == "warn" then
                local warnMenu, warnOption = submenu:AddSubMenu(name)
                if warnOption then warnOption:SetIcon(ic) end
                local severityOptions = {
                    {
                        label = L("severityLow"),
                        value = "Low"
                    },
                    {
                        label = L("severityMedium"),
                        value = "Medium"
                    },
                    {
                        label = L("severityHigh"),
                        value = "High"
                    }
                }

                local reasonKey = L("reason") or "reason"
                local function openReason(selectedSeverity)
                    lia.derma.requestArguments(name .. " - " .. selectedSeverity, {{reasonKey, "string"}}, function(success, argData)
                        if not success or not argData then
                            timer.Simple(0.1, function() AdminStickIsOpen = false end)
                            LocalPlayer().AdminStickTarget = nil
                            return
                        end

                        local reasonValue = argData[reasonKey] or ""
                        local warnCmd = baseCmd .. " " .. QuoteArgs(selectedSeverity)
                        if reasonValue ~= "" then warnCmd = warnCmd .. " " .. QuoteArgs(reasonValue) end
                        cl:ConCommand(warnCmd)
                        timer.Simple(0.1, function() AdminStickIsOpen = false end)
                    end, {
                        [reasonKey] = ""
                    })
                end

                for _, option in ipairs(severityOptions) do
                    warnMenu:AddOption(option.label, function() openReason(option.value) end):SetIcon("icon16/error.png")
                end
                return
            end

            submenu:AddOption(name, function()
                local cmd = baseCmd
                if data.arguments and #data.arguments > 0 then
                    local argTypes = {}
                    local defaults = {}
                    local startIndex = 1
                    if data.arguments[1] and (data.arguments[1].type == "player" or data.arguments[1].type == "target") then startIndex = 2 end
                    for i = startIndex, #data.arguments do
                        local arg = data.arguments[i]
                        table.insert(argTypes, {arg.name, arg.type})
                        if arg.optional then defaults[arg.name] = "" end
                    end

                    if #argTypes > 0 then
                        lia.derma.requestArguments(name .. " - Arguments", argTypes, function(success, argData)
                            if not success or not argData then
                                timer.Simple(0.1, function() AdminStickIsOpen = false end)
                                LocalPlayer().AdminStickTarget = nil
                                return
                            end

                            for i = startIndex, #data.arguments do
                                local arg = data.arguments[i]
                                local value = argData[arg.name]
                                if value and value ~= "" then cmd = cmd .. " " .. QuoteArgs(value) end
                            end

                            cl:ConCommand(cmd)
                            timer.Simple(0.1, function() AdminStickIsOpen = false end)
                        end, defaults)
                    else
                        cl:ConCommand(cmd)
                        timer.Simple(0.1, function() AdminStickIsOpen = false end)
                    end
                else
                    cl:ConCommand(cmd)
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end
            end):SetIcon(ic)
        end)
    end
end

local function hasAdminStickTargetClass(class)
    for _, c in pairs(lia.command.list) do
        if istable(c.AdminStick) and c.AdminStick.TargetClass == class then return true end
    end
    return false
end

function MODULE:OpenAdminStickUI(tgt)
    local cl = LocalPlayer()
    if not IsValid(tgt) or not tgt:isDoor() and not tgt:IsPlayer() and not tgt.isStorageEntity and not hasAdminStickTargetClass(tgt:GetClass()) then return end
    local hasAlwaysSpawnAdminStick = cl:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = cl:isStaffOnDuty()
    local permission = hasAlwaysSpawnAdminStick or isStaffOnDuty
    if not permission then return end
    if IsValid(AdminStickMenu) then AdminStickMenu:Remove() end
    local stores = {}
    MODULE.adminStickCategories = {}
    MODULE.adminStickCategoryOrder = {}
    local hasOptions = false
    if tgt:IsPlayer() then
        local charID = tgt:getChar() and tgt:getChar():getID() or L("na")
        local info = {
            {
                name = L("charIDCopyFormat", charID),
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
        if hasAlwaysSpawnAdminStick or isStaffOnDuty then hasOptions = true end
    end

    local tgtClass = tgt:GetClass()
    local cmds = {}
    for k, v in pairs(lia.command.list) do
        if v.AdminStick and istable(v.AdminStick) and not v.realCommand then
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
    if IsValid(tgt) and tgt.isStorageEntity then hasOptions = true end
    if not hasOptions then
        local generatedLists = hasAdminStickGeneratedLists(tgt)
        if generatedLists then hasOptions = true end
    end

    if not hasOptions then
        cl:notifyInfoLocalized("noOptionsAvailable")
        return
    end

    AdminStickIsOpen = true
    AdminStickMenuPositionCache = nil
    AdminStickMenuOpenTime = CurTime()
    local menu = lia.derma.dermaMenu()
    if not IsValid(menu) then return end
    local batchState = beginAdminStickMenuBatch(menu)
    stores.__batchState = batchState
    AdminStickMenu = menu
    local baseThink = menu.Think
    menu.Think = function(panel)
        if baseThink then baseThink(panel) end
        if IsValid(panel) then
            local mx, my = panel:GetPos()
            local mw, mh = panel:GetWide(), panel:GetTall()
            if mw > 0 and mh > 0 then
                AdminStickMenuPositionCache = {
                    x = mx,
                    y = my,
                    w = mw,
                    h = mh,
                    updateTime = CurTime()
                }
            end
        end
    end

    if tgt:IsPlayer() then
        local charID = tgt:getChar() and tgt:getChar():getID() or L("na")
        local charName = tgt:getChar() and tgt:getChar():getName() or tgt:Name()
        local steamName = tgt:IsBot() and "BOT" or tgt:SteamName() or ""
        local steamID = tgt:IsBot() and "BOT" or tgt:SteamID() or ""
        local steamID64 = tgt:IsBot() and "BOT" or tgt:SteamID64() or ""
        local model = tgt:GetModel() or ""
        local steamProfileLink = steamID64 ~= "BOT" and steamID64 ~= "" and ("https://steamcommunity.com/profiles/" .. steamID64) or ""
        local info = {
            {
                name = L("copySteamNameFormat", steamName),
                cmd = function()
                    if steamName ~= "BOT" and steamName ~= "" then
                        cl:notifySuccessLocalized("copied")
                        SetClipboardText(steamName)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("copySteamProfileFormat", steamProfileLink ~= "" and steamProfileLink or L("na")),
                cmd = function()
                    if steamProfileLink ~= "" then
                        cl:notifySuccessLocalized("copied")
                        SetClipboardText(steamProfileLink)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("steamIDCopyFormat", steamID),
                cmd = function()
                    if steamID ~= "BOT" and steamID ~= "" then
                        cl:notifySuccessLocalized("copied")
                        SetClipboardText(steamID)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("copySteamID64Format", steamID64),
                cmd = function()
                    if steamID64 ~= "BOT" and steamID64 ~= "" then
                        cl:notifySuccessLocalized("copied")
                        SetClipboardText(steamID64)
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("nameCopyFormat", charName),
                cmd = function()
                    cl:notifySuccessLocalized("copied")
                    SetClipboardText(charName)
                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("charIDCopyFormat", charID),
                cmd = function()
                    if tgt:getChar() then
                        cl:notifySuccessLocalized("adminStickCopiedCharID")
                        SetClipboardText(tgt:getChar():getID())
                    end

                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = L("copyModelFormat", model),
                cmd = function()
                    cl:notifySuccessLocalized("copied")
                    SetClipboardText(model)
                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
            {
                name = function()
                    local currentPos = tgt:GetPos()
                    local currentAng = tgt:GetAngles()
                    local posStr = string.format("Vector = (%.2f, %.2f, %.2f), Angle = (%.2f, %.2f, %.2f)", currentPos.x, currentPos.y, currentPos.z, currentAng.x, currentAng.y, currentAng.z)
                    return L("copyPositionFormat", posStr)
                end,
                cmd = function()
                    local client = cl
                    if not IsValid(client) then
                        chat.AddText(Color(255, 0, 0), "[Lilia] " .. L("errorPrefix") .. L("commandCanOnlyBeUsedByPlayers"))
                        return
                    end

                    local currentPos = tgt:GetPos()
                    local currentAng = tgt:GetAngles()
                    local posStr = string.format("Vector = (%.2f, %.2f, %.2f), Angle = (%.2f, %.2f, %.2f)", currentPos.x, currentPos.y, currentPos.z, currentAng.x, currentAng.y, currentAng.z)
                    chat.AddText(Color(255, 255, 255), posStr)
                    SetClipboardText(posStr)
                    cl:notifySuccessLocalized("copied")
                    menu:Remove()
                    timer.Simple(0.1, function() AdminStickIsOpen = false end)
                end,
                icon = "icon16/page_copy.png"
            },
        }

        for _, o in ipairs(info) do
            local nameText = isfunction(o.name) and o.name() or o.name
            local option = menu:AddOption(L(nameText), o.cmd)
            option:SetIcon(o.icon)
            option:SetZPos(-100)
        end

        menu:AddSpacer()
    end

    CreateOrganizedAdminStickMenu(tgt, stores, menu)
    if tgt:IsPlayer() then
        IncludeAdminMenu(tgt, menu, stores)
        IncludeCharacterManagement(tgt, menu, stores)
        IncludeFlagManagement(tgt, menu, stores)
        IncludeTeleportation(tgt, menu, stores)
    end

    table.sort(cmds, function(a, b) return a.name < b.name end)
    local categorizedCommands = {}
    local uncategorizedCommands = {}
    for _, c in ipairs(cmds) do
        if c.data.AdminStick and c.data.AdminStick.Category then
            local cat = c.data.AdminStick.Category
            if not categorizedCommands[cat] then categorizedCommands[cat] = {} end
            table.insert(categorizedCommands[cat], c)
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
        if not utilityCategory then return end
        local commandsSubCategory = GetOrCreateSubCategoryMenu(utilityCategory, "utility", "commands", stores)
        if not commandsSubCategory then return end
        for _, c in ipairs(uncategorizedCommands) do
            local ic = c.data.AdminStick and c.data.AdminStick.Icon or "icon16/page.png"
            commandsSubCategory:AddOption(c.name, function()
                local id = GetIdentifier(tgt)
                local cmd = "say /" .. c.key
                if id ~= "" then cmd = cmd .. " " .. QuoteArgs(id) end
                cl:ConCommand(cmd)
                timer.Simple(0.1, function()
                    LocalPlayer().AdminStickTarget = nil
                    AdminStickIsOpen = false
                end)
            end):SetIcon(ic)
        end
    end

    hook.Add("GetAdminStickLists", "liaDefaultAdminStickLists", function(target, lists)
        local client = LocalPlayer()
        local canFaction = client:hasPrivilege("manageTransfers")
        local canClass = client:hasPrivilege("manageClasses")
        local canWhitelist = client:hasPrivilege("manageWhitelists")
        if not target or not IsValid(target) then return end
        local pos = target:GetPos()
        local ang = target:GetAngles()
        local posStr = string.format("%.2f %.2f %.2f", pos.x, pos.y, pos.z)
        local angStr = string.format("%.2f %.2f %.2f", ang.p, ang.y, ang.r)
        local setPosAngStr = string.format("setpos %.2f %.2f %.2f; setang %.2f %.2f %.2f", pos.x, pos.y, pos.z, ang.p, ang.y, ang.r)
        local displayName
        if target:IsPlayer() then
            local char = target:getChar()
            displayName = (char and char:getName()) or target:Nick() or target:Name() or L("unknown")
        elseif target.GetName and target:GetName() ~= "" then
            displayName = target:GetName()
        else
            displayName = target:GetClass() or L("unknown")
        end

        local copyItems = {
            {
                name = "@copyName",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(displayName) end
            },
            {
                name = "@copyPosition",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(posStr) end
            },
            {
                name = "@copyAngles",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(angStr) end
            },
            {
                name = "@copyPosAngPrintpos",
                icon = "icon16/page_copy.png",
                callback = function() SetClipboardText(setPosAngStr) end
            }
        }

        table.insert(lists, {
            name = "@copy",
            category = "moderation",
            subcategory = "moderationTools",
            items = copyItems
        })

        if target.isStorageEntity then
            local storageOptions = {
                {
                    name = L("removeThing", L("password")),
                    icon = "icon16/key_delete.png",
                    callback = function() RunConsoleCommand("say", "/storagepasswordremove") end
                },
                {
                    name = "@changePassword",
                    icon = "icon16/key.png",
                    callback = function()
                        lia.derma.requestString("@enterNewPassword", "@enterNewPassword", function(password)
                            if password == false then return end
                            if password and password ~= "" then RunConsoleCommand("say", "/storagepasswordchange \"" .. password .. "\"") end
                        end, "")
                    end
                }
            }

            table.insert(lists, {
                name = "@storage",
                category = "storageManagement",
                subcategory = "storageActions",
                items = storageOptions
            })
        end

        if not target:IsPlayer() and not target.isStorageEntity then return end
        if target:IsPlayer() then
            local char = target:getChar()
            if not char then return end
            if canFaction then
                local facOptions = {}
                for _, v in pairs(lia.faction.teams) do
                    table.insert(facOptions, {
                        name = v.name,
                        icon = "icon16/group.png",
                        callback = function(callbackTarget)
                            local cmd = 'say /plytransfer ' .. QuoteArgs(GetIdentifier(callbackTarget), v.uniqueID)
                            client:ConCommand(cmd)
                        end
                    })
                end

                if #facOptions > 0 then
                    table.insert(lists, {
                        name = "@factions",
                        category = "characterManagement",
                        subcategory = "transfers",
                        subSubcategory = "@factions",
                        items = facOptions
                    })
                end
            end

            if canClass then
                local facID = char:getFaction()
                local classes = facID and (lia.faction.getClasses(facID) or {}) or {}
                if classes and #classes >= 1 then
                    local cls = {}
                    for _, c in ipairs(classes) do
                        table.insert(cls, {
                            name = c.name,
                            icon = "icon16/user.png",
                            callback = function(callbackTarget)
                                local cmd = 'say /setclass ' .. QuoteArgs(GetIdentifier(callbackTarget), c.uniqueID)
                                client:ConCommand(cmd)
                            end
                        })
                    end

                    if #cls > 0 then
                        table.insert(lists, {
                            name = "@classes",
                            category = "characterManagement",
                            subcategory = "transfers",
                            subSubcategory = "@classes",
                            items = cls
                        })
                    end
                end
            end

            if canWhitelist then
                local facAdd, facRemove = {}, {}
                for _, v in pairs(lia.faction.teams) do
                    if not v.isDefault then
                        if not target:hasWhitelist(v.index) then
                            table.insert(facAdd, {
                                name = v.name,
                                icon = "icon16/group_add.png",
                                callback = function(callbackTarget)
                                    local cmd = 'say /plywhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), v.uniqueID)
                                    client:ConCommand(cmd)
                                end
                            })
                        else
                            table.insert(facRemove, {
                                name = v.name,
                                icon = "icon16/group_delete.png",
                                callback = function(callbackTarget)
                                    local cmd = 'say /plyunwhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), v.uniqueID)
                                    client:ConCommand(cmd)
                                end
                            })
                        end
                    end
                end

                if #facAdd > 0 then
                    table.insert(lists, {
                        name = "@factions",
                        category = "characterManagement",
                        subcategory = "whitelists",
                        subSubcategory = "@factions",
                        subSubSubcategory = "@adminStickFactionAddWhitelist",
                        items = facAdd
                    })
                end

                if #facRemove > 0 then
                    table.insert(lists, {
                        name = "@factions",
                        category = "characterManagement",
                        subcategory = "whitelists",
                        subSubcategory = "@factions",
                        subSubSubcategory = "@adminStickFactionRemoveWhitelist",
                        items = facRemove
                    })
                end

                local classWhitelists = char:getClasswhitelists() or {}
                local factionClassCategories = {}
                for _, v in pairs(lia.faction.teams) do
                    local classes = lia.faction.getClasses(v.index) or {}
                    if classes and #classes > 0 then
                        factionClassCategories[v.uniqueID] = {
                            name = v.name,
                            icon = "icon16/group.png",
                            addItems = {},
                            removeItems = {}
                        }

                        for _, c in ipairs(classes) do
                            if not classWhitelists[c.index] then
                                table.insert(factionClassCategories[v.uniqueID].addItems, {
                                    name = c.name,
                                    icon = "icon16/user_add.png",
                                    callback = function(callbackTarget)
                                        local cmd = 'say /classwhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), c.uniqueID)
                                        client:ConCommand(cmd)
                                    end
                                })
                            else
                                table.insert(factionClassCategories[v.uniqueID].removeItems, {
                                    name = c.name,
                                    icon = "icon16/user_delete.png",
                                    callback = function(callbackTarget)
                                        local cmd = 'say /classunwhitelist ' .. QuoteArgs(GetIdentifier(callbackTarget), c.uniqueID)
                                        client:ConCommand(cmd)
                                    end
                                })
                            end
                        end
                    end
                end

                for factionID, factionData in pairs(factionClassCategories) do
                    if #factionData.addItems > 0 then
                        table.insert(lists, {
                            name = factionData.name,
                            category = "characterManagement",
                            subcategory = "whitelists",
                            subSubcategory = "@classes",
                            subSubSubcategory = "@adminStickClassAddWhitelist",
                            subSubSubSubcategory = factionID,
                            items = factionData.addItems
                        })
                    end

                    if #factionData.removeItems > 0 then
                        table.insert(lists, {
                            name = factionData.name,
                            category = "characterManagement",
                            subcategory = "whitelists",
                            subSubcategory = "@classes",
                            subSubSubcategory = "@adminStickClassRemoveWhitelist",
                            subSubSubSubcategory = factionID,
                            items = factionData.removeItems
                        })
                    end
                end
            end
        end
    end)

    hook.Add("PopulateAdminStick", "liaAddAdminStickLists", function(currentMenu, currentTarget, currentStores)
        local optionsAdded = 0
        local lists = {}
        hook.Run("GetAdminStickLists", currentTarget, lists)
        for _, listData in ipairs(lists) do
            local listName = isstring(listData.name) and lia.lang.resolveToken(listData.name) or listData.name
            local categoryKey = listData.category
            local subcategoryKey = listData.subcategory
            local subSubcategoryKey = isstring(listData.subSubcategory) and lia.lang.resolveToken(listData.subSubcategory) or listData.subSubcategory
            local subSubSubcategoryKey = isstring(listData.subSubSubcategory) and lia.lang.resolveToken(listData.subSubSubcategory) or listData.subSubSubcategory
            local subSubSubSubcategoryKey = isstring(listData.subSubSubSubcategory) and lia.lang.resolveToken(listData.subSubSubSubcategory) or listData.subSubSubSubcategory
            local items = listData.items
            if not (listName and categoryKey and subcategoryKey and items and #items > 0) then continue end
            local category = GetOrCreateCategoryMenu(currentMenu, categoryKey, currentStores)
            if not category or not IsValid(category) then continue end
            local subcategory = GetOrCreateSubCategoryMenu(category, categoryKey, subcategoryKey, currentStores)
            if not subcategory or not IsValid(subcategory) then continue end
            local icon = subMenuIcons[listName] or "icon16/page.png"
            appendDeferredMenuBuild(subcategory, function(submenu)
                local sortedItems = table.Copy(items)
                table.sort(sortedItems, function(a, b) return (a.name or "") < (b.name or "") end)
                local targetMenu = submenu
                local scopeKey = categoryKey .. "_" .. subcategoryKey
                if subSubcategoryKey then
                    targetMenu = GetOrCreateSubCategoryMenu(targetMenu, scopeKey, subSubcategoryKey, currentStores) or submenu
                    scopeKey = scopeKey .. "_" .. tostring(subSubcategoryKey or "")
                end

                if subSubSubcategoryKey then
                    targetMenu = GetOrCreateSubCategoryMenu(targetMenu, scopeKey, subSubSubcategoryKey, currentStores) or submenu
                    scopeKey = scopeKey .. "_" .. tostring(subSubSubcategoryKey or "")
                end

                if subSubSubSubcategoryKey then targetMenu = GetOrCreateSubCategoryMenu(targetMenu, scopeKey, subSubSubSubcategoryKey, currentStores) or submenu end
                if not targetMenu or not IsValid(targetMenu) then return end
                for _, item in ipairs(sortedItems) do
                    local itemName = isstring(item.name) and lia.lang.resolveToken(item.name) or item.name
                    local option = targetMenu:AddOption(itemName, function()
                        if item.callback then item.callback(currentTarget, item) end
                        timer.Simple(0.1, function() AdminStickIsOpen = false end)
                    end)

                    optionsAdded = optionsAdded + 1
                    if item.icon and IsValid(option) then
                        option:SetIcon(item.icon)
                    elseif icon and icon ~= "icon16/page.png" and IsValid(option) then
                        option:SetIcon(icon)
                    end
                end
            end)
        end
    end)

    hook.Run("PopulateAdminStick", menu, tgt, stores)
    finishAdminStickMenuBatch(batchState)
    stores.__batchState = nil
    function menu:OnRemove()
        if AdminStickMenu == self then
            cl.AdminStickTarget = nil
            AdminStickIsOpen = false
            AdminStickMenu = nil
            AdminStickMenuPositionCache = nil
            hook.Run("OnAdminStickMenuClosed")
        end
    end

    function menu:OnClose()
        if AdminStickMenu == self then
            cl.AdminStickTarget = nil
            AdminStickIsOpen = false
            AdminStickMenu = nil
            AdminStickMenuPositionCache = nil
            hook.Run("OnAdminStickMenuClosed")
        end
    end

    menu:Open()
    for _, delay in ipairs({0, 0.03, 0.06, 0.1}) do
        timer.Simple(delay, function()
            if AdminStickIsOpen and IsValid(menu) then
                local mx, my = menu:GetPos()
                local mw, mh = menu:GetWide(), menu:GetTall()
                if mw > 0 and mh > 0 then
                    AdminStickMenuPositionCache = {
                        x = mx,
                        y = my,
                        w = mw,
                        h = mh
                    }
                end
            end
        end)
    end
end

function MODULE:OnAdminStickMenuClosed()
    local client = LocalPlayer()
    if IsValid(client) and client.AdminStickTarget == client then client.AdminStickTarget = nil end
    AdminStickWarnings = {}
end

function MODULE:AdminStickAddModels(modList)
    local addedModels = {}
    for _, modelData in ipairs(modList) do
        addedModels[modelData.mdl] = true
    end

    local function addModel(modelPath, modelName)
        if not modelPath or modelPath == "" then return end
        if isstring(modelPath) and not addedModels[modelPath] then
            table.insert(modList, {
                name = modelName or modelPath,
                mdl = modelPath
            })

            addedModels[modelPath] = true
        end
    end

    local function processModelData(modelData, defaultName)
        if isstring(modelData) then
            addModel(modelData, defaultName)
        elseif istable(modelData) then
            if modelData[1] and isstring(modelData[1]) then addModel(modelData[1], modelData[2] or defaultName) end
        end
    end

    for _, faction in pairs(lia.faction.teams or {}) do
        if faction.models then
            if istable(faction.models) then
                local hasStringKeys = false
                for k, _ in pairs(faction.models) do
                    if isstring(k) then
                        hasStringKeys = true
                        break
                    end
                end

                if hasStringKeys then
                    for _, categoryModels in pairs(faction.models) do
                        if istable(categoryModels) then
                            for _, modelData in ipairs(categoryModels) do
                                processModelData(modelData, faction.name or L("unknownFaction"))
                            end
                        else
                            processModelData(categoryModels, faction.name or L("unknownFaction"))
                        end
                    end
                else
                    for _, modelData in ipairs(faction.models) do
                        processModelData(modelData, faction.name or L("unknownFaction"))
                    end
                end
            else
                processModelData(faction.models, faction.name or L("unknownFaction"))
            end
        end
    end

    for _, class in pairs(lia.class.list or {}) do
        if class.model and isstring(class.model) then addModel(class.model, class.name or L("unknownClass")) end
    end
end

local function DisplayAdminStickHUD(client, hudInfos, weapon)
    if not IsValid(weapon) or not weapon.GetTarget then return end
    local target = weapon:GetTarget()
    if IsValid(target) then
        local infoLines = {}
        if not target:IsPlayer() and IsValid(target:GetOwner()) and target:GetOwner():IsPlayer() then target = target:GetOwner() end
        if target:IsPlayer() then
            local char = target:getChar()
            local charName = char and char:getName() or target:Nick()
            local steamName = target:IsBot() and "BOT" or target:SteamName() or ""
            table.insert(infoLines, L("adminHUDName", charName))
            table.insert(infoLines, L("adminHUDSteamName", steamName))
            table.insert(infoLines, L("adminHUDHealth", target:Health(), target:GetMaxHealth()))
            local activeWeapon = target:GetActiveWeapon()
            local weaponName = L("none")
            if IsValid(activeWeapon) then weaponName = activeWeapon:GetPrintName() or activeWeapon:GetClass() end
            table.insert(infoLines, L("adminHUDWeapon", weaponName))
            table.insert(infoLines, L("adminHUDUserGroup", target:GetUserGroup()))
            local velocity = target:GetVelocity()
            local speed = math.Round(velocity:Length())
            table.insert(infoLines, L("adminHUDSpeed", speed))
        else
            table.insert(infoLines, L("adminHUDEntityClass", target:GetClass()))
            local owner = target:GetOwner()
            if IsValid(owner) and owner:IsPlayer() then
                table.insert(infoLines, L("adminHUDOwner", owner:Nick()))
            else
                table.insert(infoLines, L("adminHUDOwner", L("categoryWorld")))
            end

            table.insert(infoLines, L("adminHUDEntityID", target:EntIndex()))
        end

        hook.Run("AddToAdminStickHUD", client, target, infoLines)
        if IsValid(AdminStickMenu) and target:IsPlayer() then
            local char = target:getChar()
            if char then
                local charID = tostring(char:getID())
                if AdminStickWarnings[charID] == nil then
                    AdminStickWarnings[charID] = {}
                    net.Start("liaRequestPlayerWarnings")
                    net.WriteString(charID)
                    net.SendToServer()
                end

                local warnings = AdminStickWarnings[charID]
                if istable(warnings) and #warnings > 0 then
                    table.insert(infoLines, "")
                    table.insert(infoLines, "Warnings (" .. #warnings .. "):")
                    for i, warn in ipairs(warnings) do
                        if i <= 5 then
                            if istable(warn) then
                                local severity = warn.severity or "Medium"
                                local message = warn.message or ""
                                if #message > 30 then message = string.sub(message, 1, 27) .. "..." end
                                table.insert(infoLines, string.format("%d. [%s] %s", i, severity, message))
                            end
                        end
                    end

                    if #warnings > 5 then table.insert(infoLines, "... and " .. (#warnings - 5) .. " more") end
                end
            end
        end

        surface.SetFont("HUDFont.20")
        local minTextWidth = 0
        for _, line in ipairs(infoLines) do
            local w = select(1, surface.GetTextSize(line))
            minTextWidth = math.max(minTextWidth, w)
        end

        minTextWidth = minTextWidth + 24
        local hudX, hudY, hudAlignX, hudAlignY, hudWidth, hudAutoSize
        local useSidePosition = AdminStickIsOpen
        local cacheValid = AdminStickMenuPositionCache and (AdminStickMenuPositionCache.updateTime or 0) >= (AdminStickMenuOpenTime or 0) - 0.05
        if useSidePosition and cacheValid then
            local menuX = AdminStickMenuPositionCache.x
            local menuY = AdminStickMenuPositionCache.y
            local menuW = AdminStickMenuPositionCache.w
            local menuH = AdminStickMenuPositionCache.h
            hudWidth = math.max(target:IsPlayer() and (menuW * 0.65) or (menuW * 1.2), minTextWidth)
            hudX = menuX - 20 - (hudWidth / 2)
            hudY = menuY + (menuH / 2)
            hudAlignX = TEXT_ALIGN_CENTER
            hudAlignY = TEXT_ALIGN_CENTER
            hudAutoSize = false
        elseif useSidePosition then
            hudWidth = math.max(target:IsPlayer() and (ScrW() * 0.2) or (ScrW() * 0.28), minTextWidth)
            hudX = ScrW() * 0.25 - (hudWidth / 2)
            hudY = ScrH() * 0.5
            hudAlignX = TEXT_ALIGN_CENTER
            hudAlignY = TEXT_ALIGN_CENTER
            hudAutoSize = false
        else
            AdminStickMenuPositionCache = nil
            hudX = ScrW() * 0.5
            hudY = IsValid(lia.gui and lia.gui.actionCircle) and (ScrH() - 170) or (ScrH() - 30)
            hudAlignX = TEXT_ALIGN_CENTER
            hudAlignY = TEXT_ALIGN_BOTTOM
            hudWidth = nil
            hudAutoSize = true
        end

        local bgColor = Color(25, 28, 35, 250)
        local hudInfo = {
            text = infoLines,
            font = "HUDFont.20",
            color = Color(180, 180, 180),
            position = {
                x = hudX,
                y = hudY
            },
            textAlignX = hudAlignX,
            textAlignY = hudAlignY,
            autoSize = hudAutoSize,
            backgroundColor = bgColor,
            borderRadius = 12,
            borderThickness = 0,
            padding = 20,
            blur = {
                enabled = true,
                amount = 1,
                passes = 1,
                alpha = 1.0
            },
            shadow = {
                enabled = true,
                offsetX = 15,
                offsetY = 20,
                color = Color(0, 0, 0, 180)
            },
            accentBorder = {
                enabled = true,
                height = 2,
                color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
            }
        }

        if hudWidth and hudWidth > 0 then hudInfo.width = hudWidth end
        table.insert(hudInfos, hudInfo)
    end

    local instructions = {L("adminStickInstructionSelectTarget"), L("adminStickInstructionFreezePlayer"), L("adminStickInstructionSelectSelf"), L("adminStickInstructionClearSelection")}
    table.insert(hudInfos, {
        text = instructions,
        font = "HUDFont.18",
        color = Color(180, 180, 180),
        position = {
            x = ScrW() - 20,
            y = 20
        },
        textAlignX = TEXT_ALIGN_RIGHT,
        textAlignY = TEXT_ALIGN_TOP,
        backgroundColor = Color(25, 28, 35, 250),
        borderRadius = 6,
        borderThickness = 0,
        padding = 12,
        blur = {
            enabled = true,
            amount = 1,
            passes = 1,
            alpha = 1.0
        },
        shadow = {
            enabled = true,
            offsetX = 8,
            offsetY = 12,
            color = lia.color.theme.window_shadow or Color(0, 0, 0, 50)
        },
        accentBorder = {
            enabled = true,
            height = 2,
            color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
        }
    })
end

function MODULE:DisplayPlayerHUDInformation(client, hudInfos)
    if not client:getChar() then return end
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= "lia_adminstick" then return end
    DisplayAdminStickHUD(client, hudInfos, weapon)
end
