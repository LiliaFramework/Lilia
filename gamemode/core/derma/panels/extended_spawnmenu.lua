local function getGameList()
    local games = engine.GetGames()
    table.insert(games, {
        title = L("spawnmenuAll"),
        folder = "GAME",
        icon = "all",
        mounted = true
    })

    table.insert(games, {
        title = L("spawnmenuGMod"),
        folder = "garrysmod",
        icon = nil,
        mounted = true
    })
    return games
end

local currentSound
local function playSound(path)
    if currentSound then currentSound:Stop() end
    currentSound = CreateSound(LocalPlayer(), path)
    currentSound:Play()
end

local materialWarningShown
local function isMaterialUsable(path)
    if string.GetExtensionFromFilename(path) then return false end
    local shader = Material(path):GetShader()
    for _, s in ipairs({"LightmappedGeneric", "WorldVertexTransition", "Spritecard", "Water", "Cable", "Refract"}) do
        if shader:find(s) then return false end
    end
    return true
end

local function showMaterialWarning()
    if materialWarningShown then return end
    materialWarningShown = true
    Derma_Message(L("materialWarning"), L("warning"), L("ok"))
end

local function registerContentType(typeName, setupIcon, onClick, menuEntries)
    spawnmenu.AddContentType(typeName, function(container, obj)
        if not obj.nicename or not obj.spawnname then return end
        local icon = vgui.Create("ContentIcon", container)
        icon:SetContentType(typeName)
        icon:SetSpawnName(obj.spawnname)
        icon:SetName(obj.nicename)
        setupIcon(icon, obj.spawnname)
        icon.DoClick = function() onClick(obj.spawnname) end
        icon.OpenMenu = function(icn)
            local menu = DermaMenu()
            for _, e in ipairs(menuEntries) do
                if e.spacer then
                    menu:AddSpacer()
                else
                    local txt = isfunction(e.text) and e.text(obj.spawnname) or e.text
                    menu:AddOption(txt, function() e.action(obj.spawnname, icn) end):SetIcon(e.icon)
                end
            end

            menu:Open()
        end

        container:Add(icon)
        return icon
    end)
end

registerContentType("sound", function(icon) icon:SetMaterial("icon16/sound.png") end, playSound, {
    {
        text = "#spawnmenu.menu.copy",
        icon = "icon16/page_copy.png",
        action = function(p) SetClipboardText(p) end
    },
    {
        text = "Stop all sounds",
        icon = "icon16/sound_mute.png",
        action = function() RunConsoleCommand("stopsound") end
    },
    {
        spacer = true
    },
    {
        text = "#spawnmenu.menu.delete",
        icon = "icon16/bin_closed.png",
        action = function(_, icn)
            icn:Remove()
            hook.Run("SpawnlistContentChanged", icn)
        end
    }
})

registerContentType("material", function(icon, path)
    if path:match("%.png$") then
        icon:SetMaterial(path)
    else
        icon.Image:SetImage(path)
    end
end, function(path)
    if not isMaterialUsable(path) then showMaterialWarning() end
    RunConsoleCommand("material_override", path)
    spawnmenu.ActivateTool("material")
    surface.PlaySound("garrysmod/ui_click.wav")
end, {
    {
        text = "#spawnmenu.menu.copy",
        icon = "icon16/page_copy.png",
        action = function(p) SetClipboardText(p) end
    },
    {
        text = function(p) return isMaterialUsable(p) and "Use with Material Tool" or "Try with Material Tool (may not work)" end,
        icon = "icon16/pencil.png",
        action = function(p)
            RunConsoleCommand("material_override", p)
            spawnmenu.ActivateTool("material")
        end
    },
    {
        spacer = true
    },
    {
        text = "#spawnmenu.menu.delete",
        icon = "icon16/bin_closed.png",
        action = function(_, icn)
            icn:Remove()
            hook.Run("SpawnlistContentChanged", icn)
        end
    }
})

