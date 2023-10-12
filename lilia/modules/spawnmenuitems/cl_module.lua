--------------------------------------------------------------------------------------------------------------------------
function MODULE:InitializedModules()
    RunConsoleCommand("spawnmenu_reload")
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PopulateItems(pnlContent, tree, node)
    local categorised = {}
    for k, v in pairs(lia.item.list) do
        local category = v.category and v.category == "misc" and "Miscellaneous" or v.category and v.category or "Miscellaneous"
        categorised[category] = categorised[category] or {}
        table.insert(categorised[category], v)
    end

    for categoryName, v in SortedPairs(categorised) do
        local node = tree:AddNode(categoryName, "icon16/bricks.png")
        node.DoPopulate = function(pnl)
            if pnl.itemPanel then return end
            pnl.itemPanel = vgui.Create("ContentContainer", pnlContent)
            pnl.itemPanel:SetVisible(false)
            pnl.itemPanel:SetTriggerSpawnlistChange(false)
            for _, item in SortedPairsByMemberValue(v, "name") do
                spawnmenu.CreateContentIcon(
                    "item",
                    pnl.itemPanel,
                    {
                        spawnname = item.uniqueID
                    }
                )
            end
        end

        node.DoClick = function(pnl)
            pnl:DoPopulate()
            pnlContent:SwitchPanel(pnl.itemPanel)
        end
    end

    local FirstNode = tree:Root():GetChildNode(0)
    if IsValid(FirstNode) then
        FirstNode:InternalDoClick()
    end
end
--------------------------------------------------------------------------------------------------------------------------