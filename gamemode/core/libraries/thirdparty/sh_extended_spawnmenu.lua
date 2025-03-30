if SERVER then
    
    concommand.Add("rb655_playsound_all", function(client, cmd, args)
        if not client:IsSuperAdmin() or not args[1] or string.Trim(args[1]) == "" then return end
        net.Start("rb655_playsound")
        net.WriteString(args[1] or "")
        net.Broadcast()
    end)
    return
end

local cl_addTabs = CreateClientConVar("rb655_create_sm_tabs", "0", true, true)
local function getGameList()
    local games = engine.GetGames()
    table.insert(games, {
        title = "All",
        folder = "GAME",
        icon = "all",
        mounted = true
    })

    table.insert(games, {
        title = "Garry's Mod",
        folder = "garrysmod",
        mounted = true
    })
    return games
end

local theSound = nil
function rb655_playsound(snd)
    if theSound then theSound:Stop() end
    theSound = CreateSound(LocalPlayer(), snd)
    theSound:Play()
end

net.Receive("rb655_playsound", function(len) rb655_playsound(net.ReadString()) end)
spawnmenu.AddContentType("sound", function(container, obj)
    if not obj.nicename then return end
    if not obj.spawnname then return end
    local icon = vgui.Create("ContentIcon", container)
    icon:SetContentType("sound")
    icon:SetSpawnName(obj.spawnname)
    icon:SetName(obj.nicename)
    icon:SetMaterial("icon16/sound.png")
    icon.DoClick = function() rb655_playsound(obj.spawnname) end
    icon.OpenMenu = function(icn)
        local menu = DermaMenu()
        menu:AddOption("#spawnmenu.menu.copy", function() SetClipboardText(obj.spawnname) end):SetIcon("icon16/page_copy.png")
        menu:AddOption("Play on all clients", function() RunConsoleCommand("rb655_playsound_all", obj.spawnname) end):SetIcon("icon16/sound.png")
        menu:AddOption("Stop all sounds", function() RunConsoleCommand("stopsound") end):SetIcon("icon16/sound_mute.png")
        menu:AddSpacer()
        menu:AddOption("#spawnmenu.menu.delete", function()
            icn:Remove()
            hook.Run("SpawnlistContentChanged", icn)
        end):SetIcon("icon16/bin_closed.png")

        menu:Open()
    end

    if IsValid(container) then container:Add(icon) end
    return icon
end)

local function OnSndNodeSelected(self, node, name, path, pathid, icon, ViewPanel, pnlContent)
    ViewPanel:Clear(true)
    local Path = node:GetFolder()
    local files = file.Find(Path .. "/*.wav", node:GetPathID())
    files = table.Add(files, file.Find(Path .. "/*.mp3", node:GetPathID()))
    files = table.Add(files, file.Find(Path .. "/*.ogg", node:GetPathID()))
    local offset = 0
    local limit = 512
    if node.offset then offset = node.offset or 0 end
    for k, v in ipairs(files) do
        if k > limit + offset then
            if not node.Done then
                offset = offset + limit
                local mats = (self.Parent or node):AddNode((self.Text or node:GetText()) .. " (" .. offset .. " - " .. offset + limit .. ")")
                mats:SetFolder(node:GetFolder())
                mats.Text = self.Text or node:GetText()
                mats.Parent = self.Parent or node
                mats:SetPathID(node:GetPathID())
                mats:SetIcon(node:GetIcon())
                mats.offset = offset
                mats.OnNodeSelected = function(mats_self, mats_node) OnSndNodeSelected(mats_self, mats_node, mats_self.Text, mats_node:GetFolder(), mats_node:GetPathID(), mats_node:GetIcon(), ViewPanel, pnlContent) end
            end

            node.Done = true
            break
        end

        if k <= offset then continue end
        local p = Path .. "/"
        if string.StartWith(path, "addons/") or string.StartWith(path, "download/") then p = string.sub(p, string.find(p, "/sound/") + 1) end
        p = string.sub(p .. v, 7)
        spawnmenu.CreateContentIcon("sound", ViewPanel, {
            spawnname = p,
            nicename = string.Trim(v)
        })
    end

    pnlContent:SwitchPanel(ViewPanel)