local function onFileNodeSelected(self)
    local view, pnl = self.ViewPanel, self.pnlContent
    view:Clear(true)
    local path, pathID = self.BasePath, self.PathID
    local files = {}
    for _, ext in ipairs(self.Extensions) do
        files = table.Add(files, file.Find(path .. "/*" .. ext, pathID))
    end

    local offset, limit = self.offset or 0, 512
    if #files > offset + limit and not self.Done then
        self.Done = true
        local newOff = offset + limit
        local page = (self.Parent or self):AddNode((self.Text or self:GetText()) .. " (" .. newOff .. " - " .. newOff + limit .. ")")
        page.ViewPanel, page.pnlContent, page.Parent, page.Text = view, pnl, self.Parent, self.Text or self:GetText()
        page.offset, page.BasePath, page.PathID, page.Extensions, page.SpawnType = newOff, path, pathID, self.Extensions, self.SpawnType
        page.OnNodeSelected = function() onFileNodeSelected(page) end
    end

    for i = offset + 1, math.min(#files, offset + limit) do
        local fname = files[i]
        local rel = path .. "/" .. fname
        if path:match("^addons/") or path:match("^download/") then
            local s = rel:find("/sound/") or rel:find("/materials/")
            if s then rel = rel:sub(s + 1) end
        end

        spawnmenu.CreateContentIcon(self.SpawnType, view, {
            spawnname = rel,
            nicename = fname
        })
    end

    pnl:SwitchPanel(view)
end

local function addBrowseContent(node, title, icon, folder, pathID, exts, spawnType)
    local view, pnl = node.ViewPanel, node.pnlContent
    local f, d = file.Find(folder, pathID)
    if not (f and #f > 0 or d and #d > 0) then return end
    local n = node:AddFolder(title, folder, pathID, false, false, "*.*")
    n:SetIcon(icon)
    n.ViewPanel, n.pnlContent = view, pnl
    n.BasePath, n.PathID, n.Extensions, n.SpawnType = folder, pathID, exts, spawnType
    n.OnNodeSelected = onFileNodeSelected
end

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, tree)
    timer.Simple(0.5, function()
        if not IsValid(tree) or not IsValid(pnlContent) then return end
        local view = vgui.Create("ContentContainer", pnlContent)
        view:SetVisible(false)
        local root = tree:AddNode(L("browseSoundsTitle"), "icon16/sound.png")
        root.ViewPanel, root.pnlContent = view, pnlContent
        local addons = root:AddNode("#spawnmenu.category.addons", "icon16/folder_database.png")
        addons.ViewPanel, addons.pnlContent = view, pnlContent
        for _, a in SortedPairsByMemberValue(engine.GetAddons(), "title") do
            if a.downloaded and a.mounted and table.HasValue(select(2, file.Find("*", a.title)), "sound") then addBrowseContent(addons, a.title, "icon16/bricks.png", a.title .. "/sound", a.title, {".wav", ".mp3", ".ogg"}, "sound") end
        end

        local legacy = root:AddNode("#spawnmenu.category.addonslegacy", "icon16/folder_database.png")
        legacy.ViewPanel, legacy.pnlContent = view, pnlContent
        for _, folder in ipairs(file.Find("addons/*", "MOD")) do
            if file.IsDir("addons/" .. folder .. "/sound/", "MOD") then addBrowseContent(legacy, folder, "icon16/bricks.png", "addons/" .. folder .. "/sound", "MOD", {".wav", ".mp3", ".ogg"}, "sound") end
        end

        addBrowseContent(root, "#spawnmenu.category.downloads", "icon16/folder_database.png", "download/sound", "MOD", {".wav", ".mp3", ".ogg"}, "sound")
        local gamesNode = root:AddNode("#spawnmenu.category.games", "icon16/folder_database.png")
        gamesNode.ViewPanel, gamesNode.pnlContent = view, pnlContent
        for _, g in ipairs(getGameList()) do
            if g.mounted then addBrowseContent(gamesNode, g.title, "games/16/" .. (g.icon or g.folder) .. ".png", g.folder .. "/sound", g.folder, {".wav", ".mp3", ".ogg"}, "sound") end
        end
    end)
end)

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, tree)
    timer.Simple(0.5, function()
        if not IsValid(tree) or not IsValid(pnlContent) then return end
        local view = vgui.Create("ContentContainer", pnlContent)
        view:SetVisible(false)
        local root = tree:AddNode(L("browseMaterialsTitle"), "icon16/picture_empty.png")
        root.ViewPanel, root.pnlContent = view, pnlContent
        local addons = root:AddNode("#spawnmenu.category.addons", "icon16/folder_database.png")
        addons.ViewPanel, addons.pnlContent = view, pnlContent
        for _, a in SortedPairsByMemberValue(engine.GetAddons(), "title") do
            if a.downloaded and a.mounted and table.HasValue(select(2, file.Find("*", a.title)), "materials") then addBrowseContent(addons, a.title, "icon16/bricks.png", a.title .. "/materials", a.title, {".vmt", ".png"}, "material") end
        end

        local legacy = root:AddNode("#spawnmenu.category.addonslegacy", "icon16/folder_database.png")
        legacy.ViewPanel, legacy.pnlContent = view, pnlContent
        for _, folder in ipairs(file.Find("addons/*", "MOD")) do
            if file.IsDir("addons/" .. folder .. "/materials/", "MOD") then addBrowseContent(legacy, folder, "icon16/bricks.png", "addons/" .. folder .. "/materials", "MOD", {".vmt", ".png"}, "material") end
        end

        addBrowseContent(root, "#spawnmenu.category.downloads", "icon16/folder_database.png", "download/materials", "MOD", {".vmt", ".png"}, "material")
        local gamesNode = root:AddNode("#spawnmenu.category.games", "icon16/folder_database.png")
        gamesNode.ViewPanel, gamesNode.pnlContent = view, pnlContent
        for _, g in ipairs(getGameList()) do
            if g.mounted then addBrowseContent(gamesNode, g.title, "games/16/" .. (g.icon or g.folder) .. ".png", g.folder .. "/materials", g.folder, {".vmt", ".png"}, "material") end
        end
    end)
