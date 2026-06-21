--[[
    Hooks:
        CanPlayerAccessVendor(client, vendor)

    Purpose:
        Determines whether a player may open or continue using a vendor.

    Parameters:
        client (Player)
            The player attempting to access the vendor.

        vendor (Entity)
            The vendor entity being accessed.

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

    Parameters:
        client (Player)
            The player attempting the trade.

        vendor (Entity)
            The vendor handling the trade.

        itemType (string)
            The item unique ID being traded.

        isSellingToVendor (boolean)
            Whether the player is selling the item to the vendor instead of buying it.

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

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnOpenVendorMenu(panelOwner, vendor)

    Purpose:
        Called on the client after the vendor UI is created.

    Parameters:
        panelOwner (table)
            The vendor module instance opening the UI.

        vendor (Entity)
            The vendor entity being shown.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        OnVendorEdited(client, vendor, key)

    Purpose:
        Called after a player edits a vendor setting on the server.

    Parameters:
        client (Player)
            The player who edited the vendor.

        vendor (Entity)
            The vendor that was edited.

        key (string)
            The edited property key.

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

    Parameters:
        client (Player)
            The player opening the vendor.

        vendor (Entity)
            The vendor entity being opened.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        id (number)
            The class index that changed.

        allowed (boolean)
            Whether the class is now allowed.

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

    Parameters:
        vendor (Entity)
            The edited vendor.

        key (string)
            The property key that changed.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorExited()

    Purpose:
        Called on the client after the vendor UI is closed by a networked exit event.

    Parameters:
        None

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        factionID (number)
            The faction index whose buy scale changed.

        scale (number)
            The new buy scale value.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        factionID (number)
            The faction index whose sell scale changed.

        scale (number)
            The new sell scale value.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        id (number)
            The faction index that changed.

        allowed (boolean)
            Whether the faction is now allowed.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new buy price.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new max stock value.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new vendor trade mode.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new sell price.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        itemType (string)
            The affected item unique ID.

        value (number)
            The new stock count.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        VendorOpened(vendor)

    Purpose:
        Called on the client after vendor access opens the vendor UI.

    Parameters:
        vendor (Entity)
            The vendor entity that was opened.

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

    Parameters:
        vendor (Entity)
            The updated vendor.

        propertyName (string)
            The property key that changed.

        propertyValue (any)
            The synchronized property value.

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

    Parameters:
        vendor (Entity)
            The vendor that was synchronized.

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

    Parameters:
        client (Player)
            The player trading with the vendor.

        vendor (Entity)
            The vendor handling the trade.

        itemType (string)
            The item unique ID being traded.

        isSellingToVendor (boolean)
            Whether the player is selling to the vendor.

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