end

local function AddBrowseContentSnd(node, name, icon, path, pathid)
    local ViewPanel = node.ViewPanel
    local pnlContent = node.pnlContent
    if not string.EndsWith(path, "/") and string.len(path) > 1 then path = path .. "/" end
    local fi, fo = file.Find(path .. "sound", pathid)
    if not fo and not fi then return end
    local sounds = node:AddFolder(name, path .. "sound", pathid, false, false, "*.*")
    sounds:SetIcon(icon)
    sounds.OnNodeSelected = function(self, node_sel) OnSndNodeSelected(self, node_sel, name, path, pathid, icon, ViewPanel, pnlContent) end
end

local function RefreshAddonSounds(browseAddonSounds)
    for _, addon in SortedPairsByMemberValue(engine.GetAddons(), "title") do
        if not addon.downloaded then continue end
        if not addon.mounted then continue end
        if not table.HasValue(select(2, file.Find("*", addon.title)), "sound") then continue end
        AddBrowseContentSnd(browseAddonSounds, addon.title, "icon16/bricks.png", "", addon.title)
    end
end

local function RefreshGameSounds(browseGameSounds)
    local games = getGameList()
    for _, game in SortedPairsByMemberValue(games, "title") do
        if not game.mounted then continue end
        AddBrowseContentSnd(browseGameSounds, game.title, "games/16/" .. (game.icon or game.folder) .. ".png", "", game.folder)
    end
end

local browseGameSounds
local browseAddonSounds
hook.Add("PopulateContent", "SpawnmenuLoadSomeSounds", function(pnlContent, tree, browseNode)
    timer.Simple(0.5, function()
        if not IsValid(tree) or not IsValid(pnlContent) then return end
        local ViewPanel = vgui.Create("ContentContainer", pnlContent)
        ViewPanel:SetVisible(false)
        local browseSounds = tree:AddNode("Browse Sounds", "icon16/sound.png")
        browseSounds.ViewPanel = ViewPanel
        browseSounds.pnlContent = pnlContent
        browseAddonSounds = browseSounds:AddNode("#spawnmenu.category.addons", "icon16/folder_database.png")
        browseAddonSounds.ViewPanel = ViewPanel
        browseAddonSounds.pnlContent = pnlContent
        RefreshAddonSounds(browseAddonSounds)
        local addon_sounds = {}
        local _, snd_folders = file.Find("addons/*", "MOD")
        for _, addon in SortedPairs(snd_folders) do
            if not file.IsDir("addons/" .. addon .. "/sound/", "MOD") then continue end
            table.insert(addon_sounds, addon)
        end

        local browseLegacySounds = browseSounds:AddNode("Addons - Legacy", "icon16/folder_database.png")
        browseLegacySounds.ViewPanel = ViewPanel
        browseLegacySounds.pnlContent = pnlContent
        for _, addon in SortedPairsByValue(addon_sounds) do
            AddBrowseContentSnd(browseLegacySounds, addon, "icon16/bricks.png", "addons/" .. addon .. "/", "MOD")
        end

        AddBrowseContentSnd(browseSounds, "Downloads", "icon16/folder_database.png", "download/", "MOD")
        browseGameSounds = browseSounds:AddNode("#spawnmenu.category.games", "icon16/folder_database.png")
        browseGameSounds.ViewPanel = ViewPanel
        browseGameSounds.pnlContent = pnlContent
        RefreshGameSounds(browseGameSounds)
    end)
end)

hook.Add("GameContentChanged", "ES_RefreshSpawnmenuSounds", function()
    if IsValid(browseAddonSounds) then
        browseAddonSounds:Clear()
        browseAddonSounds.ViewPanel:Clear(true)
        RefreshAddonSounds(browseAddonSounds)
    end

    if IsValid(browseGameSounds) then
        browseGameSounds:Clear()
        browseGameSounds.ViewPanel:Clear(true)
        RefreshGameSounds(browseGameSounds)
    end
end)

