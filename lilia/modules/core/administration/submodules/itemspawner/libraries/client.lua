local function textWrap(text, font, maxWidth)
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
    if client:hasPrivilege("Staff Permissions - Can Use Item Spawner") then
        local icon = vgui.Create("ContentIcon", container)
        icon:SetContentType("inventoryitem")
        icon:SetSpawnName(data.id)
        icon:SetName(data.name)
        local itemData = lia.item.list[data.id]
        local modelStr = itemData.model or "default.mdl"
        local matName = string.Replace(modelStr, ".mdl", "")
        icon.Image:SetMaterial(Material("spawnicons/" .. matName .. ".png"))
        icon:SetColor(Color(205, 92, 92, 255))
        local desc = textWrap(itemData.desc or "", "DermaDefault", 560)
        icon:SetTooltip(desc)
        icon.DoClick = function()
            net.Start("lia_spawnItem")
            net.WriteString(data.id)
            net.SendToServer()
            surface.PlaySound("outlands-rp/ui/ui_return.wav")
        end

        icon.OpenMenu = function()
            local menu = DermaMenu()
            menu:AddOption("#spawnmenu.menu.copy", function() SetClipboardText(icon:GetSpawnName()) end):SetIcon("icon16/page_copy.png")
            menu:AddOption("Give to character...", function()
                local popup = vgui.Create("DFrame")
                popup:SetTitle("Spawn " .. data.id)
                popup:SetSize(300, 100)
                popup:Center()
                popup:MakePopup()
                popup:MoveToFront()
                local lbl = vgui.Create("DLabel", popup)
                lbl:Dock(TOP)
                lbl:SetText("Give to:")
                local dropdown = vgui.Create("DComboBox", popup)
                dropdown:Dock(TOP)
                for _, v in pairs(lia.char.loaded) do
                    local chosen = v == LocalPlayer():getChar()
                    dropdown:AddChoice(v:getPlayer():GetName() .. "  [" .. v:getPlayer():steamName() .. "]", v:getPlayer():GetName(), chosen)
                end

                local give = vgui.Create("DButton", popup)
                give:Dock(BOTTOM)
                give:SetText("Spawn item")
                function give:DoClick()
                    local _, target = dropdown:GetSelected()
                    net.Start("lia_spawnItem")
                    net.WriteString(data.id)
                    net.WriteString(target or "")
                    net.SendToServer()
                end
            end)

            menu:Open()
        end

        if IsValid(container) then container:Add(icon) end
        return icon
    else
        return nil
    end
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
        if category ~= "Unsorted" or (#itemList > 0) then
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
    if not LocalPlayer():hasPrivilege("Staff Permissions - Can Use Item Spawner") then
        local pnl = vgui.Create("DPanel")
        pnl:Dock(FILL)
        pnl.Paint = function(_, w, h) draw.SimpleText("You dont have permission to use this.", "DermaDefault", w / 2, h / 2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        return pnl
    else
        local ctrl = vgui.Create("SpawnmenuContentPanel")
        ctrl:CallPopulateHook("PopulateInventoryItems")
        return ctrl
    end
end, "icon16/briefcase.png")
