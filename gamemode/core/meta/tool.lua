--[[
    Tool Gun Meta Table

    This file defines the Tool Gun metatable for the Lilia gamemode framework, providing a
    comprehensive system for implementing custom tool gun functionality in Garry's Mod. The
    metatable extends the base tool gun behavior with enhanced object management, console
    variable handling, ghost entity management, and interaction systems. It serves as the
    foundation for creating custom tools that can interact with the game world, manage
    persistent objects, handle user input, and provide visual feedback through HUD elements.
    The tool gun meta table operates on both server and client realms, ensuring consistent
    behavior across networked gameplay while providing realm-specific optimizations for
    performance and security. This system is essential for administrative tools, building
    systems, interactive world objects, and any gameplay mechanic that requires precise
    user interaction with the game environment.
]]
local toolGunMeta = lia.meta.tool or {}
--[[
    Purpose: Creates a new instance of the tool gun object with default properties
    When Called: When initializing a new tool gun instance for a specific tool mode
    Parameters: None
    Returns: table - The newly created tool gun object
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Create a basic tool gun instance
        local tool = toolGunMeta:create()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Create tool with custom properties
        local tool = toolGunMeta:create()
        tool.Mode = "custom_tool"
        tool.Stage = 1
        ```

        High Complexity:
        ```lua
        -- High: Create tool with full configuration and custom objects
        local tool = toolGunMeta:create()
        tool.Mode = "advanced_builder"
        tool.ClientConVar = {
            ["build_size"] = "1",
            ["build_material"] = "wood"
        }
        tool.Objects = {}
        tool.Stage = 0
        ```
]]
function toolGunMeta:create()
    local object = {}
    setmetatable(object, self)
    self.__index = self
    object.Mode = nil
    object.SWEP = nil
    object.Owner = nil
    object.ClientConVar = {}
    object.ServerConVar = {}
    object.Objects = {}
    object.Stage = 0
    object.Message = L("start")
    object.LastMessage = 0
    object.AllowedCVar = 0
    return object
end

--[[
    Purpose: Creates console variables (ConVars) for the tool gun based on the current mode
    When Called: During tool initialization to set up configurable options for the tool
    Parameters: None
    Returns: None
    Realm: Shared (different behavior on client vs server)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Initialize basic ConVars for a tool
        local tool = toolGunMeta:create()
        tool:createConVars()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Set up tool with client-side options
        local tool = toolGunMeta:create()
        tool.ClientConVar = {["size"] = "1", ["material"] = "wood"}
        tool:createConVars()
        ```

        High Complexity:
        ```lua
        -- High: Advanced tool with multiple client and server ConVars
        local tool = toolGunMeta:create()
        tool.Mode = "advanced_builder"
        tool.ClientConVar = {
            ["build_size"] = "1",
            ["build_material"] = "wood",
            ["auto_align"] = "1"
        }
        tool:createConVars()
        ```
]]
function toolGunMeta:createConVars()
    local mode = self:getMode()
    if CLIENT then
        for cvar, default in pairs(self.ClientConVar) do
            CreateClientConVar(mode .. "_" .. cvar, default, true, true)
        end
        return
    else
        self.AllowedCVar = CreateConVar("toolmode_allow_" .. mode, 1, FCVAR_NOTIFY)
    end
end

--[[
    Purpose: Updates the tool's data and state information (placeholder for custom implementation)
    When Called: During tool operation to refresh data or synchronize with server/client state
    Parameters: None
    Returns: None
    Realm: Shared (can be overridden for specific tool behavior)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic data update call
        tool:updateData()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Update data with custom logic
        function tool:updateData()
            self.LastUpdate = CurTime()
            self.ObjectCount = #self.Objects
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced data synchronization with networking
        function tool:updateData()
            if SERVER then
                -- Server-side data update
                self:SyncDataToClients()
            else
                -- Client-side data refresh
                self:RequestServerUpdate()
            end
            self.LastUpdate = CurTime()
        end
        ```
]]
function toolGunMeta:updateData()
end

--[[
    Purpose: Freezes player movement during tool operation (placeholder for custom implementation)
    When Called: When the tool needs to restrict player movement for precise operations
    Parameters: None
    Returns: None
    Realm: Client (affects local player movement)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic movement freeze
        tool:freezeMovement()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Conditional movement freezing
        function tool:freezeMovement()
            if self:GetOwner():KeyDown(IN_ATTACK) then
                self:GetOwner():SetMoveType(MOVETYPE_NONE)
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced movement control with restoration
        function tool:freezeMovement()
            local ply = self:GetOwner()
            if not ply.FrozenPosition then
                ply.FrozenPosition = ply:GetPos()
                ply.FrozenAngles = ply:GetAngles()
                ply:SetMoveType(MOVETYPE_NONE)
            end
        end

        function tool:unfreezeMovement()
            local ply = self:GetOwner()
            if ply.FrozenPosition then
                ply:SetMoveType(MOVETYPE_WALK)
                ply.FrozenPosition = nil
                ply.FrozenAngles = nil
            end
        end
        ```
]]
function toolGunMeta:freezeMovement()
end

