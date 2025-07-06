# WebImage Library

This page explains how web images are downloaded and cached.

---

## Overview

The webimage library downloads remote images and caches them as materials. Cached files are stored under

`data/lilia/<IP>/<Gamemode>/` so each server keeps its own image collection. The library also extends

`Material()` and `DImage:SetImage()` allowing you to pass HTTP(S) URLs directly; the image is downloaded,

cached and then used automatically.

---

### lia.webimage.register

**Purpose**

Downloads an image from the given URL and saves it inside the web image cache. If the file already exists locally the callback fires immediately with the cached Material. When the HTTP request fails the callback receives `nil` and an error string.

**Parameters**

* `name` (`string`): Unique file name including extension.


* `url` (`string`): HTTP address of the image.


* `callback` (`function|nil`): Function that receives `(Material mat, boolean fromCache, string err)`.


* `flags` (`string|nil`): Optional material flags for Material().


**Realm**

`Client`


**Returns**

* None


**Example**

```lua
-- Download an image and apply it when ready
lia.webimage.register("logo.png", "https://example.com/logo.png", function(mat, fromCache, err)
    if mat then
        panel:SetMaterial(mat)
    else
        print(err)
    end
end)

-- DImage:SetImage can use the saved name later
myIcon:SetImage("logo.png")
```

---

### lia.webimage.get

**Purpose**

Returns the material previously cached with `lia.webimage.register`. If it does not exist this function returns `nil`. `Material()` and `DImage:SetImage()` call this internally when given a matching name or URL.

**Parameters**

* `name` (`string`): File name used during registration.


* `flags` (`string|nil`): Optional material flags.


**Realm**

`Client`


**Returns**

* Material|nil: The image material or nil if missing.


**Example**

```lua
-- Retrieve a cached material and draw it
local mat = lia.webimage.get("logo.png")
if mat then
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, 64, 64)
end

-- Load directly from the web
local direct = Material("https://example.com/icon.png")

-- Apply with DImage
button:SetImage("https://example.com/icon.png")
```

---

### lia_saved_images

**Purpose**

Opens a panel listing all cached web images for the current server.

**Realm**

`Client` (`Console`)

**Example**

```bash
lia_saved_images
```

---

### test_webimage_menu

**Purpose**

Shows a simple window for previewing any image URL. Useful for development.

**Realm**

`Client` (`Console`)

**Example**

```bash
test_webimage_menu
```

