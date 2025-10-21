local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
--[[
    Purpose: Converts the character object to a string representation
    When Called: When displaying character information or debugging
    Parameters: None
    Returns: string - Formatted character string with ID
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get character string representation
        local charString = character:tostring()
        print(charString) -- Output: "character[123]"
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in debug messages
        local char = player:getChar()
        if char then
            print("Character: " .. char:tostring())
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in logging system
        local char = player:getChar()
        lia.log.add(player, "action", "Character " .. char:tostring() .. " performed action")
        ```
]]
function characterMeta:tostring()
    return L("character") .. "[" .. (self.id or 0) .. "]"
end

--[[
    Purpose: Compares two character objects for equality based on their IDs
    When Called: When checking if two character references point to the same character
    Parameters: other (character) - The other character object to compare with
    Returns: boolean - True if both characters have the same ID, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Compare two character objects
        local char1 = player1:getChar()
        local char2 = player2:getChar()
        if char1:eq(char2) then
            print("Same character")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in conditional logic
        local targetChar = target:getChar()
        local myChar = player:getChar()
        if myChar:eq(targetChar) then
            -- Handle self-targeting
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in character management system
        for _, char in pairs(characterList) do
            if char:eq(selectedCharacter) then
                -- Process matching character
                break
            end
        end
        ```
]]
function characterMeta:eq(other)
    return self:getID() == other:getID()
end

--[[
    Purpose: Retrieves the unique ID of the character
    When Called: When you need to identify a specific character instance
    Parameters: None
    Returns: number - The character's unique ID
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get character ID
        local char = player:getChar()
        local charID = char:getID()
        print("Character ID: " .. charID)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use ID for database operations
        local char = player:getChar()
        local charID = char:getID()
        lia.db.query("SELECT * FROM chardata WHERE charID = " .. charID)
        ```

        High Complexity:
        ```lua
        -- High: Use ID in networking
        net.Start("liaCharInfo")
        net.WriteUInt(char:getID(), 32)
        net.Send(player)
        ```
]]
function characterMeta:getID()
    return self.id
end

--[[
    Purpose: Retrieves the player entity associated with this character
    When Called: When you need to access the player who owns this character
    Parameters: None
    Returns: Player - The player entity, or nil if not found
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get the player from character
        local char = player:getChar()
        local owner = char:getPlayer()
        if IsValid(owner) then
            print("Player: " .. owner:Name())
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use player for operations
        local char = character:getPlayer()
        if IsValid(char) then
            char:SetPos(Vector(0, 0, 0))
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in networking and validation
        local char = character:getPlayer()
        if IsValid(char) then
            net.Start("liaCharSync")
            net.WriteEntity(char)
            net.Broadcast()
        end
        ```
]]
function characterMeta:getPlayer()
    if IsValid(self.player) then return self.player end
    for _, v in player.Iterator() do
        if self.steamID then
            if v:SteamID() == self.steamID then
                self.player = v
                return v
            end
        else
            local character = v:getChar()
            if character and character:getID() == self:getID() then
                self.player = v
                return v
            end
        end
    end
end

--[[
    Purpose: Gets the display name for a character based on recognition system
    When Called: When displaying character names to other players
    Parameters: client (Player) - The client who is viewing the character
    Returns: string - The name to display (real name, fake name, or "unknown")
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get display name for a player
        local char = target:getChar()
        local displayName = char:getDisplayedName(player)
        print("You see: " .. displayName)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in chat system
        local char = speaker:getChar()
        local displayName = char:getDisplayedName(listener)
        chat.AddText(Color(255, 255, 255), displayName .. ": " .. message)
        ```

        High Complexity:
        ```lua
        -- High: Use in UI display system
        local char = character:getDisplayedName(client)
        local nameColor = char == "unknown" and Color(128, 128, 128) or Color(255, 255, 255)
        draw.SimpleText(char, "DermaDefault", x, y, nameColor)
        ```
]]
function characterMeta:getDisplayedName(client)
    local isRecognitionEnabled = lia.config.get("RecognitionEnabled", true)
    if not isRecognitionEnabled then return self:getName() end
    if not IsValid(self:getPlayer()) or not IsValid(client) then return L("unknown") end
    local ourCharacter = client:getChar()
    if not self or not ourCharacter then return L("unknown") end
    if self:getPlayer() == client then return self:getName() end
    local characterID = self:getID()
    if ourCharacter:doesRecognize(characterID) then return self:getName() end
    local myReg = ourCharacter:getFakeName()
    if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
    return L("unknown")
end

--[[
    Purpose: Checks if the character has enough money for a transaction
    When Called: Before processing purchases, payments, or money transfers
    Parameters: amount (number) - The amount of money to check for
    Returns: boolean - True if character has sufficient funds, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player can afford an item
        local char = player:getChar()
        if char:hasMoney(100) then
            print("Can afford item")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in shop system
        local char = buyer:getChar()
        local itemPrice = 500
        if char:hasMoney(itemPrice) then
            char:takeMoney(itemPrice)
            char:giveItem("item_id")
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in complex transaction system
        local char = player:getChar()
        local totalCost = calculateTotalCost(items)
        if char:hasMoney(totalCost) then
            processTransaction(char, items, totalCost)
        else
            showInsufficientFundsError(char, totalCost)
        end
        ```
]]
function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