--[[
    Purpose: Draws HUD elements for the tool gun interface (placeholder for custom implementation)
    When Called: Every frame when the tool gun is active and HUD should be displayed
    Parameters: None
    Returns: None
    Realm: Client (HUD rendering only occurs on client)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Draw basic tool information
        function tool:drawHUD()
            draw.SimpleText(self.Message, "default", 10, 10, color_white)
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Draw tool progress and object count
        function tool:drawHUD()
            local scrW, scrH = ScrW(), ScrH()

            -- Draw tool name and stage
            draw.SimpleText(self:getMode(), "liaGenericFont", scrW/2, scrH - 100, color_white, TEXT_ALIGN_CENTER)

            -- Draw progress bar
            local progress = self.Stage / 3
            surface.SetDrawColor(0, 255, 0, 255)
            surface.DrawRect(scrW/2 - 50, scrH - 80, progress * 100, 10)
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced HUD with object preview and controls
        function tool:drawHUD()
            local scrW, scrH = ScrW(), ScrH()

            -- Draw tool header
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(0, scrH - 150, scrW, 150)

            -- Draw tool name and status
            draw.SimpleText(self:getMode():upper(), "liaGenericFont", 10, scrH - 140, color_white)

            -- Draw object list
            local y = scrH - 120
            for i, obj in ipairs(self.Objects) do
                draw.SimpleText("Object " .. i .. ": " .. tostring(obj.Ent), "liaSmallFont", 10, y, color_white)
                y = y + 20
            end

            -- Draw control hints
            draw.SimpleText("Left Click: Place | Right Click: Cancel | Reload: Clear", "liaSmallFont", scrW/2, scrH - 20, color_white, TEXT_ALIGN_CENTER)
        end
        ```
]]
function toolGunMeta:drawHUD()
end

--[[
    Purpose: Retrieves server-side ConVar information for the current tool mode
    When Called: When the tool needs to access server configuration values
    Parameters: property (string) - The name of the ConVar property to retrieve
    Returns: ConVar - The server ConVar object for the specified property
    Realm: Server (accesses server-side console variables)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get basic server ConVar
        local maxObjects = tool:getServerInfo("max_objects")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use server info for validation
        local maxObjects = tool:getServerInfo("max_objects")
        if #tool.Objects >= maxObjects:GetInt() then
            tool.Message = "Maximum objects reached"
            return false
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced server configuration management
        local serverConfig = {}
        local properties = {"max_objects", "build_speed", "auto_save"}
        for _, prop in ipairs(properties) do
            local convar = tool:getServerInfo(prop)
            serverConfig[prop] = convar:GetInt()
        end

        if serverConfig.auto_save > 0 then
            tool:ScheduleAutoSave(serverConfig.auto_save)
        end
        ```
]]
function toolGunMeta:getServerInfo(property)
    local mode = self:getMode()
    return ConVar(mode .. "_" .. property)
end

--[[
    Purpose: Builds a formatted list of ConVars for the current tool mode
    When Called: When the tool needs to provide a list of available ConVars for UI or configuration
    Parameters: None
    Returns: table - A table mapping ConVar names to their default values
    Realm: Shared (can be used on both client and server)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get basic ConVar list
        local convars = tool:buildConVarList()
        PrintTable(convars)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use ConVar list for UI population
        local convars = tool:buildConVarList()
        for name, default in pairs(convars) do
            local panel = vgui.Create("DTextEntry")
            panel:SetConVar(name)
            panel:SetValue(default)
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced ConVar management with validation
        local convars = tool:buildConVarList()
        local validatedConfig = {}

        for name, default in pairs(convars) do
            local value = GetConVar(name):GetString()
            if self:ValidateConVar(name, value) then
                validatedConfig[name] = value
            else
                validatedConfig[name] = default
                print("Invalid ConVar value for " .. name .. ", using default")
            end
        end

        self:ApplyConfiguration(validatedConfig)
        ```
]]
function toolGunMeta:buildConVarList()
    local mode = self:getMode()
    local convars = {}
    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end
    return convars
end

--[[
    Purpose: Retrieves client-side ConVar information for the current tool mode
    When Called: When the tool needs to access client configuration values from the owner
    Parameters: property (string) - The name of the ConVar property to retrieve
    Returns: string - The current value of the client's ConVar for the specified property
    Realm: Shared (accesses client-side data through the owner)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get basic client ConVar value
        local size = tool:getClientInfo("build_size")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use client info for tool behavior
        local material = tool:getClientInfo("build_material")
        if material == "wood" then
            self.GhostEntity:SetMaterial("wood")
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced client configuration with fallback
        local properties = {"build_size", "build_material", "auto_align"}
        local config = {}

        for _, prop in ipairs(properties) do
            local value = tool:getClientInfo(prop)
            if value and value ~= "0" then
                config[prop] = value
            else
                config[prop] = self.ClientConVar[prop] or "1"
            end
        end

        self:ApplyClientConfiguration(config)
        ```
]]
function toolGunMeta:getClientInfo(property)
    return self:getOwner():GetInfo(self:getMode() .. "_" .. property)
