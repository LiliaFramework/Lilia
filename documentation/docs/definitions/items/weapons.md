# Weapons Item Definition

Weapon item system for the Lilia framework.

---

### name

**Example Usage**

```lua
ITEM.name = "Pistol"

```

---

### desc

**Example Usage**

```lua
ITEM.desc = "A standard issue pistol"

```

---

### category

**Example Usage**

```lua
ITEM.category = "weapons"

```

---

### model

**Example Usage**

```lua
ITEM.model = "models/weapons/w_pistol.mdl"

```

---

### class

**Example Usage**

```lua
ITEM.class = "weapon_pistol"

```

---

### width

**Example Usage**

```lua
ITEM.width = 2  -- Takes 2 slot width

```

---

### height

**Example Usage**

```lua
ITEM.height = 2  -- Takes 2 slot height

```

---

### isWeapon

**Example Usage**

```lua
ITEM.isWeapon = true

```

---

### RequiredSkillLevels

**Example Usage**

```lua
ITEM.RequiredSkillLevels = {}  -- No skill requirements

```

---

### DropOnDeath

**Example Usage**

```lua
ITEM.DropOnDeath = true  -- Drops on death

```

---

### postHooks

**Example Usage**

```lua
function ITEM.postHooks:drop()
    local client = self.player
    if not client or not IsValid(client) then return end
        if client:HasWeapon(self.class) then
            client:notifyErrorLocalized("invalidWeapon")
            client:StripWeapon(self.class)
        end
    end

```

---

### ITEM:hook("drop", function(item) ... end)

**Example Usage**

```lua
ITEM:hook("drop", function(item)
local client = item.player
if not client or not IsValid(client) then return false end
    if IsValid(client:getNetVar("ragdoll")) then
        client:notifyErrorLocalized("noRagdollAction")
        return false
    end
    -- Handle equipped weapon removal
end)

```

---

### ITEM:OnCanBeTransfered(_, newInventory)

**Example Usage**

```lua
function ITEM:OnCanBeTransfered(_, newInventory)
    if newInventory and self:getData("equip") then return false end
        return true
    end

```

---

### ITEM:onLoadout()

**Example Usage**

```lua
function ITEM:onLoadout()
    if self:getData("equip") then
        local client = self.player
        if not client or not IsValid(client) then return end
            local weapon = client:Give(self.class, true)
            if IsValid(weapon) then
                client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
                weapon:SetClip1(self:getData("ammo", 0))
                else
                    lia.error(L("weaponDoesNotExist", self.class))
                end
            end
        end

```

---

### ITEM:OnSave()

**Example Usage**

```lua
function ITEM:OnSave()
    local client = self.player
    if not client or not IsValid(client) then return end
        local weapon = client:GetWeapon(self.class)
        if IsValid(weapon) then self:setData("ammo", weapon:Clip1()) end
        end

```

---

### ITEM:getName()

**Example Usage**

```lua
function ITEM:getName()
    local weapon = weapons.GetStored(self.class)
    if weapon and weapon.PrintName then return language.GetPhrase(weapon.PrintName) end
        return self.name
    end

```

---

### Example Item:

**Example Usage**

```lua
-- Basic item identification
ITEM.name = "Pistol"                              -- Display name shown to players
ITEM.desc = "A standard issue pistol"             -- Description text
ITEM.category = "weapons"                         -- Category for inventory sorting
ITEM.model = "models/weapons/w_pistol.mdl"        -- 3D model for the weapon
ITEM.class = "weapon_pistol"                      -- Weapon class to give when equipped
ITEM.width = 2                                    -- Inventory width (2 slots)
ITEM.height = 2                                   -- Inventory height (2 slots)

```

---

