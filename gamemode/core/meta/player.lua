--[[
    Folder: Meta
    File:  player.md
]]
--[[
    Player

    Player management system for the Lilia framework.
]]
--[[
    Overview:
        The player meta table provides comprehensive functionality for managing player data, interactions, and operations in the Lilia framework. It handles player character access, notification systems, permission checking, data management, interaction systems, and player-specific operations. The meta table operates on both server and client sides, with the server managing player data and validation while the client provides player interaction and display. It includes integration with the character system for character access, notification system for player messages, permission system for access control, data system for player persistence, and interaction system for player actions. The meta table ensures proper player data synchronization, permission validation, notification delivery, and comprehensive player management from connection to disconnection.
]]
local playerMeta = FindMetaTable("Player")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    --[[
    Purpose:
        Returns the active character object associated with this player.

    When Called:
        Use whenever you need the player's character state.

    Parameters:
        None.

    Returns:
        table|nil
            Character instance or nil if none is selected.

    Realm:
        Shared

    Example Usage:
        ```lua
            local char = ply:getChar()
        ```
]]
    function playerMeta:getChar()
        return lia.char.getCharacter(self.getNetVar(self, "char"), self)
    end

    --[[
    Purpose:
        Builds a readable name for the player preferring character name.

    When Called:
        Use for logging or UI when displaying player identity.

    Parameters:
        None.

    Returns:
        string
            Character name if available, otherwise Steam name.

    Realm:
        Shared

    Example Usage:
        ```lua
            print(ply:tostring())
        ```
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
        Returns the display name, falling back to Steam name if no character.

    When Called:
        Use wherever Garry's Mod expects Name/Nick/GetName.

    Parameters:
        None.

    Returns:
        string
            Character or Steam name.

    Realm:
        Shared

    Example Usage:
        ```lua
            local name = ply:Name()
        ```
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
        Restarts a gesture animation and replicates it.

    When Called:
        Use to play a gesture on the player and sync to others.

    Parameters:
        a (number)
            Gesture activity.
        b (number)
            Layer or slot.
        c (number)
            Playback rate or weight.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:doGesture(ACT_GMOD_GESTURE_WAVE, 0, 1)
        ```
]]
function playerMeta:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    netstream.Start(self:GetPos(), "liaSyncGesture", self, a, b, c)
end

--[[
    Purpose:
        Shows an action bar for the player and runs a callback when done.

    When Called:
        Use to gate actions behind a timed progress bar.

    Parameters:
        text (string|nil)
            Message to display; nil cancels the bar.
        time (number)
            Duration in seconds.
        callback (function|nil)
            Invoked when the timer completes.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:setAction("Lockpicking", 5, onFinish)
        ```
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
        Runs a callback after the player stares at an entity for a duration.

    When Called:
        Use for interactions requiring sustained aim on a target.

    Parameters:
        entity (Entity)
            Target entity to watch.
        callback (function)
            Function called after staring completes.
        time (number)
            Duration in seconds required.
        onCancel (function|nil)
            Called if the stare is interrupted.
        distance (number|nil)
            Max distance trace length.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:doStaredAction(door, onComplete, 3)
        ```
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
        Cancels any active action or stare timers and hides the bar.

    When Called:
        Use when an action is interrupted or completed early.

    Parameters:
        None.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:stopAction()
        ```
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
        Checks if the player has a specific admin privilege.

    When Called:
        Use before allowing privileged actions.

    Parameters:
        privilegeName (string)
            Permission to query.

    Returns:
        boolean
            True if the player has access.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:hasPrivilege("canBan") then ...
        ```
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
        Deletes the player's ragdoll entity and clears the net var.

    When Called:
        Use when respawning or cleaning up ragdolls.

    Parameters:
        None.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:removeRagdoll()
        ```
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
        Returns the active weapon and matching inventory item if equipped.

    When Called:
        Use when syncing weapon state with inventory data.

    Parameters:
        None.

    Returns:
        Weapon|nil, Item|nil
            Active weapon entity and corresponding item, if found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local wep, itm = ply:getItemWeapon()
        ```
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
        Detects whether the account is being used via Steam Family Sharing.

    When Called:
        Use for restrictions or messaging on shared accounts.

    Parameters:
        None.

    Returns:
        boolean
            True if OwnerSteamID64 differs from SteamID.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:isFamilySharedAccount() then warn() end
        ```
]]
function playerMeta:isFamilySharedAccount()
    return util.SteamIDFrom64(self:OwnerSteamID64()) ~= self:SteamID()