end

--[[
    Purpose: Retrieves client-side ConVar information as a number for the current tool mode
    When Called: When the tool needs numeric client configuration values with fallback defaults
    Parameters:
        property (string) - The name of the ConVar property to retrieve
        default (number) - Default value if ConVar is not found or invalid
    Returns: number - The numeric value of the client's ConVar or the default value
    Realm: Shared (accesses client-side data through the owner)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get basic numeric client ConVar
        local size = tool:getClientNumber("build_size", 1)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use numeric client info for calculations
        local count = tool:getClientNumber("object_count", 5)
        local spacing = tool:getClientNumber("build_spacing", 10)

        for i = 1, count do
            local pos = Vector(i * spacing, 0, 0)
            self:CreateObjectAt(pos)
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced numeric configuration with validation
        local numericConfig = {
            ["build_size"] = {default = 1, min = 0.1, max = 10},
            ["build_speed"] = {default = 1, min = 0.1, max = 5},
            ["max_objects"] = {default = 50, min = 1, max = 1000}
        }

        local validatedNumbers = {}
        for prop, config in pairs(numericConfig) do
            local value = tool:getClientNumber(prop, config.default)
            value = math.Clamp(value, config.min, config.max)
            validatedNumbers[prop] = value
        end

        self:ApplyNumericConfiguration(validatedNumbers)
        ```
]]
function toolGunMeta:getClientNumber(property, default)
    return self:getOwner():GetInfoNum(self:getMode() .. "_" .. property, tonumber(default) or 0)
end

--[[
    Purpose: Checks if the tool is allowed to be used based on server configuration
    When Called: Before performing tool operations to verify permissions
    Parameters: None
    Returns: boolean - True if the tool is allowed, false otherwise
    Realm: Shared (client always returns true, server checks ConVar)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic permission check
        if not tool:allowed() then return false end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Permission-based tool behavior
        if tool:allowed() then
            tool:PerformAction()
        else
            tool.Message = "Tool usage not allowed"
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced permission system with logging
        if not tool:allowed() then
            local playerName = tool:GetOwner():Name()
            local toolMode = tool:getMode()
            print(string.format("Player %s attempted to use %s but was denied", playerName, toolMode))

            if SERVER then
                tool:GetOwner():ChatPrint("Tool usage is currently disabled")
            end
            return false
        end

        -- Continue with allowed operation
        tool:PerformAction()
        ```
]]
function toolGunMeta:allowed()
    if CLIENT then return true end
    return self.AllowedCVar:GetBool()
end

--[[
    Purpose: Initializes the tool gun instance (placeholder for custom implementation)
    When Called: When the tool gun is first created or deployed
    Parameters: None
    Returns: None
    Realm: Shared (can be overridden for specific tool initialization)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic initialization
        tool:init()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Initialize with custom setup
        function tool:init()
            self.Stage = 0
            self.LastUpdate = CurTime()
            self.Objects = {}
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced initialization with networking and validation
        function tool:init()
            -- Initialize basic properties
            self.Stage = 0
            self.Objects = {}

            -- Set up networking if server
            if SERVER then
                self:InitializeNetworkChannels()
            end

            -- Load saved data if available
            if file.Exists(self.SavePath, "DATA") then
                self:LoadToolData()
            end

            -- Initialize ghost entity
            self:CreateGhostEntity()

            print("Tool " .. self:getMode() .. " initialized for " .. self:GetOwner():Name())
        end
        ```
]]
function toolGunMeta:init()
end

--[[
    Purpose: Retrieves the current tool mode identifier
    When Called: When other methods need to know which tool mode is active
    Parameters: None
    Returns: string - The current tool mode name
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get current tool mode
        local mode = tool:getMode()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use mode for conditional behavior
        local mode = tool:getMode()
        if mode == "builder" then
            tool:EnableBuildMode()
        elseif mode == "remover" then
            tool:EnableRemoveMode()
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced mode-based configuration and validation
        local mode = tool:getMode()

        -- Validate mode exists and is allowed
        if not self.ToolModes[mode] then
            error("Invalid tool mode: " .. mode)
            return
        end

        -- Apply mode-specific configuration
        local modeConfig = self.ToolModes[mode]
        for setting, value in pairs(modeConfig) do
            self[setting] = value
        end

        -- Initialize mode-specific systems
        self:InitializeModeSystems(mode)
        ```
]]
function toolGunMeta:getMode()
    return self.Mode
