---

# **Function-Level Documentation Standard**

> **Always place each section in the exact order shown below.
> Never omit a mandatory section, even if it is “None.”**

---

## 1. Header

```
### FunctionName
```

*Exactly three `#` symbols, one space, and the bare function name.
Do **not** include parameters here

---

## 2. Description

*A single, complete sentence describing precisely **what the function does** (action, not implementation).*

---

## 3. Parameters

> **Bullet each argument on its own line.**
> Format: `` `name` (`Type`) – concise role description ``

*Example:*

* `clientID` (`string`) – Unique identifier for the requesting player.
* `silent` (`boolean`) – If **true**, suppresses chat output.

---

## 4. Realm

*One of exactly these keywords (case-sensitive):*

* **Client** – Runs only on the client.
* **Server** – Runs only on the server.
* **Shared** – Accessible from both realms.

---

## 5. Returns

```
* `ReturnType` – Explanation of the yielded value, or **nil** if nothing is returned.
```

*Keep this a single bullet. Use `nil` literally when applicable.*

---

## 6. Example Usage

Wrap in a fenced Lua block. Provide **one** self-contained snippet that demonstrates:

1. **Basic usage** (minimal call).
2. **Advanced usage** featuring extra logic or hooks.

```lua
-- Basic usage
lia.example.doThing(clientID)

-- Advanced usage
hook.Add("ExampleEvent", "lia.example.doThing.Advanced", function(ply, data)
    if not IsValid(ply) then return end
    lia.example.doThing(ply:SteamID64(), {silent = true})
end)
```

---

# **Library-Specific Rules**

1. ### Namespace

   All public library functions live under `lia.`

   ```lua
   function lia.abc.myUtility(args)
       -- implementation
   end
   ```

2. ### Duplicate Fields

   If a field is already documented in `docs/definitions`, **remove** its duplicate from other docs to avoid conflicts.

---

## Usage Notes

* Apply this template to **every entry** under `/docs`.
* If a function is **internal** (e.g., `lia.module.load`) and not intended for routine external use, append an extra line after §6:

  ```
  **Note:** _Internal function. External use discouraged._
  ```

---

### Quick-Check List for Authors & Linters

| Rule                                          | Must Follow? |
| --------------------------------------------- | ------------ |
| Header uses `###`                             | ✅            |
| Description is one sentence                   | ✅            |
| Each parameter on its own bullet              | ✅            |
| Realm is one of **Client/Server/Shared**      | ✅            |
| Returns section always present                | ✅            |
| Example block shows both basic & advanced use | ✅            |
| Internal-only note added when relevant        | ✅            |
| Functions reside in `lia.*` namespace         | ✅            |
| No duplicates with `docs/definitions`         | ✅            |

---