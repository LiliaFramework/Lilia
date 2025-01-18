function MODULE:DrawEntityInfo(entity, alpha)
  if entity:isDoor() and not entity:getNetVar("hidden", false) then
    if entity:getNetVar("disabled", false) then
      local position = entity:LocalToWorld(entity:OBBCenter()):ToScreen()
      local x, y = position.x, position.y
      lia.util.drawText(L("DoorDisabled"), x, y, ColorAlpha(color_white, alpha), 1, 1)
      return
    end

    local position = entity:LocalToWorld(entity:OBBCenter()):ToScreen()
    local x, y = position.x, position.y
    local owner = entity:GetDTEntity(0)
    local name = entity:getNetVar("title", entity:getNetVar("name", IsValid(owner) and L("DoorTitleOwned") or not entity:getNetVar("class") and not entity:getNetVar("factions") and L("DoorTitle") or ""))
    local factions = entity:getNetVar("factions", "[]")
    local class = entity:getNetVar("class")
    local price = entity:getNetVar("price", 0)
    lia.util.drawText(name, x, y, ColorAlpha(color_white, alpha), 1, 1)
    y = y + 20
    lia.util.drawText(L("DoorPrice", lia.currency.get(price)), x, y, ColorAlpha(color_white, alpha), 1, 1)
    y = y + 20
    local classData
    if class and lia.class.list[class] then classData = lia.class.list[class] end
    if IsValid(owner) then
      lia.util.drawText(L("DoorOwnedBy", owner:Name()), x, y, ColorAlpha(color_white, alpha), 1, 1)
      y = y + 20
    end

    if factions and factions ~= "[]" then
      local facs = util.JSONToTable(factions)
      if facs then
        lia.util.drawText("Factions:", x, y, ColorAlpha(color_white, alpha), 1, 1)
        y = y + 20
        for id, _ in pairs(facs) do
          local info = lia.faction.indices[id]
          if info then
            lia.util.drawText(info.name, x, y, info.color or color_white, 1, 1)
            y = y + 20
          end
        end
      end
    end

    if class and classData then
      lia.util.drawText("Classes:", x, y, ColorAlpha(color_white, alpha), 1, 1)
      y = y + 20
      lia.util.drawText(classData.name, x, y, classData.color or color_white, 1, 1)
      y = y + 20
    end

    if not IsValid(owner) and factions == "[]" and not class then lia.util.drawText(entity:getNetVar("noSell") and L("DoorIsNotOwnable") or L("DoorIsOwnable"), x, y, ColorAlpha(color_white, alpha), 1, 1) end
  end
end

function MODULE:PopulateAdminStick(AdminMenu, target)
  if IsValid(target) and target:isDoor() then
    local factionsAssignedRaw = target:getNetVar("factions", "[]")
    local factionsAssigned = util.JSONToTable(factionsAssignedRaw) or {}
    local addFactionMenu = AdminMenu:AddSubMenu("Add Faction to Door")
    for _, faction in pairs(lia.faction.teams) do
      if not factionsAssigned[faction.index] then
        addFactionMenu:AddOption(faction.name, function()
          LocalPlayer():ConCommand('say /dooraddfaction "' .. faction.uniqueID .. '"')
          AdminStickIsOpen = false
        end)
      end
    end

    if table.Count(factionsAssigned) > 0 then
      local removeFactionMenu = AdminMenu:AddSubMenu("Remove Faction from Door")
      for id, _ in pairs(factionsAssigned) do
        for _, faction in pairs(lia.faction.teams) do
          if faction.index == id then
            removeFactionMenu:AddOption(faction.name, function()
              LocalPlayer():ConCommand('say /doorremovefaction "' .. faction.uniqueID .. '"')
              AdminStickIsOpen = false
            end)
          end
        end
      end
    else
      AdminMenu:AddOption("No factions assigned to this door"):SetEnabled(false)
    end

    local setClassMenu = AdminMenu:AddSubMenu("Set Door Class")
    for classID, classData in pairs(lia.class.list) do
      setClassMenu:AddOption(classData.name, function()
        LocalPlayer():ConCommand('doorsetclass "' .. classID .. '"')
        AdminStickIsOpen = false
      end)
    end

    if target:getNetVar("class") then
      setClassMenu:AddOption("Remove Class", function()
        LocalPlayer():ConCommand('doorsetclass ""')
        AdminStickIsOpen = false
      end)
    end
  end
end
