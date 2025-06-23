lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--[[
   lia.flag.add

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
      lia.flag.onSpawn

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

lia.flag.add("C", L("flagSpawnVehicles"))
lia.flag.add("z", L("flagSpawnSweps"))
lia.flag.add("E", L("flagSpawnSents"))
lia.flag.add("L", L("flagSpawnEffects"))
lia.flag.add("r", L("flagSpawnRagdolls"))
lia.flag.add("e", L("flagSpawnProps"))
lia.flag.add("n", L("flagSpawnNpcs"))
lia.flag.add("Z", L("flagInviteToYourFaction"))
lia.flag.add("p", L("flagPhysgun"), function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)

lia.flag.add("t", L("flagToolgun"), function(client, isGiven)
    if isGiven then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    else
        client:StripWeapon("gmod_tool")
    end
end)

hook.Add("CreateInformationButtons", "liaInformationFlags", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = L("flags"),
        drawFunc = function(panel)
            local searchEntry = vgui.Create("DTextEntry", panel)
            searchEntry:Dock(TOP)
            searchEntry:SetTall(30)
            searchEntry:SetPlaceholderText(L("searchFlags"))
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            local canvas = scroll:GetCanvas()
            local function refresh()
                canvas:Clear()
                local filter = searchEntry:GetValue():lower()
                for flagName, flagData in SortedPairs(lia.flag.list) do
                    if isnumber(flagName) then continue end
                    local nameLower = flagName:lower()
                    local descLower = (flagData.desc or ""):lower()
                    if filter ~= "" and not (nameLower:find(filter, 1, true) or descLower:find(filter, 1, true)) then continue end
                    local hasDesc = flagData.desc and flagData.desc ~= ""
                    local height = hasDesc and 80 or 40
                    local flagPanel = vgui.Create("DPanel", canvas)
                    flagPanel:Dock(TOP)
                    flagPanel:DockMargin(10, 5, 10, 0)
                    flagPanel:SetTall(height)
                    flagPanel.Paint = function(panel, w, h)
                        local hasFlag = client:getChar():hasFlags(flagName)
                        local status = hasFlag and "✓" or "✗"
                        local statusColor = hasFlag and Color(0, 255, 0) or Color(255, 0, 0)
                        derma.SkinHook("Paint", "Panel", panel, w, h)
                        draw.SimpleText("Flag '" .. flagName .. "'", "liaMediumFont", 20, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        draw.SimpleText(status, "liaHugeFont", w - 20, h * 0.5, statusColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        if hasDesc then draw.SimpleText(flagData.desc, "liaSmallFont", 20, 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end
                    end
                end

                canvas:InvalidateLayout(true)
                canvas:SizeToChildren(false, true)
            end

            searchEntry.OnTextChanged = refresh
            refresh()
        end
    })
end)
