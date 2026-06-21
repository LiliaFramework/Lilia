local MODULE = MODULE

lia.secondaryBases = lia.secondaryBases or {}

local REQUIRED_FLAG = lia.config and lia.config.get and lia.config.get("SecondaryBasesFlag", "S") or "S"

function MODULE:CreateMenuButtons(tabs)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local char = client:getChar()
    if not char then return end
    if not char:hasFlags(REQUIRED_FLAG) then return end
    if not client:IsAdmin() then return end

    tabs["secondaryBases"] = {
        name = "secondaryBases",
        func = function(panel)
            panel:Clear()
            panel:DockPadding(6, 6, 6, 6)
            panel.Paint = nil
            local list = panel:Add("liaTable")
            list:Dock(FILL)
            list:AddColumn("Name")
            list:AddColumn("Factions")
            list:AddColumn("Enabled")
            list.OnRowSelected = function(_, line)
                if not IsValid(line) then return end
            end

            panel.secondaryList = list
            net.Start("liaSecondaryBases_RequestList") net.SendToServer()
                    -- add map view button
                    local btnMap = vgui.Create("liaButton")
                    btnMap:SetText("Map View")
                    btnMap:Dock(BOTTOM)
                    btnMap:DockMargin(0, 6, 0, 0)
                    btnMap.DoClick = function()
                        net.Start("liaSecondaryBases_MapViewRequest") net.SendToServer()
                    end
                    panel:Add(btnMap)
        end
    }
end

local function buildAdminList(panel, bases)
    if not IsValid(panel) or not panel.secondaryList then return end
    local list = panel.secondaryList
    for _, child in ipairs(list:GetChildren()) do child:Remove() end
    list:Clear()
    for _, b in ipairs(bases) do
        local factions = b.factions and #b.factions > 0 and table.concat(b.factions, ", ") or "All"
        local line = list:AddLine(b.name or ("#" .. tostring(b.id or "?")), factions, b.enabled and "Yes" or "No")
        if line then
            line.baseID = b.id
            line.bdata = b
            local btnToggle = vgui.Create("liaButton")
            btnToggle:SetText(b.enabled and "Disable" or "Enable")
            btnToggle.DoClick = function()
                net.Start("liaSecondaryBases_Toggle") net.WriteUInt(b.id or 0, 32) net.WriteBool(not not (not b.enabled)) net.SendToServer()
            end

            local btnRemove = vgui.Create("liaButton")
            btnRemove:SetText("Remove")
            btnRemove.DoClick = function()
                Derma_Query("Confirm remove", "Are you sure?", "Yes", function() net.Start("liaSecondaryBases_Remove") net.WriteUInt(b.id or 0, 32) net.SendToServer() end, "No", function() end)
            end

            list:AddPanelToLine(line, btnToggle)
            list:AddPanelToLine(line, btnRemove)
        end
    end
    list:ForceCommit()
end

