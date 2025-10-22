--[[
    Web Image Library

    Web-based image downloading, caching, and management system for the Lilia framework.
]]

--[[
    Overview:
    The web image library provides comprehensive functionality for downloading, caching, and managing
    web-based images in the Lilia framework. It handles automatic downloading of images from URLs,
    local caching to improve performance, and seamless integration with Garry's Mod's material system.
    The library operates on both server and client sides, with intelligent caching mechanisms that
    prevent redundant downloads and ensure images are available offline after initial download.
    It includes URL validation, file format detection, and automatic directory management for
    organized storage. The library also provides hooks for download events and statistics tracking.
    Images are stored in the data/lilia/webimages/ directory and can be accessed through various
    path formats for maximum compatibility with existing code.
]]
lia.webimage = lia.webimage or {}
lia.webimage.stored = lia.webimage.stored or {}
local baseDir = "lilia/webimages/"
local cache = {}
local urlMap = {}
local stats = {
    downloaded = 0,
    lastReset = os.time(),
    downloadedImages = {}
}

local function ensureDir(p)
    local parts = string.Explode("/", p)
    local cur = ""
    for _, v in ipairs(parts) do
        if v ~= "" then
            cur = cur == "" and v or cur .. "/" .. v
            if not file.Exists(cur, "DATA") then file.CreateDir(cur) end
        end
    end
end

local function deriveUrlSaveName(url)
    local filename = url:match("([^/]+)$") or util.CRC(url) .. ".png"
    if file.Exists(baseDir .. filename, "DATA") then return filename end
    local path = url:match("^https?://[^/]+/(.+)$") or filename
    if path:find("/") then path = path:gsub("^[^/]+/", "", 1) end
    return "urlimages/" .. path
end

local function buildMaterial(p, flags)
    return Material("data/" .. p, flags or "noclamp smooth")
end

local function validateURL(url)
    if not url or type(url) ~= "string" then return false, L("urlNotValidString") end
    if not url:find("^https?://") then return false, L("urlMustStartWithHttp") end
    local domain = url:match("^https?://([^/]+)")
    if not domain then return false, L("urlNoValidDomain") end
    if domain:find("^localhost") or domain:find("^127%.0%.0%.1") then return false, L("localhostUrlsNotAllowed") end
    local ipPattern = "^%d+%.%d+%.%d+%.%d+$"
    if domain:match(ipPattern) then
        local parts = string.Explode(".", domain)
        if #parts ~= 4 then return false, L("invalidIPAddressFormat") end
        for _, part in ipairs(parts) do
            local num = tonumber(part)
            if not num or num < 0 or num > 255 then return false, L("invalidIPAddressOctet") end
        end
    else
        if not domain:find("%.") then return false, L("domainMustContainDot") end
        if domain:find("%.%.") then return false, L("domainContainsConsecutiveDots") end
    end

    if url:find("[<>\"\\|]") then return false, L("urlContainsInvalidChars") end
    if #url > 2048 then return false, L("urlTooLong") end
    return true
end

