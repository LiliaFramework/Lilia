# Currency Library

This page documents the functions for working with currency and money management.

---

## Overview

The currency library (`lia.currency`) provides a comprehensive system for managing in-game currency, money spawning, and currency-related operations in the Lilia framework. It includes currency spawning, money management, and currency display functionality.

---

### lia.currency.get

**Purpose**

Gets the current currency symbol.

**Parameters**

*None*

**Returns**

* `symbol` (*string*): The currency symbol.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the currency symbol
local function getCurrencySymbol()
    return lia.currency.get()
end

-- Use in a function
local function formatMoney(amount)
    local symbol = lia.currency.get()
    return symbol .. amount
end

-- Use in a display
local function showMoney(amount)
    local symbol = lia.currency.get()
    draw.SimpleText(symbol .. amount, "liaMediumFont", 10, 10, Color(255, 255, 255))
end

-- Use in a command
lia.command.add("showmoney", {
    onRun = function(client, arguments)
        local symbol = lia.currency.get()
        local money = client:getChar():getMoney()
        client:notify("You have " .. symbol .. money)
    end
})
```

---

### lia.currency.spawn

**Purpose**

Spawns a money entity at the specified position.

**Parameters**

* `position` (*Vector*): The position to spawn the money at.
* `amount` (*number*): The amount of money to spawn.

**Returns**

* `moneyEntity` (*Entity*): The spawned money entity.

**Realm**

Server.

**Example Usage**

```lua
-- Spawn money at a position
local function spawnMoneyAt(pos, amount)
    return lia.currency.spawn(pos, amount)
end

-- Use in a function
local function dropMoney(client, amount)
    local pos = client:GetPos() + client:GetForward() * 50
    local money = lia.currency.spawn(pos, amount)
    if money then
        client:notify("Dropped " .. lia.currency.get() .. amount)
    end
end

-- Use in a command
lia.command.add("dropmoney", {
    arguments = {
        {name = "amount", type = "number"}
    },
    onRun = function(client, arguments)
        local amount = tonumber(arguments[1])
        if amount and amount > 0 then
            local pos = client:GetPos() + client:GetForward() * 50
            lia.currency.spawn(pos, amount)
            client:notify("Dropped " .. lia.currency.get() .. amount)
        else
            client:notify("Invalid amount")
        end
    end
})

-- Use in a timer
timer.Create("SpawnMoney", 60, 0, function()
    local pos = Vector(math.random(-1000, 1000), math.random(-1000, 1000), 0)
    lia.currency.spawn(pos, math.random(10, 100))
end)
```

---

### lia.currency.setSymbol

**Purpose**

Sets the currency symbol.

**Parameters**

* `symbol` (*string*): The new currency symbol.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set the currency symbol
local function setCurrencySymbol(symbol)
    lia.currency.setSymbol(symbol)
end

-- Use in a function
local function changeCurrency(symbol)
    lia.currency.setSymbol(symbol)
    print("Currency symbol changed to: " .. symbol)
end

-- Use in a command
lia.command.add("setcurrency", {
    arguments = {
        {name = "symbol", type = "string"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.currency.setSymbol(arguments[1])
        client:notify("Currency symbol changed to: " .. arguments[1])
    end
})

-- Use in initialization
local function initializeCurrency()
    lia.currency.setSymbol("$")
    print("Currency initialized with symbol: $")
end
```

---

### lia.currency.format

**Purpose**

Formats a money amount with the currency symbol.

**Parameters**

* `amount` (*number*): The amount to format.

**Returns**

* `formattedString` (*string*): The formatted money string.

**Realm**

Shared.

**Example Usage**

```lua
-- Format money amount
local function formatMoney(amount)
    return lia.currency.format(amount)
end

-- Use in a function
local function displayMoney(amount)
    local formatted = lia.currency.format(amount)
    draw.SimpleText(formatted, "liaMediumFont", 10, 10, Color(255, 255, 255))
end

-- Use in a command
lia.command.add("showmoney", {
    onRun = function(client, arguments)
        local money = client:getChar():getMoney()
        local formatted = lia.currency.format(money)
        client:notify("You have " .. formatted)
    end
})

-- Use in a function
local function createMoneyDisplay(amount)
    local formatted = lia.currency.format(amount)
    local label = vgui.Create("DLabel")
    label:SetText(formatted)
    return label
end
```

---

### lia.currency.add

**Purpose**

Adds money to a character.

**Parameters**

* `character` (*Character*): The character to add money to.
* `amount` (*number*): The amount to add.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add money to a character
local function addMoney(character, amount)
    lia.currency.add(character, amount)
end

-- Use in a function
local function giveMoney(client, amount)
    local character = client:getChar()
    if character then
        lia.currency.add(character, amount)
        client:notify("Received " .. lia.currency.format(amount))
    end
end

