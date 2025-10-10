lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
function lia.flag.add(flag, desc, callback)
    if lia.flag.list[flag] then return end
    lia.flag.list[flag] = {
        desc = desc and L(desc) or desc,
        callback = callback
    }
end
if SERVER then
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
lia.flag.add("V", "flagFactionRoster")
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