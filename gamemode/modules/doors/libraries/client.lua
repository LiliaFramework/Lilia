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
        local classesRaw = entity:getNetVar("classes")
        local factions = entity:getNetVar("factions", "[]")
        local classes = classesRaw
        local price = entity:getNetVar("price", 0)
        local ownable = not entity:getNetVar("noSell", false)
        lia.util.drawText(entity:getNetVar("title", entity:getNetVar("name", IsValid(owner) and L("doorTitleOwned") or (not classesRaw or classesRaw == "[]") and not entity:getNetVar("factions") and L("doorTitle") or "")), x, y, ColorAlpha(color_white, alpha), 1, 1)
        y = y + 20
        if ownable and price > 0 then
            lia.util.drawText(L("price") .. ": " .. lia.currency.get(price), x, y, ColorAlpha(color_white, alpha), 1, 1)
            y = y + 20
        end

        local classesTable = classes and util.JSONToTable(classes) or nil
        local classData
        if classesTable then
            classData = {}
            for _, uid in ipairs(classesTable) do
                local index = lia.class.retrieveClass(uid)
                local info = lia.class.list[index]
                if info then table.insert(classData, info) end
            end
        end

        if IsValid(owner) then
            lia.util.drawText(L("doorOwnedBy", owner:Name()), x, y, ColorAlpha(color_white, alpha), 1, 1)
            y = y + 20
        end

        if factions and factions ~= "[]" then
            local facs = util.JSONToTable(factions)
            if facs then
                lia.util.drawText(L("factions") .. ":", x, y, ColorAlpha(color_white, alpha), 1, 1)
                y = y + 20
                for _, id in ipairs(facs) do
                    local info = lia.faction.get(id)
                    if info then
                        lia.util.drawText(info.name, x, y, info.color or color_white, 1, 1)
                        y = y + 20
                    end
                end
            end
        end

        if classData and #classData > 0 then
            lia.util.drawText(L("classes") .. ":", x, y, ColorAlpha(color_white, alpha), 1, 1)
            y = y + 20
            for _, data in ipairs(classData) do
                lia.util.drawText(data.name, x, y, data.color or color_white, 1, 1)
                y = y + 20
            end
        end

        if not IsValid(owner) and factions == "[]" and (not classes or classes == "[]") then lia.util.drawText(ownable and L("doorIsOwnable") or L("doorIsNotOwnable"), x, y, ColorAlpha(color_white, alpha), 1, 1) end
    end
end

function MODULE:PopulateAdminStick(AdminMenu, target)
    if IsValid(target) and target:isDoor() then
        local factionsAssignedRaw = target:getNetVar("factions", "[]")
        local factionsAssigned = util.JSONToTable(factionsAssignedRaw) or {}
        local addFactionMenu, addFactionPanel = AdminMenu:AddSubMenu(L("doorAddFaction"))
        addFactionPanel:SetIcon("icon16/group_add.png")
        for _, faction in pairs(lia.faction.teams) do
            if not table.HasValue(factionsAssigned, faction.uniqueID) then
                addFactionMenu:AddOption(faction.name, function()
                    LocalPlayer():ConCommand('say /dooraddfaction "' .. faction.uniqueID .. '"')
                    AdminStickIsOpen = false
                end):SetIcon("icon16/group_add.png")
            end
        end

        if #factionsAssigned > 0 then
            local removeFactionMenu, removeFactionPanel = AdminMenu:AddSubMenu(L("doorRemoveFactionAdmin"))
            removeFactionPanel:SetIcon("icon16/group_delete.png")
            for _, id in ipairs(factionsAssigned) do
                local faction = lia.faction.get(id)
                if faction then
                    removeFactionMenu:AddOption(faction.name, function()
                        LocalPlayer():ConCommand('say /doorremovefaction "' .. faction.uniqueID .. '"')
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/group_delete.png")
                end
            end
        else
            AdminMenu:AddOption(L("doorNoFactions")):SetEnabled(false)
        end

        local setClassMenu, setClassPanel = AdminMenu:AddSubMenu(L("set") .. " " .. L("door") .. " " .. L("class"))
        setClassPanel:SetIcon("icon16/tag_blue.png")
        for classID, classData in pairs(lia.class.list) do
            setClassMenu:AddOption(classData.name, function()
                LocalPlayer():ConCommand('say /doorsetclass "' .. classID .. '"')
                AdminStickIsOpen = false
            end):SetIcon("icon16/tag_blue.png")
        end

        local existingClasses = target:getNetVar("classes")
        if existingClasses and existingClasses ~= "[]" then
            setClassMenu:AddOption(L("remove") .. " " .. L("class"), function()
                LocalPlayer():ConCommand('say /doorsetclass ""')
                AdminStickIsOpen = false
            end):SetIcon("icon16/delete.png")
        end
    end
end