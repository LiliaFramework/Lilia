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