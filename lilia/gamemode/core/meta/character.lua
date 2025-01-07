--[[--
Contains information about a player's current game state.

Characters are a fundamental object type in Lilia. They are distinct from players, where players are the representation of a
person's existence in the server that owns a character, and their character is their currently selected persona. All the
characters that a player owns will be loaded into memory once they connect to the server. Characters are saved during a regular
interval (lia.config.CharacterDataSaveInterval), and during specific events (e.g., when the owning player switches away from one character to another).

They contain all information that is not persistent with the player; names, descriptions, model, currency, etc. For the most
part, you'll want to keep all information stored on the character since it will probably be different or change if the
player switches to another character. An easy way to do this is to use `lia.char.registerVar` to easily create accessor functions
for variables that automatically save to the character object.
]]
-- @charactermeta Framework
local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
debug.getregistry().Character = lia.meta.character
--- Provides a human-readable string representation of the character.
-- @realm shared
-- @treturn String A string in the format "character[ID]", where ID is the character's unique identifier.
-- @usage
-- print(lia.char.loaded[1])
-- Output: "character[1]"
function characterMeta:__tostring()
    return "character[" .. (self.id or 0) .. "]"
end

--- Compares this character with another character for equality based on their unique IDs.
-- @realm shared
-- @character other The other character to compare against.
-- @treturn Boolean `true` if both characters have the same ID; otherwise, `false`.
-- @usage
-- local char1 = lia.char.loaded[1]
-- local char2 = lia.char.loaded[2]
-- print(char1 == char2)
-- Output: false
function characterMeta:__eq(other)
    return self:getID() == other:getID()
end

--- Retrieves the unique database ID of this character.
-- @realm shared
-- @treturn Integer The unique identifier of the character.
-- @usage
-- local charID = character:getID()
-- print(charID)
-- Output: 1
function characterMeta:getID()
    return self.id
end

--- Obtains the player object that currently owns this character.
-- @realm shared
-- @treturn The player who owns this character, or `nil` if no valid player is found.
-- @usage
-- local owner = character:getPlayer()
-- if owner then
--     print("Character is owned by:", owner:Nick())
-- end
function characterMeta:getPlayer()
    if IsValid(self.player) then
        return self.player
    elseif self.steamID then
        local steamID = self.steamID
        for _, v in player.Iterator() do
            if v:SteamID64() == steamID then
                self.player = v
                return v
            end
        end
    else
        for _, v in player.Iterator() do
            local character = v:getChar()
            if character and character:getID() == self:getID() then
                self.player = v
                return v
            end
        end
    end
end

--- Checks whether the character possesses at least a specified amount of in-game currency.
-- @realm shared
-- @float amount The minimum amount of currency to check for. Must be a non-negative number.
-- @treturn Boolean `true` if the character's current money is equal to or exceeds the specified amount; otherwise, `false`.
-- @usage
-- local hasEnoughMoney = character:hasMoney(100)
-- if hasEnoughMoney then
--     print("Character has sufficient funds.")
-- else
--     print("Character lacks sufficient funds.")
-- end
function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

--- Retrieves all flags associated with this character.
-- @realm shared
-- @treturn String A concatenated string of all flags the character possesses. Each character in the string represents an individual flag.
-- @usage
-- local flags = character:getFlags()
-- for i = 1, #flags do
--     local flag = flags:sub(i, i)
--     print("Flag:", flag)
-- end
function characterMeta:getFlags()
    return self:getData("f", "")
end

--- Determines if the character has one or more specified flags.
-- @realm shared
-- @string flags A string containing one or more flags to check.
-- @treturn Boolean `true` if the character has at least one of the specified flags; otherwise, `false`.
-- @usage
-- if character:hasFlags("admin") then
--     print("Character has admin privileges.")
-- end
function characterMeta:hasFlags(flags)
    for i = 1, #flags do
        if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
    end
    return hook.Run("CharHasFlags", self, flags) or false
end

