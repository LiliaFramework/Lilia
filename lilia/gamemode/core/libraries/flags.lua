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
    local client = LocalPlayer()
    tabs["Flags"] = function(panel)
        local char = client:getChar()
        if not char then
            print("No character found!")
            return
        end

        local scroll = vgui.Create("DScrollPanel", panel)
        scroll:Dock(FILL)
        local iconLayout = vgui.Create("DIconLayout", scroll)
        iconLayout:Dock(FILL)
        iconLayout:DockMargin(0, 50, 0, 0)
        iconLayout:SetSpaceY(5)
        iconLayout:SetSpaceX(5)
        iconLayout.PerformLayout = function(self)
            local y = 0
            local parentWidth = self:GetWide()
            for _, child in ipairs(self:GetChildren()) do
                child:SetPos((parentWidth - child:GetWide()) / 2, y)
                y = y + child:GetTall() + self:GetSpaceY()
            end

            self:SetTall(y)
        end

        for flagName, flagData in SortedPairs(lia.flag.list, function(a, b) return tostring(a) < tostring(b) end) do
            if isnumber(flagName) then continue end
            local flagPanel = vgui.Create("DPanel", iconLayout)
            flagPanel:SetSize(panel:GetWide(), 60)
            flagPanel.Paint = function(_, w, h)
                local char = client:getChar()
                if not char then return end
                local hasFlag = char:hasFlags(flagName)
                local status = hasFlag and "✓" or "✗"
                local statusColor = hasFlag and Color(0, 255, 0) or Color(255, 0, 0)
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
                draw.SimpleText(flagName, "liaMediumFont", 20, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(status, "liaBigFont", w - 20, 5, statusColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                if flagData.desc then draw.SimpleText(flagData.desc, "liaSmallFont", 20, 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end
            end
        end

        panel:InvalidateLayout(true)
    end
end)