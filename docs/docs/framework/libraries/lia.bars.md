### `lia.bar.get(identifier)`

    
    Description:
    Retrieves a bar object from the list by its unique identifier.
    
    Parameters:
    identifier (string) – The unique identifier of the bar to retrieve.
    
    Realm:
    Client
    
    Returns:
    table or nil – The bar table if found, or nil if not found.
    
    Example Usage:
    -- Retrieve the health bar and change its color at runtime
    local bar = lia.bar.get("health")
    if bar then
    bar.color = Color(0, 200, 0) -- make the bar green
    end

### `lia.bar.add(getValue, color, priority, identifier)`

    
    Description:
    Adds a new bar or replaces an existing one in the bar list.
    If the identifier matches an existing bar, the old bar is removed first.
    Bars are drawn in order of ascending priority.
    
    Parameters:
    getValue (function) – A callback that returns the current value of the bar.
    color (Color) – The fill color for the bar. Defaults to a random pastel color.
    priority (number) – Determines drawing order; lower values draw first. Defaults to end of list.
    identifier (string) – Optional unique identifier for the bar.
    
    Realm:
    Client
    
    Returns:
    number – The priority assigned to the added bar.
    
    Example Usage:
    -- Calculates the player's current health as a fraction of their maximum health.
    -- Uses a custom color (RGB 200, 50, 40) for the bar's fill.
    -- Assigns priority 1 so this bar draws before lower-priority bars.
    lia.bar.add(function()
    local client = LocalPlayer()
    return client:Health() / client:GetMaxHealth()
    end, Color(200, 50, 40), 1, "health")

### `lia.bar.remove(identifier)`

    
    Description:
    Removes a bar from the list based on its unique identifier.
    
    Parameters:
    identifier (string) – The unique identifier of the bar to remove.
    
    Realm:
    Client
    
    Returns:
    nil
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.bar.remove
    lia.bar.remove("example")

### `lia.bar.drawBar(x, y, w, h, pos, max, color)`

    
    Description:
    Draws a single horizontal bar at the specified screen coordinates,
    filling it proportionally based on pos and max.
    
    Parameters:
    x (number) – The x-coordinate of the bar's top-left corner.
    y (number) – The y-coordinate of the bar's top-left corner.
    w (number) – The total width of the bar (including padding).
    h (number) – The total height of the bar.
    pos (number) – The current value to display (will be clamped to max).
    max (number) – The maximum possible value for the bar.
    color (Color) – The color to fill the bar.
    
    Realm:
    Client
    
    Returns:
    nil
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.bar.drawBar
    lia.bar.drawBar(10, 10, 200, 20, 0.5, 1, Color(255,0,0))

### `lia.bar.drawAction(text, duration)`

    
    Description:
    Displays a temporary action progress bar with accompanying text
    for the specified duration on the HUD.
    
    Parameters:
    text (string) – The text to display above the progress bar.
    duration (number) – Duration in seconds for which the bar is displayed.
    
    Realm:
    Client
    
    Returns:
    nil
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.bar.drawAction
    lia.bar.drawAction("Reloading", 2)

### `lia.bar.drawAll()`

    
    Description:
    Iterates through all registered bars, applies smoothing to their values,
    and draws them on the HUD according to their priority and visibility rules.
    
    Parameters:
    None
    
    Realm:
    Client
    
    Returns:
    nil
    
    Example Usage:
    -- This snippet demonstrates a common usage of hook.Add
    hook.Add("HUDPaintBackground", "liaBarDraw", lia.bar.drawAll)
