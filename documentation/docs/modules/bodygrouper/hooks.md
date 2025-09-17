# Hooks

This document describes the hooks available in the Bodygrouper module for managing bodygroup editing and closet interactions.

---

## BodygrouperApplyAttempt

**Purpose**

Called when a player attempts to apply bodygroup changes to a target.

**Parameters**

* `client` (*Player*): The player attempting to apply bodygroup changes.
* `target` (*Player*): The target player whose bodygroups are being modified.
* `skin` (*number*): The skin ID being applied.
* `groups` (*table*): Table of bodygroup changes (key = bodygroup index, value = bodygroup value).

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player sends bodygroup changes via the menu
- Before any validation checks are performed
- Before permission checks

**Example Usage**

```lua
-- Log all bodygroup apply attempts
hook.Add("BodygrouperApplyAttempt", "LogBodygroupAttempts", function(client, target, skin, groups)
    lia.log.add(client, "bodygroupAttempt", target:Name(), skin, util.TableToJSON(groups))
end)

-- Track bodygroup modification statistics
hook.Add("BodygrouperApplyAttempt", "TrackBodygroupStats", function(client, target, skin, groups)
    local char = client:getChar()
    if char then
        local attempts = char:getData("bodygroup_attempts", 0)
        char:setData("bodygroup_attempts", attempts + 1)
        
        -- Track self-modification vs others
        if client == target then
            char:setData("self_bodygroup_changes", char:getData("self_bodygroup_changes", 0) + 1)
        else
            char:setData("other_bodygroup_changes", char:getData("other_bodygroup_changes", 0) + 1)
        end
    end
end)

-- Prevent bodygroup changes during certain events
hook.Add("BodygrouperApplyAttempt", "PreventDuringEvents", function(client, target, skin, groups)
    if target:getChar() and target:getChar():getData("inEvent", false) then
        client:notify("Cannot modify bodygroups during events!")
        return false
    end
end)
```

---

## BodygrouperClosetAddUser

**Purpose**

Called when a player is added to a bodygroup closet's user list.

**Parameters**

* `closet` (*Entity*): The bodygroup closet entity.
* `user` (*Player*): The player being added to the closet.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player enters a bodygroup closet
- The closet's `AddUser` method is called

**Example Usage**

```lua
-- Track closet usage
hook.Add("BodygrouperClosetAddUser", "TrackClosetUsage", function(closet, user)
    local char = user:getChar()
    if char then
        local closetUses = char:getData("closet_uses", 0)
        char:setData("closet_uses", closetUses + 1)
    end
    
    -- Log closet entry
    lia.log.add(user, "closetEntry", closet:GetPos())
end)

-- Apply special effects when entering closet
hook.Add("BodygrouperClosetAddUser", "ClosetEntryEffects", function(closet, user)
    -- Play custom sound
    user:EmitSound("doors/door_metal_thin_open1.wav", 75, 100)
    
    -- Apply screen effect
    user:ScreenFade(SCREENFADE.IN, Color(100, 100, 255, 10), 1, 0)
    
    -- Notify player
    user:notify("You entered the bodygroup closet!")
end)

-- Limit closet capacity
hook.Add("BodygrouperClosetAddUser", "LimitClosetCapacity", function(closet, user)
    local currentUsers = 0
    for _, ply in player.Iterator() do
        if closet:HasUser(ply) then
            currentUsers = currentUsers + 1
        end
    end
    
    if currentUsers >= 3 then -- Max 3 users
        user:notify("The closet is full!")
        closet:RemoveUser(user)
        return false
    end
end)
```

---

## BodygrouperClosetClosed

**Purpose**

Called when a bodygroup closet is closed (no longer has any users).

**Parameters**

* `closet` (*Entity*): The bodygroup closet entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The last user leaves the closet
- The closet's `RemoveUser` method is called and no users remain

**Example Usage**

```lua
-- Track closet closure
hook.Add("BodygrouperClosetClosed", "TrackClosetClosure", function(closet)
    lia.log.add(nil, "closetClosed", closet:GetPos())
    
    -- Reset closet state
    closet:setData("last_used", os.time())
end)

-- Apply closure effects
hook.Add("BodygrouperClosetClosed", "ClosetClosureEffects", function(closet)
    -- Play closing sound
    closet:EmitSound("doors/door_metal_thin_close2.wav", 75, 100)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(closet:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Clean up closet data
hook.Add("BodygrouperClosetClosed", "CleanupClosetData", function(closet)
    -- Clear any temporary data
    closet:setData("active_users", {})
    closet:setData("last_activity", os.time())
end)
```

