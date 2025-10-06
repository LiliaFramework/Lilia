local PANEL = {}
function PANEL:Init()
    self:SetTall(500)
    self.table = self:Add("liaTable")
    self.table:Dock(FILL)
    self.table:AddColumn(L("name"), nil, TEXT_ALIGN_LEFT, true)
    self.table:AddColumn(L("steamID"), nil, TEXT_ALIGN_LEFT, true)
    self.table:AddColumn(L("class"), nil, TEXT_ALIGN_LEFT, true)
    self.table:AddColumn(L("playTime"), 100, TEXT_ALIGN_CENTER, true)
    self.table:AddColumn(L("lastOnline"), 120, TEXT_ALIGN_CENTER, true)
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:InvalidateLayout(true)
            self:SizeToChildren(false, true)
        end
    end)
end

function PANEL:PerformLayout()
    self:SizeToChildren(false, true)
    if self.table then self.table:InvalidateLayout(true) end
end

function PANEL:SetRosterType(t)
    self.rosterType = t
    if t == "faction" then
        net.Start("liaRequestFactionRoster")
        net.SendToServer()
    end
end

function PANEL:Populate(data, canKick)
    if not IsValid(self.table) then return end
    self.table:Clear()
    if not data or #data == 0 then
        self.table:AddLine(L("noMembers"), "", "", "", "")
        return
    end

    for _, v in ipairs(data) do
        local name = v.name or L("unnamed")
        local steamID = v.steamID or L("na")
        local className = v.class or L("none")
        local playTime = v.playTime or L("na")
        local lastOnline = v.lastOnline or L("na")
        local row = self.table:AddLine(name, steamID, className, playTime, lastOnline)
        row.rowData = v
        row.DoRightClick = function()
            if not IsValid(row) or not row.rowData then return end
            local rowData = row.rowData
            local menu = lia.derma.dermaMenu()
            if canKick and rowData.steamID ~= LocalPlayer():SteamID() then
                menu:AddOption(L("kick"), function()
                    Derma_Query(L("kickConfirm"), L("confirm"), L("yes"), function()
                        net.Start("liaKickCharacter")
                        net.WriteInt(tonumber(rowData.id), 32)
                        net.SendToServer()
                    end, L("no"))
                end)
            end

            menu:AddOption(L("view") .. " " .. L("characterList"), function() LocalPlayer():ConCommand("say /charlist " .. rowData.steamID) end)
            menu:AddOption(L("copySteamID"), function() SetClipboardText(rowData.steamID or "") end)
            menu:AddOption(L("copyRow"), function()
                local rowString = ""
                for key, value in pairs(rowData) do
                    value = tostring(value or L("na"))
                    rowString = rowString .. key:gsub("^%l", string.upper) .. ": " .. value .. " | "
                end

                rowString = rowString:sub(1, -4)
                SetClipboardText(rowString)
            end)

            menu:Open()
        end
    end
end

vgui.Register("liaRoster", PANEL, "EditablePanel")