end)

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, tree)
    local node = tree:AddNode("#spawnmenu.category.entities", "icon16/bricks.png")
    node.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node.PropPanel:SetVisible(false)
    node.DoClick = function() pnlContent:SwitchPanel(node.PropPanel) end
    local categorized = {}
    for _, ent in pairs(list.Get("SpawnableEntities") or {}) do
        local cat = ent.Category or "Other"
        categorized[cat] = categorized[cat] or {}
        table.insert(categorized[cat], ent)
    end

    for catName, ents in SortedPairs(categorized) do
        local sub = node:AddNode(catName, "icon16/bricks.png")
        local panel = vgui.Create("ContentContainer", pnlContent)
        panel:SetVisible(false)
        local header = vgui.Create("ContentHeader", node.PropPanel)
        header:SetText(catName)
        node.PropPanel:Add(header)
        for _, ent in SortedPairsByMemberValue(ents, "PrintName") do
            local t = {
                nicename = ent.PrintName or ent.ClassName,
                spawnname = ent.ClassName,
                material = "entities/" .. ent.ClassName .. ".png",
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", panel, t)
            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", node.PropPanel, t)
        end

        sub.DoClick = function() pnlContent:SwitchPanel(panel) end
    end
end)

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, tree)
    local node = tree:AddNode("#spawnmenu.category.postprocess", "icon16/picture.png")
    node.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node.PropPanel:SetVisible(false)
    node.DoClick = function() pnlContent:SwitchPanel(node.PropPanel) end
    local categorized = {}
    for name, pp in pairs(list.Get("PostProcess") or {}) do
        pp.category = pp.category or "Other"
        pp.name = name
        categorized[pp.category] = categorized[pp.category] or {}
        table.insert(categorized[pp.category], pp)
    end

    for catName, pps in SortedPairs(categorized) do
        local sub = node:AddNode(catName, "icon16/picture.png")
        local panel = vgui.Create("ContentContainer", pnlContent)
        panel:SetVisible(false)
        local header = vgui.Create("ContentHeader", node.PropPanel)
        header:SetText(catName)
        node.PropPanel:Add(header)
        for _, pp in SortedPairsByMemberValue(pps, "PrintName") do
            if pp.func then
                pp.func(panel)
                pp.func(node.PropPanel)
            else
                local t = {
                    name = pp.name,
                    icon = pp.icon
                }

                spawnmenu.CreateContentIcon("postprocess", panel, t)
                spawnmenu.CreateContentIcon("postprocess", node.PropPanel, t)
            end
        end

        sub.DoClick = function() pnlContent:SwitchPanel(panel) end
    end