---

## BodygrouperClosetOpened

**Purpose**

Called when a bodygroup closet is opened (first user enters).

**Parameters**

* `closet` (*Entity*): The bodygroup closet entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The first user enters the closet
- The closet's `AddUser` method is called for the first user

**Example Usage**

```lua
-- Track closet opening
hook.Add("BodygrouperClosetOpened", "TrackClosetOpening", function(closet)
    lia.log.add(nil, "closetOpened", closet:GetPos())
    
    -- Set closet as active
    closet:setData("is_active", true)
    closet:setData("opened_time", os.time())
end)

-- Apply opening effects
hook.Add("BodygrouperClosetOpened", "ClosetOpeningEffects", function(closet)
    -- Play opening sound
    closet:EmitSound("doors/door_metal_thin_open1.wav", 75, 100)
    
    -- Create light effect
    local light = ents.Create("light_dynamic")
    light:SetPos(closet:GetPos() + Vector(0, 0, 50))
    light:SetKeyValue("brightness", "2")
    light:SetKeyValue("distance", "200")
    light:SetKeyValue("_light", "255 255 255")
    light:Spawn()
    
    -- Remove light after 5 seconds
    timer.Simple(5, function()
        if IsValid(light) then light:Remove() end
    end)
end)

-- Notify nearby players
hook.Add("BodygrouperClosetOpened", "NotifyNearbyPlayers", function(closet)
    for _, ply in player.Iterator() do
        if ply:GetPos():Distance(closet:GetPos()) < 500 then
            ply:notify("A bodygroup closet has been opened nearby!")
        end
    end
end)
```

---

## BodygrouperClosetRemoveUser

**Purpose**

Called when a player is removed from a bodygroup closet's user list.

**Parameters**

* `closet` (*Entity*): The bodygroup closet entity.
* `user` (*Player*): The player being removed from the closet.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player leaves a bodygroup closet
- The closet's `RemoveUser` method is called

**Example Usage**

```lua
-- Track closet exit
hook.Add("BodygrouperClosetRemoveUser", "TrackClosetExit", function(closet, user)
    local char = user:getChar()
    if char then
        local timeSpent = os.time() - char:getData("closet_entry_time", 0)
        char:setData("total_closet_time", char:getData("total_closet_time", 0) + timeSpent)
    end
    
    lia.log.add(user, "closetExit", closet:GetPos())
end)

-- Apply exit effects
hook.Add("BodygrouperClosetRemoveUser", "ClosetExitEffects", function(closet, user)
    -- Play exit sound
    user:EmitSound("doors/door_metal_thin_close2.wav", 75, 100)
    
    -- Clear screen effects
    user:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 1, 0)
    
    -- Notify player
    user:notify("You left the bodygroup closet!")
end)

-- Check if closet should close
hook.Add("BodygrouperClosetRemoveUser", "CheckClosetClosure", function(closet, user)
    local hasUsers = false
    for _, ply in player.Iterator() do
        if closet:HasUser(ply) then
            hasUsers = true
            break
        end
    end
    
    if not hasUsers then
        hook.Run("BodygrouperClosetClosed", closet)
    end
end)
```

---

## BodygrouperInvalidGroup

**Purpose**

Called when an invalid bodygroup value is provided.

**Parameters**

* `client` (*Player*): The player who provided the invalid bodygroup.
* `target` (*Player*): The target player.
* `groupIndex` (*number*): The bodygroup index that was invalid.
* `groupValue` (*number*): The invalid bodygroup value.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A bodygroup value exceeds the maximum allowed for that bodygroup
- Before the error notification is sent to the client

**Example Usage**

