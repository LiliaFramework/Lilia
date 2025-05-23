﻿local function textWrap(text, font, maxWidth)
    text = text or ""
    local totalWidth = 0
    surface.SetFont(font)
    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
        local char = string.sub(word, 1, 1)
        if char == "\n" or char == "\t" then totalWidth = 0 end
        local wordlen = surface.GetTextSize(word)
        totalWidth = totalWidth + wordlen
        if wordlen >= maxWidth then
            local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
            totalWidth = splitPoint
            return splitWord
        elseif totalWidth < maxWidth then
            return word
        end

        if char == ' ' then
            totalWidth = wordlen - spaceWidth
            return '\n' .. string.sub(word, 2)
        end

        totalWidth = wordlen
        return '\n' .. word
    end)
    return text
end

spawnmenu.AddContentType("inventoryitem", function(container, data)
    local client = LocalPlayer()
    if not client:hasPrivilege("Staff Permissions - Can Use Item Spawner") then return end
    local icon = vgui.Create("ContentIcon", container)
    icon:SetContentType("inventoryitem")
    icon:SetSpawnName(data.id)
    icon:SetName(data.name)
    local itemData = lia.item.list[data.id]
    local model = itemData.model or "default.mdl"
    local matName = string.Replace(model, ".mdl", "")
    icon.Image:SetMaterial(Material("spawnicons/" .. matName .. ".png"))
    icon:SetColor(Color(205, 92, 92, 255))
    icon:SetTooltip(textWrap(itemData.desc or "", "DermaDefault", 560))
    icon.DoClick = function()
        net.Start("SpawnMenuSpawnItem")
        net.WriteString(data.id)
        net.SendToServer()
        surface.PlaySound("outlands-rp/ui/ui_return.wav")
    end

    icon.OpenMenu = function()
        local menu = DermaMenu()
        menu:AddOption("Copy", function() SetClipboardText(icon:GetSpawnName()) end):SetIcon("icon16/page_copy.png")
        menu:AddOption("Give To Character...", function()
            local popup = vgui.Create("DFrame")
            popup:SetTitle("Spawn " .. data.id)
            popup:SetSize(300, 100)
            popup:Center()
            popup:MakePopup()
            local label = vgui.Create("DLabel", popup)
            label:Dock(TOP)
            label:SetText("Give to:")
            local combo = vgui.Create("DComboBox", popup)
            combo:Dock(TOP)
            for _, character in pairs(lia.char.getAll()) do
                local ply = character:getPlayer()
                if IsValid(ply) then
                    local steamID = ply:SteamID() or ""
                    local name = character:getName() or L("unknown")
                    combo:AddChoice(string.format("[%s] [%s]", name, steamID), steamID)
                end
            end

            local button = vgui.Create("liaSmallButton", popup)
            button:Dock(BOTTOM)
            button:SetText("Spawn item")
            button.DoClick = function()
                local _, target = combo:GetSelected()
                net.Start("SpawnMenuGiveItem")
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

    for uniqueID, itemData in pairs(allItems) do
        if itemData.category then
            categorized[itemData.category] = categorized[itemData.category] or {}
            table.insert(categorized[itemData.category], {
                id = uniqueID,
                name = itemData.name
            })
        else
            table.insert(categorized.Unsorted, {
                id = uniqueID,
                name = itemData.name
            })
        end
    end

    for category, itemList in SortedPairs(categorized) do
        if category ~= "Unsorted" or #itemList > 0 then
            local node = tree:AddNode(category, "icon16/picture.png")
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

spawnmenu.AddCreationTab("Inventory Items", function()
    local client = LocalPlayer()
    if not IsValid(client) or not client.hasPrivilege or not client:hasPrivilege("Staff Permissions - Can Use Item Spawner") then
        local pnl = vgui.Create("DPanel")
        pnl:Dock(FILL)
        pnl.Paint = function(_, w, h) draw.SimpleText("You don't have permission to use this.", "DermaDefault", w / 2, h / 2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        return pnl
    else
        local ctrl = vgui.Create("SpawnmenuContentPanel")
        ctrl:CallPopulateHook("PopulateInventoryItems")
        return ctrl
    end
end, "icon16/briefcase.png")
