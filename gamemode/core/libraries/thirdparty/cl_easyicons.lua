ICON_FONT = nil
local function ScrapPage()
    local d = deferred.new()
    http.Fetch('https://liliaframework.github.io/liaIcons', function(resp)
        local _, pos = resp:find('<div class="row">')
        local body = resp:sub(pos)
        local icons = {}
        for entry in body:gmatch('(icon-%S+);</i>') do
            entry = entry:gsub('">', ' '):gsub('&#', '0')
            local parts = entry:Split(' ')
            icons[parts[1]] = parts[2]
        end

        d:resolve(icons)
    end)
    return d
end

function getIcon(id, raw)
    local code = raw and id or ICON_FONT[id]
    if not code then return '' end
    return utf8.char(tonumber(code))
end

concommand.Add("test_icons", function()
    if not ICON_FONT then
        chat.AddText(Color(255, 100, 100), L("iconTesterNotLoaded"))
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("iconTesterTitle"))
    frame:SetSize(500, 250)
    frame:Center()
    frame:MakePopup()
    local list = vgui.Create("DListView", frame)
    list:SetPos(10, 30)
    list:SetSize(220, 200)
    list:AddColumn(L("iconName"))
    for name in pairs(ICON_FONT) do
        list:AddLine(name)
    end

    local entry = vgui.Create("DTextEntry", frame)
    entry:SetPos(240, 30)
    entry:SetSize(250, 20)
    entry:SetPlaceholderText(L("iconPlaceholder"))
    local label = vgui.Create("DLabel", frame)
    label:SetPos(240, 60)
    label:SetFont("liaIconsMediumNew")
    label:SetText("")
    label:SizeToContents()
    list.OnRowSelected = function(_, _, row)
        local name = row:GetColumnText(1)
        label:SetText(getIcon(name, false))
        label:SizeToContents()
    end

    entry.OnEnter = function(self)
        label:SetText(getIcon(self:GetValue(), true))
        label:SizeToContents()
    end
end, nil, "Opens a UI to test icons")

hook.Add("InitializedModules", "EasyIconsInitializedModules", function()
    ScrapPage():next(function(icons)
        ICON_FONT = icons
        hook.Run('EasyIconsLoaded')
    end)
end)