--[[
    Purpose: Checks if the character has any of the specified flags
    When Called: When checking permissions or access rights for a character
    Parameters: flagStr (string) - String containing flags to check for
    Returns: boolean - True if character has any of the specified flags, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check for admin flag
        local char = player:getChar()
        if char:hasFlags("a") then
            print("Player is admin")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check multiple flags
        local char = player:getChar()
        if char:hasFlags("ad") then
            -- Player has admin or donator flag
            grantSpecialAccess(char)
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in permission system
        local char = player:getChar()
        local requiredFlags = "adm"
        if char:hasFlags(requiredFlags) then
            showAdminPanel(player)
        else
            showAccessDenied(player)
        end
        ```
]]
function characterMeta:hasFlags(flagStr)
    local flags = self:getFlags()
    for i = 1, #flagStr do
        local flag = flagStr:sub(i, i)
        if flags:find(flag, 1, true) then return true end
    end
    return false
end

--[[
    Purpose: Checks if the character has a weapon item equipped
    When Called: When validating weapon usage or checking equipped items
    Parameters: requireEquip (boolean) - Whether to check if item is equipped (default: true)
    Returns: boolean - True if character has the weapon item, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player has weapon
        local char = player:getChar()
        if char:getItemWeapon() then
            print("Player has weapon")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check weapon with equip requirement
        local char = player:getChar()
        if char:getItemWeapon(true) then
            -- Player has equipped weapon
            allowWeaponUse(char)
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in weapon validation system
        local char = player:getChar()
        local hasWeapon = char:getItemWeapon(requireEquip)
        if hasWeapon then
            processWeaponAction(char, action)
        else
            showWeaponRequiredError(char)
        end
        ```
]]
function characterMeta:getItemWeapon(requireEquip)
    if requireEquip == nil then requireEquip = true end
    local client = self:getPlayer()
    local inv = self:getInv()
    local items = inv:getItems()
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return false end
    for _, v in pairs(items) do
        if v.class and v.class == weapon:GetClass() and requireEquip and v:getData("equip", false) then return true end
    end
    return false
end

--[[
    Purpose: Gets the value of a character attribute including boosts
    When Called: When checking character stats or calculating bonuses
    Parameters: key (string) - The attribute key to retrieve
    Parameters: default (number) - Default value if attribute doesn't exist (default: 0)
    Returns: number - The attribute value with boosts applied
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get character strength
        local char = player:getChar()
        local strength = char:getAttrib("str")
        print("Strength: " .. strength)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in skill checks
        local char = player:getChar()
        local intelligence = char:getAttrib("int", 10)
        if intelligence > 15 then
            grantSpecialAbility(char)
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in complex calculations
        local char = player:getChar()
        local baseStr = char:getAttrib("str")
        local baseInt = char:getAttrib("int")
        local totalBonus = baseStr + baseInt
        calculateCombatEffectiveness(char, totalBonus)
        ```
]]
function characterMeta:getAttrib(key, default)
    local att = self:getAttribs()[key] or default or 0
    local boosts = self:getVar("boosts", {})[key]
    if boosts then
        for _, v in pairs(boosts) do
            att = att + v
        end
    end
    return att
end

--[[
    Purpose: Gets the boost table for a specific attribute
    When Called: When checking or modifying attribute boosts
    Parameters: attribID (string) - The attribute ID to get boosts for
    Returns: table - Table containing boost values for the attribute
    Realm: Shared
    Example Usage:
        Low Complexity:
        -- Simple: Get strength boosts
        local char = player:getChar()
        local strBoosts = char:getBoost("str")
        if strBoosts then
            print("Has strength boosts")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check specific boost
        local char = player:getChar()
        local boosts = char:getBoost("int")
        if boosts and boosts["item_boost"] then
            print("Has item intelligence boost")
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in boost management system
        local char = player:getChar()
        local boosts = char:getBoost(attribID)
        if boosts then
            for boostID, value in pairs(boosts) do
                processBoost(char, attribID, boostID, value)
            end
        end
        ```
]]
function characterMeta:getBoost(attribID)
    local boosts = self:getVar("boosts", {})
    return boosts[attribID]