end

--[[
    Purpose: Retrieves the SWEP (Scripted Weapon) instance associated with this tool
    When Called: When the tool needs to access the underlying weapon entity
    Parameters: None
    Returns: Weapon - The SWEP entity instance
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get the weapon instance
        local swep = tool:getSWEP()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use SWEP for weapon-specific operations
        local swep = tool:getSWEP()
        if IsValid(swep) then
            local ammo = swep:GetPrimaryAmmoType()
            print("Primary ammo type: " .. ammo)
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced SWEP interaction and validation
        local swep = tool:getSWEP()

        -- Validate SWEP exists and is valid
        if not IsValid(swep) then
            error("Tool SWEP is not valid")
            return
        end

        -- Access weapon properties
        local weaponClass = swep:GetClass()
        local isReloading = swep:IsReloading()

        -- Perform weapon-specific operations
        if weaponClass == "weapon_physgun" then
            self:HandlePhysgunSpecificLogic(swep)
        elseif weaponClass == "weapon_physcannon" then
            self:HandleGravityGunSpecificLogic(swep)
        end

        -- Update tool state based on weapon
        self.LastWeaponCheck = CurTime()
        ```
]]
function toolGunMeta:getSWEP()
    return self.SWEP
end

--[[
    Purpose: Retrieves the player who owns/holds this tool gun
    When Called: When the tool needs to access the owning player for permissions, communication, or data
    Parameters: None
    Returns: Player - The player entity that owns this tool
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get the tool owner
        local owner = tool:GetOwner()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use owner for player-specific operations
        local owner = tool:GetOwner()
        if IsValid(owner) then
            local health = owner:Health()
            tool.Message = "Owner health: " .. health
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced owner validation and management
        local owner = tool:GetOwner()

        -- Validate owner exists and is valid
        if not IsValid(owner) then
            print("Tool has no valid owner")
            return false
        end

        -- Check owner permissions
        if not owner:IsAdmin() and not owner:IsSuperAdmin() then
            tool.Message = "Insufficient permissions"
            return false
        end

        -- Perform owner-specific operations
        local steamID = owner:SteamID()
        local team = owner:Team()

        -- Log tool usage
        print(string.format("Player %s (Team %d) used tool %s",
              owner:Name(), team, tool:getMode()))

        -- Apply team-based restrictions
        if self:HasTeamRestrictions(team) then
            tool.Message = "Your team cannot use this tool"
            return false
        end

        return true
        ```
]]
function toolGunMeta:GetOwner()
    return self:getSWEP().Owner or self.Owner
end

