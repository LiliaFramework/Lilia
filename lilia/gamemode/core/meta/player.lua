--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @playermeta Framework
local playerMeta = FindMetaTable("Player")
local vectorMeta = FindMetaTable("Vector")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    --- Returns this player's currently possessed `Character` object if it exists.
    -- @realm shared
    -- @treturn[1] Character Currently loaded character
    -- @treturn[2] nil If this player has no character loaded
    -- @usage
    -- local char = player:getChar()
    -- if char then
    --     print("Character Name:", char:getName())
    -- end
    function playerMeta:getChar()
        return lia.char.loaded[self.getNetVar(self, "char")]
    end

    --- Returns this player's current name.
    -- @realm shared
    -- @treturn String Name of this player's currently loaded character
    -- @treturn String Steam name of this player if the player has no character loaded
    -- @usage
    -- print("Player Name:", player:Name())
    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.GetCharacter = playerMeta.getChar
    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

--- Checks if the player has a specified CAMI privilege.
-- @realm shared
-- @string privilegeName The name of the privilege to check.
-- @treturn Boolean True if the player has the privilege, false otherwise.
-- @usage
-- if player:HasPrivilege("admin") then
--     print("Player is an admin.")
-- end
function playerMeta:HasPrivilege(privilegeName)
    return CAMI.PlayerHasAccess(self, privilegeName, nil)
end

--- Gets the current vehicle the player is in, if any.
-- @realm shared
-- @treturn Entity|nil The current vehicle entity, or nil if the player is not in a vehicle.
-- @usage
-- local vehicle = player:getCurrentVehicle()
-- if vehicle then
--     print("Player is in a vehicle:", vehicle:GetClass())
-- end
function playerMeta:getCurrentVehicle()
    local vehicle = self:GetVehicle()
    if vehicle and IsValid(vehicle) then return vehicle end
    if LVS then
        vehicle = self:lvsGetVehicle()
        if vehicle and IsValid(vehicle) then return vehicle end
    end
    return nil
end

--- Checks if the player is in a valid vehicle.
-- @realm shared
-- @treturn Boolean True if the player is in a valid vehicle, false otherwise.
-- @usage
-- if player:hasValidVehicle() then
--     print("Player is in a valid vehicle.")
-- end
function playerMeta:hasValidVehicle()
    return IsValid(self:getCurrentVehicle())
end

--- Checks if the player is currently observing.
-- @realm shared
-- @treturn Boolean Whether the player is currently observing.
-- @usage
-- if player:isObserving() then
--     print("Player is observing.")
-- end
function playerMeta:isObserving()
    return self:GetMoveType() == MOVETYPE_NOCLIP and not self:hasValidVehicle()
end

--- Checks if the player is currently moving.
-- @realm shared
-- @treturn Boolean Whether the player is currently moving.
-- @usage
-- if player:isMoving() then
--     print("Player is moving.")
-- end
function playerMeta:isMoving()
    if not IsValid(self) or not self:Alive() then return false end
    local keydown = self:KeyDown(IN_FORWARD) or self:KeyDown(IN_BACK) or self:KeyDown(IN_MOVELEFT) or self:KeyDown(IN_MOVERIGHT)
    return keydown and self:OnGround()
end

--- Checks if the player is currently outside (in the sky).
-- @realm shared
-- @treturn Boolean Whether the player is currently outside (in the sky).
-- @usage
-- if player:isOutside() then
--     print("Player is outside.")
-- end
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
-- @treturn Boolean Whether the player is in noclip mode.
-- @usage
-- if player:isNoClipping() then
--     print("Player is in noclip mode.")
-- end
function playerMeta:isNoClipping()
    return self:GetMoveType() == MOVETYPE_NOCLIP
end

--- Retrieves the player's DarkRP money.
-- This is used as compatibility for DarkRP Vars.
-- @realm shared
-- @string var The DarkRP variable to fetch (only "money" is allowed).
-- @treturn Integer|nil The player's money if the variable is valid, or nil if not.
-- @usage
-- local money = player:getDarkRPVar("money")
-- if money then
--     print("Player Money:", money)
-- end
function playerMeta:getDarkRPVar(var)
    local char = self:getChar()
    if var ~= "money" then
        self:ChatPrint("Invalid variable requested! Only 'money' can be fetched. Please refer to our Discord for help.")
        return nil
    end

    if char and char.getMoney then return char:getMoney() end
