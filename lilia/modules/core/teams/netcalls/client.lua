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
  frame:SetTitle("Classes List")
  frame:SetSize(600, 400)
  frame:Center()
  frame:MakePopup()
  local classList = vgui.Create("DListView", frame)
  classList:Dock(FILL)
  classList:AddColumn("Name")
  classList:AddColumn("Description")
  classList:AddColumn("Faction")
  classList:AddColumn("Default")
  for _, class in pairs(classes) do
    classList:AddLine(class.name, class.desc, class.faction, class.isDefault and "Yes" or "No")
  end
end)

net.Receive("factionlist", function()
  local factions = net.ReadTable()
  local frame = vgui.Create("DFrame")
  frame:SetTitle("Factions List")
  frame:SetSize(500, 400)
  frame:Center()
  frame:MakePopup()
  local factionList = vgui.Create("DListView", frame)
  factionList:Dock(FILL)
  factionList:AddColumn("Name")
  factionList:AddColumn("Description")
  factionList:AddColumn("Color")
  factionList:AddColumn("Default")
  function factionList:OnRowRightClick(lineID)
    local menu = DermaMenu()
    menu:AddOption("View Classes", function()
      local faction = factions[lineID]
      LocalPlayer():ConCommand("say /classlist " .. faction.name)
      frame:Remove()
    end):SetIcon("icon16/user.png")

    menu:Open()
  end

  for _, faction in pairs(factions) do
    factionList:AddLine(faction.name, faction.desc, string.format("RGB(%d, %d, %d)", faction.color.r, faction.color.g, faction.color.b), faction.isDefault and "Yes" or "No")
  end
end)
