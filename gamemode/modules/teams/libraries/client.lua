function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    hook.Run("AddTextField", L("generalInfo"), "faction", L("faction"), function()
        local factionName = team.GetName(client:Team())
        return L("factionMember", factionName)
    end)

    local classID = character:getClass()
    if not lia.class or not lia.class.list then return end
    local classData = lia.class.list[classID]
    if classID and classData and classData.name then hook.Run("AddTextField", L("generalInfo"), "class", L("class"), function() return L("classMember", classData.name) end) end
end

function MODULE:DrawCharInfo(client, character, info)
    if not lia.config.get("ClassDisplay", true) then return end
    local charClass = client:getClassData()
    if charClass then
        local classColor = charClass.color or Color(255, 255, 255)
        info[#info + 1] = {L(charClass.name) or L("undefinedClass"), classColor}
    end
end

local factionRosterPanel = nil
function MODULE:CreateMenuButtons(tabs)
    if not lia.class or not lia.class.list then return end
    local joinable = lia.class.retrieveJoinable(LocalPlayer())
    if #joinable > 1 then tabs["classes"] = function(panel) panel:Add("liaClasses") end end
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    if character:hasFlags("F") then
        tabs["factionRoster"] = function(panel)
            panel:Clear()
            panel:DockPadding(6, 6, 6, 6)
            panel.Paint = nil
            local loadingLabel = panel:Add("DLabel")
            loadingLabel:Dock(FILL)
            loadingLabel:SetText(L("loading"))
            loadingLabel:SetTextColor(Color(150, 150, 150))
            loadingLabel:SetFont("LiliaFont.20")
            loadingLabel:SetContentAlignment(5)
            panel.loadingLabel = loadingLabel
            panel.factionRosterPanel = true
            factionRosterPanel = panel
            local factionIndex = character:getFaction()
            local faction = lia.faction.get(factionIndex)
            if faction and faction.uniqueID then
                net.Start("liaRequestFactionMembers")
                net.WriteString(faction.uniqueID)
                net.SendToServer()
            else
                loadingLabel:SetText(L("noFactionsFound"))
            end
        end
    end
end

local factionMembersData = {}
local factionManagementPanel = nil
local function CreateFactionManagementUI(panel)
    panel:Clear()
    factionMembersData = {}
    panel:DockPadding(6, 6, 6, 6)
    panel.Paint = nil
    local factions = {}
    for uniqueID, faction in pairs(lia.faction.teams or {}) do
        if faction and faction.name then
            table.insert(factions, {
                uniqueID = uniqueID,
                name = faction.name,
                index = faction.index
            })
        end
    end

    table.sort(factions, function(a, b) return (a.name or ""):lower() < (b.name or ""):lower() end)
    if #factions == 0 then
        local noFactionsLabel = panel:Add("DLabel")
        noFactionsLabel:Dock(FILL)
        noFactionsLabel:SetText(L("noOptionsAvailable"))
        noFactionsLabel:SetTextColor(Color(150, 150, 150))
        noFactionsLabel:SetFont("LiliaFont.20")
        noFactionsLabel:SetContentAlignment(5)
        return
    end

    local sheet = panel:Add("liaTabs")
    sheet:Dock(FILL)
    local function requestMembersForFaction(factionUniqueID)
        if not factionUniqueID or not factionMembersData[factionUniqueID] then return end
        local pagePanel = factionMembersData[factionUniqueID].panel
        if not IsValid(pagePanel) then return end
        if IsValid(pagePanel.loadingLabel) then
            pagePanel.loadingLabel:Remove()
            pagePanel.loadingLabel = nil
        end

        for _, child in ipairs(pagePanel:GetChildren()) do
            child:Remove()
        end

        local loadingLabel = pagePanel:Add("DLabel")
        loadingLabel:Dock(FILL)
        loadingLabel:SetText(L("loading"))
        loadingLabel:SetTextColor(Color(150, 150, 150))
        loadingLabel:SetFont("LiliaFont.20")
        loadingLabel:SetContentAlignment(5)
        pagePanel.loadingLabel = loadingLabel
        net.Start("liaRequestFactionMembers")
        net.WriteString(factionUniqueID)
        net.SendToServer()
    end

    for _, factionData in ipairs(factions) do
        local pagePanel = vgui.Create("DPanel")
        pagePanel:Dock(FILL)
        pagePanel:DockPadding(10, 10, 10, 10)
        pagePanel.Paint = nil
        pagePanel.factionUniqueID = factionData.uniqueID
        local loadingLabel = pagePanel:Add("DLabel")
        loadingLabel:Dock(FILL)
        loadingLabel:SetText(L("loading"))
        loadingLabel:SetTextColor(Color(150, 150, 150))
        loadingLabel:SetFont("LiliaFont.20")
        loadingLabel:SetContentAlignment(5)
        pagePanel.loadingLabel = loadingLabel
        factionMembersData[factionData.uniqueID] = {
            panel = pagePanel,
            members = {}
        }

        sheet:AddTab(factionData.name, pagePanel, nil, function() requestMembersForFaction(factionData.uniqueID) end)
    end

    local oldSetActiveTab = sheet.SetActiveTab
    sheet.SetActiveTab = function(self, tabIndex)
        oldSetActiveTab(self, tabIndex)
        local activeTab = self.tabs[tabIndex]
        if activeTab and activeTab.pan then
            local factionUniqueID = activeTab.pan.factionUniqueID
            requestMembersForFaction(factionUniqueID)
        end
    end

    if sheet.tabs and #sheet.tabs > 0 then sheet:SetActiveTab(1) end
    panel.factionSheet = sheet
    factionManagementPanel = panel
end

local function UpdateFactionRosterUI(panel, data)
    if not IsValid(panel) or not panel.factionRosterPanel then return end
    if IsValid(panel.loadingLabel) then
        panel.loadingLabel:Remove()
        panel.loadingLabel = nil
    end

    for _, child in ipairs(panel:GetChildren()) do
        child:Remove()
    end

    local members = data.members or {}
    if #members == 0 then
        local noMembersLabel = panel:Add("DLabel")
        noMembersLabel:Dock(FILL)
        noMembersLabel:SetText(L("noOptionsAvailable"))
        noMembersLabel:SetTextColor(Color(150, 150, 150))
        noMembersLabel:SetFont("LiliaFont.20")
        noMembersLabel:SetContentAlignment(5)
        return
    end

    local list = panel:Add("liaTable")
    list:Dock(FILL)
    list:DockMargin(0, 0, 0, 0)
    list:AddColumn(L("name"))
    list:AddColumn(L("characterID"))
    for _, member in ipairs(members) do
        local line = list:AddLine(member.name or L("unknown"), member.charID or L("unknown"))
        if line then
            line.charID = member.charID
            line.steamID = member.steamID
            line.name = member.name
        end
    end

    hook.Run("PopulateFactionRosterOptions", list, members)
    list:ForceCommit()
    list:InvalidateLayout(true)
end

local function UpdateFactionMembersUI(panel, data)
    local factionUniqueID = data and data.faction
    if not factionUniqueID or not factionMembersData[factionUniqueID] then return end
    local factionData = factionMembersData[factionUniqueID]
    if not factionData then return end
    local pagePanel = factionData.panel
    if not IsValid(pagePanel) then return end
    if IsValid(pagePanel.loadingLabel) then
        pagePanel.loadingLabel:Remove()
        pagePanel.loadingLabel = nil
    end

    for _, child in ipairs(pagePanel:GetChildren()) do
        child:Remove()
    end

    factionData.members = data.members or {}
    local list = pagePanel:Add("liaTable")
    list:Dock(FILL)
    list:DockMargin(0, 0, 0, 0)
    list:AddColumn(L("name"))
    list:AddColumn(L("characterID"))
    list:AddColumn(L("steamID"))
    list:AddColumn(L("lastOnline"))
    for _, member in ipairs(factionData.members) do
        local lastOnlineText = member.lastOnline or L("unknown")
        local isOnline = false
        if lastOnlineText == L("onlineNow") then
            isOnline = true
        elseif member.charID then
            local owner = lia.char.getOwnerByID(member.charID)
            if IsValid(owner) and owner:getChar() and owner:getChar():getID() == member.charID then
                isOnline = true
                lastOnlineText = L("onlineNow")
            end
        end

        if not isOnline and isstring(lastOnlineText) and lastOnlineText ~= L("unknown") then
            local timeParts = lia.time.toNumber(lastOnlineText)
            if timeParts and timeParts.year then
                local timestamp = os.time{
                    year = timeParts.year,
                    month = timeParts.month or 1,
                    day = timeParts.day or 1,
                    hour = timeParts.hour or 0,
                    min = timeParts.min or 0,
                    sec = timeParts.sec or 0
                }

                local lastDiff = os.time() - timestamp
                if lastDiff > 0 then
                    local timeSince = lia.time.timeSince(timestamp)
                    if timeSince and timeSince ~= L("invalidDate") and timeSince ~= L("invalidInput") then
                        local timeStripped = timeSince:match("^(.-)%sago$") or timeSince
                        lastOnlineText = L("agoFormat", timeStripped, lia.time.formatDHM(lastDiff))
                    end
                end
            end
        end

        local line = list:AddLine(member.name or L("unknown"), member.charID or L("unknown"), member.steamID or L("unknown"), lastOnlineText)
        if line then
            line.charID = member.charID
            line.steamID = member.steamID
        end
    end

    list:AddMenuOption(L("kickToBaseFaction"), function(rowData)
        if not rowData or not rowData.charID then return end
        net.Start("liaKickCharacterToBase")
        net.WriteUInt(rowData.charID, 32)
        net.SendToServer()
    end, "icon16/user_delete.png")

    list:ForceCommit()
    list:InvalidateLayout(true)
end

function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    if client:hasPrivilege("listCharacters") then
        table.insert(pages, {
            name = "factionManagement",
            icon = "icon16/group.png",
            drawFunc = function(panel)
                if not panel.factionManagementInitialized then
                    panel.factionManagementInitialized = true
                    factionManagementPanel = panel
                    CreateFactionManagementUI(panel)
                end
            end
        })
    end
end

lia.net.readBigTable("liaFactionMembers", function(data)
    if not data or not data.faction then return end
    local rosterPanel = factionRosterPanel
    if not IsValid(rosterPanel) and IsValid(lia.gui.menu) and IsValid(lia.gui.menu.panel) then
        for _, child in ipairs(lia.gui.menu.panel:GetChildren()) do
            if IsValid(child) and child.factionRosterPanel then
                rosterPanel = child
                factionRosterPanel = child
                break
            end
        end
    end

    if IsValid(rosterPanel) and rosterPanel.factionRosterPanel then
        UpdateFactionRosterUI(rosterPanel, data)
        return
    end

    local panel = factionManagementPanel
    if not IsValid(panel) and IsValid(lia.gui.menu) and lia.gui.menu.tabList and lia.gui.menu.tabList["admin"] then
        local adminTab = lia.gui.menu.tabList["admin"]
        if IsValid(adminTab) and adminTab.panel then
            for _, child in ipairs(adminTab.panel:GetChildren()) do
                if IsValid(child) and child.factionSheet then
                    panel = child
                    factionManagementPanel = child
                    break
                end
            end
        end
    end

    if IsValid(panel) and panel.factionSheet then UpdateFactionMembersUI(panel, data) end
end)
