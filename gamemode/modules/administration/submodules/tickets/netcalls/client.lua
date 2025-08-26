local MODULE = MODULE
local ticketPanel
local ticketsTabAdded = false
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

net.Receive("liaTicketsCount", function()
    local count = net.ReadInt(32)
    if count > 0 and not ticketsTabAdded then
        ticketsTabAdded = true
        hook.Add("PopulateAdminTabs", "liaTicketsTab", function(pages)
            if not IsValid(LocalPlayer()) or not (LocalPlayer():hasPrivilege("alwaysSeeTickets") or LocalPlayer():isStaffOnDuty()) then return end
            table.insert(pages, {
                name = "tickets",
                icon = "icon16/report.png",
                drawFunc = function(panel)
                    ticketPanel = panel
                    net.Start("liaRequestActiveTickets")
                    net.SendToServer()
                end
            })
        end)
    end
end)

function MODULE:PopulateAdminTabs()
    if not IsValid(LocalPlayer()) or not (LocalPlayer():hasPrivilege("alwaysSeeTickets") or LocalPlayer():isStaffOnDuty()) then return end
    net.Start("liaRequestTicketsCount")
    net.SendToServer()
end

net.Receive("ViewClaims", function()
    local tbl = net.ReadTable()
    local steamid = net.ReadString()
    if steamid and steamid ~= "" and steamid ~= " " then
        local v = tbl[steamid]
        lia.admin(L("claimRecordLast", v.name, v.claims, string.NiceTime(os.time() - v.lastclaim)))
    else
        for _, v in pairs(tbl) do
            lia.admin(L("claimRecord", v.name, v.claims))
        end
    end
end)

net.Receive("TicketSystem", function()
    local pl = net.ReadEntity()
    local msg = net.ReadString()
    local claimed = net.ReadEntity()
    if LocalPlayer():isStaffOnDuty() or LocalPlayer():hasPrivilege("alwaysSeeTickets") then MODULE:TicketFrame(pl, msg, claimed) end
end)

net.Receive("TicketSystemClaim", function()
    local pl = net.ReadEntity()
    local requester = net.ReadEntity()
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then
            local titl = v:GetChildren()[4]
            titl:SetText(titl:GetText() .. " - " .. L("claimedBy") .. " " .. pl:Nick())
            if pl == LocalPlayer() then
                function v:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 230))
                    draw.RoundedBox(0, 2, 2, w - 4, 16, Color(38, 166, 91))
                end
            else
                function v:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, 230))
                    draw.RoundedBox(0, 2, 2, w - 4, 16, Color(207, 0, 15))
                end
            end

            local bu = v:GetChildren()[11]
            bu.DoClick = function()
                if LocalPlayer() == pl then
                    net.Start("TicketSystemClose")
                    net.WriteEntity(requester)
                    net.SendToServer()
                else
                    v:Close()
                end
            end
        end
    end
end)

net.Receive("TicketSystemClose", function()
    local requester = net.ReadEntity()
    if not IsValid(requester) or not requester:IsPlayer() then return end
    for _, v in pairs(TicketFrames) do
        if v.idiot == requester then v:Remove() end
    end

    if timer.Exists("ticketsystem-" .. requester:SteamID()) then timer.Remove("ticketsystem-" .. requester:SteamID()) end
end)