local function IsMaterialUsableOnEntities(matPath)
    if string.GetExtensionFromFilename(matPath) then return false end
    local mat = Material(matPath)
    if not string.find(mat:GetShader(), "LightmappedGeneric") and not string.find(mat:GetShader(), "WorldVertexTransition") and not string.find(mat:GetShader(), "Spritecard") and not string.find(mat:GetShader(), "Water") and not string.find(mat:GetShader(), "Cable") and not string.find(mat:GetShader(), "Refract") then return true end
    return false
end

local DisplayedWarning = false
local function DisplayOneTimeWarning()
    if DisplayedWarning then return end
    DisplayedWarning = true
    Derma_Message("Please note that not all materials are usable on entities, such as map textures, etc.\nYou can still try though!", "Warning", "OK")
end

spawnmenu.AddContentType("material", function(container, obj)
    if not obj.nicename then return end
    if not obj.spawnname then return end
    local icon = vgui.Create("ContentIcon", container)
    icon:SetContentType("material")
    icon:SetSpawnName(obj.spawnname)
    icon:SetName(obj.nicename)
    if string.GetExtensionFromFilename(obj.spawnname) == "png" then
        icon:SetMaterial(obj.spawnname)
    else
        icon.Image:SetImage(obj.spawnname)
    end

    icon.DoClick = function()
        if not IsMaterialUsableOnEntities(obj.spawnname) then DisplayOneTimeWarning() end
        RunConsoleCommand("material_override", obj.spawnname)
        spawnmenu.ActivateTool("material")
        surface.PlaySound("garrysmod/ui_click.wav")
    end

    icon.OpenMenu = function(icn)
        local menu = DermaMenu()
        menu:AddOption("#spawnmenu.menu.copy", function() SetClipboardText(obj.spawnname) end):SetIcon("icon16/page_copy.png")
        local str = "Use with Material Tool"
        if not IsMaterialUsableOnEntities(obj.spawnname) then str = "Try to use with Material Tool (Probably won't work)" end
        menu:AddOption(str, function()
            RunConsoleCommand("material_override", obj.spawnname)
            spawnmenu.ActivateTool("material")
        end):SetIcon("icon16/pencil.png")

        menu:AddSpacer()
        menu:AddOption("#spawnmenu.menu.delete", function()
            icn:Remove()
            hook.Run("SpawnlistContentChanged", icn)
        end):SetIcon("icon16/bin_closed.png")

        menu:Open()
    end

    if IsValid(container) then container:Add(icon) end
    return icon
end)

local function OnMatNodeSelected(self, node, name, path, pathid, icon, ViewPanel, pnlContent)
    ViewPanel:Clear(true)
    local Path = node:GetFolder()
    local mat_files = file.Find(Path .. "/*.vmt", node:GetPathID())
    mat_files = table.Add(mat_files, file.Find(Path .. "/*.png", node:GetPathID()))
    local offset = 0
    local limit = 512
    if node.offset then offset = node.offset or 0 end
    for k, v in ipairs(mat_files) do
        if k > limit + offset then
            if not node.Done then
                offset = offset + limit
                local mats = (self.Parent or node):AddNode((self.Text or node:GetText()) .. " (" .. offset .. " - " .. offset + limit .. ")")
                mats:SetFolder(node:GetFolder())
                mats.Text = self.Text or node:GetText()
                mats.Parent = self.Parent or node
                mats:SetPathID(node:GetPathID())
                mats:SetIcon(node:GetIcon())
                mats.offset = offset
                mats.OnNodeSelected = function(self_mats, node_sel) OnMatNodeSelected(self_mats, node_sel, self_mats.Text, node_sel:GetFolder(), node_sel:GetPathID(), node_sel:GetIcon(), ViewPanel, pnlContent) end
            end

            node.Done = true
            break
        end

        if k <= offset then continue end
        local p = Path .. "/"
        if string.StartWith(path, "addons/") or string.StartWith(path, "download/") then p = string.sub(p, string.find(p, "/materials/") + 1) end
        p = string.sub(p .. v, 11)
        if string.GetExtensionFromFilename(p) == "vmt" then
            p = string.StripExtension(p)
            v = string.StripExtension(v)
        end

        if Material(p):GetShader() == "Spritecard" then continue end
        spawnmenu.CreateContentIcon("material", ViewPanel, {
            spawnname = p,
            nicename = v
        })
    end

    pnlContent:SwitchPanel(ViewPanel)
