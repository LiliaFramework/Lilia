--[[
    Hooks:
        GetMoneyModel(number amount)

    Purpose:
        Allows modules to override the model used when a money entity is initialized.

    Category:
        Economy

    Parameters:
        amount (number)
            The money amount stored on the entity at initialization time.

    Returns:
        string|nil
            Return a model path to override the configured default money model. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetMoneyModel", "liaExampleGetMoneyModel", function(amount)
            if amount >= 1000 then
                return "models/props_lab/box01a.mdl"
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CanPickupMoney(Player activator, Entity moneyEntity)

    Purpose:
        Determines whether a player may pick up a money entity before the amount is credited.

    Category:
        Economy

    Parameters:
        activator (Player)
            The player trying to pick up the money.

        moneyEntity (Entity)
            The money entity being used.

    Returns:
        boolean|nil
            Return false to block the pickup. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanPickupMoney", "liaExampleCanPickupMoney", function(activator, moneyEntity)
            if activator:InVehicle() then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
function ENT:Initialize()
    self:SetModel(hook.Run("GetMoneyModel", self:getAmount()) or lia.config.get("MoneyModel"))
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:EnableMotion(true)
        physObj:Wake()
    else
        local min, max = Vector(-8, -8, -8), Vector(8, 8, 8)
        self:PhysicsInitBox(min, max)
        self:SetCollisionBounds(min, max)
    end
end

function ENT:Use(activator)
    local character = activator:getChar()
    if not character then return end
    if self.client == activator and character:getID() ~= self.charID then
        activator:notifyErrorLocalized("cantUseThisOnSameChar")
        return
    end

    if hook.Run("CanPickupMoney", activator, self) ~= false then
        activator:getChar():giveMoney(self:getAmount())
        hook.Run("OnPickupMoney", activator, self)
        SafeRemoveEntity(self)
    end
end

function ENT:setAmount(amount)
    self:setNetVar("amount", amount)
end