end

--[[
    Purpose:
        Calculates a suitable position in front of the player to drop items.

    When Called:
        Use before spawning a world item.

    Parameters:
        None.

    Returns:
        Vector
            Drop position.

    Realm:
        Shared

    Example Usage:
        ```lua
            local pos = ply:getItemDropPos()
        ```
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
        Retrieves the player's inventory items if a character exists.

    When Called:
        Use when accessing a player's item list directly.

    Parameters:
        None.

    Returns:
        table|nil
            Items table or nil if no inventory.

    Realm:
        Shared

    Example Usage:
        ```lua
            local items = ply:getItems()
        ```
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
        Returns the entity the player is aiming at within a distance.

    When Called:
        Use for interaction traces.

    Parameters:
        distance (number)
            Max trace length; default 96.

    Returns:
        Entity|nil
            Hit entity or nil.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ent = ply:getTracedEntity(128)
        ```
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
        Sends a notification to this player (or locally on client).

    When Called:
        Use to display a generic notice.

    Parameters:
        message (string)
            Text to show.
        notifType (string)
            Optional type key.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notify("Hello")
        ```
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
        Sends a localized notification to this player or locally.

    When Called:
        Use when the message is a localization token.

    Parameters:
        message (string)
            Localization key.
        notifType (string)
            Optional type key.
        ... (any)
            Format arguments.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyLocalized("itemTaken", "apple")
        ```
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
        Sends an error notification to this player or locally.

    When Called:
        Use to display error messages in a consistent style.

    Parameters:
        message (string)
            Error text.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyError("Invalid action")
        ```
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
        Sends a warning notification to this player or locally.

    When Called:
        Use for cautionary messages.

    Parameters:
        message (string)
            Text to display.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyWarning("Low health")
        ```
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
        Sends an info notification to this player or locally.

    When Called:
        Use for neutral informational messages.

    Parameters:
        message (string)
            Text to display.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyInfo("Quest updated")
        ```
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
        Sends a success notification to this player or locally.

    When Called:
        Use to indicate successful actions.

    Parameters:
        message (string)
            Text to display.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifySuccess("Saved")
        ```
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
        Sends a money-themed notification to this player or locally.

    When Called:
        Use for currency gain/spend messages.

    Parameters:
        message (string)
            Text to display.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyMoney("+$50")
        ```
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
        Sends an admin-level notification to this player or locally.

    When Called:
        Use for staff-oriented alerts.

    Parameters:
        message (string)
            Text to display.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyAdmin("Ticket opened")
        ```
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
        Sends a localized error notification to the player or locally.

    When Called:
        Use for localized error tokens.

    Parameters:
        key (string)
            Localization key.
        ... (any)
            Format args.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyErrorLocalized("invalidArg")
        ```
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
        Sends a localized warning notification to the player or locally.

    When Called:
        Use for localized warnings.

    Parameters:
        key (string)
            Localization key.
        ... (any)
            Format args.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyWarningLocalized("lowHealth")
        ```
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
        Sends a localized info notification to the player or locally.

    When Called:
        Use for localized informational messages.

    Parameters:
        key (string)
            Localization key.
        ... (any)
            Format args.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyInfoLocalized("questUpdate")
        ```
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
        Sends a localized success notification to the player or locally.

    When Called:
        Use for localized success confirmations.

    Parameters:
        key (string)
            Localization key.
        ... (any)
            Format args.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifySuccessLocalized("saved")
        ```
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
        Sends a localized money notification to the player or locally.

    When Called:
        Use for localized currency messages.

    Parameters:
        key (string)
            Localization key.
        ... (any)
            Format args.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyMoneyLocalized("moneyGained", 50)
        ```
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
        Sends a localized admin notification to the player or locally.

    When Called:
        Use for staff messages with localization.

    Parameters:
        key (string)
            Localization key.
        ... (any)
            Format args.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:notifyAdminLocalized("ticketOpened")
        ```
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
        Checks if the player can edit a vendor.

    When Called:
        Use before opening vendor edit interfaces.

    Parameters:
        vendor (Entity)
            Vendor entity to check.

    Returns:
        boolean
            True if editing is permitted.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:canEditVendor(vendor) then ...
        ```
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
        Determines if the player's user group is marked as Staff.

    When Called:
        Use for gating staff-only features.

    Parameters:
        None.

    Returns:
        boolean
            True if their usergroup includes the Staff type.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:isStaff() then ...
        ```
]]
function playerMeta:isStaff()
    return groupHasType(self:GetUserGroup(), "Staff")
end

--[[
    Purpose:
        Checks if the player is currently on the staff faction.

    When Called:
        Use when features apply only to on-duty staff.

    Parameters:
        None.

    Returns:
        boolean
            True if the player is in FACTION_STAFF.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:isStaffOnDuty() then ...
        ```
]]
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

