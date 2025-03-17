language.Add("spawnmenu.category.addonslegacy", "Addons - Legacy")
language.Add("spawnmenu.category.downloads", "Downloads")
local function AddRecursive(pnl, folder)
    local files, folders = file.Find(folder .. "*", "MOD")
    for k, v in ipairs(files or {}) do
        if not string.EndsWith(v, ".mdl") then continue end
        local cp = spawnmenu.GetContentType("model")
        if cp then
            local mdl = folder .. v
            mdl = string.sub(mdl, string.find(mdl, "models/"), string.len(mdl))
            mdl = string.gsub(mdl, "models/models/", "models/")
            cp(pnl, {
                model = mdl
            })
        end
    end

    for k, v in ipairs(folders or {}) do
        AddRecursive(pnl, folder .. v .. "/")
    end
end

local function CountRecursive(folder)
    local files, folders = file.Find(folder .. "*", "MOD")
    local val = 0
    for k, v in ipairs(files or {}) do
        if string.EndsWith(v, ".mdl") then val = val + 1 end
    end

    for k, v in ipairs(folders or {}) do
        val = val + CountRecursive(folder .. v .. "/")
    end
    return val
end

hook.Add("PopulateContent", "LegacyAddonProps", function(pnlContent, tree, node)
    if not IsValid(node) or not IsValid(pnlContent) then return end
    local ViewPanel = vgui.Create("ContentContainer", pnlContent)
    ViewPanel:SetVisible(false)
    local addons = {}
    local _files, folders = file.Find("addons/*", "MOD")
    for _, f in ipairs(folders) do
        if not file.IsDir("addons/" .. f .. "/models/", "MOD") then continue end
        local count = CountRecursive("addons/" .. f .. "/models/")
        if count == 0 then continue end
        table.insert(addons, {
            name = f,
            count = count,
            path = "addons/" .. f .. "/models/"
        })
    end

    local LegacyAddons = node:AddNode("#spawnmenu.category.addonslegacy", "icon16/folder_database.png")
    for _, f in SortedPairsByMemberValue(addons, "name") do
        local models = LegacyAddons:AddNode(f.name .. " (" .. f.count .. ")", "icon16/bricks.png")
        models.DoClick = function()
            ViewPanel:Clear(true)
            AddRecursive(ViewPanel, f.path)
            pnlContent:SwitchPanel(ViewPanel)
        end
    end

    local fi, fo = file.Find("download/models", "MOD")
    if not fi and not fo then return end
    local Downloads = node:AddFolder("#spawnmenu.category.downloads", "download/models", "MOD", false, false, "*.*")
    Downloads:SetIcon("icon16/folder_database.png")
    Downloads.OnNodeSelected = function(self, selectedNode)
        ViewPanel:Clear(true)
        local path = selectedNode:GetFolder()
        if not string.EndsWith(path, "/") and string.len(path) > 1 then path = path .. "/" end
        local path_mdl = string.sub(path, string.find(path, "/models/") + 1)
        for k, v in ipairs(file.Find(path .. "/*.mdl", selectedNode:GetPathID())) do
            local cp = spawnmenu.GetContentType("model")
            if cp then
                cp(ViewPanel, {
                    model = path_mdl .. "/" .. v
                })
            end
        end

        pnlContent:SwitchPanel(ViewPanel)
    end
end)

concommand.Add("extsm_addoninfo", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() - 100, ScrH() - 100)
    frame:Center()
    frame:MakePopup()
    local sp = frame:Add("DScrollPanel")
    sp:Dock(FILL)
    sp:Add("rb655_addonInfo")
end)

hook.Add("AddToolMenuCategories", "LegacyAddonPropsInfoCategory", function() spawnmenu.AddToolCategory("Utilities", "Robotboy655", "#Robotboy655") end)
hook.Add("PopulateToolMenu", "LegacyAddonPropsInfoThing", function()
    spawnmenu.AddToolMenuOption("Utilities", "Robotboy655", "LegacyInfoPanel", "Addon Information", "", "", function(panel)
        panel:ClearControls()
        panel:Button("Open addon data window", "extsm_addoninfo")
    end)
end)

function ScreenScaleH(size)
    return size * (ScrH() / 480.0)
end

surface.CreateFont("AddonInfo_Header", {
    font = "Helvetica",
    size = ScreenScaleH(24),
    weight = 1000
})

surface.CreateFont("AddonInfo_Text", {
    font = "Helvetica",
    size = ScreenScaleH(9),
    weight = 1000
})

surface.CreateFont("AddonInfo_Small", {
    font = "Helvetica",
    size = ScreenScaleH(8)
})