end

--[[
    Purpose: Checks if the character recognizes another character by ID
    When Called: When determining if one character knows another character's identity
    Parameters: id (number|character) - Character ID or character object to check recognition for
    Returns: boolean - True if character recognizes the other, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player recognizes target
        local char = player:getChar()
        local targetChar = target:getChar()
        if char:doesRecognize(targetChar) then
            print("Player recognizes target")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in recognition system
        local char = player:getChar()
        local targetID = target:getChar():getID()
        if char:doesRecognize(targetID) then
            showRealName(char, target)
        else
            showUnknownName(char, target)
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in complex recognition logic
        local char = player:getChar()
        for _, otherChar in pairs(characterList) do
            if char:doesRecognize(otherChar) then
                addToKnownList(char, otherChar)
            end
        end
        ```
]]
function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharRecognized", self, id) ~= false
end

--[[
    Purpose: Checks if the character has fake recognition of another character
    When Called: When determining if character knows a fake name for another character
    Parameters: id (number|character) - Character ID or character object to check fake recognition for
    Returns: boolean - True if character has fake recognition, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check fake recognition
        local char = player:getChar()
        local targetChar = target:getChar()
        if char:doesFakeRecognize(targetChar) then
            print("Player knows fake name")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in disguise system
        local char = player:getChar()
        local targetID = target:getChar():getID()
        if char:doesFakeRecognize(targetID) then
            showFakeName(char, target)
        else
            showUnknownName(char, target)
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in complex identity system
        local char = player:getChar()
        for _, otherChar in pairs(characterList) do
            if char:doesFakeRecognize(otherChar) then
                addToFakeKnownList(char, otherChar)
            end
        end
        ```
]]
function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharFakeRecognized", self, id) ~= false
end