--[[
    Purpose: Retrieves the weapon entity associated with this tool gun
    When Called: When the tool needs to access the weapon entity for physics or rendering operations
    Parameters: None
    Returns: Weapon - The weapon entity instance
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get the weapon entity
        local weapon = tool:getWeapon()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use weapon for position and angle operations
        local weapon = tool:getWeapon()
        if IsValid(weapon) then
            local pos = weapon:GetPos()
            local ang = weapon:GetAngles()
            self.GhostEntity:SetPos(pos + ang:Forward() * 50)
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced weapon interaction and validation
        local weapon = tool:getWeapon()

        -- Validate weapon exists and is valid
        if not IsValid(weapon) then
            print("Tool weapon is not valid")
            return false
        end

        -- Access weapon properties
        local weaponClass = weapon:GetClass()
        local worldModel = weapon:GetModel()

        -- Perform weapon-specific operations
        if weaponClass == "weapon_physgun" then
            -- Handle physics gun specific logic
            local heldEntity = weapon:GetParent()
            if IsValid(heldEntity) then
                self:HandleHeldEntity(heldEntity)
            end
        elseif weaponClass == "weapon_toolgun" then
            -- Handle tool gun specific logic
            local toolMode = self:getMode()
            if toolMode == "builder" then
                self:UpdateGhostEntity()
            end
        end

        -- Update tool state based on weapon
        self.LastWeaponUpdate = CurTime()
        ```
]]
function toolGunMeta:getWeapon()
    return self:getSWEP().Weapon or self.Weapon
end

--[[
    Purpose: Handles left mouse button click interactions (placeholder for custom implementation)
    When Called: When the player left-clicks while holding the tool gun
    Parameters: None
    Returns: boolean - True if the click was handled, false otherwise
    Realm: Shared (can be overridden for specific tool behavior)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic left click handling
        function tool:leftClick()
            print("Left clicked!")
            return true
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Left click with object placement
        function tool:leftClick()
            if not tool:allowed() then return false end

            local trace = self:GetOwner():GetEyeTrace()
            if not trace.Hit then return false end

            local entity = ents.Create("prop_physics")
            entity:SetPos(trace.HitPos)
            entity:Spawn()

            table.insert(self.Objects, {Ent = entity, Time = CurTime()})
            return true
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced left click with validation and networking
        function tool:leftClick()
            local owner = self:GetOwner()

            -- Validate permissions and conditions
            if not self:allowed() then return false end
            if not owner:KeyDown(IN_USE) then return false end

            -- Get target position and validate
            local trace = owner:GetEyeTrace()
            if not trace.Hit or trace.HitWorld then
                self.Message = "Invalid target"
                return false
            end

            -- Check distance and line of sight
            local distance = owner:GetPos():Distance(trace.HitPos)
            if distance > self:getClientNumber("max_distance", 100) then
                self.Message = "Too far away"
                return false
            end

            -- Create object with server validation
            if SERVER then
                local success = self:CreateServerObject(trace.HitPos, trace.HitNormal)
                if success then
                    -- Network to clients
                    net.Start("tool_object_created")
                    net.WriteVector(trace.HitPos)
                    net.Broadcast()
                    return true
                end
            else
                -- Send request to server
                net.Start("tool_create_request")
                net.WriteVector(trace.HitPos)
                net.SendToServer()
                return true
            end

            return false
        end
        ```
]]
function toolGunMeta:leftClick()
    return false
end

--[[
    Purpose: Handles right mouse button click interactions (placeholder for custom implementation)
    When Called: When the player right-clicks while holding the tool gun
    Parameters: None
    Returns: boolean - True if the click was handled, false otherwise
    Realm: Shared (can be overridden for specific tool behavior)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic right click handling
        function tool:rightClick()
            self.Message = "Right clicked!"
            return true
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Right click for object selection/manipulation
        function tool:rightClick()
            local trace = self:GetOwner():GetEyeTrace()
            if not trace.Hit then return false end

            local hitEntity = trace.Entity
            if IsValid(hitEntity) and hitEntity:GetClass() == "prop_physics" then
                self.SelectedEntity = hitEntity
                self.Message = "Selected: " .. hitEntity:GetModel()
                return true
            end

            return false
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced right click with context menus and validation
        function tool:rightClick()
            local owner = self:GetOwner()

            -- Get target and validate
            local trace = owner:GetEyeTrace()
            if not trace.Hit then return false end

            local hitEntity = trace.Entity

            -- Handle different target types
            if trace.HitWorld then
                -- World click - show position info
                self.Message = string.format("World: %.2f, %.2f, %.2f",
                    trace.HitPos.x, trace.HitPos.y, trace.HitPos.z)
                return true

            elseif IsValid(hitEntity) then
                -- Entity click - show context menu or manipulate
                if hitEntity:IsPlayer() then
                    -- Player interaction
                    if owner:KeyDown(IN_SPEED) then
                        self:OpenPlayerMenu(hitEntity)
                    else
                        self.Message = "Hold SHIFT for player menu"
                    end
                    return true

                elseif hitEntity:GetClass() == "prop_physics" then
                    -- Prop manipulation
                    if self:CanManipulateEntity(hitEntity) then
                        if owner:KeyDown(IN_DUCK) then
                            self:RemoveEntity(hitEntity)
                        else
                            self:SelectEntity(hitEntity)
                        end
                        return true
                    end
                end
            end

            return false
        end
        ```
]]
function toolGunMeta:rightClick()
    return false
end

--[[
    Purpose: Handles reload key press to clear/reset tool objects and state
    When Called: When the player presses the reload key (default R) while holding the tool gun
    Parameters: None
    Returns: None
    Realm: Shared (can be overridden for specific tool behavior)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic reload functionality
        function tool:reload()
            self:clearObjects()
            self.Message = "Objects cleared"
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Reload with confirmation and logging
        function tool:reload()
            if #self.Objects == 0 then
                self.Message = "No objects to clear"
                return
            end

            local count = #self.Objects
            self:clearObjects()
            self.Message = string.format("Cleared %d objects", count)

            if SERVER then
                print(string.format("Player %s cleared %d objects",
                    self:GetOwner():Name(), count))
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced reload with backup and networking
        function tool:reload()
            local owner = self:GetOwner()

            -- Check if there are objects to clear
            if #self.Objects == 0 then
                self.Message = "No objects to clear"
                return
            end

            -- Create backup before clearing (if configured)
            if self:getClientInfo("backup_on_reload") == "1" then
                self:CreateBackup()
            end

            -- Clear objects with individual cleanup
            local clearedCount = 0
            for i = #self.Objects, 1, -1 do
                local obj = self.Objects[i]
                if IsValid(obj.Ent) then
                    if SERVER then
                        obj.Ent:Remove()
                    end
                    clearedCount = clearedCount + 1
                end
                table.remove(self.Objects, i)
            end

            -- Reset tool state
            self.Stage = 0
            self.GhostEntity = nil

            -- Notify and log
            self.Message = string.format("Cleared %d objects", clearedCount)

            if SERVER then
                -- Network cleanup confirmation to client
                net.Start("tool_objects_cleared")
                net.WriteUInt(clearedCount, 16)
                net.Send(owner)

                print(string.format("Player %s cleared %d tool objects",
                    owner:Name(), clearedCount))
            end
        end
        ```
]]
function toolGunMeta:reload()
    self:clearObjects()
