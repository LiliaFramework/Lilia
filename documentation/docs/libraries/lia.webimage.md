# Web Image Library

Web-based image downloading, caching, and management system for the Lilia framework.

---

## Overview

The web image library provides comprehensive functionality for downloading, caching, and managing web-based images in the Lilia framework. It handles automatic downloading of images from URLs, local caching to improve performance, and seamless integration with Garry's Mod's material system. The library operates on both server and client sides, with intelligent caching mechanisms that prevent redundant downloads and ensure images are available offline after initial download. It includes URL validation, file format detection, and automatic directory management for organized storage. The library also provides hooks for download events and statistics tracking. Images are stored in the data/lilia/webimages/ directory and can be accessed through various path formats for maximum compatibility with existing code.

---

### download

**Purpose**

Downloads an image from a URL and caches it locally for future use

**When Called**

When you need to fetch an image from the internet and store it locally

**Parameters**

* `n` (*string*): Name/identifier for the image
* `u` (*string, optional*): URL to download from (uses stored URL if not provided)
* `cb` (*function, optional*): Callback function called when download completes
* `flags` (*string, optional*): Material flags for the downloaded image

**Returns**

* None (uses callback for results)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Download a single image
lia.webimage.download("logo", "https://example.com/logo.png")

```

**Medium Complexity:**
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

**High Complexity:**
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

---

### register

**Purpose**

Registers an image URL for future use and immediately downloads it

**When Called**

When you want to store an image URL and download it for later use

**Parameters**

* `n` (*string*): Name/identifier for the image
* `u` (*string*): URL to download from
* `cb` (*function, optional*): Callback function called when download completes
* `flags` (*string, optional*): Material flags for the downloaded image

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Register and download a single image
lia.webimage.register("logo", "https://example.com/logo.png")

```

**Medium Complexity:**
```lua
-- Medium: Register with callback for UI updates
lia.webimage.register("avatar", "https://example.com/avatar.jpg", function(material)
    if material and not material:IsError() then
        -- Update UI with the new avatar
        avatarPanel:SetImage("data/lilia/webimages/avatar")
    end
end)

```

**High Complexity:**
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

---

### get

**Purpose**

Retrieves a cached material from a previously downloaded image

**When Called**

When you need to get a material that has already been downloaded and cached

**Parameters**

* `n` (*string*): Name/identifier of the image or URL
* `flags` (*string, optional*): Material flags to apply to the material

**Returns**

* Material object if found, nil otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a cached material
local logo = lia.webimage.get("logo")
if logo then
    surface.SetMaterial(logo)
    surface.DrawTexturedRect(0, 0, 100, 100)
end

```

**Medium Complexity:**
```lua
-- Medium: Get material with custom flags and fallback
local avatar = lia.webimage.get("avatar", "noclamp smooth")
if avatar and not avatar:IsError() then
    avatarPanel:SetMaterial(avatar)
else
    avatarPanel:SetImage("icon16/user.png") -- fallback
end

```

**High Complexity:**
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

---

### lia.Material

**Purpose**

Retrieves a cached material from a previously downloaded image

**When Called**

When you need to get a material that has already been downloaded and cached

**Parameters**

* `n` (*string*): Name/identifier of the image or URL
* `flags` (*string, optional*): Material flags to apply to the material

**Returns**

* Material object if found, nil otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a cached material
local logo = lia.webimage.get("logo")
if logo then
    surface.SetMaterial(logo)
    surface.DrawTexturedRect(0, 0, 100, 100)
end

```

**Medium Complexity:**
```lua
-- Medium: Get material with custom flags and fallback
local avatar = lia.webimage.get("avatar", "noclamp smooth")
if avatar and not avatar:IsError() then
    avatarPanel:SetMaterial(avatar)
else
    avatarPanel:SetImage("icon16/user.png") -- fallback
end

```

**High Complexity:**
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

---

### lia.dimage:SetImage

**Purpose**

Retrieves a cached material from a previously downloaded image

**When Called**

When you need to get a material that has already been downloaded and cached

**Parameters**

* `n` (*string*): Name/identifier of the image or URL
* `flags` (*string, optional*): Material flags to apply to the material

**Returns**

* Material object if found, nil otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a cached material
local logo = lia.webimage.get("logo")
if logo then
    surface.SetMaterial(logo)
    surface.DrawTexturedRect(0, 0, 100, 100)
end

```

**Medium Complexity:**
```lua
-- Medium: Get material with custom flags and fallback
local avatar = lia.webimage.get("avatar", "noclamp smooth")
if avatar and not avatar:IsError() then
    avatarPanel:SetMaterial(avatar)
else
    avatarPanel:SetImage("icon16/user.png") -- fallback
end

```

**High Complexity:**
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

---

### getStats

**Purpose**

Retrieves statistics about downloaded and stored web images

**When Called**

When you need to monitor the library's performance or get usage statistics

**Returns**

* Table containing statistics (downloaded count, stored count, last reset time)

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get basic statistics
local stats = lia.webimage.getStats()
print("Downloaded images: " .. stats.downloaded)
print("Stored images: " .. stats.stored)

```

**Medium Complexity:**
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

**High Complexity:**
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

---

