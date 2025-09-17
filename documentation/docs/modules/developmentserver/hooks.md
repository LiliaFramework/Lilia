# Hooks

This document describes the hooks available in the Development Server module for managing development server mode functionality.

---

## DevServerAuthorized

**Purpose**

Called when a player is authorized to access the development server.

**Parameters**

* `steamid64` (*string*): The Steam ID 64 of the authorized player.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player connects to the development server
- The player's Steam ID is found in the authorized developers list
- After `DevServerUnauthorized` hook check

**Example Usage**

```lua
-- Track development server authorization
hook.Add("DevServerAuthorized", "TrackDevServerAuth", function(steamid64)
    lia.log.add(nil, "devServerAuthorized", steamid64)
    
    -- Notify all players
    for _, ply in player.Iterator() do
        if ply:SteamID64() == steamid64 then
            ply:notify("Welcome to the development server!")
        end
    end
end)

-- Apply authorization effects
hook.Add("DevServerAuthorized", "DevServerAuthEffects", function(steamid64)
    -- Find the authorized player
    for _, ply in player.Iterator() do
        if ply:SteamID64() == steamid64 then
            -- Play authorization sound
            ply:EmitSound("buttons/button14.wav", 75, 100)
            
            -- Apply screen effect
            ply:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
            
            -- Give development tools
            ply:Give("weapon_crowbar")
            ply:Give("weapon_physcannon")
        end
    end
end)

-- Track authorization statistics
hook.Add("DevServerAuthorized", "TrackDevServerAuthStats", function(steamid64)
    -- Track total authorizations
    local totalAuths = lia.data.get("dev_server_authorizations", 0)
    lia.data.set("dev_server_authorizations", totalAuths + 1)
    
    -- Track unique authorizations
    local uniqueAuths = lia.data.get("dev_server_unique_auths", {})
    uniqueAuths[steamid64] = (uniqueAuths[steamid64] or 0) + 1
    lia.data.set("dev_server_unique_auths", uniqueAuths)
end)
```

---

## DevServerModeActivated

**Purpose**

Called when development server mode is activated.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The development server mode is enabled
- The server starts in development mode
- After `DevServerModeDeactivated` hook check

**Example Usage**

```lua
-- Track development mode activation
hook.Add("DevServerModeActivated", "TrackDevModeActivation", function()
    lia.log.add(nil, "devServerModeActivated")
    
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:notify("Development server mode activated!")
    end
    
    -- Print server message
    print("Development server mode is now active!")
end)

-- Apply development mode effects
hook.Add("DevServerModeActivated", "DevModeActivationEffects", function()
    -- Enable development features
    RunConsoleCommand("sv_cheats", "1")
    RunConsoleCommand("sv_allowcslua", "1")
    
    -- Set development server settings
    RunConsoleCommand("sv_gravity", "600")
    RunConsoleCommand("sv_friction", "4")
    
    -- Create development entities
    local devSpawn = ents.Create("info_player_start")
    devSpawn:SetPos(Vector(0, 0, 0))
    devSpawn:Spawn()
end)

-- Track activation statistics
hook.Add("DevServerModeActivated", "TrackDevModeActivationStats", function()
    -- Track activation count
    local activations = lia.data.get("dev_mode_activations", 0)
    lia.data.set("dev_mode_activations", activations + 1)
    
    -- Track activation time
    lia.data.set("dev_mode_activation_time", os.time())
end)
```

---

## DevServerModeDeactivated

**Purpose**

Called when development server mode is deactivated.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The development server mode is disabled
- The server switches to production mode
- After `DevServerModeActivated` hook check

**Example Usage**

```lua
-- Track development mode deactivation
hook.Add("DevServerModeDeactivated", "TrackDevModeDeactivation", function()
    lia.log.add(nil, "devServerModeDeactivated")
    
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:notify("Development server mode deactivated!")
    end
    
    -- Print server message
    print("Development server mode is now inactive!")
end)

-- Apply development mode deactivation effects
hook.Add("DevServerModeDeactivated", "DevModeDeactivationEffects", function()
    -- Disable development features
    RunConsoleCommand("sv_cheats", "0")
    RunConsoleCommand("sv_allowcslua", "0")
    
    -- Reset server settings
    RunConsoleCommand("sv_gravity", "600")
    RunConsoleCommand("sv_friction", "4")
    
    -- Clean up development entities
    for _, ent in pairs(ents.FindByClass("info_player_start")) do
        if ent:GetPos() == Vector(0, 0, 0) then
            ent:Remove()
        end
    end
end)

-- Track deactivation statistics
hook.Add("DevServerModeDeactivated", "TrackDevModeDeactivationStats", function()
    -- Track deactivation count
    local deactivations = lia.data.get("dev_mode_deactivations", 0)
    lia.data.set("dev_mode_deactivations", deactivations + 1)
    
    -- Track deactivation time
    lia.data.set("dev_mode_deactivation_time", os.time())
end)
```

---

## DevServerUnauthorized

**Purpose**

Called when a player is unauthorized to access the development server.

**Parameters**

* `steamid64` (*string*): The Steam ID 64 of the unauthorized player.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player connects to the development server
- The player's Steam ID is not found in the authorized developers list
- Before `DevServerAuthorized` hook check

**Example Usage**

```lua
-- Track development server unauthorized access
hook.Add("DevServerUnauthorized", "TrackDevServerUnauth", function(steamid64)
    lia.log.add(nil, "devServerUnauthorized", steamid64)
    
    -- Notify unauthorized player
    for _, ply in player.Iterator() do
        if ply:SteamID64() == steamid64 then
            ply:notify("You are not authorized to access the development server!")
        end
    end
end)

-- Apply unauthorized effects
hook.Add("DevServerUnauthorized", "DevServerUnauthEffects", function(steamid64)
    -- Find the unauthorized player
    for _, ply in player.Iterator() do
        if ply:SteamID64() == steamid64 then
            -- Play unauthorized sound
            ply:EmitSound("buttons/button16.wav", 75, 100)
            
            -- Apply screen effect
            ply:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 20), 1, 0)
            
            -- Kick player after delay
            timer.Simple(3, function()
                if IsValid(ply) then
                    ply:Kick("Unauthorized access to development server")
                end
            end)
        end
    end
end)

-- Track unauthorized access statistics
hook.Add("DevServerUnauthorized", "TrackDevServerUnauthStats", function(steamid64)
    -- Track total unauthorized attempts
    local totalUnauths = lia.data.get("dev_server_unauthorized_attempts", 0)
    lia.data.set("dev_server_unauthorized_attempts", totalUnauths + 1)
    
    -- Track unique unauthorized attempts
    local uniqueUnauths = lia.data.get("dev_server_unique_unauths", {})
    uniqueUnauths[steamid64] = (uniqueUnauths[steamid64] or 0) + 1
    lia.data.set("dev_server_unique_unauths", uniqueUnauths)
end)
```