end

--[[
    Purpose: Handles tool deployment when the weapon is drawn/equipped
    When Called: When the player switches to or initially equips the tool gun
    Parameters: None
    Returns: None
    Realm: Shared (can be overridden for specific tool behavior)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic deploy functionality
        function tool:deploy()
            self.Message = "Tool deployed"
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Deploy with initialization
        function tool:deploy()
            self:releaseGhostEntity()
            self:init()
            self:createConVars()
            self.Message = "Tool ready"
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced deploy with validation and networking
        function tool:deploy()
            local owner = self:GetOwner()

            -- Release any existing ghost entity
            self:releaseGhostEntity()

            -- Initialize tool systems
            self:init()

            -- Create ConVars for this session
            self:createConVars()

            -- Validate tool mode and permissions
            if not self:allowed() then
                self.Message = "Tool usage disabled"
                return
            end

            -- Check if tool mode is valid
            local mode = self:getMode()
            if not self.ToolModes or not self.ToolModes[mode] then
                self.Message = "Invalid tool mode"
                return
            end

            -- Initialize mode-specific systems
            if SERVER then
                -- Server-side initialization
                self:InitializeServerSystems()
                self:LoadPlayerData(owner)

                -- Network tool state to client
                net.Start("tool_deployed")
                net.WriteString(mode)
                net.Send(owner)
            else
                -- Client-side initialization
                self:InitializeClientSystems()
                self:CreateGhostEntity()
            end

            -- Set initial state
            self.Stage = 0
            self.LastDeploy = CurTime()
            self.Message = string.format("%s tool ready", mode)

            print(string.format("Player %s deployed %s tool",
                owner:Name(), mode))
        end
        ```
]]
function toolGunMeta:deploy()
    self:releaseGhostEntity()
end

--[[
    Purpose: Handles tool holstering when the weapon is put away/switched from
    When Called: When the player switches away from the tool gun or puts it away
    Parameters: None
    Returns: None
    Realm: Shared (can be overridden for specific tool behavior)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic holster functionality
        function tool:holster()
            self:releaseGhostEntity()
            self.Message = "Tool holstered"
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Holster with cleanup
        function tool:holster()
            self:releaseGhostEntity()
            self:SaveToolData()
            self.Stage = 0
            self.Message = ""
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced holster with state preservation and networking
        function tool:holster()
            local owner = self:GetOwner()

            -- Release ghost entity and clean up visual elements
            self:releaseGhostEntity()

            -- Save current tool state if configured
            if self:getClientInfo("save_state_on_holster") == "1" then
                self:SaveToolState()
            end

            -- Clean up temporary objects and effects
            self:CleanupTemporaryObjects()

            -- Reset tool state
            self.Stage = 0
            self.LastInteraction = nil
            self.Message = ""

            -- Handle realm-specific cleanup
            if SERVER then
                -- Server-side cleanup
                self:SavePlayerData(owner)
                self:CleanupServerObjects()

                -- Network holster state to client
                net.Start("tool_holstered")
                net.WriteBool(true) -- Successfully holstered
                net.Send(owner)
            else
                -- Client-side cleanup
                self:CleanupClientEffects()
                self:ResetClientState()
            end

            -- Log holster action
            print(string.format("Player %s holstered %s tool",
                owner:Name(), self:getMode()))
        end
        ```
]]
function toolGunMeta:holster()
    self:releaseGhostEntity()
