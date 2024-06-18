--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @meta Player
local playerMeta = FindMetaTable("Player")
local vectorMeta = FindMetaTable("Vector")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    --- Returns this player's currently possessed `Character` object if it exists.
    -- @realm shared
    -- @treturn[1] Character Currently loaded character
    -- @treturn[2] nil If this player has no character loaded
    function playerMeta:getChar()
        return lia.char.loaded[self.getNetVar(self, "char")]
    end

    --- Returns this player's current name.
    -- @realm shared
    -- @treturn[1] string Name of this player's currently loaded character
    -- @treturn[2] string Steam name of this player if the player has no character loaded
    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.GetCharacter = playerMeta.getChar
    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

--- Whitelists all classes for the player.
-- @realm shared
function playerMeta:WhitelistAllClasses()
    for class, _ in pairs(lia.class.list) do
        if lia.class.hasWhitelist(class) then self:classWhitelist(class) end
    end
end

--- Whitelists all factions for the player.
-- @realm shared
function playerMeta:WhitelistAllFactions()
    for faction, _ in pairs(lia.faction.indices) do
        self:setWhitelisted(faction, true)
    end
end

--- Whitelists everything (all classes and factions) for the player.
-- @realm shared
function playerMeta:WhitelistEverything()
    self:WhitelistAllFactions()
    self:WhitelistAllClasses()
end

--- Checks if the player belongs to the "user" user group.
-- @realm shared
-- @treturn bool Whether the player belongs to the "user" user group.
function playerMeta:isUser()
    return self:IsUserGroup("user")
end

--- Checks if the player is a staff member.
-- @realm shared
-- @treturn bool Whether the player is a staff member.
function playerMeta:isStaff()
    return CAMI.PlayerHasAccess(self, "UserGroups - Staff Group", nil) or self:IsSuperAdmin()
end

--- Checks if the player is a VIP.
-- @realm shared
-- @treturn bool Whether the player is a VIP.
function playerMeta:isVIP()
    return CAMI.PlayerHasAccess(self, "UserGroups - VIP Group", nil)
end

--- Checks if the staff member is currently on duty (FACTION_STAFF).
-- @realm shared
-- @treturn bool Whether the staff member is currently on duty.
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

--- Checks if the player is currently observing.
-- @realm shared
-- @treturn bool Whether the player is currently observing.
function playerMeta:isObserving()
    if self:GetMoveType() == MOVETYPE_NOCLIP and not self:InVehicle() then
        return true
    else
        return false
    end
end

--- Checks if the player is currently moving.
-- @realm shared
-- @treturn bool Whether the player is currently moving.
function playerMeta:isMoving()
    if not IsValid(self) or not self:Alive() then return false end
    local keydown = self:KeyDown(IN_FORWARD) or self:KeyDown(IN_BACK) or self:KeyDown(IN_MOVELEFT) or self:KeyDown(IN_MOVERIGHT)
    return keydown and self:OnGround()
end

--- Checks if the player is currently outside (in the sky).
-- @realm shared
-- @treturn bool Whether the player is currently outside (in the sky).
function playerMeta:isOutside()
    local trace = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() + self:GetUp() * 9999999999,
        filter = self
    })
    return trace.HitSky
end

--- Checks if the player is currently in noclip mode.
-- @realm shared
-- @treturn bool Whether the player is in noclip mode.
function playerMeta:isNoClipping()
    return self:GetMoveType() == MOVETYPE_NOCLIP
end

--- Checks if the player has a valid ragdoll entity.
-- @realm shared
-- @treturn bool Whether the player has a valid ragdoll entity.
function playerMeta:hasRagdoll()
    return IsValid(self.liaRagdoll)
end

--- Returns the player's ragdoll entity if valid.
-- @realm shared
-- @treturn Entity|nil The player's ragdoll entity if it exists and is valid, otherwise nil.
function playerMeta:getRagdoll()
    if not self:hasRagdoll() then return end
    return self.liaRagdoll
end

--- Checks if the player belongs to the specified faction.
-- @realm shared
-- @string faction The faction to check against.
-- @treturn bool Whether the player belongs to the specified faction.
function playerMeta:isFaction(faction)
    return self:getChar():getFaction() == faction
end

--- Checks if the player belongs to the specified class.
-- @realm shared
-- @string class The class to check against.
-- @treturn bool Whether the player belongs to the specified class.
function playerMeta:isClass(class)
    return self:getChar():getClass() == class
end

--- Checks if the player is stuck.
-- @realm shared
-- @treturn bool Whether the player is stuck.
function playerMeta:isStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
end

--- Calculates the squared distance from the player to the specified entity.
-- @realm shared
-- @entity entity The entity to calculate the distance to.
-- @treturn number The squared distance from the player to the entity.
function playerMeta:squaredDistanceFromEnt(entity)
    return self:GetPos():DistToSqr(entity)
end

--- Calculates the distance from the player to the specified entity.
-- @realm shared
-- @entity entity The entity to calculate the distance to.
-- @treturn number The distance from the player to the entity.
function playerMeta:distanceFromEnt(entity)
    return self:GetPos():Distance(entity)
end

