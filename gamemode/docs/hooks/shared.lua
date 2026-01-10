--[[
    Folder: Hooks
    File:  shared.md
]]
--[[
    Shared Hooks

    Shared hook system for the Lilia framework.
    These hooks run on both client and server and are used for shared functionality and data synchronization.
]]
--[[
    Overview:
        Shared hooks in the Lilia framework handle functionality available on both client and server, typically for data synchronization, shared utilities, and cross-realm features. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.
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
function AdjustCreationData(client, data, newData, originalData)
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
function AdjustPACPartData(wearer, id, data)
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
function AdjustStaminaOffset(client, offset)
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
function AdvDupe_FinishPasting(tbl)
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
function AttachPart(client, id)
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
function BagInventoryReady(bagItem, inventory)
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
function BagInventoryRemoved(bagItem, inventory)
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
function CalcStaminaChange(client)
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
function CanCharBeTransfered(tChar, faction, arg3)
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
function CanInviteToClass(client, target)
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
function CanInviteToFaction(client, target)
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
function CanOutfitChangeModel(item)
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
function CanPerformVendorEdit(client, vendor)
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
function CanPickupMoney(activator, moneyEntity)
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
function CanPlayerChooseWeapon(weapon)
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
function CanPlayerCreateChar(client, data)
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
function CanPlayerJoinClass(client, class, info)
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
function CanPlayerKnock(arg1)
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
function CanPlayerModifyConfig(client, key)
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
function CanPlayerRotateItem(client, item)
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
function CanPlayerThrowPunch(client)
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
function CanPlayerUseCommand(client, command)
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
function CanRunItemAction(tempItem, key)
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
function CharForceRecognized(ply, range)
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
function CharHasFlags(client, flags)
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
function ChatParsed(client, chatType, message, anonymous)
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
function CommandAdded(command, data)
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
function ConfigChanged(key, value, oldValue, client)
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
function DoModuleIncludes(path, MODULE)
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
function ForceRecognizeRange(ply, range, fakeName)
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
function GetAttributeMax(client, id)
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
function GetAttributeStartingMax(client, attribute)
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
function GetCharMaxStamina(char)
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
function GetDefaultCharDesc(client, arg2, data)
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
function GetDefaultCharName(client, faction, data)
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
function GetDefaultInventorySize(client, char)
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
function GetDisplayedName(client, chatType)
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
function GetHandsAttackSpeed(arg1)
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
function GetItemDropModel(itemTable, itemEntity)
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
function GetMaxPlayerChar(client)
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
function GetMaxStartingAttributePoints(client, count)
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
function GetModelGender(model)
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
function GetMoneyModel(arg1)
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
function GetNPCDialogOptions(arg1)
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
function GetPlayerPunchDamage(arg1)
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
function GetPlayerPunchRagdollTime(arg1)
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
function GetPriceOverride(vendor, uniqueID, price, isSellingToVendor)
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
function GetRagdollTime(client, time)
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
function GetVendorSaleScale(vendor)
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
function GetWeaponName(weapon)
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
function InitializeStorage(entity)
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
function InitializedConfig()
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
function InitializedItems()
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
function InitializedKeybinds()
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
function InitializedModules()
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
function InitializedOptions()
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
function InitializedSchema()
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
function InventoryDataChanged(instance, key, oldValue, value)
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
function InventoryInitialized(instance)
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
function InventoryItemAdded(inventory, item)
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
function InventoryItemRemoved(inventory, instance, preserveItem)
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
function IsCharFakeRecognized(character, id)
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
function IsCharRecognized(a, arg2)
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
function IsRecognizedChatType(chatType)
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
function IsSuitableForTrunk(ent)
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
function ItemDataChanged(item, key, oldValue, newValue)
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
function ItemDefaultFunctions(arg1)
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
function ItemInitialized(item)
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
function ItemQuantityChanged(item, oldValue, quantity)
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
function LiliaLoaded()
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
function NetVarChanged(client, key, oldValue, value)
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
function OnAdminSystemLoaded(arg1, arg2)
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
function OnCharGetup(target, entity)
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
function OnCharVarChanged(character, varName, oldVar, newVar)
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
function OnConfigUpdated(key, oldValue, value)
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
function OnItemAdded(owner, item)
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
function OnItemCreated(itemTable, itemEntity)
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
function OnItemOverridden(item, overrides)
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
function OnItemRegistered(ITEM)
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
function OnLocalizationLoaded()
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
function OnPAC3PartTransfered(part)
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
function OnPlayerPurchaseDoor(client, door, arg3)
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
function OnPrivilegeRegistered(arg1, arg2, arg3, arg4)
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
function OnPrivilegeUnregistered(arg1, arg2)
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
function OnThemeChanged(themeName, useTransition)
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
function OnTransferred(target)
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
function OnUsergroupCreated(groupName, arg2)
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
function OnUsergroupRemoved(groupName)
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
function OnUsergroupRenamed(oldName, newName)
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
function OptionAdded(key, name, option)
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
function OptionChanged(key, old, value)
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
function OverrideFactionDesc(uniqueID, arg2)
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
function OverrideFactionModels(uniqueID, arg2)
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
function OverrideFactionName(uniqueID, arg2)
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
function OverrideSpawnTime(ply, baseTime)
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
function PlayerThrowPunch(client)
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
function PreLiliaLoaded()
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
function RemovePart(client, id)
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
function SetupBagInventoryAccessRules(inventory)
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
function SetupPACDataFromItems()
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
function getData(default)
end