end)

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, tree)
    local node = tree:AddNode("#spawnmenu.category.npcs", "icon16/monkey.png")
    node.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node.PropPanel:SetVisible(false)
    node.DoClick = function() pnlContent:SwitchPanel(node.PropPanel) end
    local cats = {}
    for className, ent in pairs(list.Get("NPC") or {}) do
        local cat = ent.Category or "Other"
        cats[cat] = cats[cat] or {}
        cats[cat][className] = ent
    end

    for catName, ents in SortedPairs(cats) do
        local sub = node:AddNode(catName, "icon16/monkey.png")
        local panel = vgui.Create("ContentContainer", pnlContent)
        panel:SetVisible(false)
        local header = vgui.Create("ContentHeader", node.PropPanel)
        header:SetText(catName)
        node.PropPanel:Add(header)
        for className, ent in SortedPairsByMemberValue(ents, "Name") do
            local t = {
                nicename = ent.Name or className,
                spawnname = className,
                material = "entities/" .. className .. ".png",
                weapon = ent.Weapons,
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon("npc", panel, t)
            spawnmenu.CreateContentIcon("npc", node.PropPanel, t)
        end

        sub.DoClick = function() pnlContent:SwitchPanel(panel) end
    end
end)

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, tree)
    local node = tree:AddNode("#spawnmenu.category.vehicles", "icon16/car.png")
    node.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node.PropPanel:SetVisible(false)
    node.DoClick = function() pnlContent:SwitchPanel(node.PropPanel) end
    local cats = {}
    for className, v in pairs(list.Get("Vehicles") or {}) do
        v.Category = v.Category or "Other"
        v.ClassName, v.PrintName, v.ScriptedEntityType = className, v.Name, "vehicle"
        cats[v.Category] = cats[v.Category] or {}
        table.insert(cats[v.Category], v)
    end

    for catName, vs in SortedPairs(cats) do
        local sub = node:AddNode(catName, "icon16/car.png")
        local panel = vgui.Create("ContentContainer", pnlContent)
        panel:SetVisible(false)
        local header = vgui.Create("ContentHeader", node.PropPanel)
        header:SetText(catName)
        node.PropPanel:Add(header)
        for _, ent in SortedPairsByMemberValue(vs, "PrintName") do
            local t = {
                nicename = ent.PrintName or ent.ClassName,
                spawnname = ent.ClassName,
                material = "entities/" .. ent.ClassName .. ".png",
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", panel, t)
            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", node.PropPanel, t)
        end

        sub.DoClick = function() pnlContent:SwitchPanel(panel) end
    end
end)

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, tree)
    local node = tree:AddNode("#spawnmenu.category.weapons", "icon16/gun.png")
    node.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node.PropPanel:SetVisible(false)
    node.DoClick = function() pnlContent:SwitchPanel(node.PropPanel) end
    local cats = {}
    for _, w in pairs(list.Get("Weapon") or {}) do
        if w.Spawnable or w.AdminSpawnable then
            local cat = w.Category or "Other"
            cats[cat] = cats[cat] or {}
            table.insert(cats[cat], w)
        end
    end

    for catName, ws in SortedPairs(cats) do
        local sub = node:AddNode(catName, "icon16/gun.png")
        local panel = vgui.Create("ContentContainer", pnlContent)
        panel:SetVisible(false)
        local header = vgui.Create("ContentHeader", node.PropPanel)
        header:SetText(catName)
        node.PropPanel:Add(header)
        for _, ent in SortedPairsByMemberValue(ws, "PrintName") do
            local t = {
                nicename = ent.PrintName or ent.ClassName,
                spawnname = ent.ClassName,
                material = "entities/" .. ent.ClassName .. ".png",
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", panel, t)
            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", node.PropPanel, t)
        end

        sub.DoClick = function() pnlContent:SwitchPanel(panel) end
    end
end)

