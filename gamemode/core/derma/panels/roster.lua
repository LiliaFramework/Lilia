local PANEL = {}
function PANEL:Init()
    self:SetTall(500) -- Set minimum height for the roster panel
    self.sheet = self:Add("liaSheet")
    self.sheet:Dock(FILL)
    self.sheet:SetPlaceholderText(L("search"))
    -- Ensure proper sizing after initialization
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:InvalidateLayout(true)
            self:SizeToChildren(false, true)
        end
    end)
end

function PANEL:PerformLayout()
    self:SizeToChildren(false, true)
    if self.sheet then self.sheet:InvalidateLayout(true) end
end

function PANEL:SetRosterType(t)
    self.rosterType = t
    -- Request data when roster type is set
    if t == "faction" then
        net.Start("RequestFactionRoster")
        net.SendToServer()
    elseif t == "class" then
        net.Start("RequestClassRoster")
        net.SendToServer()
    end
end

function PANEL:Populate(data, canKick)
    if not IsValid(self.sheet) then return end
    self.sheet.search:SetValue("")
    self.sheet:Clear()
    -- Handle empty data
    if not data or #data == 0 then
        self.sheet:AddTextRow({
            title = L("none"),
            desc = L("noMembers"),
            compact = true
        })

        self.sheet:Refresh()
        return
    end

    local rows = {}
    local originals = {}
    for _, v in ipairs(data) do
        rows[#rows + 1] = {v.name, v.steamID, v.class or L("none"), v.playTime, v.lastOnline}
        originals[#originals + 1] = v
    end

    local row = self.sheet:AddListViewRow({
        columns = {L("name"), L("steamID"), L("class"), L("playtime"), L("lastOnline")},
        data = rows,
        height = 400, -- Increased height for better visibility
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

    self.sheet:Refresh()
    -- Ensure proper sizing after populating data
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:InvalidateLayout(true)
            self:SizeToChildren(false, true)
        end
    end)
end

vgui.Register("liaRoster", PANEL, "EditablePanel")