```lua
-- Log invalid bodygroup attempts
hook.Add("BodygrouperInvalidGroup", "LogInvalidGroups", function(client, target, groupIndex, groupValue)
    lia.log.add(client, "invalidBodygroup", target:Name(), groupIndex, groupValue)
    
    -- Notify administrators
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            admin:notify(client:Name() .. " attempted invalid bodygroup " .. groupIndex .. " = " .. groupValue)
        end
    end
end)

-- Track invalid attempts for moderation
hook.Add("BodygrouperInvalidGroup", "TrackInvalidAttempts", function(client, target, groupIndex, groupValue)
    local char = client:getChar()
    if char then
        local invalidAttempts = char:getData("invalid_bodygroup_attempts", 0)
        char:setData("invalid_bodygroup_attempts", invalidAttempts + 1)
        
        -- Flag for review if too many invalid attempts
        if invalidAttempts >= 10 then
            char:setData("flagged_for_review", true)
            lia.log.add(client, "flaggedForReview", "Too many invalid bodygroup attempts")
        end
    end
end)

-- Provide helpful error messages
hook.Add("BodygrouperInvalidGroup", "HelpfulErrorMessages", function(client, target, groupIndex, groupValue)
    local maxValue = target:GetBodygroupCount(groupIndex) - 1
    client:notify("Invalid bodygroup! Group " .. groupIndex .. " only accepts values 0-" .. maxValue .. " (you provided " .. groupValue .. ")")
end)
```

---

## BodygrouperInvalidSkin

**Purpose**

Called when an invalid skin value is provided.

**Parameters**

* `client` (*Player*): The player who provided the invalid skin.
* `target` (*Player*): The target player.
* `skin` (*number*): The invalid skin value.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A skin value exceeds the maximum allowed for the model
- Before the error notification is sent to the client

**Example Usage**

```lua
-- Log invalid skin attempts
hook.Add("BodygrouperInvalidSkin", "LogInvalidSkins", function(client, target, skin)
    lia.log.add(client, "invalidSkin", target:Name(), skin)
    
    -- Notify administrators
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            admin:notify(client:Name() .. " attempted invalid skin " .. skin)
        end
    end
end)

-- Track invalid skin attempts
hook.Add("BodygrouperInvalidSkin", "TrackInvalidSkinAttempts", function(client, target, skin)
    local char = client:getChar()
    if char then
        local invalidSkins = char:getData("invalid_skin_attempts", 0)
        char:setData("invalid_skin_attempts", invalidSkins + 1)
    end
end)

-- Provide helpful error messages
hook.Add("BodygrouperInvalidSkin", "HelpfulSkinErrors", function(client, target, skin)
    local maxSkin = target:SkinCount() - 1
    client:notify("Invalid skin! This model only supports skins 0-" .. maxSkin .. " (you provided " .. skin .. ")")
end)
```

---

## BodygrouperMenuClosed

**Purpose**

Called when the bodygroup menu is closed on the client side.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The bodygroup menu is closed
- The menu is removed from the client

**Example Usage**

```lua
-- Clean up client-side effects
hook.Add("BodygrouperMenuClosed", "CleanupMenuEffects", function()
    -- Remove any custom HUD elements
    if IsValid(BodygroupHUD) then
        BodygroupHUD:Remove()
    end
    
    -- Clear screen effects
    LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 0.5, 0)
end)

-- Track menu usage
hook.Add("BodygrouperMenuClosed", "TrackMenuUsage", function()
    local char = LocalPlayer():getChar()
    if char then
        local menuUses = char:getData("bodygroup_menu_uses", 0)
        char:setData("bodygroup_menu_uses", menuUses + 1)
    end
end)

-- Play close sound
hook.Add("BodygrouperMenuClosed", "MenuCloseSound", function()
    LocalPlayer():EmitSound("ui/buttonclickrelease.wav", 75, 100)
end)
```

---

## BodygrouperMenuClosedServer

**Purpose**

Called when the bodygroup menu is closed on the server side.

**Parameters**

* `client` (*Player*): The client whose menu was closed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The server receives a menu close network message
- The client's closet users are removed

**Example Usage**

```lua
-- Clean up server-side data
hook.Add("BodygrouperMenuClosedServer", "CleanupServerData", function(client)
    -- Remove client from all closets
    for _, closet in pairs(ents.FindByClass("lia_bodygrouper")) do
        if closet:HasUser(client) then
            closet:RemoveUser(client)
        end
    end
    
    -- Clear any temporary data
    client:setData("in_bodygroup_menu", false)
end)

-- Track menu closure
hook.Add("BodygrouperMenuClosedServer", "TrackMenuClosure", function(client)
    lia.log.add(client, "bodygroupMenuClosed")
    
    -- Notify if client was in menu for too long
    local menuStartTime = client:getData("menu_start_time", 0)
    if menuStartTime > 0 then
        local timeSpent = os.time() - menuStartTime
        if timeSpent > 300 then -- 5 minutes
            lia.log.add(client, "longMenuSession", timeSpent)
        end
    end
end)

-- Apply closure effects
hook.Add("BodygrouperMenuClosedServer", "MenuClosureEffects", function(client)
    -- Notify client
    client:notify("Bodygroup menu closed!")
    
    -- Clear any temporary permissions
    client:setData("temp_bodygroup_access", false)
end)
```