--- Checks if the player is near another entity within a specified radius.
-- @realm shared
-- @int radius The radius within which to check for proximity.
-- @entity entity The entity to check proximity to.
-- @treturn bool Whether the player is near the specified entity within the given radius.
function playerMeta:isNearPlayer(radius, entity)
    local squaredRadius = radius * radius
    local squaredDistance = self:GetPos():DistToSqr(entity:GetPos())
    return squaredDistance <= squaredRadius
end

--- Retrieves entities near the player within a specified radius.
-- @realm shared
-- @int radius The radius within which to search for entities.
-- @bool[opt] playerOnly If true, only return player entities.
-- @treturn table A table containing the entities near the player.
function playerMeta:entitiesNearPlayer(radius, playerOnly)
    local nearbyEntities = {}
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if playerOnly and not v:IsPlayer() then continue end
        table.insert(nearbyEntities, v)
    end
    return nearbyEntities
end

--- Retrieves the active weapon item of the player.
-- @realm shared
-- @treturn Entity|nil The active weapon entity of the player, or nil if not found.
function playerMeta:getItemWeapon()
    local character = self:getChar()
    local inv = character:getInv()
    local items = inv:getItems()
    local weapon = self:GetActiveWeapon()
    if not IsValid(weapon) then return false end
    for _, v in pairs(items) do
        if v.class then
            if v.class == weapon:GetClass() and v:getData("equip", false) then
                return weapon, v
            else
                return false
            end
        end
    end
end

--- Adds money to the player's character.
-- @realm shared
-- @int amount The amount of money to add.
function playerMeta:addMoney(amount)
    local character = self:getChar()
    if not character then return end
    local currentMoney = character:getMoney()
    local maxMoneyLimit = lia.config.MoneyLimit or 0
    if hook.Run("WalletLimit", self) ~= nil then maxMoneyLimit = hook.Run("WalletLimit", self) end
    if maxMoneyLimit > 0 then
        local totalMoney = currentMoney + amount
        if totalMoney > maxMoneyLimit then
            local remainingMoney = totalMoney - maxMoneyLimit
            character:giveMoney(maxMoneyLimit)
            local money = lia.currency.spawn(self:getItemDropPos(), remainingMoney)
            money.client = self
            money.charID = character:getID()
        else
            character:giveMoney(amount)
        end
    else
        character:giveMoney(amount)
    end
end

--- Takes money from the player's character.
-- @realm shared
-- @int amount The amount of money to take.
function playerMeta:takeMoney(amount)
    local character = self:getChar()
    if character then character:giveMoney(-amount) end
end

--- Retrieves the amount of money owned by the player's character.
-- @realm shared
-- @treturn number The amount of money owned by the player's character.
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--- Checks if the player's character can afford a specified amount of money.
-- @realm shared
-- @int amount The amount of money to check.
-- @treturn bool Whether the player's character can afford the specified amount of money.
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--- Checks if the player is running.
-- @realm shared
-- @treturn bool Whether the player is running.
function playerMeta:isRunning()
    return vectorMeta.Length2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
end

--- Checks if the player's character is female based on the model.
-- @realm shared
-- @treturn bool Whether the player's character is female.
function playerMeta:isFemale()
    local model = self:GetModel():lower()
    return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
end

--- Calculates the position to drop an item from the player's inventory.
-- @realm shared
-- @treturn Vector The position to drop an item from the player's inventory.
function playerMeta:getItemDropPos()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = self:GetShootPos() + self:GetAimVector() * 86
    data.filter = self
    local trace = util.TraceLine(data)
    data.start = trace.HitPos
    data.endpos = data.start + trace.HitNormal * 46
    data.filter = {}
    trace = util.TraceLine(data)
    return trace.HitPos
end

--- Checks if the player has whitelisted access to a faction.
-- @realm shared
-- @int faction The faction to check for whitelisting.
-- @treturn bool Whether the player has whitelisted access to the specified faction.
function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        local liaData = self:getLiliaData("whitelists", {})
        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
    end
    return false
end

--- Checks if the player has whitelisted access to a class.
-- @realm shared
-- @int class The class to check for whitelisting.
-- @treturn bool Whether the player has whitelisted access to the specified faction.
function playerMeta:hasClassWhitelist(class)
    local char = client:getChar()
    if not char then return false end
    local wl = char:getData("whitelist", {})
    return wl[class] ~= nil
end

--- Whitelists the player for a specific class.
-- @realm shared
-- @int class The class to whitelist the player for.
function playerMeta:classWhitelist(class)
    local wl = self:getChar():getData("whitelist", {})
    wl[class] = true
    self:getChar():setData("whitelist", wl)
end

--- Removes the whitelist status for a specific class from the player.
-- @realm shared
-- @int class The class to remove the whitelist status for.
function playerMeta:classUnWhitelist(class)
    local wl = self:getChar():getData("whitelist", {})
    wl[class] = false
    self:getChar():setData("whitelist", wl)
end

--- Retrieves the items of the player's character inventory.
-- @realm shared
-- @treturn table|nil A table containing the items in the player's character inventory, or nil if not found.
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

--- Retrieves the class of the player's character.
-- @realm shared
-- @treturn string|nil The class of the player's character, or nil if not found.
function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

--- Retrieves the entity traced by the player's aim.
-- @realm shared
-- @treturn Entity|nil The entity traced by the player's aim, or nil if not found.
function playerMeta:getTracedEntity()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * 96
    data.filter = self
    local target = util.TraceLine(data).Entity
    return target
