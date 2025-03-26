--[[ 
    Hook: ShouldHideBars

    Description:
        Determines whether the player's HUD bars (action/status) should be hidden.
        If this hook returns true, lia.bar.drawAll will skip rendering all bars.

    Parameters:
        None

    Returns:
        boolean - Return true to hide bars, false or nil to show them.

    Realm:
        Client

    Example Usage:
        hook.Add("ShouldHideBars", "MyCustomCondition", function()
            return LocalPlayer():InVehicle()
        end)
]]