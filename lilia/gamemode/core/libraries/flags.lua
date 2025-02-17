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

hook.Add("CreateMenuButtons", "FlagsMenuButtons", function(tabs)
    local function createListPanel(parent, columns)
        local panel = parent:Add("DPanel")
        panel:SetSize(parent:GetWide(), parent:GetTall())
        panel:Dock(FILL)
        local list = panel:Add("DListView")
        list:Dock(FILL)
        list:SetMultiSelect(false)
        for _, colName in ipairs(columns) do
            list:AddColumn(colName)
        end

        local function addRow(data)
            list:AddLine(unpack(data))
        end
        return panel, addRow
    end

    tabs["Flags"] = function(panel)
        local f = vgui.Create("DFrame", panel)
        f:SetSize(ScrW() * 0.6, ScrH() * 0.7)
        f:Center()
        f:SetTitle("Flags")
        f:MakePopup()
        local panelList, addRow = createListPanel(f, {"Status", "Flag", "Description"})
        f:Add(panelList)
        for flagName, flagData in SortedPairs(lia.flag.list, function(a, b) return tostring(a) < tostring(b) end) do
            if isnumber(flagName) then continue end
            local hasFlag = LocalPlayer():getChar():hasFlags(flagName) and "✓" or "✗"
            addRow({hasFlag, flagName, flagData.desc or ""})
        end
    end
end)