end

--- Performs a trace from the player's view.
-- @realm shared
-- @treturn table A table containing the trace result.
function playerMeta:getTrace()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * 200
    data.filter = {self, self}
    data.mins = -Vector(4, 4, 4)
    data.maxs = Vector(4, 4, 4)
    local trace = util.TraceHull(data)
    return trace
end

--- Retrieves the data of the player's character class.
-- @realm shared
-- @treturn table|nil A table containing the data of the player's character class, or nil if not found.
function playerMeta:getClassData()
    local character = self:getChar()
    if character then
        local class = character:getClass()
        if class then
            local classData = lia.class.list[class]
            return classData
        end
    end
end

--- Checks if the player has a skill level equal to or greater than the specified level.
-- @realm shared
-- @string skill The skill to check.
-- @int level The required skill level.
-- @treturn bool Whether the player's skill level meets or exceeds the specified level.
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--- Checks if the player meets the required skill levels.
-- @realm shared
-- @tab requiredSkillLevels A table containing the required skill levels.
-- @treturn bool Whether the player meets all the required skill levels.
function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

--- Retrieves the entity within the player's line of sight.
-- @realm shared
-- @int[opt] distance The maximum distance to consider.
-- @treturn Entity|nil The entity within the player's line of sight, or nil if not found.
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

--- Requests a string input from the player.
-- @realm shared
-- @string title The title of the request.
-- @string subTitle The subtitle of the request.
-- @func callback The function to call upon receiving the string input.
-- @string default The default value for the string input.
function playerMeta:RequestString(title, subTitle, callback, default)
    local time = math.floor(os.time())
    self.StrReqs = self.StrReqs or {}
    self.StrReqs[time] = callback
    net.Start("StringRequest")
    net.WriteUInt(time, 32)
    net.WriteString(title)
    net.WriteString(subTitle)
    net.WriteString(default)
    net.Send(self)
end

