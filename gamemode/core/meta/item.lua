--[[
    Item Meta
    Item management system for the Lilia framework.
]]
--[[
    Overview:
    The item meta table provides comprehensive functionality for managing item data, properties, and operations in the Lilia framework. It handles item creation, data persistence, inventory management, stacking, rotation, and item-specific operations. The meta table operates on both server and client sides, with the server managing item storage and validation while the client provides item data access and display. It includes integration with the inventory system for item storage, database system for item persistence, and rendering system for item display. The meta table ensures proper item data synchronization, quantity management, rotation handling, and comprehensive item lifecycle management from creation to destruction.
]]
local ITEM = lia.meta.item or {}
debug.getregistry().Item = lia.meta.item
ITEM.__index = ITEM
ITEM.name = "invalidName"
ITEM.desc = ITEM.desc or "invalidDescription"
ITEM.id = ITEM.id or 0
ITEM.uniqueID = "undefined"
ITEM.isItem = true
ITEM.isStackable = false
ITEM.quantity = 1
ITEM.maxQuantity = 1
ITEM.canSplit = true
ITEM.scale = 1
--[[
    Purpose: Checks if the item is currently rotated in the inventory
    When Called: When checking item orientation for inventory display or placement
    Parameters: None
    Returns: boolean - True if the item is rotated, false otherwise
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Check if item is rotated
        local isRotated = item:isRotated()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use rotation state for inventory calculations
        local width = item:isRotated() and item.height or item.width
    ```
    High Complexity:
    ```lua
        -- High: Complex inventory placement logic
        if item:isRotated() then
            -- Handle rotated item placement
        end
    ```
]]
function ITEM:isRotated()
    return self:getData("rotated", false)
end

--[[
    Purpose: Gets the effective width of the item, accounting for rotation
    When Called: When calculating item dimensions for inventory placement
    Parameters: None
    Returns: number - The effective width of the item (height if rotated)
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item width
        local width = item:getWidth()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use width for inventory calculations
        local canFit = inventory:canFit(item:getWidth(), item:getHeight())
    ```
    High Complexity:
    ```lua
        -- High: Complex inventory placement with rotation
        local effectiveWidth = item:isRotated() and item.height or item.width
    ```
]]
function ITEM:getWidth()
    return self:isRotated() and (self.height or 1) or self.width or 1
end

--[[
    Purpose: Gets the effective height of the item, accounting for rotation
    When Called: When calculating item dimensions for inventory placement
    Parameters: None
    Returns: number - The effective height of the item (width if rotated)
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item height
        local height = item:getHeight()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use height for inventory calculations
        local canFit = inventory:canFit(item:getWidth(), item:getHeight())
    ```
    High Complexity:
    ```lua
        -- High: Complex inventory placement with rotation
        local effectiveHeight = item:isRotated() and item.width or item.height
    ```
]]
function ITEM:getHeight()
    return self:isRotated() and (self.width or 1) or self.height or 1
end

--[[
    Purpose: Gets the current quantity of the item
    When Called: When checking item quantity for inventory management or display
    Parameters: None
    Returns: number - The current quantity of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item quantity
        local quantity = item:getQuantity()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Check if item can be split
        if item:getQuantity() > 1 then
            -- Allow splitting
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex quantity management
        local currentQty = item:getQuantity()
        local maxQty = item.maxQuantity
        if currentQty < maxQty then
            -- Handle stacking
        end
    ```
]]
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--[[
    Purpose: Converts the item to a string representation for debugging
    When Called: When displaying item information in console or debug output
    Parameters: None
    Returns: string - Formatted string representation of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Print item info
        print(item:tostring())
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use in debug messages
        lia.information("Item: " .. item:tostring())
    ```
    High Complexity:
    ```lua
        -- High: Complex logging with item details
        lia.logger.info("Processing item: " .. item:tostring())
    ```
]]
function ITEM:tostring()
    return L("item") .. "[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--[[
    Purpose: Gets the unique ID of the item instance
    When Called: When identifying a specific item instance for operations
    Parameters: None
    Returns: number - The unique ID of the item instance
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item ID
        local id = item:getID()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use ID for inventory operations
        inventory:removeItem(item:getID())
    ```
    High Complexity:
    ```lua
        -- High: Complex item tracking
        local itemID = item:getID()
        if itemID > 0 then
            -- Handle valid item instance
        end
    ```
]]
function ITEM:getID()
    return self.id