end

--[[
    Purpose: Main think function called every frame while the tool is active (placeholder for custom implementation)
    When Called: Every frame/tick while the tool gun is deployed and active
    Parameters: None
    Returns: None
    Realm: Shared (can be overridden for specific tool behavior)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic per-frame updates
        function tool:think()
            self:releaseGhostEntity()
            self:updateData()
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Think with ghost entity management
        function tool:think()
            local owner = self:GetOwner()

            -- Update ghost entity position if it exists
            if not IsValid(self.GhostEntity) then
                self:CreateGhostEntity()
            else
                local trace = owner:GetEyeTrace()
                if trace.Hit then
                    self.GhostEntity:SetPos(trace.HitPos)
                    self.GhostEntity:SetAngles(trace.HitNormal:Angle())
                end
            end

            -- Update tool state
            self:updateData()
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced think with multiple systems and networking
        function tool:think()
            local owner = self:GetOwner()
            local curTime = CurTime()

            -- Rate limiting for performance
            if not self.LastThink or curTime - self.LastThink > 0.1 then
                self.LastThink = curTime

                -- Update ghost entity with advanced positioning
                self:UpdateGhostEntity()

                -- Check object validity and cleanup invalid ones
                self:checkObjects()

                -- Update tool data and state
                self:updateData()

                -- Handle player input and interactions
                if owner:KeyDown(IN_ATTACK) and not self.LastLeftClick then
                    self:leftClick()
                    self.LastLeftClick = true
                elseif not owner:KeyDown(IN_ATTACK) then
                    self.LastLeftClick = false
                end

                -- Network updates to clients (server only)
                if SERVER and curTime - (self.LastNetworkUpdate or 0) > 1.0 then
                    self:NetworkToolState()
                    self.LastNetworkUpdate = curTime
                end

                -- Update effects and visual feedback
                self:UpdateVisualEffects()

                -- Check for tool mode changes
                if self:ShouldChangeMode() then
                    self:ChangeToolMode()
                end
            end
        end
        ```
]]
function toolGunMeta:think()
    self:releaseGhostEntity()
end

--[[
    Purpose: Validates and cleans up invalid objects in the tool's object list
    When Called: Periodically during tool operation to maintain object integrity
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic object validation
        function tool:checkObjects()
            for _, v in pairs(self.Objects) do
                if not IsValid(v.Ent) then
                    self:clearObjects()
                end
            end
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check objects with individual cleanup
        function tool:checkObjects()
            local invalidObjects = {}

            for i, v in pairs(self.Objects) do
                if not IsValid(v.Ent) or v.Ent:IsWorld() then
                    table.insert(invalidObjects, i)
                end
            end

            -- Remove invalid objects
            for i = #invalidObjects, 1, -1 do
                table.remove(self.Objects, invalidObjects[i])
            end

            if #invalidObjects > 0 then
                self.Message = string.format("Cleaned up %d invalid objects", #invalidObjects)
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced object validation with networking and logging
        function tool:checkObjects()
            local owner = self:GetOwner()
            local invalidObjects = {}
            local removedCount = 0

            for i, obj in pairs(self.Objects) do
                local isValid = true

                -- Multiple validation checks
                if not IsValid(obj.Ent) then
                    isValid = false
                elseif obj.Ent:IsWorld() then
                    isValid = false
                elseif SERVER and obj.Ent:GetPos():Distance(owner:GetPos()) > 5000 then
                    -- Server-side distance check
                    isValid = false
                elseif CLIENT and not obj.Ent:GetNoDraw() == false then
                    -- Client-side visibility check
                    isValid = false
                end

                if not isValid then
                    table.insert(invalidObjects, i)

                    -- Handle object cleanup
                    if SERVER and IsValid(obj.Ent) then
                        obj.Ent:Remove()
                    end

                    removedCount = removedCount + 1
                end
            end

            -- Remove invalid object references
            for i = #invalidObjects, 1, -1 do
                table.remove(self.Objects, invalidObjects[i])
            end

            -- Handle results
            if removedCount > 0 then
                self.Message = string.format("Cleaned up %d invalid objects", removedCount)

                if SERVER then
                    -- Network cleanup to clients
                    net.Start("tool_objects_cleaned")
                    net.WriteUInt(removedCount, 8)
                    net.Broadcast()

                    -- Log cleanup action
                    print(string.format("Player %s had %d invalid tool objects cleaned up",
                        owner:Name(), removedCount))
                end
            end

            -- Update cleanup timestamp
            self.LastObjectCheck = CurTime()
        end
        ```
]]
function toolGunMeta:checkObjects()
    for _, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not IsValid(v.Ent) then self:clearObjects() end
    end
