netstream.Hook("classUpdate", function(joinedClient)
    if lia.gui.classes and lia.gui.classes:IsVisible() then
        if joinedClient == LocalPlayer() then
            lia.gui.classes:loadClasses()
        else
            for _, v in ipairs(lia.gui.classes.classPanels) do
                local data = v.data
                v:setNumber(#lia.class.getPlayers(data.index))
            end
        end
    end
end)

net.Receive("classlist", function()
    local classes = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("classListTitle"))
    frame:SetSize(600, 400)
    frame:Center()
    frame:MakePopup()
    local classList = vgui.Create("DListView", frame)
    classList:Dock(FILL)
    classList:AddColumn(L("name"))
    classList:AddColumn(L("description"))
    classList:AddColumn(L("faction"))
    classList:AddColumn(L("default"))
    for _, class in pairs(classes) do
        classList:AddLine(L(class.name), L(class.desc), L(class.faction), class.isDefault and L("yes") or L("no"))
    end
end)

net.Receive("factionlist", function()
    local factions = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("factionListTitle"))
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    local factionList = vgui.Create("DListView", frame)
    factionList:Dock(FILL)
    factionList:AddColumn(L("name"))
    factionList:AddColumn(L("description"))
    factionList:AddColumn(L("color"))
    factionList:AddColumn(L("default"))
    function factionList:OnRowRightClick(lineID)
        local menu = DermaMenu()
        menu:AddOption(L("viewClasses"), function()
            local faction = factions[lineID]
            LocalPlayer():ConCommand("say /classlist " .. faction.name)
            frame:Remove()
        end):SetIcon("icon16/user.png")

        menu:Open()
    end

    for _, faction in pairs(factions) do
        factionList:AddLine(L(faction.name), L(faction.desc), string.format("RGB(%d, %d, %d)", faction.color.r, faction.color.g, faction.color.b), faction.isDefault and L("yes") or L("no"))
    end
end)
