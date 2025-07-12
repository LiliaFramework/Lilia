lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
function lia.flag.add(flag, desc, callback)
    if lia.flag.list[flag] then return end
    lia.flag.list[flag] = {
        desc = desc,
        callback = callback
    }
end

if SERVER then
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

lia.flag.add("V", L("flagSpawnVehicles"))
lia.flag.add("S", L("flagSpawnSweps"))
lia.flag.add("SS", L("flagSpawnSents"))
lia.flag.add("E", L("flagSpawnEffects"))
lia.flag.add("R", L("flagSpawnRagdolls"))
lia.flag.add("PR", L("flagSpawnProps"))
lia.flag.add("N", L("flagSpawnNpcs"))
lia.flag.add("F", L("flagInviteToYourFaction"))
lia.flag.add("C", L("flagInviteToYourClass"))
lia.flag.add("P", L("flagPhysgun"), function(client, isGiven)
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
                    flagPanel.Paint = function(pnl, w, h)
                        local hasFlag = client:getChar():hasFlags(flagName)
                        local status = hasFlag and "✓" or "✗"
                        local statusColor = hasFlag and Color(0, 255, 0) or Color(255, 0, 0)
                        derma.SkinHook("Paint", "Panel", pnl, w, h)
                        draw.SimpleText(L("flagLabel", flagName), "liaMediumFont", 20, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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