end

--- Checks if the player has a valid ragdoll entity.
-- @realm shared
-- @treturn Boolean Whether the player has a valid ragdoll entity.
-- @usage
-- if player:hasRagdoll() then
--     print("Player has a ragdoll.")
-- end
function playerMeta:hasRagdoll()
    return IsValid(self.liaRagdoll)
end

--- Returns the player's ragdoll entity if valid.
-- @realm shared
-- @treturn Entity|nil The player's ragdoll entity if it exists and is valid, otherwise nil.
-- @usage
-- local ragdoll = player:getRagdoll()
-- if ragdoll then
--     print("Ragdoll found:", ragdoll:GetClass())
-- end
function playerMeta:getRagdoll()
    if not self:hasRagdoll() then return end
    return self.liaRagdoll
end

--- Checks if the player is stuck.
-- @realm shared
-- @treturn Boolean Whether the player is stuck.
-- @usage
-- if player:isStuck() then
--     print("Player is stuck.")
-- end
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
-- @treturn Float The squared distance from the player to the entity.
-- @usage
-- local sqDist = player:squaredDistanceFromEnt(entity)
-- print("Squared Distance:", sqDist)
function playerMeta:squaredDistanceFromEnt(entity)
    return self:GetPos():DistToSqr(entity:GetPos())
end

--- Calculates the distance from the player to the specified entity.
-- @realm shared
-- @entity entity The entity to calculate the distance to.
-- @treturn Float The distance from the player to the entity.
-- @usage
-- local dist = player:distanceFromEnt(entity)
-- print("Distance:", dist)
function playerMeta:distanceFromEnt(entity)
    return self:GetPos():Distance(entity:GetPos())
end

--- Checks if the player is near another entity within a specified radius.
-- @realm shared
-- @int radius The radius within which to check for proximity.
-- @entity entity The entity to check proximity to.
-- @treturn Boolean Whether the player is near the specified entity within the given radius.
-- @usage
-- if player:isNearPlayer(100, targetPlayer) then
--     print("Player is near the target.")
-- end
function playerMeta:isNearPlayer(radius, entity)
    local squaredRadius = radius * radius
    local squaredDistance = self:GetPos():DistToSqr(entity:GetPos())
    return squaredDistance <= squaredRadius
end

--- Retrieves entities near the player within a specified radius.
-- @realm shared
-- @int radius The radius within which to search for entities.
-- @bool playerOnly If true, only return player entities.
-- @treturn Table A table containing the entities near the player.
-- @usage
-- local nearbyPlayers = player:entitiesNearPlayer(200, true)
-- for _, p in ipairs(nearbyPlayers) do
--     print("Nearby Player:", p:Nick())
-- end
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
-- @usage
-- local weapon, item = player:getItemWeapon()
-- if weapon then
--     print("Active Weapon:", weapon:GetClass())
-- end
function playerMeta:getItemWeapon()
    local character = self:getChar()
    local inv = character:getInv()
    local items = inv:getItems()
    local weapon = self:GetActiveWeapon()
    if not IsValid(weapon) then return nil end
    for _, v in pairs(items) do
        if v.class then
            if v.class == weapon:GetClass() and v:getData("equip", false) then
                return weapon, v
            else
                return nil
            end
        end
    end
end

--- Checks if the player's character can afford a specified amount of money.
-- This function uses Lilia methods to determine if the player can afford the specified amount.
-- It is designed to be compatible with the DarkRP `canAfford` method.
-- @realm shared
-- @int amount The amount of money to check.
-- @treturn Boolean Whether the player's character can afford the specified amount of money.
-- @usage
-- if player:canAfford(500) then
--     print("Player can afford the item.")
-- else
--     print("Player cannot afford the item.")
-- end
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--- Adds money to the player's character.
-- This function uses Lilia methods to add the specified amount of money to the player.
-- It is designed to be compatible with the DarkRP `addMoney` method.
-- If the total amount exceeds the configured money limit, the excess is spawned as an item in the world.
-- @realm shared
-- @int amount The amount of money to add.
-- @usage
-- player:addMoney(1000, {player}, false)
function playerMeta:addMoney(amount)
    local character = self:getChar()
    if not character then return end
    local currentMoney = character:getMoney()
    local maxMoneyLimit = lia.config.MoneyLimit or 0
    local limitOverride = hook.Run("WalletLimit", self)
    if limitOverride then maxMoneyLimit = limitOverride end
    if maxMoneyLimit > 0 then
        local totalMoney = currentMoney + amount
        if totalMoney > maxMoneyLimit then
            local excessMoney = totalMoney - maxMoneyLimit
            character:giveMoney(maxMoneyLimit - currentMoney, false)
            local money = lia.currency.spawn(self:getItemDropPos(), excessMoney)
            money.client = self
            money.charID = character:getID()
        else
            character:giveMoney(amount, false)
        end
    else
        character:giveMoney(amount, false)
    end
