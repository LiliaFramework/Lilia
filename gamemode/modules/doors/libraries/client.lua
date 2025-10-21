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

    if ownable and not IsValid(owner) then
        table.insert(doorInfo, {
            text = L("doorCanBeOwned")
        })
    end

    if IsValid(owner) then
        table.insert(doorInfo, {
            text = L("doorOwnedBy", owner:Name())
        })
    end

    if factions and #factions > 0 then
        table.insert(doorInfo, {
            text = L("doorAllowedFactions") .. ":"
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
                text = L("doorAllowedClasses") .. ":"
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
    -- Don't show door UI if admin stick is out
    local client = LocalPlayer()
    if IsValid(client) and client:GetActiveWeapon():GetClass() == "adminstick" then return end
    if entity:isDoor() then
        local doorData = entity:getNetVar("doorData", {})
        if not (doorData.hidden or false) then
            if doorData.disabled then
                lia.util.drawEntText(entity, L("doorDisabled"), 0, alpha)
                return
            end

            local doorInfo = {}
            hook.Run("GetDoorInfo", entity, doorData, doorInfo)
            -- Allow filtering/modifying door information before display
            -- Hook: FilterDoorInfo(entity, doorData, doorInfo)
            -- Parameters:
            --   entity: The door entity
            --   doorData: The door's configuration data
            --   doorInfo: Table of door information entries (can be modified)
            -- Each entry in doorInfo has: {text = "display text", color = Color(255,255,255)}
            -- You can remove entries by setting them to nil or remove them from the table
            -- Example: Remove price information for non-admins
            -- hook.Add("FilterDoorInfo", "HidePriceForNonAdmins", function(entity, doorData, doorInfo)
            --     if not LocalPlayer():isStaffOnDuty() then
            --         for i = #doorInfo, 1, -1 do
            --             if doorInfo[i].text and doorInfo[i].text:find("Price:") then
            --                 table.remove(doorInfo, i)
            --             end
            --         end
            --     end
            -- end)
            hook.Run("FilterDoorInfo", entity, doorData, doorInfo)
            -- Collect all door info text into a single array
            local infoTexts = {}
            for _, info in ipairs(doorInfo) do
                if info.text and info.text ~= "" then table.insert(infoTexts, info.text) end
            end

            -- Draw all door info in a single box if there's any info
            if #infoTexts > 0 then self:DrawDoorInfoBox(entity, infoTexts, alpha) end
        end
    end
end

function MODULE:DrawDoorInfoBox(entity, infoTexts, alphaOverride)
    if not (IsValid(entity) and infoTexts and #infoTexts > 0) then return end
    -- Use the same distance and fade logic as drawEntText
    local distSqr = EyePos():DistToSqr(entity:GetPos())
    local maxDist = 380
    if distSqr > maxDist * maxDist then return end
    local dist = math.sqrt(distSqr)
    local minDist = 20
    local idx = entity:EntIndex()
    local prev = lia.util.entsScales[idx] or 0
    local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
    local appearThreshold = 0.8
    local disappearThreshold = 0.01
    local target
    if normalized <= disappearThreshold then
        target = 0
    elseif normalized >= appearThreshold then
        target = 1
    else
        target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
    end

    local dt = FrameTime() or 0.016
    local appearSpeed = 18
    local disappearSpeed = 12
    local speed = (target > prev) and appearSpeed or disappearSpeed
    local cur = lia.util.approachExp(prev, target, speed, dt)
    if math.abs(cur - target) < 0.0005 then cur = target end
    if cur == 0 and target == 0 then
        lia.util.entsScales[idx] = nil
        return
    end

    lia.util.entsScales[idx] = cur
    local eased = lia.util.easeInOutCubic(cur)
    if eased <= 0 then return end
    local fade = eased
    if alphaOverride then
        if alphaOverride > 1 then
            fade = fade * math.Clamp(alphaOverride / 255, 0, 1)
        else
            fade = fade * math.Clamp(alphaOverride, 0, 1)
        end
    end

    if fade <= 0 then return end
    -- Apply fade to colors
    local fadeAlpha = math.Clamp(fade, 0, 1)
    -- Draw at bottom center of screen
    local screenX = ScrW() / 2
    local screenY = ScrH() - 50
    -- Draw the door info box using drawBoxWithText
    lia.derma.drawBoxWithText(infoTexts, screenX, screenY, {
        font = "LiliaFont.18",
        textColor = Color(255, 255, 255, math.floor(255 * fadeAlpha)),
        backgroundColor = Color(0, 0, 0, math.floor(150 * fadeAlpha)),
        borderColor = Color(lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, math.floor(255 * fadeAlpha)),
        borderRadius = 8,
        borderThickness = 2,
        padding = 20,
        textAlignX = TEXT_ALIGN_CENTER,
        textAlignY = TEXT_ALIGN_BOTTOM,
        lineSpacing = 4,
        autoSize = true,
        blur = {
            enabled = true,
            amount = 3,
            passes = 3,
            alpha = fadeAlpha * 0.9
        }
    })
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

function MODULE:AddToAdminStickHUD(_, target, information)
    if IsValid(target) and target:isDoor() then
        local extraInfo = {}
        hook.Run("GetDoorInfoForAdminStick", target, extraInfo)
        for _, info in ipairs(extraInfo) do
            table.insert(information, info)
        end

        local doorData = target:getNetVar("doorData", {})
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

        local doorLabels = {
            name = L("name"),
            price = L("price"),
            locked = L("locked"),
            disabled = L("disabled"),
            hidden = L("hidden"),
            noSell = L("doorCanBeSold"),
            ownable = L("doorCanBeOwned"),
            factions = L("doorAllowedFactions"),
            classes = L("doorAllowedClasses")
        }

        for key, defaultValue in pairs(defaultDoorData) do
            if key ~= "factions" and key ~= "classes" then
                local value = doorData[key]
                local label = doorLabels[key] or key
                local displayValue = value
                if value == nil then displayValue = defaultValue end
                if type(displayValue) == "boolean" then
                    local booleanLabels = {
                        locked = function(val) return val and L("locked") or L("unlocked") end,
                        disabled = function(val) return val and L("disabled") or L("enabled") end,
                        hidden = function(val) return val and L("hidden") or L("visible") end,
                        noSell = function(val) return val and L("doorCannotBeSold") or L("doorCanBeSold") end,
                        ownable = function(val) return val and L("doorCanBeOwned") or L("doorCannotBeOwned") end
                    }

                    if booleanLabels[key] then
                        displayValue = booleanLabels[key](displayValue)
                    else
                        displayValue = displayValue and L("yes") or L("no")
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
                    table.insert(information, L("doorAllowedFactions") .. ":")
                    for _, factionName in ipairs(factionNames) do
                        table.insert(information, "- " .. factionName)
                    end
                end
            end
        end

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
                    table.insert(information, L("doorAllowedClasses") .. ":")
                    for _, className in ipairs(classNames) do
                        table.insert(information, "- " .. className)
                    end
                end
            end
        end

        if target.liaAccess then table.insert(information, "Access Data: " .. util.TableToJSON(target.liaAccess)) end
        if target.liaPartner and IsValid(target.liaPartner) then table.insert(information, "Partner Door: " .. tostring(target.liaPartner)) end
        table.insert(information, "Is Locked: " .. (target:isLocked() and "Yes" or "No"))
        table.insert(information, "ID: " .. tostring(target:MapCreationID()))
    end
end
