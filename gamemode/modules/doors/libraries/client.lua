local appendDoorAdminFallbackRows
function MODULE:GetDoorInfo(entity, doorData, doorInfo)
    local owner = entity:GetDTEntity(0)
    local classes = doorData.classes or {}
    local factions = doorData.factions or {}
    local price = doorData.price or 0
    local hasFactions = factions and #factions > 0
    local hasClasses = classes and #classes > 0
    local ownable = not (doorData.noSell or hasFactions or hasClasses)
    local title = doorData.title or doorData.name or entity:getNetVar("doorTitle", "")
    if isstring(title) then title = string.Trim(title) end
    if title and title ~= "" then
        table.insert(doorInfo, {
            text = title
        })
    end

    if ownable and price > 0 then
        table.insert(doorInfo, {
            text = "Price(" .. "): " .. lia.currency.get(price)
        })
    end

    if ownable and not IsValid(owner) then
        table.insert(doorInfo, {
            text = "You can purchase this door by pressing F2."
        })
    end

    if IsValid(owner) then
        table.insert(doorInfo, {
            text = string.format("This door is owned by %s.", owner:Name())
        })
    end

    if factions and #factions > 0 then
        table.insert(doorInfo, {
            text = "Allowed Factions(" .. "):"
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
                text = "Allowed Classes(" .. "):"
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

local function normalizeDoorInfoRows(infoEntries)
    local rows = {}
    for _, entry in ipairs(infoEntries or {}) do
        if istable(entry) then
            if entry.divider then
                rows[#rows + 1] = {
                    divider = true
                }
            else
                local row = table.Copy(entry)
                local text = isstring(row.text) and string.Trim(row.text) or ""
                if text ~= "" and not row.label and not row.value then
                    local label, value = text:match("^([^:]+):%s*(.+)$(")
                    if label and value then
                        row.label = string.Trim(label)
                        row.value = string.Trim(value)
                        row.text = nil
                    elseif text:sub(-1) == "):" then
                        row.section = string.Trim(text:sub(1, -2))
                        row.text = nil
                    else
                        row.text = text
                    end
                end

                if row.label or row.value or row.text or row.section then rows[#rows + 1] = row end
            end
        elseif isstring(entry) then
            local text = string.Trim(entry)
            if text == "" then
                rows[#rows + 1] = {
                    divider = true
                }
            else
                local label, value = text:match("^([^:]+):%s*(.+)$(")
                if label and value then
                    rows[#rows + 1] = {
                        label = string.Trim(label),
                        value = string.Trim(value)
                    }
                elseif text:sub(-1) == "):" then
                    rows[#rows + 1] = {
                        section = string.Trim(text:sub(1, -2))
                    }
                else
                    rows[#rows + 1] = {
                        text = text
                    }
                end
            end
        end
    end
    return rows
end

local function DrawDoorInfoBox(entity, title, infoRows, alphaOverride)
    if not (IsValid(entity) and ((title and title ~= "") or (infoRows and #infoRows > 0))) then return end
    local distSqr = EyePos():DistToSqr(entity:GetPos())
    local maxDist = 256
    if distSqr > maxDist * maxDist then return end
    local dist = math.sqrt(distSqr)
    local minDist = 20
    local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
    local appearThreshold = 0.8
    local disappearThreshold = 0.01
    local fadeAlpha
    if normalized <= disappearThreshold then
        fadeAlpha = 0
    elseif normalized >= appearThreshold then
        fadeAlpha = 1
    else
        fadeAlpha = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
    end

    if alphaOverride then
        if alphaOverride > 1 then
            fadeAlpha = math.Clamp(alphaOverride / 255, 0, 1)
        else
            fadeAlpha = math.Clamp(alphaOverride, 0, 1)
        end
    end

    if fadeAlpha <= 0 then return end
    local worldPosition = entity.WorldSpaceCenter and entity:WorldSpaceCenter() or entity:GetPos()
    local screenPosition = worldPosition:ToScreen()
    if screenPosition.visible == false then return end
    local accent = lia.color.theme.accent or lia.color.theme.theme or color_white
    lia.derma.drawBoxWithText(nil, screenPosition.x + 24, screenPosition.y, {
        title = title,
        rows = infoRows,
        textAlignX = TEXT_ALIGN_LEFT,
        textAlignY = TEXT_ALIGN_CENTER,
        minWidth = 320,
        maxWidth = 520,
        padding = 12,
        rowHeight = 18,
        sectionGap = 6,
        columnGap = 18,
        backgroundColor = Color(3, 18, 22, math.floor(232 * fadeAlpha)),
        borderColor = Color(accent.r, accent.g, accent.b, math.floor(110 * fadeAlpha)),
        textColor = Color(235, 240, 242, math.floor(255 * fadeAlpha)),
        mutedTextColor = Color(160, 178, 180, math.floor(255 * fadeAlpha)),
        accentColor = Color(accent.r, accent.g, accent.b, math.floor(255 * fadeAlpha)),
        accentAlpha = math.floor(210 * fadeAlpha),
        shadow = {
            enabled = true,
            color = Color(0, 0, 0, math.floor(125 * fadeAlpha)),
            offsetX = 8,
            offsetY = 14
        },
        blur = {
            enabled = true,
            amount = 2,
            passes = 2,
            alpha = 0.65 * fadeAlpha
        }
    })
end

local function buildDoorDisplayData(entity)
    if not IsValid(entity) then return end
    if not entity:isDoor() then return end
    local doorData = lia.doors.getData(entity)
    local title = doorData.title or doorData.name or entity:getNetVar("doorTitle", "")
    if isstring(title) then title = string.Trim(title) end
    if doorData.disabled then
        return {
            disabled = true,
            entity = entity,
            title = title
        }
    end

    local doorInfo = {}
    local doorsModule = lia.module.get("doors")
    if doorsModule and isfunction(doorsModule.GetDoorInfo) then doorsModule:GetDoorInfo(entity, doorData, doorInfo) end
    hook.Run("FilterDoorInfo", entity, doorData, doorInfo)
    local infoRows = normalizeDoorInfoRows(doorInfo)
    local owner = entity:GetDTEntity(0)
    local hasFactions = istable(doorData.factions) and #doorData.factions > 0
    local hasClasses = istable(doorData.classes) and #doorData.classes > 0
    local ownable = not (doorData.noSell or hasFactions or hasClasses)
    if title and title ~= "" and infoRows[1] and infoRows[1].text == title then table.remove(infoRows, 1) end
    if (not title or title == "") and #infoRows == 0 then
        local client = LocalPlayer()
        local canSeeAdminData = IsValid(client) and (client:hasPrivilege("manageDoors") or client:isStaffOnDuty())
        if canSeeAdminData then
            title = "Door Information"
            appendDoorAdminFallbackRows(entity, doorData, infoRows)
        elseif IsValid(owner) then
            title = "Owned Door"
            infoRows[#infoRows + 1] = {
                text = string.format("This door is owned by %s.", owner:Name())
            }
        elseif ownable then
            title = "Unowned Door"
            infoRows[#infoRows + 1] = {
                text = "You can purchase this door by pressing F2."
            }
        elseif hasFactions or hasClasses then
            title = "Door Information"
            if hasFactions then
                infoRows[#infoRows + 1] = {
                    text = "Allowed Factions"
                }
            end

            if hasClasses then
                infoRows[#infoRows + 1] = {
                    text = "Allowed Classes"
                }
            end
        end
    end

    if (title and title ~= "") or #infoRows > 0 then
        return {
            entity = entity,
            title = title,
            rows = infoRows
        }
    end
end

function MODULE:DrawEntityInfo(entity, alpha)
    return
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if not (IsValid(client) and client:getChar()) then return end
    local activeWeapon = client:GetActiveWeapon()
    if IsValid(activeWeapon) and activeWeapon:GetClass() == "lia_adminstick" then return end
    local trace = client:GetEyeTraceNoCursor()
    local entity = trace.Entity
    if not IsValid(entity) then return end
    if not entity:isDoor() then return end
    local distance = client:GetShootPos():Distance(trace.HitPos)
    if distance > 256 then return end
    local displayData = buildDoorDisplayData(entity)
    if not displayData then return end
    if displayData.disabled then
        lia.util.drawEntText(entity, "This door is disabled.", 0, 255)
        return
    end

    DrawDoorInfoBox(entity, displayData.title, displayData.rows, 255)
end

function MODULE:GetAdminStickLists(tgt, lists)
    if not IsValid(tgt) or not tgt:isDoor() then return end
    local client = LocalPlayer()
    local hasManageDoors = client:hasPrivilege("manageDoors")
    local isStaffOnDuty = client:isStaffOnDuty()
    local permission = hasManageDoors or isStaffOnDuty
    if not permission then return end
    local doorData = lia.doors.getData(tgt)
    local factionsAssigned = doorData.factions or {}
    local existingClasses = doorData.classes or {}
    local addFactionItems = {}
    for _, faction in pairs(lia.faction.teams) do
        if not table.HasValue(factionsAssigned, faction.uniqueID) then
            table.insert(addFactionItems, {
                name = faction.name,
                icon = "icon16/group_add.png",
                callback = function() LocalPlayer():ConCommand("say /dooraddfaction '" .. faction.uniqueID .. "'") end
            })
        end
    end

    if #addFactionItems > 0 then
        table.insert(lists, {
            name = "Add Factions",
            category = "Door Management",
            subcategory = "Factions",
            subSubcategory = "Add Factions",
            items = addFactionItems
        })
    end

    local removeFactionItems = {}
    for _, id in ipairs(factionsAssigned) do
        local faction = lia.faction.get(id)
        if faction then
            table.insert(removeFactionItems, {
                name = faction.name,
                icon = "icon16/group_delete.png",
                callback = function() LocalPlayer():ConCommand("say /doorremovefaction '" .. faction.uniqueID .. "'") end
            })
        end
    end

    if #removeFactionItems > 0 then
        table.insert(lists, {
            name = string.format("Remove %s", "Factions"),
            category = "Door Management",
            subcategory = "Factions",
            subSubcategory = "removeFactions",
            items = removeFactionItems
        })
    end

    local addClassItems = {}
    for classID, classData in pairs(lia.class.list) do
        local isAlreadyAssigned = false
        for _, classUID in ipairs(existingClasses) do
            if lia.class.retrieveClass(classUID) == classID then
                isAlreadyAssigned = true
                break
            end
        end

        if not isAlreadyAssigned then
            table.insert(addClassItems, {
                name = classData.name,
                icon = "icon16/user_add.png",
                callback = function() LocalPlayer():ConCommand("say /doorsetclass '" .. classID .. "'") end
            })
        end
    end

    if #addClassItems > 0 then
        table.insert(lists, {
            name = "Add Classes",
            category = "Door Management",
            subcategory = "Classes",
            subSubcategory = "Add Classes",
            items = addClassItems
        })
    end

    local removeClassItems = {}
    for _, classUID in ipairs(existingClasses) do
        local classIndex = lia.class.retrieveClass(classUID)
        local classInfo = lia.class.list[classIndex]
        if classInfo then
            table.insert(removeClassItems, {
                name = classInfo.name,
                icon = "icon16/user_delete.png",
                callback = function() LocalPlayer():ConCommand("say /doorremoveclass '" .. classUID .. "'") end
            })
        end
    end

    if #existingClasses > 0 then
        table.insert(removeClassItems, {
            name = "Remove" .. " " .. "All" .. " " .. "Classes",
            icon = "icon16/delete.png",
            callback = function() LocalPlayer():ConCommand("say /doorremoveclass ''") end
        })
    end

    if #removeClassItems > 0 then
        table.insert(lists, {
            name = string.format("Remove %s", "Classes"),
            category = "Door Management",
            subcategory = "Classes",
            subSubcategory = "removeClasses",
            items = removeClassItems
        })
    end
end

appendDoorAdminFallbackRows = function(entity, doorData, infoRows)
    local owner = entity:GetDTEntity(0)
    if IsValid(owner) then
        infoRows[#infoRows + 1] = {
            text = string.format("This door is owned by %s.", owner:Name())
        }
    end

    if (doorData.price or 0) > 0 then
        infoRows[#infoRows + 1] = {
            label = "Price",
            value = lia.currency.get(doorData.price)
        }
    end

    infoRows[#infoRows + 1] = {
        label = "Can Be Sold",
        value = doorData.noSell and "No" or "Yes"
    }

    infoRows[#infoRows + 1] = {
        label = "Hidden",
        value = doorData.hidden and "Yes" or "No"
    }

    infoRows[#infoRows + 1] = {
        label = "Locked",
        value = doorData.locked and "Yes" or "No"
    }

    local factions = doorData.factions or {}
    if #factions > 0 then
        infoRows[#infoRows + 1] = {
            section = "Allowed Factions"
        }

        for _, id in ipairs(factions) do
            local faction = lia.faction.get(id)
            if faction then
                infoRows[#infoRows + 1] = {
                    text = "- " .. faction.name
                }
            end
        end
    end

    local classes = doorData.classes or {}
    if #classes > 0 then
        infoRows[#infoRows + 1] = {
            section = "Allowed Classes"
        }

        for _, uid in ipairs(classes) do
            local index = lia.class.retrieveClass(uid)
            local classInfo = lia.class.list[index]
            if classInfo then
                infoRows[#infoRows + 1] = {
                    text = "- " .. classInfo.name
                }
            end
        end
    end
end

function MODULE:AddToAdminStickHUD(client, target, information)
    if IsValid(target) and target:isDoor() then
        local extraInfo = {}
        hook.Run("GetDoorInfoForAdminStick", target, extraInfo)
        for _, info in ipairs(extraInfo) do
            table.insert(information, info)
        end

        local doorData = lia.doors.getData(target)
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
            name = "Name",
            price = "Price",
            locked = "Locked",
            disabled = "Disabled",
            hidden = "hidden",
            noSell = "Can Be Sold",
            ownable = "Door Can Be Owned",
            factions = "Allowed Factions",
            classes = "Allowed Classes"
        }

        for key, defaultValue in pairs(defaultDoorData) do
            if key ~= "factions" and key ~= "classes" then
                local value = doorData[key]
                local label = doorLabels[key] or key
                local displayValue = value
                if value == nil then displayValue = defaultValue end
                if isbool(displayValue) then
                    local booleanLabels = {
                        locked = function(val) return val and "Locked" or "unlocked" end,
                        disabled = function(val) return val and "Disabled" or "Enabled" end,
                        hidden = function(val) return val and "hidden" or "visible" end,
                        noSell = function(val) return val and "Cannot Be Sold" or "Can Be Sold" end,
                        ownable = function(val) return val and "Door Can Be Owned" or "Cannot Be Owned" end
                    }

                    if booleanLabels[key] then
                        displayValue = booleanLabels[key](displayValue)
                    else
                        displayValue = displayValue and "Yes" or "No"
                    end
                elseif isnumber(displayValue) and key == "price" then
                    displayValue = lia.currency.get(displayValue)
                elseif istable(displayValue) then
                    displayValue = util.TableToJSON(displayValue)
                elseif isstring(displayValue) and displayValue == "" then
                    displayValue = "None("
                end

                table.insert(information, label .. "): " .. displayValue)
            end
        end

        local factions = doorData.factions
        if factions and #factions > 0 then
            local factionNames = {}
            for _, factionId in ipairs(factions) do
                local faction = lia.faction.indices[factionId]
                if faction then table.insert(factionNames, faction.name) end
            end

            if #factionNames > 0 then
                table.insert(information, "Allowed Factions(" .. "):")
                for _, factionName in ipairs(factionNames) do
                    table.insert(information, "- " .. factionName)
                end
            end
        end

        local classes = doorData.classes
        if classes and #classes > 0 then
            local classNames = {}
            for _, classId in ipairs(classes) do
                local classIndex = lia.class.retrieveClass(classId)
                local classInfo = lia.class.list[classIndex]
                if classInfo then table.insert(classNames, classInfo.name) end
            end

            if #classNames > 0 then
                table.insert(information, "Allowed Classes(" .. "):")
                for _, className in ipairs(classNames) do
                    table.insert(information, "- " .. className)
                end
            end
        end

        if target.liaAccess then table.insert(information, string.format("Access Data: %s", util.TableToJSON(target.liaAccess))) end
        if target.liaPartner and IsValid(target.liaPartner) then table.insert(information, string.format("Partner Door: %s", tostring(target.liaPartner))) end
        table.insert(information, string.format("Is Locked: %s", target:isLocked() and "Yes" or "No"))
        table.insert(information, string.format("ID: %s", tostring(target:MapCreationID())))
    end
end