end

--- Takes money from the player's character.
-- @realm shared
-- @int amount The amount of money to take.
-- @usage
-- player:takeMoney(200)
function playerMeta:takeMoney(amount)
    local character = self:getChar()
    if character then character:giveMoney(-amount) end
end

--- Retrieves the amount of money owned by the player's character.
-- @realm shared
-- @treturn Integer The amount of money owned by the player's character.
-- @usage
-- local money = player:getMoney()
-- print("Player Money:", money)
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--- Checks if the player is running.
-- @realm shared
-- @treturn Boolean Whether the player is running.
-- @usage
-- if player:isRunning() then
--     print("Player is running.")
-- end
function playerMeta:isRunning()
    return vectorMeta.Length2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
end

--- Checks if the player's character is female based on the model.
-- @realm shared
-- @treturn Boolean Whether the player's character is female.
-- @usage
-- if player:isFemale() then
--     print("Player character is female.")
-- end
function playerMeta:isFemale()
    local model = self:GetModel():lower()
    return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
end

--- Calculates the position to drop an item from the player's inventory.
-- @realm shared
-- @treturn Vector The position to drop an item from the player's inventory.
-- @usage
-- local dropPos = player:getItemDropPos()
-- item:spawn(dropPos, Angle(0, 0, 0))
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

--- Retrieves the items of the player's character inventory.
-- @realm shared
-- @treturn Table|nil A table containing the items in the player's character inventory, or nil if not found.
-- @usage
-- local items = player:getItems()
-- if items then
--     for _, item in ipairs(items) do
--         print("Item:", item.uniqueID)
--     end
-- end
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

--- Retrieves the entity traced by the player's aim.
-- @realm shared
-- @treturn Entity|nil The entity traced by the player's aim, or nil if not found.
-- @usage
-- local target = player:getTracedEntity()
-- if target then
--     print("Traced Entity:", target:GetClass())
-- end
function playerMeta:getTracedEntity()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * 96
    data.filter = self
    local targetEntity = util.TraceLine(data).Entity
    return targetEntity
end

--- Performs a trace from the player's view.
-- @realm shared
-- @treturn Table A table containing the trace result.
-- @usage
-- local trace = player:getTrace()
-- if trace.Hit then
--     print("Trace hit:", trace.Entity:GetClass())
-- end
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

--- Retrieves the entity within the player's line of sight.
-- @realm shared
-- @int distance The maximum distance to consider.
-- @treturn Entity|nil The entity within the player's line of sight, or nil if not found.
-- @usage
-- local eyeEnt = player:getEyeEnt(200)
-- if eyeEnt then
--     print("Entity in sight:", eyeEnt:GetClass())
-- end
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