--[[
    Purpose: Downloads an image from a URL and caches it locally for future use
    When Called: When you need to fetch an image from the internet and store it locally
    Parameters:
        - n (string): Name/identifier for the image
        - u (string, optional): URL to download from (uses stored URL if not provided)
        - cb (function, optional): Callback function called when download completes
        - flags (string, optional): Material flags for the downloaded image
    Returns: None (uses callback for results)
    Realm: Client
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Download a single image
        lia.webimage.download("logo", "https://example.com/logo.png")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Download with callback and custom flags
        lia.webimage.download("avatar", "https://example.com/avatar.jpg", function(material, fromCache)
            if material then
                print("Image downloaded successfully")
            else
                print("Failed to download image")
            end
        end, "noclamp smooth")
        ```

        High Complexity:
        ```lua
        -- High: Batch download with error handling and progress tracking
        local images = {
            {name = "banner", url = "https://example.com/banner.png"},
            {name = "icon", url = "https://example.com/icon.jpg"},
            {name = "background", url = "https://example.com/bg.png"}
        }

        local completed = 0
        for _, img in ipairs(images) do
            lia.webimage.download(img.name, img.url, function(material, fromCache, error)
                completed = completed + 1
                if material then
                    print("Downloaded: " .. img.name)
                else
                    print("Failed to download " .. img.name .. ": " .. (error or "unknown error"))
                end

                if completed == #images then
                    print("All downloads completed")
                end
            end)
        end
        ```
]]
function lia.webimage.download(n, u, cb, flags)
    if not isstring(n) then return end
    local url = u or lia.webimage.stored[n] and lia.webimage.stored[n].url
    local flg = flags or lia.webimage.stored[n] and lia.webimage.stored[n].flags
    if not url or url == "" then
        if cb then cb(nil, false, "no url") end
        return
    end

    local isValidURL, validationError = validateURL(url)
    if not isValidURL then
        if cb then cb(nil, false, "invalid url: " .. validationError) end
        return
    end

    if isstring(url) then urlMap[url] = n end
    cache[n] = nil
    local savePath = baseDir .. n
    local function finalize(fromCache)
        local m = buildMaterial(savePath, flg)
        cache[n] = m
        if cb then cb(m, fromCache) end
        if not fromCache and not stats.downloadedImages[n] then
            stats.downloadedImages[n] = true
            stats.downloaded = stats.downloaded + 1
            hook.Run("WebImageDownloaded", n, "data/" .. savePath)
        end
    end

    local cleanName = n:gsub("%.%w+$", "")
    local extension = nil
    for _, ext in ipairs({"png", "jpg", "jpeg"}) do
        local testPath = baseDir .. cleanName .. "." .. ext
        if file.Exists(testPath, "DATA") then
            savePath = testPath
            finalize(true)
            return
        end
    end

    http.Fetch(url, function(b)
        if string.lower(string.sub(b, 2, 4)) == "png" then
            extension = "png"
        elseif string.lower(string.sub(b, 7, 10)) == "jfif" or string.lower(string.sub(b, 7, 10)) == "exif" then
            extension = "jpg"
        end

        if not extension then
            if cb then cb(nil, false, L("invalidFileFormatNotPngJpeg")) end
            return
        end

        savePath = baseDir .. cleanName .. "." .. extension
        if file.Exists(savePath, "DATA") then
            local existingSize = file.Size(savePath, "DATA")
            if existingSize == #b then
                finalize(true)
                return
            end
        end

        local dirPath = savePath:match("(.+)/[^/]+$")
        if dirPath then
            ensureDir(dirPath)
        else
            ensureDir(baseDir)
        end

        file.Write(savePath, b)
        finalize(false)
    end, function(e)
        for _, ext in ipairs({"png", "jpg", "jpeg"}) do
            local testPath = baseDir .. cleanName .. "." .. ext
            if file.Exists(testPath, "DATA") then
                savePath = testPath
                finalize(true)
                return
            end
        end

        if cb then cb(nil, false, e) end
    end)
end

--[[
    Purpose: Registers an image URL for future use and immediately downloads it
    When Called: When you want to store an image URL and download it for later use
    Parameters:
        - n (string): Name/identifier for the image
        - u (string): URL to download from
        - cb (function, optional): Callback function called when download completes
        - flags (string, optional): Material flags for the downloaded image
    Returns: None
    Realm: Client
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Register and download a single image
        lia.webimage.register("logo", "https://example.com/logo.png")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Register with callback for UI updates
        lia.webimage.register("avatar", "https://example.com/avatar.jpg", function(material)
            if material and not material:IsError() then
                -- Update UI with the new avatar
                avatarPanel:SetImage("data/lilia/webimages/avatar")
            end
        end)
        ```

        High Complexity:
        ```lua
        -- High: Register multiple images with progress tracking
        local imageConfigs = {
            {name = "banner", url = "https://example.com/banner.png", flags = "noclamp"},
            {name = "icon", url = "https://example.com/icon.jpg", flags = "smooth"},
            {name = "background", url = "https://example.com/bg.png"}
        }

        local registered = 0
        for _, config in ipairs(imageConfigs) do
            lia.webimage.register(config.name, config.url, function(material)
                registered = registered + 1
                if material then
                    print("Registered: " .. config.name)
                end

                if registered == #imageConfigs then
                    print("All images registered successfully")
                end
            end, config.flags)
        end
        ```
]]
function lia.webimage.register(n, u, cb, flags)
    lia.webimage.stored[n] = {
        url = u,
        flags = flags
    }

    lia.webimage.download(n, u, cb, flags)
end

