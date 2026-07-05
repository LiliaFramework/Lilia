--[[
    Hooks:
        CanPlayerAccessVendor(client, vendor)

    Purpose:
        Determines whether a player may open or continue using a vendor.

    Category:
        Vendor

    Parameters:
        client (Player)
            The player attempting to access the vendor.

        vendor (Entity)
            The vendor entity being accessed.

    Example Usage:
        ```lua
        hook.Add("CanPlayerAccessVendor", "liaExampleCanPlayerAccessVendor", function(client, vendor)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to block vendor access.

    Realm:
        Server
]]
--[[
    Hooks:
        CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)

    Purpose:
        Determines whether a player may buy or sell a specific item through a vendor.

    Category:
        Vendor

    Parameters:
        client (Player)
            The player attempting the trade.

        vendor (Entity)
            The vendor handling the trade.

        itemType (string)
            The item unique ID being traded.

        isSellingToVendor (boolean)
            Whether the player is selling the item to the vendor instead of buying it.

    Example Usage:
        ```lua
        hook.Add("CanPlayerTradeWithVendor", "liaExampleCanPlayerTradeWithVendor", function(client, vendor, itemType, isSellingToVendor)
            if itemType == "restricted_crate" and not isSellingToVendor then
                return false, "vendorDoesNotHaveItem"
            end
        end)
        ```

    Returns:
        boolean|nil, string|nil, any
            Return false to block the trade. Additional return values may supply a localized reason and optional format parameter.

    Realm:
        Server
]]
--[[
    Hooks:
        GetPriceOverride(client, vendor, uniqueID, price, isSellingToVendor)

    Purpose:
        Allows code to override a vendor trade price for a player.

    Category:
        Vendor

    Parameters:
        client (Player)
            The player receiving the quoted price.

        vendor (Entity)
            The vendor entity pricing the trade.

        uniqueID (string)
            The item unique ID being priced.

        price (number)
            The default calculated price.

        isSellingToVendor (boolean)
            Whether the player is selling to the vendor.

    Example Usage:
        ```lua
        hook.Add("GetPriceOverride", "liaExampleGetPriceOverride", function(client, vendor, uniqueID, price, isSellingToVendor)
            return (price or 0) + 5
        end)
        ```

    Returns:
        number|nil
            Return a replacement price.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)

    Purpose:
        Called after the vendor system processes a character trade attempt.

    Category:
        Vendor

    Parameters:
        client (Player)
            The player trading with the vendor.

        vendor (Entity)
            The vendor entity used for the trade.

        item (table|nil)
            The traded item instance when available.

        isSellingToVendor (boolean)
            Whether the player sold to the vendor.

        character (Character)
            The trading character.

        itemType (string|nil)
            The item unique ID involved in the trade when no item instance was created.

        isFailed (boolean|nil)
            Whether the trade attempt failed after validation.

    Example Usage:
        ```lua
        hook.Add("OnCharTradeVendor", "liaExampleOnCharTradeVendor", function(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled OnCharTradeVendor for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnVendorEdited(client, vendor, key)

    Purpose:
        Called after a player edits a vendor setting on the server.

    Category:
        Vendor

    Parameters:
        client (Player)
            The player who edited the vendor.

        vendor (Entity)
            The vendor that was edited.

        key (string)
            The edited property key.

    Example Usage:
        ```lua
        hook.Add("OnVendorEdited", "liaExampleOnVendorEdited", function(client, vendor, key)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled OnVendorEdited for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerAccessVendor(client, vendor)

    Purpose:
        Called after a player is granted access to a vendor and the open packets are sent.

    Category:
        Vendor

    Parameters:
        client (Player)
            The player opening the vendor.

        vendor (Entity)
            The vendor entity being opened.

    Example Usage:
        ```lua
        hook.Add("PlayerAccessVendor", "liaExamplePlayerAccessVendor", function(client, vendor)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled PlayerAccessVendor for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        VendorClassUpdated(vendor, id, allowed)

    Purpose:
        Called on the client after a vendor class whitelist entry changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        id (number)
            The class index that changed.

        allowed (boolean)
            Whether the class is now allowed.

    Example Usage:
        ```lua
        hook.Add("VendorClassUpdated", "liaExampleVendorClassUpdated", function(vendor, id, allowed)
            print("[MyModule] handled VendorClassUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorEdited(vendor, key)

    Purpose:
        Called on the client after a vendor edit synchronization updates a field.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The edited vendor.

        key (string)
            The property key that changed.

    Example Usage:
        ```lua
        hook.Add("VendorEdited", "liaExampleVendorEdited", function(vendor, key)
            print("[MyModule] handled VendorEdited")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorFactionBuyScaleUpdated(vendor, factionID, scale)

    Purpose:
        Called on the client after a faction buy scale changes for a vendor.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        factionID (number)
            The faction index whose buy scale changed.

        scale (number)
            The new buy scale value.

    Example Usage:
        ```lua
        hook.Add("VendorFactionBuyScaleUpdated", "liaExampleVendorFactionBuyScaleUpdated", function(vendor, factionID, scale)
            print("[MyModule] handled VendorFactionBuyScaleUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorFactionSellScaleUpdated(vendor, factionID, scale)

    Purpose:
        Called on the client after a faction sell scale changes for a vendor.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        factionID (number)
            The faction index whose sell scale changed.

        scale (number)
            The new sell scale value.

    Example Usage:
        ```lua
        hook.Add("VendorFactionSellScaleUpdated", "liaExampleVendorFactionSellScaleUpdated", function(vendor, factionID, scale)
            print("[MyModule] handled VendorFactionSellScaleUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorFactionUpdated(vendor, id, allowed)

    Purpose:
        Called on the client after a vendor faction whitelist entry changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        id (number)
            The faction index that changed.

        allowed (boolean)
            Whether the faction is now allowed.

    Example Usage:
        ```lua
        hook.Add("VendorFactionUpdated", "liaExampleVendorFactionUpdated", function(vendor, id, allowed)
            print("[MyModule] handled VendorFactionUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorItemBuyPriceUpdated(vendor, itemType, value)

    Purpose:
        Called on the client after a vendor item buy price changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new buy price.

    Example Usage:
        ```lua
        hook.Add("VendorItemBuyPriceUpdated", "liaExampleVendorItemBuyPriceUpdated", function(vendor, itemType, value)
            print("[MyModule] handled VendorItemBuyPriceUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorItemMaxStockUpdated(vendor, itemType, value)

    Purpose:
        Called on the client after a vendor item max stock value changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new max stock value.

    Example Usage:
        ```lua
        hook.Add("VendorItemMaxStockUpdated", "liaExampleVendorItemMaxStockUpdated", function(vendor, itemType, value)
            print("[MyModule] handled VendorItemMaxStockUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorItemModeUpdated(vendor, itemType, value)

    Purpose:
        Called on the client after a vendor item trade mode changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new vendor trade mode.

    Example Usage:
        ```lua
        hook.Add("VendorItemModeUpdated", "liaExampleVendorItemModeUpdated", function(vendor, itemType, value)
            print("[MyModule] handled VendorItemModeUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorItemSellPriceUpdated(vendor, itemType, value)

    Purpose:
        Called on the client after a vendor item sell price changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new sell price.

    Example Usage:
        ```lua
        hook.Add("VendorItemSellPriceUpdated", "liaExampleVendorItemSellPriceUpdated", function(vendor, itemType, value)
            print("[MyModule] handled VendorItemSellPriceUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorItemStockUpdated(vendor, itemType, value)

    Purpose:
        Called on the client after a vendor item stock count changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new stock count.

    Example Usage:
        ```lua
        hook.Add("VendorItemStockUpdated", "liaExampleVendorItemStockUpdated", function(vendor, itemType, value)
            print("[MyModule] handled VendorItemStockUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorMessagesUpdated(vendor)

    Purpose:
        Called on the client after a vendor's message table is synchronized.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

    Example Usage:
        ```lua
        hook.Add("VendorMessagesUpdated", "liaExampleVendorMessagesUpdated", function(vendor)
            print("[MyModule] handled VendorMessagesUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorPropertyUpdated(vendor, propertyName, propertyValue)

    Purpose:
        Called on the client after a synchronized vendor property changes.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The updated vendor.

        propertyName (string)
            The property key that changed.

        propertyValue (any)
            The synchronized property value.

    Example Usage:
        ```lua
        hook.Add("VendorPropertyUpdated", "liaExampleVendorPropertyUpdated", function(vendor, propertyName, propertyValue)
            print("[MyModule] handled VendorPropertyUpdated")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorSynchronized(vendor)

    Purpose:
        Called on the client after a full vendor sync packet is applied.

    Category:
        Vendor

    Parameters:
        vendor (Entity)
            The vendor that was synchronized.

    Example Usage:
        ```lua
        hook.Add("VendorSynchronized", "liaExampleVendorSynchronized", function(vendor)
            print("[MyModule] handled VendorSynchronized")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorTradeEvent(client, vendor, itemType, isSellingToVendor)

    Purpose:
        Called when the vendor system begins processing a buy or sell transaction.

    Category:
        Vendor

    Parameters:
        client (Player)
            The player trading with the vendor.

        vendor (Entity)
            The vendor handling the trade.

        itemType (string)
            The item unique ID being traded.

        isSellingToVendor (boolean)
            Whether the player is selling to the vendor.

    Example Usage:
        ```lua
        hook.Add("VendorTradeEvent", "liaExampleVendorTradeEvent", function(client, vendor, itemType, isSellingToVendor)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled VendorTradeEvent for %s", client:Name()))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
MODULE.name = "@vendor"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@npcVendorDescription"
MODULE.NetworkStrings = {"liaVendorAllowClass", "liaVendorAllowFaction", "liaVendorBuyPrice", "liaVendorDeletePreset", "liaVendorExit", "liaVendorFaction", "liaVendorFactionBuyScale", "liaVendorFactionSellScale", "liaVendorInitialSync", "liaVendorLoadPreset", "liaVendorMaxStock", "liaVendorMode", "liaVendorOpen", "liaVendorRequestData", "liaVendorSavePreset", "liaVendorSellPrice", "liaVendorStock", "liaVendorSync", "liaVendorSyncMessages", "liaVendorTrade",}
MODULE.Privileges = {
    ["canEditVendors"] = {
        Name = "@canEditVendors",
        MinAccess = "superadmin",
        Category = "@vendors",
    },
    ["canCreateVendorPresets"] = {
        Name = "@canCreateVendorPresets",
        MinAccess = "admin",
        Category = "@vendors",
    },
}

VENDOR_WELCOME = 1
VENDOR_LEAVE = 2
VENDOR_NOTRADE = 3
VENDOR_PRICE = 1
VENDOR_STOCK = 2
VENDOR_MODE = 3
VENDOR_MAXSTOCK = 4
VENDOR_BUYPRICE = 5
VENDOR_SELLPRICE = 6
VENDOR_SELLANDBUY = 1
VENDOR_SELLONLY = 2
VENDOR_BUYONLY = 3
