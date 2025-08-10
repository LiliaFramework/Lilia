# WebSound Library

This page explains how remote sounds are downloaded and cached.

---

## Overview

The web-sound library downloads remote audio files and stores them inside
`data/lilia/sounds/<IP>/<Gamemode>/`. Each server therefore keeps its own
collection of downloaded sounds. The library overrides `sound.PlayFile` and
`sound.PlayURL` so HTTP(S) URLs may be passed directly—the file is downloaded,
cached and then played. Web addresses can also be used anywhere a sound path is
expected, such as with `Entity:EmitSound`. If a web URL is passed to
`sound.PlayFile` or `sound.PlayURL` without prior registration, a hashed file
name is generated using `util.CRC` and the extension taken from the URL (default
`mp3`). The `mode` argument to both overrides defaults to an empty string. When a
cached name or matching URL is supplied, the stored file is reused. Volume and
pitch from `EntityEmitSound` are preserved for 3D playback.

---

### lia.websound.register

**Purpose**

Downloads a sound from the given URL and saves it in the web-sound cache. Any
existing file with the same name is overwritten by the new download. If the
request fails the old cached file is used and passed to the callback.

**Parameters**

* `name` (*string*): Unique file name including extension.
* `url` (*string*): HTTP address of the sound file.
* `cb` (*function | nil*): Called as `cb(path, fromCache)` on success or
  `cb(nil, false, err)` on failure. `path` is the local data path and
  `fromCache` is `true` when loaded from disk.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Download a sound and play it when ready
lia.websound.register("alert.mp3", "https://example.com/alert.mp3", function(path, fromCache, err)
    if path then
        sound.PlayFile(path, "", function(chan) if chan then chan:Play() end end)
    else
        print(err)
    end
end)
```

---

### lia.websound.get

**Purpose**

Returns the file path cached with `lia.websound.register`. The `name` can be
either the registered file name or the original URL. If the file is missing
`nil` is returned. Both `sound.PlayFile` and `sound.PlayURL` call this internally
when a cached name or matching URL is supplied.

**Parameters**

* `name` (*string*): File name or URL used during registration.

**Realm**

`Client`

**Returns**

* *string | nil*: Local data path or `nil` if not found.

**Example Usage**

```lua
-- Retrieve a cached sound and play it
local path = lia.websound.get("alert.mp3")
if path then
    sound.PlayFile(path, "", function(chan) if chan then chan:Play() end end)
end

-- Play directly from the web
sound.PlayFile("https://example.com/alert.mp3", "", function(chan)
    if chan then chan:Play() end
end)

-- Emit a web sound from an entity
local ply = LocalPlayer()
ply:EmitSound("https://example.com/alert.mp3")
```

---

### Viewing Saved Sounds

Use the `lia_saved_sounds` console command on the client to open a menu listing
all cached web sounds for preview and playback. If no sounds are cached the menu
is not opened.

---

### Clearing the Cache

To remove all downloaded web sounds on the client use the following console
command:

```
lia_wipe_sounds
```

This deletes every cached file and resets the internal cache tables. Any sounds
played afterwards will be downloaded again as needed.
