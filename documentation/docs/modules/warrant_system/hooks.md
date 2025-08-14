# Hooks

Module-specific events raised by the Warrant System module.

---

### `PreWarrantToggle`

**Purpose**

`Called just before a character's warrant status is changed.`

**Parameters**

* `character` (`Character`): `Character whose warrant state is toggling.`

* `warranter` (`Player`): `Player issuing or removing the warrant.`

* `warranted` (`boolean`): `Whether the character is becoming warranted.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PreWarrantToggle", "LogAttempt", function(char, warranter, warranted)
    print("Warrant change for " .. char:getName())
end)
```

---

### `WarrantStatusChanged`

**Purpose**

`Fires immediately after the warrant flag is updated.`

**Parameters**

* `character` (`Character`): `Character that had their warrant status updated.`

* `warranter` (`Player`): `Player responsible for the change.`

* `warranted` (`boolean`): `Current warrant status.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("WarrantStatusChanged", "NotifyAdmins", function(char, warranter, warranted)
    if warranted then
        PrintMessage(HUD_PRINTTALK, char:getName() .. " is now warranted")
    end
end)
```

---

### `PostWarrantToggle`

**Purpose**

`Runs after notifications about a warrant have been sent.`

**Parameters**

* `character` (`Character`): `Character that was affected.`

* `warranter` (`Player`): `Player who issued or cleared the warrant.`

* `warranted` (`boolean`): `Whether the warrant is active after the change.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PostWarrantToggle", "Cleanup", function(char, warranter, warranted)
    if not warranted then
        -- custom cleanup here
    end
end)
```

---


