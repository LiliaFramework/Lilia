function MODULE:GetDoorInfo(entity, doorData, doorInfo)
    local owner = entity:GetDTEntity(0)
    local classes = doorData.classes or {}
    local factions = doorData.factions or {}
    local price = doorData.price or 0
    local ownable = not (doorData.noSell or false)
    local title = doorData.title or doorData.name or ""
    if title and title ~= "" then
        table.insert(doorInfo, {
            text = title
        })
    end

    if ownable and price > 0 then
        table.insert(doorInfo, {
            text = L("price") .. ": " .. lia.currency.get(price)
        })
    end

    if IsValid(owner) then
        table.insert(doorInfo, {
            text = L("doorOwnedBy", owner:Name())
        })
    end

    if factions and #factions > 0 then
        table.insert(doorInfo, {
            text = L("factions") .. ":"
        })

        for _, id in ipairs(factions) do
            local info = lia.faction.get(id)
            if info then
                table.insert(doorInfo, {
                    text = info.name,
                    color = info.color or color_white
                })
            end
        end
    end

    if classes and #classes > 0 then
        local classData = {}
        for _, uid in ipairs(classes) do
            local index = lia.class.retrieveClass(uid)
            local info = lia.class.list[index]
            if info then table.insert(classData, info) end
        end

        if #classData > 0 then
            table.insert(doorInfo, {
                text = L("classes") .. ":"
            })

            for _, data in ipairs(classData) do
                table.insert(doorInfo, {
                    text = data.name,
                    color = data.color or color_white
                })
            end
        end
    end
end

function MODULE:DrawEntityInfo(entity, alpha)
    if entity:isDoor() then
        local doorData = entity:getNetVar("doorData", {})
        if not (doorData.hidden or false) then
            if doorData.disabled then
                local pos = entity:LocalToWorld(entity:OBBCenter()):ToScreen()
                lia.util.drawText(L("doorDisabled"), pos.x, pos.y, ColorAlpha(color_white, alpha), 1, 1)
                return
            end

            local pos = entity:LocalToWorld(entity:OBBCenter()):ToScreen()
            local x, y = pos.x, pos.y
            local doorInfo = {}
            hook.Run("GetDoorInfo", entity, doorData, doorInfo)
            for _, info in ipairs(doorInfo) do
                if info.text and info.text ~= "" then
                    local color = info.color or ColorAlpha(color_white, alpha)
                    lia.util.drawText(info.text, x, y, color, 1, 1)
                    y = y + 20
                end
            end
        end
    end
end

function MODULE:PopulateAdminStick(AdminMenu, target)
    if IsValid(target) and target:isDoor() then
        local doorData = target:getNetVar("doorData", {})
        local factionsAssigned = doorData.factions or {}
        local addFactionMenu, addFactionPanel = AdminMenu:AddSubMenu(L("doorAddFaction"))
        addFactionPanel:SetIcon("icon16/group_add.png")
        for _, faction in pairs(lia.faction.teams) do
            if not table.HasValue(factionsAssigned, faction.uniqueID) then
                addFactionMenu:AddOption(faction.name, function()
                    LocalPlayer():ConCommand("say /dooraddfaction '" .. faction.uniqueID .. "'")
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
                        LocalPlayer():ConCommand("say /doorremovefaction '" .. faction.uniqueID .. "'")
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/group_delete.png")
                end
            end
        else
            AdminMenu:AddOption(L("doorNoFactions")):SetEnabled(false)
        end

        local setClassMenu, setClassPanel = AdminMenu:AddSubMenu(L("set") .. " " .. L("door") .. " " .. L("class"))
        setClassPanel:SetIcon("icon16/tag_blue.png")
        local existingClasses = doorData.classes or {}
        for classID, classData in pairs(lia.class.list) do
            local isAlreadyAssigned = false
            for _, classUID in ipairs(existingClasses) do
                if lia.class.retrieveClass(classUID) == classID then
                    isAlreadyAssigned = true
                    break
                end
            end

            if not isAlreadyAssigned then
                setClassMenu:AddOption(classData.name, function()
                    LocalPlayer():ConCommand("say /doorsetclass '" .. classID .. "'")
                    AdminStickIsOpen = false
                end):SetIcon("icon16/tag_blue.png")
            end
        end

        if existingClasses and #existingClasses > 0 then
            local removeClassMenu, removeClassPanel = AdminMenu:AddSubMenu(L("remove") .. " " .. L("door") .. " " .. L("class"))
            removeClassPanel:SetIcon("icon16/delete.png")
            for _, classUID in ipairs(existingClasses) do
                local classIndex = lia.class.retrieveClass(classUID)
                local classInfo = lia.class.list[classIndex]
                if classInfo then
                    removeClassMenu:AddOption(classInfo.name, function()
                        LocalPlayer():ConCommand("say /doorremoveclass '" .. classUID .. "'")
                        AdminStickIsOpen = false
                    end):SetIcon("icon16/delete.png")
                end
            end

            removeClassMenu:AddOption(L("remove") .. " " .. L("all") .. " " .. L("classes"), function()
                LocalPlayer():ConCommand("say /doorremoveclass ''")
                AdminStickIsOpen = false
            end):SetIcon("icon16/delete.png")
        end
    end
end