if SERVER then
    --- Loads Lilia data for the player from the database.
    -- @func[opt] callback Function to call after the data is loaded, passing the loaded data as an argument.
    -- @realm server
    function playerMeta:loadLiliaData(callback)
        local name = self:steamName()
        local steamID64 = self:SteamID64()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.db.query("SELECT _data, _firstJoin, _lastJoin FROM lia_players WHERE _steamID = " .. steamID64, function(data)
            if IsValid(self) and data and data[1] and data[1]._data then
                lia.db.updateTable({
                    _lastJoin = timeStamp,
                }, nil, "players", "_steamID = " .. steamID64)

                self.firstJoin = data[1]._firstJoin or timeStamp
                self.lastJoin = data[1]._lastJoin or timeStamp
                self.liaData = util.JSONToTable(data[1]._data)
                if callback then callback(self.liaData) end
            else
                lia.db.insertTable({
                    _steamID = steamID64,
                    _steamName = name,
                    _firstJoin = timeStamp,
                    _lastJoin = timeStamp,
                    _data = {}
                }, nil, "players")

                if callback then callback({}) end
            end
        end)
    end

    --- Saves the player's Lilia data to the database.
    -- @realm server
    function playerMeta:saveLiliaData()
        local name = self:steamName()
        local steamID64 = self:SteamID64()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.db.updateTable({
            _steamName = name,
            _lastJoin = timeStamp,
            _data = self.liaData
        }, nil, "players", "_steamID = " .. steamID64)
    end

    --- Sets a key-value pair in the player's Lilia data.
    -- @string key The key for the data.
    -- @param value The value to set.
    -- @bool[opt] noNetworking If true, suppresses network broadcasting of the update.
    -- @realm server
    function playerMeta:setLiliaData(key, value, noNetworking)
        self.liaData = self.liaData or {}
        self.liaData[key] = value
        if not noNetworking then netstream.Start(self, "liaData", key, value) end
    end

    --- Displays a notification for this player in the chatbox.
    -- @realm server
    -- @string message Text to display in the notification
    function playerMeta:chatNotify(message)
        net.Start("chatNotifyNet")
        net.WriteString(message)
        net.Send(self)
    end

    --- Displays a notification for this player in the chatbox with the given language phrase.
    -- @realm server
    -- @string message ID of the phrase to display to the player
    -- @param ... Arguments to pass to the phrase
    function playerMeta:chatNotifyLocalized(message, ...)
        message = L(message, self, ...)
        net.Start("chatNotifyNet")
        net.WriteString(message)
        net.Send(self)
    end

    --- Retrieves a value from the player's Lilia data.
    -- @string key The key for the data.
    -- @param default[opt=nil] The default value to return if the key does not exist.
    -- @realm server
    -- @treturn any The value corresponding to the key, or the default value if the key does not exist.
    function playerMeta:getLiliaData(key, default)
        if key == true then return self.liaData end
        local data = self.liaData and self.liaData[key]
        if data == nil then
            return default
        else
            return data
        end
    end

    --- Sets the player's ragdoll entity.
    -- @realm shared
    -- @tparam Entity entity The entity to set as the player's ragdoll.
    function playerMeta:setRagdoll(entity)
        self.liaRagdoll = entity
    end

    --- Sets an action bar for the player.
    -- @string text The text to display on the action bar.
    -- @int[opt] time The duration for the action bar to display, defaults to 5 seconds. Set to 0 or nil to remove the action bar immediately.
    -- @func[opt] callback Function to execute when the action bar timer expires.
    -- @int[opt] startTime The start time of the action bar, defaults to the current time.
    -- @int[opt] finishTime The finish time of the action bar, defaults to startTime + time.
    -- @realm server
    function playerMeta:setAction(text, time, callback, startTime, finishTime)
        if time and time <= 0 then
            if callback then callback(self) end
            return
        end

        time = time or 5
        startTime = startTime or CurTime()
        finishTime = finishTime or (startTime + time)
        if text == false then
            timer.Remove("liaAct" .. self:SteamID64())
            netstream.Start(self, "actBar")
            return
        end

        netstream.Start(self, "actBar", startTime, finishTime, text)
        if callback then timer.Create("liaAct" .. self:SteamID64(), time, 1, function() if IsValid(self) then callback(self) end end) end
    end

    --- Stops the action bar for the player.
    -- Removes the action bar currently being displayed.
    -- @realm server
    function playerMeta:stopAction()
        timer.Remove("liaAct" .. self:SteamID64())
        netstream.Start(self, "actBar")
    end

    --- Retrieves the player's permanent flags.
    -- @realm server
    -- @treturn string The player's permanent flags.
    function playerMeta:getPermFlags()
        return self:getLiliaData("permflags", "")
    end

    --- Sets the player's permanent flags.
    -- @string flags The permanent flags to set.
    -- @realm server
    function playerMeta:setPermFlags(flags)
        self:setLiliaData("permflags", flags or "")
        self:saveLiliaData()
    end

    --- Grants permanent flags to the player.
    -- @tab flags The permanent flags to grant.
    -- @realm server
    function playerMeta:givePermFlags(flags)
        local curFlags = self:getPermFlags()
        for i = 1, #flags do
            local flag = flags[i]
            if not self:hasPermFlag(flag) and not self:hasFlagBlacklist(flag) then curFlags = curFlags .. flag end
        end

        self:setPermFlags(curFlags)
        if self.liaCharList then
            for _, v in pairs(self.liaCharList) do
                local character = lia.char.loaded[v]
                if character then char:giveFlags(flags) end
            end
        end
    end

    --- Revokes permanent flags from the player.
    -- @tab flags The permanent flags to revoke.
    -- @realm server
    function playerMeta:takePermFlags(flags)
        local curFlags = self:getPermFlags()
        for i = 1, #flags do
            curFlags = curFlags:gsub(flags[i], "")
        end

        self:setPermFlags(curFlags)
        if self.liaCharList then
            for _, v in pairs(self.liaCharList) do
                local character = lia.char.loaded[v]
                if character then char:takeFlags(flags) end
            end
        end
    end

    --- Checks if the player has a specific permanent flag.
    -- @string flag The permanent flag to check.
    -- @realm server
    -- @treturn bool Whether or not the player has the permanent flag.
    function playerMeta:hasPermFlag(flag)
        if not flag or #flag ~= 1 then return end
        local curFlags = self:getPermFlags()
        for i = 1, #curFlags do
            if curFlags[i] == flag then return true end
        end
        return false
    end

    --- Retrieves the player's flag blacklist.
    -- @realm server
    -- @treturn string The player's flag blacklist.
    function playerMeta:getFlagBlacklist()
        return self:getLiliaData("flagblacklist", "")
    end

    --- Sets the player's flag blacklist.
    -- @tab flags The flag blacklist to set.
    -- @realm server
    function playerMeta:setFlagBlacklist(flags)
        self:setLiliaData("flagblacklist", flags)
        self:saveLiliaData()
    end

    --- Adds flags to the player's flag blacklist.
    -- @tab flags The flags to add to the blacklist.
    -- @tab[opt] blacklistInfo Additional information about the blacklist entry.
    -- @realm server
    function playerMeta:addFlagBlacklist(flags, blacklistInfo)
        local curBlack = self:getFlagBlacklist()
        for i = 1, #flags do
            local curFlag = flags[i]
            if not self:hasFlagBlacklist(curFlag) then curBlack = curBlack .. flags[i] end
        end

        self:setFlagBlacklist(curBlack)
        self:takePermFlags(flags)
        if blacklistInfo then
            local blacklistLog = self:getLiliaData("flagblacklistlog", {})
            blacklistInfo.starttime = os.time()
            blacklistInfo.time = blacklistInfo.time or 0
            blacklistInfo.endtime = blacklistInfo.time <= 0 and 0 or (os.time() + blacklistInfo.time)
            blacklistInfo.admin = blacklistInfo.admin or "N/A"
            blacklistInfo.adminsteam = blacklistInfo.adminsteam or "N/A"
            blacklistInfo.active = true
            blacklistInfo.flags = blacklistInfo.flags or ""
            blacklistInfo.reason = blacklistInfo.reason or "N/A"
            table.insert(blacklistLog, blacklistInfo)
            self:setLiliaData("flagblacklistlog", blacklistLog)
            self:saveLiliaData()
        end
    end

    --- Removes flags from the player's flag blacklist.
    -- @realm server
    -- @tab flags A table containing the flags to remove from the blacklist.
    function playerMeta:removeFlagBlacklist(flags)
        local curBlack = self:getFlagBlacklist()
        for i = 1, #flags do
            local curFlag = flags[i]
            curBlack = curBlack:gsub(curFlag, "")
        end

        self:setFlagBlacklist(curBlack)
    end

    --- Checks if the player has a specific flag blacklisted.
    -- @realm server
    -- @string flag The flag to check for in the blacklist.
    -- @treturn bool Whether the player has the specified flag blacklisted.
    function playerMeta:hasFlagBlacklist(flag)
        local flags = self:getFlagBlacklist()
        for i = 1, #flags do
            if flags[i] == flag then return true end
        end
        return false
    end

    --- Checks if the player has any of the specified flags blacklisted.
    -- @realm server
    -- @tab flags A table containing the flags to check for in the blacklist.
    -- @treturn bool Whether the player has any of the specified flags blacklisted.
    function playerMeta:hasAnyFlagBlacklist(flags)
        for i = 1, #flags do
            if self:hasFlagBlacklist(flags[i]) then return true end
        end
        return false
    end

    --- Plays a sound for the player.
    -- @realm client
    -- @string sound The sound to play.
    -- @int[opt] pitch The pitch of the sound.
    function playerMeta:playSound(sound, pitch)
        net.Start("LiliaPlaySound")
        net.WriteString(tostring(sound))
        net.WriteUInt(tonumber(pitch) or 100, 7)
        net.Send(self)
    end

    --- Opens a VGUI panel for the player.
    -- @realm client
    -- @param panel The name of the VGUI panel to open.
    function playerMeta:openUI(panel)
        net.Start("OpenVGUI")
        net.WriteString(panel)
        net.Send(self)
    end

    playerMeta.OpenUI = playerMeta.openUI
    --- Opens a web page for the player.
    -- @realm client
    -- @string url The URL of the web page to open.
    function playerMeta:openPage(url)
        net.Start("OpenPage")
        net.WriteString(url)
        net.Send(self)
    end

    --- Retrieves the player's total playtime.
    -- @realm shared
    -- @treturn number The total playtime of the player.
    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(self.lastJoin)) - os.time(lia.util.dateToNumber(self.firstJoin))
        return diff + (RealTime() - (self.liaJoinTime or RealTime()))
    end

    playerMeta.GetPlayTime = playerMeta.getPlayTime
    --- Creates a ragdoll entity for the player on the server.
    -- @realm server
    -- @bool[opt] dontSetPlayer Determines whether to associate the player with the ragdoll.
    -- @treturn Entity The created ragdoll entity.
    function playerMeta:createServerRagdoll(dontSetPlayer)
        local entity = ents.Create("prop_ragdoll")
        entity:SetPos(self:GetPos())
        entity:SetAngles(self:EyeAngles())
        entity:SetModel(self:GetModel())
        entity:SetSkin(self:GetSkin())
        for _, v in ipairs(self:GetBodyGroups()) do
            entity:SetBodygroup(v.id, self:GetBodygroup(v.id))
        end

        entity:Spawn()
        if not dontSetPlayer then entity:SetNetVar("player", self) end
        entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        entity:Activate()
        hook.Run("OnCreatePlayerServerRagdoll", self)
        local velocity = self:GetVelocity()
        for i = 0, entity:GetPhysicsObjectCount() - 1 do
            local physObj = entity:GetPhysicsObjectNum(i)
            if IsValid(physObj) then
                physObj:SetVelocity(velocity)
                local index = entity:TranslatePhysBoneToBone(i)
                if index then
                    local position, angles = self:GetBonePosition(index)
                    physObj:SetPos(position)
                    physObj:SetAngles(angles)
                end
            end
        end
        return entity
    end

    --- Performs a stared action towards an entity for a certain duration.
    -- @realm server
    -- @entity entity The entity towards which the player performs the stared action.
    -- @func callback The function to call when the stared action is completed.
    -- @int[opt] time The duration of the stared action in seconds.
    -- @func[opt] onCancel The function to call if the stared action is canceled.
    -- @int[opt] distance The maximum distance for the stared action.
    function playerMeta:doStaredAction(entity, callback, time, onCancel, distance)
        local uniqueID = "liaStare" .. self:SteamID64()
        local data = {}
        data.filter = self
        timer.Create(uniqueID, 0.1, time / 0.1, function()
            if IsValid(self) and IsValid(entity) then
                data.start = self:GetShootPos()
                data.endpos = data.start + self:GetAimVector() * (distance or 96)
                local targetEntity = util.TraceLine(data).Entity
                if IsValid(targetEntity) and targetEntity:GetClass() == "prop_ragdoll" and IsValid(targetEntity:getNetVar("player")) then targetEntity = targetEntity:getNetVar("player") end
                if targetEntity ~= entity then
                    timer.Remove(uniqueID)
                    if onCancel then onCancel() end
                elseif callback and timer.RepsLeft(uniqueID) == 0 then
                    callback()
                end
            else
                timer.Remove(uniqueID)
                if onCancel then onCancel() end
            end
        end)
    end

    --- Notifies the player with a message.
    -- @realm shared
    -- @string message The message to notify the player.
    function playerMeta:notify(message)
        lia.util.notify(message, self)
    end

    --- Notifies the player with a localized message.
    -- @realm shared
    -- @string message The key of the localized message to notify the player.
    -- @tab ... Additional arguments to format the localized message.
    function playerMeta:notifyLocalized(message, ...)
        lia.util.notifyLocalized(message, self, ...)
    end

    --- Requests a string input from the player.
    -- @realm shared
    -- @string title The title of the string input dialog.
    -- @string subTitle The subtitle or description of the string input dialog.
    -- @func callback The function to call with the entered string.
    -- @param[opt] default The default value for the string input.
    -- @treturn Promise A promise object resolving with the entered string.
    function playerMeta:requestString(title, subTitle, callback, default)
        local d
        if not isfunction(callback) and default == nil then
            default = callback
            d = deferred.new()
            callback = function(value) d:resolve(value) end
        end

        self.liaStrReqs = self.liaStrReqs or {}
        local id = table.insert(self.liaStrReqs, callback)
        net.Start("liaStringReq")
        net.WriteUInt(id, 32)
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteString(default or "")
        net.Send(self)
        return d
    end

    --- Creates a ragdoll entity for the player.
    -- @realm server
    -- @bool freeze Whether to freeze the ragdoll initially.
    -- @treturn Entity The created ragdoll entity.
    function playerMeta:createRagdoll(freeze)
        local entity = ents.Create("prop_ragdoll")
        entity:SetPos(self:GetPos())
        entity:SetAngles(self:EyeAngles())
        entity:SetModel(self:GetModel())
        entity:SetSkin(self:GetSkin())
        entity:Spawn()
        entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        entity:Activate()
        local velocity = self:GetVelocity()
        for i = 0, entity:GetPhysicsObjectCount() - 1 do
            local physObj = entity:GetPhysicsObjectNum(i)
            if IsValid(physObj) then
                local index = entity:TranslatePhysBoneToBone(i)
                if index then
                    local position, angles = self:GetBonePosition(index)
                    physObj:SetPos(position)
                    physObj:SetAngles(angles)
                end

                if freeze then
                    physObj:EnableMotion(false)
                else
                    physObj:SetVelocity(velocity)
                end
            end
        end
        return entity
    end

    --- Sets the player to a ragdolled state or removes the ragdoll.
    -- @realm server
    -- @bool state Whether to set the player to a ragdolled state (`true`) or remove the ragdoll (`false`).
    -- @int[opt] time The duration for which the player remains ragdolled.
    -- @int[opt] getUpGrace The grace period for the player to get up before the ragdoll is removed.
    function playerMeta:setRagdolled(state, time, getUpGrace)
        getUpGrace = getUpGrace or time or 5
        local hasRagdoll = self:hasRagdoll()
        local ragdoll = self:getRagdoll()
        if state then
            if hasRagdoll then ragdoll:Remove() end
            local entity = self:createRagdoll()
            entity:setNetVar("player", self)
            entity:CallOnRemove("fixer", function()
                if IsValid(self) then
                    self:setLocalVar("blur", nil)
                    self:setLocalVar("ragdoll", nil)
                    if not entity.liaNoReset then self:SetPos(entity:GetPos()) end
                    self:SetNoDraw(false)
                    self:SetNotSolid(false)
                    self:Freeze(false)
                    self:SetMoveType(MOVETYPE_WALK)
                    self:SetLocalVelocity(IsValid(entity) and entity.liaLastVelocity or vector_origin)
                end

                if IsValid(self) and not entity.liaIgnoreDelete then
                    if entity.liaWeapons then
                        for _, v in ipairs(entity.liaWeapons) do
                            self:Give(v, true)
                            if entity.liaAmmo then
                                for k2, v2 in ipairs(entity.liaAmmo) do
                                    if v == v2[1] then self:SetAmmo(v2[2], tostring(k2)) end
                                end
                            end
                        end

                        for _, v in ipairs(self:GetWeapons()) do
                            v:SetClip1(0)
                        end
                    end

                    if self:isStuck() then
                        entity:DropToFloor()
                        self:SetPos(entity:GetPos() + Vector(0, 0, 16))
                        local positions = lia.util.findEmptySpace(self, {entity, self})
                        for _, v in ipairs(positions) do
                            self:SetPos(v)
                            if not self:isStuck() then return end
                        end
                    end
                end
            end)

            self:setLocalVar("blur", 25)
            self:setRagdoll(entity)
            entity.liaWeapons = {}
            entity.liaAmmo = {}
            entity.liaPlayer = self
            if getUpGrace then entity.liaGrace = CurTime() + getUpGrace end
            if time and time > 0 then
                entity.liaStart = CurTime()
                entity.liaFinish = entity.liaStart + time
                self:setAction("@wakingUp", nil, nil, entity.liaStart, entity.liaFinish)
            end

            for _, v in ipairs(self:GetWeapons()) do
                entity.liaWeapons[#entity.liaWeapons + 1] = v:GetClass()
                local clip = v:Clip1()
                local reserve = self:GetAmmoCount(v:GetPrimaryAmmoType())
                local ammo = clip + reserve
                entity.liaAmmo[v:GetPrimaryAmmoType()] = {v:GetClass(), ammo}
            end

            self:GodDisable()
            self:StripWeapons()
            self:Freeze(true)
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            self:SetMoveType(MOVETYPE_NONE)
            if time then
                local uniqueID = "liaUnRagdoll" .. self:SteamID()
                timer.Create(uniqueID, 0.33, 0, function()
                    if IsValid(entity) and IsValid(self) then
                        local velocity = entity:GetVelocity()
                        entity.liaLastVelocity = velocity
                        self:SetPos(entity:GetPos())
                        if velocity:Length2D() >= 8 then
                            if not entity.liaPausing then
                                self:stopAction()
                                entity.liaPausing = true
                            end
                            return
                        elseif entity.liaPausing then
                            self:setAction("@wakingUp", time)
                            entity.liaPausing = false
                        end

                        time = time - 0.33
                        if time <= 0 then entity:Remove() end
                    else
                        timer.Remove(uniqueID)
                    end
                end)
            end

            self:setLocalVar("ragdoll", entity:EntIndex())
            hook.Run("OnCharFallover", self, entity, true)
        elseif hasRagdoll then
            self.liaRagdoll:Remove()
            hook.Run("OnCharFallover", self, nil, false)
        end
    end

    --- Sets whether the player is whitelisted for a faction.
    -- @realm server
    -- @int faction The faction ID.
    -- @bool whitelisted Whether the player should be whitelisted for the faction.
    -- @treturn bool Whether the operation was successful.
    function playerMeta:setWhitelisted(faction, whitelisted)
        if not whitelisted then whitelisted = nil end
        local data = lia.faction.indices[faction]
        if data then
            local whitelists = self:getLiliaData("whitelists", {})
            whitelists[SCHEMA.folder] = whitelists[SCHEMA.folder] or {}
            whitelists[SCHEMA.folder][data.uniqueID] = whitelisted and true or nil
            self:setLiliaData("whitelists", whitelists)
            self:saveLiliaData()
            return true
        end
        return false
    end

    --- Synchronizes networked variables with the player.
    -- @internal
    -- @realm server
    function playerMeta:syncVars()
        for entity, data in pairs(lia.net) do
            if entity == "globals" then
                for k, v in pairs(data) do
                    netstream.Start(self, "gVar", k, v)
                end
            elseif IsValid(entity) then
                for k, v in pairs(data) do
                    netstream.Start(self, "nVar", entity:EntIndex(), k, v)
                end
            end
        end
    end

    --- Sets a local variable for the player.
    -- @realm server
    -- @string key The key of the variable.
    -- @param value The value of the variable.
    function playerMeta:setLocalVar(key, value)
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        lia.net[self][key] = value
        netstream.Start(self, "nLcl", key, value)
    end

    playerMeta.SetLocalVar = playerMeta.setLocalVar
    --- Notifies the player with a message and prints the message to their chat.
    -- @realm server
    -- @string text The message to notify and print.
    function playerMeta:notifyP(text)
        self:notify(text)
        self:chatNotify(text)
    end

    --- Sends a message to the player.
    -- @realm server
    -- @tab ... The message(s) to send.
    function playerMeta:sendMessage(...)
        net.Start("SendMessage")
        net.WriteTable({...} or {})
        net.Send(self)
    end

    --- Sends a message to the player to be printed.
    -- @realm server
    -- @tab ... The message(s) to print.
    function playerMeta:sendPrint(...)
        net.Start("SendPrint")
        net.WriteTable({...} or {})
        net.Send(self)
    end

    --- Sends a table to the player to be printed.
    -- @realm server
    -- @tab ... The table(s) to print.
    function playerMeta:sendPrintTable(...)
        net.Start("SendPrintTable")
        net.WriteTable({...} or {})
        net.Send(self)
    end
else
    --- Displays a notification for this player in the chatbox.
    -- @realm client
    -- @string message Text to display in the notification
    function playerMeta:chatNotify(message)
        if self == LocalPlayer() then chat.AddText(Color(175, 200, 255), message) end
    end

    --- Displays a notification for this player in the chatbox with the given language phrase.
    -- @realm client
    -- @string message ID of the phrase to display to the player
    -- @param ... Arguments to pass to the phrase
    function playerMeta:chatNotifyLocalized(message, ...)
        if self == LocalPlayer() then
            message = L(message, ...)
            chat.AddText(Color(175, 200, 255), message)
        end
    end

    --- Retrieves the player's total playtime.
    -- @realm client
    -- @treturn number The total playtime of the player.
    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(lia.lastJoin)) - os.time(lia.util.dateToNumber(lia.firstJoin))
        return diff + (RealTime() - lia.joinTime or 0)
    end

    playerMeta.GetPlayTime = playerMeta.getPlayTime
    --- Opens a UI panel for the player.
    -- @param panel The panel type to create.
    -- @realm client
    -- @treturn Panel The created UI panel.
    function playerMeta:openUI(panel)
        return vgui.Create(panel)
    end

    playerMeta.OpenUI = playerMeta.openUI
    --- Sets a waypoint for the player.
    -- @string name The name of the waypoint.
    -- @vector vector The position vector of the waypoint.
    -- @func onReach[opt=nil] Function to call when the player reaches the waypoint.
    -- @realm client
    function playerMeta:setWeighPoint(name, vector, onReach)
        hook.Add("HUDPaint", "WeighPoint", function()
            local dist = self:GetPos():Distance(vector)
            local spos = vector:ToScreen()
            local howclose = math.Round(math.floor(dist) / 40)
            if not spos then return end
            render.SuppressEngineLighting(true)
            surface.SetFont("WB_Large")
            draw.DrawText(name .. "\n" .. howclose .. " Meters\n", "CenterPrintText", spos.x, spos.y, Color(123, 57, 209), TEXT_ALIGN_CENTER)
            render.SuppressEngineLighting(false)
            if howclose <= 3 then RunConsoleCommand("weighpoint_stop") end
        end)

        concommand.Add("weighpoint_stop", function()
            hook.Add("HUDPaint", "WeighPoint", function() end)
            if IsValid(onReach) then onReach() end
        end)
    end

    --- Retrieves a value from the local Lilia data.
    -- @string key The key for the data.
    -- @param[opt] default The default value to return if the key does not exist.
    -- @realm client
    -- @treturn any The value corresponding to the key, or the default value if the key does not exist.
    function playerMeta:getLiliaData(key, default)
        local data = lia.localData and lia.localData[key]
        if data == nil then
            return default
        else
            return data
        end
    end
