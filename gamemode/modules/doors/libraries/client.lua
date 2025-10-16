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
            text = "Allowed Factions:"
        })

        for _, id in ipairs(factions) do
            local info = lia.faction.get(id)
            if info then
                table.insert(doorInfo, {
                    text = "- " .. info.name,
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
                text = "Allowed Classes:"
            })

            for _, data in ipairs(classData) do
                table.insert(doorInfo, {
                    text = "- " .. data.name,
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

-- Add door information to admin stick HUD
function MODULE:AddToAdminStickHUD(_, target, information)
    if IsValid(target) and target:isDoor() then
        -- Allow other modules to add custom door information
        local extraInfo = {}
        hook.Run("GetDoorInfoForAdminStick", target, extraInfo)
        -- Add extra information from sub-hook
        for _, info in ipairs(extraInfo) do
            table.insert(information, info)
        end

        -- Basic door data from netvars with defaults
        local doorData = target:getNetVar("doorData", {})
        -- Define all possible door variables with their default values
        local defaultDoorData = {
            name = "",
            price = 0,
            locked = false,
            disabled = false,
            hidden = false,
            noSell = false,
            ownable = true,
            factions = {},
            classes = {}
        }

        -- Create user-friendly labels and formatters for door variables
        local doorLabels = {
            name = "Name",
            price = "Price",
            locked = "Locked",
            disabled = "Disabled",
            hidden = "Hidden",
            noSell = "Can Be Sold",
            ownable = "Can Be Owned",
            factions = "Allowed Factions",
            classes = "Allowed Classes"
        }

        -- Show all door variables (defined values override defaults)
        for key, defaultValue in pairs(defaultDoorData) do
            -- Skip factions and classes here as they're handled separately below
            if key ~= "factions" and key ~= "classes" then
                local value = doorData[key]
                local label = doorLabels[key] or key
                local displayValue = value
                -- Use defined value if it exists, otherwise use default
                if value == nil then displayValue = defaultValue end
                -- Handle different value types with custom formatting
                if type(displayValue) == "boolean" then
                    -- Format boolean values with appropriate labels
                    local booleanLabels = {
                        locked = function(val) return val and "Locked" or "Unlocked" end,
                        disabled = function(val) return val and "Disabled" or "Enabled" end,
                        hidden = function(val) return val and "Hidden" or "Visible" end,
                        noSell = function(val) return val and "Cannot Be Sold" or "Can Be Sold" end,
                        ownable = function(val) return val and "Can Be Owned" or "Cannot Be Owned" end
                    }

                    if booleanLabels[key] then
                        displayValue = booleanLabels[key](displayValue)
                    else
                        displayValue = displayValue and "Yes" or "No"
                    end
                elseif type(displayValue) == "number" and key == "price" then
                    displayValue = lia.currency.get(displayValue)
                elseif type(displayValue) == "table" then
                    displayValue = util.TableToJSON(displayValue)
                elseif type(displayValue) == "string" and displayValue == "" then
                    displayValue = "(none)"
                end

                table.insert(information, label .. ": " .. displayValue)
            end
        end

        -- Faction access
        local factions = target:getNetVar("factions")
        if factions and factions ~= "[]" then
            local factionData = util.JSONToTable(factions)
            if factionData and #factionData > 0 then
                local factionNames = {}
                for _, factionId in ipairs(factionData) do
                    local faction = lia.faction.indices[factionId]
                    if faction then table.insert(factionNames, faction.name) end
                end

                if #factionNames > 0 then
                    table.insert(information, "Allowed Factions:")
                    for _, factionName in ipairs(factionNames) do
                        table.insert(information, "- " .. factionName)
                    end
                end
            end
        end

        -- Class access
        local classes = target:getNetVar("classes")
        if classes and classes ~= "[]" then
            local classData = util.JSONToTable(classes)
            if classData and #classData > 0 then
                local classNames = {}
                for _, classId in ipairs(classData) do
                    local classIndex = lia.class.retrieveClass(classId)
                    local classInfo = lia.class.list[classIndex]
                    if classInfo then table.insert(classNames, classInfo.name) end
                end

                if #classNames > 0 then
                    table.insert(information, "Allowed Classes:")
                    for _, className in ipairs(classNames) do
                        table.insert(information, "- " .. className)
                    end
                end
            end
        end

        -- Door access data
        if target.liaAccess then table.insert(information, "Access Data: " .. util.TableToJSON(target.liaAccess)) end
        -- Door partner
        if target.liaPartner and IsValid(target.liaPartner) then table.insert(information, "Partner Door: " .. tostring(target.liaPartner)) end
        -- Entity properties
        table.insert(information, "Is Locked: " .. (target:isLocked() and "Yes" or "No"))
        table.insert(information, "ID: " .. tostring(target:MapCreationID()))
    end
end