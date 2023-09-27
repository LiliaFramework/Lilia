--------------------------------------------------------------------------------------------------------
function MODULE:InitializedModules()
    RunConsoleCommand("spawnmenu_reload")
end

--------------------------------------------------------------------------------------------------------
spawnmenu.AddContentType(
    "item",
    function(container, object)
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
    end
)

--------------------------------------------------------------------------------------------------------
function MODULE:PopulateItems(pnlContent, tree, parentNode)
    local categorised = {}
    for k, v in pairs(lia.item.list) do
        local category = v.category and v.category == "misc" and "Miscellaneous" or v.category and v.category or "Miscellaneous"
        categorised[category] = categorised[category] or {}
        table.insert(categorised[category], v)
    end

    for categoryName, itemTable in SortedPairs(categorised) do
        local node = tree:AddNode(categoryName, "icon16/bricks.png")
        node.DoPopulate = function(treeNode)
            if treeNode.itemPanel then return end
            treeNode.itemPanel = vgui.Create("ContentContainer", pnlContent)
            treeNode.itemPanel:SetVisible(false)
            treeNode.itemPanel:SetTriggerSpawnlistChange(false)
            for _, item in SortedPairsByMemberValue(itemTable, "name") do
                spawnmenu.CreateContentIcon(
                    "item",
                    treeNode.itemPanel,
                    {
                        spawnname = item.uniqueID
                    }
                )
            end
        end

        node.DoClick = function(treeNode)
            treeNode:DoPopulate()
            pnlContent:SwitchPanel(treeNode.itemPanel)
        end
    end

    local firstNode = tree:Root():GetChildNode(0)
    if IsValid(firstNode) then
        firstNode:InternalDoClick()
    end
end

--------------------------------------------------------------------------------------------------------
spawnmenu.AddCreationTab(
    "Items",
    function()
        local ctrl = vgui.Create("SpawnmenuContentPanel")
        ctrl:EnableSearch("items", "PopulateItems")
        ctrl:CallPopulateHook("PopulateItems")

        return ctrl
    end, "icon16/cog_add.png", 200
)
--------------------------------------------------------------------------------------------------------