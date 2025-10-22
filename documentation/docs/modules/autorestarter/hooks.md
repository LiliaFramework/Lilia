# Hooks

This document describes the hooks available in the Auto Restarter module for managing automatic server restarts and countdown notifications.

---

## AutoRestart

**Purpose**

Called when the server is about to restart due to the automatic restart timer.

**Parameters**

* `timestamp` (*number*): The Unix timestamp when the restart was triggered.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The restart timer expires
- The server is about to execute the changelevel command
- After `AutoRestartScheduled` hook

**Example Usage**

```lua
-- Save important data before restart
hook.Add("AutoRestart", "SaveDataBeforeRestart", function(timestamp)
    -- Save player data
    for _, ply in player.Iterator() do
        if ply:getChar() then
            ply:getChar():save()
        end
    end
    
    -- Save server statistics
    local stats = {
        restart_time = timestamp,
        player_count = #player.GetAll(),
        uptime = os.time() - server_start_time
    }
    
    file.Write("server_restart_stats.json", util.TableToJSON(stats))
end)

-- Notify external systems about restart
hook.Add("AutoRestart", "NotifyExternalSystems", function(timestamp)
    -- Send restart notification to Discord webhook
    local webhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
    local data = {
        content = "Server is restarting automatically at " .. os.date("%Y-%m-%d %H:%M:%S", timestamp)
    }
    
    http.Post(webhook, data, function(response)
        print("Restart notification sent to Discord")
    end)
end)

-- Log restart event
hook.Add("AutoRestart", "LogRestartEvent", function(timestamp)
    lia.log.add(nil, "autoRestart", timestamp)
    print("Auto restart triggered at " .. os.date("%Y-%m-%d %H:%M:%S", timestamp))
end)
```

---

## AutoRestartCountdown

**Purpose**

Called when the restart countdown is active (within 25% of the restart interval).

**Parameters**

* `remaining` (*number*): The remaining seconds until restart.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The remaining time is within 25% of the restart interval
- The countdown display is shown to players
- Every second during the countdown period

**Example Usage**

```lua
-- Custom countdown announcements
hook.Add("AutoRestartCountdown", "CustomCountdownAnnouncements", function(remaining)
    -- Announce at specific intervals
    if remaining == 300 then -- 5 minutes
        for _, ply in player.Iterator() do
            ply:ChatPrint("Server will restart in 5 minutes!")
        end
    elseif remaining == 60 then -- 1 minute
        for _, ply in player.Iterator() do
            ply:ChatPrint("Server will restart in 1 minute!")
        end
    elseif remaining == 30 then -- 30 seconds
        for _, ply in player.Iterator() do
            ply:ChatPrint("Server will restart in 30 seconds!")
        end
    elseif remaining <= 10 then -- Final countdown
        for _, ply in player.Iterator() do
            ply:ChatPrint("Server restarting in " .. remaining .. " seconds!")
        end
    end
end)

-- Apply countdown effects
hook.Add("AutoRestartCountdown", "ApplyCountdownEffects", function(remaining)
    -- Apply screen effects during countdown
    if remaining <= 60 then
        for _, ply in player.Iterator() do
            ply:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.5, 0)
        end
    end
    
    -- Play countdown sound
    if remaining <= 10 and remaining > 0 then
        for _, ply in player.Iterator() do
            ply:EmitSound("buttons/button15.wav", 75, 100)
        end
    end
end)

-- Track countdown events
hook.Add("AutoRestartCountdown", "TrackCountdownEvents", function(remaining)
    -- Log countdown milestones
    if remaining == 300 or remaining == 60 or remaining == 30 or remaining == 10 then
        lia.log.add(nil, "restartCountdown", remaining)
    end
end)
```

---

## AutoRestartScheduled

**Purpose**

Called when a new restart is scheduled or rescheduled.

**Parameters**

* `nextRestart` (*number*): The Unix timestamp of the next scheduled restart.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The module initializes and schedules the first restart
- A restart occurs and the next restart is scheduled
- The restart interval configuration changes

**Example Usage**

```lua
-- Notify administrators about restart schedule
hook.Add("AutoRestartScheduled", "NotifyAdmins", function(nextRestart)
    local restartTime = os.date("%Y-%m-%d %H:%M:%S", nextRestart)
    
    for _, ply in player.Iterator() do
        if ply:IsAdmin() then
            ply:ChatPrint("Next server restart scheduled for: " .. restartTime)
        end
    end
    
    print("Next restart scheduled for: " .. restartTime)
end)

-- Update external monitoring systems
hook.Add("AutoRestartScheduled", "UpdateMonitoring", function(nextRestart)
    -- Send restart schedule to monitoring service
    local data = {
        next_restart = nextRestart,
        restart_time = os.date("%Y-%m-%d %H:%M:%S", nextRestart),
        server_name = GetHostName()
    }
    
    http.Post("https://your-monitoring-service.com/restart-schedule", data, function(response)
        print("Restart schedule updated in monitoring system")
    end)
end)

-- Log restart scheduling
hook.Add("AutoRestartScheduled", "LogRestartSchedule", function(nextRestart)
    lia.log.add(nil, "restartScheduled", nextRestart)
    
    -- Calculate time until restart
    local timeUntilRestart = nextRestart - os.time()
    local hours = math.floor(timeUntilRestart / 3600)
    local minutes = math.floor((timeUntilRestart % 3600) / 60)
    
    print("Restart scheduled in " .. hours .. " hours and " .. minutes .. " minutes")
end)
```

---

## AutoRestartStarted

**Purpose**

Called when the restart process has actually begun (after the changelevel command is issued).

**Parameters**

* `mapName` (*string*): The name of the map the server is restarting to.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `changelevel` command has been executed
- The server is about to change maps
- After `AutoRestart` hook

**Example Usage**

```lua
-- Final cleanup before map change
hook.Add("AutoRestartStarted", "FinalCleanup", function(mapName)
    -- Save all character data
    for _, ply in player.Iterator() do
        if ply:getChar() then
            ply:getChar():save()
        end
    end
    
    -- Save server state
    local serverState = {
        map = mapName,
        restart_time = os.time(),
        players = {}
    }
    
    for _, ply in player.Iterator() do
        table.insert(serverState.players, {
            steamid = ply:SteamID(),
            name = ply:Name(),
            char_id = ply:getChar() and ply:getChar():getID() or nil
        })
    end
    
    file.Write("server_state.json", util.TableToJSON(serverState))
end)

-- Send final notifications
hook.Add("AutoRestartStarted", "FinalNotifications", function(mapName)
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:ChatPrint("Server is now restarting to " .. mapName .. "!")
    end
    
    -- Send to external systems
    local data = {
        content = "Server restarting to map: " .. mapName,
        timestamp = os.time()
    }
    
    http.Post("https://discord.com/api/webhooks/YOUR_WEBHOOK_URL", data, function(response)
        print("Restart notification sent")
    end)
end)

-- Log restart completion
hook.Add("AutoRestartStarted", "LogRestartCompletion", function(mapName)
    lia.log.add(nil, "restartStarted", mapName)
    print("Auto restart started - changing to map: " .. mapName)
end)
```

