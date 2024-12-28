local GM = GM or GAMEMODE
local string = string
function GM:Move(client, moveData)
    local character = client:getChar()
    if not character then return end
    if client:GetMoveType() == MOVETYPE_WALK and moveData:KeyDown(IN_WALK) then
        local mf, ms = 0, 0
        local speed = client:GetWalkSpeed()
        local ratio = lia.config.WalkRatio
        if moveData:KeyDown(IN_FORWARD) then
            mf = ratio
        elseif moveData:KeyDown(IN_BACK) then
            mf = -ratio
        end

        if moveData:KeyDown(IN_MOVELEFT) then
            ms = -ratio
        elseif moveData:KeyDown(IN_MOVERIGHT) then
            ms = ratio
        end

        moveData:SetForwardSpeed(mf * speed)
        moveData:SetSideSpeed(ms * speed)
    end
end

function GM:Move(client, moveData)
    local character = client:getChar()
    if not character then return end
    if client:GetMoveType() == MOVETYPE_WALK and moveData:KeyDown(IN_WALK) then
        local mf, ms = 0, 0
        local speed = client:GetWalkSpeed()
        local ratio = lia.config.WalkRatio
        if moveData:KeyDown(IN_FORWARD) then
            mf = ratio
        elseif moveData:KeyDown(IN_BACK) then
            mf = -ratio
        end

        if moveData:KeyDown(IN_MOVELEFT) then
            ms = -ratio
        elseif moveData:KeyDown(IN_MOVERIGHT) then
            ms = ratio
        end

        moveData:SetForwardSpeed(mf * speed)
        moveData:SetSideSpeed(ms * speed)
    end
end

function GM:LiliaLoaded()
    local namecache = {}
    for _, MODULE in pairs(lia.module.list) do
        local authorID = (tonumber(MODULE.author) and tostring(MODULE.author)) or (string.match(MODULE.author, "STEAM_") and util.SteamIDTo64(MODULE.author)) or "Unknown"
        if authorID then
            if namecache[authorID] ~= nil then
                MODULE.author = namecache[authorID]
            else
                steamworks.RequestPlayerInfo(authorID, function(newName)
                    namecache[authorID] = newName
                    MODULE.author = newName or MODULE.author
                end)
            end
        end
    end

    lia.module.namecache = namecache
end

function GM:InitPostEntity()
    if SERVER then
        lia.faction.formatModelData()
        timer.Simple(2, function() lia.entityDataLoaded = true end)
        lia.db.waitForTablesToLoad():next(function()
            hook.Run("LoadData")
            hook.Run("PostLoadData")
        end)
    else
        lia.joinTime = RealTime() - 0.9716
        if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
    end
end

function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

function GM:InitializedModules()
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
        RunConsoleCommand("spawnmenu_reload")
    else
        local bootstrapEndTime = SysTime()
        local timeTaken = bootstrapEndTime - BootingTime
        LiliaBootstrap("Bootstrapper", string.format("Lilia loaded in %.2f seconds.", timeTaken), Color(0, 255, 0))
        for _, data in pairs(lia.char.vars) do
            if data.fieldType then
                local fieldDefinition
                if data.fieldType == "string" then
                    fieldDefinition = data.field .. " VARCHAR(" .. (data.length or "255") .. ")"
                elseif data.fieldType == "integer" then
                    fieldDefinition = data.field .. " INT"
                elseif data.fieldType == "float" then
                    fieldDefinition = data.field .. " FLOAT"
                elseif data.fieldType == "boolean" then
                    fieldDefinition = data.field .. " TINYINT(1)"
                elseif data.fieldType == "datetime" then
                    fieldDefinition = data.field .. " DATETIME"
                elseif data.fieldType == "text" then
                    fieldDefinition = data.field .. " TEXT"
                end

                if fieldDefinition then
                    if data.default ~= nil then fieldDefinition = fieldDefinition .. " DEFAULT '" .. tostring(data.default) .. "'" end
                    lia.db.query("SELECT " .. data.field .. " FROM lia_characters", function(result)
                        if not result then
                            local success, _ = lia.db.query("ALTER TABLE lia_characters ADD COLUMN " .. fieldDefinition)
                            if success then
                                LiliaInformation("Adding column " .. data.field .. " to the database!")
                            else
                                LiliaInformation("Failed to add column " .. data.field .. " due to a query error.")
                            end
                        end
                    end)
                end
            end
        end
    end
end

function GM:GetAttributeMax(_, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.MaxAttributePoints end
    if istable(attribTable) and isnumber(attribTable.maxValue) then return attribTable.maxValue end
    return lia.config.MaxAttributePoints
end

function GM:GetAttributeStartingMax(_, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.MaxStartingAttributes end
    if istable(attribTable) and isnumber(attribTable.startingMax) then return attribTable.startingMax end
    return lia.config.MaxStartingAttributes
end

function GM:GetMaxStartingAttributePoints()
    return lia.config.StartingAttributePoints
end

function GM:GetMaxPlayerCharacter(client)
    LiliaDeprecated("GetMaxPlayerCharacter", function() hook.Run("GetMaxPlayerChar", client) end)
end

function GM:CanPlayerCreateCharacter(client)
    LiliaDeprecated("CanPlayerCreateCharacter", function() hook.Run("CanPlayerCreateChar", client) end)
end

function widgets.PlayerTick()
end

hook.Remove("PlayerTick", "TickWidgets")