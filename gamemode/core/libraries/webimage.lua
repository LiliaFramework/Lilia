lia.webimage = lia.webimage or {}
local ip = string.Replace(string.Replace(game.GetIPAddress() or "unknown", ":", "_"), "%.", "_")
local gamemode = engine.ActiveGamemode() or "unknown"
local baseDir = "lilia/" .. ip .. "/" .. gamemode .. "/"
local cache = {}
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
    if cache[n] then
        if cb then cb(cache[n], true) end
        return
    end

    local savePath = baseDir .. n
    local function finalize(fromCache)
        local m = buildMaterial(savePath, flags)
        cache[n] = m
        if cb then cb(m, fromCache) end
    end

    if file.Exists(savePath, "DATA") then
        finalize(true)
        return
    end

    http.Fetch(u, function(b)
        ensureDir(baseDir)
        file.Write(savePath, b)
        finalize(false)
    end, function(e) if cb then cb(nil, false, e) end end)
end

function lia.webimage.get(n, flags)
    if cache[n] then return cache[n] end
    local savePath = baseDir .. n
    if file.Exists(savePath, "DATA") then
        local m = buildMaterial(savePath, flags)
        cache[n] = m
        return m
    end
end

ensureDir(baseDir)
concommand.Add("lia_saved_images", function()
    local files = file.Find(baseDir .. "*", "DATA")
    if not files or #files == 0 then return end
    local f = vgui.Create("DFrame")
    f:SetTitle("Web Images")
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

concommand.Add("test_webimage_menu", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("WebImage Tester")
    frame:SetSize(500, 400)
    frame:Center()
    frame:MakePopup()
    local urlEntry = vgui.Create("DTextEntry", frame)
    urlEntry:SetPos(10, 30)
    urlEntry:SetSize(frame:GetWide() - 20, 25)
    urlEntry:SetText("https://i.imgur.com/WNdLdwQ.jpeg")
    local loadBtn = vgui.Create("DButton", frame)
    loadBtn:SetPos(10, 65)
    loadBtn:SetSize(frame:GetWide() - 20, 30)
    loadBtn:SetText("Load Image")
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