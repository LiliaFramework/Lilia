# Option Library

This page details the client/server option system.

---

## Overview

The option library stores user and server options with default values. It offers getters and setters that automatically network changes between client and server.
--[[--
Client-side configuration management.

The `option` library provides a cleaner way to manage any arbitrary data on the client without the hassle of managing CVars. It
is analagous to the `ix.config` library, but it only deals with data that needs to be stored on the client.

To get started, you'll need to define an option in a client realm so the framework can be aware of its existence. This can be
done in the `cl_init.lua` file of your schema, or in an `if (CLIENT) then` statement in the `sh_plugin.lua` file of your plugin:
	ix.option.Add("headbob", ix.type.bool, true)

If you need to get the value of an option on the server, you'll need to specify `true` for the `bNetworked` argument in
`ix.option.Add`. *NOTE:* You also need to define your option in a *shared* realm, since the server now also needs to be aware
of its existence. This makes it so that the client will send that option's value to the server whenever it changes, which then
means that the server can now retrieve the value that the client has the option set to. For example, if you need to get what
language a client is using, you can simply do the following:
	ix.option.Get(player.GetByID(1), "language", "english")

This will return the language of the player, or `"english"` if one isn't found. Note that `"language"` is a networked option
that is already defined in the framework, so it will always be available. All options will show up in the options menu on the
client, unless `hidden` returns `true` when using `ix.option.Add`.

Note that the labels for each option in the menu will use a language phrase to show the name. For example, if your option is
named `headbob`, then you'll need to define a language phrase called `optHeadbob` that will be used as the option title.
]]
---

### `lia.option.add(key, name, desc, default, callback, data)`

    
    Description:
    Adds a configuration option to the lia.option system.
    
    Parameters:
    key (string) — The unique key for the option.
    name (string) — The display name of the option.
    desc (string) — A brief description of the option's purpose.
    default (any) — The default value for this option.
    callback (function) — A function to call when the option’s value changes (optional).
    data (table) — Additional data describing the option (e.g., min, max, type, category, visible, shouldNetwork).
    
    Returns:
    nil
    
    Realm:
    Shared
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.option.add
    lia.option.add("showHints", "Show Hints", "Display hints", true)

### `lia.option.set(key, value)`

    
    Description:
    Sets the value of a specified option, saves locally, and optionally networks to the server.
    
    Parameters:
    key (string) — The unique key identifying the option.
    value (any) — The new value to assign to this option.
    
    Returns:
    nil
    
    Realm:
    Client
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.option.set
    lia.option.set("showHints", false)

### `lia.option.get(key, default)`

    
    Description:
    Retrieves the value of a specified option, or returns a default if it doesn't exist.
    
    Parameters:
    key (string) — The unique key identifying the option.
    default (any) — The value to return if the option is not found.
    
    Returns:
    (any) The current value of the option or the provided default.
    
    Realm:
    Client
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.option.get
    local show = lia.option.get("showHints", true)

### `lia.option.save()`

    
    Description:
    Saves all current option values to a file, named based on the server IP, within the active gamemode folder.
    
    Parameters:
    None
    
    Returns:
    nil
    
    Realm:
    Client
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.option.save
    lia.option.save()

### `lia.option.load()`

    
    Description:
    Loads saved option values from disk based on server IP and applies them to lia.option.stored.
    
    Parameters:
    None
    
    Returns:
    nil
    
    Realm:
    Client
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.option.load
    lia.option.load()
