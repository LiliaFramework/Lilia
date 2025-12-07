# Weapons Item Definition

Weapon item system for the Lilia framework.

---

### name

#### 📋 Purpose
Sets the display name of the weapon item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.name = "Pistol"

```

---

### desc

#### 📋 Purpose
Sets the description of the weapon item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.desc = "A standard issue pistol"

```

---

### category

#### 📋 Purpose
Sets the category for the weapon item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.category = "weapons"

```

---

### model

#### 📋 Purpose
Sets the 3D model for the weapon item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.model = "models/weapons/w_pistol.mdl"

```

---

### class

#### 📋 Purpose
Sets the weapon class name

#### ⏰ When Called
During item definition (used in equip/unequip functions)

#### 💡 Example Usage

```lua
    ITEM.class = "weapon_pistol"

```

---

### width

#### 📋 Purpose
Sets the inventory width of the weapon item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.width = 2  -- Takes 2 slot width

```

---

### height

#### 📋 Purpose
Sets the inventory height of the weapon item

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.height = 2  -- Takes 2 slot height

```

---

### health

#### 📋 Purpose
Sets the health value for the weapon item when it's dropped as an entity in the world

#### ⏰ When Called
During item definition (used when item is spawned as entity)
Notes:
- Defaults to 100 if not specified
- When the item entity takes damage, its health decreases
- Item is destroyed when health reaches 0
- Only applies if ITEM.CanBeDestroyed is true (controlled by config)

#### 💡 Example Usage

```lua
    ITEM.health = 250  -- Weapon can take 250 damage before being destroyed

```

---

### isWeapon

#### 📋 Purpose
Marks the item as a weapon

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.isWeapon = true

```

---

### RequiredSkillLevels

#### 📋 Purpose
Sets required skill levels for the weapon

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.RequiredSkillLevels = {}  -- No skill requirements

```

---

### DropOnDeath

#### 📋 Purpose
Sets whether the weapon drops when player dies

#### ⏰ When Called
During item definition

#### 💡 Example Usage

```lua
    ITEM.DropOnDeath = true  -- Drops on death

```

---

### OnCanBeTransfered

#### 📋 Purpose
Post-hook for weapon dropping

#### ⏰ When Called
After weapon is dropped

#### 💡 Example Usage

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

### OnCanBeTransfered

#### 📋 Purpose
Handles weapon dropping with ragdoll and equip checks

#### ⏰ When Called
When weapon is dropped

#### 💡 Example Usage

```lua
    ITEM:hook("drop", function(item)
        local client = item.player
        if not client or not IsValid(client) then return false end
        if IsValid(client:GetRagdollEntity()) then
            client:notifyErrorLocalized("noRagdollAction")
            return false
        end
        -- Handle equipped weapon removal
    end)

```

---

### onLoadout

#### 📋 Purpose
Prevents transfer of equipped weapons

#### ⏰ When Called
When attempting to transfer the weapon

#### 💡 Example Usage

```lua
    function ITEM:OnCanBeTransfered(_, newInventory)
        if newInventory and self:getData("equip") then return false end
        return true
    end

```

---

### OnSave

#### 📋 Purpose
Handles weapon loading on player spawn

#### ⏰ When Called
When player spawns with equipped weapon

#### 💡 Example Usage

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

### getName

#### 📋 Purpose
Saves weapon ammo data

#### ⏰ When Called
When saving the weapon item

#### 💡 Example Usage

```lua
    function ITEM:OnSave()
        local client = self.player
        if not client or not IsValid(client) then return end
        local weapon = client:GetWeapon(self.class)
        if IsValid(weapon) then self:setData("ammo", weapon:Clip1()) end
    end

```

---

### name

#### 📋 Purpose
Custom name function for weapons (CLIENT only)

#### ⏰ When Called
When displaying weapon name

#### 💡 Example Usage

```lua
    function ITEM:getName()
        local weapon = weapons.GetStored(self.class)
        if weapon and weapon.PrintName then return language.GetPhrase(weapon.PrintName) end
        return self.name
    end

```

---

## Complete Examples

The following examples demonstrate how to use all the properties and methods together to create complete definitions.

### Complete Item Example

Below is a comprehensive example showing how to define a complete item with all available properties and methods.

```lua
        ITEM.name = "Pistol"

        ITEM.desc = "A standard issue pistol"

        ITEM.category = "weapons"

        ITEM.model = "models/weapons/w_pistol.mdl"

        ITEM.class = "weapon_pistol"

        ITEM.width = 2  -- Takes 2 slot width

        ITEM.height = 2  -- Takes 2 slot height

        ITEM.health = 250  -- Weapon can take 250 damage before being destroyed

        ITEM.isWeapon = true

        ITEM.RequiredSkillLevels = {}  -- No skill requirements

        ITEM.DropOnDeath = true  -- Drops on death

        function ITEM.postHooks:drop()
            local client = self.player
            if not client or not IsValid(client) then return end
            if client:HasWeapon(self.class) then
                client:notifyErrorLocalized("invalidWeapon")
                client:StripWeapon(self.class)
            end
        end

        ITEM:hook("drop", function(item)
            local client = item.player
            if not client or not IsValid(client) then return false end
            if IsValid(client:GetRagdollEntity()) then
                client:notifyErrorLocalized("noRagdollAction")
                return false
            end
            -- Handle equipped weapon removal
        end)

        function ITEM:OnCanBeTransfered(_, newInventory)
            if newInventory and self:getData("equip") then return false end
            return true
        end

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

        function ITEM:OnSave()
            local client = self.player
            if not client or not IsValid(client) then return end
            local weapon = client:GetWeapon(self.class)
            if IsValid(weapon) then self:setData("ammo", weapon:Clip1()) end
        end

        function ITEM:getName()
            local weapon = weapons.GetStored(self.class)
            if weapon and weapon.PrintName then return language.GetPhrase(weapon.PrintName) end
            return self.name
        end

    -- Basic item identification
    ITEM.name        = "Pistol"                       -- Display name shown to players
    ITEM.desc        = "A standard issue pistol"      -- Description text
    ITEM.category    = "weapons"                      -- Category for inventory sorting
    ITEM.model       = "models/weapons/w_pistol.mdl"  -- 3D model for the weapon
    ITEM.class       = "weapon_pistol"                -- Weapon class to give when equipped
    ITEM.width       = 2                              -- Inventory width (2 slots)
    ITEM.height      = 2                              -- Inventory height (2 slots)
    ITEM.DropOnDeath = true                           -- Drops on death

```

---