end

playerMeta.IsUser = playerMeta.isUser
playerMeta.IsStaff = playerMeta.isStaff
playerMeta.IsVIP = playerMeta.isVIP
playerMeta.ChatNotify = playerMeta.chatNotify
playerMeta.ChatNotifyLocalized = playerMeta.chatNotifyLocalized
playerMeta.IsStaffOnDuty = playerMeta.isStaffOnDuty
playerMeta.IsObserving = playerMeta.isObserving
playerMeta.IsOutside = playerMeta.isOutside
playerMeta.IsNoClipping = playerMeta.isNoClipping
playerMeta.SquaredDistanceFromEnt = playerMeta.squaredDistanceFromEnt
playerMeta.DistanceFromEnt = playerMeta.distanceFromEnt
playerMeta.IsNearPlayer = playerMeta.isNearPlayer
playerMeta.EntitiesNearPlayer = playerMeta.entitiesNearPlayer
playerMeta.GetItemWeapon = playerMeta.getItemWeapon
playerMeta.AddMoney = playerMeta.addMoney
playerMeta.TakeMoney = playerMeta.takeMoney
playerMeta.GetMoney = playerMeta.getMoney
playerMeta.CanAfford = playerMeta.canAfford
playerMeta.IsRunning = playerMeta.isRunning
playerMeta.IsFemale = playerMeta.isFemale
playerMeta.GetItemDropPos = playerMeta.getItemDropPos
playerMeta.HasWhitelist = playerMeta.hasWhitelist
playerMeta.HasClassWhitelist = playerMeta.hasClassWhitelist
playerMeta.ClassWhitelist = playerMeta.classWhitelist
playerMeta.ClassUnWhitelist = playerMeta.classUnWhitelist
playerMeta.GetTracedEntity = playerMeta.getTracedEntity
playerMeta.GetTrace = playerMeta.getTrace
playerMeta.GetClassData = playerMeta.getClassData
playerMeta.HasSkillLevel = playerMeta.hasSkillLevel
playerMeta.MeetsRequiredSkills = playerMeta.meetsRequiredSkills
playerMeta.GetEyeEnt = playerMeta.getEyeEnt
playerMeta.SetAction = playerMeta.setAction
playerMeta.StopAction = playerMeta.stopAction
playerMeta.GetPermFlags = playerMeta.getPermFlags
playerMeta.SetPermFlags = playerMeta.setPermFlags
playerMeta.GivePermFlags = playerMeta.givePermFlags
playerMeta.TakePermFlags = playerMeta.takePermFlags
playerMeta.HasPermFlag = playerMeta.hasPermFlag
playerMeta.GetFlagBlacklist = playerMeta.getFlagBlacklist
playerMeta.SetFlagBlacklist = playerMeta.setFlagBlacklist
playerMeta.AddFlagBlacklist = playerMeta.addFlagBlacklist
playerMeta.RemoveFlagBlacklist = playerMeta.removeFlagBlacklist
playerMeta.HasFlagBlacklist = playerMeta.hasFlagBlacklist
playerMeta.HasAnyFlagBlacklist = playerMeta.hasAnyFlagBlacklist
playerMeta.PlaySound = playerMeta.playSound
playerMeta.OpenPage = playerMeta.openPage
playerMeta.CreateServerRagdoll = playerMeta.createServerRagdoll
playerMeta.DoStaredAction = playerMeta.doStaredAction
playerMeta.Notify = playerMeta.notify
playerMeta.NotifyLocalized = playerMeta.notifyLocalized
playerMeta.SetRagdolled = playerMeta.setRagdolled
playerMeta.SetWhitelisted = playerMeta.setWhitelisted
playerMeta.SyncVars = playerMeta.syncVars
playerMeta.NotifyP = playerMeta.notifyP
playerMeta.SendMessage = playerMeta.sendMessage
playerMeta.SendPrint = playerMeta.sendPrint
playerMeta.SendPrintTable = playerMeta.sendPrintTable
playerMeta.SetWeighPoint = playerMeta.setWeighPoint
