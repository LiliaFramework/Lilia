local PANEL = {}

function PANEL:Init()
    self.sheet = self:Add("liaSheet")
    self.sheet:Dock(FILL)
    self.sheet:SetPlaceholderText(L("search"))
end

function PANEL:SetRosterType(t)
    self.rosterType = t
end

function PANEL:Populate(data, canKick)
    if not IsValid(self.sheet) then return end
    self.sheet.search:SetValue("")
    self.sheet:Clear()
    local rows = {}
    local originals = {}
    for _, v in ipairs(data) do
        rows[#rows + 1] = {v.name, v.steamID, v.class or L("none"), v.playTime, v.lastOnline}
        originals[#originals + 1] = v
    end
    local row = self.sheet:AddListViewRow({
        columns = {L("name"), L("steamID"), L("class"), L("playtime"), L("lastOnline")},
        data = rows,
        getLineText = function(line)
            local s = ""
            for i = 1, 5 do
                local v = line:GetValue(i)
                if v then s = s .. " " .. tostring(v) end
            end
            return s
        end
    })
    if row and row.widget then
        for i, line in ipairs(row.widget:GetLines() or {}) do
            line.rowData = originals[i]
        end
        row.widget.OnRowRightClick = function(_, _, line)
            if not IsValid(line) or not line.rowData then return end
            local rowData = line.rowData
            local menu = DermaMenu()
            if canKick and rowData.steamID ~= LocalPlayer():SteamID() then
                menu:AddOption(L("kick"), function()
                    Derma_Query(L("kickConfirm"), L("confirm"), L("yes"), function()
                        net.Start("KickCharacter")
                        net.WriteInt(tonumber(rowData.id), 32)
                        net.SendToServer()
                    end, L("no"))
                end)
            end
            menu:AddOption(L("view") .. " " .. L("characterList"), function()
                LocalPlayer():ConCommand("say /charlist " .. rowData.steamID)
            end)
            menu:AddOption(L("copySteamID"), function()
                SetClipboardText(rowData.steamID or "")
            end)
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
    self.sheet:Refresh()
end

vgui.Register("liaRoster", PANEL, "EditablePanel")

