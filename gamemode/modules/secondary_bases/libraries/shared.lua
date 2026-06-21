local MODULE = MODULE

-- Register a position tool callback so admins can add secondary bases using the map configurer
lia.util.setPositionCallback("Secondary Base", {
    onRun = function(pos, client, typeId)
        -- open a simple UI for name and faction selection
        if CLIENT then
            local frame = vgui.Create("DFrame")
            frame:SetTitle("Create Secondary Base")
            frame:SetSize(420, 380)
            frame:Center()
            frame:MakePopup()
            local nameEntry = vgui.Create("liaEntry", frame)
            nameEntry:Dock(TOP)
            nameEntry:DockMargin(8, 8, 8, 8)
            nameEntry:SetTall(30)
            nameEntry:SetValue("Secondary Base")
            local factionList = vgui.Create("DPanelList", frame)
            factionList:Dock(FILL)
            factionList:EnableVerticalScrollbar(true)
            factionList:DockMargin(8, 0, 8, 8)
            local factions = lia.faction.teams or {}
            local checks = {}
            for uid, info in pairs(factions) do
                local cb = vgui.Create("DCheckBoxLabel")
                cb:SetText(info.name or tostring(uid))
                cb:SizeToContents()
                cb:Dock(TOP)
                factionList:AddItem(cb)
                checks[#checks + 1] = {id = uid, cb = cb}
            end

            local btn = vgui.Create("DButton", frame)
            btn:Dock(BOTTOM)
            btn:SetText("Create")
            btn.DoClick = function()
                local name = nameEntry:GetValue() or ""
                local sel = {}
                for _, info in ipairs(checks) do if info.cb and info.cb:GetChecked() then sel[#sel + 1] = info.id end end
                net.Start("liaSecondaryBases_Create")
                net.WriteString(name)
                net.WriteString(lia.data.getEquivalencyMap(game.GetMap()))
                net.WriteVector(pos)
                net.WriteAngle(Angle(0, 0, 0))
                net.WriteUInt(#sel, 16)
                for i = 1, #sel do net.WriteString(tostring(sel[i])) end
                net.SendToServer()
                frame:Close()
            end
        end
    end,
    onSelect = function(client, cb)
        -- server-side listing handled elsewhere
        cb({}, 0)
    end,
    serverOnly = false,
    color = Color(180, 180, 255)
})
