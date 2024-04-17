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
-- @classmod Character
local charMeta = lia.meta.character or {}
charMeta.__index = charMeta
charMeta.id = charMeta.id or 0
charMeta.vars = charMeta.vars or {}
debug.getregistry().Character = lia.meta.character
--- Returns a string representation of this character
-- @realm shared
-- @return string String representation
-- @usage print(lia.char.loaded[1])
-- > "character[1]"
function charMeta:__tostring()
    return "character[" .. (self.id or 0) .. "]"
end

--- Returns true if this character is equal to another character. Internally, this checks character IDs.
-- @realm shared
-- @character other Character to compare to
-- @return bool Whether or not this character is equal to the given character
-- @usage print(lia.char.loaded[1] == lia.char.loaded[2])
-- > false
function charMeta:__eq(other)
    return self:getID() == other:getID()
end

--- Returns this character's database ID. This is guaranteed to be unique.
-- @realm shared
-- @return number Unique ID of character
function charMeta:getID()
    return self.id
end

--- Retrieves the boost value for a specific attribute.
-- @function charMeta:getBoost
-- @int attribID The ID of the attribute for which to retrieve the boost.
-- @realm shared
-- @return number|nil The boost value for the specified attribute, or nil if no boost is found.
-- @usage local boostValue = char:getBoost("some_attribute_id")
function charMeta:getBoost(attribID)
    local boosts = self:getBoosts()
    return boosts[attribID]
end

--- Retrieves all boosts applied to the character's attributes.
-- @function charMeta:getBoosts
-- @realm shared
-- @return table A table containing all boosts applied to the character's attributes.
-- @usage local boostsTable = char:getBoosts()
function charMeta:getBoosts()
    return self:getVar("boosts", {})
end

--- Retrieves the character's equipped weapon and its corresponding item from the inventory.
-- @function charMeta:getItemWeapon
-- @realm shared
-- @return Entity|false The equipped weapon entity, or false if no weapon is equipped.
-- @return Item|false The corresponding item from the character's inventory, or false if no corresponding item is found.
-- @usage local weapon, item = char:getItemWeapon()
function charMeta:getItemWeapon()
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

--- Retrieves the value of a character attribute, including applied boosts.
-- @function charMeta:getAttrib
-- @string key The key of the attribute to retrieve.
-- @int[opt=0] default The default value to return if the attribute is not found.
-- @realm shared
-- @return number The value of the specified attribute, including applied boosts.
-- @usage local attributeValue = char:getAttrib("some_attribute_key")
function charMeta:getAttrib(key, default)
    local att = self:getAttribs()[key] or default or 0
    local boosts = self:getBoosts()[key]
    if boosts then
        for _, v in pairs(boosts) do
            att = att + v
        end
    end
    return att
end

--- Returns the player that owns this character.
-- @realm shared
-- @return player Player that owns this character
function charMeta:getPlayer()
    if IsValid(self.player) then
        return self.player
    elseif self.steamID then
        local steamID = self.steamID
        for _, v in ipairs(player.GetAll()) do
            if v:SteamID64() == steamID then
                self.player = v
                return v
            end
        end
    else
        for _, v in ipairs(player.GetAll()) do
            local character = v:getChar()
            if character and (character:getID() == self:getID()) then
                self.player = v
                return v
            end
        end
    end
end

--- Checks if the character has at least the specified amount of money.
-- @function charMeta:hasMoney
-- @int amount The amount of money to check for.
-- @realm shared
-- @return bool Whether the character has at least the specified amount of money.
-- @usage local hasEnoughMoney = char:hasMoney(100)
function charMeta:hasMoney(amount)
    if amount < 0 then print("Negative Money Check Received.") end
    return self:getMoney() >= amount
end

