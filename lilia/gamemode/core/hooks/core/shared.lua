local GM = GM or GAMEMODE
local getModelClass = lia.anim.getModelClass
local IsValid = IsValid
local string = string
local type = type
local vectorAngle = FindMetaTable("Vector").Angle
local normalizeAngle = math.NormalizeAngle
local oldCalcSeqOverride
local PLAYER_HOLDTYPE_TRANSLATOR = lia.anim.PlayerHoldTypeTranslator
local HOLDTYPE_TRANSLATOR = lia.anim.HoldTypeTranslator
function GM:TranslateActivity(client, act)
    local model = string.lower(client.GetModel(client))
    local class = getModelClass(model) or "player"
    local weapon = client.GetActiveWeapon(client)
    if class == "player" then
        if (RaisedWeaponCore and not RaisedWeaponCore.WepAlwaysRaised and client.isWepRaised and not client.isWepRaised(client)) and IsValid(weapon) and client:OnGround() or client:IsNoClipping() then
            if string.find(model, "zombie") then
                local tree = lia.anim.zombie
                if string.find(model, "fast") then tree = lia.anim.fastZombie end
                if tree[act] then return tree[act] end
            end

            local holdType = IsValid(weapon) and (weapon.HoldType or weapon.GetHoldType(weapon)) or "normal"
            holdType = PLAYER_HOLDTYPE_TRANSLATOR[holdType] or "passive"
            local tree = lia.anim.player[holdType]
            if tree and tree[act] then
                if type(tree[act]) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(tree[act])
                    return
                else
                    return tree[act]
                end
            end
        end
        return self.BaseClass.TranslateActivity(self.BaseClass, client, act)
    end

    local tree = lia.anim[class]
    if tree then
        local subClass = "normal"
        if client.InVehicle(client) then
            local vehicle = client.GetVehicle(client)
            local class = vehicle:isChair() and "chair" or vehicle:GetClass()
            if tree.vehicle and tree.vehicle[class] then
                local act = tree.vehicle[class][1]
                local fixvec = tree.vehicle[class][2]
                if fixvec then client:SetLocalPos(Vector(16.5438, -0.1642, -20.5493)) end
                if isstring(act) then
                    client.CalcSeqOverride = client.LookupSequence(client, act)
                    return
                else
                    return act
                end
            else
                act = tree.normal[ACT_MP_CROUCH_IDLE][1]
                if isstring(act) then client.CalcSeqOverride = client:LookupSequence(act) end
                return
            end
        elseif client.OnGround(client) then
            client.ManipulateBonePosition(client, 0, vector_origin)
            if IsValid(weapon) then
                subClass = weapon.HoldType or weapon.GetHoldType(weapon)
                subClass = HOLDTYPE_TRANSLATOR[subClass] or subClass
            end

            if tree[subClass] and tree[subClass][act] then
                local index = (not client.isWepRaised or client:isWepRaised()) and 2 or 1
                local act2 = tree[subClass][act][index]
                if isstring(act2) then
                    client.CalcSeqOverride = client.LookupSequence(client, act2)
                    return
                end
                return act2
            end
        elseif tree.glide then
            return tree.glide
        end
    end
end

function GM:DoAnimationEvent(client, event, data)
    local class = lia.anim.getModelClass(client:GetModel())
    if class == "player" then
        return self.BaseClass:DoAnimationEvent(client, event, data)
    else
        local weapon = client:GetActiveWeapon()
        if IsValid(weapon) then
            local holdType = weapon.HoldType or weapon:GetHoldType()
            holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType
            local animation = lia.anim[class][holdType]
            if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
                return ACT_VM_PRIMARYATTACK
            elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
                return ACT_VM_SECONDARYATTACK
            elseif event == PLAYERANIMEVENT_RELOAD then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.reload or ACT_GESTURE_RELOAD_SMG1, true)
                return ACT_INVALID
            elseif event == PLAYERANIMEVENT_JUMP then
                client.m_bJumping = true
                client.m_bFistJumpFrame = true
                client.m_flJumpStartTime = CurTime()
                client:AnimRestartMainSequence()
                return ACT_INVALID
            elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
                client:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
                return ACT_INVALID
            end
        end
    end
    return ACT_INVALID
