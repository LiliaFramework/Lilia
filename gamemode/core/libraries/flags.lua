--[[
    Folder: Libraries
    File: flag.md
]]
--[[
    Flags Library

    Character permission and access control system for the Lilia framework.
]]
--[[
    Overview:
        The flags library provides a comprehensive permission system for managing character abilities and access rights in the Lilia framework. It allows administrators to assign specific flags to characters that grant or restrict various gameplay features and tools. The library operates on both server and client sides, with the server handling flag assignment and callback execution during character spawning, while the client provides user interface elements for viewing and managing flags. Flags can have associated callbacks that execute when granted or removed, enabling dynamic behavior changes based on permission levels. The system includes built-in flags for common administrative tools like physgun, toolgun, and various spawn permissions. The library ensures proper flag validation and prevents duplicate flag assignments.
]]
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--[[
    Purpose:
        Register a flag with description and optional grant/remove callback.

    When Called:
        During framework setup to define permission flags.

    Parameters:
        flag (string)
            Single-character flag id.
        desc (string)
            Localization key or plain description.
        callback (function|nil)
            function(client, isGiven) for grant/remove side effects.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.flag.add("B", "flagBuildMenu", function(client, isGiven)
                if isGiven then
                    client:Give("weapon_physgun")
                else
                    client:StripWeapon("weapon_physgun")
                end
            end)
        ```
]]
function lia.flag.add(flag, desc, callback)
    if lia.flag.list[flag] then return end
    lia.flag.list[flag] = {
        desc = desc and L(desc) or desc,
        callback = callback
    }
end

if SERVER then
    --[[
    Purpose:
        Execute flag callbacks for a player on spawn, ensuring each flag runs once.

    When Called:
        Automatically when characters spawn; can be hooked for reapplication.

    Parameters:
        client (Player)
            Player whose flags should be processed.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            hook.Add("PlayerSpawn", "ApplyFlagWeapons", lia.flag.onSpawn)
        ```
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

lia.flag.add("C", "flagSpawnVehicles")
lia.flag.add("z", "flagSpawnSweps")
lia.flag.add("E", "flagSpawnSents")
lia.flag.add("L", "flagSpawnEffects")
lia.flag.add("r", "flagSpawnRagdolls")
lia.flag.add("e", "flagSpawnProps")
lia.flag.add("n", "flagSpawnNpcs")
lia.flag.add("Z", "flagInviteToYourFaction")
lia.flag.add("X", "flagInviteToYourClass")
lia.flag.add("p", "flagPhysgun", function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)

lia.flag.add("t", "flagToolgun", function(client, isGiven)
    if isGiven then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    else
        client:StripWeapon("gmod_tool")
    end
end)

--[[
    Purpose:
        Creates a character information panel displaying flag status for the local player.

    When Called:
        When the character information menu is opened to show available flag information panels.

    Parameters:
        pages (table)
            Array of information panel configurations to add the flags panel to.

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        This hook is automatically called by the framework when building information panels.
        No manual calling is required.
]]
hook.Add("CreateInformationButtons", "liaInformationFlagsUnified", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = "charFlagsTitle",
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
                    pnl.Paint = function(_, w, h)
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
