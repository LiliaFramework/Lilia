--[[
    Flags Library

    Character permission and access control system for the Lilia framework.
]]

--[[
    Overview:
    The flags library provides a comprehensive permission system for managing character abilities
    and access rights in the Lilia framework. It allows administrators to assign specific flags
    to characters that grant or restrict various gameplay features and tools. The library operates
    on both server and client sides, with the server handling flag assignment and callback execution
    during character spawning, while the client provides user interface elements for viewing and
    managing flags. Flags can have associated callbacks that execute when granted or removed,
    enabling dynamic behavior changes based on permission levels. The system includes built-in
    flags for common administrative tools like physgun, toolgun, and various spawn permissions.
    The library ensures proper flag validation and prevents duplicate flag assignments.
]]
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--[[
    Purpose: Adds a new flag to the flag system with optional description and callback function
    When Called: During module initialization or when registering new permission flags
    Parameters:
        - flag (string): Single character flag identifier (e.g., "C", "p", "t")
        - desc (string, optional): Localized description key for the flag
        - callback (function, optional): Function to execute when flag is granted/removed
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Add a basic flag with description
        lia.flag.add("A", "flagAdmin")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Add flag with callback for weapon management
        lia.flag.add("w", "flagWeapon", function(client, isGiven)
            if isGiven then
                client:Give("weapon_pistol")
            else
                client:StripWeapon("weapon_pistol")
            end
        end)
        ```

        High Complexity:
        ```lua
        -- High: Add flag with complex callback and validation
        lia.flag.add("M", "flagModerator", function(client, isGiven)
            if isGiven then
                client:SetNWBool("isModerator", true)
                client:ChatPrint("Moderator privileges granted!")
                -- Additional setup logic here
            else
                client:SetNWBool("isModerator", false)
                client:ChatPrint("Moderator privileges revoked!")
                -- Cleanup logic here
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
        Purpose: Processes and executes callbacks for all flags assigned to a character when they spawn
        When Called: Automatically called when a character spawns on the server
        Parameters:
            - client (Player): The player whose character is spawning
        Returns: None
        Realm: Server
        Example Usage:
            Low Complexity:
            ```lua
            -- Simple: Called automatically when player spawns
            -- No direct usage needed - handled by framework
            ```

            Medium Complexity:
            ```lua
            -- Medium: Manual flag processing for specific cases
            local client = Player(1)
            if client and client:IsValid() then
                lia.flag.onSpawn(client)
            end
            ```

            High Complexity:
            ```lua
            -- High: Custom spawn handling with flag validation
            hook.Add("PlayerSpawn", "CustomFlagHandler", function(client)
                if client:getChar() then
                    -- Custom pre-spawn logic
                    lia.flag.onSpawn(client)
                    -- Custom post-spawn logic
                end
            end)
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
