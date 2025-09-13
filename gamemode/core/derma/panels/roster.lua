local PANEL = {}
function PANEL:Init()
    self:SetTall(500)
    self.sheet = self:Add("liaSheet")
    self.sheet:Dock(FILL)
    self.sheet:SetPlaceholderText(L("search"))
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
    if t == "faction" then
        net.Start("RequestFactionRoster")
        net.SendToServer()
    end
end

function PANEL:Populate(data, canKick)
    if not IsValid(self.sheet) then return end
    self.sheet.search:SetValue("")
    self.sheet:Clear()
    if not data or #data == 0 then
        self.sheet:AddTextRow({
            title = L("none"),
            desc = L("noMembers"),
            compact = true
        })

        self.sheet:Refresh()
        return
    end

    for _, v in ipairs(data) do
        local title = v.name or L("unnamed")
        local desc = string.format("%s | %s | %s", v.steamID or L("na"), v.class or L("none"), v.playTime or L("na"))
        local right = v.lastOnline or L("na")
        local classData = v.classID and lia.class.list[v.classID]
        local hasLogo = classData and classData.logo and classData.logo ~= ""
        local row
        if hasLogo then
            row = self.sheet:AddRow(function(p, rowPanel)
                local logoSize = 64
                local margin = 8
                local rowHeight = logoSize + self.sheet.padding * 2
                local logo = vgui.Create("DImage", p)
                logo:SetSize(logoSize, logoSize)
                logo:SetMaterial(Material(classData.logo))
                logo:SetPos(margin, margin)
                local t = vgui.Create("DLabel", p)
                t:SetFont("liaMediumFont")
                t:SetText(title)
                t:SizeToContents()
                t:SetPos(margin + logoSize + margin, margin)
                local d = vgui.Create("DLabel", p)
                d:SetFont("liaSmallFont")
                d:SetWrap(true)
                d:SetAutoStretchVertical(true)
                d:SetText(desc)
                d:SetPos(margin + logoSize + margin, margin + t:GetTall() + 5)
                local r = vgui.Create("DLabel", p)
                r:SetFont("liaSmallFont")
                r:SetText(right)
                r:SizeToContents()
                p.PerformLayout = function()
                    local pad = self.sheet.padding
                    local spacing = 5
                    logo:SetPos(pad, pad)
                    t:SetPos(pad + logoSize + pad, pad)
                    d:SetPos(pad + logoSize + pad, pad + t:GetTall() + spacing)
                    d:SetWide(p:GetWide() - (pad + logoSize + pad) - pad - (r:GetWide() + 10))
                    d:SizeToContentsY()
                    if r then
                        local y = d and pad + t:GetTall() + spacing + d:GetTall() - r:GetTall() or p:GetTall() * 0.5 - r:GetTall() * 0.5
                        r:SetPos(p:GetWide() - r:GetWide() - pad, math.max(pad, y))
                    end

                    local textH = pad + t:GetTall() + spacing + d:GetTall() + pad
                    p:SetTall(math.max(rowHeight, textH))
                end

                rowPanel.filterText = (title .. " " .. desc .. " " .. right):lower()
            end)
        else
            row = self.sheet:AddTextRow({
                title = title,
                desc = desc,
                right = right,
                minHeight = self.sheet.padding * 2 + 64
            })
        end

        row.rowData = v
        row.filterText = (title .. " " .. desc .. " " .. right):lower()
        row.OnRightClick = function()
            if not IsValid(row) or not row.rowData then return end
            local rowData = row.rowData
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
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:InvalidateLayout(true)
            self:SizeToChildren(false, true)
        end
    end)
end

vgui.Register("liaRoster", PANEL, "EditablePanel")