--[[
    Purpose:
        Checks if the player has whitelist access to a faction.

    When Called:
        Use before allowing faction selection.

    Parameters:
        faction (number)
            Faction ID.

    Returns:
        boolean
            True if default or whitelisted.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:hasWhitelist(factionID) then ...
        ```
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
        Retrieves the class table for the player's current character.

    When Called:
        Use when needing class metadata like limits or permissions.

    Parameters:
        None.

    Returns:
        table|nil
            Class definition or nil if unavailable.

    Realm:
        Shared

    Example Usage:
        ```lua
            local classData = ply:getClassData()
        ```
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
        Provides DarkRP compatibility for money queries.

    When Called:
        Use when DarkRP expects getDarkRPVar("money").

    Parameters:
        var (string)
            Variable name, only "money" supported.

    Returns:
        number|nil
            Character money or nil if unsupported var.

    Realm:
        Shared

    Example Usage:
        ```lua
            local cash = ply:getDarkRPVar("money")
        ```
]]
function playerMeta:getDarkRPVar(var)
    if var ~= "money" then return end
    local char = self:getChar()
    return char:getMoney()
end

--[[
    Purpose:
        Returns the character's money or zero if unavailable.

    When Called:
        Use whenever reading player currency.

    Parameters:
        None.

    Returns:
        number
            Current money amount.

    Realm:
        Shared

    Example Usage:
        ```lua
            local cash = ply:getMoney()
        ```
]]
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--[[
    Purpose:
        Returns whether the player can afford a cost.

    When Called:
        Use before charging the player.

    Parameters:
        amount (number)
            Cost to check.

    Returns:
        boolean
            True if the player has enough money.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:canAfford(100) then ...
        ```
]]
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--[[
    Purpose:
        Checks if the player meets a specific skill level requirement.

    When Called:
        Use for gating actions behind skills.

    Parameters:
        skill (string)
            Attribute key.
        level (number)
            Required level.

    Returns:
        boolean
            True if the player meets or exceeds the level.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:hasSkillLevel("lockpick", 3) then ...
        ```
]]
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--[[
    Purpose:
        Verifies all required skills meet their target levels.

    When Called:
        Use when checking multiple skill prerequisites.

    Parameters:
        requiredSkillLevels (table)
            Map of skill keys to required levels.

    Returns:
        boolean
            True if all requirements pass.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:meetsRequiredSkills(reqs) then ...
        ```
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
        Forces the player to play a sequence and freezes movement if needed.

    When Called:
        Use for scripted animations like sit or interact sequences.

    Parameters:
        sequenceName (string|nil)
            Sequence to play; nil clears the current sequence.
        callback (function|nil)
            Called when the sequence ends.
        time (number|nil)
            Override duration.
        noFreeze (boolean)
            Prevent movement freeze when true.

    Returns:
        number|boolean|nil
            Duration when started, false on failure, or nil when clearing.

    Realm:
        Shared

    Example Usage:
        ```lua
            ply:forceSequence("sit", nil, 5)
        ```
]]
function playerMeta:forceSequence(sequenceName, callback, time, noFreeze)
    hook.Run("OnPlayerEnterSequence", self, sequenceName, callback, time, noFreeze)
    if not sequenceName then
        net.Start("liaSeqSet")
        net.WriteEntity(self)
        net.WriteBool(false)
        net.Broadcast()
        return
    end

    local seqId = self:LookupSequence(sequenceName)
    if seqId and seqId > 0 then
        local dur = time or self:SequenceDuration(seqId)
        if isfunction(callback) then
            self.liaSeqCallback = callback
        else
            self.liaSeqCallback = nil
        end

        self.liaForceSeq = seqId
        if not noFreeze then self:SetMoveType(MOVETYPE_NONE) end
        if dur > 0 then timer.Create("liaSeq" .. self:EntIndex(), dur, 1, function() if IsValid(self) then self:leaveSequence() end end) end
        net.Start("liaSeqSet")
        net.WriteEntity(self)
        net.WriteBool(true)
        net.WriteInt(seqId, 16)
        net.Broadcast()
        return dur
    end
    return false