--- Sets the character's class to the specified class.
-- @function charMeta:joinClass
-- @string class The class to join.
-- @bool[opt=false] isForced Whether to force the character to join the class even if conditions are not met.
-- @realm shared
-- @return bool Whether the character successfully joined the class.
-- @usage local success = char:joinClass("some_class")
function charMeta:joinClass(class, isForced)
    if not class then
        self:kickClass()
        return
    end

    local oldClass = self:getClass()
    local client = self:getPlayer()
    if isForced or lia.class.canBe(client, class) then
        self:setClass(class)
        hook.Run("OnPlayerJoinClass", client, class, oldClass)
        return true
    else
        return false
    end
end

--- Kicks the character from their current class and joins them to the default class of their faction.
-- @function charMeta:kickClass
-- @realm shared
-- @usage char:kickClass()
function charMeta:kickClass()
    local client = self:getPlayer()
    if not client then return end
    local goClass
    for k, v in pairs(lia.class.list) do
        if v.faction == client:Team() and v.isDefault then
            goClass = k
            break
        end
    end

    self:joinClass(goClass)
    hook.Run("OnPlayerJoinClass", client, goClass)
end

--- Checks if the character belongs to the specified faction.
-- @function charMeta:isFaction
-- @int faction Index of the faction to check against.
-- @realm shared
-- @return bool Whether the character belongs to the specified faction.
-- @usage local isInFaction = char:isFaction("some_faction")
function charMeta:isFaction(faction)
    return self:getFaction() == faction
end