---

## BodygrouperMenuOpened

**Purpose**

Called when the bodygroup menu is opened on the client side.

**Parameters**

* `menu` (*Panel*): The bodygroup menu panel.
* `target` (*Player*): The target player whose bodygroups are being edited.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The bodygroup menu is created and displayed
- The menu is set up with the target player

**Example Usage**

```lua
-- Apply custom styling to the menu
hook.Add("BodygrouperMenuOpened", "CustomMenuStyling", function(menu, target)
    -- Set custom colors
    menu:SetBackgroundColor(Color(50, 50, 50, 200))
    
    -- Add custom title
    local title = menu:Add("DLabel")
    title:SetText("Custom Bodygroup Editor")
    title:SetFont("DermaDefault")
    title:SetTextColor(Color(255, 255, 255))
    title:Dock(TOP)
end)

-- Track menu opening
hook.Add("BodygrouperMenuOpened", "TrackMenuOpening", function(menu, target)
    local char = LocalPlayer():getChar()
    if char then
        char:setData("last_menu_open", os.time())
        char:setData("menu_target", target:Name())
    end
end)

-- Apply opening effects
hook.Add("BodygrouperMenuOpened", "MenuOpeningEffects", function(menu, target)
    -- Play opening sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(100, 100, 255, 5), 1, 0)
end)
```

---

## BodygrouperValidated

**Purpose**

Called when bodygroup changes pass all validation checks.

**Parameters**

* `client` (*Player*): The player applying the changes.
* `target` (*Player*): The target player.
* `skin` (*number*): The skin ID being applied.
* `groups` (*table*): Table of bodygroup changes.

**Realm**

Server.

**When Called**

This hook is triggered when:
- All validation checks pass (skin and bodygroup values are valid)
- Before the actual bodygroup changes are applied
- After permission checks

**Example Usage**

```lua
-- Log successful validations
hook.Add("BodygrouperValidated", "LogSuccessfulValidations", function(client, target, skin, groups)
    lia.log.add(client, "bodygroupValidated", target:Name(), skin, util.TableToJSON(groups))
end)

-- Apply pre-application effects
hook.Add("BodygrouperValidated", "PreApplicationEffects", function(client, target, skin, groups)
    -- Notify target if someone else is changing their bodygroups
    if client ~= target then
        target:notify(client:Name() .. " is about to modify your appearance!")
    end
    
    -- Apply temporary effects
    target:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.5, 0)
end)

-- Track validation statistics
hook.Add("BodygrouperValidated", "TrackValidationStats", function(client, target, skin, groups)
    local char = client:getChar()
    if char then
        local validations = char:getData("bodygroup_validations", 0)
        char:setData("bodygroup_validations", validations + 1)
    end
end)
```

---

## PostBodygroupApply

**Purpose**

Called after bodygroup changes have been successfully applied.

**Parameters**

* `client` (*Player*): The player who applied the changes.
* `target` (*Player*): The target player whose bodygroups were changed.
* `skin` (*number*): The skin ID that was applied.
* `groups` (*table*): Table of bodygroup changes that were applied.

**Realm**

Server.

**When Called**

This hook is triggered after:
- Bodygroup changes have been applied to the target
- Character data has been updated
- Before success notifications are sent

**Example Usage**

