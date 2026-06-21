--[[
    Folder: Developer - Libraries
    File: lia.flag.md
]]
--[[
    Flags

    Flag helpers for registering character permission flags, storing flag metadata, reapplying flag callbacks on player spawn, and displaying available flags in the character information menu.
]]
--[[
    Overview:
        The flag library centralizes shared flag registration under `lia.flag`. Registered flags are stored in `lia.flag.list` with an optional localized description and callback. On the server, player spawn handling reapplies callbacks for each unique flag the player has. On the client, the information menu displays all registered flags and indicates whether the local character currently has each one.
]]
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--[[
    Purpose:
        Registers a character permission flag with an optional localized description and optional callback.

    Parameters:
        flag (string)
            The single-character flag identifier to register.

        desc (string|nil)
            The language token or description for the flag. When provided, it is resolved through lia.lang.resolveToken before being stored.

        callback (function|nil)
            Optional function called when the flag is applied or removed by flag handling code. The callback receives the player and a boolean indicating whether the flag is being given.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.flag.add("p", "@flagPhysgun", function(client, isGiven)
            if isGiven then
                client:Give("weapon_physgun")
            else
                client:StripWeapon("weapon_physgun")
            end
        end)
        ```

    Realm:
        Shared
]]
function lia.flag.add(flag, desc, callback)
    if lia.flag.list[flag] then return end
    lia.flag.list[flag] = {
        desc = desc and lia.lang.resolveToken(desc) or desc,
        callback = callback
    }
end

if SERVER then
    --[[
    Purpose:
        Reapplies registered flag callbacks for every unique flag the player has when spawn handling runs.

    Parameters:
        client (Player)
            The player whose current flags should be processed.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.flag.onSpawn(client)
        ```

    Realm:
        Server
]]
    function lia.flag.onSpawn(client)
        local flags = client:getFlags()
        local processed = {}
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not processed[flag] then
                processed[flag] = true
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(client, true) end
            end
        end
    end
end

lia.flag.add("C", "@flagSpawnVehicles")
lia.flag.add("z", "@flagSpawnSweps")
lia.flag.add("E", "@flagSpawnSents")
lia.flag.add("L", "@flagSpawnEffects")
lia.flag.add("r", "@flagSpawnRagdolls")
lia.flag.add("e", "@flagSpawnProps")
lia.flag.add("n", "@flagSpawnNpcs")
lia.flag.add("Z", "@flagInviteToYourFaction")
lia.flag.add("X", "@flagInviteToYourClass")
lia.flag.add("F", "@flagViewFactionRoster")
lia.flag.add("p", "@flagPhysgun", function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)

lia.flag.add("t", "@flagToolgun", function(client, isGiven)
    if isGiven then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    else
        client:StripWeapon("gmod_tool")
    end
end)

hook.Add("CreateInformationButtons", "liaInformationFlagsUnified", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = "charFlagsTitle",
        shouldShow = function() return true end,
        drawFunc = function(parent)
            parent:Clear()
            local sheet = vgui.Create("liaSheet", parent)
            sheet:Dock(FILL)
            sheet:SetPlaceholderText(L("searchFlags"))
            for flagName, flagData in SortedPairs(lia.flag.list) do
                if not isnumber(flagName) then
                    local descText = flagData.desc or ""
                    local row = sheet:AddTextRow({
                        title = L("flag") .. " '" .. flagName .. "'",
                        desc = descText
                    })

                    local pnl = row.panel
                    local basePaint = pnl.Paint
                    pnl.Paint = function(panel, w, h)
                        if basePaint then basePaint(panel, w, h) end
                        local char = client:getChar()
                        local hasFlag = char and char:hasFlags(flagName)
                        local icon = hasFlag and "checkbox.png" or "unchecked.png"
                        local s = 40
                        lia.util.drawTexture(icon, color_white, w - s - sheet.padding, h * 0.5 - s * 0.5, s, s)
                    end

                    row.filterText = (flagName .. " " .. descText):lower()
                end
            end

            sheet:Refresh()
        end
    })
end)