--[[
    Purpose: Retrieves a cached material from a previously downloaded image
    When Called: When you need to get a material that has already been downloaded and cached
    Parameters:
        - n (string): Name/identifier of the image or URL
        - flags (string, optional): Material flags to apply to the material
    Returns: Material object if found, nil otherwise
    Realm: Client
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get a cached material
        local logo = lia.webimage.get("logo")
        if logo then
            surface.SetMaterial(logo)
            surface.DrawTexturedRect(0, 0, 100, 100)
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Get material with custom flags and fallback
        local avatar = lia.webimage.get("avatar", "noclamp smooth")
        if avatar and not avatar:IsError() then
            avatarPanel:SetMaterial(avatar)
        else
            avatarPanel:SetImage("icon16/user.png") -- fallback
        end
        ```

        High Complexity:
        ```lua
        -- High: Batch retrieval with validation and error handling
        local imageNames = {"banner", "icon", "background", "logo"}
        local materials = {}

        for _, name in ipairs(imageNames) do
            local material = lia.webimage.get(name, "noclamp")
            if material and not material:IsError() then
                materials[name] = material
                print("Retrieved material: " .. name)
            else
                print("Failed to get material: " .. name)
                -- Trigger re-download if needed
                lia.webimage.download(name)
            end
        end

        -- Use materials for rendering
        for name, material in pairs(materials) do
            surface.SetMaterial(material)
            surface.DrawTexturedRect(0, 0, 200, 200)
        end
        ```
]]
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
                n = deriveUrlSaveName(p)
                urlMap[p] = n
            end

            lia.webimage.register(n, p)
            return origMaterial("data/" .. baseDir .. n, flags)
        elseif p:find("^lilia/webimages/") then
            local webPath = p:gsub("^lilia/webimages/", "")
            local mat = lia.webimage.get(webPath, flags)
            if mat then return mat end
            return origMaterial("data/" .. baseDir .. webPath, flags)
        elseif p:find("^webimages/") then
            local webPath = p:gsub("^webimages/", "")
            local mat = lia.webimage.get(webPath, flags)
            if mat then return mat end
            return origMaterial("data/" .. baseDir .. webPath, flags)
        else
            local mat = lia.webimage.get(p, flags)
            if mat then return mat end
        end
    end
    return origMaterial(p, flags)
end

local dimage = vgui.GetControlTable("DImage")
local origSetImage = dimage.SetImage
function dimage:SetImage(src, backup)
    if isstring(src) then
        if src:find("^https?://") then
            local n = urlMap[src]
            if not n then
                n = deriveUrlSaveName(src)
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
        elseif src:find("^lilia/webimages/") then
            local webPath = src:gsub("^lilia/webimages/", "")
            local m = lia.webimage.get(webPath)
            if m and not m:IsError() then
                origSetImage(self, "data/" .. baseDir .. webPath, backup)
                return
            end
        elseif src:find("^webimages/") then
            local webPath = src:gsub("^webimages/", "")
            local m = lia.webimage.get(webPath)
            if m and not m:IsError() then
                origSetImage(self, "data/" .. baseDir .. webPath, backup)
                return
            end
        else
            local m = lia.webimage.get(src)
            if m and not m:IsError() then
                origSetImage(self, "data/" .. baseDir .. src, backup)
                return
            end
        end
    end

    origSetImage(self, src, backup)
end

--[[
    Purpose: Retrieves statistics about downloaded and stored web images
    When Called: When you need to monitor the library's performance or get usage statistics
    Parameters: None
    Returns: Table containing statistics (downloaded count, stored count, last reset time)
    Realm: Client
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get basic statistics
        local stats = lia.webimage.getStats()
        print("Downloaded images: " .. stats.downloaded)
        print("Stored images: " .. stats.stored)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Display statistics in a panel
        local stats = lia.webimage.getStats()
        local statsPanel = vgui.Create("DPanel")
        statsPanel:SetSize(200, 100)

        local downloadedLabel = vgui.Create("DLabel", statsPanel)
        downloadedLabel:SetText("Downloaded: " .. stats.downloaded)
        downloadedLabel:SetPos(10, 10)

        local storedLabel = vgui.Create("DLabel", statsPanel)
        storedLabel:SetText("Stored: " .. stats.stored)
        storedLabel:SetPos(10, 30)

        local resetLabel = vgui.Create("DLabel", statsPanel)
        resetLabel:SetText("Last Reset: " .. os.date("%H:%M:%S", stats.lastReset))
        resetLabel:SetPos(10, 50)
        ```

        High Complexity:
        ```lua
        -- High: Create a comprehensive statistics dashboard
        local function createStatsDashboard()
            local stats = lia.webimage.getStats()
            local dashboard = vgui.Create("DFrame")
            dashboard:SetSize(400, 300)
            dashboard:SetTitle("Web Image Statistics")
            dashboard:Center()
            dashboard:MakePopup()

            local scrollPanel = vgui.Create("DScrollPanel", dashboard)
            scrollPanel:Dock(FILL)

            -- Download statistics
            local downloadPanel = vgui.Create("DPanel", scrollPanel)
            downloadPanel:SetSize(380, 80)
            downloadPanel:Dock(TOP)
            downloadPanel:DockMargin(5, 5, 5, 5)

            local downloadLabel = vgui.Create("DLabel", downloadPanel)
            downloadLabel:SetText("Downloaded Images: " .. stats.downloaded)
            downloadLabel:SetPos(10, 10)
            downloadLabel:SetFont("DermaDefault")

            -- Stored statistics
            local storedPanel = vgui.Create("DPanel", scrollPanel)
            storedPanel:SetSize(380, 80)
            storedPanel:Dock(TOP)
            storedPanel:DockMargin(5, 5, 5, 5)

            local storedLabel = vgui.Create("DLabel", storedPanel)
            storedLabel:SetText("Stored Images: " .. stats.stored)
            storedLabel:SetPos(10, 10)
            storedLabel:SetFont("DermaDefault")

            -- Reset time
            local resetPanel = vgui.Create("DPanel", scrollPanel)
            resetPanel:SetSize(380, 80)
            resetPanel:Dock(TOP)
            resetPanel:DockMargin(5, 5, 5, 5)

            local resetLabel = vgui.Create("DLabel", resetPanel)
            resetLabel:SetText("Last Reset: " .. os.date("%Y-%m-%d %H:%M:%S", stats.lastReset))
            resetLabel:SetPos(10, 10)
            resetLabel:SetFont("DermaDefault")

            -- Refresh button
            local refreshBtn = vgui.Create("DButton", dashboard)
            refreshBtn:SetText("Refresh Stats")
            refreshBtn:SetSize(100, 30)
            refreshBtn:SetPos(150, 250)
            refreshBtn.DoClick = function()
                dashboard:Close()
                createStatsDashboard() -- Refresh
            end
        end

        createStatsDashboard()
        ```
]]
function lia.webimage.getStats()
    local totalStored = 0
    for _ in pairs(lia.webimage.stored) do
        totalStored = totalStored + 1
    end
    return {
        downloaded = stats.downloaded,
        stored = totalStored,
        lastReset = stats.lastReset
    }
