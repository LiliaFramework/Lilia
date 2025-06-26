lia.command = lia.command or {}
lia.command.list = lia.command.list or {}
--[[
    lia.command.add(command, data)

    Description:
        Registers a new command with its associated data.

    Parameters:
        command (string) – Command name.
        data (table) – Table containing command properties.

    Returns:
        nil

    Realm:
        Shared
]]
function lia.command.add(command, data)
    data.syntax = data.syntax or ""
    data.desc = data.desc or ""
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    if not data.onRun then
        ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n")
        return
    end

    if superAdminOnly or adminOnly then
        local privilegeName = "Commands - " .. (isstring(data.privilege) and data.privilege or command)
        if not CAMI.GetPrivilege(privilegeName) then
            CAMI.RegisterPrivilege({
                Name = privilegeName,
                MinAccess = superAdminOnly and "superadmin" or "admin",
                Description = data.description
            })
        end
    end

    local onRun = data.onRun
    data._onRun = data.onRun
    data.onRun = function(client, arguments)
        local hasAccess, _ = lia.command.hasAccess(client, command, data)
        if hasAccess then
            return onRun(client, arguments)
        else
            return "noPerm"
        end
    end

    local alias = data.alias
    if alias then
        if istable(alias) then
            for _, v in ipairs(alias) do
                lia.command.list[v:lower()] = data
            end
        elseif isstring(alias) then
            lia.command.list[alias:lower()] = data
        end
    end

    if command == command:lower() then
        lia.command.list[command] = data
    else
        data.realCommand = command
        lia.command.list[command:lower()] = data
    end
end

--[[
    lia.command.hasAccess(client, command, data)

    Description:
        Determines if a player may run the specified command.

    Parameters:
        client (Player) – Command caller.
        command (string) – Command name.
        data (table) – Command data table.

    Returns:
        boolean – Whether access is granted.
        string – Privilege checked.

    Realm:
        Shared
]]
function lia.command.hasAccess(client, command, data)
    if not data then data = lia.command.list[command] end
    local privilege = data.privilege
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local accessLevels = superAdminOnly and "superadmin" or adminOnly and "admin" or "user"
    if not privilege then privilege = accessLevels == "user" and "Global" or command end
    local hasAccess = true
    if accessLevels ~= "user" then
        local privilegeName = "Commands - " .. privilege
        hasAccess = client:hasPrivilege(privilegeName)
    end

    if hook.Run("CanPlayerUseCommand", client, command) == false then hasAccess = false end
    return hasAccess, privilege
end

