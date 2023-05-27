net.Receive("LiliaResetVariablesNew", function()
    local background = vgui.Create("DFrame")
    background:SetSize(ScrW() / 2, ScrH() / 2)
    background:Center()
    background:SetTitle("Admin Spawn Menu")
    background:MakePopup()
    background:ShowCloseButton(true)
    scroll = background:Add("DScrollPanel")
    scroll:Dock(FILL)
    categoryPanels = {}

    for k, v in pairs(lia.item.list) do
        if not categoryPanels[L(v.category)] then
            categoryPanels[L(v.category)] = v.category
        end
    end

    for category, realName in SortedPairs(categoryPanels) do
        local collapsibleCategory = scroll:Add("DCollapsibleCategory")
        collapsibleCategory:SetTall(36)
        collapsibleCategory:SetLabel(category)
        collapsibleCategory:Dock(TOP)
        collapsibleCategory:SetExpanded(0)
        collapsibleCategory:DockMargin(5, 5, 5, 0)
        collapsibleCategory.category = realName

        for k, v in pairs(lia.item.list) do
            if v.category == collapsibleCategory.category and v.category ~= "Weapons" then
                local item = collapsibleCategory:Add("DButton")
                item:SetText(v.name)
                item:SizeToContents()

                item.DoClick = function()
                    net.Start("LiliaResetVariables2")
                    net.WriteString(v.name)
                    net.SendToServer()
                    surface.PlaySound("buttons/button14.wav")
                end
            end
        end

        categoryPanels[realName] = collapsibleCategory
    end
end)

lia.command.add("adminspawnmenu", {
    onRun = function(client, arguments) end
})