end

local function AddBrowseContentMaterial(node, name, icon, path, pathid)
    local ViewPanel = node.ViewPanel
    local pnlContent = node.pnlContent
    if not string.EndsWith(path, "/") and string.len(path) > 1 then path = path .. "/" end
    local fi, fo = file.Find(path .. "materials", pathid)
    if not fi and not fo then return end
    local materials = node:AddFolder(name, path .. "materials", pathid, false, false, "*.*")
    materials:SetIcon(icon)
    materials.OnNodeSelected = function(self, node_sel) OnMatNodeSelected(self, node_sel, name, path, pathid, icon, ViewPanel, pnlContent) end
end

local function RefreshAddonMaterials(node)
    for _, addon in SortedPairsByMemberValue(engine.GetAddons(), "title") do
        if not addon.downloaded then continue end
        if not addon.mounted then continue end
        if not table.HasValue(select(2, file.Find("*", addon.title)), "materials") then continue end
        AddBrowseContentMaterial(node, addon.title, "icon16/bricks.png", "", addon.title)
    end
end

local function RefreshGameMaterials(node)
    local games = getGameList()
    for _, game in SortedPairsByMemberValue(games, "title") do
        if not game.mounted then continue end
        AddBrowseContentMaterial(node, game.title, "games/16/" .. (game.icon or game.folder) .. ".png", "", game.folder)
    end
end

local browseAddonMaterials
local browseGameMaterials
hook.Add("PopulateContent", "SpawnmenuLoadSomeMaterials", function(pnlContent, tree, browseNode)
    timer.Simple(0.5, function()
        if not IsValid(tree) or not IsValid(pnlContent) then return end
        local ViewPanel = vgui.Create("ContentContainer", pnlContent)
        ViewPanel:SetVisible(false)
        local browseMaterials = tree:AddNode("Browse Materials", "icon16/picture_empty.png")
        browseMaterials.ViewPanel = ViewPanel
        browseMaterials.pnlContent = pnlContent
        browseAddonMaterials = browseMaterials:AddNode("Addons", "icon16/folder_database.png")
        browseAddonMaterials.ViewPanel = ViewPanel
        browseAddonMaterials.pnlContent = pnlContent
        RefreshAddonMaterials(browseAddonMaterials)
        local addon_mats = {}
        local _, mat_folders = file.Find("addons/*", "MOD")
        for _, addon in SortedPairs(mat_folders) do
            if not file.IsDir("addons/" .. addon .. "/materials/", "MOD") then continue end
            table.insert(addon_mats, addon)
        end

        local browseLegacyMaterials = browseMaterials:AddNode("Addons - Legacy", "icon16/folder_database.png")
        browseLegacyMaterials.ViewPanel = ViewPanel
        browseLegacyMaterials.pnlContent = pnlContent
        for _, addon in SortedPairsByValue(addon_mats) do
            AddBrowseContentMaterial(browseLegacyMaterials, addon, "icon16/bricks.png", "addons/" .. addon .. "/", "MOD")
        end

        AddBrowseContentMaterial(browseMaterials, "Downloads", "icon16/folder_database.png", "download/", "MOD")
        browseGameMaterials = browseMaterials:AddNode("#spawnmenu.category.games", "icon16/folder_database.png")
        browseGameMaterials.ViewPanel = ViewPanel
        browseGameMaterials.pnlContent = pnlContent
        RefreshGameMaterials(browseGameMaterials)
    end)
end)

hook.Add("GameContentChanged", "ES_RefreshSpawnmenuMaterials", function()
    if IsValid(browseAddonMaterials) then
        browseAddonMaterials:Clear()
        browseAddonMaterials.ViewPanel:Clear(true)
        RefreshAddonMaterials(browseAddonMaterials)
    end

    if IsValid(browseGameMaterials) then
        browseGameMaterials:Clear()
        browseGameMaterials.ViewPanel:Clear(true)
        RefreshGameMaterials(browseGameMaterials)
    end
end)

