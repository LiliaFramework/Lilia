# Function-Level Documentation Standard

## 1 · Header

```
### FunctionName
```

*Exactly three hash symbols (`###`) followed by the function name and empty parentheses.
Do **not** list parameters here; they belong in **Parameters**.*

## 2 · Description

*A single, precise sentence that states what the function does.*

## 3 · Parameters

List each argument on its own bullet:

* `argName` (`Type`) – Concise explanation of the argument’s role.

## 4 · Realm

One of:

* **Client**
* **Server**
* **Shared**

## 5 · Returns

* `ReturnType` – What the function yields.

## 6 · Examples

Provide one self-contained example of increasing complexity:

```lua
-- Basic usage
-- Advanced usage with extra logic
hook.Add("functionname", "functionname.Advanced", function()
    -- extensive involved code here
end)
```

---

## Copy-Paste Template

### FunctionName

**Description:**
\[One-sentence summary.]

**Parameters:**

* `argName` (`Type`) – Description.

**Realm:**
Client | Server | Shared

**Returns:**
`ReturnType` – Description.

**Examples:**

```lua
-- Example 1
-- …

-- Example 2
-- …
```

---

## Library-Specific Rules

1. **Namespace**
   Define all library functions under the `lia.*` namespace.

   ```lua
   function lia.abc.myUtility()
       -- implementation
   end
   ```

2. **Duplicate Fields**
   If a field is already documented in `docs/definitions`, remove its duplicate from library documentation.

---

### Usage Notes

* Use this standard for every entry under `/docs`.
* Each **Examples** block should contain **both** basic and advanced scenarios that are **complex and varied**.