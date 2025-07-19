# WebImage Library

This page explains how web images are downloaded and cached.

---

## Overview

The web-image library downloads remote images and caches them as materials. Cached files are stored under

`data/lilia/<IP>/<Gamemode>/`, so each server keeps its own image collection. The library also extends

`Material()` and `DImage:SetImage()` so you can pass HTTP(S) URLs directly—the image is downloaded, cached, and used automatically. Images retrieved later using the same URL will return the previously cached file, and you may reference the saved name anywhere an image path is expected.

---

### lia.webimage.register

**Purpose**

Downloads an image from the given URL and saves it inside the web-image cache. If the file already exists it will be replaced with the new download. Should the request fail the previous cached file is used and passed to the callback.

**Parameters**

* `name` (*string*): Unique file name including extension.

* `url` (*string*): HTTP address of the image.

* `callback` (*function | nil*): Called as `callback(mat, fromCache, err)` where `mat` is a `Material`, `fromCache` is `true` if loaded from disk, and `err` is an error string on failure.

* `flags` (*string | nil*): Optional material flags passed to `Material()`.

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

* `name` (*string*): File name used during registration.

* `flags` (*string | nil*): Optional material flags.

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

-- Registered names and URLs are interchangeable
lia.webimage.register("logo_axis.png", "https://example.com/logo.png")
local byName = Material("logo_axis.png")
local byURL = Material("https://example.com/logo.png")
```

---

### Clearing the Cache

Use the `lia_wipewebimages` console command on the client to delete all cached web
images from disk. New requests will download the images again.