hook.Add("PopulateContent", "rb655_extended_spawnmenu_entities", function(pnlContent, tree, node)
    if not cl_addTabs:GetBool() then return end
    local node_w = tree:AddNode("#spawnmenu.category.entities", "icon16/bricks.png")
    node_w.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node_w.PropPanel:SetVisible(false)
    function node_w:DoClick()
        pnlContent:SwitchPanel(self.PropPanel)
    end

    local Categorised = {}
    local SpawnableEntities = list.Get("SpawnableEntities")
    if SpawnableEntities then
        for k, v in pairs(SpawnableEntities) do
            v.Category = v.Category or "Other"
            Categorised[v.Category] = Categorised[v.Category] or {}
            table.insert(Categorised[v.Category], v)
        end
    end

    for CategoryName, v in SortedPairs(Categorised) do
        local node_new = node_w:AddNode(CategoryName, "icon16/bricks.png")
        local CatPropPanel = vgui.Create("ContentContainer", pnlContent)
        CatPropPanel:SetVisible(false)
        local Header = vgui.Create("ContentHeader", node_w.PropPanel)
        Header:SetText(CategoryName)
        node_w.PropPanel:Add(Header)
        for k, ent in SortedPairsByMemberValue(v, "PrintName") do
            local t = {
                nicename = ent.PrintName or ent.ClassName,
                spawnname = ent.ClassName,
                material = "entities/" .. ent.ClassName .. ".png",
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", CatPropPanel, t)
            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", node_w.PropPanel, t)
        end

        function node_new:DoClick()
            pnlContent:SwitchPanel(CatPropPanel)
        end
    end
end)

hook.Add("PopulateContent", "rb655_extended_spawnmenu_post_processing", function(pnlContent, tree, node)
    if not cl_addTabs:GetBool() then return end
    local node_w = tree:AddNode("#spawnmenu.category.postprocess", "icon16/picture.png")
    node_w.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node_w.PropPanel:SetVisible(false)
    function node_w:DoClick()
        pnlContent:SwitchPanel(self.PropPanel)
    end

    local Categorised = {}
    local PostProcess = list.Get("PostProcess")
    if PostProcess then
        for k, v in pairs(PostProcess) do
            v.category = v.category or "Other"
            v.name = k
            Categorised[v.category] = Categorised[v.category] or {}
            table.insert(Categorised[v.category], v)
        end
    end

    for CategoryName, v in SortedPairs(Categorised) do
        local node_new = node_w:AddNode(CategoryName, "icon16/picture.png")
        local CatPropPanel = vgui.Create("ContentContainer", pnlContent)
        CatPropPanel:SetVisible(false)
        local Header = vgui.Create("ContentHeader", node_w.PropPanel)
        Header:SetText(CategoryName)
        node_w.PropPanel:Add(Header)
        for k, pp in SortedPairsByMemberValue(v, "PrintName") do
            if pp.func then
                pp.func(CatPropPanel)
                pp.func(node_w.PropPanel)
                continue
            end

            local t = {
                name = pp.name,
                icon = pp.icon
            }

            spawnmenu.CreateContentIcon("postprocess", CatPropPanel, t)
            spawnmenu.CreateContentIcon("postprocess", node_w.PropPanel, t)
        end

        function node_new:DoClick()
            pnlContent:SwitchPanel(CatPropPanel)
        end
    end
end)

hook.Add("PopulateContent", "rb655_extended_spawnmenu_npcs", function(pnlContent, tree, node)
    if not cl_addTabs:GetBool() then return end
    local node_w = tree:AddNode("#spawnmenu.category.npcs", "icon16/monkey.png")
    node_w.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node_w.PropPanel:SetVisible(false)
    function node_w:DoClick()
        pnlContent:SwitchPanel(self.PropPanel)
    end

    local NPCList = list.Get("NPC")
    local Categories = {}
    for k, v in pairs(NPCList) do
        local Category = v.Category or "Other"
        local Tab = Categories[Category] or {}
        Tab[k] = v
        Categories[Category] = Tab
    end

    for CategoryName, v in SortedPairs(Categories) do
        local node_new = node_w:AddNode(CategoryName, "icon16/monkey.png")
        local CatPropPanel = vgui.Create("ContentContainer", pnlContent)
        CatPropPanel:SetVisible(false)
        local Header = vgui.Create("ContentHeader", node_w.PropPanel)
        Header:SetText(CategoryName)
        node_w.PropPanel:Add(Header)
        for name, ent in SortedPairsByMemberValue(v, "Name") do
            local t = {
                nicename = ent.Name or name,
                spawnname = name,
                material = "entities/" .. name .. ".png",
                weapon = ent.Weapons,
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon("npc", CatPropPanel, t)
            spawnmenu.CreateContentIcon("npc", node_w.PropPanel, t)
        end

        function node_new:DoClick()
            pnlContent:SwitchPanel(CatPropPanel)
        end
    end
end)

hook.Add("PopulateContent", "rb655_extended_spawnmenu_vehicles", function(pnlContent, tree, node)
    if not cl_addTabs:GetBool() then return end
    local node_w = tree:AddNode("#spawnmenu.category.vehicles", "icon16/car.png")
    node_w.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node_w.PropPanel:SetVisible(false)
    function node_w:DoClick()
        pnlContent:SwitchPanel(self.PropPanel)
    end

    local Categorised = {}
    local Vehicles = list.Get("Vehicles")
    if Vehicles then
        for k, v in pairs(Vehicles) do
            v.Category = v.Category or "Other"
            Categorised[v.Category] = Categorised[v.Category] or {}
            v.ClassName = k
            v.PrintName = v.Name
            v.ScriptedEntityType = "vehicle"
            table.insert(Categorised[v.Category], v)
        end
    end

    for CategoryName, v in SortedPairs(Categorised) do
        local node_new = node_w:AddNode(CategoryName, "icon16/car.png")
        local CatPropPanel = vgui.Create("ContentContainer", pnlContent)
        CatPropPanel:SetVisible(false)
        local Header = vgui.Create("ContentHeader", node_w.PropPanel)
        Header:SetText(CategoryName)
        node_w.PropPanel:Add(Header)
        for k, ent in SortedPairsByMemberValue(v, "PrintName") do
            local t = {
                nicename = ent.PrintName or ent.ClassName,
                spawnname = ent.ClassName,
                material = "entities/" .. ent.ClassName .. ".png",
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", node_w.PropPanel, t)
            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", CatPropPanel, t)
        end

        function node_new:DoClick()
            pnlContent:SwitchPanel(CatPropPanel)
        end
    end
end)

hook.Add("PopulateContent", "rb655_extended_spawnmenu_weapons", function(pnlContent, tree, node)
    if not cl_addTabs:GetBool() then return end
    local node_w = tree:AddNode("#spawnmenu.category.weapons", "icon16/gun.png")
    node_w.PropPanel = vgui.Create("ContentContainer", pnlContent)
    node_w.PropPanel:SetVisible(false)
    function node_w:DoClick()
        pnlContent:SwitchPanel(self.PropPanel)
    end

    local Weapons = list.Get("Weapon")
    local Categorised = {}
    for k, weapon in pairs(Weapons) do
        if not weapon.Spawnable and not weapon.AdminSpawnable then continue end
        Categorised[weapon.Category] = Categorised[weapon.Category] or {}
        table.insert(Categorised[weapon.Category], weapon)
    end

    for CategoryName, v in SortedPairs(Categorised) do
        local node_new = node_w:AddNode(CategoryName, "icon16/gun.png")
        local CatPropPanel = vgui.Create("ContentContainer", pnlContent)
        CatPropPanel:SetVisible(false)
        local Header = vgui.Create("ContentHeader", node_w.PropPanel)
        Header:SetText(CategoryName)
        node_w.PropPanel:Add(Header)
        for k, ent in SortedPairsByMemberValue(v, "PrintName") do
            local t = {
                nicename = ent.PrintName or ent.ClassName,
                spawnname = ent.ClassName,
                material = "entities/" .. ent.ClassName .. ".png",
                admin = ent.AdminOnly
            }

            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", CatPropPanel, t)
            spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", node_w.PropPanel, t)
        end

        function node_new:DoClick()
            pnlContent:SwitchPanel(CatPropPanel)
        end
    end
end)
