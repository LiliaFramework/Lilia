# Currency Library

This page documents the functions for working with currency and money management.

---

## Overview

The currency library (`lia.currency`) provides a comprehensive system for managing in-game currency, money spawning, and currency-related operations in the Lilia framework, serving as the core economic system that enables realistic and engaging monetary transactions and economic gameplay throughout the server. This library handles sophisticated currency management with support for multiple currency types, complex transaction processing, and dynamic currency spawning that creates realistic economic systems and meaningful financial progression. The system features advanced money management with support for secure transactions, currency validation, and comprehensive economic tracking that ensures balanced and fair economic gameplay for all players. It includes comprehensive currency spawning with support for dynamic money creation, currency distribution, and economic event integration that enables rich economic scenarios and player-driven market dynamics. The library provides robust currency operations with support for money transfers, currency conversion, and comprehensive financial logging that maintains economic integrity and provides detailed transaction records. Additional features include integration with the framework's character system for personal finances, performance optimization for high-frequency transactions, and comprehensive administrative tools that enable effective economic management and provide powerful financial control capabilities, making it essential for creating engaging economic systems that enhance roleplay depth and provide meaningful financial progression opportunities for players.

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

