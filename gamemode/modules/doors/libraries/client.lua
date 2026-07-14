--[[
    Hooks:
        GetDoorInfo(Entity entity, table doorData, table doorInfo)

    Purpose:
        Populates the mutable clientside door information list that is shown when the player looks at a visible door.

    Category:
        Doors

    Parameters:
        entity (Entity)
            The door entity currently being inspected.

        doorData (table)
            The cached door data resolved for the entity.

        doorInfo (table)
            The mutable list that receives formatted entries with `text` and optional `color` fields.

    Example Usage:
        ```lua
        hook.Add("GetDoorInfo", "liaExampleGetDoorInfo", function(entity, doorData, doorInfo)
            if IsValid(entity) and doorData.title and doorData.title ~= "" then
                doorInfo[#doorInfo + 1] = {
                    text = "Internal title: " .. doorData.title
                }
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        FilterDoorInfo(Entity entity, table doorData, table doorInfo)

    Purpose:
        Runs after door information entries are assembled so client code can adjust the final list before it is rendered.

    Category:
        Doors

    Parameters:
        entity (Entity)
            The door entity currently being inspected.

        doorData (table)
            The cached door data resolved for the entity.

        doorInfo (table)
            The mutable list of formatted door information entries that will be rendered.

    Example Usage:
        ```lua
        hook.Add("FilterDoorInfo", "liaExampleFilterDoorInfo", function(entity, doorData, doorInfo)
            if not (doorData.hidden and doorInfo[1]) then return end
            doorInfo[#doorInfo + 1] = {
                text = "Hidden door"
            }
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        GetDoorInfoForAdminStick(Entity target, table extraInfo)

    Purpose:
        Allows clientside code to append extra door-specific text lines to the admin stick HUD output.

    Category:
        Doors

    Parameters:
        target (Entity)
            The door entity currently targeted by the admin stick.

        extraInfo (table)
            The mutable array of additional text lines that will be appended to the admin stick HUD.

    Example Usage:
        ```lua
        hook.Add("GetDoorInfoForAdminStick", "liaExampleGetDoorInfoForAdminStick", function(target, extraInfo)
            if IsValid(target) and target:isDoor() then
                extraInfo[#extraInfo + 1] = "Map ID: " .. target:MapCreationID()
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
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
            text = L("price") .. ": " .. lia.currency.get(price)
        })
    end

    if ownable and not IsValid(owner) then
        table.insert(doorInfo, {
            text = L("doorIsOwnable")
        })
    end

    if IsValid(owner) then
        table.insert(doorInfo, {
            text = L("doorOwnedBy", owner:Name())
        })
    end

    if factions and #factions > 0 then
        table.insert(doorInfo, {
            text = L("allowedFactions") .. ":"
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
                text = L("allowedClasses") .. ":"
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
                    local label, value = text:match("^([^:]+):%s*(.+)$")
                    if label and value then
                        row.label = string.Trim(label)
                        row.value = string.Trim(value)
                        row.text = nil
                    elseif text:sub(-1) == ":" then
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
                local label, value = text:match("^([^:]+):%s*(.+)$")
                if label and value then
                    rows[#rows + 1] = {
                        label = string.Trim(label),
                        value = string.Trim(value)
                    }
                elseif text:sub(-1) == ":" then
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
    if doorsModule and isfunction(doorsModule.GetDoorInfo) then
        doorsModule:GetDoorInfo(entity, doorData, doorInfo)
    end

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
            title = L("doorInformation")
            appendDoorAdminFallbackRows(entity, doorData, infoRows)
        elseif IsValid(owner) then
            title = L("doorTitleOwned")
            infoRows[#infoRows + 1] = {
                text = L("doorOwnedBy", owner:Name())
            }
        elseif ownable then
            title = L("doorTitle")
            infoRows[#infoRows + 1] = {
                text = L("doorIsOwnable")
            }
        elseif hasFactions or hasClasses then
            title = L("doorInformation")
            if hasFactions then
                infoRows[#infoRows + 1] = {
                    text = L("allowedFactions")
                }
            end

            if hasClasses then
                infoRows[#infoRows + 1] = {
                    text = L("allowedClasses")
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
        lia.util.drawEntText(entity, L("doorDisabled"), 0, 255)
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
            name = L("addFactions"),
            category = "doorManagement",
            subcategory = "factions",
            subSubcategory = "addFactions",
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
            name = L("removeThing", L("factions")),
            category = "doorManagement",
            subcategory = "factions",
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
            name = L("addClasses"),
            category = "doorManagement",
            subcategory = "classes",
            subSubcategory = "addClasses",
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
            name = L("remove") .. " " .. L("all") .. " " .. L("classes"),
            icon = "icon16/delete.png",
            callback = function() LocalPlayer():ConCommand("say /doorremoveclass ''") end
        })
    end

    if #removeClassItems > 0 then
        table.insert(lists, {
            name = L("removeThing", L("classes")),
            category = "doorManagement",
            subcategory = "classes",
            subSubcategory = "removeClasses",
            items = removeClassItems
        })
    end
end

appendDoorAdminFallbackRows = function(entity, doorData, infoRows)
    local owner = entity:GetDTEntity(0)
    if IsValid(owner) then
        infoRows[#infoRows + 1] = {
            text = L("doorOwnedBy", owner:Name())
        }
    end

    if (doorData.price or 0) > 0 then
        infoRows[#infoRows + 1] = {
            label = L("price"),
            value = lia.currency.get(doorData.price)
        }
    end

    infoRows[#infoRows + 1] = {
        label = L("doorCanBeSold"),
        value = doorData.noSell and L("no") or L("yes")
    }

    infoRows[#infoRows + 1] = {
        label = L("hidden"),
        value = doorData.hidden and L("yes") or L("no")
    }

    infoRows[#infoRows + 1] = {
        label = L("locked"),
        value = doorData.locked and L("yes") or L("no")
    }

    local factions = doorData.factions or {}
    if #factions > 0 then
        infoRows[#infoRows + 1] = {
            section = L("allowedFactions")
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
            section = L("allowedClasses")
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
            name = L("name"),
            price = L("price"),
            locked = L("locked"),
            disabled = L("disabled"),
            hidden = L("hidden"),
            noSell = L("doorCanBeSold"),
            ownable = L("doorCanBeOwned"),
            factions = L("allowedFactions"),
            classes = L("allowedClasses")
        }

        for key, defaultValue in pairs(defaultDoorData) do
            if key ~= "factions" and key ~= "classes" then
                local value = doorData[key]
                local label = doorLabels[key] or key
                local displayValue = value
                if value == nil then displayValue = defaultValue end
                if isbool(displayValue) then
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
                elseif isnumber(displayValue) and key == "price" then
                    displayValue = lia.currency.get(displayValue)
                elseif istable(displayValue) then
                    displayValue = util.TableToJSON(displayValue)
                elseif isstring(displayValue) and displayValue == "" then
                    displayValue = L("none")
                end

                table.insert(information, label .. ": " .. displayValue)
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
                table.insert(information, L("allowedFactions") .. ":")
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
                table.insert(information, L("allowedClasses") .. ":")
                for _, className in ipairs(classNames) do
                    table.insert(information, "- " .. className)
                end
            end
        end

        if target.liaAccess then table.insert(information, L("doorAccessDataLabel", util.TableToJSON(target.liaAccess))) end
        if target.liaPartner and IsValid(target.liaPartner) then table.insert(information, L("doorPartnerDoorLabel", tostring(target.liaPartner))) end
        table.insert(information, L("doorIsLockedLabel", target:isLocked() and L("yes") or L("no")))
        table.insert(information, L("idPrefix", tostring(target:MapCreationID())))
    end
end
