if CLIENT then TicketFrames = {} end
MODULE.name = L("tickets")
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = L("moduleTicketsDesc")
MODULE.Privileges = {
    {
        Name = L("alwaysSeeTickets"),
        MinAccess = "superadmin",
        Category = L("tickets"),
    },
}

if CLIENT then
    local ticketPanel
    net.Receive("liaActiveTickets", function()
        local tickets = net.ReadTable() or {}
        if not IsValid(ticketPanel) then return end
        ticketPanel:Clear()
        local search = ticketPanel:Add("DTextEntry")
        search:Dock(TOP)
        search:SetPlaceholderText(L("search"))
        search:SetTextColor(Color(255, 255, 255))
        local list = ticketPanel:Add("DListView")
        list:Dock(FILL)
        local function addSizedColumn(text)
            local col = list:AddColumn(text)
            surface.SetFont(col.Header:GetFont())
            local w = surface.GetTextSize(col.Header:GetText())
            col:SetMinWidth(w + 16)
            col:SetWidth(w + 16)
            return col
        end

        addSizedColumn(L("timestamp"))
        addSizedColumn(L("requester"))
        addSizedColumn(L("admin"))
        addSizedColumn(L("message"))

        local function populate(filter)
            list:Clear()
            filter = string.lower(filter or "")
            for _, t in pairs(tickets) do
                local requester = t.requester or ""
                if requester ~= "" then
                    local requesterPly = lia.util.getBySteamID(requester)
                    local requesterName = IsValid(requesterPly) and requesterPly:Nick() or requester
                    requester = string.format("%s (%s)", requesterName, requester)
                end

                local ts = os.date("%Y-%m-%d %H:%M:%S", t.timestamp or os.time())
                local entries = {
                    ts,
                    requester,
                    t.admin and (function()
                        local adminPly = lia.util.getBySteamID(t.admin)
                        local adminName = IsValid(adminPly) and adminPly:Nick() or t.admin
                        return string.format("%s (%s)", adminName, t.admin)
                    end)() or L("unassigned"),
                    t.message or ""
                }
                local match = false
                if filter == "" then
                    match = true
                else
                    for _, value in ipairs(entries) do
                        if tostring(value):lower():find(filter, 1, true) then
                            match = true
                            break
                        end
                    end
                end
                if match then list:AddLine(unpack(entries)) end
            end
        end

        search.OnChange = function() populate(search:GetValue()) end
        populate("")

        function list:OnRowRightClick(_, line)
            if not IsValid(line) then return end
            local menu = DermaMenu()
            menu:AddOption(L("copyRow"), function()
                local rowString = ""
                for i, column in ipairs(self.Columns or {}) do
                    local header = column.Header and column.Header:GetText() or L("columnWithNumber", i)
                    local value = line:GetColumnText(i) or ""
                    rowString = rowString .. header .. " " .. value .. " | "
                end
                SetClipboardText(string.sub(rowString, 1, -4))
            end):SetIcon("icon16/page_copy.png")
            menu:Open()
        end
    end)

    function MODULE:PopulateAdminTabs(pages)
        if not IsValid(LocalPlayer()) or not (LocalPlayer():hasPrivilege(L("alwaysSeeTickets")) or LocalPlayer():isStaffOnDuty()) then return end
        table.insert(pages, {
            name = L("tickets"),
            drawFunc = function(panel)
                ticketPanel = panel
                net.Start("liaRequestActiveTickets")
                net.SendToServer()
            end
        })
    end
end
