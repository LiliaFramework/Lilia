# Hooks

Module-specific events raised by the Corpse Identification module.

---

### `RefreshFonts`

**Purpose**

Rebuilds fonts used for corpse identification displays when the configured font changes.

**Parameters**

* *(None)*

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("RefreshFonts", "UpdateCorpseFonts", function()
    surface.CreateFont("CorpseFont", {font = lia.config.get("CorpseMessageFont"), size = 32})
end)
```

---

### `CorpseIdentifyStarted`

**Purpose**

Fires when a player begins the corpse identification progress bar.

**Parameters**

* `client` (`Player`): Player performing the identification.

* `target` (`Player`): Player the corpse belongs to.

* `corpse` (`Entity`): The ragdoll entity.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CorpseIdentifyStarted", "NotifyAdmins", function(client, target)
    print(client:Nick() .. " is identifying " .. target:Nick())
end)
```

---

### `CorpseIdentified`

**Purpose**

Called after a corpse has been successfully identified.

**Parameters**

* `client` (`Player`): Player that identified the corpse.

* `target` (`Player`): Owner of the corpse.

* `corpse` (`Entity`): The ragdoll entity.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CorpseIdentified", "LogIdentification", function(ply, target)
    print(ply:Nick() .. " identified " .. target:Nick())
end)
```

---

### `CorpseIdentifyBegin`

**Purpose**

Triggered when the player agrees to identify a corpse.

**Parameters**

* `client` (`Player`): Player interacting with the corpse.

* `corpse` (`Entity`): The ragdoll entity.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CorpseIdentifyBegin", "PlaySound", function(client, corpse)
    client:EmitSound("buttons/button14.wav")
end)
```

---

### `CorpseIdentifyDeclined`

**Purpose**

Runs when a player chooses not to identify a corpse.

**Parameters**

* `client` (`Player`): The player who declined.

* `corpse` (`Entity`): The ragdoll entity.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CorpseIdentifyDeclined", "NotifyDecline", function(client)
    print(client:Nick() .. " declined to identify a corpse")
end)
```

---

### `CorpseCreated`

**Purpose**

Called when a ragdoll is created for a dead player.

**Parameters**

* `client` (`Player`): Player that died.

* `corpse` (`Entity`): The created ragdoll.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CorpseCreated", "StoreCorpse", function(client, corpse)
    print("Corpse created for " .. client:Name())
end)
```

---

