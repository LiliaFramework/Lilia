lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--[[
   Function: lia.flag.add

   Description:
      Registers a new flag by adding it to the flag list.
      Each flag has a description and an optional callback that is executed when the flag is applied to a player.

   Parameters:
      flag (string) - The unique flag identifier.
      desc (string) - A description of what the flag does.
      callback (function) - An optional callback function executed when the flag is applied to a player.

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      lia.flag.add("C", "Spawn vehicles.")
]]
function lia.flag.add(flag, desc, callback)
    if lia.flag.list[flag] then return end
    lia.flag.list[flag] = {
        desc = desc,
        callback = callback
    }
end

if SERVER then
    --[[
      Function: lia.flag.onSpawn

      Description:
         Called when a player spawns. This function checks the player's character flags and triggers
         the associated callbacks for each flag that the character possesses.

      Parameters:
         client (Player) - The player who spawned.

      Returns:
         nil

      Realm:
         Server

      Example Usage:
         lia.flag.onSpawn(player)
]]
    function lia.flag.onSpawn(client)
        if client:getChar() then
            local flags = client:getChar():getFlags()
            for i = 1, #flags do
                local flag = flags:sub(i, i)
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(client, true) end
            end
        end
    end
end

lia.flag.add("C", "Spawn vehicles.")
lia.flag.add("z", "Spawn SWEPS.")
lia.flag.add("E", "Spawn SENTs.")
lia.flag.add("L", "Spawn Effects.")
lia.flag.add("r", "Spawn ragdolls.")
lia.flag.add("e", "Spawn props.")
lia.flag.add("n", "Spawn NPCs.")
lia.flag.add("p", "Physgun.", function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)

lia.flag.add("t", "Toolgun", function(client, isGiven)
    if isGiven then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    else
        client:StripWeapon("gmod_tool")
    end
end)

hook.Add("BuildInformationMenu", "BuildInformationMenuFlags", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = "Flags",
        drawFunc = function(panel)
            local char = client:getChar()
            if not char then
                panel:Add("DLabel"):SetText("No character found!"):Dock(TOP)
                return
            end

            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            for flagName, flagData in SortedPairs(lia.flag.list) do
                if isnumber(flagName) then continue end
                local hasDesc = flagData.desc and flagData.desc ~= ""
                local height = hasDesc and 80 or 40
                local flagPanel = vgui.Create("DPanel", scroll)
                flagPanel:Dock(TOP)
                flagPanel:DockMargin(10, 5, 10, 0)
                flagPanel:SetTall(height)
                flagPanel.Paint = function(_, w, h)
                    local hasFlag = char:hasFlags(flagName)
                    local status = hasFlag and "✓" or "✗"
                    local statusColor = hasFlag and Color(0, 255, 0) or Color(255, 0, 0)
                    draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
                    draw.SimpleText("Flag '" .. flagName .. "'", "liaMediumFont", 20, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText(status, "liaHugeFont", w - 20, h / 2, statusColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    if hasDesc then draw.SimpleText(flagData.desc, "liaSmallFont", 20, 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end
                end
            end
        end
    })
end)