end

--[[
    Purpose: Gets the model path of the item
    When Called: When displaying or spawning the item entity
    Parameters: None
    Returns: string - The model path of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item model
        local model = item:getModel()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use model for entity creation
        local entity = ents.Create("lia_item")
        entity:SetModel(item:getModel())
    ```
    High Complexity:
    ```lua
        -- High: Complex model validation
        local model = item:getModel()
        if model and util.IsValidModel(model) then
            -- Handle valid model
        end
    ```
]]
function ITEM:getModel()
    return self.model
end

--[[
    Purpose: Gets the skin index of the item
    When Called: When applying visual customization to the item entity
    Parameters: None
    Returns: number - The skin index of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item skin
        local skin = item:getSkin()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Apply skin to entity
        local entity = item:getEntity()
        if IsValid(entity) then
            entity:SetSkin(item:getSkin())
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex skin management
        local skin = item:getSkin()
        if skin and skin > 0 then
            -- Handle custom skin
        end
    ```
]]
function ITEM:getSkin()
    return self.skin
end

--[[
    Purpose: Gets the bodygroup data of the item
    When Called: When applying bodygroup modifications to the item entity
    Parameters: None
    Returns: table - The bodygroup data of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item bodygroups
        local bodygroups = item:getBodygroups()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Apply bodygroups to entity
        local entity = item:getEntity()
        if IsValid(entity) then
            for group, value in pairs(item:getBodygroups()) do
                entity:SetBodygroup(group, value)
            end
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex bodygroup management
        local bodygroups = item:getBodygroups()
        if bodygroups and next(bodygroups) then
            -- Handle custom bodygroups
        end
    ```
]]
function ITEM:getBodygroups()
    return self.bodygroups or {}
end

--[[
    Purpose: Gets the price of the item, with optional custom calculation
    When Called: When displaying item price or calculating transaction costs
    Parameters: None
    Returns: number - The calculated price of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item price
        local price = item:getPrice()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use price for vendor transactions
        local totalCost = item:getPrice() * quantity
    ```
    High Complexity:
    ```lua
        -- High: Complex pricing with custom calculation
        local basePrice = item.price
        local finalPrice = item:getPrice()
        if item.calcPrice then
            -- Custom price calculation applied
        end
    ```
]]
function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

--[[
    Purpose: Calls a method on the item with context switching
    When Called: When executing item methods with specific player and entity context
    Parameters:
        - method (string): The method name to call
        - client (Player, optional): The player context for the call
        - entity (Entity, optional): The entity context for the call
        - ... (any): Additional arguments to pass to the method
    Returns: any - The return value(s) from the called method
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Call item method
        item:call("onUse", player)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Call with context
        item:call("onDrop", player, entity, data)
    ```
    High Complexity:
    ```lua
        -- High: Complex method calling with hooks
        local result = item:call("customAction", player, entity, arg1, arg2)
        if result then
            -- Handle result
        end
    ```
]]
function ITEM:call(method, client, entity, ...)
    local oldPlayer, oldEntity = self.player, self.entity
    self.player = client or self.player
    self.entity = entity or self.entity
    if isfunction(self[method]) then
        local results = {self[method](self, ...)}
        self.player = oldPlayer
        self.entity = oldEntity
        hook.Run("ItemFunctionCalled", self, method, client, entity, results)
        return unpack(results)
    end

    self.player = oldPlayer
    self.entity = oldEntity
end

--[[
    Purpose: Gets the owner of the item (the player who has it in their inventory)
    When Called: When determining item ownership for permissions or display
    Parameters: None
    Returns: Player - The player who owns the item, or nil if not found
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item owner
        local owner = item:getOwner()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Check ownership for permissions
        local owner = item:getOwner()
        if owner == player then
            -- Player owns the item
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex ownership validation
        local owner = item:getOwner()
        if owner and IsValid(owner) then
            -- Handle valid owner
        end
    ```
]]
function ITEM:getOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end

