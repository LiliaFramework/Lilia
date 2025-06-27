--[[
    lia.webimage.register(name, url, callback, flags)

    Description:
        Downloads an image from the specified URL and caches it within the
        data folder. Once available, the provided callback receives the
        resulting Material.

    Parameters:
        name (string) – Unique file name including extension.
        url (string) – HTTP address of the image.
        callback (function|nil) – Called with (Material, fromCache, err).
        flags (string|nil) – Optional material flags for Material().

    Realm:
        Client

    Returns:
        nil

    Example Usage:
        lia.webimage.register("logo.png", "https://example.com/logo.png")
]]

--[[
    lia.webimage.get(name, flags)

    Description:
        Retrieves a Material for a previously registered image if it exists in
        the cache.

    Parameters:
        name (string) – File name used during registration.
        flags (string|nil) – Optional material flags.

    Realm:
        Client

    Returns:
        Material|nil – The image material or nil if missing.

    Example Usage:
        local mat = lia.webimage.get("logo.png")
]]
