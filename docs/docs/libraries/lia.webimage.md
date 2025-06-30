# WebImage Library


This page explains how web images are downloaded and cached.


---


## Overview


The webimage library downloads remote images and caches them as materials. It avoids repeated downloads and allows you to reference web images by name.


---


### lia.webimage.register(name, url, callback, flags)

**Description:**


Downloads an image from the specified URL and caches it within the

data folder. Once available, the provided callback receives the

resulting Material.


**Parameters:**


* name (string) – Unique file name including extension.


* url (string) – HTTP address of the image.


* callback (function|nil) – Called with (Material, fromCache, err).


* flags (string|nil) – Optional material flags for Material().


**Realm:**


* Client


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.webimage.register
    lia.webimage.register("logo.png", "https://example.com/logo.png")
```


---


### lia.webimage.get(name, flags)

**Description:**


The library extends Garry's Mod's `Material()` and `DImage:SetImage()`

functions so they accept direct HTTP or HTTPS image URLs. The image is

automatically downloaded via `lia.webimage.register` and cached before

the material is returned or applied.


**Parameters:**


* name (string) – File name used during registration.


* flags (string|nil) – Optional material flags.


**Realm:**


* Client


**Returns:**


* Material|nil – The image material or nil if missing.


**Example Usage:**


```lua
    -- Load a material directly from the web
    local mat = Material("https://example.com/icon.png")

    -- Apply a remote image to a button
    button:SetImage("https://example.com/icon.png")
```

