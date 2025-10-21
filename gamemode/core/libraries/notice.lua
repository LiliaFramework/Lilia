--[[
    Notice Library

    Player notification and messaging system for the Lilia framework.
]]
--[[
    Overview:
    The notice library provides comprehensive functionality for displaying notifications
    and messages to players in the Lilia framework. It handles both server-side and
    client-side notification systems, supporting both direct text messages and localized
    messages with parameter substitution. The library operates across server and client
    realms, with the server sending notification data to clients via network messages,
    while the client handles the visual display of notifications using VGUI panels.
    It includes automatic organization of multiple notifications, sound effects, and
    console output for debugging purposes. The library also provides compatibility
    with Garry's Mod's legacy notification system.
]]
lia.notices = lia.notices or {}
if SERVER then
    --[[
        Purpose: Sends a notification message to a specific client or all clients
        When Called: When server needs to display a notification to player(s)
        Parameters:
            - client (Player|nil): Target player to send notification to, or nil for all players
            - message (string): The notification message text to display
            - notifType (string|nil): Type of notification ("default", "error", "success", "info", etc.)
        Returns: None
        Realm: Server
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Send basic notification to all players
        lia.notices.notify(nil, "Server restarting in 5 minutes!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send error notification to specific player
        local player = Player(1)
        if IsValid(player) then
            lia.notices.notify(player, "You don't have permission to do that!", "error")
        end
        ```

        High Complexity:
        ```lua
        -- High: Send notifications to multiple players with different types
        local players = player.GetAll()
        for _, ply in ipairs(players) do
            if ply:IsAdmin() then
                lia.notices.notify(ply, "Admin panel updated", "info")
            else
                lia.notices.notify(ply, "Welcome to the server!", "success")
            end
        end
        ```
    ]]
    function lia.notices.notify(client, message, notifType)
        net.Start("liaNotificationData")
        net.WriteString(message)
        net.WriteString(notifType or "default")
        if client then
            net.Send(client)
        else
            net.Broadcast()
        end
    end

    --[[
        Purpose: Sends a localized notification message to a specific client or all clients
        When Called: When server needs to display a localized notification with parameter substitution
        Parameters:
            - client (Player|nil): Target player to send notification to, or nil for all players
            - key (string): Localization key for the message
            - notifType (string|nil): Type of notification ("default", "error", "success", "info", etc.)
            - ... (any): Variable arguments to substitute into the localized message
        Returns: None
        Realm: Server
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Send localized notification to all players
        lia.notices.notifyLocalized(nil, "server.restart", "info")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized notification with one parameter
        local player = Player(1)
        lia.notices.notifyLocalized(player, "player.welcome", "success", player:Name())
        ```

        High Complexity:
        ```lua
        -- High: Send localized notifications with multiple parameters
        local players = player.GetAll()
        for _, ply in ipairs(players) do
            local timeLeft = math.max(0, 300 - CurTime())
            lia.notices.notifyLocalized(ply, "server.restart.time", "warning",
                ply:Name(), math.floor(timeLeft / 60), timeLeft % 60)
        end
        ```
    ]]
    function lia.notices.notifyLocalized(client, key, notifType, ...)
        local args = {...}
        if client and type(client) ~= "Player" then
            table.insert(args, 1, client)
            client = nil
        end

        net.Start("liaNotifyLocal")
        net.WriteString(key)
        net.WriteUInt(#args, 8)
        for i = 1, #args do
            net.WriteString(tostring(args[i]))
        end

        net.WriteString(tostring(notifType or "default"))
        if client then
            net.Send(client)
        else
            net.Broadcast()
        end
    end
else
    --[[
        Purpose: Receives and displays notification messages from the server
        When Called: Automatically called when server sends notification data via network
        Parameters: None (reads from network stream)
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Function is called automatically when server sends notification
        -- No direct usage needed - handled by network receiver
        ```

        Medium Complexity:
        ```lua
        -- Medium: Custom network receiver with additional processing
        net.Receive("liaNotificationData", function()
            lia.notices.receiveNotify()
            -- Additional custom processing here
            print("Notification received from server")
        end)
        ```

        High Complexity:
        ```lua
        -- High: Override default behavior with custom notification handling
        local originalReceiveNotify = lia.notices.receiveNotify
        lia.notices.receiveNotify = function()
            local msg = net.ReadString() or ""
            local ntype = net.ReadString() or "default"

            -- Custom processing before creating notice
            if ntype == "error" then
                -- Log errors to file
                file.Append("notifications.log", os.date() .. ": " .. msg .. "\n")
            end

            -- Call original function
            originalReceiveNotify()
        end
        ```
    ]]
    function lia.notices.receiveNotify()
        local msg = net.ReadString() or ""
        local ntype = net.ReadString() or "default"
        local notice = vgui.Create("liaNotice")
        notice:SetText(msg)
        notice:SetType(ntype)
        table.insert(lia.notices, notice)
        OrganizeNotices()
        MsgC(Color(0, 255, 255), msg .. "\n")
        timer.Simple(0.15, function()
            local lp = LocalPlayer()
            if IsValid(lp) then lp:EmitSound("garrysmod/content_downloaded.wav", 50, 250, 1, CHAN_AUTO) end
        end)
    end

    net.Receive("liaNotificationData", lia.notices.receiveNotify)
    --[[
        Purpose: Receives and displays localized notification messages from the server
        When Called: Automatically called when server sends localized notification data via network
        Parameters: None (reads from network stream)
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Function is called automatically when server sends localized notification
        -- No direct usage needed - handled by network receiver
        ```

        Medium Complexity:
        ```lua
        -- Medium: Custom network receiver with additional processing
        net.Receive("liaNotifyLocal", function()
            lia.notices.receiveNotifyL()
            -- Additional custom processing here
            print("Localized notification received from server")
        end)
        ```

        High Complexity:
        ```lua
        -- High: Override default behavior with custom localized notification handling
        local originalReceiveNotifyL = lia.notices.receiveNotifyL
        lia.notices.receiveNotifyL = function()
            local key = net.ReadString() or ""
            local argc = net.ReadUInt(8) or 0
            local args = {}
            for i = 1, argc do
                args[i] = net.ReadString()
            end

            -- Custom processing before creating notice
            local msg = L(key, unpack(args))
            if string.find(msg, "error") then
                -- Log errors to file
                file.Append("notifications.log", os.date() .. ": " .. msg .. "\n")
            end

            -- Call original function
            originalReceiveNotifyL()
        end
        ```
    ]]
    function lia.notices.receiveNotifyL()
        local key = net.ReadString() or ""
        local argc = net.ReadUInt(8) or 0
        local args = {}
        for i = 1, argc do
            args[i] = net.ReadString()
        end

        local ntype = net.ReadString() or "default"
        local msg = L(key, unpack(args))
        local notice = vgui.Create("liaNotice")
        notice:SetText(tostring(msg))
        notice:SetType(ntype)
        table.insert(lia.notices, notice)
        OrganizeNotices()
        MsgC(Color(0, 255, 255), tostring(msg) .. "\n")
        timer.Simple(0.15, function()
            local lp = LocalPlayer()
            if IsValid(lp) then lp:EmitSound("garrysmod/content_downloaded.wav", 50, 250, 1, CHAN_AUTO) end
        end)
    end

    net.Receive("liaNotifyLocal", lia.notices.receiveNotifyL)
    --[[
        Purpose: Creates and displays a notification message directly on the client
        When Called: When client needs to display a notification without server communication
        Parameters:
            - _ (any): Ignored parameter (for compatibility with server version)
            - message (string): The notification message text to display
            - notifType (string|nil): Type of notification ("default", "error", "success", "info", etc.)
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Display basic notification
        lia.notices.notify(nil, "Settings saved!", "success")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Display notification with dynamic content
        local playerName = LocalPlayer():Name()
        lia.notices.notify(nil, "Welcome back, " .. playerName .. "!", "info")
        ```

        High Complexity:
        ```lua
        -- High: Display notifications based on conditions
        local player = LocalPlayer()
        if player:GetNWInt("health") < 25 then
            lia.notices.notify(nil, "Health critical! Find medical attention!", "error")
        elseif player:GetNWInt("health") < 50 then
            lia.notices.notify(nil, "Health low - be careful!", "warning")
        else
            lia.notices.notify(nil, "Health status: Good", "success")
        end
        ```
    ]]
    function lia.notices.notify(_, message, notifType)
        local notice = vgui.Create("liaNotice")
        notice:SetText(tostring(message))
        notice:SetType(tostring(notifType or "default"))
        table.insert(lia.notices, notice)
        OrganizeNotices()
        MsgC(Color(0, 255, 255), tostring(message) .. "\n")
        timer.Simple(0.15, function()
            local lp = LocalPlayer()
            if IsValid(lp) then lp:EmitSound("garrysmod/content_downloaded.wav", 50, 250, 1, CHAN_AUTO) end
        end)
    end

    --[[
        Purpose: Creates and displays a localized notification message directly on the client
        When Called: When client needs to display a localized notification without server communication
        Parameters:
            - client (any): Ignored parameter (for compatibility with server version)
            - key (string): Localization key for the message
            - notifType (string|nil): Type of notification ("default", "error", "success", "info", etc.)
            - ... (any): Variable arguments to substitute into the localized message
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Display localized notification
        lia.notices.notifyLocalized(nil, "ui.settings.saved", "success")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Display localized notification with one parameter
        local playerName = LocalPlayer():Name()
        lia.notices.notifyLocalized(nil, "ui.welcome.back", "info", playerName)
        ```

        High Complexity:
        ```lua
        -- High: Display localized notifications with multiple parameters
        local player = LocalPlayer()
        local health = player:GetNWInt("health")
        local maxHealth = player:GetMaxHealth()
        local healthPercent = math.floor((health / maxHealth) * 100)

        if health < 25 then
            lia.notices.notifyLocalized(nil, "ui.health.critical", "error",
                health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyLocalized(nil, "ui.health.low", "warning",
                health, maxHealth, healthPercent)
        else
            lia.notices.notifyLocalized(nil, "ui.health.good", "success",
                health, maxHealth, healthPercent)
        end
        ```
    ]]
    function lia.notices.notifyLocalized(client, key, notifType, ...)
        lia.notices.notify(client, L(key, ...), notifType or "default")
    end

    --[[
        Purpose: Provides compatibility with Garry's Mod's legacy notification system
        When Called: When legacy notification functions are used (e.g., notification.AddLegacy)
        Parameters:
            - text (string): The notification message text to display
            - typeId (number): Legacy notification type ID (0=info, 1=error, 2=success)
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Use legacy notification system
        notification.AddLegacy("Server restarting!", 0)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Convert legacy notifications to new system
        local legacyTypes = {[0] = "info", [1] = "error", [2] = "success"}
        local message = "Player disconnected"
        local typeId = 1
        notification.AddLegacy(message, typeId)
        ```

        High Complexity:
        ```lua
        -- High: Override legacy notification with custom handling
        local originalAddLegacy = notification.AddLegacy
        notification.AddLegacy = function(text, typeId)
            local map = {[0] = "info", [1] = "error", [2] = "success"}
            local notifType = map[tonumber(typeId) or -1] or "default"

            -- Custom processing
            if notifType == "error" then
                -- Log errors to file
                file.Append("legacy_notifications.log", os.date() .. ": " .. text .. "\n")
            end

            -- Call original function
            originalAddLegacy(text, typeId)
        end
        ```
    ]]
    function notification.AddLegacy(text, typeId)
        local map = {
            [0] = "info",
            [1] = "error",
            [2] = "success"
        }

        lia.notices.notify(nil, tostring(text), map[tonumber(typeId) or -1] or "default")
    end
end

--[[
    Purpose: Organizes and positions notification panels on the screen
    When Called: Automatically called when new notifications are created
    Parameters: None
    Returns: None
    Realm: Client
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Function is called automatically when notifications are created
    -- No direct usage needed - handled internally
    ```

    Medium Complexity:
    ```lua
    -- Medium: Manually organize notices after bulk creation
    for i = 1, 5 do
        lia.notices.notify(nil, "Notification " .. i, "info")
    end
    OrganizeNotices() -- Ensure proper positioning
    ```

    High Complexity:
    ```lua
    -- High: Custom notice organization with different positioning
    local originalOrganizeNotices = OrganizeNotices
    OrganizeNotices = function()
        local scale = ScrH() / 1080
        local baseY = ScrH() - 300 * scale -- Different base position
        local spacing = 8 * scale -- Different spacing
        local y = baseY

        for _, v in ipairs(lia.notices) do
            if IsValid(v) then
                v.targetY = y
                -- Add custom animation
                v:MoveTo(v:GetX(), y, 0.3, 0, 0.5)
                y = y - (v:GetTall() + spacing)
            end
        end
    end
    ```
]]
function OrganizeNotices()
    local scale = ScrH() / 1080
    local baseY = ScrH() - 200 * scale
    local spacing = 4 * scale
    local y = baseY
    for _, v in ipairs(lia.notices) do
        if IsValid(v) then
            v.targetY = y
            y = y - (v:GetTall() + spacing)
        end
    end
end
