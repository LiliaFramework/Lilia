# Keybind Library


This page describes functions to register custom keybinds.


---


## Overview


The keybind library stores user-defined keyboard bindings. It reads and writes keybind files and dispatches callbacks when the associated keys are pressed.


---


### lia.keybind.add(k, d, cb, rcb)

**Description:**


Registers a new keybind for a given action.

Converts the provided key identifier to its corresponding key constant (if it's a string),

and stores the keybind settings including the default key, press callback, and release callback.

Also maps the key code back to the action identifier for reverse lookup.


**Parameters:**


* k (string or number) – The key identifier, either as a string (to be converted) or as a key code.


* d (string) – The unique identifier for the keybind action.


* cb (function) – The callback function to be executed when the key is pressed.


* rcb (function) – The callback function to be executed when the key is released.


**Realm:**


* Client


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.keybind.add
    lia.keybind.add("space", "jump", function() print("Jump pressed!") end, function() print("Jump released!") end)
```


---


### lia.keybind.get(a, df)

**Description:**


Retrieves the current key code for a specified keybind action.

If the keybind has a set value, that value is returned; otherwise, it falls back to the default key

or an optionally provided fallback value.


**Parameters:**


* a (string) – The unique identifier for the keybind action.


* df (number) – An optional default key code to return if the keybind is not set.


**Realm:**


* Client


**Returns:**


* number – The key code associated with the keybind action, or the default/fallback value if not set.


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.keybind.get
    local jumpKey = lia.keybind.get("jump", KEY_SPACE)
```


---


### lia.keybind.save()

**Description:**


Saves the current keybind settings to a file.

The function creates a directory specific to the active gamemode, constructs a filename based on the server's IP address,

and writes the keybind mapping (action identifiers to key codes) in JSON format.


**Parameters:**


* None


**Realm:**


* Client


    Internal Function:

    true


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.keybind.save
    lia.keybind.save()
```


---


### lia.keybind.load()

**Description:**


Loads keybind settings from a file.

The function reads a JSON file from a gamemode-specific directory, applies the saved keybind values to the stored keybinds,

and if no saved file is found, it resets the keybinds to their default values and saves them.

It also sets up a reverse mapping from key codes to keybind action identifiers.

Finally, it triggers the "InitializedKeybinds" hook.


**Parameters:**


* None


**Realm:**


* Client


    Internal Function:

    true


**Returns:**


* None


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.keybind.load
    lia.keybind.load()
```