if SERVER then
    --- Updates the value of a character attribute by adding a specified value to it.
    -- @function charMeta:updateAttrib
    -- @string key The key of the attribute to update.
    -- @int value The value to add to the attribute.
    -- @realm server
    -- @usage char:updateAttrib("some_attribute_key", 10)
    function charMeta:updateAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if attribute then
            local attrib = self:getAttribs()
            attrib[key] = math.min((attrib[key] or 0) + value, attribute.maxValue or lia.config.MaxAttributes)
            if IsValid(client) then
                netstream.Start(client, "attrib", self:getID(), key, attrib[key])
                if attribute.setup then attribute.setup(attrib[key]) end
            end
        end

        hook.Run("OnCharAttribUpdated", client, self, key, value)
    end

    --- Sets the value of a character attribute.
    -- @function charMeta:setAttrib
    -- @string key The key of the attribute to set.
    -- @int value The value to set for the attribute.
    -- @realm server
    -- @usage char:setAttrib("some_attribute_key", 10)
    function charMeta:setAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if attribute then
            local attrib = self:getAttribs()
            attrib[key] = value
            if IsValid(client) then
                netstream.Start(client, "attrib", self:getID(), key, attrib[key])
                if attribute.setup then attribute.setup(attrib[key]) end
            end
        end

        hook.Run("OnCharAttribUpdated", client, self, key, value)
    end

    --- Adds a boost to the character's attributes.
    -- @function charMeta:addBoost
    -- @string boostID The ID of the boost to add.
    -- @string attribID The ID of the attribute to which the boost should be added.
    -- @int boostAmount The amount of boost to add to the attribute.
    -- @realm server
    -- @usage char:removeBoost("some_boost_id", "some_attribute_id", 10)
    function charMeta:addBoost(boostID, attribID, boostAmount)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = boostAmount
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --- Removes a boost from the character's attributes.
    -- @function charMeta:removeBoost
    -- @string boostID The ID of the boost to remove.
    -- @string attribID The ID of the attribute from which the boost should be removed.
    -- @realm server
    -- @usage char:removeBoost("some_boost_id", "some_attribute_id")
    function charMeta:removeBoost(boostID, attribID)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = nil
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --- Saves this character's info to the database.
    -- @realm server
    -- @func[opt=nil] callback Function to call when the save has completed.
    -- @usage lia.char.loaded[1]:save(function()
    -- 	print("Done saving " .. lia.char.loaded[1] .. "!")
    -- end)
    -- > Done saving character[1]! -- after a moment
    function charMeta:save(callback)
        if self.isBot then return end
        local data = {}
        for k, v in pairs(lia.char.vars) do
            if v.field and self.vars[k] ~= nil then data[v.field] = self.vars[k] end
        end

        local shouldSave = hook.Run("CharacterPreSave", self)
        if shouldSave ~= false then
            lia.db.updateTable(data, function()
                if callback then callback() end
                hook.Run("CharacterPostSave", self)
            end, nil, "_id = " .. self:getID())
        end
    end

    --- Networks this character's information to make the given player aware of this character's existence. If the receiver is
    -- not the owner of this character, it will only be sent a limited amount of data (as it does not need anything else).
    -- This is done automatically by the framework.
    -- @internal
    -- @realm server
    -- @player[opt=nil] receiver Player to send the information to. This will sync to all connected players if set to `nil`.
    function charMeta:sync(receiver)
        if receiver == nil then
            for _, v in ipairs(player.GetAll()) do
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
    function charMeta:setup(noNetworking)
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

            hook.Run("CharacterLoaded", self:getID())
            self.firstTimeLoaded = true
        end
    end

    --- Forces a player off their current character, and sends them to the character menu to select a character.
    -- @realm server
    function charMeta:kick()
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
    -- @number[opt] time Amount of seconds to ban the character for. If left as `nil`, the character will be banned permanently
    function charMeta:ban(time)
        time = tonumber(time)
        if time then time = os.time() + math.max(math.ceil(time), 60) end
        self:setData("banned", time or true)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    --- Deletes the character from the character database and removes it from memory.
    -- @function charMeta:delete
    -- @realm shared
    function charMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    --- Destroys the character, removing it from memory and notifying clients to remove it.
    -- @function charMeta:destroy
    -- @realm shared
    function charMeta:destroy()
        local id = self:getID()
        lia.char.loaded[id] = nil
        netstream.Start(nil, "charDel", id)
    end

    --- Gives or takes money from the character's wallet.
    -- @function charMeta:giveMoney
    -- @int amount The amount of money to give or take.
    -- @bool[opt=false] takingMoney Whether the operation is to take money from the character.
    -- @realm shared
    -- @return bool Whether the operation was successful.
    function charMeta:giveMoney(amount, takingMoney)
        local client = self:getPlayer()
        local currentMoney = self:getMoney()
        local totalMoney = currentMoney + amount
        local maxMoneyLimit = lia.config.MoneyLimit or 0
        local remainingMoney = totalMoney - maxMoneyLimit
        local negativeTotalMoney = currentMoney + amount
        if hook.Run("WalletLimit", client) ~= nil then maxMoneyLimit = hook.Run("WalletLimit", client) end
        if not takingMoney then
            if maxMoneyLimit > 0 then
                if totalMoney > maxMoneyLimit then
                    client:notify("You can't carry more than " .. maxMoneyLimit .. " " .. lia.currency.plural .. " dropping remaining " .. remainingMoney .. " " .. lia.currency.plural .. " on the ground!")
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
                lia.log.add(client, "money", amount)
                self:setMoney(totalMoney)
            end
        else
            lia.log.add(client, "money", amount)
            self:setMoney(negativeTotalMoney)
        end
        return true
    end

    --- Takes money from the character's wallet.
    -- @function charMeta:takeMoney
    -- @int amount The amount of money to take.
    -- @realm shared
    -- @return bool Whether the operation was successful.
    function charMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount, true)
        lia.log.add(client, "money", -amount)
        return true
    end
end

charMeta.GetBoost = charMeta.getBoost
charMeta.GetBoosts = charMeta.getBoosts
charMeta.GetAttribute = charMeta.getAttrib
charMeta.GetPlayer = charMeta.getPlayer
charMeta.HasMoney = charMeta.hasMoney
charMeta.JoinClass = charMeta.joinClass
charMeta.KickClass = charMeta.kickClass
charMeta.UpdateAttrib = charMeta.updateAttrib
charMeta.SetAttribute = charMeta.setAttrib
charMeta.AddBoost = charMeta.addBoost
charMeta.RemoveBoost = charMeta.removeBoost
charMeta.Save = charMeta.save
charMeta.Sync = charMeta.sync
charMeta.GiveMoney = charMeta.giveMoney
charMeta.TakeMoney = charMeta.takeMoney
lia.meta.character = charMeta