end

--[[
    Purpose: Completely clears all objects from the tool's object list and performs cleanup
    When Called: When explicitly clearing all tool objects or during error recovery
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic object clearing
        tool:clearObjects()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Clear with confirmation message
        function tool:clearObjects()
            local count = #self.Objects
            self.Objects = {}
            self.Message = string.format("Cleared %d objects", count)
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced clearing with individual cleanup and networking
        function tool:clearObjects()
            local owner = self:GetOwner()
            local clearedCount = #self.Objects

            if clearedCount == 0 then return end

            -- Clean up each object individually
            for _, obj in pairs(self.Objects) do
                if SERVER and IsValid(obj.Ent) then
                    -- Server-side entity cleanup
                    obj.Ent:Remove()

                    -- Remove associated data
                    if obj.Data then
                        self:CleanupObjectData(obj.Data)
                    end
                end
            end

            -- Clear the objects table
            self.Objects = {}

            -- Reset related state
            self.Stage = 0
            self.SelectedEntity = nil

            -- Update UI and notify
            self.Message = string.format("Cleared %d objects", clearedCount)

            if SERVER then
                -- Network clear confirmation to client
                net.Start("tool_objects_cleared")
                net.WriteUInt(clearedCount, 16)
                net.Send(owner)

                -- Log the clearing action
                print(string.format("Player %s cleared all %d tool objects",
                    owner:Name(), clearedCount))

                -- Save state after clearing
                self:SaveToolState()
            end

            -- Reset ghost entity if needed
            if IsValid(self.GhostEntity) then
                self:releaseGhostEntity()
            end
        end
        ```
]]
function toolGunMeta:clearObjects()
    self.Objects = {}
end

--[[
    Purpose: Safely removes and cleans up the ghost entity used for preview/placement
    When Called: When switching tools, holstering, or when the ghost entity is no longer needed
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Basic ghost entity cleanup
        tool:releaseGhostEntity()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Release with effects cleanup
        function tool:releaseGhostEntity()
            if IsValid(self.GhostEntity) then
                -- Remove associated effects
                if self.GhostEffects then
                    for _, effect in pairs(self.GhostEffects) do
                        effect:Remove()
                    end
                    self.GhostEffects = nil
                end

                SafeRemoveEntity(self.GhostEntity)
                self.GhostEntity = nil
                self.Message = "Ghost entity removed"
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Advanced ghost entity management with networking
        function tool:releaseGhostEntity()
            local owner = self:GetOwner()

            if IsValid(self.GhostEntity) then
                -- Store ghost entity data before removal (if needed)
                if self:getClientInfo("preserve_ghost_data") == "1" then
                    self.LastGhostData = {
                        Model = self.GhostEntity:GetModel(),
                        Pos = self.GhostEntity:GetPos(),
                        Ang = self.GhostEntity:GetAngles(),
                        Time = CurTime()
                    }
                end

                -- Clean up associated effects and particles
                self:CleanupGhostEffects()

                -- Remove the ghost entity safely
                SafeRemoveEntity(self.GhostEntity)
                self.GhostEntity = nil

                -- Reset ghost-related state
                self.GhostStage = 0
                self.GhostLastUpdate = nil

                -- Update UI
                self.Message = "Preview removed"

                if SERVER then
                    -- Network ghost removal to clients
                    net.Start("tool_ghost_removed")
                    net.WriteEntity(owner)
                    net.Broadcast()

                    -- Log ghost entity removal
                    print(string.format("Player %s removed ghost entity for %s tool",
                        owner:Name(), self:getMode()))
                else
                    -- Client-side cleanup confirmation
                    self:ResetGhostMaterials()
                end
            end
        end
        ```
]]
function toolGunMeta:releaseGhostEntity()
    if IsValid(self.GhostEntity) then
        SafeRemoveEntity(self.GhostEntity)
        self.GhostEntity = nil
    end
end

lia.meta.tool = toolGunMeta