if SERVER then
    --- Loads Lilia data for the player from the database.
    -- @realm server
    -- @func callback Function to call after the data is loaded, passing the loaded data as an argument.
    -- @usage
    -- player:loadLiliaData(function(data)
    --     print("Data loaded:", data)
    -- end)
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
    -- @usage
    -- player:saveLiliaData()
    function playerMeta:saveLiliaData()
        if self:IsBot() then return end
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
    -- This method updates the player's `liaData` table with the specified key and value. Optionally, it can suppress the networking of the data update.
    -- @realm server
    -- @tparam String key The key for the data.
    -- @tparam any[opt=nil] value The value to set for the specified key. Defaults to `nil` if not provided.
    -- @tparam Boolean[opt=false] noNetworking If set to `true`, the data update will not be sent to clients. Defaults to `false`.
    -- @treturn void
    -- @usage
    -- ```lua
    -- Example 1: Setting a key-value pair with networking
    -- player:setLiliaData("score", 1500)
    -- Example 2: Setting a key-value pair without networking
    -- player:setLiliaData("health", 100, true)
    -- ```
    function playerMeta:setLiliaData(key, value, noNetworking)
        self.liaData = self.liaData or {}
        self.liaData[key] = value
        if not noNetworking then netstream.Start(self, "liaData", key, value) end
    end

    --- Notifies the player with a message.
    -- @realm server
    -- @string message The message to notify the player.
    -- @usage
    -- player:chatNotify("Welcome to the server!")
    function playerMeta:chatNotify(message)
        net.Start("chatNotify")
        net.WriteString(message)
        net.Send(self)
    end

    --- Notifies the player with a localized message.
    -- @realm server
    -- @string message ID of the phrase to display to the player.
    -- @tparam ... any Arguments to pass to the phrase.
    -- @usage
    -- player:chatNotifyLocalized("welcome_message", player:Nick())
    function playerMeta:chatNotifyLocalized(message, ...)
        message = L(message, self, ...)
        net.Start("chatNotify")
        net.WriteString(message)
        net.Send(self)
    end

    --- Retrieves a value from the player's Lilia data.
    -- @realm server
    -- @string key The key for the data.
    -- @tparam any[opt=nil] default The default value to return if the key does not exist.
    -- @treturn any The value corresponding to the key, or the default value if the key does not exist.
    -- @usage
    -- local level = player:getLiliaData("level", 1)
    -- print("Player Level:", level)
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
    -- @realm server
    -- @entity entity The entity to set as the player's ragdoll.
    -- @usage
    -- local ragdoll = player:createServerRagdoll()
    -- player:setRagdoll(ragdoll)
    function playerMeta:setRagdoll(entity)
        self.liaRagdoll = entity
    end

    --- Sets an action bar for the player.
    -- @realm server
    -- @string text The text to display on the action bar.
    -- @int[opt=5] time The duration for the action bar to display in seconds. Set to 0 or nil to remove the action bar immediately.
    -- @func callback Function to execute when the action bar timer expires.
    -- @int[opt] startTime The start time of the action bar, defaults to the current time.
    -- @int[opt] finishTime The finish time of the action bar, defaults to startTime + time.
    -- @usage
    -- player:setAction("Processing...", 10, function(p) print("Action completed for", p:Nick()) end)
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
    -- @usage
    -- player:stopAction()
    function playerMeta:stopAction()
        timer.Remove("liaAct" .. self:SteamID64())
        netstream.Start(self, "actBar")
    end

    --- Plays a sound for the player.
    -- @realm server
    -- @string sound The sound to play.
    -- @int[opt=75] volume The volume of the sound.
    -- @int[opt=100] pitch The pitch of the sound.
    -- @bool shouldEmit Whether to emit sound server-side or send it to the client.
    -- @usage
    -- player:PlaySound("ambient/alarms/warningbell1.wav", 100, 100, false)
    function playerMeta:PlaySound(sound, volume, pitch, shouldEmit)
        volume = volume or 75
        pitch = pitch or 100
        if shouldEmit then
            self:EmitSound(sound, volume, pitch)
        else
            net.Start("PlaySound")
            net.WriteString(sound)
            net.WriteUInt(volume, 8)
            net.WriteUInt(pitch, 8)
            net.Send(self)
        end
    end

    --- Opens a VGUI panel for the player.
    -- @realm server
    -- @string panel The name of the VGUI panel to open.
    -- @usage
    -- player:openUI("InventoryPanel")
    function playerMeta:openUI(panel)
        net.Start("OpenVGUI")
        net.WriteString(panel)
        net.Send(self)
    end

    playerMeta.OpenUI = playerMeta.openUI
    --- Opens a web page for the player.
    -- @realm server
    -- @string url The URL of the web page to open.
    -- @usage
    -- player:openPage("https://example.com")
    function playerMeta:openPage(url)
        net.Start("OpenPage")
        net.WriteString(url)
        net.Send(self)
    end

    --- Requests a dropdown selection from the player.
    -- @realm shared
    -- @string title The title of the request.
    -- @string subTitle The subtitle of the request.
    -- @tab options The table of options to choose from.
    -- @func callback The function to call upon receiving the selected option.
    -- @usage
    -- player:requestDropdown("Choose Option", "Select one of the following:", {"Option1", "Option2"}, function(selected)
    --     print("Player selected:", selected)
    -- end)
    function playerMeta:requestDropdown(title, subTitle, options, callback)
        net.Start("DropdownRequest")
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options)
        net.Send(self)
        self.dropdownCallback = callback
    end

    --- Requests multiple options selection from the player.
    -- @realm server
    -- @string title The title of the request.
    -- @string subTitle The subtitle of the request.
    -- @tab options The table of options to choose from.
    -- @int limit The maximum number of selectable options.
    -- @func callback The function to call upon receiving the selected options.
    -- @usage
    -- player:requestOptions("Select Items", "Choose up to 3 items:", {"Item1", "Item2", "Item3"}, 3, function(selected)
    --     print("Player selected:", table.concat(selected, ", "))
    -- end)
    function playerMeta:requestOptions(title, subTitle, options, limit, callback)
        net.Start("OptionsRequest")
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options)
        net.WriteUInt(limit, 32)
        net.Send(self)
        self.optionsCallback = callback
    end

    --- Requests a string input from the player.
    -- @realm shared
    -- @string title The title of the string input dialog.
    -- @string subTitle The subtitle or description of the string input dialog.
    -- @func callback The function to call with the entered string.
    -- @string[opt=nil] default The default value for the string input.
    -- @treturn Promise|nil A promise object resolving with the entered string, or nil if a callback is provided.
    -- @usage
    -- player:requestString("Enter Name", "Please enter your name:", function(name)
    --     print("Player entered:", name)
    -- end)
    -- Using promise
    -- local promise = player:requestString("Enter Name", "Please enter your name:", "DefaultName")
    -- if promise then
    --     promise:next(function(name)
    --         print("Player entered:", name)
    --     end)
    -- end
    function playerMeta:requestString(title, subTitle, callback, default)
        local d
        if not isfunction(callback) and default == nil then
            default = callback
            d = deferred.new()
            callback = function(value) d:resolve(value) end
        end

        self.liaStrReqs = self.liaStrReqs or {}
        local id = table.insert(self.liaStrReqs, callback)
        net.Start("StringRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteString(default or "")
        net.Send(self)
        return d
    end

    --- Requests a binary choice from the player.
    -- @realm server
    -- @string question The question to present to the player.
    -- @string option1 The text for the first option.
    -- @string option2 The text for the second option.
    -- @bool manualDismiss Whether the notice should be manually dismissed.
    -- @func callback The function to call with the choice (0 or 1) when the player selects an option.
    -- @usage
    -- player:binaryQuestion("Confirm Action", "Are you sure you want to proceed?", "Yes", "No", false, function(choice)
    --     if choice == 1 then
    --         print("Player chose Yes.")
    --     else
    --         print("Player chose No.")
    --     end
    -- end)
    function playerMeta:binaryQuestion(question, option1, option2, manualDismiss, callback)
        net.Start("BinaryQuestionRequest")
        net.WriteString(question)
        net.WriteString(option1)
        net.WriteString(option2)
        net.WriteBool(manualDismiss)
        net.Send(self)
        self.binaryQuestionCallback = callback
    end

    --- Retrieves the player's total playtime.
    -- @realm server
    -- @treturn Float The total playtime of the player.
    -- @usage
    -- local playTime = player:getPlayTime()
    -- print("Playtime:", playTime, "seconds")
    function playerMeta:getPlayTime()
        local diff = os.time(lia.date.toNumber(self.lastJoin)) - os.time(lia.date.toNumber(self.firstJoin))
        return diff + (RealTime() - (self.liaJoinTime or RealTime()))
    end

    playerMeta.GetPlayTime = playerMeta.getPlayTime
    --- Creates a ragdoll entity for the player on the server.
    -- @realm server
    -- @bool dontSetPlayer Determines whether to associate the player with the ragdoll.
    -- @treturn Entity The created ragdoll entity.
    -- @usage
    -- local ragdoll = player:createServerRagdoll()
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
    -- @int[opt=5] time The duration of the stared action in seconds.
    -- @func onCancel The function to call if the stared action is canceled.
    -- @int[opt=96] distance The maximum distance for the stared action.
    -- @usage
    -- player:doStaredAction(targetEntity, function()
    --     print("Stared action completed.")
    -- end, 10, function()
    --     print("Stared action canceled.")
    -- end, 150)
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

    --- Notifies the player with a message and prints the message to their chat.
    -- @realm server
    -- @string message The message to notify and print.
    -- @usage
    -- player:notifyP("You have received a new item!")
    function playerMeta:notifyP(message)
        self:notify(message)
        self:chatNotify(message)
    end

    --- Notifies the player with a message.
    -- @realm server
    -- @string message The message to notify the player.
    function playerMeta:notify(message)
        lia.notices.notify(message, self)
    end

    --- Notifies the player with a localized message.
    -- @realm server
    -- @string message The key of the localized message to notify the player.
    -- @tab ... Additional arguments to format the localized message.
    function playerMeta:notifyLocalized(message, ...)
        lia.notices.notifyLocalized(message, self, ...)
    end

    --- Sets a waypoint for the player.
    -- @realm server
    -- @string name The name of the waypoint.
    -- @tparam Vector vector The position vector of the waypoint.
    -- @func onReach Function to call when the player reaches the waypoint.
    -- @usage
    -- player:setWeighPoint("Spawn Point", Vector(100, 200, 300), function(p)
    --     print("Player reached the waypoint.")
    -- end)
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
            hook.Remove("HUDPaint", "WeighPoint")
            if IsValid(onReach) then onReach() end
        end)
    end

    --- Retrieves the player's total playtime.
    -- @realm client
    -- @treturn Float The total playtime of the player.
    -- @usage
    -- local playTime = player:getPlayTime()
    -- print("Playtime:", playTime, "seconds")
    function playerMeta:getPlayTime()
        local diff = os.time(lia.date.toNumber(lia.lastJoin)) - os.time(lia.date.toNumber(lia.firstJoin))
        return diff + (RealTime() - (lia.joinTime or 0))
    end

    playerMeta.GetPlayTime = playerMeta.getPlayTime
    --- Creates a ragdoll entity for the player.
    -- @realm server
    -- @bool freeze Whether to freeze the ragdoll initially.
    -- @treturn Entity The created ragdoll entity.
    -- @usage
    -- local ragdoll = player:createRagdoll(true)
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
    -- @int[opt=0] time The duration for which the player remains ragdolled.
    -- @int[opt=0] getUpGrace The grace period for the player to get up before the ragdoll is removed.
    -- @string[opt="@wakingUp"] getUpMessage The message displayed when the player is getting up.
    -- @usage
    -- player:setRagdolled(true, 10, 5, "@gettingUp")
    function playerMeta:setRagdolled(state, time, getUpGrace, getUpMessage)
        getUpMessage = getUpMessage or "@wakingUp"
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
                self:setAction(getUpMessage, nil, nil, entity.liaStart, entity.liaFinish)
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
                            self:setAction(getUpMessage, time)
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
            if IsValid(entity) then
                entity:SetCollisionGroup(COLLISION_GROUP_NONE)
                entity:SetCustomCollisionCheck(false)
            end

            hook.Run("OnCharFallover", self, entity, true)
        elseif hasRagdoll then
            self.liaRagdoll:Remove()
            hook.Run("OnCharFallover", self, nil, false)
        end
    end

    --- Synchronizes networked variables with the player.
    -- @realm server
    -- @usage
    -- player:syncVars()
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
    -- @tparam any value The value of the variable.
    -- @usage
    -- player:setLocalVar("health", 100)
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
    -- @usage
    -- player:notifyP("You have received a new item!")
    function playerMeta:notifyP(text)
        self:notify(text)
        self:chatNotify(text)
    end
