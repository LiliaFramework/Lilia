local panelRef
local warningsTabAdded = false
net.Receive("liaAllWarnings", function()
    local warnings = net.ReadTable() or {}
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    panelRef:DockPadding(6, 6, 6, 6)
    panelRef.Paint = function() end
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:DockMargin(0, 0, 0, 15)
    search:SetTall(30)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(200, 200, 200))
    search.PaintOver = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local list = panelRef:Add("liaTable")
    list:Dock(FILL)
    local columns = {
        {
            name = L("timestamp"),
            field = "timestamp"
        },
        {
            name = L("warned"),
            field = "warnedDisplay"
        },
        {
            name = L("admin"),
            field = "adminDisplay"
        },
        {
            name = L("warningMessage"),
            field = "message"
        }
    }

    for _, col in ipairs(columns) do
        list:AddColumn(col.name)
    end

    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, warn in ipairs(warnings) do
            local warnedDisplay = string.format("%s (%s)", warn.warned or "", warn.warnedSteamID or "")
            local adminDisplay = string.format("%s (%s)", warn.warner or "", warn.warnerSteamID or "")
            local values = {warn.timestamp or "", warnedDisplay, adminDisplay, warn.message or ""}
            local match = false
            if filter == "" then
                match = true
            else
                for _, value in ipairs(values) do
                    if tostring(value):lower():find(filter, 1, true) then
                        match = true
                        break
                    end
                end
            end

            if match then list:AddLine(unpack(values)) end
        end
    end

    search.OnChange = function() populate(search:GetValue()) end
    populate("")
    function list:OnRowRightClick(_, line)
        if not IsValid(line) then return end
        local menu = lia.derma.dermaMenu()
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

net.Receive("liaWarningsCount", function()
    local count = net.ReadInt(32)
    warningsCount = count
    if not warningsTabAdded and count > 0 then warningsTabAdded = true end
end)

hook.Add("PopulateAdminTabs", "liaWarningsTab", function(pages)
    if not IsValid(LocalPlayer()) or not LocalPlayer():hasPrivilege("viewPlayerWarnings") then return end
    if warningsCount and warningsCount > 0 then
        table.insert(pages, {
            name = "warnings",
            icon = "icon16/error.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestAllWarnings")
                net.SendToServer()
            end
        })
    end
end)
-- Warnings count is requested and handled by the hook above