local function addRecursive(pnl, folder)
    local files, folders = file.Find(folder .. "*", "MOD")
    for _, v in ipairs(files) do
        if v:match("%.mdl$") then
            local func = spawnmenu.GetContentType("model")
            if func then
                local m = folder .. v
                m = m:match("models/.*") or m
                m = m:gsub("models/models/", "models/")
                func(pnl, {
                    model = m
                })
            end
        end
    end

    for _, d in ipairs(folders) do
        addRecursive(pnl, folder .. d .. "/")
    end
end

local function countRecursive(folder)
    local files, folders = file.Find(folder .. "*", "MOD")
    local cnt = 0
    for _, v in ipairs(files) do
        if v:match("%.mdl$") then cnt = cnt + 1 end
    end

    for _, d in ipairs(folders) do
        cnt = cnt + countRecursive(folder .. d .. "/")
    end
    return cnt
end

hook.Add("PopulateContent", "liaExtendedSpawnMenuPopulateContent", function(pnlContent, _, node)
    if not IsValid(node) or not IsValid(pnlContent) then return end
    local view = vgui.Create("ContentContainer", pnlContent)
    view:SetVisible(false)
    local legacy = node:AddNode(L("addonsLegacyTitle"), "icon16/folder_database.png")
    for _, a in ipairs(file.Find("addons/*", "MOD")) do
        if file.IsDir("addons/" .. a .. "/models/", "MOD") then
            local c = countRecursive("addons/" .. a .. "/models/")
            if c > 0 then
                local child = legacy:AddNode(a .. " (" .. c .. ")", "icon16/bricks.png")
                child.DoClick = function()
                    view:Clear(true)
                    addRecursive(view, "addons/" .. a .. "/models/")
                    pnlContent:SwitchPanel(view)
                end
            end
        end
    end

    local f, d = file.Find("download/models", "MOD")
    if f and #f > 0 or d and #d > 0 then
        local dn = node:AddFolder(L("downloads"), "download/models", "MOD", false, false, "*.*")
        dn:SetIcon("icon16/folder_database.png")
        dn.OnNodeSelected = function(self)
            view:Clear(true)
            local p = self:GetFolder():match("/models/.*") or self:GetFolder()
            for _, v in ipairs(file.Find(self:GetFolder() .. "/*.mdl", self:GetPathID())) do
                local func = spawnmenu.GetContentType("model")
                if func then
                    func(view, {
                        model = p .. "/" .. v
                    })
                end
            end

            pnlContent:SwitchPanel(view)
        end
    end
end)

concommand.Add("extsm_addoninfo", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() - 100, ScrH() - 100)
    frame:Center()
    frame:MakePopup()
    local scroll = frame:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:Add("rb655_addonInfo")
end)

hook.Add("AddToolMenuCategories", "liaExtendedSpawnMenuAddToolMenuCategories", function() spawnmenu.AddToolCategory("Utilities", "Robotboy655", "#Robotboy655") end)
local PANEL = {}
function PANEL:Init()
    self.computed = false
end

