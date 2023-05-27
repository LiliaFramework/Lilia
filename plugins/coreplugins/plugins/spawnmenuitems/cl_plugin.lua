function PLUGIN:InitializedPlugins()
    RunConsoleCommand("spawnmenu_reload")
end

spawnmenu.AddContentType("item", function(container, object)
    local icon = vgui.Create("SpawnIcon", p)
    icon:SetWide(64)
    icon:SetTall(64)
    icon:InvalidateLayout(true)
    local item = lia.item.list[object.spawnname]
    icon:SetModel(item.model)
    icon:SetTooltip(item.name)

    icon.DoClick = function()
        if LocalPlayer():IsAdmin() then
            surface.PlaySound("ui/buttonclickrelease.wav")
            netstream.Start("liaItemSpawn", item.uniqueID)
        else
            surface.PlaySound("buttons/button10.wav")
        end
    end

    icon:InvalidateLayout(true)

    if IsValid(container) then
        container:Add(icon)
    end

    return icon
end)

hook.Add("PopulateItems", "AddEntityContent", function(pnlContent, tree, node)
    local categorised = {}

    for k, v in pairs(lia.item.list) do
        local category = v.category and v.category == "misc" and "Miscellaneous" or v.category and v.category or "Miscellaneous"
        categorised[category] = categorised[category] or {}
        table.insert(categorised[category], v)
    end

    --
    -- Add a tree node for each category
    --
    for categoryName, v in SortedPairs(categorised) do
        -- Add a node to the tree
        local node = tree:AddNode(categoryName, "icon16/bricks.png")

        -- When we click on the node - populate it using this function
        node.DoPopulate = function(self)
            -- If we've already populated it - forget it.
            if self.itemPanel then return end
            -- Create the container panel
            self.itemPanel = vgui.Create("ContentContainer", pnlContent)
            self.itemPanel:SetVisible(false)
            self.itemPanel:SetTriggerSpawnlistChange(false)

            for _, item in SortedPairsByMemberValue(v, "name") do
                spawnmenu.CreateContentIcon("item", self.itemPanel, {
                    spawnname = item.uniqueID
                })
            end
        end

        -- If we click on the node populate it and switch to it.
        node.DoClick = function(self)
            self:DoPopulate()
            pnlContent:SwitchPanel(self.itemPanel)
        end
    end

    -- Select the first node
    local FirstNode = tree:Root():GetChildNode(0)

    if IsValid(FirstNode) then
        FirstNode:InternalDoClick()
    end
end)

spawnmenu.AddCreationTab("Items", function()
    local ctrl = vgui.Create("SpawnmenuContentPanel")
    ctrl:EnableSearch("items", "PopulateItems")
    ctrl:CallPopulateHook("PopulateItems")

    return ctrl
end, "icon16/cog_add.png", 200)