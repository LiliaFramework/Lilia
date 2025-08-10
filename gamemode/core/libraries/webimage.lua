lia.webimage = lia.webimage or {}
local ip = string.Replace(string.Replace(game.GetIPAddress() or "unknown", ":", "_"), "%.", "_")
local gamemode = engine.ActiveGamemode() or "unknown"
local baseDir = "lilia/" .. ip .. "/" .. gamemode .. "/"
local cache = {}
local urlMap = {}
local registered = lia.webimage._registered or {}
local function ensureDir(p)
    local parts = string.Explode("/", p)
    local cur = ""
    for _, v in ipairs(parts) do
        cur = cur == "" and v or cur .. "/" .. v
        if not file.Exists(cur, "DATA") then file.CreateDir(cur) end
    end
end

local function buildMaterial(p, flags)
    return Material("data/" .. p, flags or "noclamp smooth")
end

function lia.webimage.register(n, u, cb, flags)
    if isstring(u) then urlMap[u] = n end
    registered[n] = {
        url = u,
        flags = flags
    }

    lia.webimage._registered = registered
    cache[n] = nil
    local savePath = baseDir .. n
    local function finalize(fromCache)
        local m = buildMaterial(savePath, flags)
        cache[n] = m
        if cb then cb(m, fromCache) end
        if not fromCache then hook.Run("WebImageDownloaded", n, "data/" .. savePath) end
    end

    http.Fetch(u, function(b)
        ensureDir(baseDir)
        file.Write(savePath, b)
        finalize(false)
    end, function(e)
        if file.Exists(savePath, "DATA") then
            finalize(true)
        elseif cb then
            cb(nil, false, e)
        end
    end)
end

function lia.webimage.get(n, flags)
    local key = urlMap[n] or n
    if cache[key] then return cache[key] end
    local savePath = baseDir .. key
    if file.Exists(savePath, "DATA") then
        local m = buildMaterial(savePath, flags)
        cache[key] = m
        return m
    end
end

local origMaterial = Material
function Material(p, ...)
    local flags = select(1, ...)
    if isstring(p) then
        if p:find("^https?://") then
            local n = urlMap[p]
            if not n then
                local ext = p:match("%.([%w]+)$") or "png"
                n = util.CRC(p) .. "." .. ext
                urlMap[p] = n
            end

            lia.webimage.register(n, p)
            return origMaterial("data/" .. baseDir .. n, flags)
        else
            local mat = lia.webimage.get(p, flags)
            if mat then return mat end
        end
    end
    return origMaterial(p, flags)
end

local dimage = vgui.GetControlTable("DImage")
if dimage and dimage.SetImage then
    local origSetImage = dimage.SetImage
    function dimage:SetImage(src, backup)
        if isstring(src) then
            if src:find("^https?://") then
                local n = urlMap[src]
                if not n then
                    local ext = src:match("%.([%w]+)$") or "png"
                    n = util.CRC(src) .. "." .. ext
                    urlMap[src] = n
                end

                local savePath = baseDir .. n
                lia.webimage.register(n, src, function(m)
                    if m and not m:IsError() then
                        origSetImage(self, "data/" .. savePath, backup)
                    elseif backup then
                        origSetImage(self, backup)
                    end
                end)
                return
            end

            local m = lia.webimage.get(src)
            if m and not m:IsError() then
                origSetImage(self, "data/" .. baseDir .. src, backup)
                return
            end
        end

        origSetImage(self, src, backup)
    end
end

