spawnmenu.AddContentType("inventoryitem", function(container, data)
    local client = LocalPlayer()
    if not client:hasPrivilege("canUseItemSpawner") then return end
    local icon = vgui.Create("ContentIcon", container)
    icon:SetContentType("inventoryitem")
    icon:SetSpawnName(data.id)
    icon:SetName(data.name)
    local itemData = lia.item.list[data.id]
    if itemData.icon then
        icon.Image:SetMaterial(itemData.icon)
    else
        local model = itemData.model or "default.mdl"
        local matName = string.Replace(model, ".mdl", "")
        icon.Image:SetMaterial(Material("spawnicons/" .. matName .. ".png"))
    end

    icon:SetColor(Color(205, 92, 92, 255))
    icon:SetTooltip(lia.darkrp.textWrap(itemData.desc or "", "DermaDefault", 560))
    icon.DoClick = function()
        net.Start("liaSpawnMenuSpawnItem")
        net.WriteString(data.id)
        net.SendToServer()
        surface.PlaySound("outlands-rp/ui/ui_return.wav")
    end

    icon.OpenMenu = function()
        local menu = lia.derma.dermaMenu()
        menu:AddOption(L("copy"), function() SetClipboardText(icon:GetSpawnName()) end):SetIcon("icon16/page_copy.png")
        menu:AddOption(L("giveToCharacter"), function()
            local popup = vgui.Create("DFrame")
            popup:SetTitle(L("spawnItemTitle", data.id))
            popup:SetSize(300, 100)
            popup:Center()
            popup:MakePopup()
            local label = vgui.Create("DLabel", popup)
            label:Dock(TOP)
            label:SetText(L("giveTo") .. ":")
            local combo = vgui.Create("DComboBox", popup)
            combo:Dock(TOP)
            for _, character in pairs(lia.char.getAll()) do
                local ply = character:getPlayer()
                if IsValid(ply) then
                    local steamID = ply:SteamID() or ""
                    combo:AddChoice(L("characterSteamIDFormat", character:getName() or L("unknown"), steamID), steamID)
                end
            end

            local button = vgui.Create("liaSmallButton", popup)
            button:Dock(BOTTOM)
            button:SetText(L("spawnItem"))
            button.DoClick = function()
                local _, target = combo:GetSelected()
                net.Start("liaSpawnMenuGiveItem")
                net.WriteString(data.id)
                net.WriteString(target or "")
                net.SendToServer()
                popup:Remove()
            end
        end)

        menu:Open()
    end

    container:Add(icon)
    return icon
end)

function MODULE:PopulateInventoryItems(pnlContent, tree)
    local allItems = lia.item.list
    local categorized = {
        Unsorted = {}
    }

    tree:Clear()
    for uniqueID, itemData in pairs(allItems) do
        local category = itemData:getCategory()
        categorized[category] = categorized[category] or {}
        table.insert(categorized[category], {
            id = uniqueID,
            name = itemData.name
        })
    end

    for category, itemList in SortedPairs(categorized) do
        if category ~= L("unsorted") or #itemList > 0 then
            local node = tree:AddNode(category == L("unsorted") and L("unsorted") or category, "icon16/picture.png")
            node.DoPopulate = function(btn)
                if btn.PropPanel then return end
                btn.PropPanel = vgui.Create("ContentContainer", pnlContent)
                btn.PropPanel:SetVisible(false)
                btn.PropPanel:SetTriggerSpawnlistChange(false)
                for _, itemListData in SortedPairsByMemberValue(itemList, "name") do
                    spawnmenu.CreateContentIcon("inventoryitem", btn.PropPanel, {
                        name = itemListData.name,
                        id = itemListData.id
                    })
                end
            end

            node.DoClick = function(btn)
                btn:DoPopulate()
                pnlContent:SwitchPanel(btn.PropPanel)
            end
        end
    end
end

search.AddProvider(function(str)
    local results = {}
    if not str or str == "" then return results end
    local query = string.lower(str)
    for uniqueID, itemData in pairs(lia.item.list or {}) do
        local name = tostring(itemData.name or "")
        local desc = tostring(itemData.desc or "")
        local category = tostring((itemData.getCategory and itemData:getCategory()) or "")
        if string.find(string.lower(name), query, 1, true) or string.find(string.lower(desc), query, 1, true) or string.find(string.lower(category), query, 1, true) or string.find(string.lower(uniqueID), query, 1, true) then
            local icon = spawnmenu.CreateContentIcon("inventoryitem", g_SpawnMenu and g_SpawnMenu.SearchPropPanel or nil, {
                name = name ~= "" and name or uniqueID,
                id = uniqueID
            })

            table.insert(results, {
                text = name ~= "" and name or uniqueID,
                icon = icon
            })
        end
    end

    table.SortByMember(results, "text", true)
    return results
end, "inventoryitems")

spawnmenu.AddCreationTab(L("inventoryItems"), function()
    local client = LocalPlayer()
    if not IsValid(client) or not client.hasPrivilege or not client:hasPrivilege("canUseItemSpawner") then
        local pnl = vgui.Create("DPanel")
        pnl:Dock(FILL)
        pnl.Paint = function(_, w, h) draw.SimpleText(L("noItemSpawnerPermission"), "DermaDefault", w / 2, h / 2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        return pnl
    else
        local ctrl = vgui.Create("SpawnmenuContentPanel")
        if isfunction(ctrl.EnableSearch) then ctrl:EnableSearch("inventoryitems", "PopulateInventoryItems") end
        timer.Simple(0, function() if IsValid(ctrl) then ctrl:CallPopulateHook("PopulateInventoryItems") end end)
        return ctrl
    end
end, "icon16/briefcase.png")