--[[
    Purpose: Gets a specific data value from the item
    When Called: When retrieving stored data from the item
    Parameters:
        - key (string): The data key to retrieve
        - default (any, optional): Default value if key doesn't exist
    Returns: any - The data value or default if not found
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item data
        local value = item:getData("customValue")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Get data with default
        local durability = item:getData("durability", 100)
    ```
    High Complexity:
    ```lua
        -- High: Complex data retrieval
        local data = item:getData("complexData", {})
        if data and istable(data) then
            -- Handle complex data
        end
    ```
]]
function ITEM:getData(key, default)
    self.data = self.data or {}
    local value = self.data[key]
    if value ~= nil then return value end
    if IsValid(self.entity) then
        local data = self.entity:getNetVar("data", {})
        value = data[key]
        if value ~= nil then return value end
    end
    return default
end

--[[
    Purpose: Gets all data from the item, including entity data
    When Called: When retrieving complete item data for serialization or display
    Parameters: None
    Returns: table - Complete data table combining item and entity data
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get all item data
        local data = item:getAllData()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use data for serialization
        local serialized = util.TableToJSON(item:getAllData())
    ```
    High Complexity:
    ```lua
        -- High: Complex data processing
        local allData = item:getAllData()
        for key, value in pairs(allData) do
            -- Process each data entry
        end
    ```
]]
function ITEM:getAllData()
    self.data = self.data or {}
    local fullData = table.Copy(self.data)
    if IsValid(self.entity) then
        local entityData = self.entity:getNetVar("data", {})
        for key, value in pairs(entityData) do
            fullData[key] = value
        end
    end
    return fullData
end

--[[
    Purpose: Registers a hook function for the item
    When Called: When setting up item-specific hook functions
    Parameters:
        - name (string): The hook name to register
        - func (function): The function to call for this hook
    Returns: None
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Register hook
        item:hook("onUse", function(self)
            -- Handle use
        end)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Register with parameters
        item:hook("onDrop", function(self, position)
            -- Handle drop
        end)
    ```
    High Complexity:
    ```lua
        -- High: Complex hook registration
        item:hook("customAction", function(self, data)
            -- Complex hook logic
        end)
    ```
]]
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

--[[
    Purpose: Registers a post-hook function for the item
    When Called: When setting up item-specific post-hook functions that run after main hooks
    Parameters:
        - name (string): The hook name to register
        - func (function): The function to call for this post-hook
    Returns: None
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Register post-hook
        item:postHook("onUse", function(self, result)
            -- Handle after use
        end)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Register with parameters
        item:postHook("onDrop", function(self, result, position)
            -- Handle after drop
        end)
    ```
    High Complexity:
    ```lua
        -- High: Complex post-hook registration
        item:postHook("customAction", function(self, result, data)
            -- Complex post-hook logic
        end)
    ```
]]
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