local function GetWorkshopLeftovers()
    local subscriptions = {}
    for id, t in ipairs(engine.GetAddons()) do
        subscriptions[tonumber(t.wsid)] = true
    end

    local t = {}
    for id, fileh in ipairs(file.Find("addons/*.gma", "MOD")) do
        local a = string.StripExtension(fileh)
        a = string.Explode("_", a)
        a = tonumber(a[#a])
        if not subscriptions[a] then table.insert(t, fileh) end
    end
    return t
end

local function GetSize(b)
    b = b / 1000
    if b < 1000 then return math.floor(b * 10) / 10 .. " KB" end
    b = b / 1000
    if b < 1000 then return math.floor(b * 10) / 10 .. " MB" end
    b = b / 1000
    return math.floor(b * 10) / 10 .. " GB"
end

local function DrawText(txt, font, x, y, clr)
    draw.SimpleText(txt, font, x, y, clr)
    surface.SetFont(font)
    return surface.GetTextSize(txt)
end

local PANEL = {}
function PANEL:Init()
    self.Computed = false
end

function PANEL:Compute()
    self.WorkshopSize = 0
    for id, fle in ipairs(file.Find("addons/*.gma", "MOD")) do
        self.WorkshopSize = self.WorkshopSize + (file.Size("addons/" .. fle, "MOD") or 0)
    end

    self.WorkshopWaste = 0
    self.WorkshopWasteFiles = {}
    for id, fle in ipairs(GetWorkshopLeftovers()) do
        self.WorkshopWaste = self.WorkshopWaste + (file.Size("addons/" .. fle, "MOD") or 0)
        table.insert(self.WorkshopWasteFiles, {"addons/" .. fle, file.Size("addons/" .. fle, "MOD") or 0})
    end

    local _files, folders = file.Find("addons/*", "MOD")
    self.LegacyAddons = {}
    for k, v in ipairs(folders or {}) do
        self.LegacyAddons["addons/" .. v .. "/"] = "Installed"
        if file.IsDir("addons/" .. v .. "/models/", "MOD") then self.LegacyAddons["addons/" .. v .. "/"] = "Installed (Has Models)" end
        local _fi, fo = file.Find("addons/" .. v .. "/*", "MOD")
        if table.Count(fo or {}) < 1 then self.LegacyAddons["addons/" .. v .. "/"] = "Installed (Empty)" end
        if not file.IsDir("addons/" .. v .. "/models/", "MOD") and not file.IsDir("addons/" .. v .. "/materials/", "MOD") and not file.IsDir("addons/" .. v .. "/lua/", "MOD") and not file.IsDir("addons/" .. v .. "/sound/", "MOD") then self.LegacyAddons["addons/" .. v .. "/"] = "Installed Incorrectly!" end
    end

    local luaFiles = file.Find("cache/lua/*", "MOD")
    self.LuaCacheSize = #luaFiles * 1400
    self.LuaCacheFiles = #luaFiles
    local wsFiles = file.Find("cache/workshop/*", "MOD")
    self.WSCacheSize = 0
    for id, fle in ipairs(wsFiles) do
        self.WSCacheSize = self.WSCacheSize + (file.Size("cache/workshop/" .. fle, "MOD") or 0)
    end

    self.WSCacheFiles = #wsFiles
    self.Computed = true
end

function PANEL:Paint(w, h)
    if not self.Computed then self:Compute() end
    local txtW = self:GetParent():GetWide()
    local txtH = 0
    local tW, tH = DrawText("Cache Sizes", "AddonInfo_Header", 0, txtH, color_white)
    txtH = txtH + tH
    local localH = 0
    local localW = 0
    tW, tH = DrawText("~" .. GetSize(self.LuaCacheSize or 0) .. " (" .. self.LuaCacheFiles .. " files)", "AddonInfo_Small", 0, txtH + localH, Color(220, 220, 220))
    localH = localH + tH
    localW = math.max(localW, tW)
    tW, tH = DrawText("~" .. GetSize(self.WSCacheSize or 0) .. " (" .. self.WSCacheFiles .. " files)", "AddonInfo_Small", 0, txtH + localH, Color(220, 220, 220))
    localH = localH + tH
    localW = math.max(localW, tW)
    localW = localW + 25
    tW, tH = DrawText("Server Lua cache", "AddonInfo_Small", localW, txtH, color_white)
    txtH = txtH + tH
    tW, tH = DrawText("Workshop download cache", "AddonInfo_Small", localW, txtH, color_white)
    txtH = txtH + tH
    txtH = txtH + ScreenScaleH(8)
    tW, tH = DrawText("Workshop Subscriptions", "AddonInfo_Header", 0, txtH, color_white)
    txtH = txtH + tH
    tW, tH = DrawText("Used Size:  ", "AddonInfo_Text", 0, txtH, color_white)
    local maxW = tW
    txtH = txtH + tH
    tW, tH = DrawText("Wasted Space:  ", "AddonInfo_Text", 0, txtH, color_white)
    maxW = math.max(maxW, tW)
    txtH = txtH + tH
    tW, tH = DrawText("Total Size:  ", "AddonInfo_Text", 0, txtH, color_white)
    maxW = math.max(maxW, tW)
    txtH = txtH - tH * 2
    tW, tH = DrawText(GetSize((self.WorkshopSize - self.WorkshopWaste) or 0), "AddonInfo_Text", maxW, txtH, Color(220, 220, 220))
    txtH = txtH + tH
    tW, tH = DrawText(GetSize(self.WorkshopWaste or 0), "AddonInfo_Text", maxW, txtH, Color(220, 220, 220))
    txtH = txtH + tH
    tW, tH = DrawText(GetSize(self.WorkshopSize or 0), "AddonInfo_Text", maxW, txtH, Color(220, 220, 220))
    txtH = txtH + tH * 2
    tW, tH = DrawText("Files that aren't used: ( Safe to delete )", "AddonInfo_Text", 0, txtH, color_white)
    txtH = txtH + tH
    localH = 0
    localW = 0
    for id, t in pairs(self.WorkshopWasteFiles or {}) do
        tW, tH = DrawText(GetSize(t[2]) .. "    ", "AddonInfo_Small", 0, txtH + localH, Color(220, 220, 220))
        localH = localH + tH
        localW = math.max(localW, tW)
    end

    for id, t in pairs(self.WorkshopWasteFiles or {}) do
        tW, tH = DrawText(t[1], "AddonInfo_Small", localW, txtH, color_white)
        txtH = txtH + tH
    end

    tW, tH = DrawText("Legacy Addons", "AddonInfo_Header", 0, txtH + ScreenScaleH(8), color_white)
    txtH = txtH + tH + ScreenScaleH(8)
    tW, tH = DrawText("Legacy Addons with models:", "AddonInfo_Text", 0, txtH, color_white)
    txtH = txtH + tH
    if table.Count(self.LegacyAddons or {}) > 0 then
        local maxNameW = 0
        local oldH = txtH
        for path, status in pairs(self.LegacyAddons or {}) do
            tW, tH = DrawText(path, "AddonInfo_Small", 0, txtH, color_white)
            maxNameW = math.max(maxNameW, tW)
            txtH = txtH + tH
        end

        maxNameW = maxNameW + 25
        txtH = oldH
        for path, status in pairs(self.LegacyAddons or {}) do
            tW, tH = DrawText(status, "AddonInfo_Small", maxNameW, txtH, Color(220, 220, 220))
            txtH = txtH + tH
        end
    else
        tW, tH = DrawText("None.", "AddonInfo_Small", 0, txtH, color_white)
        txtH = txtH + tH
    end

    if not system.IsWindows() then
        txtH = txtH + tH
        tW, tH = DrawText("OSX AND LINUX USERS BEWARE:", "AddonInfo_Text", 0, txtH, color_white)
        txtH = txtH + tH
        tW, tH = DrawText("MAKE SURE ALL FILE AND FOLDER NAMES", "AddonInfo_Text", 0, txtH, color_white)
        txtH = txtH + tH
        tW, tH = DrawText("IN ALL ADDONS ARE LOWERCASE ONLY", "AddonInfo_Text", 0, txtH, color_white)
        txtH = txtH + tH
        tW, tH = DrawText("INCLUDING ALL SUB FOLDERS", "AddonInfo_Text", 0, txtH, color_white)
        txtH = txtH + tH
    end

    txtH = txtH + tH
    self:SetSize(txtW, txtH)
end

vgui.Register("rb655_addonInfo", PANEL, "Panel")
hook.Add("PopulatePropMenu", "rb655_LoadLegacySpawnlists", function()
    local sid = 0
    for id, spawnlist in ipairs(file.Find("settings/spawnlist/*.txt", "MOD")) do
        local content = file.Read("settings/spawnlist/" .. spawnlist, "MOD")
        if not content then continue end
        content = util.KeyValuesToTable(content)
        if not content.entries or content.contents then continue end
        local contents = {}
        for eid, entry in ipairs(content.entries) do
            if type(entry) == "table" then entry = entry.model end
            table.insert(contents, {
                type = "model",
                model = entry
            })
        end

        if not content.information then
            content.information = {
                name = spawnlist
            }
        end

        spawnmenu.AddPropCategory("settings/spawnlist/" .. spawnlist, content.information.name, contents, "icon16/page.png", sid + id, sid)
    end
end)