-- Use in a command
lia.command.add("givemoney", {
    arguments = {
        {name = "player", type = "string"},
        {name = "amount", type = "number"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local amount = tonumber(arguments[2])
            if amount and amount > 0 then
                local character = target:getChar()
                if character then
                    lia.currency.add(character, amount)
                    client:notify("Gave " .. lia.currency.format(amount) .. " to " .. target:Name())
                end
            else
                client:notify("Invalid amount")
            end
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a timer
timer.Create("GiveMoney", 300, 0, function()
    for _, client in ipairs(player.GetAll()) do
        local character = client:getChar()
        if character then
            lia.currency.add(character, 100)
        end
    end
end)
```

---

### lia.currency.remove

**Purpose**

Removes money from a character.

**Parameters**

* `character` (*Character*): The character to remove money from.
* `amount` (*number*): The amount to remove.

**Returns**

* `success` (*boolean*): True if the money was removed successfully.

**Realm**

Server.

**Example Usage**

```lua
-- Remove money from a character
local function removeMoney(character, amount)
    return lia.currency.remove(character, amount)
end

-- Use in a function
local function takeMoney(client, amount)
    local character = client:getChar()
    if character then
        local success = lia.currency.remove(character, amount)
        if success then
            client:notify("Lost " .. lia.currency.format(amount))
        else
            client:notify("Not enough money")
        end
    end
end

-- Use in a command
lia.command.add("takemoney", {
    arguments = {
        {name = "player", type = "string"},
        {name = "amount", type = "number"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local amount = tonumber(arguments[2])
            if amount and amount > 0 then
                local character = target:getChar()
                if character then
                    local success = lia.currency.remove(character, amount)
                    if success then
                        client:notify("Took " .. lia.currency.format(amount) .. " from " .. target:Name())
                    else
                        client:notify("Player doesn't have enough money")
                    end
                end
            else
                client:notify("Invalid amount")
            end
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function payForItem(client, item, price)
    local character = client:getChar()
    if character then
        local success = lia.currency.remove(character, price)
        if success then
            character:getInv():add(item)
            client:notify("Purchased " .. item.name .. " for " .. lia.currency.format(price))
        else
            client:notify("Not enough money")
        end
    end
end
```

---

### lia.currency.get

**Purpose**

Gets the money amount for a character.

**Parameters**

* `character` (*Character*): The character to get money from.

**Returns**

* `amount` (*number*): The money amount.

**Realm**

Shared.

**Example Usage**

```lua
-- Get money amount for a character
local function getMoney(character)
    return lia.currency.get(character)
end

-- Use in a function
local function showMoney(client)
    local character = client:getChar()
    if character then
        local money = lia.currency.get(character)
        client:notify("You have " .. lia.currency.format(money))
    end
end

-- Use in a command
lia.command.add("checkmoney", {
    arguments = {
        {name = "player", type = "string"}
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local character = target:getChar()
            if character then
                local money = lia.currency.get(character)
                client:notify(target:Name() .. " has " .. lia.currency.format(money))
            end
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function createMoneyDisplay(character)
    local money = lia.currency.get(character)
    local formatted = lia.currency.format(money)
    local label = vgui.Create("DLabel")
    label:SetText(formatted)
    return label
end
```

---

### lia.currency.set

**Purpose**

Sets the money amount for a character.

**Parameters**

* `character` (*Character*): The character to set money for.
* `amount` (*number*): The amount to set.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set money amount for a character
local function setMoney(character, amount)
    lia.currency.set(character, amount)
end

-- Use in a function
local function resetMoney(client, amount)
    local character = client:getChar()
    if character then
        lia.currency.set(character, amount)
        client:notify("Money set to " .. lia.currency.format(amount))
    end
end

-- Use in a command
lia.command.add("setmoney", {
    arguments = {
        {name = "player", type = "string"},
        {name = "amount", type = "number"}
    },
    privilege = "Admin Access",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local amount = tonumber(arguments[2])
            if amount and amount >= 0 then
                local character = target:getChar()
                if character then
                    lia.currency.set(character, amount)
                    client:notify("Set " .. target:Name() .. "'s money to " .. lia.currency.format(amount))
                end
            else
                client:notify("Invalid amount")
            end
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function giveStartingMoney(character)
    lia.currency.set(character, 1000)
    print("Starting money given to character")
end
```

---

### lia.currency.transfer

**Purpose**

Transfers money from one character to another.

**Parameters**

* `fromCharacter` (*Character*): The character to transfer money from.
* `toCharacter` (*Character*): The character to transfer money to.
* `amount` (*number*): The amount to transfer.

**Returns**

* `success` (*boolean*): True if the transfer was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Transfer money between characters
local function transferMoney(fromCharacter, toCharacter, amount)
    return lia.currency.transfer(fromCharacter, toCharacter, amount)
end

-- Use in a function
local function payPlayer(client, target, amount)
    local fromCharacter = client:getChar()
    local toCharacter = target:getChar()
    if fromCharacter and toCharacter then
        local success = lia.currency.transfer(fromCharacter, toCharacter, amount)
        if success then
            client:notify("Paid " .. lia.currency.format(amount) .. " to " .. target:Name())
            target:notify("Received " .. lia.currency.format(amount) .. " from " .. client:Name())
        else
            client:notify("Not enough money")
        end
    end
end

-- Use in a command
lia.command.add("pay", {
    arguments = {
        {name = "player", type = "string"},
        {name = "amount", type = "number"}
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target then
            local amount = tonumber(arguments[2])
            if amount and amount > 0 then
                local fromCharacter = client:getChar()
                local toCharacter = target:getChar()
                if fromCharacter and toCharacter then
                    local success = lia.currency.transfer(fromCharacter, toCharacter, amount)
                    if success then
                        client:notify("Paid " .. lia.currency.format(amount) .. " to " .. target:Name())
                        target:notify("Received " .. lia.currency.format(amount) .. " from " .. client:Name())
                    else
                        client:notify("Not enough money")
                    end
                end
            else
                client:notify("Invalid amount")
            end
        else
            client:notify("Player not found")
        end
    end
})

-- Use in a function
local function createPaymentSystem(fromCharacter, toCharacter, amount)
    local success = lia.currency.transfer(fromCharacter, toCharacter, amount)
    if success then
        print("Payment successful")
    else
        print("Payment failed")
    end
    return success
end
```