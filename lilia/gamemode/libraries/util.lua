--- Various useful helper functions.
-- @module lia.util
lia.util.cachedMaterials = lia.util.cachedMaterials or {}
--- Removes the realm prefix from a file name. The returned string will be unchanged if there is no prefix found.
-- @realm shared
-- @string name String to strip prefix from
-- @treturn string String stripped of prefix
-- @usage print(lia.util.stripRealmPrefix("sv_init.lua"))
-- > init.lua
function lia.util.stripRealmPrefix(name)
    local prefix = name:sub(1, 3)
    return (prefix == "sh_" or prefix == "sv_" or prefix == "cl_") and name:sub(4) or name
end

--- Attempts to find a player by matching their name or Steam ID.
-- @realm shared
-- @string identifier Search query
-- @bool[opt=false] allowPatterns Whether or not to accept Lua patterns in `identifier`
-- @treturn player Player that matches the given search query - this will be `nil` if a player could not be found
function lia.util.findPlayer(identifier, allowPatterns)
    if lia.util.isSteamID(identifier) then return player.GetBySteamID(identifier) end
    if not allowPatterns then identifier = string.PatternSafe(identifier) end
    for _, v in ipairs(player.GetAll()) do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

--- Emits sounds one after the other from an entity.
-- @realm shared
-- @entity entity Entity to play sounds from
-- @tab sounds Sound paths to play
-- @number delay[opt=0] How long to wait before starting to play the sounds
-- @number spacing[opt=0.1] How long to wait between playing each sound
-- @number volume[opt=75] The sound level of each sound
-- @number pitch[opt=100] Pitch percentage of each sound
-- @treturn number How long the entire sequence of sounds will take to play
function lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
    delay = delay or 0
    spacing = spacing or 0.1
    for _, v in ipairs(sounds) do
        local postSet, preSet = 0, 0
        if istable(v) then
            postSet, preSet = v[2] or 0, v[3] or 0
            v = v[1]
        end

        local length = SoundDuration(SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/" .. v)
        delay = delay + preSet
        timer.Simple(delay, function() if IsValid(entity) then entity:EmitSound(v, volume, pitch) end end)
        delay = delay + length + postSet + spacing
    end
    return delay
end

--- Checks to see if two strings are equivalent using a fuzzy manner. Both strings will be lowered, and will return `true` if
-- the strings are identical, or if `b` is a substring of `a`.
-- @realm shared
-- @string a First string to check
-- @string b Second string to check
-- @treturn bool Whether or not the strings are equivalent
function lia.util.stringMatches(a, b)
    if a and b then
        local a2, b2 = a:lower(), b:lower()
        if a == b then return true end
        if a2 == b2 then return true end
        if a:find(b) then return true end
        if a2:find(b2) then return true end
    end
    return false
end

--- Rounds a vector to the nearest multiple of a given grid size.
-- @realm shared
-- @vector vec Vector to be rounded
-- @int gridSize Grid size to round to
-- @treturn Vector The rounded vector
function lia.util.gridVector(vec, gridSize)
    if gridSize <= 0 then gridSize = 1 end
    for i = 1, 3 do
        vec[i] = vec[i] / gridSize
        vec[i] = math.Round(vec[i])
        vec[i] = vec[i] * gridSize
    end
    return vec
end

--- Retrieves the SteamIDs of all connected players.
-- @treturn table Table containing SteamIDs of all connected players
-- @realm shared
function lia.util.getAllChar()
    local charTable = {}
    for _, v in ipairs(player.GetAll()) do
        if v:getChar() then table.insert(charTable, v:getChar():getID()) end
    end
    return charTable
end

--- Checks if a given value is a SteamID.
-- @string value The value to check
-- @treturn boolean True if the value is a SteamID, false otherwise
-- @realm shared
function lia.util.isSteamID(value)
    if string.match(value, "STEAM_(%d+):(%d+):(%d+)") then return true end
    return false
end

--- Converts a date string to a table containing date and time components.
-- @string str The date string in the format "YYYY-MM-DD HH:MM:SS"
-- @treturn table Table containing date and time components
-- @realm shared
function lia.util.dateToNumber(str)
    str = str or os.date("%Y-%m-%d %H:%M:%S", os.time())
    return {
        year = tonumber(str:sub(1, 4)),
        month = tonumber(str:sub(6, 7)),
        day = tonumber(str:sub(9, 10)),
        hour = tonumber(str:sub(12, 13)),
        min = tonumber(str:sub(15, 16)),
        sec = tonumber(str:sub(18, 19)),
    }
end

--- Retrieves all online players with administrative permissions.
-- @treturn table Table containing all online players with administrative permissions
-- @realm shared
function lia.util.getAdmins()
    local staff = {}
    for _, client in ipairs(player.GetAll()) do
        local hasPermission = CAMI.PlayerHasAccess(client, "UserGroups - Staff Group", nil)
        if hasPermission then staff[#staff + 1] = client end
    end
    return staff
end

--- Finds a player by their SteamID64.
-- @string SteamID64 The SteamID64 of the player to find
-- @treturn Player The player object if found, nil otherwise
-- @realm shared
function lia.util.findPlayerBySteamID64(SteamID64)
    for _, client in ipairs(player.GetAll()) do
        if client:SteamID64() == SteamID64 then return client end
    end
    return nil
end

--- Finds a player by their SteamID.
-- @string SteamID The SteamID of the player to find
-- @treturn Player The player object if found, nil otherwise
-- @realm shared
function lia.util.findPlayerBySteamID(SteamID)
    for _, client in ipairs(player.GetAll()) do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

--- Checks if a position can fit a player's collision hull.
-- @vector pos The position to check
-- @vector[opt] mins The minimum size of the collision hull
-- @vector[opt] maxs The maximum size of the collision hull
-- @tab[opt] filter Entities to filter out from the collision check
-- @treturn boolean True if the position can fit the collision hull, false otherwise
-- @realm shared
function lia.util.canFit(pos, mins, maxs, filter)
    mins = mins ~= nil and mins or Vector(16, 16, 0)
    local tr = util.TraceHull({
        start = pos + Vector(0, 0, 1),
        mask = MASK_PLAYERSOLID,
        filter = filter,
        endpos = pos,
        mins = mins.x > 0 and mins * -1 or mins,
        maxs = maxs ~= nil and maxs or mins
    })
    return not tr.Hit
end

--- Rolls a chance based on a given probability.
-- @int chance The probability of success in percentage
-- @treturn boolean True if the chance is successful, false otherwise
-- @realm shared
function lia.util.chance(chance)
    local rand = math.random(0, 100)
    if rand <= chance then return true end
    return false
end

--- Retrieves all players within a certain radius from a given position.
-- @vector pos The center position
-- @int dist The maximum distance from the center
-- @treturn table Table containing players within the specified radius
-- @realm shared
function lia.util.playerInRadius(pos, dist)
    dist = dist * dist
    local t = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():DistToSqr(pos) < dist then t[#t + 1] = ply end
    end
    return t
end

if SERVER then
    --- Notifies a player or all players with a message.
    -- @realm server
    -- @string message The message to be notified
    -- @client recipient The player to receive the notification
    function lia.util.notify(message, recipient)
        net.Start("liaNotify")
        net.WriteString(message)
        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
    end

    lia.util.Notify = lia.util.notify
    --- Spawns entities from a table of entity-position pairs.
    -- @realm server
    -- @tab entityTable Table containing entity-position pairs
    function lia.util.spawnEntities(entityTable)
        for entity, position in pairs(entityTable) do
            if isvector(position) then
                local newEnt = ents.Create(entity)
                if IsValid(newEnt) then
                    newEnt:SetPos(position)
                    newEnt:Spawn()
                end
            else
                print("Invalid position for entity", entity)
            end
        end
    end

    --- Notifies a player or all players with a localized message.
    -- @realm server
    -- @string message The localized message to be notified
    -- @client recipient The player to receive the notification
    -- @param ... Additional parameters for message formatting
    function lia.util.notifyLocalized(message, recipient, ...)
        local args = {...}
        if recipient ~= nil and not istable(recipient) and type(recipient) ~= "Player" then
            table.insert(args, 1, recipient)
            recipient = nil
        end

        net.Start("liaNotifyL")
        net.WriteString(message)
        net.WriteUInt(#args, 8)
        for i = 1, #args do
            net.WriteString(tostring(args[i]))
        end

        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
    end

    lia.util.NotifyLocalized = lia.util.notifyLocalized
    --- Finds empty spaces around an entity where another entity can be placed.
    -- @realm server
    -- @client entity The client to find empty spaces around
    -- @tab[opt] filter Entities to filter out from the collision check
    -- @int spacing Spacing between empty spaces (default is 32 units)
    -- @int size Size of the search grid (default is 3)
    -- @int height Height of the search grid (default is 36 units)
    -- @int tolerance Tolerance for collision checking (default is 5 units)
    -- @return Table containing positions of empty spaces
    function lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)
        spacing = spacing or 32
        size = size or 3
        height = height or 36
        tolerance = tolerance or 5
        local position = entity:GetPos()
        local mins = Vector(-spacing * 0.5, -acing * 0.5, 0)
        local maxs = Vector(spacing * 0.5, sping * 0.5, height)
        local output = {}
        for x = -size, size do
            for y = -size, size do
                local origin = position + Vecr(x * spacing, y * spacing, 0)
                local data = {}
                data.start = origin + mins + Vector(0, 0, tolerance)
                data.endpos = origin + maxs
                data.filter = filter or entity
                local trace = util.TraceLine(data)
                data.start = origin + Vector(-maxs.x, -maxs.y, tolerance)
                data.endpos = origin + Vector(mins.x, mins.y, height)
                local trace2 = util.TraceLine(data)
                if trace.StartSolid or trace.Hit or trace2.StartSolid or trace2.Hit or not util.IsInWorld(origin) then continue end
                output[#output + 1] = origin
            end
        end

        table.sort(output, function(a, b) return a:Distance(position) < b:Distance(position) end)
        return output
    end

    --- Spawns a prop at a given position with optional parameters.
    -- @realm server
    -- @string model Model of the prop to spawn
    -- @vector position Position to spawn the prop
    -- @param[opt] force Force to apply to the prop
    -- @int[opt] lifetime Lifetime of the prop in seconds
    -- @angle[opt] angles Angles of the prop
    -- @param[opt] collision Collision group of the prop
    -- @return The spawned prop entity
    function lia.util.spawnProp(model, position, force, lifetime, angles, collision)
        local entity = ents.Create("prop_physics")
        entity:SetModel(model)
        entity:Spawn()
        entity:SetCollisionGroup(collision or COLLISION_GROUP_WEAPON)
        entity:SetAngles(angles or angle_zero)
        if type(position) == "Player" then position = position:GetItemDropPos(entity) end
        entity:SetPos(position)
        if force then
            local phys = entity:GetPhysicsObject()
            if IsValid(phys) then phys:ApplyForceCenter(force) end
        end

        if (lifetime or 0) > 0 then timer.Simple(lifetime, function() if IsValid(entity) then entity:Remove() end end) end
        return entity
    end

    --- Logs a message with a timestamp to the console.
    -- @realm server
    -- @string str The message to be logged
    function lia.util.debugLog(str)
        MsgC(Color("sky_blue"), os.date("(%d/%m/%Y - %H:%M:%S)", os.time()), Color("yellow"), " [LOG] ", color_white, str, "\n")
    end

    --- Logs a debug message to the console.
    -- @realm server
    -- @string msg The debug message string
    -- @tab ... Additional parameters for message formatting
    function lia.util.debugMessage(msg, ...)
        MsgC(Color(70, 150, 255), "[CityRP] DEBUG: ", string.format(msg, ...), "\n")
    end

    --- Logs a warning message to the console.
    -- @realm server
    -- @string message The warning message string
    -- @tab ... Additional parameters for message formatting
    function lia.util.dWarningMessage(message, ...)
        MsgC(Color(255, 100, 0), string.format(message, ...), "\n")
    end

    --- Prints a message to a player's chat.
    -- @realm server
    -- @client target The player to receive the chat message
    -- @tab ... The message or messages to print
    function lia.util.ChatNotify(target, ...)
        netstream.Start(target, "ChatPrint", {...})
    end
else
    --- Draws some text with a shadow.
    -- @realm client
    -- @string text Text to draw
    -- @number x X-position of the text
    -- @number y Y-position of the text
    -- @color color Color of the text to draw
    -- @number[opt=TEXT_ALIGN_LEFT] alignX Horizontal alignment of the text, using one of the `TEXT_ALIGN_*` constants
    -- @number[opt=TEXT_ALIGN_LEFT] alignY Vertical alignment of the text, using one of the `TEXT_ALIGN_*` constants
    -- @string[opt="ixGenericFont"] font Font to use for the text
    -- @number[opt=color.a * 0.575] alpha Alpha of the shadow
    function lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
        color = color or color_white
        return draw.TextShadow({
            text = text,
            font = font or "liaGenericFont",
            pos = {x, y},
            color = color,
            xalign = alignX or 0,
            yalign = alignY or 0
        }, 1, alpha or (color.a * 0.575))
    end

    --- Draws a textured rectangle with a specified material and color.
    -- @realm client
    -- @string material Material to use for the texture
    -- @color color Color of the texture to draw
    -- @int x X-position of the top-left corner of the rectangle
    -- @int y Y-position of the top-left corner of the rectangle
    -- @int w Width of the rectangle
    -- @int h Height of the rectangle
    function lia.util.drawTexture(material, color, x, y, w, h)
        surface.SetDrawColor(color or color_white)
        surface.SetMaterial(lia.util.getMaterial(material))
        surface.DrawTexturedRect(x, y, w, h)
    end

    --- Calls a named skin function with optional arguments on a panel.
    -- @realm client
    -- @string name Name of the skin function to call
    -- @param[opt] panel Panel to apply the skin function to
    -- @param[opt] a Argument 1
    -- @param[opt] b Argument 2
    -- @param[opt] c Argument 3
    -- @param[opt] d Argument 4
    -- @param[opt] e Argument 5
    -- @param[opt] f Argument 6
    -- @param[opt] g Argument 7
    -- @return The result of the skin function call
    function lia.util.skinFunc(name, panel, a, b, c, d, e, f, g)
        local skin = (ispanel(panel) and IsValid(panel)) and panel:GetSkin() or derma.GetDefaultSkin()
        if not skin then return end
        local func = skin[name]
        if not func then return end
        return func(skin, panel, a, b, c, d, e, f, g)
    end

    --- Wraps text so it does not pass a certain width. This function will try and break lines between words if it can,
    -- otherwise it will break a word if it's too long.
    -- @realm client
    -- @string text Text to wrap
    -- @number width Maximum allowed width in pixels
    -- @string[opt="liaChatFont"] font Font to use for the text
    function lia.util.wrapText(text, width, font)
        font = font or "liaChatFont"
        surface.SetFont(font)
        local exploded = string.Explode("%s", text, true)
        local line = ""
        local lines = {}
        local w = surface.GetTextSize(text)
        local maxW = 0
        if w <= width then
            text, _ = text:gsub("%s", " ")
            return {text}, w
        end

        for i = 1, #exploded do
            local word = exploded[i]
            line = line .. " " .. word
            w = surface.GetTextSize(line)
            if w > width then
                lines[#lines + 1] = line
                line = ""
                if w > maxW then maxW = w end
            end
        end

        if line ~= "" then lines[#lines + 1] = line end
        return lines, maxW
    end

    --- Displays a notification message in the chat.
    -- @string message The message to display
    -- @realm client
    function lia.util.notify(message)
        chat.AddText(message)
    end

    lia.util.Notify = lia.util.notify
    --- Displays a localized notification message in the chat.
    -- @realm client
    -- @string message The message to display (localized)
    -- @param ... Additional parameters for string formatting
    function lia.util.notifyLocalized(message, ...)
        lia.util.notify(L(message, ...))
    end

    lia.util.NotifyLocalized = lia.util.notifyLocalized
    --- Converts a color object to a string representation.
    -- @realm client
    -- @color color The color object to convert
    -- @return A string representation of the color in the format "r,g,b,a"
    function lia.util.colorToText(color)
        if not IsColor(color) then return end
        return (color.r or 255) .. "," .. (color.g or 255) .. "," .. (color.b or 255) .. "," .. (color.a or 255)
    end

    --- Displays a caption message on the screen for a specified duration.
    -- @realm client
    -- @string text The caption text to display
    -- @int[opt] duration The duration (in seconds) for which to display the caption
    function lia.util.endCaption(text, duration)
        RunConsoleCommand("closecaption", "1")
        gui.AddCaption(text, duration or string.len(text) * 0.1)
    end

    --- Displays a caption message on the screen for a specified duration.
    -- @realm client
    -- @string text The caption text to display
    -- @int[opt] duration The duration (in seconds) for which to display the caption
    function lia.util.startCaption(text, duration)
        RunConsoleCommand("closecaption", "1")
        gui.AddCaption(text, duration or string.len(text) * 0.1)
    end

    --- Determines the color indicating the health status of a player.
    -- @realm client
    -- @client client The player for which to determine the color
    -- @return The color representing the player's health status
    function lia.util.getInjuredColor(client)
        local health_color = color_white
        if not IsValid(client) then return health_color end
        local health, healthMax = client:Health(), client:GetMaxHealth()
        if (health / healthMax) < .95 then health_color = lia.color.LerpHSV(nil, nil, healthMax, health, 0) end
        return health_color
    end

    --- Scales a value proportionally based on the screen height.
    -- @realm client
    -- @int n The value to scale
    -- @bool bool If true, scales based on vertical resolution; if false or nil, scales based on default values
    -- @return The scaled value
    function lia.util.screenScaleH(n, bool)
        if bool then
            if ScrH() > 720 then return n end
            return math.ceil(n / 1080 * ScrH())
        end
        return n * (ScrH() / 480)
    end

    timer.Create("liaResolutionMonitor", 1, 0, function()
        local scrW, scrH = ScrW(), ScrH()
        if scrW ~= LAST_WIDTH or scrH ~= LAST_HEIGHT then
            hook.Run("ScreenResolutionChanged", LAST_WIDTH, LAST_HEIGHT)
            LAST_WIDTH = scrW
            LAST_HEIGHT = scrH
        end
    end)

    --- Displays a numeric input request dialog.
    -- @realm client
    -- @string strTitle The title of the dialog window
    -- @string strText The text to display in the dialog
    -- @string strDefaultText The default text to display in the input field
    -- @func fnEnter The function to call when the Enter key is pressed, with the input value as its argument
    -- @func[opt] fnCancel The function to call when the dialog is canceled or closed, with the input value as its argument
    -- @string[opt] strButtonText The text to display on the confirmation button
    -- @string[opt] strButtonCancelText The text to display on the cancel button
    -- @return The created DFrame window
    function Derma_NumericRequest(strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText)
        local Window = vgui.Create("DFrame")
        Window:SetTitle(strTitle or "Message Title (First Parameter)")
        Window:SetDraggable(false)
        Window:ShowCloseButton(false)
        Window:SetBackgroundBlur(true)
        Window:SetDrawOnTop(true)
        local InnerPanel = vgui.Create("DPanel", Window)
        InnerPanel:SetPaintBackground(false)
        local Text = vgui.Create("DLabel", InnerPanel)
        Text:SetText(strText or "Message Text (Second Parameter)")
        Text:SizeToContents()
        Text:SetContentAlignment(5)
        Text:SetTextColor(color_white)
        local TextEntry = vgui.Create("DTextEntry", InnerPanel)
        TextEntry:SetValue(strDefaultText or "")
        TextEntry.OnEnter = function()
            Window:Close()
            fnEnter(TextEntry:GetValue())
        end

        TextEntry:SetNumeric(true)
        local ButtonPanel = vgui.Create("DPanel", Window)
        ButtonPanel:SetTall(30)
        ButtonPanel:SetPaintBackground(false)
        local Button = vgui.Create("DButton", ButtonPanel)
        Button:SetText(strButtonText or "OK")
        Button:SizeToContents()
        Button:SetTall(20)
        Button:SetWide(Button:GetWide() + 20)
        Button:SetPos(5, 5)
        Button.DoClick = function()
            Window:Close()
            fnEnter(TextEntry:GetValue())
        end

        local ButtonCancel = vgui.Create("DButton", ButtonPanel)
        ButtonCancel:SetText(strButtonCancelText or L"derma_request_cancel")
        ButtonCancel:SizeToContents()
        ButtonCancel:SetTall(20)
        ButtonCancel:SetWide(Button:GetWide() + 20)
        ButtonCancel:SetPos(5, 5)
        ButtonCancel.DoClick = function()
            Window:Close()
            if fnCancel then fnCancel(TextEntry:GetValue()) end
        end

        ButtonCancel:MoveRightOf(Button, 5)
        ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10)
        local w, h = Text:GetSize()
        w = math.max(w, 400)
        Window:SetSize(w + 50, h + 25 + 75 + 10)
        Window:Center()
        InnerPanel:StretchToParent(5, 25, 5, 45)
        Text:StretchToParent(5, 5, 5, 35)
        TextEntry:StretchToParent(5, nil, 5, nil)
        TextEntry:AlignBottom(5)
        TextEntry:RequestFocus()
        TextEntry:SelectAllText(true)
        ButtonPanel:CenterHorizontal()
        ButtonPanel:AlignBottom(8)
        Window:MakePopup()
        Window:DoModal()
        return Window
    end

    --- Displays a query notification panel with options.
    -- @realm client
    -- @string question The question or prompt to display
    -- @string option1 The text for the first option
    -- @string option2 The text for the second option
    -- @bool manualDismiss If true, the panel requires manual dismissal
    -- @int notifType The type of notification
    -- @func callback The function to call when an option is selected, with the option index and the notice panel as arguments
    -- @return The created notification panel
    function lia.util.notifQuery(question, option1, option2, manualDismiss, notifType, callback)
        if not callback or not isfunction(callback) then Error("A callback function must be specified") end
        if not question or not isstring(question) then Error("A question string must be specified") end
        if not option1 then option1 = "Yes" end
        if not option2 then option2 = "No" end
        if not manualDismiss then manualDismiss = false end
        local notice = CreateNoticePanel(10, manualDismiss)
        local i = table.insert(lia.noticess, notice)
        notice.isQuery = true
        notice.text:SetText(question)
        notice:SetPos(0, (i - 1) * (notice:GetTall() + 4) + 4)
        notice:SetTall(36 * 2.3)
        notice:CalcWidth(120)
        notice:CenterHorizontal()
        notice.notifType = notifType or 7
        if manualDismiss then notice.start = nil end
        notice.opt1 = notice:Add("DButton")
        notice.opt1:SetAlpha(0)
        notice.opt2 = notice:Add("DButton")
        notice.opt2:SetAlpha(0)
        notice.oh = notice:GetTall()
        OrganizeNotices(false)
        notice:SetTall(0)
        notice:SizeTo(notice:GetWide(), 36 * 2.3, 0.2, 0, -1, function()
            notice.text:SetPos(0, 0)
            local function styleOpt(o)
                o.color = Color(0, 0, 0, 30)
                AccessorFunc(o, "color", "Color")
                function o:Paint(w, h)
                    if self.left then
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, true, false)
                    else
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, false, true)
                    end
                end
            end

            if notice.opt1 and IsValid(notice.opt1) then
                notice.opt1:SetAlpha(255)
                notice.opt1:SetSize(notice:GetWide() / 2, 25)
                notice.opt1:SetText(option1 .. " (F8)")
                notice.opt1:SetPos(0, notice:GetTall() - notice.opt1:GetTall())
                notice.opt1:CenterHorizontal(0.25)
                notice.opt1:SetAlpha(0)
                notice.opt1:AlphaTo(255, 0.2)
                notice.opt1:SetTextColor(color_white)
                notice.opt1.left = true
                styleOpt(notice.opt1)
                function notice.opt1:keyThink()
                    if input.IsKeyDown(KEY_F8) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(1, notice)
                        timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                        notice.lastKey = CurTime()
                    end
                end
            end

            if notice.opt2 and IsValid(notice.opt2) then
                notice.opt2:SetAlpha(255)
                notice.opt2:SetSize(notice:GetWide() / 2, 25)
                notice.opt2:SetText(option2 .. " (F9)")
                notice.opt2:SetPos(0, notice:GetTall() - notice.opt2:GetTall())
                notice.opt2:CenterHorizontal(0.75)
                notice.opt2:SetAlpha(0)
                notice.opt2:AlphaTo(255, 0.2)
                notice.opt2:SetTextColor(color_white)
                styleOpt(notice.opt2)
                function notice.opt2:keyThink()
                    if input.IsKeyDown(KEY_F9) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(2, notice)
                        timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                        notice.lastKey = CurTime()
                    end
                end
            end

            notice.lastKey = CurTime()
            notice.respondToKeys = true
            function notice:Think()
                if not self.respondToKeys then return end
                local queries = {}
                for _, v in pairs(lia.noticess) do
                    if v.isQuery then queries[#queries + 1] = v end
                end

                for k, v in pairs(queries) do
                    if v == self and k > 1 then return end
                end

                if self.opt1 and IsValid(self.opt1) then self.opt1:keyThink() end
                if self.opt2 and IsValid(self.opt2) then self.opt2:keyThink() end
            end
        end)
        return notice
    end

    local useCheapBlur = CreateClientConVar("lia_cheapblur", 0, true):GetBool()
    --- Blurs the content underneath the given panel. This will fall back to a simple darkened rectangle if the player has
    -- blurring disabled.
    -- @realm client
    -- @tparam panel panel Panel to draw the blur for
    -- @number[opt=5] amount Intensity of the blur. This should be kept between 0 and 10 for performance reasons
    -- @number[opt=0.2] passes Quality of the blur. This should be kept as default
    -- @usage function PANEL:Paint(width, height)
    -- 	lia.util.drawBlur(self)
    -- end
    function lia.util.drawBlur(panel, amount, passes)
        amount = amount or 5
        if useCheapBlur then
            surface.SetDrawColor(50, 50, 50, amount * 20)
            surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
        else
            surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
            surface.SetDrawColor(255, 255, 255)
            local x, y = panel:LocalToScreen(0, 0)
            for i = -(passes or 0.2), 1, 0.2 do
                lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
                lia.util.getMaterial("pp/blurscreen"):Recompute()
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
            end
        end
    end

    --- Draws a blurred rectangle with the given position and bounds. This shouldn't be used for panels, see `lia.util.drawBlur`
    -- instead.
    -- @realm client
    -- @number x X-position of the rectangle
    -- @number y Y-position of the rectangle
    -- @number w Width of the rectangle
    -- @number h Height of the rectangle
    -- @number[opt=5] amount Intensity of the blur. This should be kept between 0 and 10 for performance reasons
    -- @number[opt=0.2] passes Quality of the blur. This should be kept as default
    -- @usage hook.Add("HUDPaint", "MyHUDPaint", function()
    -- 	lia.util.drawBlurAt(0, 0, ScrW(), ScrH())
    -- end)
    function lia.util.drawBlurAt(x, y, w, h, amount, passes)
        amount = amount or 5
        if useCheapBlur then
            surface.SetDrawColor(30, 30, 30, amount * 20)
            surface.DrawRect(x, y, w, h)
        else
            surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
            surface.SetDrawColor(255, 255, 255)
            local scrW, scrH = ScrW(), ScrH()
            local x2, y2 = x / scrW, y / scrH
            local w2, h2 = (x + w) / scrW, (y + h) / scrH
            for i = -(passes or 0.2), 1, 0.2 do
                lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
                lia.util.getMaterial("pp/blurscreen"):Recompute()
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
            end
        end
    end

    file.CreateDir("lilia/images")
    lia.util.LoadedImages = lia.util.LoadedImages or {
        [0] = Material("icon16/cross.png")
    }

    --- Fetches an image from either local data or a remote server and provides it to a callback function.
    -- @realm client
    -- @string id The unique identifier or filename of the image
    -- @func callback The function to call with the loaded image material as its argument, or false if the image could not be loaded
    -- @string[opt] pngParameters parameters for loading PNG images (default is "noclamp smooth")
    -- @string[opt] imageProvider URL for the remote image provider (default is "https://i.imgur.com/")
    function lia.util.fetchImage(id, callback, pngParameters, imageProvider)
        local loadedImage = lia.util.LoadedImages[id]
        if loadedImage then
            if callback then callback(loadedImage) end
            return
        end

        if file.Exists("lilia/images/" .. id .. ".png", "DATA") then
            local mat = Material("data/lilia/images/" .. id .. ".png", pngParameters or "noclamp smooth")
            if mat then
                lia.util.LoadedImages[id] = mat
                if callback then callback(mat) end
            elseif callback then
                callback(false)
            end
        else
            http.Fetch((imageProvider or "https://i.imgur.com/") .. id .. ".png", function(body, _, _, code)
                if code ~= 200 then
                    callback(false)
                    return
                end

                if not body or body == "" then
                    callback(false)
                    return
                end

                file.Write("lilia/images/" .. id .. ".png", body)
                local mat = Material("data/lilia/images/" .. id .. ".png", "noclamp smooth")
                lia.util.LoadedImages[id] = mat
                if callback then callback(mat) end
            end, function() if callback then callback(false) end end)
        end
    end

    cvars.AddChangeCallback("lia_cheapblur", function(_, _, new) useCheapBlur = (tonumber(new) or 0) > 0 end)
end

--- Returns a cached copy of the given material, or creates and caches one if it doesn't exist. This is a quick helper function.
-- if you aren't locally storing a `Material()` call.
-- @realm shared
-- @string materialPath Path to the material
-- @treturn[1] material The cached material
-- @treturn[2] nil If the material doesn't exist in the filesystem
function lia.util.getMaterial(materialPath)
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath)
    return lia.util.cachedMaterials[materialPath]
end

lia.util.FindPlayer = lia.util.findPlayer
lia.util.EmitQueuedSounds = lia.util.emitQueuedSounds
lia.util.StringMatches = lia.util.stringMatches
lia.util.GridVector = lia.util.gridVector
lia.util.GetAllChar = lia.util.getAllChar
lia.util.IsSteamID = lia.util.isSteamID
lia.util.DateToNumber = lia.util.dateToNumber
lia.util.GetAdmins = lia.util.getAdmins
lia.util.FindPlayerBySteamID64 = lia.util.findPlayerBySteamID64
lia.util.FindPlayerBySteamID = lia.util.findPlayerBySteamID
lia.util.CanFit = lia.util.canFit
lia.util.Chance = lia.util.chance
lia.util.PlayerInRadius = lia.util.playerInRadius
lia.util.SpawnEntities = lia.util.spawnEntities
lia.util.FindEmptySpace = lia.util.findEmptySpace
lia.util.SpawnProp = lia.util.spawnProp
lia.util.DebugLog = lia.util.debugLog
lia.util.DebugMessage = lia.util.debugMessage
lia.util.DWarningMessage = lia.util.dWarningMessage
lia.util.ChatPrint = lia.util.chatPrint
lia.util.DrawText = lia.util.drawText
lia.util.DrawTexture = lia.util.drawTexture
lia.util.SkinFunc = lia.util.skinFunc
lia.util.WrapText = lia.util.wrapText
lia.util.ColorToText = lia.util.colorToText
lia.util.EndCaption = lia.util.endCaption
lia.util.StartCaption = lia.util.startCaption
lia.util.GetInjuredColor = lia.util.getInjuredColor
lia.util.ScreenScaleH = lia.util.screenScaleH
lia.util.NotifQuery = lia.util.notifQuery
lia.util.DrawBlur = lia.util.drawBlur
lia.util.DrawBlurAt = lia.util.drawBlurAt
lia.util.FetchImage = lia.util.fetchImage
lia.util.GetMaterial = lia.util.getMaterial
