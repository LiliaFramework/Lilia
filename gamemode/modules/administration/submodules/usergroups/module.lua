MODULE.name = "Usergroups"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Lists CAMI usergroups."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Manage UserGroups",
        MinAccess = "superadmin"
    }
}

local DEFAULT_GROUPS = {
    user = true,
    admin = true,
    superadmin = true
}

local CHUNK = 60000
local function buildDefaultTable(g)
    local t = {}
    for _, v in ipairs(CAMI.GetPrivileges() or {}) do
        if CAMI.UsergroupInherits(g, v.MinAccess or "user") then t[v.Name] = true end
    end
    return t
end

local function ensureCAMIGroup(n, inh)
    local g = CAMI.GetUsergroups() or {}
    if not g[n] then
        CAMI.RegisterUsergroup({
            Name = n,
            Inherits = inh or "user"
        })
    end
end

local function dropCAMIGroup(n)
    local g = CAMI.GetUsergroups() or {}
    if g[n] then CAMI.UnregisterUsergroup(n) end
end

if SERVER then
    util.AddNetworkString("liaGroupsAdd")
    util.AddNetworkString("liaGroupsRemove")
    util.AddNetworkString("liaGroupsRequest")
    util.AddNetworkString("liaGroupsApply")
    util.AddNetworkString("liaGroupsDefaults")
    util.AddNetworkString("liaGroupsDataChunk")
    util.AddNetworkString("liaGroupsDataDone")
    util.AddNetworkString("liaGroupsNotice")
    lia.admin.privileges = lia.admin.privileges or {}
    lia.admin.groups = lia.admin.groups or {}
    local function syncPrivileges()
        for _, v in ipairs(CAMI.GetPrivileges() or {}) do
            lia.admin.privileges[v.Name] = {
                Name = v.Name,
                MinAccess = v.MinAccess or "user"
            }
        end

        for n, d in pairs(CAMI.GetUsergroups() or {}) do
            lia.admin.groups[n] = lia.admin.groups[n] or buildDefaultTable(n)
            ensureCAMIGroup(n, d.Inherits or "user")
        end
    end

    local function allowed(p)
        return IsValid(p) and p:IsSuperAdmin() and p:hasPrivilege("Staff Permissions - Manage UserGroups")
    end

    local function getPrivList()
        local t = {}
        for n in pairs(lia.admin.privileges) do
            t[#t + 1] = n
        end

        table.sort(t)
        return t
    end

    local function payload()
        return {
            cami = CAMI.GetUsergroups() or {},
            perms = lia.admin.groups or {},
            privList = getPrivList()
        }
    end

    local function sendBigTable(ply, tbl)
        local raw = util.TableToJSON(tbl)
        local comp = util.Compress(raw)
        local len = #comp
        local id = util.CRC(tostring(SysTime()) .. len)
        local parts = math.ceil(len / CHUNK)
        for i = 1, parts do
            local chunk = string.sub(comp, (i - 1) * CHUNK + 1, math.min(i * CHUNK, len))
            net.Start("liaGroupsDataChunk")
            net.WriteString(id)
            net.WriteUInt(i, 16)
            net.WriteUInt(parts, 16)
            net.WriteUInt(#chunk, 16)
            net.WriteData(chunk, #chunk)
            if IsEntity(ply) then
                net.Send(ply)
            else
                net.Broadcast()
            end
        end

        net.Start("liaGroupsDataDone")
        net.WriteString(id)
        if IsEntity(ply) then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end

    local function broadcastGroups()
        sendBigTable(nil, payload())
    end

    local function applyToCAMI(g, t)
        ensureCAMIGroup(g, CAMI.GetUsergroups()[g] and CAMI.GetUsergroups()[g].Inherits or "user")
        hook.Run("CAMI.OnUsergroupPermissionsChanged", g, t)
    end

    local function notify(p, msg)
        if IsValid(p) and p.notify then p:notify(msg) end
        net.Start("liaGroupsNotice")
        net.WriteString(msg)
        if IsEntity(p) then
            net.Send(p)
        else
            net.Broadcast()
        end
    end

    syncPrivileges()
    net.Receive("liaGroupsRequest", function(_, p)
        if not allowed(p) then return end
        syncPrivileges()
        sendBigTable(p, payload())
    end)

    net.Receive("liaGroupsAdd", function(_, p)
        if not allowed(p) then return end
        local n = net.ReadString()
        if n == "" then return end
        lia.admin.createGroup(n)
        lia.admin.groups[n] = buildDefaultTable(n)
        ensureCAMIGroup(n, "user")
        lia.admin.save(true)
        applyToCAMI(n, lia.admin.groups[n])
        broadcastGroups()
        notify(p, "Group '" .. n .. "' created.")
    end)

    net.Receive("liaGroupsRemove", function(_, p)
        if not allowed(p) then return end
        local n = net.ReadString()
        if n == "" or DEFAULT_GROUPS[n] then return end
        lia.admin.removeGroup(n)
        lia.admin.groups[n] = nil
        dropCAMIGroup(n)
        lia.admin.save(true)
        broadcastGroups()
        notify(p, "Group '" .. n .. "' removed.")
    end)

    net.Receive("liaGroupsApply", function(_, p)
        if not allowed(p) then return end
        local g = net.ReadString()
        local t = net.ReadTable()
        if g == "" or DEFAULT_GROUPS[g] then return end
        lia.admin.groups[g] = {}
        for k, v in pairs(t) do
            if v then lia.admin.groups[g][k] = true end
        end

        lia.admin.save(true)
        applyToCAMI(g, lia.admin.groups[g])
        broadcastGroups()
        notify(p, "Permissions saved for '" .. g .. "'.")
    end)

    net.Receive("liaGroupsDefaults", function(_, p)
        if not allowed(p) then return end
        local g = net.ReadString()
        if g == "" or DEFAULT_GROUPS[g] then return end
        lia.admin.groups[g] = buildDefaultTable(g)
        lia.admin.save(true)
        applyToCAMI(g, lia.admin.groups[g])
        broadcastGroups()
        notify(p, "Defaults restored for '" .. g .. "'.")
    end)
else
    local chunks = {}
    local PRIV_LIST = {}
    local LAST_GROUP
    local function setFont(o, f)
        if IsValid(o) then o:SetFont(f) end
    end

    local function renderGroupInfo(parent, g, cami, perms)
        parent:Clear()
        LAST_GROUP = g
        local scroll = parent:Add("DScrollPanel")
        scroll:Dock(FILL)
        local btnBar = scroll:Add("DPanel")
        btnBar:Dock(TOP)
        btnBar:SetTall(36)
        btnBar:DockMargin(20, 20, 20, 12)
        btnBar.Paint = function() end
        local editable = not DEFAULT_GROUPS[g]
        local tickAll = btnBar:Add("liaSmallButton")
        tickAll:Dock(LEFT)
        tickAll:SetWide(90)
        tickAll:SetText("Tick All")
        local untickAll = btnBar:Add("liaSmallButton")
        untickAll:Dock(LEFT)
        untickAll:DockMargin(6, 0, 0, 0)
        untickAll:SetWide(90)
        untickAll:SetText("Untick All")
        local defaultsBtn = btnBar:Add("liaSmallButton")
        defaultsBtn:Dock(LEFT)
        defaultsBtn:DockMargin(6, 0, 0, 0)
        defaultsBtn:SetWide(90)
        defaultsBtn:SetText("Defaults")
        local saveBtn = btnBar:Add("liaSmallButton")
        saveBtn:Dock(RIGHT)
        saveBtn:SetWide(90)
        saveBtn:SetText("Save")
        if not editable then
            tickAll:SetEnabled(false)
            untickAll:SetEnabled(false)
            defaultsBtn:SetEnabled(false)
            saveBtn:SetEnabled(false)
        end

        local delBtn
        if not DEFAULT_GROUPS[g] then
            delBtn = btnBar:Add("liaSmallButton")
            delBtn:Dock(RIGHT)
            delBtn:DockMargin(0, 0, 6, 0)
            delBtn:SetWide(90)
            delBtn:SetText("Delete")
        end

        local nameLbl = scroll:Add("DLabel")
        nameLbl:Dock(TOP)
        nameLbl:DockMargin(20, 0, 0, 0)
        nameLbl:SetText("Name:")
        setFont(nameLbl, "liaBigFont")
        nameLbl:SizeToContents()
        local nameVal = scroll:Add("DLabel")
        nameVal:Dock(TOP)
        nameVal:DockMargin(20, 2, 0, 10)
        nameVal:SetText(g)
        setFont(nameVal, "liaMediumFont")
        nameVal:SizeToContents()
        local inhLbl = scroll:Add("DLabel")
        inhLbl:Dock(TOP)
        inhLbl:DockMargin(20, 10, 0, 0)
        inhLbl:SetText("Inherits from:")
        setFont(inhLbl, "liaBigFont")
        inhLbl:SizeToContents()
        local inh = cami[g] and cami[g].Inherits or "user"
        local inhVal = scroll:Add("DLabel")
        inhVal:Dock(TOP)
        inhVal:DockMargin(20, 2, 0, 20)
        inhVal:SetText(inh)
        setFont(inhVal, "liaMediumFont")
        inhVal:SizeToContents()
        local privLbl = scroll:Add("DLabel")
        privLbl:Dock(TOP)
        privLbl:DockMargin(20, 0, 0, 6)
        privLbl:SetText("Privileges")
        setFont(privLbl, "liaBigFont")
        privLbl:SizeToContents()
        local listHolder = scroll:Add("DPanel")
        listHolder:Dock(TOP)
        listHolder:DockMargin(20, 0, 20, 20)
        listHolder:InvalidateParent(true)
        listHolder:SetTall(0)
        listHolder.Paint = function() end
        local list = vgui.Create("DListLayout", listHolder)
        list:Dock(FILL)
        local current = table.Copy(perms[g] or {})
        local checkboxes = {}
        surface.SetFont("liaMediumFont")
        local _, fh = surface.GetTextSize("W")
        local rowH = fh + 24
        local off = math.floor((rowH - fh) * 0.5)
        for _, priv in ipairs(PRIV_LIST) do
            local row = vgui.Create("DPanel", list)
            row:SetTall(rowH)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 10)
            row.Paint = function() end
            local lbl = row:Add("DLabel")
            lbl:Dock(LEFT)
            lbl:SetText(priv)
            setFont(lbl, "liaMediumFont")
            lbl:SizeToContents()
            lbl:DockMargin(0, off, 12, 0)
            local chk = row:Add("liaCheckBox")
            chk:Dock(LEFT)
            chk:SetWide(32)
            chk:SetChecked(current[priv] and true or false)
            chk.OnChange = function(_, v)
                if v then
                    current[priv] = true
                else
                    current[priv] = nil
                end
            end

            if not editable then chk:SetEnabled(false) end
            row.PerformLayout = function(_, w, h)
                local m = math.floor((h - chk:GetTall()) * 0.5)
                chk:DockMargin(0, m, 0, 0)
            end

            checkboxes[#checkboxes + 1] = chk
        end

        list:InvalidateLayout(true)
        local h = 0
        for _, c in ipairs(list:GetChildren()) do
            h = h + c:GetTall() + 10
        end

        listHolder:SetTall(h)
        local function setAll(state)
            for _, cb in ipairs(checkboxes) do
                cb:SetChecked(state)
            end
        end

        tickAll.DoClick = function() if editable then setAll(true) end end
        untickAll.DoClick = function() if editable then setAll(false) end end
        defaultsBtn.DoClick = function()
            if not editable then return end
            net.Start("liaGroupsDefaults")
            net.WriteString(g)
            net.SendToServer()
        end

        saveBtn.DoClick = function()
            if not editable then return end
            net.Start("liaGroupsApply")
            net.WriteString(g)
            net.WriteTable(current)
            net.SendToServer()
        end

        if delBtn then
            delBtn.DoClick = function()
                Derma_Query("Delete group '" .. g .. "'?", "Confirm", "Yes", function()
                    net.Start("liaGroupsRemove")
                    net.WriteString(g)
                    net.SendToServer()
                end, "No")
            end
        end
    end

    local function buildGroupsUI(panel, cami, perms)
        panel:Clear()
        local sidebar = panel:Add("DScrollPanel")
        sidebar:Dock(RIGHT)
        sidebar:SetWide(200)
        sidebar:DockMargin(0, 20, 20, 20)
        local content = panel:Add("DPanel")
        content:Dock(FILL)
        content:DockMargin(10, 10, 10, 10)
        local selected
        local keys = {}
        for g in pairs(cami) do
            keys[#keys + 1] = g
        end

        table.sort(keys)
        for _, g in ipairs(keys) do
            local b = sidebar:Add("liaMediumButton")
            b:Dock(TOP)
            b:DockMargin(0, 0, 0, 10)
            b:SetTall(40)
            b:SetText(g)
            b.DoClick = function()
                if IsValid(selected) then selected:SetSelected(false) end
                b:SetSelected(true)
                selected = b
                renderGroupInfo(content, g, cami, perms)
            end
        end

        local addBtn = sidebar:Add("liaMediumButton")
        addBtn:Dock(TOP)
        addBtn:DockMargin(0, 20, 0, 0)
        addBtn:SetTall(36)
        addBtn:SetText("Create Group")
        addBtn.DoClick = function()
            Derma_StringRequest("Create Group", "New group name:", "", function(txt)
                if txt == "" then return end
                LAST_GROUP = txt
                net.Start("liaGroupsAdd")
                net.WriteString(txt)
                net.SendToServer()
            end)
        end

        if LAST_GROUP and cami[LAST_GROUP] then
            for _, b in ipairs(sidebar:GetChildren()) do
                if b.GetText and b:GetText() == LAST_GROUP then
                    b:DoClick()
                    break
                end
            end
        else
            local first = keys[1]
            if first then
                for _, b in ipairs(sidebar:GetChildren()) do
                    if b.GetText and b:GetText() == first then
                        b:DoClick()
                        break
                    end
                end
            end
        end
    end

    local function handleDone(id)
        local data = table.concat(chunks[id])
        chunks[id] = nil
        local tbl = util.JSONToTable(util.Decompress(data) or "") or {}
        PRIV_LIST = tbl.privList or {}
        lia.admin.groups = tbl.perms or {}
        if IsValid(lia.gui.usergroups) then buildGroupsUI(lia.gui.usergroups, tbl.cami or {}, lia.admin.groups) end
    end

    net.Receive("liaGroupsDataChunk", function()
        local id = net.ReadString()
        local idx = net.ReadUInt(16)
        local total = net.ReadUInt(16)
        local len = net.ReadUInt(16)
        local dat = net.ReadData(len)
        chunks[id] = chunks[id] or {}
        chunks[id][idx] = dat
        if idx == total then handleDone(id) end
    end)

    net.Receive("liaGroupsDataDone", function()
        local id = net.ReadString()
        if chunks[id] then handleDone(id) end
    end)

    net.Receive("liaGroupsNotice", function()
        local msg = net.ReadString()
        if IsValid(LocalPlayer()) and LocalPlayer().notify then LocalPlayer():notify(msg) end
    end)

    function MODULE:CreateMenuButtons(tabs)
        if IsValid(LocalPlayer()) and LocalPlayer():IsSuperAdmin() and LocalPlayer():hasPrivilege("Staff Permissions - Manage UserGroups") then
            tabs[L("userGroups")] = function(parent)
                lia.gui.usergroups = parent
                parent:Clear()
                parent:DockPadding(10, 10, 10, 10)
                parent.Paint = function(p, w, h) derma.SkinHook("Paint", "Frame", p, w, h) end
                net.Start("liaGroupsRequest")
                net.SendToServer()
            end
        end
    end
end

hook.Add("CAMI.OnUsergroupRegistered", "liaSyncAdminGroupAdd", function(g)
    if lia.admin.isDisabled() then return end
    lia.admin.groups[g.Name] = buildDefaultTable(g.Name)
    if SERVER then
        ensureCAMIGroup(g.Name, g.Inherits or "user")
        lia.admin.save(true)
    end
end)

hook.Add("CAMI.OnUsergroupUnregistered", "liaSyncAdminGroupRemove", function(g)
    if lia.admin.isDisabled() then return end
    lia.admin.groups[g.Name] = nil
    if SERVER then
        dropCAMIGroup(g.Name)
        lia.admin.save(true)
    end
end)

hook.Add("CAMI.OnPrivilegeRegistered", "liaSyncAdminPrivilegeAdd", function(pv)
    if lia.admin.isDisabled() or not pv or not pv.Name then return end
    lia.admin.privileges[pv.Name] = {
        Name = pv.Name,
        MinAccess = pv.MinAccess or "user"
    }

    for g in pairs(lia.admin.groups) do
        if CAMI.UsergroupInherits(g, pv.MinAccess or "user") then lia.admin.groups[g][pv.Name] = true end
    end

    if SERVER then lia.admin.save(true) end
end)

hook.Add("CAMI.OnPrivilegeUnregistered", "liaSyncAdminPrivilegeRemove", function(pv)
    if lia.admin.isDisabled() or not pv or not pv.Name then return end
    lia.admin.privileges[pv.Name] = nil
    for _, p in pairs(lia.admin.groups) do
        p[pv.Name] = nil
    end

    if SERVER then lia.admin.save(true) end
end)