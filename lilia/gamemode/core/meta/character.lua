--[[--
Contains information about a player's current game state.

Characters are a fundamental object type in Lilia. They are distinct from players, where players are the representation of a
person's existence in the server that owns a character, and their character is their currently selected persona. All the
characters that a player owns will be loaded into memory once they connect to the server. Characters are saved during a regular
interval (lia.config.CharacterDataSaveInterval), and during specific events (e.g when the owning player switches away from one character to another).

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
--- Returns a string representation of this character
-- @realm shared
-- @return string String representation
-- @usage print(lia.char.loaded[1])
-- > "character[1]"
function characterMeta:__tostring()
    return "character[" .. (self.id or 0) .. "]"
end

--- Returns true if this character is equal to another character. Internally, this checks character IDs.
-- @realm shared
-- @character other Character to compare to
-- @return bool Whether or not this character is equal to the given character
-- @usage print(lia.char.loaded[1] == lia.char.loaded[2])
-- > false
function characterMeta:__eq(other)
    return self:getID() == other:getID()
end

--- Returns this character's database ID. This is guaranteed to be unique.
-- @realm shared
-- @return number Unique ID of character
function characterMeta:getID()
    return self.id
end

--- Returns the player that owns this character.
-- @realm shared
-- @return player Player that owns this character
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
            if character and (character:getID() == self:getID()) then
                self.player = v
                return v
            end
        end
    end
end

--- Checks if the character has at least the specified amount of money.
-- @int amount The amount of money to check for.
-- @realm shared
-- @return bool Whether the character has at least the specified amount of money.
-- @usage local hasEnoughMoney = character:hasMoney(100)
function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then
        LiliaInformation("Negative Money Check Received.")
        return false
    end
    return self:getMoney() >= amount
end

--- Returns all of the flags this character has.
-- @realm shared
-- @treturn string Flags this character has represented as one string. You can access individual flags by iterating through
-- the string letter by letter
function characterMeta:getFlags()
    return self:getData("f", "")
end

--- Returns `true` if the character has the given flag(s).
-- @realm shared
-- @string flags Flag(s) to check access for
-- @treturn bool Whether or not this character has access to the given flag(s)
function characterMeta:hasFlags(flags)
    for i = 1, #flags do
        if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
    end
    return hook.Run("CharHasFlags", self, flags) or false
end

--- Retrieves the character's equipped weapon and its corresponding item from the inventory.
-- @realm shared
-- @return Entity|false The equipped weapon entity, or false if no weapon is equipped.
-- @return Item|false The corresponding item from the character's inventory, or false if no corresponding item is found.
-- @usage local weapon, item = character:getItemWeapon()
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
    --- Sets this character's accessible flags. Note that this method overwrites **all** flags instead of adding them.
    -- @realm server
    -- @string flags Flag(s) this charater is allowed to have
    -- @see giveFlags
    function characterMeta:setFlags(flags)
        self:setData("f", flags)
    end

    --- Adds a flag to the list of this character's accessible flags. This does not overwrite existing flags.
    -- @realm server
    -- @string flags Flag(s) this character should be given
    -- @usage character:GiveFlags("pet")
    -- gives p, e, and t flags to the character
    -- @see hasFlags
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

    --- Removes this character's access to the given flags.
    -- @realm server
    -- @string flags Flag(s) to remove from this character
    -- @usage -- for a character with "pet" flags
    -- character:takeFlags("p")
    -- -- character now has e, and t flags
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

    --- Saves this character's info to the database.
    -- @realm server
    -- @func[opt=nil] callback Function to call when the save has completed.
    -- @usage lia.char.loaded[1]:save(function()
    -- 	print("Done saving " .. lia.char.loaded[1] .. "!")
    -- end)
    -- > Done saving character[1]! -- after a moment
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

    --- Networks this character's information to make the given player aware of this character's existence. If the receiver is
    -- not the owner of this character, it will only be sent a limited amount of data (as it does not need anything else).
    -- This is done automatically by the framework.
    -- @internal
    -- @realm server
    -- @client[opt=nil] receiver Player to send the information to. This will sync to all connected players if set to `nil`.
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

    -- Sets up the "appearance" related inforomation for the character.
    --- Applies the character's appearance and synchronizes information to the owning player.
    -- @realm server
    -- @internal
    -- @bool[opt] noNetworking Whether or not to sync the character info to other players
    function characterMeta:setup(noNetworking)
        local client = self:getPlayer()
        if IsValid(client) then
            client:SetModel(isstring(self:getModel()) and self:getModel() or self:getModel()[1])
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

    --- Forces a player off their current character, and sends them to the character menu to select a character.
    -- @realm server
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

    --- Forces a player off their current character, and prevents them from using the character for the specified amount of time.
    -- @realm server
    -- @float[opt] time Amount of seconds to ban the character for. If left as `nil`, the character will be banned permanently
    function characterMeta:ban(time)
        time = tonumber(time)
        if time then time = os.time() + math.max(math.ceil(time), 60) end
        self:setData("banned", time or true)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    --- Deletes the character from the character database and removes it from memory.
    -- @realm server
    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    --- Destroys the character, removing it from memory and notifying clients to remove it.
    -- @realm server
    function characterMeta:destroy()
        local id = self:getID()
        lia.char.loaded[id] = nil
    end

    --- Gives or takes money from the character's wallet.
    -- @realm server
    -- @int amount The amount of money to give or take.
    -- @bool[opt=false] takingMoney Whether the operation is to take money from the character.
    -- @return bool Whether the operation was successful.
    function characterMeta:giveMoney(amount, takingMoney)
        local client = self:getPlayer()
        local currentMoney = self:getMoney()
        local maxMoneyLimit = lia.config.MoneyLimit or 0
        local limitOverride = hook.Run("WalletLimit", client)
        if limitOverride then maxMoneyLimit = limitOverride end
        local totalMoney = currentMoney + amount
        if not takingMoney then
            if maxMoneyLimit > 0 then
                if totalMoney > maxMoneyLimit then
                    local remainingMoney = totalMoney - maxMoneyLimit
                    client:notify("You can't carry more than " .. maxMoneyLimit .. " " .. lia.currency.plural .. ". Dropping remaining " .. remainingMoney .. " " .. lia.currency.plural .. " on the ground!")
                    self:setMoney(maxMoneyLimit)
                    local money = lia.currency.spawn(client:getItemDropPos(), remainingMoney)
                    money.client = client
                    money.charID = self:getID()
                    lia.log.add(client, "money", maxMoneyLimit)
                else
                    self:setMoney(totalMoney)
                    lia.log.add(client, "money", amount)
                end
            else
                self:setMoney(totalMoney)
                lia.log.add(client, "money", amount)
            end
        else
            self:setMoney(totalMoney)
            lia.log.add(client, "money", amount)
        end
        return true
    end

    --- Takes money from the character's wallet.
    -- @realm server
    -- @int amount The amount of money to take.
    -- @return bool Whether the operation was successful.
    function characterMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount, true)
        lia.log.add(client, "money", -amount)
        return true
    end
end

characterMeta.Save = characterMeta.save
characterMeta.Sync = characterMeta.sync
characterMeta.HasMoney = characterMeta.hasMoney
characterMeta.GetPlayer = characterMeta.getPlayer
characterMeta.GiveMoney = characterMeta.giveMoney
characterMeta.TakeMoney = characterMeta.takeMoney
lia.meta.character = characterMeta