end

function GM:HandlePlayerLanding(client, velocity, wasOnGround)
    if client:GetMoveType() == MOVETYPE_NOCLIP then return end
    if client:IsOnGround() and not wasOnGround then
        local length = (client.lastVelocity or velocity):LengthSqr()
        local animClass = lia.anim.getModelClass(client:GetModel())
        if animClass ~= "player" and length < 100000 then return end
        client:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
        return true
    end
end

function GM:CalcMainActivity(client, velocity)
    client.CalcIdeal = ACT_MP_STAND_IDLE
    oldCalcSeqOverride = client.CalcSeqOverride
    client.CalcSeqOverride = -1
    local animClass = lia.anim.getModelClass(client:GetModel())
    if animClass ~= "player" then client:SetPoseParameter("move_yaw", normalizeAngle(vectorAngle(velocity)[2] - client:EyeAngles()[2])) end
    if not (self:HandlePlayerLanding(client, velocity, client.m_bWasOnGround) or self:HandlePlayerNoClipping(client, velocity) or self:HandlePlayerDriving(client) or self:HandlePlayerVaulting(client, velocity) or (usingPlayerAnims and self:HandlePlayerJumping(client, velocity)) or self:HandlePlayerSwimming(client, velocity) or self:HandlePlayerDucking(client, velocity)) then
        local len2D = velocity:Length2DSqr()
        if len2D > 22500 then
            client.CalcIdeal = ACT_MP_RUN
        elseif len2D > 0.25 then
            client.CalcIdeal = ACT_MP_WALK
        end
    end

    client.m_bWasOnGround = client:IsOnGround()
    client.m_bWasNoclipping = client:GetMoveType() == MOVETYPE_NOCLIP and not client:InVehicle()
    client.lastVelocity = velocity
    if CLIENT then client:SetIK(false) end
    return client.CalcIdeal, oldCalcSeqOverride
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

function GM:GetMaxPlayerCharacter(client)
    LiliaDeprecated("GetMaxPlayerCharacter is deprecated. Use GetMaxPlayerChar for optimization purposes.")
    hook.Run("GetMaxPlayerChar", client)
end

function GM:CanPlayerCreateCharacter(client)
    LiliaDeprecated("CanPlayerCreateCharacter is deprecated. Use CanPlayerCreateChar for optimization purposes.")
    hook.Run("CanPlayerCreateChar", client)
end

function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

local function getAllFilesInDirectory(directory, extension)
    local files = {}
    local function scanDirectory(dir)
        local fileList, directoryList = file.Find(dir .. "/*", "GAME")
        for _, fileName in ipairs(fileList) do
            if string.EndsWith(fileName, extension) then table.insert(files, dir .. "/" .. fileName) end
        end

        for _, subDir in ipairs(directoryList) do
            scanDirectory(dir .. "/" .. subDir)
        end
    end

    scanDirectory(directory)
    return files
end

local function getAllCitizenModels()
    local allModels = {}
    for _, path in ipairs(lia.anim.CitizenModelPaths) do
        local modelsInPath = getAllFilesInDirectory(path, ".mdl")
        for _, model in ipairs(modelsInPath) do
            table.insert(allModels, model)
        end
    end
    return allModels
end

function GM:InitializedModules()
    for model, animtype in pairs(lia.anim.DefaultTposingFixer) do
        lia.anim.setModelClass(model, animtype)
    end

    for _, model in ipairs(getAllCitizenModels()) do
        local lowerModel = string.lower(model)
        local class = string.find(lowerModel, "female_") and "citizen_female" or "citizen_male"
        lia.anim.setModelClass(lowerModel, class)
    end

    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
        RunConsoleCommand("spawnmenu_reload")
    else
        local bootstrapEndTime = SysTime()
        local timeTaken = bootstrapEndTime - BootingTime
        LogBootstrap("Bootstrapper", string.format("Lilia loaded in %.2f seconds.", timeTaken), Color(0, 255, 0))
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
                                LiliaPrint("Adding column " .. data.field .. " to the database!")
                            else
                                LiliaPrint("Failed to add column " .. data.field .. " due to a query error.")
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

function widgets.PlayerTick()
end

hook.Remove("PlayerTick", "TickWidgets")