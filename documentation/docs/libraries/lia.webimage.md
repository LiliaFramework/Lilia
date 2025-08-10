# WebImage Library

This page explains how web images are downloaded and cached.

---

## Overview

The web-image library downloads remote images and caches them as materials. Cached files are stored under

`data/lilia/<IP>/<Gamemode>/`, so each server keeps its own image collection. The library overrides

`Material()` and `DImage:SetImage()` so HTTP(S) URLs can be used directly. When given a URL, a unique file
name based on the URL's CRC is generated, the image is downloaded and saved, and the material is returned or
applied. Subsequent calls reuse the cached file, and the saved name can be referenced anywhere an image path is
expected. `DImage:SetImage` continues to support its optional `backup` argument, which is used if the download
fails or the material errors.

---

### lia.webimage.register

**Purpose**

Downloads an image from the given URL and saves it inside the web-image cache. If the file already exists it
will be replaced with the new download. Should the request fail the previous cached file is used when available.
If no cached copy exists, the callback receives `nil`, `false`, and the error message. When a new file is
successfully downloaded the `WebImageDownloaded` hook is triggered with the saved name and path.

**Parameters**

* `n` (*string*): Unique file name including extension.

* `u` (*string*): HTTP address of the image.

* `cb` (*function | nil*): Called as `cb(mat, fromCache[, err])` where `mat` is a `Material`, `fromCache` is `true` if loaded from disk, and `err` is an error string on failure.

* `flags` (*string | nil*): Optional material flags passed to `Material()`. Defaults to `"noclamp smooth"` when omitted.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Download an image and apply it when ready
lia.webimage.register("logo.png", "https://example.com/logo.png", function(mat, fromCache, err)
    if mat then
        panel:SetMaterial(mat)
    else
        print(err)
    end
end)

-- Later, DImage:SetImage can use the cached name
myIcon:SetImage("logo.png")
```

---

### lia.webimage.get

**Purpose**

Returns the material cached with `lia.webimage.register`. If the file is missing, returns `nil`. Both `Material()` and `DImage:SetImage()` call this internally when a cached name or matching URL is supplied.

**Parameters**

* `n` (*string*): Registered file name or URL.

* `flags` (*string | nil*): Optional material flags. Defaults to `"noclamp smooth"` when omitted.

**Realm**

`Client`

**Returns**

* *Material | nil*: Cached material or `nil` if not found.

**Example Usage**

```lua
-- Retrieve a cached material and draw it
local mat = lia.webimage.get("logo.png")
if mat then
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, 64, 64)
end

-- Load directly from the web with Material()
local direct = Material("https://example.com/icon.png")

-- Apply to a DImage
button:SetImage("https://example.com/icon.png")

-- Provide a fallback image if the download fails
button:SetImage("https://example.com/does_not_exist.png", "icon16/error.png")

-- Registered names and URLs are interchangeable
lia.webimage.register("logo_axis.png", "https://example.com/logo.png")
local byName = Material("logo_axis.png")
local byURL = Material("https://example.com/logo.png")
```

---

### Viewing Saved Images

Run the `lia_saved_images` console command on the client to open a panel that lists all cached web images.

---

### Clearing the Cache

Use the `lia_wipewebimages` console command on the client to delete all cached web images from disk. New requests will download the images again.

---

### Test Menu

The `test_webimage_menu` console command opens a simple interface for loading and previewing images from arbitrary URLs.
