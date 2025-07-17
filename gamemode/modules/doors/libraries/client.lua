function MODULE:DrawEntityInfo(entity, alpha)
    if entity:isDoor() and not entity:getNetVar("hidden", false) then
        if entity:getNetVar("disabled", false) then
            local pos = entity:LocalToWorld(entity:OBBCenter()):ToScreen()
            lia.util.drawText(L("doorDisabled"), pos.x, pos.y, ColorAlpha(color_white, alpha), 1, 1)
            return
        end

        local pos = entity:LocalToWorld(entity:OBBCenter()):ToScreen()
        local x, y = pos.x, pos.y
        local owner = entity:GetDTEntity(0)
        local name = entity:getNetVar("title", entity:getNetVar("name", IsValid(owner) and L("doorTitleOwned") or not entity:getNetVar("class") and not entity:getNetVar("factions") and L("doorTitle") or ""))
        local factions = entity:getNetVar("factions", "[]")
        local class = entity:getNetVar("class")
        local price = entity:getNetVar("price", 0)
        local ownable = not entity:getNetVar("noSell", false)
        lia.util.drawText(name, x, y, ColorAlpha(color_white, alpha), 1, 1)
        y = y + 20
        if ownable then
            lia.util.drawText(L("priceLabel", lia.currency.get(price)), x, y, ColorAlpha(color_white, alpha), 1, 1)
            y = y + 20
        end

        local classData
        if class and lia.class.list[class] then classData = lia.class.list[class] end
        if IsValid(owner) then
            lia.util.drawText(L("doorOwnedBy", owner:Name()), x, y, ColorAlpha(color_white, alpha), 1, 1)
            y = y + 20
        end

        if factions and factions ~= "[]" then
            local facs = util.JSONToTable(factions)
            if facs then
                lia.util.drawText(L("doorFactions"), x, y, ColorAlpha(color_white, alpha), 1, 1)
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
            lia.util.drawText(L("classes"), x, y, ColorAlpha(color_white, alpha), 1, 1)
            y = y + 20
            lia.util.drawText(classData.name, x, y, classData.color or color_white, 1, 1)
            y = y + 20
        end

        if not IsValid(owner) and factions == "[]" and not class then lia.util.drawText(ownable and L("doorIsOwnable") or L("doorIsNotOwnable"), x, y, ColorAlpha(color_white, alpha), 1, 1) end
    end
end

function MODULE:PopulateAdminStick(AdminMenu, target)
    if IsValid(target) and target:isDoor() then
        local factionsAssignedRaw = target:getNetVar("factions", "[]")
        local factionsAssigned = util.JSONToTable(factionsAssignedRaw) or {}
        local addFactionMenu = AdminMenu:AddSubMenu(L("doorAddFaction"))
        for _, faction in pairs(lia.faction.teams) do
            if not factionsAssigned[faction.index] then
                addFactionMenu:AddOption(faction.name, function()
                    LocalPlayer():ConCommand('say /dooraddfaction "' .. faction.uniqueID .. '"')
                    AdminStickIsOpen = false
                end)
            end
        end

        if table.Count(factionsAssigned) > 0 then
            local removeFactionMenu = AdminMenu:AddSubMenu(L("doorRemoveFactionAdmin"))
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
            AdminMenu:AddOption(L("doorNoFactions")):SetEnabled(false)
        end

        local setClassMenu = AdminMenu:AddSubMenu(L("doorSetDoorClass"))
        for classID, classData in pairs(lia.class.list) do
            setClassMenu:AddOption(classData.name, function()
                LocalPlayer():ConCommand('doorsetclass "' .. classID .. '"')
                AdminStickIsOpen = false
            end)
        end

        if target:getNetVar("class") then
            setClassMenu:AddOption(L("doorRemoveDoorClass"), function()
                LocalPlayer():ConCommand('doorsetclass ""')
                AdminStickIsOpen = false
            end)
        end
    end
end