--[[
   lia.command.extractArgs

   Description:
      Splits the provided text into arguments, respecting quotes.
      Quoted sections are treated as single arguments.

   Parameters:
      text (string) - The raw input text to parse.

   Returns:
      table - A list of arguments extracted from the text.

   Realm:
      Shared

   Example Usage:
      local args = lia.command.extractArgs('/mycommand "quoted arg" anotherArg')
      -- args = {"quoted arg", "anotherArg"}
]]
function lia.command.extractArgs(text)
    local skip = 0
    local arguments = {}
    local curString = ""
    for i = 1, #text do
        if i <= skip then continue end
        local c = text:sub(i, i)
        if c == "\"" then
            local match = text:sub(i):match("%b" .. c .. c)
            if match then
                curString = ""
                skip = i + #match
                arguments[#arguments + 1] = match:sub(2, -2)
            else
                curString = curString .. c
            end
        elseif c == " " and curString ~= "" then
            arguments[#arguments + 1] = curString
            curString = ""
        else
            if c == " " and curString == "" then continue end
            curString = curString .. c
        end
    end

    if curString ~= "" then arguments[#arguments + 1] = curString end
    return arguments
end

if SERVER then
    --[[
      lia.command.run

      Description:
         Executes a command by its name, passing the provided arguments.
         If the command returns a string, it notifies the client (if valid).

      Parameters:
         client (Player) - The player or console running the command.
         command (string) - The name of the command to run.
         arguments (table) - A list of arguments for the command.

      Returns:
         nil

      Realm:
         Server

      Example Usage:
         lia.command.run(player, "mycommand", {"arg1", "arg2"})
   ]]
    function lia.command.run(client, command, arguments)
        local commandTbl = lia.command.list[command:lower()]
        if commandTbl then
            local results = {commandTbl.onRun(client, arguments or {})}
            local result = results[1]
            if isstring(result) then
                if IsValid(client) then
                    if result:sub(1, 1) == "@" then
                        client:notifyLocalized(result:sub(2), unpack(results, 2))
                    else
                        client:notify(result)
                    end
                else
                    print(result)
                end
            end
        end
    end

    --[[
      lia.command.parse

      Description:
         Attempts to parse the input text as a command, optionally using realCommand
         and arguments if provided. If parsed successfully, the command is executed.

      Parameters:
         client (Player) - The player or console issuing the command.
         text (string) - The raw text that may contain the command name and arguments.
         realCommand (string) - If provided, use this as the command name instead of parsing text.
         arguments (table) - If provided, use these as the command arguments instead of parsing text.

      Returns:
         boolean - True if the text was parsed as a valid command, false otherwise.

      Realm:
         Server

      Example Usage:
         lia.command.parse(player, "/mycommand arg1 arg2")
   ]]
    function lia.command.parse(client, text, realCommand, arguments)
        if realCommand or utf8.sub(text, 1, 1) == "/" then
            local match = realCommand or text:lower():match("/" .. "([_%w]+)")
            if not match then
                local post = string.Explode(" ", text)
                local len = string.len(post[1])
                match = utf8.sub(post[1], 2, len)
            end

            match = match:lower()
            local command = lia.command.list[match]
            if command then
                if not arguments then arguments = lia.command.extractArgs(text:sub(#match + 3)) end
                lia.command.run(client, match, arguments)
                if not realCommand then lia.log.add(client, "command", text) end
            else
                if IsValid(client) then
                    client:notifyLocalized("cmdNoExist")
                else
                    lia.information("Sorry, that command does not exist.")
                end
            end
            return true
        end
        return false
    end
else
    --[[
      lia.command.send

      Description:
         Sends a command (and optional arguments) from the client to the server using netstream.
         The server will then execute the command.

      Parameters:
         command (string) - The name of the command to send.
         ... (vararg) - Any additional arguments to pass to the command.

      Returns:
         nil

      Realm:
         Client

      Example Usage:
         lia.command.send("mycommand", "arg1", "arg2")
   ]]
    function lia.command.send(command, ...)
        netstream.Start("cmd", command, {...})
    end
end

hook.Add("CreateInformationButtons", "liaInformationCommands", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = L("commands"),
        drawFunc = function(panel)
            local searchEntry = vgui.Create("DTextEntry", panel)
            searchEntry:Dock(TOP)
            searchEntry:SetTall(30)
            searchEntry:SetPlaceholderText(L("searchCommands"))
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            local iconLayout = vgui.Create("DIconLayout", scroll)
            iconLayout:Dock(FILL)
            iconLayout:SetSpaceY(5)
            iconLayout:SetSpaceX(5)
            iconLayout.PerformLayout = function(self)
                local y = 0
                local w = self:GetWide()
                for _, child in ipairs(self:GetChildren()) do
                    child:SetPos((w - child:GetWide()) * 0.5, y)
                    y = y + child:GetTall() + self:GetSpaceY()
                end

                self:SetTall(y)
            end

            local function refresh()
                iconLayout:Clear()
                local filter = searchEntry:GetValue():lower()
                for cmdName, cmdData in SortedPairs(lia.command.list) do
                    if isnumber(cmdName) then continue end
                    local nameLower = cmdName:lower()
                    local descLower = (cmdData.desc or ""):lower()
                    local syntaxLower = (cmdData.syntax or ""):lower()
                    if filter ~= "" and not (nameLower:find(filter) or descLower:find(filter) or syntaxLower:find(filter)) then continue end
                    local hasAccess, privilege = lia.command.hasAccess(client, cmdName, cmdData)
                    if not hasAccess then continue end
                    local hasDesc = cmdData.desc and cmdData.desc ~= ""
                    local height = hasDesc and 80 or 40
                    local commandPanel = vgui.Create("DPanel", iconLayout)
                    commandPanel:SetSize(panel:GetWide(), height)
                    commandPanel.Paint = function(panel, w, h)
                        derma.SkinHook("Paint", "Panel", panel, w, h)
                        local baseX = 20
                        local text = "/" .. cmdName
                        if cmdData.syntax and cmdData.syntax ~= "" then text = text .. " " .. cmdData.syntax end
                        if hasDesc then
                            draw.SimpleText(text, "liaMediumFont", baseX, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText(cmdData.desc, "liaSmallFont", baseX, 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText(privilege or L("none"), "liaSmallFont", w - 20, 45, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                        else
                            draw.SimpleText(text, "liaMediumFont", baseX, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            draw.SimpleText(privilege or L("none"), "liaSmallFont", w - 20, h * 0.5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        end
                    end
                end

                iconLayout:InvalidateLayout(true)
            end

            searchEntry.OnTextChanged = refresh
            refresh()
        end
    })
end)

lia.command.findPlayer = lia.util.findPlayer