function PANEL:Compute()
    self.workshopSize = 0
    for _, f in ipairs(file.Find("addons/*.gma", "MOD")) do
        self.workshopSize = self.workshopSize + (file.Size("addons/" .. f, "MOD") or 0)
    end

    self.workshopWaste = 0
    self.workshopWasteFiles = {}
    for _, f in ipairs(file.Find("addons/*.gma", "MOD")) do
        local id = tonumber(f:match("_(%d+)%.gma$"))
        if id and not engine.GetAddons()[id] then
            local sz = file.Size("addons/" .. f, "MOD") or 0
            self.workshopWaste = self.workshopWaste + sz
            table.insert(self.workshopWasteFiles, {"addons/" .. f, sz})
        end
    end

    local _, addonFolders = file.Find("addons/*", "MOD")
    self.legacyAddons = {}
    for _, d in ipairs(addonFolders) do
        local path = "addons/" .. d .. "/"
        local status = "Installed"
        if file.IsDir(path .. "models/", "MOD") then status = "Installed (Has Models)" end
        local _, sub = file.Find(path .. "*", "MOD")
        if #sub < 1 then status = "Installed (Empty)" end
        if not (file.IsDir(path .. "models/", "MOD") or file.IsDir(path .. "materials/", "MOD") or file.IsDir(path .. "lua/", "MOD") or file.IsDir(path .. "sound/", "MOD")) then status = "Installed Incorrectly!" end
        self.legacyAddons[path] = status
    end

    local luaFiles = file.Find("cache/lua/*", "MOD")
    self.luaCacheFiles = #luaFiles
    self.luaCacheSize = self.luaCacheFiles * 1400
    local wsFiles = file.Find("cache/workshop/*", "MOD")
    self.wsCacheFiles = #wsFiles
    self.wsCacheSize = 0
    for _, f in ipairs(wsFiles) do
        self.wsCacheSize = self.wsCacheSize + (file.Size("cache/workshop/" .. f, "MOD") or 0)
    end

    self.computed = true
end

local function DrawText(text, font, x, y, clr)
    draw.SimpleText(text, font, x, y, clr)
    surface.SetFont(font)
    return surface.GetTextSize(text)
end

local function GetSize(bytes)
    local kb = bytes / 1000
    if kb < 1000 then return math.floor(kb * 10) / 10 .. " KB" end
    local mb = kb / 1000
    if mb < 1000 then return math.floor(mb * 10) / 10 .. " MB" end
    return math.floor(mb / 1000 * 10) / 10 .. " GB"
end

