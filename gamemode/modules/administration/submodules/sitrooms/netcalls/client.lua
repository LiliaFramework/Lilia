local function sendSitroomAction(action, name, newName)
    net.Start("liaManagesitroomsAction")
    net.WriteUInt(action, 2)
    net.WriteString(name)
    if action == 2 then net.WriteString(newName or "") end
    net.SendToServer()
end

local function openRenamePrompt(parent, name)
    local prompt = vgui.Create("liaFrame")
    prompt:SetTitle("Rename Administration Room")
    prompt:SetSize(300, 100)
    prompt:Center()
    prompt:MakePopup()
    local txt = vgui.Create("liaEntry", prompt)
    txt:Dock(FILL)
    local ok = vgui.Create("liaButton", prompt)
    ok:Dock(BOTTOM)
    ok:SetText(string.upper("Ok"))
    ok.DoClick = function()
        local newName = txt:GetValue() or ""
        if newName == "" then return end
        sendSitroomAction(2, name, newName)
        prompt:Close()
        if IsValid(parent) then parent:Close() end
    end
end

net.Receive("liaManagesitrooms", function()
    local client = LocalPlayer()
    if not IsValid(client) or not client:hasPrivilege("manageSitRooms") then return end
    local rooms = net.ReadTable() or {}
    local frame = vgui.Create("liaFrame")
    frame:SetTitle("Manage Administration Rooms")
    frame:SetSize(640, 420)
    frame:Center()
    frame:MakePopup()
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 30, 10, 10)
    for name in pairs(rooms) do
        local entry = vgui.Create("DPanel", scroll)
        entry:SetTall(40)
        entry:Dock(TOP)
        entry:DockMargin(0, 0, 0, 5)
        local lbl = vgui.Create("DLabel", entry)
        lbl:Dock(LEFT)
        lbl:DockMargin(5, 0, 0, 0)
        lbl:SetText(name)
        lbl:SetTall(40)
        lbl:SetContentAlignment(4)
        local function makeButton(key, action)
            local btn = vgui.Create("liaButton", entry)
            btn:Dock(RIGHT)
            btn:SetWide(80)
            btn:SetText(tostring(key))
            btn.DoClick = function()
                if action == 2 then
                    openRenamePrompt(frame, name)
                    return
                end

                sendSitroomAction(action, name)
                frame:Close()
            end
        end

        makeButton("Teleport", 1)
        makeButton("Reposition", 3)
        makeButton("Rename", 2)
    end
end)
