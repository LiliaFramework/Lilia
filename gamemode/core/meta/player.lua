--[[
    Folder: Developer - Meta Tables
    File: player.md
]]
--[[
    Player

    Player metadata helpers for character access, notifications, requests, progression, persistence, and ragdoll state.
]]
--[[
    Overview:
        The player meta table extends Garry's Mod player entities with Lilia-specific helpers for resolving active characters, handling action bars and prompts, managing flags and money, querying stored profile data, syncing local and networked vars, and coordinating server-side gameplay state such as stamina, ragdolls, and bans.
]]
local playerMeta = FindMetaTable("Player")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    --[[
        Purpose:
            Returns the currently loaded character attached to this player.

        Returns:
            Character|nil
                The active character object when one is loaded.

        Example Usage:
            ```lua
            local character = client:getChar()
            if character then print(character:getName()) end
            ```

        Realm:
            Shared
    ]]
    function playerMeta:getChar()
        return lia.char.getCharacter(self.getNetVar(self, "char"), self)
    end

    --[[
        Purpose:
            Produces a string representation of the player using the active character name when available.

        Returns:
            string
                The character name or the Steam display name.

        Example Usage:
            ```lua
            print(client:tostring())
            ```

        Realm:
            Shared
    ]]
    function playerMeta:tostring()
        local character = self:getChar()
        if character and character.getName then
            return character:getName()
        else
            return self:SteamName()
        end
    end

    --[[
        Purpose:
            Overrides the player name lookup to prefer the active character name.

        Returns:
            string
                The character name or the original Steam name fallback.

        Example Usage:
            ```lua
            print(client:Name())
            ```

        Realm:
            Shared
    ]]
    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

--[[
    Purpose:
        Restarts a player gesture locally and syncs it to nearby players.

    Parameters:
        a (number)
            The gesture slot.
        b (number)
            The animation activity or gesture ID.
        c (boolean|number|nil)
            Optional autokill or blend argument passed to the engine call.

    Returns:
        nil

    Example Usage:
        ```lua
        client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_WAVE, true)
        ```

    Realm:
        Shared
]]
function playerMeta:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    netstream.Start(self:GetPos(), "liaSyncGesture", self, a, b, c)
end

--[[
    Purpose:
        Starts, updates, or clears the action bar for this player and optionally runs a callback when it completes.

    Parameters:
        text (string|nil)
            The label to display, or `nil` to clear the action.
        time (number|nil)
            The duration in seconds.
        callback (function|nil)
            Runs when the timer completes successfully.

    Returns:
        nil

    Example Usage:
        ```lua
        client:setAction("Searching crate", 4, function(ply)
            ply:notify("Search complete.")
        end)
        ```

    Realm:
        Shared
]]
function playerMeta:setAction(text, time, callback)
    if time and time <= 0 then
        if callback then callback(self) end
        return
    end

    time = time or 5
    if not text then
        if SERVER then
            timer.Remove("liaAct" .. self:SteamID64())
            net.Start("liaActBar")
            net.WriteBool(false)
            net.Send(self)
        else
            if IsValid(lia.gui.actionCircle) then lia.gui.actionCircle:Remove() end
        end
        return
    end

    if SERVER then
        net.Start("liaActBar")
        net.WriteBool(true)
        net.WriteString(text)
        net.WriteFloat(time)
        net.Send(self)
        if callback then timer.Create("liaAct" .. self:SteamID64(), time, 1, function() if IsValid(self) then callback(self) end end) end
    else
        if IsValid(lia.gui.actionCircle) then lia.gui.actionCircle:Remove() end
        lia.gui = lia.gui or {}
        local pnl = vgui.Create("liaLockCircle")
        pnl:Start(text, time)
        lia.gui.actionCircle = pnl
        if callback then timer.Simple(time, function() if IsValid(self) then callback(self) end end) end
    end
end

