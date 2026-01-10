--[[
    Folder: Hooks
    File:  server.md
]]
--[[
    Server-Side Hooks

    Server-side hook system for the Lilia framework.
    These hooks run on the server and are used for server-side logic, data management, and game state handling.
]]
--[[
    Overview:
        Server-side hooks in the Lilia framework handle server-side logic, data persistence, permissions, character management, and other server-specific functionality. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.
]]
--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanItemBeTransfered(item, inventory, VendorInventoryMeasure, client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPersistEntity(entity)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerAccessDoor(client, door, access)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerAccessVendor(client, vendor)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerDropItem(client, item)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerEarnSalary(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerEquipItem(client, item)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerHoldObject(client, entity)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerInteractItem(client, action, item, data)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerLock(client, door)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerSeeLogCategory(client, category)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerSpawnStorage(client, entity, info)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerSwitchChar(client, currentCharacter, newCharacter)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerTakeItem(client, item)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerUnequipItem(client, item)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerUnlock(client, door)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerUseChar(client, character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanPlayerUseDoor(client, door)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CanSaveData(ent, inventory)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CharCleanUp(character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CharDeleted(client, character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CharListExtraDetails(client, entry, stored)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CharPostSave(character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CharPreSave(character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function CheckFactionLimitReached(faction, character, client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DatabaseConnected()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DiscordRelaySend(embed)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DiscordRelayUnavailable()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DiscordRelayed(embed)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DoorEnabledToggled(client, door, newState)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DoorHiddenToggled(client, entity, newState)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DoorLockToggled(client, door, state)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DoorOwnableToggled(client, door, newState)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DoorPriceSet(client, door, price)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function DoorTitleSet(client, door, name)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function FetchSpawns()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetAllCaseClaims()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetBotModel(client, faction)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetDamageScale(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetDefaultInventoryType(character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetEntitySaveData(ent)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetOOCDelay(speaker)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetPlayTime(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetPlayerDeathSound(client, isFemale)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetPlayerPainSound(client, paintype, isFemale)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetPlayerRespawnLocation(client, character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetPlayerSpawnLocation(client, character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetPrestigePayBonus(client, char, pay, faction, class)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetSalaryAmount(client, faction, class)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetTicketsByRequester(steamID)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetWarnings(charID)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function GetWarningsByIssuer(steamID)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function HandleItemTransferRequest(client, itemID, x, y, invID)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function InventoryDeleted(instance)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ItemCombine(client, item, target)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ItemDeleted(instance)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ItemFunctionCalled(item, method, client, entity, results)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ItemTransfered(context)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function KeyLock(client, door, time)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function KeyUnlock(client, door, time)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function KickedFromChar(characterID, isCurrentChar)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function LiliaTablesLoaded()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function LoadData()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ModifyCharacterModel(arg1, character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharAttribBoosted(client, character, attribID, boostID, arg5)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharAttribUpdated(client, character, key, arg4)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharCreated(client, character, originalData)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharDelete(client, id)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharDisconnect(client, character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharFlagsGiven(ply, character, addedFlags)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharFlagsTaken(ply, character, removedFlags)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharKick(character, client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharNetVarChanged(character, key, oldVar, value)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharPermakilled(character, time)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharRecognized(client, arg2)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnCheaterCaught(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnDataSet(key, value, gamemode, map)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnDatabaseLoaded()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnDeathSoundPlayed(client, deathSound)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnEntityLoaded(ent, data)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnEntityPersistUpdated(ent, data)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnEntityPersisted(ent, entData)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnItemSpawned(itemEntity)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnLoadTables()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnNPCTypeSet(client, npc, npcID, filteredData)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnOOCMessageSent(client, message)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPainSoundPlayed(entity, painSound)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPickupMoney(activator, moneyEntity)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerEnterSequence(client, sequenceName, callback, time, noFreeze)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerInteractItem(client, action, item, result, data)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerJoinClass(target, arg2, oldClass)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerLeaveSequence(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerLostStackItem(itemTypeOrItem)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerObserve(client, state)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerRagdolled(client, ragdoll)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnPlayerSwitchClass(client, class, oldClass)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnRequestItemTransfer(inventoryPanel, itemID, targetInventoryID, x, y)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnSalaryAdjust(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnSalaryGiven(client, char, pay, faction, class)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnSavedItemLoaded(loadedItems)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnServerLog(client, logType, logString, category)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnTicketClaimed(client, requester, ticketMessage)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnTicketClosed(client, requester, ticketMessage)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnTicketCreated(noob, message)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnUsergroupPermissionsChanged(groupName, arg2)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnVendorEdited(client, vendor, key)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OnVoiceTypeChanged(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function OptionReceived(arg1, key, value)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerAccessVendor(client, vendor)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerCheatDetected(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerGagged(target, admin)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerLiliaDataLoaded(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerModelChanged(client, value)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerMuted(target, admin)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerShouldPermaKill(client, inflictor, attacker)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerSpawnPointSelected(client, pos, ang)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerStaminaGained(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerStaminaLost(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerUngagged(target, admin)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerUnmuted(target, admin)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PlayerUseDoor(client, door)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PostDoorDataLoad(ent, doorData)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PostLoadData()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PostPlayerInitialSpawn(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PostPlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PostPlayerLoadout(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PostPlayerSay(client, message, chatType, anonymous)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PostScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PreCharDelete(id)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PreDoorDataSave(door, doorData)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PrePlayerInteractItem(client, action, item)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PrePlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PreSalaryGive(client, char, pay, faction, class)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function PreScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function RemoveWarning(charID, index)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function SaveData()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function SendPopup(noob, message)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function SetupBotPlayer(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function SetupDatabase()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function SetupPlayerModel(modelEntity, character)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ShouldDataBeSaved()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ShouldDeleteSavedItems()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ShouldPlayDeathSound(client, deathSound)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ShouldPlayPainSound(entity, painSound)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ShouldSpawnClientRagdoll(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function StorageCanTransferItem(client, storage, item)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function StorageEntityRemoved(storageEntity, inventory)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function StorageInventorySet(entity, inventory, isCar)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function StorageItemRemoved()
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function StorageRestored(ent, inventory)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function StoreSpawns(spawns)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function SyncCharList(client)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function TicketSystemClaim(client, requester, ticketMessage)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function TicketSystemClose(client, requester, ticketMessage)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function ToggleLock(client, door, state)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function UpdateEntityPersistence(vendor)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorClassUpdated(vendor, id, allowed)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorEdited(liaVendorEnt, key)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorFactionBuyScaleUpdated(vendor, factionID, scale)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorFactionSellScaleUpdated(vendor, factionID, scale)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorFactionUpdated(vendor, id, allowed)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorItemMaxStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorItemModeUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorItemPriceUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorItemStockUpdated(vendor, itemType, value)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorMessagesUpdated(vendor)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorSynchronized(vendor)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function WarningIssued(client, target, reason, severity, count, warnerSteamID, targetSteamID)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function WarningRemoved(client, targetClient, arg3, arg4, arg5, arg6)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function setData(value, global, ignoreMap)
end

--[[
    Purpose:
        <Brief, clear description of what the function does.>

    When Called:
        <Describe when and why this function is invoked.>

    Parameters:
        <paramName> (<type>)
            <Description.>

    Returns:
        <returnType>
            <Description or "nil".>

    Realm:
        <Client | Server | Shared>

    Example Usage:
        ```lua
            <High Complexity and well documented Function Call Or Use Case Here>
        ```
]]
function syncVendorDataToClient(client)
end