end

--[[
    Purpose:
        Stops the forced sequence, unfreezes movement, and runs callbacks.

    When Called:
        Use when a sequence finishes or must be cancelled.

    Parameters:
        None.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:leaveSequence()
        ```
]]
function playerMeta:leaveSequence()
    hook.Run("OnPlayerLeaveSequence", self)
    net.Start("liaSeqSet")
    net.WriteEntity(self)
    net.WriteBool(false)
    net.Broadcast()
    self:SetMoveType(MOVETYPE_WALK)
    self.liaForceSeq = nil
    if isfunction(self.liaSeqCallback) then self.liaSeqCallback() end
    self.liaSeqCallback = nil
end

--[[
    Purpose:
        Returns the flag string from the player's character.

    When Called:
        Use when checking player permissions.

    Parameters:
        None.

    Returns:
        string
            Concatenated flags or empty string.

    Realm:
        Shared

    Example Usage:
        ```lua
            local flags = ply:getFlags()
        ```
]]
function playerMeta:getFlags()
    local char = self:getChar()
    return char and char:getFlags() or ""
end

--[[
    Purpose:
        Grants one or more flags to the player's character.

    When Called:
        Use when adding privileges.

    Parameters:
        flags (string)
            Flags to give.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:giveFlags("z")
        ```
]]
function playerMeta:giveFlags(flags)
    local char = self:getChar()
    if char then char:giveFlags(flags) end
end