--[[
    Purpose:
        Requires the player to keep looking at an entity for a duration before a callback fires.

    Parameters:
        entity (Entity)
            The entity the player must keep tracing.
        callback (function|nil)
            Runs when the stare completes.
        time (number)
            The total stare time in seconds.
        onCancel (function|nil)
            Runs if the action is interrupted.
        distance (number|nil)
            Optional trace distance override.

    Returns:
        nil

    Example Usage:
        ```lua
        client:doStaredAction(door, function()
            client:notify("Unlocked.")
        end, 3)
        ```

    Realm:
        Shared
]]
function playerMeta:doStaredAction(entity, callback, time, onCancel, distance)
    local uniqueID = "liaStare" .. self:SteamID64()
    local data = {}
    data.filter = self
    timer.Create(uniqueID, 0.1, time / 0.1, function()
        if IsValid(self) and IsValid(entity) then
            data.start = self:GetShootPos()
            data.endpos = data.start + self:GetAimVector() * (distance or 96)
            local targetEntity = self:getTracedEntity()
            if IsValid(targetEntity) and targetEntity:GetClass() == "prop_ragdoll" then
                for _, ply in player.Iterator() do
                    if ply:GetRagdollEntity() == targetEntity then
                        targetEntity = ply
                        break
                    end
                end
            end

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

--[[
    Purpose:
        Stops the player's active action bar and stare timer.

    Returns:
        nil

    Example Usage:
        ```lua
        client:stopAction()
        ```

    Realm:
        Server
]]
function playerMeta:stopAction()
    timer.Remove("liaAct" .. self:SteamID64())
    timer.Remove("liaStare" .. self:SteamID64())
    net.Start("liaActBar")
    net.WriteBool(false)
    net.Send(self)
end

--[[
    Purpose:
        Checks whether the player has access to a named administrative privilege.

    Parameters:
        privilegeName (string)
            The privilege identifier to test.

    Returns:
        boolean
            `true` when the player has access.

    Example Usage:
        ```lua
        if client:hasPrivilege("canEditVendors") then
            print("Vendor editing allowed.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:hasPrivilege(privilegeName)
    if not isstring(privilegeName) then
        lia.error(L("hasPrivilegeExpectedString", tostring(privilegeName)))
        return false
    end
    return lia.admin.hasAccess(self, privilegeName)
end

--[[
    Purpose:
        Removes the player's current ragdoll entity and clears the associated network var.

    Returns:
        nil

    Example Usage:
        ```lua
        client:removeRagdoll()
        ```

    Realm:
        Server
]]
function playerMeta:removeRagdoll()
    local ragdoll = self:GetRagdollEntity()
    if not IsValid(ragdoll) then return end
    ragdoll.liaIgnoreDelete = true
    SafeRemoveEntity(ragdoll)
    self:setNetVar("ragdoll", nil)
end

--[[
    Purpose:
        Resolves the equipped inventory item that matches the player's active weapon.

    Returns:
        Weapon|nil
            The active weapon entity when it maps to an equipped item.
        Item|nil
            The matching inventory item.

    Example Usage:
        ```lua
        local weapon, item = client:getItemWeapon()
        if item then print(item.uniqueID) end
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Detects whether the player is connected through Steam Family Sharing.

    Returns:
        boolean
            `true` when the owner's SteamID differs from the current player's SteamID.

    Example Usage:
        ```lua
        if client:isFamilySharedAccount() then
            print("Family-shared account detected.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:isFamilySharedAccount()
    return util.SteamIDFrom64(self:OwnerSteamID64()) ~= self:SteamID()
end

--[[
    Purpose:
        Calculates a nearby valid world position for dropping an item in front of the player.

    Returns:
        Vector
            The traced drop position.

    Example Usage:
        ```lua
        local dropPos = client:getItemDropPos()
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Returns the item table for the player's active character inventory.

    Returns:
        table|nil
            A table of inventory items when the character and inventory exist.

    Example Usage:
        ```lua
        local items = client:getItems() or {}
        print(#items)
        ```

    Realm:
        Shared
]]
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

--[[
    Purpose:
        Traces forward from the player and returns the entity they are looking at.

    Parameters:
        distance (number|nil)
            Optional maximum trace distance. Defaults to `96`.

    Returns:
        Entity
            The traced entity, which may be invalid.

    Example Usage:
        ```lua
        local target = client:getTracedEntity(128)
        ```

    Realm:
        Shared
]]
function playerMeta:getTracedEntity(distance)
    if not distance then distance = 96 end
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * distance
    data.filter = self
    local targetEntity = util.TraceLine(data).Entity
    return targetEntity
end

--[[
    Purpose:
        Sends a plain notification to the player or local client.

    Parameters:
        message (string)
            The notification text.
        notifType (string|nil)
            The notice style. Defaults to `"default"`.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notify("Inventory updated.")
        ```

    Realm:
        Shared
]]
function playerMeta:notify(message, notifType)
    if SERVER then
        lia.notices.notify(self, message, notifType or "default")
    else
        lia.notices.notify(nil, message, notifType or "default")
    end
end

--[[
    Purpose:
        Sends a localized notification with formatting arguments.

    Parameters:
        message (string)
            The localization key or text token.
        notifType (string|nil)
            The notice style. Defaults to `"default"`.
        ... (any)
            Additional localization arguments.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyLocalized("salary", "money", "250", "salary")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyLocalized(message, notifType, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, message, notifType or "default", ...)
    else
        lia.notices.notifyLocalized(nil, message, notifType or "default", ...)
    end
end

--[[
    Purpose:
        Sends an error notification.

    Parameters:
        message (string)
            The error text.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyError("You cannot do that.")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyError(message)
    if SERVER then
        lia.notices.notify(self, message, "error")
    else
        lia.notices.notify(nil, message, "error")
    end
end

--[[
    Purpose:
        Sends a warning notification.

    Parameters:
        message (string)
            The warning text.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyWarning("You are over-encumbered.")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyWarning(message)
    if SERVER then
        lia.notices.notify(self, message, "warning")
    else
        lia.notices.notify(nil, message, "warning")
    end
end

--[[
    Purpose:
        Sends an informational notification.

    Parameters:
        message (string)
            The info text.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyInfo("Waypoint updated.")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyInfo(message)
    if SERVER then
        lia.notices.notify(self, message, "info")
    else
        lia.notices.notify(nil, message, "info")
    end
end

--[[
    Purpose:
        Sends a success notification.

    Parameters:
        message (string)
            The success text.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifySuccess("Craft complete.")
        ```

    Realm:
        Shared
]]
function playerMeta:notifySuccess(message)
    if SERVER then
        lia.notices.notify(self, message, "success")
    else
        lia.notices.notify(nil, message, "success")
    end
end

--[[
    Purpose:
        Sends a money-themed notification.

    Parameters:
        message (string)
            The money notice text.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyMoney("+250 tokens")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyMoney(message)
    if SERVER then
        lia.notices.notify(self, message, "money")
    else
        lia.notices.notify(nil, message, "money")
    end
end

--[[
    Purpose:
        Sends an admin-themed notification.

    Parameters:
        message (string)
            The admin notice text.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyAdmin("Staff mode enabled.")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyAdmin(message)
    if SERVER then
        lia.notices.notify(self, message, "admin")
    else
        lia.notices.notify(nil, message, "admin")
    end
end

--[[
    Purpose:
        Sends a localized error notification.

    Parameters:
        key (string)
            The localization token.
        ... (any)
            Additional localization arguments.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyErrorLocalized("notEnoughMoney")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyErrorLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "error", ...)
    else
        lia.notices.notifyLocalized(nil, key, "error", ...)
    end
end

--[[
    Purpose:
        Sends a localized warning notification.

    Parameters:
        key (string)
            The localization token.
        ... (any)
            Additional localization arguments.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyWarningLocalized("storageNotLocked")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyWarningLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "warning", ...)
    else
        lia.notices.notifyLocalized(nil, key, "warning", ...)
    end
end

--[[
    Purpose:
        Sends a localized informational notification.

    Parameters:
        key (string)
            The localization token.
        ... (any)
            Additional localization arguments.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyInfoLocalized("questUpdate")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyInfoLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "info", ...)
    else
        lia.notices.notifyLocalized(nil, key, "info", ...)
    end
end

--[[
    Purpose:
        Sends a localized success notification.

    Parameters:
        key (string)
            The localization token.
        ... (any)
            Additional localization arguments.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifySuccessLocalized("npcCustomizedSuccessfully")
        ```

    Realm:
        Shared
]]
function playerMeta:notifySuccessLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "success", ...)
    else
        lia.notices.notifyLocalized(nil, key, "success", ...)
    end
end

--[[
    Purpose:
        Sends a localized money notification.

    Parameters:
        key (string)
            The localization token.
        ... (any)
            Additional localization arguments.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyMoneyLocalized("salary", "250", "salary")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyMoneyLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "money", ...)
    else
        lia.notices.notifyLocalized(nil, key, "money", ...)
    end
end

--[[
    Purpose:
        Sends a localized admin notification.

    Parameters:
        key (string)
            The localization token.
        ... (any)
            Additional localization arguments.

    Returns:
        nil

    Example Usage:
        ```lua
        client:notifyAdminLocalized("groupPermissionsUpdated")
        ```

    Realm:
        Shared
]]
function playerMeta:notifyAdminLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "admin", ...)
    else
        lia.notices.notifyLocalized(nil, key, "admin", ...)
    end
end

--[[
    Purpose:
        Checks whether the player can edit a vendor, honoring hook overrides first.

    Parameters:
        vendor (Entity)
            The vendor entity to test.

    Returns:
        boolean
            `true` when editing is allowed.

    Example Usage:
        ```lua
        if client:canEditVendor(vendor) then
            print("Vendor editing permitted.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:canEditVendor(vendor)
    local hookResult = hook.Run("CanPerformVendorEdit", self, vendor)
    if hookResult ~= nil then return hookResult end
    return self:hasPrivilege("canEditVendors")
end

local function groupHasType(groupName, t)
    local groups = lia.admin.groups or {}
    local visited = {}
    t = t:lower()
    while groupName and not visited[groupName] do
        visited[groupName] = true
        local data = groups[groupName]
        if not data then break end
        local info = data._info or {}
        for _, typ in ipairs(info.types or {}) do
            if tostring(typ):lower() == t then return true end
        end

        groupName = info.inheritance
    end
    return false
end

--[[
    Purpose:
        Checks whether the player's admin group is classified as staff.

    Returns:
        boolean
            `true` when the user's group inherits the `Staff` type.

    Example Usage:
        ```lua
        if client:isStaff() then print("Staff account.") end
        ```

    Realm:
        Shared
]]
function playerMeta:isStaff()
    return groupHasType(self:GetUserGroup(), "Staff")
end

--[[
    Purpose:
        Checks whether the player is currently on the staff faction.

    Returns:
        boolean
            `true` when the player's team matches `FACTION_STAFF`.

    Example Usage:
        ```lua
        if client:isStaffOnDuty() then print("On-duty staff.") end
        ```

    Realm:
        Shared
]]
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

--[[
    Purpose:
        Checks whether the player has access to a faction whitelist.

    Parameters:
        faction (number)
            The faction index to test.

    Returns:
        boolean
            `true` when the faction is default or whitelisted for this schema.

    Example Usage:
        ```lua
        if client:hasWhitelist(FACTION_CWU) then
            print("Whitelist available.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        if not data.uniqueID then return false end
        local liaData = self:getLiliaData("whitelists", {})
        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] or false
    end
    return false
end

--[[
    Purpose:
        Returns the class definition for the player's active character.

    Returns:
        table|nil
            The class data table when a class is assigned.

    Example Usage:
        ```lua
        local classData = client:getClassData()
        if classData then print(classData.name) end
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Provides DarkRP compatibility for retrieving player money.

    Parameters:
        var (string)
            The DarkRP var name to query.

    Returns:
        number|nil
            The player's money for the `"money"` key.

    Example Usage:
        ```lua
        local money = client:getDarkRPVar("money")
        ```

    Realm:
        Shared
]]
function playerMeta:getDarkRPVar(var)
    if var ~= "money" then return end
    local char = self:getChar()
    return char:getMoney()
end

--[[
    Purpose:
        Returns the current money value from the player's active character.

    Returns:
        number
            The character's money, or `0` if no character is loaded.

    Example Usage:
        ```lua
        print(client:getMoney())
        ```

    Realm:
        Shared
]]
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--[[
    Purpose:
        Checks whether the player can afford a given amount.

    Parameters:
        amount (number)
            The amount to compare against the player's money.

    Returns:
        boolean|nil
            `true` when the character has enough money.

    Example Usage:
        ```lua
        if client:canAfford(100) then
            print("Purchase allowed.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--[[
    Purpose:
        Checks whether the active character meets a minimum level for one skill.

    Parameters:
        skill (string)
            The attribute or skill identifier.
        level (number)
            The required level.

    Returns:
        boolean
            `true` when the character's effective attribute meets the threshold.

    Example Usage:
        ```lua
        if client:hasSkillLevel("stm", 10) then
            print("Stamina requirement met.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--[[
    Purpose:
        Checks whether the active character satisfies every required skill threshold in a table.

    Parameters:
        requiredSkillLevels (table|nil)
            A map of skill IDs to minimum levels.

    Returns:
        boolean
            `true` when all requirements are satisfied or no requirements were supplied.

    Example Usage:
        ```lua
        if client:meetsRequiredSkills({str = 5, stm = 10}) then
            print("All skill requirements met.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

--[[
    Purpose:
        Returns the active character's flags.

    Returns:
        string
            The character flag string, or an empty string.

    Example Usage:
        ```lua
        print(client:getFlags())
        ```

    Realm:
        Shared
]]
function playerMeta:getFlags()
    local char = self:getChar()
    return char and char:getFlags() or ""
end

--[[
    Purpose:
        Grants flags to the active character.

    Parameters:
        flags (string)
            The flags to add.

    Returns:
        nil

    Example Usage:
        ```lua
        client:giveFlags("ab")
        ```

    Realm:
        Shared
]]
function playerMeta:giveFlags(flags)
    local char = self:getChar()
    if char then char:giveFlags(flags) end
end

--[[
    Purpose:
        Removes flags from the active character.

    Parameters:
        flags (string)
            The flags to remove.

    Returns:
        nil

    Example Usage:
        ```lua
        client:takeFlags("b")
        ```

    Realm:
        Shared
]]
function playerMeta:takeFlags(flags)
    local char = self:getChar()
    if char then char:takeFlags(flags) end
end

--[[
    Purpose:
        Broadcasts or applies procedural bone animation state for the player.

    Parameters:
        active (boolean)
            Whether the animation should be applied or cleared.
        boneData (table)
            A map of bone names to target angles.

    Returns:
        nil

    Example Usage:
        ```lua
        client:networkAnimation(true, {
            ["ValveBiped.Bip01_Head1"] = Angle(10, 0, 0)
        })
        ```

    Realm:
        Shared
]]
function playerMeta:networkAnimation(active, boneData)
    if SERVER then
        net.Start("liaAnimationStatus")
        net.WriteEntity(self)
        net.WriteBool(active)
        net.WriteTable(boneData)
        net.Broadcast()
    else
        if not self.liaBoneCache then self.liaBoneCache = {} end
        for name, ang in pairs(boneData) do
            local i = self:LookupBone(name)
            if i then
                local targetAng = active and ang or angle_zero
                local cachedAng = self.liaBoneCache[i]
                local shouldUpdate = true
                if cachedAng then
                    local diff = math.abs(cachedAng.p - targetAng.p) + math.abs(cachedAng.y - targetAng.y) + math.abs(cachedAng.r - targetAng.r)
                    shouldUpdate = diff > 0.001
                end

                if shouldUpdate then
                    self:ManipulateBoneAngles(i, targetAng)
                    self.liaBoneCache[i] = targetAng
                end
            end
        end
    end
end

--[[
    Purpose:
        Returns the full Lilia profile data table for this player on the current realm.

    Returns:
        table
            The server-side `liaData` table or the client-side `lia.localData` cache.

    Example Usage:
        ```lua
        local allData = client:getAllLiliaData()
        ```

    Realm:
        Shared
]]
function playerMeta:getAllLiliaData()
    if SERVER then
        self.liaData = self.liaData or {}
        return self.liaData
    else
        lia.localData = lia.localData or {}
        return lia.localData
    end
end

--[[
    Purpose:
        Sets a waypoint for the player or renders one locally until it is reached.

    Parameters:
        name (string)
            The waypoint label.
        vector (Vector)
            The world position to target.
        logo (string|nil)
            Optional material path for the waypoint icon.
        onReach (function|nil)
            Optional callback fired when the waypoint is cleared locally.

    Returns:
        nil

    Example Usage:
        ```lua
        client:setWaypoint("Safehouse", Vector(0, 0, 0), "materials/icon16/house.png")
        ```

    Realm:
        Shared
]]
function playerMeta:setWaypoint(name, vector, logo, onReach)
    if SERVER then
        net.Start("liaSetWaypoint")
        net.WriteString(name)
        net.WriteVector(vector)
        net.WriteString(logo or "")
        net.Send(self)
    else
        if not isstring(name) or not isvector(vector) then return end
        local logoMaterial
        if logo and isstring(logo) and logo ~= "" then
            logoMaterial = Material(logo, "smooth mips noclamp")
            if not logoMaterial or logoMaterial:IsError() then logoMaterial = nil end
        end

        if logo and not logoMaterial then return end
        local waypointID = "Waypoint_" .. tostring(self:SteamID64()) .. "_" .. tostring(math.random(100000, 999999))
        hook.Add("HUDPaint", waypointID, function()
            if not IsValid(self) then
                hook.Remove("HUDPaint", waypointID)
                return
            end

            local dist = self:GetPos():Distance(vector)
            local spos = vector:ToScreen()
            local howClose = math.Round(dist / 40)
            if spos.visible then
                if logoMaterial then
                    local logoSize = 24
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(logoMaterial)
                    surface.DrawTexturedRect(spos.x - logoSize / 2, spos.y - logoSize / 2 - 25, logoSize, logoSize)
                end

                surface.SetFont("LiliaFont.17")
                local nameText = name
                local metersText = L("meters", howClose)
                local nameTw, nameTh = surface.GetTextSize(nameText)
                local metersTw, metersTh = surface.GetTextSize(metersText)
                local containerTw = math.max(nameTw, metersTw)
                local containerTh = nameTh + metersTh + 6
                local bx, by = math.Round(spos.x - containerTw * 0.5 - 8), math.Round(spos.y - 8)
                local bw, bh = containerTw + 16, containerTh + 12
                local theme = lia.color.theme or {
                    background_panelpopup = Color(30, 30, 30, 180),
                    theme = Color(255, 255, 255),
                    text = Color(255, 255, 255)
                }

                local fadeAlpha = 1
                local headerColor = Color(theme.background_panelpopup.r, theme.background_panelpopup.g, theme.background_panelpopup.b, math.Clamp(theme.background_panelpopup.a * fadeAlpha, 0, 255))
                local accentColor = Color(theme.theme.r, theme.theme.g, theme.theme.b, math.Clamp(theme.theme.a * fadeAlpha, 0, 255))
                local textColor = Color(theme.text.r, theme.text.g, theme.text.b, math.Clamp(theme.text.a * fadeAlpha, 0, 255))
                lia.util.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
                lia.derma.rect(bx, by, bw, bh - 6):Radii(16, 16, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
                lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 16, 16):Color(accentColor):Draw()
                draw.SimpleText(nameText, "LiliaFont.17", math.Round(spos.x), math.Round(spos.y - 1), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(metersText, "LiliaFont.17", math.Round(spos.x), math.Round(spos.y - 1 + nameTh + 3), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            if howClose <= 3 then RunConsoleCommand("waypoint_stop_" .. waypointID) end
        end)

        concommand.Add("waypoint_stop_" .. waypointID, function()
            hook.Remove("HUDPaint", waypointID)
            concommand.Remove("waypoint_stop_" .. waypointID)
            if onReach and isfunction(onReach) then onReach(self) end
            if SERVER then
                if self.waypointOnReach and isfunction(self.waypointOnReach) then
                    self.waypointOnReach(self)
                    self.waypointOnReach = nil
                end
            else
                net.Start("liaWaypointReached")
                net.SendToServer()
            end
        end)
    end
end

--[[
    Purpose:
        Returns one stored Lilia data value with a fallback default.

    Parameters:
        key (string)
            The data key to fetch.
        default (any)
            The fallback value when the key is missing.

    Returns:
        any
            The stored value or the provided default.

    Example Usage:
        ```lua
        local whitelists = client:getLiliaData("whitelists", {})
        ```

    Realm:
        Shared
]]
function playerMeta:getLiliaData(key, default)
    local data
    if SERVER then
        data = self.liaData and self.liaData[key]
    else
        data = lia.localData and lia.localData[key]
    end

    if data == nil then
        return default
    else
        return data
    end
end

--[[
    Purpose:
        Returns the player's configured main character ID.

    Returns:
        number|nil
            The main character ID, if one has been set.

    Example Usage:
        ```lua
        local mainCharID = client:getMainCharacter()
        ```

    Realm:
        Shared
]]
function playerMeta:getMainCharacter()
    local mainCharData = self:getLiliaData("mainCharacter")
    if mainCharData then
        if istable(mainCharData) then
            return mainCharData.charID
        else
            return mainCharData
        end
    else
        return nil
    end
end

--[[
    Purpose:
        Sets or clears the player's main character, enforcing cooldowns and ownership checks on the server.

    Parameters:
        charID (number|nil)
            The character ID to set as main, or `nil`/`0` to clear it.

    Returns:
        boolean|nil
            On the server, `true` for success or `false` on failure.
        string|nil
            An optional localized error message when blocked by cooldowns.

    Example Usage:
        ```lua
        local success, err = client:setMainCharacter(12)
        ```

    Realm:
        Shared
]]
function playerMeta:setMainCharacter(charID)
    if SERVER then
        charID = tonumber(charID)
        if not charID or charID == 0 then
            self:setLiliaData("mainCharacter", nil)
            self:saveLiliaData()
            return true
        end

        local cooldownDays = lia.config.get("MainCharacterCooldownDays", 0)
        if cooldownDays > 0 then
            local mainCharData = self:getLiliaData("mainCharacter")
            local lastSetTime
            if istable(mainCharData) then
                lastSetTime = mainCharData.setTime
            else
                lastSetTime = self:getLiliaData("mainCharacterSetTime")
            end

            if lastSetTime then
                local daysSince = (os.time() - lastSetTime) / 86400
                if daysSince < cooldownDays then
                    local daysRemaining = math.ceil(cooldownDays - daysSince)
                    return false, L("mainCharacterCooldownActive", daysRemaining)
                end
            end
        end

        if table.HasValue(self.liaCharList or {}, charID) then
            local mainCharTable = {
                charID = charID,
                setTime = os.time()
            }

            self:setLiliaData("mainCharacter", mainCharTable)
            if self.liaData and self.liaData.mainCharacterSetTime then self.liaData.mainCharacterSetTime = nil end
            self:saveLiliaData()
            return true
        end
        return false
    else
        net.Start("liaSetMainCharacter")
        net.WriteUInt(charID or 0, 32)
        net.SendToServer()
    end
end

--[[
    Purpose:
        Checks whether the active character owns any of the requested flags.

    Parameters:
        flags (string)
            One or more flag characters to test.

    Returns:
        boolean
            `true` when any requested flag exists or a hook grants access.

    Example Usage:
        ```lua
        if client:hasFlags("pet") then
            print("Flag requirement met.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:hasFlags(flags)
    for i = 1, #flags do
        local flag = flags:sub(i, i)
        if self:getFlags():find(flag, 1, true) then return true end
    end
    return hook.Run("CharHasFlags", self, flags) or false
end

--[[
    Purpose:
        Checks whether the player's total playtime exceeds a threshold.

    Parameters:
        time (number)
            The threshold in seconds.

    Returns:
        boolean
            `true` when playtime is greater than the given amount.

    Example Usage:
        ```lua
        if client:playTimeGreaterThan(3600) then
            print("Played more than an hour.")
        end
        ```

    Realm:
        Shared
]]
function playerMeta:playTimeGreaterThan(time)
    local playTime = self:getPlayTime()
    if not playTime or not time then return false end
    return playTime > time
end

local function serializeRequestText(value)
    if istable(value) then
        local token = value[1]
        if isstring(token) and token:sub(1, 1) == "@" then
            return lia.lang.resolveToken(token, unpack(value, 2))
        elseif token ~= nil then
            return tostring(token)
        end
        return ""
    end
    return value or ""
end

--[[
    Purpose:
        Opens a list selection request for the player, or a local Derma dialog on the client.

    Parameters:
        title (string|table)
            The request title.
        subTitle (string|table)
            Supporting description text.
        options (table|nil)
            The selectable option list.
        limit (number|nil)
            Maximum number of allowed selections.
        callback (function|nil)
            Runs with the selected result.
        onCancel (function|nil)
            Client-side cancel callback.

    Returns:
        nil

    Example Usage:
        ```lua
        client:requestOptions("Choose Loadout", "Select one option.", {"Rifle", "SMG"}, 1, function(result)
            PrintTable(result)
        end)
        ```

    Realm:
        Shared
]]
function playerMeta:requestOptions(title, subTitle, options, limit, callback, onCancel)
    if SERVER then
        self.liaOptionsReqs = self.liaOptionsReqs or {}
        local id = table.insert(self.liaOptionsReqs, {
            callback = callback,
            allowed = options or {},
            limit = tonumber(limit) or 1
        })

        net.Start("liaOptionsRequest")
        net.WriteUInt(id, 32)
        net.WriteString(serializeRequestText(title))
        net.WriteString(serializeRequestText(subTitle))
        net.WriteTable(options or {})
        net.WriteUInt(tonumber(limit) or 1, 32)
        net.Send(self)
    else
        lia.derma.requestOptions(title, subTitle, options, tonumber(limit) or 1, callback, onCancel)
    end
end

--[[
    Purpose:
        Requests a string input from the player and optionally returns a deferred promise-like object.

    Parameters:
        title (string|table)
            The request title.
        subTitle (string|table)
            The prompt text.
        callback (function|string|nil)
            The completion callback, or the default value when omitted.
        default (string|nil)
            The initial input value.

    Returns:
        Deferred|nil
            A deferred handle when no callback function is supplied.

    Example Usage:
        ```lua
        client:requestString("Callsign", "Enter a callsign.", function(value)
            print(value)
        end)
        ```

    Realm:
        Shared
]]
function playerMeta:requestString(title, subTitle, callback, default)
    local d
    if not isfunction(callback) and default == nil then
        default = callback
        d = deferred.new()
        callback = function(value) d:resolve(value) end
    end

    if SERVER then
        self.liaStrReqs = self.liaStrReqs or {}
        local id = table.insert(self.liaStrReqs, callback)
        net.Start("liaStringRequest")
        net.WriteUInt(id, 32)
        net.WriteString(serializeRequestText(title))
        net.WriteString(serializeRequestText(subTitle))
        net.WriteString(default or "")
        net.Send(self)
        return d
    else
        lia.derma.requestString(title, subTitle, callback, default or "")
        return d
    end
end

--[[
    Purpose:
        Requests typed argument input from the player and optionally returns a deferred handle.

    Parameters:
        title (string|table)
            The request title.
        argTypes (table)
            Argument specification data.
        callback (function|nil)
            Runs with the submitted values.

    Returns:
        Deferred|nil
            A deferred handle when no callback function is supplied.

    Example Usage:
        ```lua
        client:requestArguments("Create Item", {
            {"name", "string"},
            {"amount", "number"}
        }, function(values)
            PrintTable(values)
        end)
        ```

    Realm:
        Shared
]]
function playerMeta:requestArguments(title, argTypes, callback)
    local d
    if not isfunction(callback) then
        d = deferred.new()
        callback = function(value) d:resolve(value) end
    end

    if SERVER then
        self.liaArgReqs = self.liaArgReqs or {}
        local id = table.insert(self.liaArgReqs, {
            callback = callback,
            spec = argTypes or {}
        })

        net.Start("liaArgumentsRequest")
        net.WriteUInt(id, 32)
        net.WriteString(serializeRequestText(title))
        net.WriteTable(argTypes or {})
        net.Send(self)
        return d
    else
        lia.derma.requestArguments(title, argTypes, callback)
        return d
    end
end

--[[
    Purpose:
        Prompts the player with a two-option confirmation dialog.

    Parameters:
        question (string|table)
            The prompt text or title, depending on the call form.
        option1 (string|table)
            The first option label or shifted question text.
        option2 (string|table)
            The second option label or shifted first option label.
        manualDismiss (boolean|string|function|nil)
            Whether dismissal is manual, or shifted arguments for the alternate call form.
        callback (function|nil)
            Runs with the chosen response.

    Returns:
        nil

    Example Usage:
        ```lua
        client:requestBinaryQuestion("Delete item?", "Yes", "No", false, function(result)
            print(result)
        end)
        ```

    Realm:
        Shared
]]
function playerMeta:requestBinaryQuestion(question, option1, option2, manualDismiss, callback)
    local title = ""
    if isstring(question) and isstring(option1) and isstring(option2) and (isbool(manualDismiss) or isfunction(manualDismiss)) then
        title = ""
    elseif isstring(question) and isstring(option1) and isstring(option2) and isstring(manualDismiss) and isfunction(callback) then
        title = question
        question = option1
        option1 = option2
        option2 = manualDismiss
        manualDismiss = false
    end

    if SERVER then
        self.liaBinaryReqs = self.liaBinaryReqs or {}
        local id = table.insert(self.liaBinaryReqs, callback)
        net.Start("liaBinaryQuestionRequest")
        net.WriteUInt(id, 32)
        net.WriteString(serializeRequestText(question))
        net.WriteString(serializeRequestText(option1))
        net.WriteString(serializeRequestText(option2))
        net.WriteBool(manualDismiss)
        net.Send(self)
    else
        lia.derma.requestBinaryQuestion(title, question, function(result) if callback then callback(result and 0 or 1) end end, option1, option2)
    end
end

--[[
    Purpose:
        Shows a popup question with a custom button list.

    Parameters:
        question (string|table)
            The prompt text.
        buttons (table)
            Button definitions or labels.

    Returns:
        nil

    Example Usage:
        ```lua
        client:requestPopupQuestion("Select a stance", {
            {"Aggressive", function() print("Aggressive") end},
            {"Defensive", function() print("Defensive") end}
        })
        ```

    Realm:
        Shared
]]
function playerMeta:requestPopupQuestion(question, buttons)
    if SERVER then
        self.liaPopupReqs = self.liaPopupReqs or {}
        local callbacks = {}
        for i, buttonInfo in ipairs(buttons) do
            if istable(buttonInfo) then callbacks[i] = buttonInfo[2] end
        end

        local id = table.insert(self.liaPopupReqs, callbacks)
        net.Start("liaPopupQuestionRequest")
        net.WriteUInt(id, 32)
        net.WriteString(serializeRequestText(question))
        net.WriteUInt(#buttons, 8)
        for _, buttonInfo in ipairs(buttons) do
            local buttonText = istable(buttonInfo) and buttonInfo[1] or tostring(buttonInfo)
            net.WriteString(serializeRequestText(buttonText))
        end

        net.Send(self)
    else
        lia.derma.requestPopupQuestion(question, buttons)
    end
end

--[[
    Purpose:
        Resolves the player's ragdoll entity from netvars, engine state, or client-side fallbacks.

    Returns:
        Entity|nil
            The ragdoll entity when found.

    Example Usage:
        ```lua
        local ragdoll = client:getRagdoll()
        ```

    Realm:
        Shared
]]
function playerMeta:getRagdoll()
    local ragdollValue = self:getNetVar("ragdoll")
    if isnumber(ragdollValue) then
        local ragdoll = Entity(ragdollValue)
        if IsValid(ragdoll) then return ragdoll end
    end

    if isentity(ragdollValue) and IsValid(ragdollValue) then return ragdollValue end
    local gmodRagdoll = self:GetRagdollEntity()
    if IsValid(gmodRagdoll) then return gmodRagdoll end
    if CLIENT then
        if isentity(ragdollValue) and not IsValid(ragdollValue) then
            self.liaNextRagdollDebug = self.liaNextRagdollDebug or 0
            if self.liaNextRagdollDebug < CurTime() then self.liaNextRagdollDebug = CurTime() + 1 end
        end

        for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
            if IsValid(ent) and ent:getNetVar("player") == self then return ent end
        end
    end
    return nil
end

--[[
    Purpose:
        Displays a button-based request to the player.

    Parameters:
        title (string|table)
            The request title.
        buttons (table)
            Button definitions containing text and callbacks.

    Returns:
        nil

    Example Usage:
        ```lua
        client:requestButtons("Choose Option", {
            {text = "Accept", callback = function() print("Accepted") end},
            {text = "Decline", callback = function() print("Declined") end}
        })
        ```

    Realm:
        Shared
]]
function playerMeta:requestButtons(title, buttons)
    if SERVER then
        self.buttonRequests = self.buttonRequests or {}
        local labels = {}
        local callbacks = {}
        for i, data in ipairs(buttons) do
            labels[i] = data.text or data[1] or ""
            callbacks[i] = data.callback or data[2]
        end

        local id = table.insert(self.buttonRequests, callbacks)
        net.Start("liaButtonRequest")
        net.WriteUInt(id, 32)
        net.WriteString(serializeRequestText(title))
        net.WriteUInt(#labels, 8)
        for _, lbl in ipairs(labels) do
            net.WriteString(serializeRequestText(lbl))
        end

        net.Send(self)
    else
        lia.derma.requestButtons(title, buttons)
    end
end

--[[
    Purpose:
        Checks whether the player is currently stuck in solid space.

    Returns:
        boolean
            `true` when the player's hull starts inside solid geometry.

    Example Usage:
        ```lua
        if client:isStuck() then print("Player is stuck.") end
        ```

    Realm:
        Shared
]]
function playerMeta:isStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
end

--[[
    Purpose:
        Shows a dropdown request to the player.

    Parameters:
        title (string|table)
            The request title.
        subTitle (string|table)
            Supporting prompt text.
        options (table|nil)
            Allowed dropdown options.
        callback (function|nil)
            Runs with the selected result.

    Returns:
        nil

    Example Usage:
        ```lua
        client:requestDropdown("Faction", "Choose a faction.", {"Citizen", "Worker"}, function(choice)
            print(choice)
        end)
        ```

    Realm:
        Shared
]]
function playerMeta:requestDropdown(title, subTitle, options, callback)
    if SERVER then
        self.liaDropdownReqs = self.liaDropdownReqs or {}
        local id = table.insert(self.liaDropdownReqs, {
            callback = callback,
            allowed = options or {}
        })

        net.Start("liaRequestDropdown")
        net.WriteUInt(id, 32)
        net.WriteString(serializeRequestText(title))
        net.WriteString(serializeRequestText(subTitle))
        net.WriteTable(options or {})
        net.Send(self)
    else
        lia.derma.requestDropdown(title, subTitle, options, callback)
    end
end

if SERVER then
    --[[
        Purpose:
            Restores stamina up to the character's maximum and clears the breathing flag when recovery is sufficient.

        Parameters:
            amount (number)
                The amount of stamina to restore.

        Returns:
            nil

        Example Usage:
            ```lua
            client:restoreStamina(15)
            ```

        Realm:
            Server
    ]]
    function playerMeta:restoreStamina(amount)
        local char = self:getChar()
        local maxStamina = char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
        local current = self:getLocalVar("stamina", maxStamina)
        local value = math.Clamp(current + amount, 0, maxStamina)
        if current ~= value then self:setLocalVar("stamina", value) end
        if value >= maxStamina * 0.25 and self:getLocalVar("brth", false) then
            self:setLocalVar("brth", nil)
            hook.Run("PlayerStaminaGained", self)
        end
    end

    --[[
        Purpose:
            Reduces stamina and marks the player as out of breath when it reaches zero.

        Parameters:
            amount (number)
                The amount of stamina to consume.

        Returns:
            nil

        Example Usage:
            ```lua
            client:consumeStamina(10)
            ```

        Realm:
            Server
    ]]
    function playerMeta:consumeStamina(amount)
        local char = self:getChar()
        local max = char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
        local current = self:getLocalVar("stamina", max)
        local value = math.Clamp(current - amount, 0, max)
        if current ~= value then
            self:setLocalVar("stamina", value)
            if value == 0 and not self:getLocalVar("brth", false) then
                self:setLocalVar("brth", true)
                hook.Run("PlayerStaminaLost", self)
            end
        end
    end

    --[[
        Purpose:
            Adds money to the active character and records the change in the money log.

        Parameters:
            amount (number)
                The amount to add, which may be negative.

        Returns:
            boolean
                `false` if no active character exists, otherwise `true`.

        Example Usage:
            ```lua
            client:addMoney(250)
            ```

        Realm:
            Server
    ]]
    function playerMeta:addMoney(amount)
        local character = self:getChar()
        if not character then return false end
        local currentMoney = character:getMoney()
        local totalMoney = currentMoney + amount
        character:setMoney(totalMoney)
        lia.log.add(self, "money", amount)
        return true
    end

    --[[
        Purpose:
            Removes money from the active character.

        Parameters:
            amount (number)
                The amount to remove.

        Returns:
            nil

        Example Usage:
            ```lua
            client:takeMoney(100)
            ```

        Realm:
            Server
    ]]
    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end

    --[[
        Purpose:
            Loads persistent Lilia player data from the database or creates a fresh row when none exists.

        Parameters:
            callback (function|nil)
                Runs after the data table has been loaded or initialized.

        Returns:
            nil

        Example Usage:
            ```lua
            client:loadLiliaData(function(data)
                PrintTable(data)
            end)
            ```

        Realm:
            Server
    ]]
    function playerMeta:loadLiliaData(callback)
        local name = self:steamName()
        local steamID = self:SteamID()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.db.query("SELECT data, firstJoin, lastJoin, lastIP, lastOnline, totalOnlineTime FROM lia_players WHERE steamID = " .. lia.db.convertDataType(steamID), function(data)
            if IsValid(self) and data and data[1] and data[1].data then
                lia.db.updateTable({
                    lastJoin = timeStamp,
                }, nil, "players", "steamID = " .. lia.db.convertDataType(steamID))

                self.firstJoin = data[1].firstJoin or timeStamp
                self.lastJoin = data[1].lastJoin or timeStamp
                self.liaData = util.JSONToTable(data[1].data)
                if self.liaData and self.liaData.mainCharacter and istable(self.liaData.mainCharacter) and self.liaData.mainCharacterSetTime then self.liaData.mainCharacterSetTime = nil end
                self.totalOnlineTime = tonumber(data[1].totalOnlineTime) or self:getLiliaData("totalOnlineTime", 0)
                local default = os.time(lia.time.toNumber(self.lastJoin))
                self.lastOnline = tonumber(data[1].lastOnline) or self:getLiliaData("lastOnline", default)
                self.lastIP = data[1].lastIP or self:getLiliaData("lastIP")
                if callback then callback(self.liaData) end
            else
                lia.db.insertTable({
                    steamID = steamID,
                    steamName = name,
                    firstJoin = timeStamp,
                    lastJoin = timeStamp,
                    userGroup = lia.admin.getDefaultUserGroup(),
                    data = {},
                    lastIP = "",
                    lastOnline = os.time(lia.time.toNumber(timeStamp)),
                    totalOnlineTime = 0
                }, nil, "players")

                if callback then callback({}) end
            end
        end)
    end

    --[[
        Purpose:
            Saves the player's Lilia profile data and updates session tracking fields.

        Returns:
            nil

        Example Usage:
            ```lua
            client:saveLiliaData()
            ```

        Realm:
            Server
    ]]
    function playerMeta:saveLiliaData()
        if self:IsBot() then return end
        local name = self:steamName()
        local steamID = self:SteamID()
        local currentTime = os.time()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", currentTime)
        local stored = self:getLiliaData("totalOnlineTime", 0)
        local session = RealTime() - (self.liaJoinTime or RealTime())
        self:setLiliaData("totalOnlineTime", stored + session, true, true)
        self:setLiliaData("lastOnline", currentTime, true, true)
        lia.db.updateTable({
            steamName = name,
            lastJoin = timeStamp,
            data = self.liaData,
            lastIP = self:getLiliaData("lastIP", ""),
            lastOnline = currentTime,
            totalOnlineTime = stored + session
        }, nil, "players", "steamID = " .. lia.db.convertDataType(steamID))
    end

    --[[
        Purpose:
            Stores one Lilia profile value, optionally syncing it and optionally saving immediately.

        Parameters:
            key (string)
                The data key to write.
            value (any)
                The value to store.
            noNetworking (boolean|nil)
                Whether to skip sending the updated value to the player.
            noSave (boolean|nil)
                Whether to skip immediate persistence.

        Returns:
            nil

        Example Usage:
            ```lua
            client:setLiliaData("title", "Quartermaster")
            ```

        Realm:
            Server
    ]]
    function playerMeta:setLiliaData(key, value, noNetworking, noSave)
        self.liaData = self.liaData or {}
        self.liaData[key] = value
        if not noNetworking then
            net.Start("liaDataSync")
            net.WriteString(key)
            net.WriteType(value)
            net.Send(self)
        end

        if not noSave then self:saveLiliaData() end
    end

    --[[
        Purpose:
            Records a ban entry in the database and kicks the player with the localized ban message.

        Parameters:
            reason (string|nil)
                The ban reason.
            duration (number|nil)
                The duration value used by the localized message.
            banner (Player|nil)
                The staff member issuing the ban.

        Returns:
            nil

        Example Usage:
            ```lua
            client:banPlayer("Mass RDM", 1440, admin)
            ```

        Realm:
            Server
    ]]
    function playerMeta:banPlayer(reason, duration, banner)
        local steamID = self:SteamID()
        lia.db.insertTable({
            player = self:Name(),
            playerSteamID = steamID,
            reason = reason or L("genericReason"),
            bannerName = IsValid(banner) and banner:Name() or "",
            bannerSteamID = IsValid(banner) and banner:SteamID() or "",
            timestamp = os.time(),
            evidence = ""
        }, nil, "bans")

        self:Kick(L("banMessage", duration or 0, reason or L("genericReason")))
    end

    --[[
        Purpose:
            Returns the player's total playtime, honoring hook overrides and active session time.

        Returns:
            number
                The total playtime in seconds.

        Example Usage:
            ```lua
            print(client:getPlayTime())
            ```

        Realm:
            Server
    ]]
    function playerMeta:getPlayTime()
        local hookResult = hook.Run("GetPlayTime", self)
        if hookResult ~= nil then return hookResult end
        local char = self:getChar()
        if char then
            local loginTime = char:getLoginTime() or os.time()
            return char:getPlayTime() + os.time() - loginTime
        end

        local diff = os.time(lia.time.toNumber(self.lastJoin)) - os.time(lia.time.toNumber(self.firstJoin))
        return diff + RealTime() - (self.liaJoinTime or RealTime())
    end

    --[[
        Purpose:
            Creates a physics ragdoll copy of the player, optionally frozen in place.

        Parameters:
            freeze (boolean|nil)
                Whether the ragdoll's physics objects should be immobile.

        Returns:
            Entity
                The created ragdoll entity.

        Example Usage:
            ```lua
            local ragdoll = client:createRagdoll()
            ```

        Realm:
            Server
    ]]
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

    --[[
        Purpose:
            Toggles the player's ragdolled state, including weapon storage, movement locking, and timed recovery handling.

        Parameters:
            state (boolean)
                Whether to ragdoll or restore the player.
            time (number|nil)
                Optional duration before automatic recovery.
            getUpGrace (number|nil)
                Optional grace period before the player may stand up again.

        Returns:
            nil

        Example Usage:
            ```lua
            client:setRagdolled(true, 10)
            ```

        Realm:
            Server
    ]]
    function playerMeta:setRagdolled(state, time, getUpGrace)
        getUpGrace = getUpGrace or time or 5
        if state and time and time > 0 then time = hook.Run("GetRagdollTime", self, time) or time end
        if state then
            if IsValid(self.Ragdoll) then self.Ragdoll:Remove() end
            local existingGmodRagdoll = self:GetRagdollEntity()
            if IsValid(existingGmodRagdoll) then
                existingGmodRagdoll.liaIgnoreDelete = true
                SafeRemoveEntity(existingGmodRagdoll)
            end

            local entity = self:createRagdoll()
            entity:SetNoDraw(false)
            entity:DrawShadow(true)
            entity:SetRenderMode(RENDERMODE_NORMAL)
            entity:SetColor(Color(255, 255, 255, 255))
            entity:setNetVar("player", self)
            entity:CallOnRemove("fixer", function()
                if IsValid(self) then
                    self:setLocalVar("blur", nil)
                    self:setNetVar("ragdoll", nil)
                    if not entity.NoReset then self:SetPos(entity:GetPos()) end
                    self:SetNoDraw(false)
                    self:SetNotSolid(false)
                    self:Freeze(false)
                    self:SetMoveType(MOVETYPE_WALK)
                    self:SetLocalVelocity(IsValid(entity) and entity.LastVelocity or vector_origin)
                end

                if IsValid(self) and not entity.IgnoreDelete then
                    if entity.Weapons then
                        for k, v in ipairs(entity.Weapons) do
                            self:Give(v)
                            if entity.Ammo then
                                for k2, v2 in ipairs(entity.Ammo) do
                                    if v == v2[1] then self:SetAmmo(v2[2], tostring(k2)) end
                                end
                            end
                        end

                        for k, v in ipairs(self:GetWeapons()) do
                            v:SetClip1(0)
                        end
                    end

                    if self:isStuck() then
                        entity:DropToFloor()
                        self:SetPos(entity:GetPos() + Vector(0, 0, 16))
                        local positions = lia.util.findEmptySpace(self, {entity, self})
                        for k, v in ipairs(positions) do
                            self:SetPos(v)
                            if not self:isStuck() then return end
                        end
                    end
                end
            end)

            self:setLocalVar("blur", 25)
            self.Ragdoll = entity
            self:setNetVar("ragdoll", entity:EntIndex())
            entity.Weapons = {}
            entity.Ammo = {}
            entity.Player = self
            if getUpGrace then entity.Grace = CurTime() + getUpGrace end
            if time and time > 0 then
                entity.Start = CurTime()
                entity.Finish = entity.Start + time
                self:setAction("@wakingUp", nil, nil, entity.Start, entity.Finish)
            end

            for k, v in ipairs(self:GetWeapons()) do
                entity.Weapons[#entity.Weapons + 1] = v:GetClass()
                local clip = v:Clip1()
                local reserve = self:GetAmmoCount(v:GetPrimaryAmmoType())
                local ammo = clip + reserve
                entity.Ammo[v:GetPrimaryAmmoType()] = {v:GetClass(), ammo}
            end

            self:GodDisable()
            self:StripWeapons()
            self:Freeze(true)
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            self:SetMoveType(MOVETYPE_NONE)
            if time then
                local uniqueID = "UnRagdoll" .. self:SteamID()
                timer.Create(uniqueID, 0.33, 0, function()
                    if IsValid(entity) and IsValid(self) then
                        local velocity = entity:GetVelocity()
                        entity.LastVelocity = velocity
                        self:SetPos(entity:GetPos())
                        if velocity:Length2D() >= 8 then
                            if not entity.Pausing then
                                self:setAction()
                                entity.Pausing = true
                            end
                            return
                        elseif entity.Pausing then
                            self:setAction("@wakingUp", time)
                            entity.Pausing = false
                        end

                        time = time - 0.33
                        if time <= 0 then entity:Remove() end
                    else
                        timer.Remove(uniqueID)
                    end
                end)
            end

            hook.Run("OnCharFallover", self, entity, true)
        else
            local rag = self.Ragdoll
            if IsValid(rag) then rag:Remove() end
            self:setLocalVar("blur", nil)
            self:setNetVar("ragdoll", nil)
            self:SetNoDraw(false)
            self:SetNotSolid(false)
            self:Freeze(false)
            self:SetMoveType(MOVETYPE_WALK)
            hook.Run("OnCharFallover", self, rag, false)
        end
    end

    --[[
        Purpose:
            Sends all current global, entity, and local netvars to the player.

        Returns:
            nil

        Example Usage:
            ```lua
            client:syncVars()
            ```

        Realm:
            Server
    ]]
    function playerMeta:syncVars()
        for entity, data in pairs(lia.net) do
            if entity == "globals" then
                for k, v in pairs(data) do
                    net.Start("liaGlobalVar")
                    net.WriteString(k)
                    net.WriteType(v)
                    net.Send(self)
                end
            elseif IsValid(entity) then
                for k, v in pairs(data) do
                    net.Start("liaNetVar")
                    net.WriteUInt(entity:EntIndex(), 16)
                    net.WriteString(k)
                    net.WriteType(v)
                    net.Send(self)
                end
            end
        end

        if lia.net.locals[self] then
            for k, v in pairs(lia.net.locals[self]) do
                net.Start("liaNetLocal")
                net.WriteString(k)
                net.WriteType(v)
                net.Send(self)
            end
        end
    end

    --[[
        Purpose:
            Stores a replicated netvar for the player and broadcasts the change.

        Parameters:
            key (string)
                The netvar key.
            value (any)
                The value to assign.

        Returns:
            nil

        Example Usage:
            ```lua
            client:setNetVar("char", 15)
            ```

        Realm:
            Server
    ]]
    function playerMeta:setNetVar(key, value)
        if lia.net.checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        if oldValue == value then return end
        lia.net[self][key] = value
        net.Start("liaNetVar")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(key)
        net.WriteType(value)
        net.Broadcast()
        if not self:IsBot() then
            net.Start("liaNetLocal")
            net.WriteString(key)
            net.WriteType(value)
            net.Send(self)
        end

        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    --[[
        Purpose:
            Stores a local-only netvar for the player and syncs it to that player.

        Parameters:
            key (string)
                The local netvar key.
            value (any)
                The value to assign.

        Returns:
            nil

        Example Usage:
            ```lua
            client:setLocalVar("stamina", 75)
            ```

        Realm:
            Server
    ]]
    function playerMeta:setLocalVar(key, value)
        if not IsValid(self) then return end
        if lia.net.checkBadType(key, value) then return end
        lia.net.locals[self] = lia.net.locals[self] or {}
        local oldValue = lia.net.locals[self][key]
        if oldValue == value and not istable(value) then return end
        lia.net.locals[self][key] = value
        if not lia.shuttingDown then
            net.Start("liaNetLocal")
            net.WriteString(key)
            net.WriteType(value)
            net.Send(self)
        end

        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    --[[
        Purpose:
            Returns a server-side local netvar with a default fallback.

        Parameters:
            key (string)
                The local netvar key.
            default (any)
                The fallback value when the key is missing.

        Returns:
            any
                The stored local value or the default.

        Example Usage:
            ```lua
            local stamina = client:getLocalVar("stamina", 100)
            ```

        Realm:
            Server
    ]]
    function playerMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        if lia.net.locals[self] and lia.net.locals[self][key] ~= nil then return lia.net.locals[self][key] end
        return default
    end
else
    --[[
        Purpose:
            Returns a client-side local netvar cache entry with a fallback default.

        Parameters:
            key (string)
                The local netvar key.
            default (any)
                The fallback value when the key is missing.

        Returns:
            any
                The cached local value or the default.

        Example Usage:
            ```lua
            local blurAmount = LocalPlayer():getLocalVar("blur", 0)
            ```

        Realm:
            Client
    ]]
    function playerMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        local idx = self:EntIndex()
        if lia.net[idx] and lia.net[idx][key] ~= nil then return lia.net[idx][key] end
        return default
    end

    --[[
        Purpose:
            Returns the player's total playtime on the client using replicated character and session data.

        Returns:
            number
                The total playtime in seconds.

        Example Usage:
            ```lua
            print(LocalPlayer():getPlayTime())
            ```

        Realm:
            Client
    ]]
    function playerMeta:getPlayTime()
        local hookResult = hook.Run("GetPlayTime", self)
        if hookResult ~= nil then return hookResult end
        local char = self:getChar()
        if char then
            local loginTime = char:getLoginTime() or os.time()
            return char:getPlayTime() + os.time() - loginTime
        end

        local diff = os.time(lia.time.toNumber(lia.lastJoin)) - os.time(lia.time.toNumber(lia.firstJoin))
        return diff + RealTime() - (lia.joinTime or 0)
    end
end