concommand.Add("lia_saved_images", function()
    local files = file.Find(baseDir .. "*", "DATA")
    if not files or #files == 0 then return end
    local f = vgui.Create("DFrame")
    f:SetTitle(L("webImagesTitle"))
    f:SetSize(ScrW() * 0.6, ScrH() * 0.6)
    f:Center()
    f:MakePopup()
    local scroll = vgui.Create("DScrollPanel", f)
    scroll:Dock(FILL)
    local layout = vgui.Create("DIconLayout", scroll)
    layout:Dock(FILL)
    layout:SetSpaceX(4)
    layout:SetSpaceY(4)
    for _, fn in ipairs(files) do
        local img = layout:Add("DImage")
        img:SetMaterial(buildMaterial(baseDir .. fn))
        img:SetSize(128, 128)
        img:SetTooltip(fn)
    end
end)

concommand.Add("lia_wipewebimages", function()
    local files = file.Find(baseDir .. "*", "DATA")
    if files then
        for _, fn in ipairs(files) do
            file.Delete(baseDir .. fn)
        end
    end

    cache = {}
    urlMap = {}
    lia.information(L("webImagesCleared"))
    ensureDir(baseDir)
end)

concommand.Add("test_webimage_menu", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("webImageTesterTitle"))
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    local urlEntry = vgui.Create("DTextEntry", frame)
    urlEntry:SetPos(10, 30)
    urlEntry:SetSize(frame:GetWide() - 20, 25)
    urlEntry:SetText("")
    urlEntry:SetPlaceholderText(L("imageURLPlaceholder"))
    local loadBtn = vgui.Create("DButton", frame)
    loadBtn:SetPos(10, 65)
    loadBtn:SetSize(frame:GetWide() - 20, 30)
    loadBtn:SetText(L("loadImage"))
    local imgPanel = vgui.Create("DPanel", frame)
    imgPanel:SetPos(10, 105)
    imgPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 115)
    loadBtn.DoClick = function()
        for _, child in ipairs(imgPanel:GetChildren()) do
            child:Remove()
        end

        local src = urlEntry:GetValue()
        local img = vgui.Create("DImage", imgPanel)
        img:SetPos(0, 0)
        img:SetSize(imgPanel:GetWide(), imgPanel:GetTall())
        img:SetImage(src)
    end
end)

lia.webimage.register("lilia.png", "https://github.com/LiliaFramework/liaIcons/blob/main/lilia.png?raw=true")
lia.webimage.register("locked.png", "https://github.com/LiliaFramework/liaIcons/blob/main/locked.png?raw=true")
lia.webimage.register("unlocked.png", "https://github.com/LiliaFramework/liaIcons/blob/main/unlocked.png?raw=true")
lia.webimage.register("checkbox.png", "https://github.com/LiliaFramework/liaIcons/blob/main/checkbox.png?raw=true")
lia.webimage.register("unchecked.png", "https://github.com/LiliaFramework/liaIcons/blob/main/unchecked.png?raw=true")
lia.webimage.register("normaltalk.png", "https://github.com/LiliaFramework/liaIcons/blob/main/normaltalk.png?raw=true")
lia.webimage.register("yelltalk.png", "https://github.com/LiliaFramework/liaIcons/blob/main/yelltalk.png?raw=true")
lia.webimage.register("whispertalk.png", "https://github.com/LiliaFramework/liaIcons/blob/main/whispertalk.png?raw=true")
lia.webimage.register("notalk.png", "https://github.com/LiliaFramework/liaIcons/blob/main/notalk.png?raw=true")
lia.webimage.register("invslotfree.png", "https://github.com/LiliaFramework/liaIcons/blob/main/invslotfree.png?raw=true")
lia.webimage.register("vignette.png", "https://github.com/LiliaFramework/liaIcons/blob/main/vignette.png?raw=true")
lia.webimage.register("dark_vignette.png", "https://github.com/LiliaFramework/liaIcons/blob/main/dark_vignette.png?raw=true")
lia.webimage.register("invslotblocked.png", "https://github.com/LiliaFramework/liaIcons/blob/main/invslotblocked.png?raw=true")
lia.webimage.register("settings.png", "https://github.com/LiliaFramework/liaIcons/blob/main/settings.png?raw=true")
ensureDir(baseDir)