```lua
-- Log successful bodygroup applications
hook.Add("PostBodygroupApply", "LogBodygroupApplications", function(client, target, skin, groups)
    lia.log.add(client, "bodygroupApplied", target:Name(), skin, util.TableToJSON(groups))
end)

-- Apply post-application effects
hook.Add("PostBodygroupApply", "PostApplicationEffects", function(client, target, skin, groups)
    -- Clear screen effects
    target:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 1, 0)
    
    -- Play success sound
    target:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos() + Vector(0, 0, 50))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track bodygroup change statistics
hook.Add("PostBodygroupApply", "TrackBodygroupStats", function(client, target, skin, groups)
    local char = target:getChar()
    if char then
        local changes = char:getData("bodygroup_changes", 0)
        char:setData("bodygroup_changes", changes + 1)
        
        -- Track specific changes
        for groupIndex, groupValue in pairs(groups) do
            local groupChanges = char:getData("bodygroup_" .. groupIndex .. "_changes", 0)
            char:setData("bodygroup_" .. groupIndex .. "_changes", groupChanges + 1)
        end
    end
end)

-- Award achievements
hook.Add("PostBodygroupApply", "BodygroupAchievements", function(client, target, skin, groups)
    local char = target:getChar()
    if char then
        local totalChanges = char:getData("bodygroup_changes", 0)
        
        if totalChanges == 1 then
            target:notify("Achievement: First Makeover!")
        elseif totalChanges == 10 then
            target:notify("Achievement: Fashion Enthusiast!")
        elseif totalChanges == 50 then
            target:notify("Achievement: Style Master!")
        end
    end
end)
```

---

## PreBodygroupApply

**Purpose**

Called before bodygroup changes are applied to the target.

**Parameters**

* `client` (*Player*): The player applying the changes.
* `target` (*Player*): The target player.
* `skin` (*number*): The skin ID being applied.
* `groups` (*table*): Table of bodygroup changes.

**Realm**

Server.

**When Called**

This hook is triggered when:
- All validation checks have passed
- Before the actual bodygroup changes are applied
- Before character data is updated

**Example Usage**

```lua
-- Prevent bodygroup changes under certain conditions
hook.Add("PreBodygroupApply", "PreventBodygroupChanges", function(client, target, skin, groups)
    -- Prevent changes during combat
    if target:getChar() and target:getChar():getData("inCombat", false) then
        client:notify("Cannot modify bodygroups during combat!")
        return false
    end
    
    -- Prevent changes if target is frozen
    if target:GetMoveType() == MOVETYPE_NONE then
        client:notify("Cannot modify bodygroups of frozen players!")
        return false
    end
end)

-- Apply pre-application effects
hook.Add("PreBodygroupApply", "PreApplicationEffects", function(client, target, skin, groups)
    -- Store original appearance for potential rollback
    local char = target:getChar()
    if char then
        char:setData("original_skin", target:GetSkin())
        char:setData("original_bodygroups", target:GetBodyGroups())
    end
    
    -- Apply preparation effects
    target:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 20), 0.5, 0)
end)

-- Log pre-application
hook.Add("PreBodygroupApply", "LogPreApplication", function(client, target, skin, groups)
    lia.log.add(client, "preBodygroupApply", target:Name(), skin, util.TableToJSON(groups))
end)
```

---

## PreBodygrouperMenuOpen

**Purpose**

Called before the bodygroup menu is opened for a target.

**Parameters**

* `client` (*Player*): The client opening the menu.
* `target` (*Player*): The target player whose bodygroups will be edited.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `viewBodygroups` command is executed
- Before the menu network message is sent to the client

**Example Usage**

```lua
-- Check additional permissions
hook.Add("PreBodygrouperMenuOpen", "CheckAdditionalPermissions", function(client, target)
    -- Check if target allows bodygroup editing
    if target:getChar() and target:getChar():getData("allowBodygroupEditing", true) == false then
        client:notify("This player has disabled bodygroup editing!")
        return false
    end
    
    -- Check cooldown
    local lastEdit = target:getData("last_bodygroup_edit", 0)
    if os.time() - lastEdit < 60 then -- 1 minute cooldown
        client:notify("Please wait before editing this player's bodygroups again!")
        return false
    end
end)

-- Log menu open attempts
hook.Add("PreBodygrouperMenuOpen", "LogMenuOpenAttempts", function(client, target)
    lia.log.add(client, "bodygroupMenuOpen", target:Name())
    
    -- Track menu open statistics
    local char = client:getChar()
    if char then
        local menuOpens = char:getData("bodygroup_menu_opens", 0)
        char:setData("bodygroup_menu_opens", menuOpens + 1)
    end
end)

-- Apply pre-menu effects
hook.Add("PreBodygrouperMenuOpen", "PreMenuEffects", function(client, target)
    -- Notify target if someone else is opening their menu
    if client ~= target then
        target:notify(client:Name() .. " is opening your bodygroup editor!")
    end
    
    -- Set menu start time
    client:setData("menu_start_time", os.time())
    client:setData("in_bodygroup_menu", true)
end)
```
