# Meta

Convenience helpers for playing handcuff animations and player state management.

---

### Player:IsHandcuffed

**Purpose**

Returns whether the player is currently handcuffed/restrained.

**Parameters**

*None*

**Realm**

Shared

**Returns**

`boolean` — `true` if the player is handcuffed, `false` otherwise

**Example**

```lua
if target:IsHandcuffed() then
    -- Player is restrained
end
```

---

### Player:StartHandcuffAnim

**Purpose**

Plays the networked arm pose that visually handcuffs the player.

**Parameters**

*None*

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:StartHandcuffAnim()
```

---

### Player:EndHandcuffAnim

**Purpose**

Stops the handcuff animation and resets the player's pose.

**Parameters**

*None*

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:EndHandcuffAnim()
```

---

### Player:IsBeingSearched

**Purpose**

Returns whether the player is currently being searched by another player.

**Parameters**

*None*

**Realm**

Shared

**Returns**

`Player|nil` — The player searching this player, or `nil` if not being searched

**Example**

```lua
if target:IsBeingSearched() then
    -- Player is being searched
end
```

---

