# Hooks

Module-specific events raised by the Simple Cutscenes module.

---

### `CutsceneStarted`

**Purpose**

Fired when a cutscene begins running. On the server it is called for every player that will view the cutscene.

**Parameters**

* `player` (`Player`): Player who started viewing the cutscene. *(Server only)*

* `id` (`string`): Identifier of the cutscene. On the client this is the sole parameter.

**Realm**

`Client & Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CutsceneStarted", "AnnounceCutscene", function(ply, id)
    print("Cutscene " .. id .. " started")
end)
```

---

### `CutsceneEnded`

**Purpose**

Called on the client once the cutscene has fully finished.

**Parameters**

* `id` (`string`): Identifier of the cutscene.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CutsceneEnded", "FadeOut", function(id)
    print("Cutscene " .. id .. " ended")
end)
```

---

### `CutsceneSceneStarted`

**Purpose**

Runs when a scene within the current cutscene begins.

**Parameters**

* `id` (`string`): Identifier of the cutscene.

* `scene` (`table`): Table describing the scene.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CutsceneSceneStarted", "Music", function(id, scene)
    if scene.sound then print("Playing " .. scene.sound) end
end)
```

---

### `CutsceneSceneEnded`

**Purpose**

Called after a scene finishes playing.

**Parameters**

* `id` (`string`): Identifier of the cutscene.

* `scene` (`table`): Table describing the scene.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CutsceneSceneEnded", "SceneDone", function(id, scene)
    print("Scene finished")
end)
```

---

### `CutsceneSubtitleStarted`

**Purpose**

Triggered whenever a subtitle line is displayed.

**Parameters**

* `id` (`string`): Identifier of the cutscene.

* `subtitle` (`table`): Subtitle information table.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CutsceneSubtitleStarted", "Subtitle", function(id, sub)
    print(sub.text)
end)
```

---