else
    --- Displays a notification for this player in the chatbox.
    -- @realm client
    -- @string message Text to display in the notification.
    -- @usage
    -- player:chatNotify("Welcome to the server!")
    function playerMeta:chatNotify(message)
        local client = LocalPlayer()
        if self == client then chat.AddText(Color(255, 215, 0), message) end
    end

    --- Displays a notification for the player in the chatbox with the given language phrase.
    -- @realm client
    -- @string message ID of the phrase to display to the player.
    -- @tparam ... any Arguments to pass to the phrase.
    -- @usage
    -- player:chatNotifyLocalized("welcome_message", player:Nick())
    function playerMeta:chatNotifyLocalized(message, ...)
        local client = LocalPlayer()
        if self == client then
            message = L(message, ...)
            chat.AddText(Color(255, 215, 0), message)
        end
    end

    --- Retrieves the player's total playtime.
    -- @realm client
    -- @treturn Float The total playtime of the player.
    -- @usage
    -- local playTime = player:getPlayTime()
    -- print("Playtime:", playTime, "seconds")
    function playerMeta:getPlayTime()
        local diff = os.time(lia.date.toNumber(lia.lastJoin)) - os.time(lia.date.toNumber(lia.firstJoin))
        return diff + (RealTime() - (lia.joinTime or 0))
    end

    playerMeta.GetPlayTime = playerMeta.getPlayTime
    --- Opens a UI panel for the player.
    -- @realm client
    -- @string panel The panel type to create.
    -- @treturn Panel The created UI panel.
    -- @usage
    -- local inventoryPanel = player:openUI("InventoryPanel")
    function playerMeta:openUI(panel)
        return vgui.Create(panel)
    end

    playerMeta.OpenUI = playerMeta.openUI
    --- Sets a waypoint for the player.
    -- @realm client
    -- @string name The name of the waypoint.
    -- @vector vector The position vector of the waypoint.
    -- @func onReach Function to call when the player reaches the waypoint.
    -- @usage
    -- player:setWeighPoint("Spawn Point", Vector(100, 200, 300), function(p)
    --     print("Player reached the waypoint.")
    -- end)
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
            hook.Remove("HUDPaint", "WeighPoint")
            if IsValid(onReach) then onReach() end
        end)
    end

    --- Retrieves a value from the local Lilia data.
    -- @realm client
    -- @string key The key for the data.
    -- @tparam any[opt=nil] default The default value to return if the key does not exist.
    -- @treturn any The value corresponding to the key, or the default value if the key does not exist.
    -- @usage
    -- local rank = player:getLiliaData("rank", "Novice")
    -- print("Player Rank:", rank)
    function playerMeta:getLiliaData(key, default)
        local data = lia.localData and lia.localData[key]
        if data == nil then
            return default
        else
            return data
        end
    end