--- Retrieves the currently equipped weapon of the character along with its corresponding inventory item.
-- @realm shared
-- @treturn Entity|false The equipped weapon entity if a weapon is equipped; otherwise, `false`.
-- @treturn Item|false The corresponding item from the character's inventory if found; otherwise, `false`.
-- @usage
-- local weapon, item = character:getItemWeapon()
-- if weapon then
--     print("Equipped weapon:", weapon:GetClass())
-- else
--     print("No weapon equipped.")
-- end
function characterMeta:getItemWeapon()
    local client = self:getPlayer()
    local inv = self:getInv()
    local items = inv:getItems()
    local weapon = client:GetActiveWeapon()
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

if SERVER then
    --- Sets the complete set of flags accessible by this character, replacing any existing flags.
    -- **Note:** This method overwrites all existing flags and does not append to them.
    -- @realm server
    -- @string flags A string containing one or more flags to assign to the character.
    -- @usage
    -- character:setFlags("petr")
    -- This sets the character's flags to 'p', 'e', 't', 'r'
    function characterMeta:setFlags(flags)
        self:setData("f", flags)
    end

    --- Adds one or more flags to the character's existing set of accessible flags without removing existing ones.
    -- @realm server
    -- @string flags A string containing one or more flags to add.
    -- @usage
    -- character:giveFlags("pet")
    -- Adds 'p', 'e', and 't' flags to the character
    function characterMeta:giveFlags(flags)
        local addedFlags = ""
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info then
                if not self:hasFlags(flag) then addedFlags = addedFlags .. flag end
                if info.callback then info.callback(self:getPlayer(), true) end
            end
        end

        if addedFlags ~= "" then self:setFlags(self:getFlags() .. addedFlags) end
    end

    --- Removes one or more flags from the character's set of accessible flags.
    -- @realm server
    -- @string flags A string containing one or more flags to remove.
    -- @usage
    -- For a character with "pet" flags
    -- character:takeFlags("p")
    -- The character now only has 'e' and 't' flags
    function characterMeta:takeFlags(flags)
        local oldFlags = self:getFlags()
        local newFlags = oldFlags
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info and info.callback then info.callback(self:getPlayer(), false) end
            newFlags = newFlags:gsub(flag, "")
        end

        if newFlags ~= oldFlags then self:setFlags(newFlags) end
    end

    --- Persists the character's current state and data to the database.
    -- @realm server
    -- @func callback An optional callback function to execute after the save operation completes successfully.
    -- @usage
    -- character:save(function()
    --     print("Character saved successfully!")
    -- end)
    function characterMeta:save(callback)
        if self.isBot then return end
        local data = {}
        for k, v in pairs(lia.char.vars) do
            if v.field and self.vars[k] ~= nil then data[v.field] = self.vars[k] end
        end

        local shouldSave = hook.Run("CharPreSave", self)
        if shouldSave ~= false then
            lia.db.updateTable(data, function()
                if callback then callback() end
                hook.Run("CharPostSave", self)
            end, nil, "_id = " .. self:getID())
        end
    end

    --- Synchronizes the character's data with clients, making them aware of the character's current state.
    -- This method handles different synchronization scenarios:
    -- - If `receiver` is `nil`, the character's data is synced to all connected players.
    -- - If `receiver` is the owner of the character, full character data is sent.
    -- - If `receiver` is not the owner, only limited data is sent to prevent unauthorized access.
    -- @realm server
    -- @client receiver The specific player to send the character data to. If `nil`, data is sent to all players.
    -- @internal
    function characterMeta:sync(receiver)
        if receiver == nil then
            for _, v in player.Iterator() do
                self:sync(v)
            end
        elseif receiver == self.player then
            local data = {}
            for k, v in pairs(self.vars) do
                if lia.char.vars[k] ~= nil and not lia.char.vars[k].noNetworking then data[k] = v end
            end

            netstream.Start(self.player, "charInfo", data, self:getID())
            for _, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then v.onSync(self, self.player) end
            end
        else
            local data = {}
            for k, v in pairs(lia.char.vars) do
                if not v.noNetworking and not v.isLocal then data[k] = self.vars[k] end
            end

            netstream.Start(receiver, "charInfo", data, self:getID(), self.player)
            for _, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then v.onSync(self, receiver) end
            end
        end
    end

    --- Configures the character's appearance and synchronizes this information with the owning player.
    -- This includes setting the player's model, faction, body groups, and skin. Optionally, it can prevent networking to other clients.
    -- @realm server
    -- @bool noNetworking Optional. If set to `true`, the character's information will not be synchronized with other players.
    -- @internal
    -- @usage
    -- character:setup()
    function characterMeta:setup(noNetworking)
        local client = self:getPlayer()
        if IsValid(client) then
            local model = self:getModel()
            if isstring(model) then
                client:SetModel(model)
            elseif istable(model) then
                client:SetModel(model[1])
            end

            client:SetTeam(self:getFaction())
            client:setNetVar("char", self:getID())
            for k, v in pairs(self:getData("groups", {})) do
                client:SetBodygroup(k, v)
            end

            client:SetSkin(self:getData("skin", 0))
            if not noNetworking then
                for _, v in ipairs(self:getInv(true)) do
                    if istable(v) then v:sync(client) end
                end

                self:sync()
            end

            hook.Run("CharLoaded", self:getID())
            self.firstTimeLoaded = true
        end
    end

    --- Forces the player to exit their current character and redirects them to the character selection menu.
    -- This is typically used when a character is banned or deleted.
    -- @realm server
    -- @usage
    -- character:kick()
    function characterMeta:kick()
        local client = self:getPlayer()
        client:KillSilent()
        local steamID = client:SteamID64()
        local id = self:getID()
        local isCurrentChar = self and self:getID() == id
        if self and self.steamID == steamID then
            netstream.Start(client, "charKick", id, isCurrentChar)
            if isCurrentChar then
                client:setNetVar("char", nil)
                client:Spawn()
            end
        end
    end

    --- Bans the character, preventing it from being used for a specified duration or permanently if no duration is provided.
    -- This action also forces the player out of the character.
    -- @realm server
    -- @float time The duration of the ban in seconds. If omitted or `nil`, the ban is permanent.
    -- @usage
    -- character:ban(3600) -- Bans the character for 1 hour
    -- character:ban() -- Permanently bans the character
    function characterMeta:ban(time)
        time = tonumber(time)
        if time then time = os.time() + math.max(math.ceil(time), 60) end
        self:setData("banned", time or true)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    --- Removes the character from the database and memory, effectively deleting it permanently.
    -- @realm server
    -- @usage
    -- character:delete()
    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    --- Destroys the character instance, removing it from memory and ensuring it is no longer tracked by the server.
    -- This does not delete the character from the database.
    -- @realm server
    -- @usage
    -- character:destroy()
    function characterMeta:destroy()
        local id = self:getID()
        lia.char.loaded[id] = nil
    end

    --- Adds or subtracts money from the character's wallet.
    -- This function adds money to the wallet and optionally handles overflow by dropping excess money on the ground.
    -- @realm server
    -- @float amount The amount of money to add or subtract.
    -- @treturn Boolean Always returns `true` to indicate the operation was processed.
    -- @usage
    -- character:giveMoney(500) -- Adds 500 to the character's wallet
    function characterMeta:giveMoney(amount)
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        local currentMoney = self:getMoney()
        local maxMoneyLimit = lia.config.MoneyLimit or 0
        local totalMoney = currentMoney + amount
        if maxMoneyLimit > 0 and isnumber(maxMoneyLimit) and totalMoney > maxMoneyLimit then
            local excessMoney = totalMoney - maxMoneyLimit
            self:setMoney(maxMoneyLimit)
            client:notifyLocalized(L("moneyLimit", lia.currency.get(maxMoneyLimit), lia.currency.plural, lia.currency.get(excessMoney), lia.currency.plural))
            local money = lia.currency.spawn(client:getItemDropPos(), excessMoney)
            if IsValid(money) then
                money.client = client
                money.charID = self:getID()
            end

            lia.log.add(client, "money", maxMoneyLimit - currentMoney)
        else
            self:setMoney(totalMoney)
            lia.log.add(client, "money", amount)
        end
        return true
    end

    --- Specifically removes money from the character's wallet.
    -- This function ensures that only positive values are used to subtract from the wallet.
    -- @realm server
    -- @float amount The amount of money to remove. Must be a positive number.
    -- @treturn Boolean Always returns `true` to indicate the operation was processed.
    -- @usage
    -- character:takeMoney(100) -- Removes 100 from the character's wallet
    function characterMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount, true)
        lia.log.add(self:getPlayer(), "money", -amount)
        return true
    end
end

lia.meta.character = characterMeta