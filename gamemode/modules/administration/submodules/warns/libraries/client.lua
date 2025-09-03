local panelRef
local warningsTabAdded = false
net.Receive("liaAllWarnings", function()
    local warnings = net.ReadTable() or {}
    if not IsValid(panelRef) then return end
    panelRef:Clear()
    local search = panelRef:Add("DTextEntry")
    search:Dock(TOP)
    search:SetPlaceholderText(L("search"))
    search:SetTextColor(Color(255, 255, 255))
    local list = panelRef:Add("DListView")
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
    addSizedColumn(L("warned"))
    addSizedColumn(L("admin"))
    addSizedColumn(L("warningMessage"))
    local function populate(filter)
        list:Clear()
        filter = string.lower(filter or "")
        for _, warn in ipairs(warnings) do
            local entries = {warn.timestamp or "", string.format("%s (%s)", warn.warned or "", warn.warnedSteamID or ""), string.format("%s (%s)", warn.warner or "", warn.warnerSteamID or ""), warn.message or ""}
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

net.Receive("liaWarningsCount", function()
    local count = net.ReadInt(32)
    if count > 0 and not warningsTabAdded then
        warningsTabAdded = true
        hook.Add("PopulateAdminTabs", "liaWarningsTab", function(pages)
            if not IsValid(LocalPlayer()) or not LocalPlayer():hasPrivilege("viewPlayerWarnings") then return end
            table.insert(pages, {
                name = "warnings",
                icon = "icon16/error.png",
                drawFunc = function(panel)
                    panelRef = panel
                    net.Start("liaRequestAllWarnings")
                    net.SendToServer()
                end
            })
        end)
    end
end)

function MODULE:PopulateAdminTabs()
    if not IsValid(LocalPlayer()) or not LocalPlayer():hasPrivilege("viewPlayerWarnings") then return end
    net.Start("liaRequestWarningsCount")
    net.SendToServer()
end