net.Receive("liaSecondaryBases_Sync", function()
    local count = net.ReadUInt(16)
    local bases = {}
    for i = 1, count do
        local id = net.ReadUInt(32)
        local name = net.ReadString()
        local enabled = net.ReadBool()
        local map = net.ReadString()
        local fcount = net.ReadUInt(16)
        local factions = {}
        for j = 1, fcount do factions[j] = net.ReadString() end
        local pos = net.ReadType()
        local ang = net.ReadType()
        bases[#bases + 1] = {id = id, name = name, enabled = enabled, map = map, factions = factions, pos = pos, ang = ang}
    end

    -- find open panel
    if IsValid(lia.gui.menu) and lia.gui.menu.tabList and lia.gui.menu.tabList["secondaryBases"] then
        local pan = lia.gui.menu.tabList["secondaryBases"].pan
        if IsValid(pan) then buildAdminList(pan, bases) end
    end
end)

-- Availability responses (for spawn menu integration)
net.Receive("liaSecondaryBases_Available", function()
    local count = net.ReadUInt(16)
    local avail = {}
    for i = 1, count do
        local id = net.ReadUInt(32)
        local name = net.ReadString()
        local map = net.ReadString()
        local pos = net.ReadType()
        local ang = net.ReadType()
        avail[#avail + 1] = {id = id, name = name, map = map, pos = pos, ang = ang}
    end
    lia.secondaryBases.available = avail
    hook.Run("SecondaryBasesUpdated", avail)
    if lia.secondaryBases._awaitingRespawn == true then
        lia.secondaryBases._awaitingRespawn = false
        -- open simple selection UI
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Select spawn point")
        frame:SetSize(480, 320)
        frame:Center()
        frame:MakePopup()
        local list = vgui.Create("DPanelList", frame)
        list:Dock(FILL)
        list:EnableVerticalScrollbar(true)
        list:DockMargin(8, 8, 8, 8)
            for _, b in ipairs(avail) do
            local btn = vgui.Create("DButton")
            btn:SetText(b.name or ("#" .. tostring(b.id)))
            btn:SetTall(40)
            btn.DoClick = function()
                    local question = ("Spawn at %s?"):format(b.name or "Unknown")
                    Derma_Query(question, "Confirm", "Yes", function()
                        lia.secondaryBases.SpawnAt(b.id)
                        frame:Close()
                    end, "No", function() end)
            end
            list:AddItem(btn)
        end
    end
end)

local MAP_IMG = "https://i.imgur.com/DbXAJ3m.jpeg"

net.Receive("liaSecondaryBases_MapViewResponse", function()
    local count = net.ReadUInt(16)
    local bases = {}
    for i = 1, count do
        local id = net.ReadUInt(32)
        local name = net.ReadString()
        local pos = net.ReadVector()
        local enabled = net.ReadBool()
        local fcount = net.ReadUInt(16)
        local facs = {}
        for j = 1, fcount do facs[j] = net.ReadString() end
        bases[#bases + 1] = {id = id, name = name, pos = pos, enabled = enabled, factions = facs}
    end
    local minV = net.ReadVector()
    local maxV = net.ReadVector()

    -- open map UI
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Secondary Bases")
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()

    local html = vgui.Create("DHTML", frame)
    html:Dock(FILL)
    local htmlStr = [[
        <html><body style="margin:0;overflow:hidden;background:#111;">
        <img src=']] .. MAP_IMG .. [[' style="width:100%;height:100%;object-fit:contain;" />
        </body></html>
    ]]
    html:SetHTML(htmlStr)

    local overlay = vgui.Create("DPanel", frame)
    overlay:SetMouseInputEnabled(true)
    overlay:Dock(FILL)
    overlay.Paint = function(self, w, h)
        -- draw grid
        surface.SetDrawColor(80, 80, 80, 80)
        local cols, rows = 16, 12
        for i = 0, cols do
            local x = i / cols * w
            surface.DrawLine(x, 0, x, h)
        end
        for j = 0, rows do
            local y = j / rows * h
            surface.DrawLine(0, y, w, y)
        end
        -- draw icons
        for _, b in ipairs(bases) do
            if not b.pos then continue end
            local nx = (b.pos.x - minV.x) / math.max(1, (maxV.x - minV.x))
            local ny = 1 - ((b.pos.y - minV.y) / math.max(1, (maxV.y - minV.y)))
            local px = math.Clamp(nx * w, 0, w)
            local py = math.Clamp(ny * h, 0, h)
            local col = b.enabled and Color(100, 220, 100, 220) or Color(200, 80, 80, 200)
            draw.RoundedBox(8, px - 10, py - 10, 20, 20, col)
            surface.SetFont("LiliaFont.14")
            local txt = b.name or ("#" .. tostring(b.id))
            surface.SetTextColor(255,255,255)
            surface.SetTextPos(px + 12, py - 8)
            surface.DrawText(txt)
        end
    end

    overlay.OnMouseReleased = function(self, code)
        local mx, my = gui.MousePos()
        local gx, gy = frame:LocalToScreen(0, 0)
        local x = mx - gx
        local y = my - gy
        local w, h = overlay:GetSize()
        -- find closest base within radius
        local best, bestDist = nil, 1e9
        for _, b in ipairs(bases) do
            local nx = (b.pos.x - minV.x) / math.max(1, (maxV.x - minV.x))
            local ny = 1 - ((b.pos.y - minV.y) / math.max(1, (maxV.y - minV.y)))
            local px = math.Clamp(nx * w, 0, w)
            local py = math.Clamp(ny * h, 0, h)
            local d = math.sqrt((px - x)^2 + (py - y)^2)
            if d < bestDist then bestDist = d best = b end
        end
        if best and bestDist <= 32 then
            Derma_Query(("Spawn at %s?"):format(best.name or ""), "Confirm", "Yes", function() lia.secondaryBases.SpawnAt(best.id) frame:Close() end, "No", function() end)
        end
    end
end)

function lia.secondaryBases.RequestAvailable()
    net.Start("liaSecondaryBases_RequestAvailable") net.SendToServer()
end

function lia.secondaryBases.SpawnAt(id)
    net.Start("liaSecondaryBases_Select") net.WriteUInt(id or 0, 32) net.SendToServer()
end

function MODULE:OnRespawnKeyPressed(ply, key, left, baseTime, lastDeath)
    -- Intercept respawn key and present secondary base options if available
    if ply ~= LocalPlayer() then return end
    if left > 0 then return end
    lia.secondaryBases._awaitingRespawn = true
    lia.secondaryBases.RequestAvailable()
    return false
end