--[[
    Purpose: Sets character data and optionally syncs it to database and clients
    When Called: When storing character-specific data that needs persistence
    Parameters: k (string|table) - Key to set or table of key-value pairs
    Parameters: v (any) - Value to set (ignored if k is table)
    Parameters: noReplication (boolean) - Skip client replication (default: false)
    Parameters: receiver (Player) - Specific client to send to (default: character owner)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set single data value
        local char = player:getChar()
        char:setData("lastLogin", os.time())
        ```

        Medium Complexity:
        -- Medium: Set multiple values
        local char = player:getChar()
        char:setData({
            ["level"] = 5,
            ["experience"] = 1000,
            ["class"] = "warrior"
        })
        ```

        High Complexity:
        ```lua
        -- High: Use in data management system
        local char = player:getChar()
        local dataToSet = {
            ["inventory"] = serializeInventory(inventory),
            ["position"] = player:GetPos(),
            ["health"] = player:Health()
        }
        char:setData(dataToSet, nil, false, specificPlayer)
        ```
]]
function characterMeta:setData(k, v, noReplication, receiver)
    if not self.dataVars then self.dataVars = {} end
    local toNetwork = {}
    if istable(k) then
        for nk, nv in pairs(k) do
            self.dataVars[nk] = nv
            toNetwork[#toNetwork + 1] = nk
        end
    else
        self.dataVars[k] = v
        toNetwork[1] = k
    end

    if SERVER then
        if not noReplication and #toNetwork > 0 then
            local target = receiver or self:getPlayer()
            if IsValid(target) then
                net.Start("liaCharacterData")
                net.WriteUInt(self:getID(), 32)
                net.WriteUInt(#toNetwork, 32)
                for _, nk in ipairs(toNetwork) do
                    local data = self.dataVars[nk]
                    if istable(data) then data = pon.encode(data) end
                    net.WriteString(nk)
                    net.WriteType(data)
                end

                net.Send(target)
            end
        end

        if istable(k) then
            for nk, nv in pairs(k) do
                if nv == nil then
                    lia.db.delete("chardata", "charID = " .. self:getID() .. " AND key = '" .. lia.db.escape(nk) .. "'")
                else
                    local encoded = pon.encode({nv})
                    lia.db.upsert({
                        charID = self:getID(),
                        key = nk,
                        value = encoded
                    }, "chardata", function(success, err) if not success then lia.error(L("failedInsertCharData", err)) end end)
                end
            end
        else
            if v == nil then
                lia.db.delete("chardata", "charID = " .. self:getID() .. " AND key = '" .. lia.db.escape(k) .. "'")
            else
                local encoded = pon.encode({v})
                lia.db.upsert({
                    charID = self:getID(),
                    key = k,
                    value = encoded
                }, "chardata", function(success, err) if not success then lia.error(L("failedInsertCharData", err)) end end)
            end
        end
    end
end

--[[
    Purpose: Retrieves character data by key or returns all data
    When Called: When accessing stored character-specific data
    Parameters: key (string) - The data key to retrieve (optional)
    Parameters: default (any) - Default value if key doesn't exist (optional)
    Returns: any - The data value, all data table, or default value
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get specific data
        local char = player:getChar()
        local level = char:getData("level", 1)
        print("Level: " .. level)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Get all character data
        local char = player:getChar()
        local allData = char:getData()
        for key, value in pairs(allData) do
            print(key .. ": " .. tostring(value))
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in data processing system
        local char = player:getChar()
        local inventory = char:getData("inventory", {})
        local position = char:getData("position", Vector(0, 0, 0))
        processCharacterState(char, inventory, position)
        ```
]]
function characterMeta:getData(key, default)
    self.dataVars = self.dataVars or {}
    if not key then return self.dataVars end
    local value = self.dataVars and self.dataVars[key] or default
    return value
end

--[[
    Purpose: Checks if the character is currently banned
    When Called: When validating character access or checking ban status
    Parameters: None
    Returns: boolean - True if character is banned, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if character is banned
        local char = player:getChar()
        if char:isBanned() then
            print("Character is banned")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in login validation
        local char = player:getChar()
        if char:isBanned() then
            player:Kick("Your character is banned")
            return
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in ban management system
        local char = player:getChar()
        if char:isBanned() then
            local banTime = char:getBanned()
            local banReason = char:getData("banReason", "No reason provided")
            showBanMessage(player, banTime, banReason)
        end
        ```
]]
function characterMeta:isBanned()
    local banned = self:getBanned()
    return banned ~= 0 and (banned == -1 or banned > os.time())
end

if SERVER then
    --[[
    Purpose: Makes the character recognize another character (with optional fake name)
    When Called: When establishing recognition between characters
    Parameters: character (number|character) - Character ID or character object to recognize
    Parameters: name (string) - Optional fake name to assign (default: nil)
    Returns: boolean - True if recognition was successful
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Recognize another character
        local char = player:getChar()
        local targetChar = target:getChar()
        char:recognize(targetChar)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Recognize with fake name
        local char = player:getChar()
        local targetID = target:getChar():getID()
        char:recognize(targetID, "John Doe")
        ```

        High Complexity:
        ```lua
        -- High: Use in recognition system
        local char = player:getChar()
        for _, otherChar in pairs(characterList) do
            if shouldRecognize(char, otherChar) then
                char:recognize(otherChar, getFakeName(char, otherChar))
            end
        end
        ```
]]
    function characterMeta:recognize(character, name)
        local id
        if isnumber(character) then
            id = character
        elseif character and character.getID then
            id = character:getID()
        end

        local recognized = self:getRecognition()
        local nameList = self:getFakeName()
        if name ~= nil then
            nameList[id] = name
            self:setFakeName(nameList)
        else
            self:setRecognition(recognized .. "," .. id .. ",")
        end
        return true
    end

    --[[
    Purpose: Makes the character join a specific class (faction job)
    When Called: When changing character class or job within their faction
    Parameters: class (string) - The class name to join
    Parameters: isForced (boolean) - Whether to force the class change (default: false)
    Returns: boolean - True if class change was successful, false otherwise
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Join a class
        local char = player:getChar()
        char:joinClass("citizen")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Force class change
        local char = player:getChar()
        if char:joinClass("police", true) then
            print("Successfully joined police force")
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in class management system
        local char = player:getChar()
        local newClass = determineClass(char, player)
        if char:joinClass(newClass) then
            updateCharacterUI(player)
            notifyClassChange(player, newClass)
        else
            showClassChangeError(player, newClass)
        end
        ```
]]
    function characterMeta:joinClass(class, isForced)
        if not class then
            self:kickClass()
            return false
        end

        local client = self:getPlayer()
        local classData = lia.class.list[class]
        if not classData or classData.faction ~= client:Team() then
            self:kickClass()
            return false
        end

        local oldClass = self:getClass()
        local hadOldClass = oldClass and oldClass ~= -1
        if isForced or lia.class.canBe(client, class) then
            self:setClass(class)
            if hadOldClass then
                hook.Run("OnPlayerSwitchClass", client, class, oldClass)
            else
                hook.Run("OnPlayerJoinClass", client, class, oldClass)
            end
            return true
        else
            return false
        end
    end

    --[[
    Purpose: Removes the character from their current class and assigns default class
    When Called: When removing character from their current job or class
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Kick from class
        local char = player:getChar()
        char:kickClass()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in demotion system
        local char = player:getChar()
        if char:getClass() == "police" then
            char:kickClass()
            notifyDemotion(player)
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in class management system
        local char = player:getChar()
        local oldClass = char:getClass()
        char:kickClass()
        logClassChange(player, oldClass, "none")
        updateCharacterPermissions(player)
        ```
]]
    function characterMeta:kickClass()
        local client = self:getPlayer()
        if not client then return end
        local validDefaultClass
        for k, v in pairs(lia.class.list) do
            if v.faction == client:Team() and v.isDefault then
                validDefaultClass = k
                break
            end
        end

        if validDefaultClass then
            self:joinClass(validDefaultClass)
            hook.Run("OnPlayerJoinClass", client, validDefaultClass)
        else
            self:setClass(nil)
        end
    end

    --[[
    Purpose: Updates a character attribute by adding to the current value
    When Called: When modifying character stats through gameplay or admin actions
    Parameters: key (string) - The attribute key to update
    Parameters: value (number) - The amount to add to the current attribute value
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Increase strength
        local char = player:getChar()
        char:updateAttrib("str", 1)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in level up system
        local char = player:getChar()
        char:updateAttrib("int", 2)
        char:updateAttrib("str", 1)
        notifyStatIncrease(player, "int", 2)
        ```

        High Complexity:
        ```lua
        -- High: Use in complex attribute system
        local char = player:getChar()
        local statGains = calculateStatGains(char, experience)
        for stat, gain in pairs(statGains) do
            char:updateAttrib(stat, gain)
            logStatChange(player, stat, gain)
        end
        ```
]]
    function characterMeta:updateAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if not attribute then return end
        local attrib = self:getAttribs()
        local currentLevel = attrib[key] or 0
        local maxLevel = hook.Run("GetAttributeMax", client, key) or math.huge
        attrib[key] = math.min(currentLevel + value, maxLevel)
        if IsValid(client) then
            net.Start("liaAttributeData")
            net.WriteUInt(self:getID(), 32)
            net.WriteString(key)
            net.WriteType(attrib[key])
            net.Send(client)
            hook.Run("OnCharAttribUpdated", client, self, key, attrib[key])
        end
    end

    --[[
    Purpose: Sets a character attribute to a specific value
    When Called: When setting character stats to exact values
    Parameters: key (string) - The attribute key to set
    Parameters: value (number) - The exact value to set the attribute to
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set strength to specific value
        local char = player:getChar()
        char:setAttrib("str", 10)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in character creation
        local char = player:getChar()
        char:setAttrib("str", 5)
        char:setAttrib("int", 8)
        char:setAttrib("dex", 6)
        ```

        High Complexity:
        ```lua
        -- High: Use in admin system
        local char = player:getChar()
        local newStats = calculateNewStats(char, adminCommand)
        for stat, value in pairs(newStats) do
            char:setAttrib(stat, value)
            logAdminAction(admin, "set " .. stat .. " to " .. value)
        end
        ```
]]
    function characterMeta:setAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if attribute then
            local attrib = self:getAttribs()
            attrib[key] = value
            if IsValid(client) then
                net.Start("liaAttributeData")
                net.WriteUInt(self:getID(), 32)
                net.WriteString(key)
                net.WriteType(attrib[key])
                net.Send(client)
                hook.Run("OnCharAttribUpdated", client, self, key, attrib[key])
            end
        end
    end

    --[[
    Purpose: Adds a temporary boost to a character attribute
    When Called: When applying temporary stat bonuses from items, spells, or effects
    Parameters: boostID (string) - Unique identifier for this boost
    Parameters: attribID (string) - The attribute to boost
    Parameters: boostAmount (number) - The amount to boost the attribute by
    Returns: boolean - True if boost was added successfully
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Add strength boost
        local char = player:getChar()
        char:addBoost("potion_str", "str", 5)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in item system
        local char = player:getChar()
        local item = char:getItem("strength_potion")
        if item then
            char:addBoost("item_" .. item:getID(), "str", item:getData("boostAmount", 3))
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in complex boost system
        local char = player:getChar()
        local boosts = calculateBoosts(char, equipment)
        for boostID, boostData in pairs(boosts) do
            char:addBoost(boostID, boostData.attrib, boostData.amount)
        end
        ```
]]
    function characterMeta:addBoost(boostID, attribID, boostAmount)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = boostAmount
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --[[
    Purpose: Removes a temporary boost from a character attribute
    When Called: When removing temporary stat bonuses from items, spells, or effects
    Parameters: boostID (string) - Unique identifier for the boost to remove
    Parameters: attribID (string) - The attribute the boost was applied to
    Returns: boolean - True if boost was removed successfully
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Remove strength boost
        local char = player:getChar()
        char:removeBoost("potion_str", "str")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in item removal
        local char = player:getChar()
        local item = char:getItem("strength_potion")
        if item then
            char:removeBoost("item_" .. item:getID(), "str")
        end
        ```

        High Complexity:
        ```lua
        -- High: Use in boost cleanup system
        local char = player:getChar()
        local expiredBoosts = getExpiredBoosts(char)
        for boostID, attribID in pairs(expiredBoosts) do
            char:removeBoost(boostID, attribID)
        end
        ```
]]
    function characterMeta:removeBoost(boostID, attribID)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = nil
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --[[
    Purpose: Sets the character flags to a specific string
    When Called: When changing character permissions or access rights
    Parameters: flags (string) - The flags string to set
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set admin flags
        local char = player:getChar()
        char:setFlags("a")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in permission system
        local char = player:getChar()
        char:setFlags("ad")
        notifyPermissionChange(player, "admin and donator")
        ```

        High Complexity:
        ```lua
        -- High: Use in complex permission management
        local char = player:getChar()
        local newFlags = calculateFlags(char, role, level)
        char:setFlags(newFlags)
        updateCharacterPermissions(player)
        logPermissionChange(admin, player, newFlags)
        ```
]]
    function characterMeta:setFlags(flags)
        local oldFlags = self:getFlags()
        self.vars.flags = flags
        net.Start("liaCharSet")
        net.WriteString("flags")
        net.WriteType(flags)
        net.WriteType(self:getID())
        net.Broadcast()
        hook.Run("OnCharVarChanged", self, "flags", oldFlags, flags)
        local ply = self:getPlayer()
        if not IsValid(ply) then return end
        for i = 1, #oldFlags do
            local flag = oldFlags:sub(i, i)
            if not flags:find(flag, 1, true) then
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(ply, false) end
            end
        end

        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not oldFlags:find(flag, 1, true) then
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(ply, true) end
            end
        end
    end

    --[[
    Purpose: Adds flags to the character without removing existing ones
    When Called: When granting additional permissions to a character
    Parameters: flags (string) - The flags to add to the character
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Give donator flag
        local char = player:getChar()
        char:giveFlags("d")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in reward system
        local char = player:getChar()
        char:giveFlags("v")
        notifyReward(player, "VIP status granted")
        ```

        High Complexity:
        ```lua
        -- High: Use in complex permission system
        local char = player:getChar()
        local earnedFlags = calculateEarnedFlags(char, achievements)
        char:giveFlags(earnedFlags)
        updateCharacterUI(player)
        logFlagGrant(admin, player, earnedFlags)
        ```
]]
    function characterMeta:giveFlags(flags)
        local addedFlags = ""
        local ply = self:getPlayer()
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not self:hasFlags(flag) then
                addedFlags = addedFlags .. flag
                local info = lia.flag.list[flag]
                if info and info.callback and ply and IsValid(ply) then info.callback(ply, true) end
            end
        end

        if addedFlags ~= "" then
            self:setFlags(self:getFlags() .. addedFlags)
            if ply and IsValid(ply) then hook.Run("OnCharFlagsGiven", ply, self, addedFlags) end
        end
    end

    --[[
    Purpose: Removes flags from the character
    When Called: When revoking permissions or access rights from a character
    Parameters: flags (string) - The flags to remove from the character
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Remove admin flag
        local char = player:getChar()
        char:takeFlags("a")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in demotion system
        local char = player:getChar()
        char:takeFlags("a")
        notifyDemotion(player, "Admin status revoked")
        ```

        High Complexity:
        ```lua
        -- High: Use in complex permission system
        local char = player:getChar()
        local revokedFlags = calculateRevokedFlags(char, violations)
        char:takeFlags(revokedFlags)
        updateCharacterUI(player)
        logFlagRevoke(admin, player, revokedFlags)
        ```
]]
    function characterMeta:takeFlags(flags)
        local oldFlags = self:getFlags()
        local newFlags = oldFlags
        local ply = self:getPlayer()
        local removedFlags = ""
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info and info.callback and ply and IsValid(ply) then info.callback(ply, false) end
            newFlags = newFlags:gsub(flag, "")
            if not removedFlags:find(flag, 1, true) then removedFlags = removedFlags .. flag end
        end

        if newFlags ~= oldFlags then
            self:setFlags(newFlags)
            if removedFlags ~= "" then hook.Run("OnCharFlagsTaken", ply, self, removedFlags) end
        end
    end

    --[[
    Purpose: Saves the character data to the database
    When Called: When persisting character changes to the database
    Parameters: callback (function) - Optional callback function to execute after save
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Save character
        local char = player:getChar()
        char:save()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Save with callback
        local char = player:getChar()
        char:save(function()
            print("Character saved successfully")
        end)
        ```

        High Complexity:
        ```lua
        -- High: Use in save system
        local char = player:getChar()
        char:save(function()
            updateCharacterCache(char)
            notifySaveComplete(player)
            logCharacterSave(char)
        end)
        ```
]]
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
            end, nil, "id = " .. self:getID())
        end
    end

    --[[
    Purpose: Synchronizes character data with clients
    When Called: When updating character information on client side
    Parameters: receiver (Player) - Specific client to sync to (default: all players)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Sync to all players
        local char = player:getChar()
        char:sync()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Sync to specific player
        local char = player:getChar()
        char:sync(targetPlayer)
        ```

        High Complexity:
        ```lua
        -- High: Use in sync system
        local char = player:getChar()
        char:sync(receiver)
        updateCharacterUI(receiver)
        logCharacterSync(char, receiver)
        ```
]]
    function characterMeta:sync(receiver)
        if receiver == nil then
            for _, v in player.Iterator() do
                self:sync(v)
            end
        elseif receiver == self.player then
            local player = self:getPlayer()
            if IsValid(player) then
                local data = {}
                for k, v in pairs(self.vars) do
                    if lia.char.vars[k] ~= nil and not lia.char.vars[k].noNetworking then data[k] = v end
                end

                net.Start("liaCharInfo")
                net.WriteTable(data)
                net.WriteUInt(self:getID(), 32)
                net.Send(player)
                for _, v in pairs(lia.char.vars) do
                    if isfunction(v.onSync) then v.onSync(self, player) end
                end
            end
        else
            local data = {}
            for k, v in pairs(lia.char.vars) do
                if not v.noNetworking and not v.isLocal then data[k] = self.vars[k] end
            end

            net.Start("liaCharInfo")
            net.WriteTable(data)
            net.WriteUInt(self:getID(), 32)
            net.WriteEntity(self:getPlayer())
            net.Send(receiver)
            local ply = self:getPlayer()
            if IsValid(ply) then
                lia.net[ply] = lia.net[ply] or {}
                local oldVal = lia.net[ply]["char"]
                lia.net[ply]["char"] = self:getID()
                net.Start("liaNetVar")
                net.WriteUInt(ply:EntIndex(), 16)
                net.WriteString("char")
                net.WriteType(self:getID())
                net.Send(receiver)
                hook.Run("NetVarChanged", ply, "char", oldVal, self:getID())
            end

            for _, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then v.onSync(self, receiver) end
            end
        end
    end

    --[[
    Purpose: Sets up the character for the player (model, team, inventory, etc.)
    When Called: When loading a character for a player
    Parameters: noNetworking (boolean) - Skip networking setup (default: false)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Setup character
        local char = player:getChar()
        char:setup()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Setup without networking
        local char = player:getChar()
        char:setup(true)
        ```

        High Complexity:
        ```lua
        -- High: Use in character loading system
        local char = player:getChar()
        char:setup(noNetworking)
        updateCharacterUI(player)
        logCharacterLoad(char)
        ```
]]
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
            for k, v in pairs(self:getBodygroups()) do
                local index = tonumber(k)
                local value = tonumber(v) or 0
                if index then client:SetBodygroup(index, value) end
            end

            client:SetSkin(self:getSkin())
            hook.Run("SetupPlayerModel", client, self)
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

    --[[
    Purpose: Kicks the character from the server
    When Called: When removing a character from the game
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Kick character
        local char = player:getChar()
        char:kick()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in admin system
        local char = target:getChar()
        char:kick()
        notifyKick(admin, target)
        ```

        High Complexity:
        ```lua
        -- High: Use in complex kick system
        local char = player:getChar()
        char:kick()
        logCharacterKick(char, reason)
        updateCharacterList()
        ```
]]
    function characterMeta:kick()
        local client = self:getPlayer()
        client:KillSilent()
        local curChar, steamID = client:getChar(), client:SteamID()
        local isCurChar = curChar and curChar:getID() == self:getID() or false
        if self.steamID == steamID then
            if isCurChar then
                net.Start("liaRemoveFOne")
                net.Send(client)
            end

            net.Start("liaCharKick")
            net.WriteUInt(self:getID(), 32)
            net.WriteBool(isCurChar)
            net.Send(client)
            if isCurChar then
                client:setNetVar("char", nil)
                client:Spawn()
            end
        end

        hook.Run("OnCharKick", self, client)
    end

    --[[
    Purpose: Bans the character for a specified time or permanently
    When Called: When applying a ban to a character
    Parameters: time (number) - Ban duration in seconds (nil for permanent ban)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Ban character permanently
        local char = player:getChar()
        char:ban()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Ban for specific time
        local char = player:getChar()
        char:ban(3600) -- 1 hour ban
        ```

        High Complexity:
        ```lua
        -- High: Use in ban system
        local char = player:getChar()
        char:ban(banTime)
        logCharacterBan(char, banTime, reason)
        notifyBan(admin, player, banTime)
        ```
]]
    function characterMeta:ban(time)
        time = tonumber(time)
        local value
        if time then
            value = os.time() + math.max(math.ceil(time), 60)
        else
            value = -1
        end

        self:setBanned(value)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    --[[
    Purpose: Deletes the character from the database
    When Called: When permanently removing a character
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Delete character
        local char = player:getChar()
        char:delete()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in admin system
        local char = target:getChar()
        char:delete()
        notifyDeletion(admin, target)
        ```

        High Complexity:
        ```lua
        -- High: Use in complex deletion system
        local char = player:getChar()
        char:delete()
        logCharacterDeletion(char, reason)
        updateCharacterList()
        ```
]]
    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    --[[
    Purpose: Destroys the character object and removes it from memory
    When Called: When cleaning up character data from memory
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Destroy character
        local char = player:getChar()
        char:destroy()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in cleanup system
        local char = player:getChar()
        char:destroy()
        updateCharacterList()
        ```

        High Complexity:
        ```lua
        -- High: Use in complex cleanup system
        local char = player:getChar()
        char:destroy()
        logCharacterDestroy(char)
        updateCharacterCache()
        ```
]]
    function characterMeta:destroy()
        local id = self:getID()
        lia.char.removeCharacter(id)
    end

    --[[
    Purpose: Gives money to the character
    When Called: When adding money to a character's account
    Parameters: amount (number) - The amount of money to give
    Returns: boolean - True if money was given successfully
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Give money
        local char = player:getChar()
        char:giveMoney(100)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in reward system
        local char = player:getChar()
        char:giveMoney(rewardAmount)
        notifyReward(player, "You received $" .. rewardAmount)
        ```

        High Complexity:
        ```lua
        -- High: Use in complex economy system
        local char = player:getChar()
        char:giveMoney(amount)
        logMoneyTransaction(char, amount, "reward")
        updateEconomyStats()
        ```
]]
    function characterMeta:giveMoney(amount)
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        return client:addMoney(amount)
    end

    --[[
    Purpose: Takes money from the character
    When Called: When removing money from a character's account
    Parameters: amount (number) - The amount of money to take
    Returns: boolean - True if money was taken successfully
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Take money
        local char = player:getChar()
        char:takeMoney(50)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use in payment system
        local char = player:getChar()
        char:takeMoney(itemPrice)
        notifyPayment(player, "You paid $" .. itemPrice)
        ```

        High Complexity:
        ```lua
        -- High: Use in complex economy system
        local char = player:getChar()
        char:takeMoney(amount)
        logMoneyTransaction(char, -amount, "purchase")
        updateEconomyStats()
        ```
]]
    function characterMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount)
        lia.log.add(self:getPlayer(), "money", -amount)
        return true
    end
end

lia.meta.character = characterMeta