end

lia.webimage.register("lilia.png", "https://bleonheart.github.io/Samael-Assets/lilia.png")
lia.webimage.register("locked.png", "https://bleonheart.github.io/Samael-Assets/misc/locked.png")
lia.webimage.register("unlocked.png", "https://bleonheart.github.io/Samael-Assets/misc/unlocked.png")
lia.webimage.register("checkbox.png", "https://bleonheart.github.io/Samael-Assets/misc/checkbox.png")
lia.webimage.register("unchecked.png", "https://bleonheart.github.io/Samael-Assets/misc/unchecked.png")
lia.webimage.register("normaltalk.png", "https://bleonheart.github.io/Samael-Assets/misc/normaltalk.png")
lia.webimage.register("yelltalk.png", "https://bleonheart.github.io/Samael-Assets/misc/yelltalk.png")
lia.webimage.register("whispertalk.png", "https://bleonheart.github.io/Samael-Assets/misc/whispertalk.png")
lia.webimage.register("notalk.png", "https://bleonheart.github.io/Samael-Assets/misc/notalk.png")
lia.webimage.register("invslotfree.png", "https://bleonheart.github.io/Samael-Assets/misc/invslotfree.png")
lia.webimage.register("vignette.png", "https://bleonheart.github.io/Samael-Assets/misc/vignette.png")
lia.webimage.register("dark_vignette.png", "https://bleonheart.github.io/Samael-Assets/misc/dark_vignette.png")
lia.webimage.register("invslotblocked.png", "https://bleonheart.github.io/Samael-Assets/misc/invslotblocked.png")
lia.webimage.register("settings.png", "https://bleonheart.github.io/Samael-Assets/misc/settings.png")
lia.webimage.register("close_button.png", "https://bleonheart.github.io/Samael-Assets/misc/close_button.png")
lia.webimage.register("drug.png", "https://bleonheart.github.io/Samael-Assets/misc/drug.png")
lia.webimage.register("armor.png", "https://bleonheart.github.io/Samael-Assets/misc/armor.png")
lia.webimage.register("emptyframe.png", "https://bleonheart.github.io/Samael-Assets/misc/emptyframe.png")
lia.webimage.register("cuffed.png", "https://bleonheart.github.io/Samael-Assets/misc/cuffed.png")
lia.webimage.register("backgroundsquare.png", "https://bleonheart.github.io/Samael-Assets/misc/backgroundsquare.png")
ensureDir(baseDir)
