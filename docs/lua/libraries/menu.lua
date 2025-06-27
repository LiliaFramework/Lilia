--[[
    lia.menu.add(opts, pos, onRemove)

    Description:
        Creates a new world or entity menu using the entries provided in 'opts'.
        Keys are display text and values are callback functions executed when
        selected. The menu may be positioned at a world Vector or anchored to
        an entity.

    Parameters:
        opts (table) – Table of label/callback pairs.
        pos (Vector|Entity|nil) – World position or entity to attach the menu to.
        onRemove (function|nil) – Called when the menu is removed.

    Realm:
        Client

    Returns:
        number – Identifier for the created menu entry.
]]

--[[
    lia.menu.drawAll()

    Description:
        Draws all active menus on the player's screen. Typically called from
        HUDPaint.

    Parameters:
        None

    Realm:
        Client

    Returns:
        nil
]]

--[[
    lia.menu.getActiveMenu()

    Description:
        Returns the ID and callback of the menu item currently being hovered
        or selected by the player.

    Parameters:
        None

    Realm:
        Client

    Returns:
        id (number|nil) – Index of the active menu.
        callback (function|nil) – Callback for the hovered item.
]]

--[[
    lia.menu.onButtonPressed(id, callback)

    Description:
        Removes the specified menu and runs its callback if provided.

    Parameters:
        id (number) – Identifier returned by lia.menu.add.
        callback (function|nil) – Function to execute after removal.

    Realm:
        Client

    Returns:
        boolean – True if a callback was executed.
]]
