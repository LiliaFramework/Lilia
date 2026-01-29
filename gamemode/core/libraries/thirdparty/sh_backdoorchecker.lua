local Triggers = {"http\\.", "HTTP", "CompileString", "CompileFile", "RunString", "RunStringEx", "%(_G%)", "Base64Encode", "Base64Decode", "CRC", ":Ban\\(", ":Kick\\(", "player.GetByUniqueID", "SetUserGroup", "setroot", "setrank", "hostip", "hostname", "server.cfg", "autoexec.cfg", "\\.dll", "\\.exe", "bind\\ ", "connect\\ ", "point_servercommand", "lua_run", "\"rcon", "\"rcon_password", "\"sv_password", "\"sv_cheats"}
local LogBuffer = "\n"
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

concommand.Add("lia_backdoorcheck", function(ply, com, arg)
    if IsValid(ply) then return end
    if not arg[1] then
        print("\n---------- Lilia Backdoor Checker ----------\n")
        print("Scans schema and addons for suspicious code (ignores).")
        print("To search all addons: lia_backdoorcheck all 1")
        print("To search a specific addon: lia_backdoorcheck *ID* 1")
        print("Last argument is whether to save log or not.")
        print("\n----------------------------------")
        return
    end

    local savelog = arg[2] == "1" and true or false
    local addons = engine.GetAddons()
    print("\n---------- Lilia Backdoor Checker ----------\n")
    print("Addons installed: " .. #addons)
    print("\nStarting search...\n")
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

    if arg[1] == "all" then
        for anum, addon in pairs(addons) do
            if addon.title:lower() == "lilia" then continue end
            addon.path = addon.title
            ScanAddon(addon)
        end

        if savelog and SERVER and lia.data and lia.data.set then lia.data.set("backdoorchecker.scan_all_" .. os.date("%y-%m-%d_%H-%M-%S"), LogBuffer, true, true) end
    else
        print("Specific search for ID " .. arg[1] .. "...")
        local found = false
        for anum, addon in pairs(addons) do
            if addon.wsid == arg[1] then
                if addon.title:lower() == "lilia" then
                    MsgC(Color(255, 255, 0), "Skipping Lilia core as requested.\n")
                    found = true
                    break
                end

                addon.path = addon.title
                ScanAddon(addon)
                found = true
                break
            end
        end

        if savelog and SERVER and lia.data and lia.data.set then lia.data.set("backdoorchecker.scan_" .. (found and arg[1] or "notfound") .. "_" .. os.date("%y-%m-%d_%H-%M-%S"), LogBuffer, true, true) end
        if not found then MsgC(Color(255, 0, 0), "No addon with that ID installed.\n\n") end
    end

    MsgC(Color(0, 255, 0), "All done.")
    if savelog then MsgC(Color(0, 255, 0), "\nLog file saved to data directory.") end
    print("\n\n----------------------------------")
end)
