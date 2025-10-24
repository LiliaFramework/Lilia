# Weapons Item Definition

Weapon item system for the Lilia framework.

---

### name

**Purpose**

Sets the display name of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.name = "Pistol"
```

---

### desc

**Purpose**

Sets the description of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.desc = "A standard issue pistol"
```

---

### category

**Purpose**

Sets the category for the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.category = "weapons"
```

---

### model

**Purpose**

Sets the 3D model for the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.model = "models/weapons/w_pistol.mdl"
```

---

### class

**Purpose**

Sets the weapon class name

**When Called**

During item definition (used in equip/unequip functions)

**Example Usage**

```lua
ITEM.class = "weapon_pistol"
```

---

### width

**Purpose**

Sets the inventory width of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.width = 2  -- Takes 2 slot width
```

---

### height

**Purpose**

Sets the inventory height of the weapon item

**When Called**

During item definition

**Example Usage**

```lua
ITEM.height = 2  -- Takes 2 slot height
```

---

### isWeapon

**Purpose**

Marks the item as a weapon

**When Called**

During item definition

**Example Usage**

```lua
ITEM.isWeapon = true
```

---

### RequiredSkillLevels

**Purpose**

Sets required skill levels for the weapon

**When Called**

During item definition

**Example Usage**

```lua
ITEM.RequiredSkillLevels = {}  -- No skill requirements
```

---

### DropOnDeath

**Purpose**

Sets whether the weapon drops when player dies

**When Called**

During item definition

**Example Usage**

```lua
ITEM.DropOnDeath = true  -- Drops on death
```

---

### postHooks

**Purpose**

Post-hook for weapon dropping

**When Called**

After weapon is dropped

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

**Purpose**

Handles weapon dropping with ragdoll and equip checks

**When Called**

When weapon is dropped

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

**Purpose**

Prevents transfer of equipped weapons

**When Called**

When attempting to transfer the weapon

**Example Usage**

```lua
function ITEM:OnCanBeTransfered(_, newInventory)
if newInventory and self:getData("equip") then return false end
return true
end
```

---

### ITEM:onLoadout()

**Purpose**

Handles weapon loading on player spawn

**When Called**

When player spawns with equipped weapon

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

**Purpose**

Saves weapon ammo data

**When Called**

When saving the weapon item

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

**Purpose**

Custom name function for weapons (CLIENT only)

**When Called**

When displaying weapon name

**Example Usage**

```lua
function ITEM:getName()
local weapon = weapons.GetStored(self.class)
if weapon and weapon.PrintName then return language.GetPhrase(weapon.PrintName) end
return self.name
end
```

---