--[[
    Purpose:
        Removes flags from the player's character.

    When Called:
        Use when revoking privileges.

    Parameters:
        flags (string)
            Flags to remove.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:takeFlags("z")
        ```
]]
function playerMeta:takeFlags(flags)
    local char = self:getChar()
    if char then char:takeFlags(flags) end
end

--[[
    Purpose:
        Synchronizes or applies a bone animation state across server/client.

    When Called:
        Use when enabling or disabling custom bone angles.

    Parameters:
        active (boolean)
            Whether the animation is active.
        boneData (table)
            Map of bone names to Angle values.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:networkAnimation(true, bones)
        ```
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
        Returns the table storing Lilia-specific player data.

    When Called:
        Use when reading or writing persistent player data.

    Parameters:
        None.

    Returns:
        table
            Data table per realm.

    Realm:
        Shared

    Example Usage:
        ```lua
            local data = ply:getAllLiliaData()
        ```
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
        Sets a waypoint for the player and draws HUD guidance clientside.

    When Called:
        Use when directing a player to a position or objective.

    Parameters:
        name (string)
            Label shown on the HUD.
        vector (Vector)
            Target world position.
        logo (string|nil)
            Optional material path for the icon.
        onReach (function|nil)
            Callback fired when the waypoint is reached.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:setWaypoint("Stash", pos)
        ```
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
        Reads stored Lilia player data, returning a default when missing.

    When Called:
        Use for persistent per-player data such as settings or cooldowns.

    Parameters:
        key (string)
            Data key to fetch.
        default (any)
            Value to return when unset.

    Returns:
        any
            Stored value or default.

    Realm:
        Shared

    Example Usage:
        ```lua
            local last = ply:getLiliaData("lastIP", "")
        ```
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
        Returns the player's recorded main character ID, if set.

    When Called:
        Use to highlight or auto-select the main character.

    Parameters:
        None.

    Returns:
        number|nil
            Character ID or nil when unset.

    Realm:
        Shared

    Example Usage:
        ```lua
            local main = ply:getMainCharacter()
        ```
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
        Sets the player's main character, applying cooldown rules server-side.

    When Called:
        Use when a player picks or clears their main character.

    Parameters:
        charID (number|nil)
            Character ID to set, or nil/0 to clear.

    Returns:
        boolean, string|nil
            True on success, or false with a reason.

    Realm:
        Shared

    Example Usage:
        ```lua
            ply:setMainCharacter(charID)
        ```
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
        Checks if the player (via their character) has any of the given flags.

    When Called:
        Use when gating actions behind flag permissions.

    Parameters:
        flags (string)
            One or more flag characters to test.

    Returns:
        boolean
            True if at least one flag is present.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:hasFlags("z") then ...
        ```
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
        Returns true if the player's recorded playtime exceeds a value.

    When Called:
        Use for requirements based on time played.

    Parameters:
        time (number)
            Threshold in seconds.

    Returns:
        boolean
            True if playtime is greater than the threshold.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ply:playTimeGreaterThan(3600) then ...
        ```
]]
function playerMeta:playTimeGreaterThan(time)
    local playTime = self:getPlayTime()
    if not playTime or not time then return false end
    return playTime > time
end

--[[
    Purpose:
        Presents a list of options to the player and returns selected values.

    When Called:
        Use for multi-choice prompts that may return multiple selections.

    Parameters:
        title (string)
            Dialog title.
        subTitle (string)
            Subtitle/description.
        options (table)
            Array of option labels.
        limit (number)
            Max selections allowed.
        callback (function)
            Called with selections when chosen.

    Returns:
        deferred|nil
            Promise when callback omitted, otherwise nil.

    Realm:
        Shared

    Example Usage:
        ```lua
            ply:requestOptions("Pick", "Choose one", {"A","B"}, 1, cb)
        ```
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
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options or {})
        net.WriteUInt(tonumber(limit) or 1, 32)
        net.Send(self)
    else
        lia.derma.requestOptions(title, subTitle, options, tonumber(limit) or 1, callback, onCancel)
    end
end

--[[
    Purpose:
        Prompts the player for a string value and returns it.

    When Called:
        Use when collecting free-form text input.

    Parameters:
        title (string)
        subTitle (string)
        callback (function|nil)
            Receives the string result; optional if using deferred.
        default (string|nil)
            Prefilled value.

    Returns:
        deferred|nil
            Promise when callback omitted, otherwise nil.

    Realm:
        Shared

    Example Usage:
        ```lua
            ply:requestString("Name", "Enter name", onDone)
        ```
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
        net.WriteString(title)
        net.WriteString(subTitle)
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
        Requests typed arguments from the player based on a specification.

    When Called:
        Use for admin commands requiring typed input.

    Parameters:
        title (string)
            Dialog title.
        argTypes (table)
            Schema describing required arguments.
        callback (function|nil)
            Receives parsed values; optional if using deferred.

    Returns:
        deferred|nil
            Promise when callback omitted.

    Realm:
        Shared

    Example Usage:
        ```lua
            ply:requestArguments("Teleport", spec, cb)
        ```
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
        net.WriteString(title or "")
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
        Shows a binary (two-button) question to the player and returns choice.

    When Called:
        Use for yes/no confirmations.

    Parameters:
        question (string)
            Prompt text.
        option1 (string)
            Label for first option.
        option2 (string)
            Label for second option.
        manualDismiss (boolean)
            Require manual close; optional.
        callback (function)
            Receives 0/1 result.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:requestBinaryQuestion("Proceed?", "Yes", "No", false, cb)
        ```
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
        net.WriteString(question)
        net.WriteString(option1)
        net.WriteString(option2)
        net.WriteBool(manualDismiss)
        net.Send(self)
    else
        lia.derma.requestBinaryQuestion(title, question, function(result) if callback then callback(result and 0 or 1) end end, option1, option2)
    end
end

--[[
    Purpose:
        Displays a popup question with arbitrary buttons and handles responses.

    When Called:
        Use for multi-button confirmations or admin prompts.

    Parameters:
        question (string)
            Prompt text.
        buttons (table)
            Array of strings or {label, callback} pairs.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:requestPopupQuestion("Choose", {{"A", cbA}, {"B", cbB}})
        ```
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
        net.WriteString(question)
        net.WriteUInt(#buttons, 8)
        for _, buttonInfo in ipairs(buttons) do
            local buttonText = istable(buttonInfo) and buttonInfo[1] or tostring(buttonInfo)
            net.WriteString(buttonText)
        end

        net.Send(self)
    else
        lia.derma.requestPopupQuestion(question, buttons)
    end
end

--[[
    Purpose:
        Sends a button list prompt to the player and routes callbacks.

    When Called:
        Use when a simple list of actions is needed.

    Parameters:
        title (string)
            Dialog title.
        buttons (table)
            Array of {text=, callback=} entries.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:requestButtons("Actions", {{text="A", callback=cb}})
        ```
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
        net.WriteString(title or "")
        net.WriteUInt(#labels, 8)
        for _, lbl in ipairs(labels) do
            net.WriteString(lbl)
        end

        net.Send(self)
    else
        lia.derma.requestButtons(title, buttons)
    end
end

--[[
    Purpose:
        Presents a dropdown selection dialog to the player.

    When Called:
        Use for single-choice option selection.

    Parameters:
        title (string)
        subTitle (string)
        options (table)
            Available options.
        callback (function)
            Invoked with chosen option.
    Realm:
        Shared

    Example Usage:
        ```lua
            ply:requestDropdown("Pick class", "Choose", opts, cb)
        ```
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
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options or {})
        net.Send(self)
    else
        lia.derma.requestDropdown(title, subTitle, options, callback)
    end
end

if SERVER then
    --[[
    Purpose:
        Restores stamina by an amount, clamping to the character's maximum.

    When Called:
        Use when giving the player stamina back (e.g., resting or items).

    Parameters:
        amount (number)
            Stamina to add.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:restoreStamina(10)
        ```
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
        Reduces stamina by an amount and handles exhaustion state.

    When Called:
        Use when sprinting or performing actions that consume stamina.

    Parameters:
        amount (number)
            Stamina to subtract.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:consumeStamina(5)
        ```
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
        Adds money to the player's character and logs the change.

    When Called:
        Use when rewarding currency server-side.

    Parameters:
        amount (number)
            Amount to add (can be negative via takeMoney).

    Returns:
        boolean
            False if no character exists.

    Realm:
        Server

    Example Usage:
        ```lua
            ply:addMoney(50)
        ```
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
        Removes money from the player's character by delegating to giveMoney.

    When Called:
        Use when charging the player server-side.

    Parameters:
        amount (number)
            Amount to deduct.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:takeMoney(20)
        ```
]]
    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end

    --[[
    Purpose:
        Loads persistent Lilia player data from the database.

    When Called:
        Use during player initial spawn to hydrate data.

    Parameters:
        callback (function|nil)
            Invoked with loaded data table.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:loadLiliaData()
        ```
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
                    userGroup = "user",
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
        Persists the player's Lilia data back to the database.

    When Called:
        Use on disconnect or after updating persistent data.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:saveLiliaData()
        ```
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
        Sets a key in the player's Lilia data, optionally syncing and saving.

    When Called:
        Use when updating persistent player-specific values.

    Parameters:
        key (string)
            Data key.
        value (any)
            Value to store.
        noNetworking (boolean)
            Skip net sync when true.
        noSave (boolean)
            Skip immediate DB save when true.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:setLiliaData("lastIP", ip)
        ```
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
        Records a ban entry and kicks the player with a ban message.

    When Called:
        Use when banning a player via scripts.

    Parameters:
        reason (string)
            Ban reason.
        duration (number)
            Duration in minutes; 0 or nil for perm.
        banner (Player|nil)
            Staff issuing the ban.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:banPlayer("RDM", 60, admin)
        ```
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
        Returns the player's total playtime in seconds (server calculation).

    When Called:
        Use for server-side playtime checks.

    Parameters:
        None.

    Returns:
        number
            Playtime in seconds.

    Realm:
        Server

    Example Usage:
        ```lua
            local t = ply:getPlayTime()
        ```
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

    local function isStuck(client)
        return util.TraceEntity({
            start = client:GetPos(),
            endpos = client:GetPos(),
            filter = client
        }, client).StartSolid
    end

    --[[
    Purpose:
        Toggles ragdoll state for the player, handling weapons, timers, and get-up.

    When Called:
        Use when knocking out or reviving a player.

    Parameters:
        state (boolean)
            True to ragdoll, false to restore.
        baseTime (number|nil)
            Duration to stay ragdolled.
        getUpGrace (number|nil)
            Additional grace time before getting up.
        getUpMessage (string|nil)
            Action bar text while ragdolled.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:setRagdolled(true, 10)
        ```
]]
    function playerMeta:setRagdolled(state, baseTime, getUpGrace, getUpMessage)
        getUpMessage = getUpMessage or L("wakingUp")
        local ragdoll = self:GetRagdollEntity()
        local time = hook.Run("GetRagdollTime", self, time) or baseTime or 10
        if state then
            local handsWeapon = self:GetActiveWeapon()
            if IsValid(handsWeapon) and handsWeapon:GetClass() == "lia_hands" and handsWeapon:IsHoldingObject() then handsWeapon:DropObject() end
            if not IsValid(ragdoll) then
                self:CreateRagdoll()
                ragdoll = self:GetRagdollEntity()
                self:SetCreator(self)
            end

            local entity = ragdoll
            if IsValid(entity) then self:setNetVar("ragdoll", entity) end
            hook.Run("OnPlayerRagdolled", self, entity)
            entity.liaWeapons = {}
            entity.liaAmmo = {}
            entity.liaWeaponClips = {}
            local processedAmmoTypes = {}
            for _, w in ipairs(self:GetWeapons()) do
                local weaponClass = w:GetClass()
                entity.liaWeapons[#entity.liaWeapons + 1] = weaponClass
                local ammoType = w:GetPrimaryAmmoType()
                local clip = w:Clip1()
                entity.liaWeaponClips[weaponClass] = clip
                if ammoType and ammoType > 0 and not processedAmmoTypes[ammoType] then
                    local reserve = self:GetAmmoCount(ammoType)
                    entity.liaAmmo[ammoType] = reserve
                    processedAmmoTypes[ammoType] = true
                end
            end

            entity:CallOnRemove("fixer", function()
                if IsValid(self) then
                    self:setNetVar("ragdoll", nil)
                    if self.liaStoredHealth then self:SetHealth(math.max(self.liaStoredHealth, 1)) end
                    if not entity.liaNoReset then self:SetPos(entity:GetPos()) end
                    self:SetNoDraw(false)
                    self:SetNotSolid(false)
                    self:Freeze(false)
                    self:SetMoveType(MOVETYPE_WALK)
                    self:SetLocalVelocity(IsValid(entity) and entity.liaLastVelocity or vector_origin)
                    self.liaStoredHealth = nil
                    self.liaStoredMaxHealth = nil
                end

                if IsValid(self) and not entity.liaIgnoreDelete then
                    if entity.liaWeapons then
                        for _, weaponClass in ipairs(entity.liaWeapons) do
                            self:Give(weaponClass, true)
                        end

                        if entity.liaWeaponClips then
                            for _, weapon in ipairs(self:GetWeapons()) do
                                local weaponClass = weapon:GetClass()
                                local clip = entity.liaWeaponClips[weaponClass]
                                if clip and clip > 0 then weapon:SetClip1(clip) end
                            end
                        end

                        if entity.liaAmmo then
                            for ammoType, reserve in pairs(entity.liaAmmo) do
                                if reserve and reserve > 0 then self:SetAmmo(reserve, ammoType) end
                            end
                        end
                    end

                    if isStuck(self) then
                        entity:DropToFloor()
                        self:SetPos(entity:GetPos() + Vector(0, 0, 16))
                        local positions = lia.util.findEmptySpace(self, {entity, self})
                        for _, pos in ipairs(positions) do
                            self:SetPos(pos)
                            if not isStuck(self) then return end
                        end
                    end
                end
            end)

            if getUpGrace then entity.liaGrace = CurTime() + getUpGrace end
            if time and time > 0 then
                entity.liaStart = CurTime()
                entity.liaFinish = entity.liaStart + time
                self:setAction(getUpMessage, time)
            end

            self:GodEnable()
            self:StripWeapons()
            self:Freeze(true)
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            self:SetMoveType(MOVETYPE_NONE)
            if time then
                local uniqueID = "liaUnRagdoll" .. self:SteamID64()
                timer.Create(uniqueID, 1.0, 0, function()
                    if not IsValid(entity) or not IsValid(self) then
                        timer.Remove(uniqueID)
                        return
                    end

                    local velocity = entity:GetVelocity()
                    entity.liaLastVelocity = velocity
                    self:SetPos(entity:GetPos())
                    time = time - 1.0
                    if time <= 0 then
                        timer.Remove(uniqueID)
                        self:setRagdolled(false)
                    end
                end)
            end

            if IsValid(entity) then
                entity:SetCollisionGroup(COLLISION_GROUP_NONE)
                entity:SetCustomCollisionCheck(false)
            end
        else
            ragdoll = self:GetRagdollEntity()
            if IsValid(ragdoll) then
                if ragdoll.liaWeapons then
                    for _, weaponClass in ipairs(ragdoll.liaWeapons) do
                        self:Give(weaponClass, true)
                    end

                    if ragdoll.liaWeaponClips then
                        for _, weapon in ipairs(self:GetWeapons()) do
                            local weaponClass = weapon:GetClass()
                            local clip = ragdoll.liaWeaponClips[weaponClass]
                            if clip and clip > 0 then weapon:SetClip1(clip) end
                        end
                    end

                    if ragdoll.liaAmmo then
                        for ammoType, reserve in pairs(ragdoll.liaAmmo) do
                            if reserve and reserve > 0 then self:SetAmmo(reserve, ammoType) end
                        end
                    end
                end

                self:removeRagdoll()
                self:GodDisable()
                self:Freeze(false)
                self:SetNoDraw(false)
                self:SetNotSolid(false)
                self:SetMoveType(MOVETYPE_WALK)
            end
        end
    end

    --[[
    Purpose:
        Sends all known net variables to this player.

    When Called:
        Use when a player joins or needs a full resync.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:syncVars()
        ```
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
        Sets a networked variable for this player and broadcasts it.

    When Called:
        Use when updating shared player state.

    Parameters:
        key (string)
            Variable name.
        value (any)
            Value to store.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:setNetVar("hasKey", true)
        ```
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
        Sets a server-local variable for this player and sends it only to them.

    When Called:
        Use for per-player state that should not broadcast.

    Parameters:
        key (string)
            Variable name.
        value (any)
            Value to store.
    Realm:
        Server

    Example Usage:
        ```lua
            ply:setLocalVar("stamina", 80)
        ```
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
        Reads a server-local variable for this player.

    When Called:
        Use when accessing non-networked state.

    Parameters:
        key (string)
            Variable name.
        default (any)
            Fallback when unset.

    Returns:
        any
            Stored value or default.

    Realm:
        Server

    Example Usage:
        ```lua
            local stamina = ply:getLocalVar("stamina", 100)
        ```
]]
    function playerMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        if lia.net.locals[self] and lia.net.locals[self][key] ~= nil then return lia.net.locals[self][key] end
        return default
    end
else
    --[[
    Purpose:
        Reads a networked variable for this player on the client.

    When Called:
        Use clientside when accessing shared netvars.

    Parameters:
        key (string)
            Variable name.
        default (any)
            Fallback when unset.

    Returns:
        any
            Stored value or default.

    Realm:
        Client

    Example Usage:
        ```lua
            local val = ply:getLocalVar("stamina", 0)
        ```
]]
    function playerMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        local idx = self:EntIndex()
        if lia.net[idx] and lia.net[idx][key] ~= nil then return lia.net[idx][key] end
        return default
    end

    --[[
    Purpose:
        Returns the player's playtime (client-calculated fallback).

    When Called:
        Use on the client when server data is unavailable.

    Parameters:
        None.

    Returns:
        number
            Playtime in seconds.

    Realm:
        Client

    Example Usage:
        ```lua
            local t = ply:getPlayTime()
        ```
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
