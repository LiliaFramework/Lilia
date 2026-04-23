local Triggers = {"http\\.", "HTTP", "CompileString", "CompileFile", "RunString", "RunStringEx", "%(_G%)", "Base64Encode", "Base64Decode", "CRC", ":Ban\\(", ":Kick\\(", "player.GetByUniqueID", "SetUserGroup", "setroot", "setrank", "hostip", "hostname", "server.cfg", "autoexec.cfg", "\\.dll", "\\.exe", "bind\\ ", "connect\\ ", "point_servercommand", "lua_run", "\"rcon", "\"rcon_password", "\"sv_password", "\"sv_cheats"}
local LogBuffer = "\n"
local function canRunBackdoorCheck(ply)
    if not IsValid(ply) then return true end
    return ply:IsAdmin()
end

local function printToRunner(ply, text)
    print(text)
    if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, text) end
end

local function notifyBackdoorCheckDenied(ply)
    if not IsValid(ply) then return end
    if ply.notifyError then
        ply:notifyError("You must be an admin to use lia_backdoorcheck.")
    else
        ply:PrintMessage(HUD_PRINTCONSOLE, "[lia_backdoorcheck] You must be an admin to use this command.")
    end
end

local function printBackdoorCheckUsage(ply)
    printToRunner(ply, "")
    printToRunner(ply, "---------- Lilia Backdoor Checker ----------")
    printToRunner(ply, "Scans the active schema by default and can also scan addons.")
    printToRunner(ply, "Usage: lia_backdoorcheck")
    printToRunner(ply, "Usage: lia_backdoorcheck all [saveLog]")
    printToRunner(ply, "Usage: lia_backdoorcheck <workshopID> [saveLog]")
    printToRunner(ply, "Examples: lia_backdoorcheck all 1")
    printToRunner(ply, "Examples: lia_backdoorcheck 1234567890 1")
    printToRunner(ply, "----------------------------------")
end