function PANEL:Paint()
    if not self.computed then self:Compute() end
    local wdt = self:GetParent():GetWide()
    local y = 0
    local _, th = DrawText(L("cacheSizes"), "AddonInfo_Header", 0, y, color_white)
    y = y + th
    local tw1, h1 = DrawText("~" .. GetSize(self.luaCacheSize) .. " (" .. self.luaCacheFiles .. " files)", "AddonInfo_Small", 0, y, Color(220, 220, 220))
    y = y + h1
    local tw2, h2 = DrawText("~" .. GetSize(self.wsCacheSize) .. " (" .. self.wsCacheFiles .. " files)", "AddonInfo_Small", 0, y, Color(220, 220, 220))
    y = y + h2
    local maxW = math.max(tw1, tw2) + 25
    local _, th2 = DrawText(L("serverLuaCache"), "AddonInfo_Small", maxW, y, color_white)
    y = y + th2
    local _, th3 = DrawText(L("workshopDownloadCache"), "AddonInfo_Small", maxW, y)
    y = y + th3 + ScreenScaleH(8)
    local _, th4 = DrawText(L("workshopSubscriptions"), "AddonInfo_Header", 0, y, color_white)
    y = y + th4
    local tw3, th5 = DrawText(L("usedSize"), "AddonInfo_Text", 0, y, color_white)
    local lblW = tw3
    y = y + th5
    local tw4, th6 = DrawText(L("wastedSpace"), "AddonInfo_Text", 0, y, color_white)
    lblW = math.max(lblW, tw4)
    y = y + th6
    local tw5, th7 = DrawText(L("totalSize"), "AddonInfo_Text", 0, y, color_white)
    lblW = math.max(lblW, tw5)
    y = y + th7 * 2
    local _, th8 = DrawText(GetSize(self.workshopSize - self.workshopWaste), "AddonInfo_Text", lblW, y, Color(220, 220, 220))
    y = y + th8
    local _, th9 = DrawText(GetSize(self.workshopWaste), "AddonInfo_Text", lblW, y, Color(220, 220, 220))
    y = y + th9
    local _, th10 = DrawText(GetSize(self.workshopSize), "AddonInfo_Text", lblW, y, Color(220, 220, 220))
    y = y + th10 * 2
    local _, th11 = DrawText(L("filesUnusedDelete"), "AddonInfo_Text", 0, y, color_white)
    y = y + th11
    local maxW2 = 0
    for _, e in ipairs(self.workshopWasteFiles) do
        local tw6, th12 = DrawText(GetSize(e[2]) .. "    ", "AddonInfo_Small", 0, y, Color(220, 220, 220))
        maxW2 = math.max(maxW2, tw6)
        y = y + th12
    end

    y = y - #self.workshopWasteFiles * th12
    for _, e in ipairs(self.workshopWasteFiles) do
        local _, th13 = DrawText(e[1], "AddonInfo_Small", maxW2, y, color_white)
        y = y + th13
    end

    y = y + ScreenScaleH(8)
    local _, th14 = DrawText(L("legacyAddons"), "AddonInfo_Header", 0, y, color_white)
    y = y + th14 + ScreenScaleH(8)
    local _, th15 = DrawText(L("legacyAddonsWithModels"), "AddonInfo_Text", 0, y, color_white)
    y = y + th15
    if next(self.legacyAddons) then
        local nameW, startY = 0, y
        for p in pairs(self.legacyAddons) do
            local tw7, th16 = DrawText(p, "AddonInfo_Small", 0, y, color_white)
            nameW = math.max(nameW, tw7)
            y = y + th16
        end

        nameW = nameW + 25
        y = startY
        for _, st in pairs(self.legacyAddons) do
            local _, th17 = DrawText(st, "AddonInfo_Small", nameW, y, Color(220, 220, 220))
            y = y + th17
        end
    else
        local _, th18 = DrawText(L("none"), "AddonInfo_Small", 0, y, color_white)
        y = y + th18
    end

    if not system.IsWindows() then
        local _, th19 = DrawText(L("osxLinuxBeware"), "AddonInfo_Text", 0, y, color_white)
        y = y + th19
        local _, th20 = DrawText(L("makeSureLowercase"), "AddonInfo_Text", 0, y, color_white)
        y = y + th20
        local _, th21 = DrawText(L("lowercaseOnlyWarning"), "AddonInfo_Text", 0, y, color_white)
        y = y + th21
        local _, th22 = DrawText(L("includingAllSubfolders"), "AddonInfo_Text", 0, y, color_white)
        y = y + th22
    end

    self:SetSize(wdt, y)
end

vgui.Register("rb655_addonInfo", PANEL, "Panel")
hook.Add("PopulatePropMenu", "liaExtendedSpawnMenuPopulatePropMenu", function(pnl, _, node)
    if not IsValid(node) or not IsValid(pnl) then return end
    local view = vgui.Create("ContentContainer", pnl)
    view:SetVisible(false)
    local sid = 0
    for _, fn in ipairs(file.Find("settings/spawnlist/*.txt", "MOD")) do
        local content = util.KeyValuesToTable(file.Read("settings/spawnlist/" .. fn, "MOD") or "")
        if content and content.entries and not content.contents then
            local items = {}
            for _, e in ipairs(content.entries) do
                local mdl = istable(e) and e.model or e
                table.insert(items, {
                    type = "model",
                    model = mdl
                })
            end

            local info = content.information or {
                name = fn
            }

            spawnmenu.AddPropCategory("settings/spawnlist/" .. fn, info.name, items, "icon16/page.png", sid + 1, sid)
            sid = sid + 1
        end
    end
end)
