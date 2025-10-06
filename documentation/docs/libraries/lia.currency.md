# Currency Library

This page documents the functions for working with currency and money management.

---

## Overview

The currency library (`lia.currency`) provides a comprehensive system for managing in-game currency, money spawning, and currency-related operations in the Lilia framework, serving as the core economic system that enables realistic and engaging monetary transactions and economic gameplay throughout the server. This library handles sophisticated currency management with support for multiple currency types, complex transaction processing, and dynamic currency spawning that creates realistic economic systems and meaningful financial progression. The system features advanced money management with support for secure transactions, currency validation, and comprehensive economic tracking that ensures balanced and fair economic gameplay for all players. It includes comprehensive currency spawning with support for dynamic money creation, currency distribution, and economic event integration that enables rich economic scenarios and player-driven market dynamics. The library provides robust currency operations with support for money transfers, currency conversion, and comprehensive financial logging that maintains economic integrity and provides detailed transaction records. Additional features include integration with the framework's character system for personal finances, performance optimization for high-frequency transactions, and comprehensive administrative tools that enable effective economic management and provide powerful financial control capabilities, making it essential for creating engaging economic systems that enhance roleplay depth and provide meaningful financial progression opportunities for players.

---

### get

**Purpose**

Formats a currency amount with the appropriate symbol and singular/plural form.

**Parameters**

* `amount` (*number*): The amount of currency to format.

**Returns**

* `formatted` (*string*): The formatted currency string.

**Realm**

Shared.

**Example Usage**

```lua
-- Format a currency amount
local function formatMoney(amount)
    return lia.currency.get(amount)
end

-- Use in a function
local function showFormattedMoney(amount)
    local formatted = lia.currency.get(amount)
    print("You have " .. formatted)
end

-- Use in a display
local function showMoney(amount)
    local formatted = lia.currency.get(amount)
    draw.SimpleText(formatted, "liaMediumFont", 10, 10, Color(255, 255, 255))
end

-- Use in a command
lia.command.add("showmoney", {
    arguments = {
        {name = "amount", type = "number"}
    },
    onRun = function(client, arguments)
        local amount = tonumber(arguments[1])
        if amount then
            local formatted = lia.currency.get(amount)
            client:notify("Formatted amount: " .. formatted)
        end
    end
})
```

---

### spawn

**Purpose**

Spawns a money entity at the specified position.

**Parameters**

* `pos` (*Vector*): The position to spawn the money at.
* `amount` (*number*): The amount of money to spawn.
* `angle` (*Angle*, optional): The angle for the spawned money entity.

**Returns**

* `moneyEntity` (*Entity*): The spawned money entity or nil if spawning failed.

**Realm**

Server.

**Example Usage**

```lua
-- Spawn money at a position
local function spawnMoneyAt(pos, amount, angle)
    return lia.currency.spawn(pos, amount, angle)
end

-- Use in a function
local function dropMoney(client, amount)
    local pos = client:GetPos() + client:GetForward() * 50
    local angle = client:GetAngles()
    local money = lia.currency.spawn(pos, amount, angle)
    if money then
        client:notify("Dropped " .. lia.currency.get(amount))
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
            local angle = client:GetAngles()
            local money = lia.currency.spawn(pos, amount, angle)
            if money then
                client:notify("Dropped " .. lia.currency.get(amount))
            else
                client:notify("Failed to drop money")
            end
        else
            client:notify("Invalid amount")
        end
    end
})

-- Use in a timer
timer.Create("SpawnMoney", 60, 0, function()
    local pos = Vector(math.random(-1000, 1000), math.random(-1000, 1000), 0)
    local angle = Angle(0, math.random(0, 360), 0)
    lia.currency.spawn(pos, math.random(10, 100), angle)
end)
```