local function ScanAddon(addon)
    if not addon.title then addon.title = "[Title not available]" end
    if not addon.file then addon.file = "[File not available]" end
    if not addon.wsid then addon.wsid = "[ID not available]" end
    local line = "♫ " .. addon.title .. " ♫"
    MsgC(Color(0, 255, 255), line .. "\n")
    LogBuffer = LogBuffer .. line .. "\n"
    line = "File: " .. addon.file
    MsgC(Color(200, 200, 200), line .. "\n")
    LogBuffer = LogBuffer .. line .. "\n"
    line = "ID: " .. addon.wsid
    MsgC(Color(200, 200, 200), line .. "\n")
    LogBuffer = LogBuffer .. line .. "\n"
    MsgN("")
    LogBuffer = LogBuffer .. "\n"
    local luafiles = 0
    local found = 0
    local Files = {}
    local function Recurs(f, a)
        local files, folders = file.Find(f .. "*", a)
        if not files then return end
        if not folders then folders = {} end
        for k, v in pairs(files) do
            local s = string.Split(v, ".")
            if s[#s] == "dll" then
                line = "\n\n!!! DLL file found in the addon " .. a .. " !!!\n"
                MsgC(Color(255, 0, 0), line)
                LogBuffer = LogBuffer .. line .. "\n"
            end

            if s[#s] == "lua" then
                table.insert(Files, f .. v)
                luafiles = luafiles + 1
                local luafile = file.Read(f .. v, "GAME")
                if not luafile then
                    line = "Unable to read Lua file: " .. f .. v
                    MsgC(Color(255, 0, 0), line .. "\n")
                    LogBuffer = LogBuffer .. line .. "\n"
                    continue
                end

                local lines = string.Split(luafile, "\n")
                if not lines then continue end
                if #lines == 1 then
                    line = "+-- Only one line in " .. f .. v .. " --"
                    MsgC(Color(255, 0, 0), line .. "\n")
                    LogBuffer = LogBuffer .. line .. "\n"
                    line = "| 1 | " .. lines[1] .. "\n"
                    MsgC(Color(0, 255, 0), line)
                    LogBuffer = LogBuffer .. line .. "\n"
                    found = found + 1
                end

                for linenr, lineText in pairs(lines) do
                    for _, w in pairs(Triggers) do
                        if string.find(lineText, w, 0, false) then
                            local ln = "┌── Suspicious element '" .. w .. "' found in " .. f .. v .. " at line " .. linenr .. " ──"
                            MsgC(Color(255, 0, 0), ln .. "\n")
                            LogBuffer = LogBuffer .. ln .. "\n"
                            for i = math.Clamp(linenr - 3, 0, 9999), math.Clamp(linenr + 3, 0, #lines) do
                                if not lines[i] then continue end
                                ln = "│ " .. i .. " | " .. lines[i]
                                MsgC(i == linenr and Color(0, 255, 0) or Color(255, 255, 0), ln .. "\n")
                                LogBuffer = LogBuffer .. ln .. "\n"
                            end

                            MsgC(Color(255, 0, 0), "└───●\n")
                            LogBuffer = LogBuffer .. "└───●\n\n"
                            found = found + 1
                        end
                    end

                    local steamid = string.match(lineText, "(STEAM_[0-9]:[0-9]:[0-9]+)")
                    if steamid then
                        local ln = "┌── SteamID " .. steamid .. " found on line " .. linenr .. " in " .. f .. v .. " ──"
                        MsgC(Color(255, 0, 0), ln .. "\n")
                        LogBuffer = LogBuffer .. ln .. "\n"
                        for i = math.Clamp(linenr - 3, 0, 9999), math.Clamp(linenr + 3, 0, #lines) do
                            ln = "│ " .. i .. " | " .. (lines[i] or "")
                            MsgC(i == linenr and Color(0, 255, 0) or Color(255, 255, 0), ln .. "\n")
                            LogBuffer = LogBuffer .. ln .. "\n"
                        end

                        MsgC(Color(255, 0, 0), "└───●\n")
                        LogBuffer = LogBuffer .. "└───●\n\n"
                        found = found + 1
                    end
                end
            end
        end

        for k, v in pairs(folders) do
            Recurs(f .. v .. "/", a)
        end
    end

    Recurs(addon.baseDir or "", addon.path or addon.title)
    line = "⌐ Lua files:          " .. luafiles
    MsgC(Color(200, 200, 128), line .. "\n")
    LogBuffer = LogBuffer .. line .. "\n"
    line = "⌐ Suspicious things:  " .. found
    MsgC(Color(200, 200, 128), line .. "\n")
    LogBuffer = LogBuffer .. line .. "\n"
    MsgN("")
    LogBuffer = LogBuffer .. "\n"
end

local function runBackdoorCheck(ply, arg)
    if not canRunBackdoorCheck(ply) then
        notifyBackdoorCheckDenied(ply)
        return
    end

    arg = arg or {}
    local mode = arg[1]
    local savelog = arg[2] == "1" or arg[2] == "true"
    local addons = engine.GetAddons()
    print("\n---------- Lilia Backdoor Checker ----------\n")
    print("Addons installed: " .. #addons)
    print("\nStarting search...\n")
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, "---------- Lilia Backdoor Checker ----------")
        ply:PrintMessage(HUD_PRINTCONSOLE, "Addons installed: " .. #addons)
        ply:PrintMessage(HUD_PRINTCONSOLE, "Starting search...")
    end

    if not Triggers then
        MsgC(Color(255, 0, 0), "No definitions file, odd.\n")
        return
    end

    LogBuffer = ""
    local schema = engine.ActiveGamemode()
    ScanAddon({
        title = "Schema (" .. schema .. ")",
        file = "gamemodes/" .. schema .. "/",
        wsid = "N/A",
        path = "GAME",
        baseDir = "gamemodes/" .. schema .. "/"
    })

    if not mode or mode == "" or mode == "schema" or mode == "current" then
        if savelog and SERVER and lia.data and lia.data.set then lia.data.set("backdoorchecker.scan_schema_" .. os.date("%y-%m-%d_%H-%M-%S"), LogBuffer, true, true) end
    elseif mode == "all" then
        for anum, addon in pairs(addons) do
            if addon.title:lower() == "lilia" then continue end
            addon.path = addon.title
            ScanAddon(addon)
        end

        if savelog and SERVER and lia.data and lia.data.set then lia.data.set("backdoorchecker.scan_all_" .. os.date("%y-%m-%d_%H-%M-%S"), LogBuffer, true, true) end
    else
        print("Specific search for ID " .. mode .. "...")
        if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, "Specific search for ID " .. mode .. "...") end
        local found = false
        for anum, addon in pairs(addons) do
            if addon.wsid == mode then
                if addon.title:lower() == "lilia" then
                    MsgC(Color(255, 255, 0), "Skipping Lilia core as requested.\n")
                    if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, "Skipping Lilia core as requested.") end
                    found = true
                    break
                end

                addon.path = addon.title
                ScanAddon(addon)
                found = true
                break
            end
        end

        if savelog and SERVER and lia.data and lia.data.set then lia.data.set("backdoorchecker.scan_" .. (found and mode or "notfound") .. "_" .. os.date("%y-%m-%d_%H-%M-%S"), LogBuffer, true, true) end
        if not found then
            MsgC(Color(255, 0, 0), "No addon with that ID installed.\n\n")
            if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, "No addon with that ID installed.") end
        end
    end

    MsgC(Color(0, 255, 0), "All done.")
    if savelog then MsgC(Color(0, 255, 0), "\nLog file saved to data directory.") end
    print("\n\n----------------------------------")
    if IsValid(ply) then
        ply:PrintMessage(HUD_PRINTCONSOLE, "All done.")
        if savelog then ply:PrintMessage(HUD_PRINTCONSOLE, "Log file saved to data directory.") end
        if ply.notifySuccess then ply:notifySuccess("Backdoor scan complete. Open your console for results.") end
    end
end

concommand.Add("lia_backdoorcheck", function(ply, com, arg)
    if arg and (arg[1] == "help" or arg[1] == "?") then
        printBackdoorCheckUsage(ply)
        return
    end

    runBackdoorCheck(ply, arg)
end)