--[[
    Purpose: Called when the item is registered in the system
    When Called: During item registration, typically for precaching models
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Basic registration
        function ITEM:onRegistered()
            -- Basic setup
        end
    ```
    Medium Complexity:
    ```lua
        -- Medium: Model precaching
        function ITEM:onRegistered()
            if self.model then
                util.PrecacheModel(self.model)
            end
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex registration setup
        function ITEM:onRegistered()
            -- Complex initialization logic
        end
    ```
]]
function ITEM:onRegistered()
    if self.model and isstring(self.model) then util.PrecacheModel(self.model) end
end

--[[
    Purpose: Prints item information for debugging
    When Called: When displaying item information in console or debug output
    Parameters:
        - detail (boolean, optional): Whether to include detailed information
    Returns: None
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Print basic info
        item:print()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Print with details
        item:print(true)
    ```
    High Complexity:
    ```lua
        -- High: Complex debugging
        if debugMode then
            item:print(true)
        end
    ```
]]
function ITEM:print(detail)
    if detail then
        lia.information(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        lia.information(Format("%s[%s]", self.uniqueID, self.id))
    end
end

--[[
    Purpose: Prints detailed item data for debugging
    When Called: When displaying complete item data in console or debug output
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Print item data
        item:printData()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Conditional data printing
        if debugMode then
            item:printData()
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex debugging with data
        item:print(true)
        item:printData()
    ```
]]
function ITEM:printData()
    self:print(true)
    lia.information(L("itemData") .. ":")
    for k, v in pairs(self.data) do
        lia.information(L("itemDataEntry", k, v))
    end
end

--[[
    Purpose: Gets the display name of the item
    When Called: When displaying the item name in UI or inventory
    Parameters: None
    Returns: string - The display name of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item name
        local name = item:getName()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use name in UI
        local displayText = item:getName() .. " x" .. item:getQuantity()
    ```
    High Complexity:
    ```lua
        -- High: Complex name handling
        local name = item:getName()
        if name and name ~= "invalidName" then
            -- Handle valid name
        end
    ```
]]
function ITEM:getName()
    return self.name
end

--[[
    Purpose: Gets the description of the item
    When Called: When displaying the item description in UI or tooltips
    Parameters: None
    Returns: string - The description of the item
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item description
        local desc = item:getDesc()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use description in tooltip
        local tooltip = item:getName() .. "\n" .. item:getDesc()
    ```
    High Complexity:
    ```lua
        -- High: Complex description handling
        local desc = item:getDesc()
        if desc and desc ~= "invalidDescription" then
            -- Handle valid description
        end
    ```
]]
function ITEM:getDesc()
    return self.desc
end

if SERVER then
    --[[
    Purpose: Removes the item from its current inventory
    When Called: When transferring or removing an item from an inventory
    Parameters:
        - preserveItem (boolean, optional): Whether to preserve the item data
    Returns: Promise - Promise that resolves when removal is complete
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Remove from inventory
        item:removeFromInventory()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Remove with preservation
        item:removeFromInventory(true)
    ```
    High Complexity:
    ```lua
        -- High: Complex removal handling
        item:removeFromInventory():next(function()
            -- Handle after removal
        end)
    ```
]]
    function ITEM:removeFromInventory(preserveItem)
        local inventory = lia.inventory.instances[self.invID]
        self.invID = 0
        if inventory then return inventory:removeItem(self:getID(), preserveItem) end
        local d = deferred.new()
        d:resolve()
        return d
    end

    --[[
    Purpose: Deletes the item from the database and triggers cleanup
    When Called: When permanently removing an item from the system
    Parameters: None
    Returns: Promise - Promise that resolves when deletion is complete
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Delete item
        item:delete()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Delete with callback
        item:delete():next(function()
            -- Handle after deletion
        end)
    ```
    High Complexity:
    ```lua
        -- High: Complex deletion handling
        item:destroy()
        item:delete():next(function()
            -- Handle after deletion
        end)
    ```
]]
    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

    --[[
    Purpose: Removes the item from the world and database
    When Called: When completely removing an item from the game world
    Parameters: None
    Returns: Promise - Promise that resolves when removal is complete
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Remove item
        item:remove()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Remove with callback
        item:remove():next(function()
            -- Handle after removal
        end)
    ```
    High Complexity:
    ```lua
        -- High: Complex removal handling
        item:remove():next(function()
            -- Handle after removal
        end)
    ```
]]
    function ITEM:remove()
        local d = deferred.new()
        if IsValid(self.entity) then SafeRemoveEntity(self.entity) end
        self:removeFromInventory():next(function()
            d:resolve()
            return self:delete()
        end)
        return d
    end

    --[[
    Purpose: Destroys the item instance and notifies clients
    When Called: When removing an item instance from memory
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Destroy item
        item:destroy()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Destroy with cleanup
        item:destroy()
        item:onDisposed()
    ```
    High Complexity:
    ```lua
        -- High: Complex destruction handling
        item:destroy()
        -- Additional cleanup logic
    ```
]]
    function ITEM:destroy()
        net.Start("liaItemDelete")
        net.WriteUInt(self:getID(), 32)
        net.Broadcast()
        lia.item.instances[self:getID()] = nil
        self:onDisposed()
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:onDisposed()
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end

    --[[
    Purpose: Spawns the item as an entity in the world
    When Called: When creating a physical item entity in the game world
    Parameters:
        - position (Vector|Player): The spawn position or player to drop near
        - angles (Angle, optional): The spawn angles for the entity
    Returns: Entity - The spawned item entity, or nil if failed
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Spawn item
        local entity = item:spawn(Vector(0, 0, 0))
    ```
    Medium Complexity:
    ```lua
        -- Medium: Spawn with angles
        local entity = item:spawn(Vector(0, 0, 0), Angle(0, 0, 0))
    ```
    High Complexity:
    ```lua
        -- High: Complex spawning with player
        local entity = item:spawn(player, Angle(0, 0, 0))
        if IsValid(entity) then
            -- Handle spawned entity
        end
    ```
]]
    function ITEM:spawn(position, angles)
        local instance = lia.item.instances[self.id]
        if instance then
            if IsValid(instance.entity) then
                instance.entity.liaIsSafe = true
                SafeRemoveEntity(instance.entity)
            end

            local client
            if isentity(position) and position:IsPlayer() then
                client = position
                position = position:getItemDropPos()
            end

            position = lia.data.decode(position)
            if not isvector(position) and istable(position) then
                local x = tonumber(position.x or position[1])
                local y = tonumber(position.y or position[2])
                local z = tonumber(position.z or position[3])
                if x and y and z then position = Vector(x, y, z) end
            end

            if angles then
                angles = lia.data.decode(angles)
                if not isangle(angles) then
                    if isvector(angles) then
                        angles = Angle(angles.x, angles.y, angles.z)
                    elseif istable(angles) then
                        local p = tonumber(angles.p or angles[1])
                        local yaw = tonumber(angles.y or angles[2])
                        local r = tonumber(angles.r or angles[3])
                        if p and yaw and r then angles = Angle(p, yaw, r) end
                    end
                end
            end

            local entity = ents.Create("lia_item")
            entity:Spawn()
            entity:SetPos(position)
            entity:SetAngles(angles or angle_zero)
            entity:setItem(self.id)
            instance.entity = entity
            if self.scale and self.scale ~= 1 then entity:SetModelScale(self.scale) end
            if IsValid(client) then
                entity.SteamID = client:SteamID()
                if client:getChar() then
                    entity.liaCharID = client:getChar():getID()
                else
                    entity.liaCharID = 0
                end

                entity:SetCreator(client)
            end
            return entity
        end
    end

    --[[
    Purpose: Transfers the item to a new inventory
    When Called: When moving an item between inventories
    Parameters:
        - newInventory (Inventory): The target inventory to transfer to
        - bBypass (boolean, optional): Whether to bypass access checks
    Returns: boolean - True if transfer was successful
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Transfer item
        item:transfer(targetInventory)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Transfer with bypass
        item:transfer(targetInventory, true)
    ```
    High Complexity:
    ```lua
        -- High: Complex transfer handling
        if item:transfer(targetInventory) then
            -- Handle successful transfer
        end
    ```
]]
    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:onInstanced()
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:onSync()
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:onRemoved()
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:onRestored()
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:sync(recipient)
        net.Start("liaItemInstance")
        net.WriteUInt(self:getID(), 32)
        net.WriteString(self.uniqueID)
        net.WriteTable(self.data)
        net.WriteType(self.invID)
        net.WriteUInt(self.quantity, 32)
        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end

        self:onSync(recipient)
    end

    --[[
    Purpose: Sets a data value for the item and synchronizes it
    When Called: When storing or updating item data
    Parameters:
        - key (string): The data key to set
        - value (any): The value to store
        - receivers (Player|table, optional): Specific players to sync to
        - noSave (boolean, optional): Whether to skip database saving
        - noCheckEntity (boolean, optional): Whether to skip entity checks
    Returns: None
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Set item data
        item:setData("customValue", 100)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Set data with specific receivers
        item:setData("durability", 50, player)
    ```
    High Complexity:
    ```lua
        -- High: Complex data setting
        item:setData("complexData", data, receivers, false, true)
    ```
]]
    function ITEM:setData(key, value, receivers, noSave, noCheckEntity)
        self.data = self.data or {}
        self.data[key] = value
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("data", self.data) end
        end

        if receivers or self:getOwner() then
            net.Start("liaInvData")
            net.WriteUInt(self:getID(), 32)
            net.WriteString(key)
            net.WriteType(value)
            if receivers then
                net.Send(receivers)
            else
                net.Send(self:getOwner())
            end
        end

        if noSave or not lia.db then return end
        if key == "x" or key == "y" then
            value = tonumber(value)
            lia.db.updateTable({
                [key] = value
            }, nil, "items", "itemID = " .. self:getID())
            return
        end

        local x, y = self.data.x, self.data.y
        self.data.x, self.data.y = nil, nil
        lia.db.updateTable({
            data = self.data
        }, nil, "items", "itemID = " .. self:getID())

        self.data.x, self.data.y = x, y
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    --[[
    Purpose: Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called: When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns: boolean - True if sound was played successfully
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
    ```
    Medium Complexity:
    ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
    ```
    High Complexity:
    ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
    ```
]]
    function ITEM:setQuantity(quantity, receivers, noCheckEntity)
        self.quantity = quantity
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("quantity", self.quantity) end
        end

        if receivers or self:getOwner() then
            net.Start("liaInvQuantity")
            net.WriteUInt(self:getID(), 32)
            net.WriteUInt(self.quantity, 32)
            if receivers then
                net.Send(receivers)
            else
                net.Send(self:getOwner())
            end
        end

        if noSave or not lia.db then return end
        lia.db.updateTable({
            quantity = self.quantity
        }, nil, "items", "itemID = " .. self:getID())
    end

    --[[
    Purpose: Handles item interaction with players
    When Called: When a player interacts with an item (use, drop, etc.)
    Parameters:
        - action (string): The action being performed
        - client (Player): The player performing the action
        - entity (Entity, optional): The item entity if applicable
        - data (any, optional): Additional data for the interaction
    Returns: boolean - True if interaction was successful
    Realm: Server
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Use item
        item:interact("use", player)
    ```
    Medium Complexity:
    ```lua
        -- Medium: Drop item with data
        item:interact("drop", player, entity, position)
    ```
    High Complexity:
    ```lua
        -- High: Complex interaction
        local success = item:interact("customAction", player, entity, data)
        if success then
            -- Handle successful interaction
        end
    ```
]]
    function ITEM:interact(action, client, entity, data)
        assert(client:IsPlayer() and IsValid(client), L("itemActionNoPlayer"))
        local canInteract, reason = hook.Run("CanPlayerInteractItem", client, action, self, data)
        if canInteract == false then
            if reason then client:notifyErrorLocalized(reason) end
            return false
        end

        local oldPlayer, oldEntity = self.player, self.entity
        self.player = client
        self.entity = entity
        local callback = self.functions[action]
        if not callback then
            self.player = oldPlayer
            self.entity = oldEntity
            return false
        end

        if isfunction(callback.onCanRun) then
            canInteract = callback.onCanRun(self, data)
        else
            canInteract = true
        end

        if not canInteract then
            self.player = oldPlayer
            self.entity = oldEntity
            return false
        end

        hook.Run("PrePlayerInteractItem", client, action, self)
        local result
        if isfunction(self.hooks[action]) then result = self.hooks[action](self, data) end
        if result == nil then
            local isMulti = callback.isMulti or callback.multiOptions and istable(callback.multiOptions)
            if isMulti and isstring(data) and callback.multiOptions then
                local optionFunc = callback.multiOptions[data]
                if optionFunc then
                    if isfunction(optionFunc) then
                        result = optionFunc(self)
                    elseif istable(optionFunc) then
                        local runFunc = optionFunc[1] or optionFunc.onRun
                        if isfunction(runFunc) then result = runFunc(self) end
                    end
                end
            elseif isfunction(callback.onRun) then
                result = callback.onRun(self, data)
            end
        end

        if self.postHooks[action] then self.postHooks[action](self, result, data) end
        hook.Run("OnPlayerInteractItem", client, action, self, result, data)
        if result ~= false and not deferred.isPromise(result) then
            if IsValid(entity) then
                SafeRemoveEntity(entity)
            else
                self:remove()
            end
        end

        self.player = oldPlayer
        self.entity = oldEntity
        return true
    end
end

--[[
    Purpose: Gets the localized category name of the item
    When Called: When displaying item category in UI or sorting
    Parameters: None
    Returns: string - The localized category name
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
        -- Simple: Get item category
        local category = item:getCategory()
    ```
    Medium Complexity:
    ```lua
        -- Medium: Use category for sorting
        local category = item:getCategory()
        if category == "weapons" then
            -- Handle weapon category
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex category handling
        local category = item:getCategory()
        local displayName = item:getName() .. " (" .. category .. ")"
    ```
]]
function ITEM:getCategory()
    return self.category and L(self.category) or L("misc")
end

lia.meta.item = ITEM
