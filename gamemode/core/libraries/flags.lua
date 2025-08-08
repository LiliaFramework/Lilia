--[[
# Flags Library

This page documents the functions for working with permission flags and player abilities.

---

## Overview

The flags library provides a system for managing permission flags and player abilities within the Lilia framework. It handles flag registration, assignment, and provides utilities for granting and revoking special permissions to players. The library supports flag callbacks, descriptions, and provides a foundation for role-based permission systems.
]]
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--[[
    lia.flag.add

    Purpose:
        Registers a new flag with an optional description and callback function. Flags are used to grant special abilities or permissions to players.
        The callback, if provided, is called when the flag is given or removed from a player.

    Parameters:
        flag (string)      - The unique character representing the flag.
        desc (string)      - (Optional) The description of the flag, will be localized if possible.
        callback (function)- (Optional) Function to call when the flag is given or removed. Receives (client, isGiven).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Add a flag "F" that allows spawning furniture, with a description and a callback
        lia.flag.add("F", "flagSpawnFurniture", function(client, isGiven)
            if isGiven then
                client:Give("spawn_furniture_tool")
            else
                client:StripWeapon("spawn_furniture_tool")
            end
        end)
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
        lia.flag.onSpawn

        Purpose:
            Called when a player spawns. Iterates through all of the player's flags and executes any associated callbacks for each flag.
            Ensures each flag's callback is only called once per spawn.

        Parameters:
            client (Player) - The player entity who has spawned.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Call onSpawn for a player after they have spawned
            hook.Add("PlayerSpawn", "liaFlagOnSpawn", function(client)
                lia.flag.onSpawn(client)
            end)
    ]]
    function lia.flag.onSpawn(client)
        local flags = client:getFlags() .. client:getPlayerFlags()
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
        name = L("charFlagsTitle"),
        drawFunc = function(parent)
            local sheet = vgui.Create("liaSheet", parent)
            sheet:SetPlaceholderText(L("searchFlags"))
            for flagName, flagData in SortedPairs(lia.flag.list) do
                if isnumber(flagName) then continue end
                local descText = flagData.desc or ""
                local row = sheet:AddTextRow({
                    title = L("flag") .. " '" .. flagName .. "'",
                    desc = descText
                })

                local pnl = row.panel
                pnl.Paint = function(pnl2, w, h)
                    derma.SkinHook("Paint", "Panel", pnl2, w, h)
                    local char = client:getChar()
                    local hasFlag = char and char:hasFlags(flagName)
                    local icon = hasFlag and "checkbox.png" or "unchecked.png"
                    local s = 40
                    lia.util.drawTexture(icon, color_white, w - s - sheet.padding, h * 0.5 - s * 0.5, s, s)
                end

                row.filterText = (flagName .. " " .. descText):lower()
            end

            sheet:Refresh()
        end
    })

    table.insert(pages, {
        name = L("playerFlagsTitle"),
        drawFunc = function(parent)
            local sheet = vgui.Create("liaSheet", parent)
            sheet:SetPlaceholderText(L("searchFlags"))
            for flagName, flagData in SortedPairs(lia.flag.list) do
                if isnumber(flagName) then continue end
                local descText = flagData.desc or ""
                local row = sheet:AddTextRow({
                    title = L("flag") .. " '" .. flagName .. "'",
                    desc = descText
                })

                local pnl = row.panel
                pnl.Paint = function(pnl2, w, h)
                    derma.SkinHook("Paint", "Panel", pnl2, w, h)
                    local hasFlag = client:getPlayerFlags():find(flagName, 1, true)
                    local icon = hasFlag and "checkbox.png" or "unchecked.png"
                    local s = 40
                    lia.util.drawTexture(icon, color_white, w - s - sheet.padding, h * 0.5 - s * 0.5, s, s)
                end

                row.filterText = (flagName .. " " .. descText):lower()
            end

            sheet:Refresh()
        end
    })
end)