end

playerMeta.GetItemDropPos = playerMeta.getItemDropPos
playerMeta.ChatNotify = playerMeta.chatNotify
playerMeta.ChatNotifyLocalized = playerMeta.chatNotifyLocalized
playerMeta.IsObserving = playerMeta.isObserving
playerMeta.IsOutside = playerMeta.isOutside
playerMeta.IsNoClipping = playerMeta.isNoClipping
playerMeta.SquaredDistanceFromEnt = playerMeta.squaredDistanceFromEnt
playerMeta.DistanceFromEnt = playerMeta.distanceFromEnt
playerMeta.IsNearPlayer = playerMeta.isNearPlayer
playerMeta.EntitiesNearPlayer = playerMeta.entitiesNearPlayer
playerMeta.GetItemWeapon = playerMeta.getItemWeapon
playerMeta.TakeMoney = playerMeta.takeMoney
playerMeta.GetMoney = playerMeta.getMoney
playerMeta.IsRunning = playerMeta.isRunning
playerMeta.IsFemale = playerMeta.isFemale
playerMeta.GetTracedEntity = playerMeta.getTracedEntity
playerMeta.GetTrace = playerMeta.getTrace
playerMeta.GetEyeEnt = playerMeta.getEyeEnt
playerMeta.SetAction = playerMeta.setAction
playerMeta.StopAction = playerMeta.stopAction
playerMeta.PlaySound = playerMeta.PlaySound
playerMeta.OpenPage = playerMeta.openPage
playerMeta.CreateServerRagdoll = playerMeta.createServerRagdoll
playerMeta.DoStaredAction = playerMeta.doStaredAction
playerMeta.Notify = playerMeta.notify
playerMeta.NotifyLocalized = playerMeta.notifyLocalized
playerMeta.SetRagdolled = playerMeta.setRagdolled
playerMeta.SyncVars = playerMeta.syncVars
playerMeta.NotifyP = playerMeta.notifyP
playerMeta.SetWeighPoint = playerMeta.setWeighPoint