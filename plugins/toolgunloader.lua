local PLUGIN = PLUGIN
PLUGIN.name = "Toolgun Tool Loader"
PLUGIN.desc = "Allows plugins to easily load new tools for the toolgun."
PLUGIN.ToolObj = PLUGIN.ToolObj or {}
local ToolObj = PLUGIN.ToolObj
local SWEP = weapons.GetStored("gmod_tool")

function ToolObj:Create()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.Mode = nil
    o.SWEP = nil
    o.Owner = nil
    o.ClientConVar = {}
    o.ServerConVar = {}
    o.Objects = {}
    o.Stage = 0
    o.Message = "start"
    o.LastMessage = 0
    o.AllowedCVar = 0

    return o
end

function ToolObj:CreateConVars()
    local mode = self:GetMode()

    if CLIENT then
        for cvar, default in pairs(self.ClientConVar) do
            CreateClientConVar(mode .. "_" .. cvar, default, true, true)
        end

        return
    end

    -- Note: I changed this from replicated because replicated convars don't work
    -- when they're created via Lua.
    if SERVER then
        self.AllowedCVar = CreateConVar("toolmode_allow_" .. mode, 1, FCVAR_NOTIFY)

        for cvar, default in pairs(self.ServerConVar) do
            CreateConVar(mode .. "_" .. cvar, default, FCVAR_ARCHIVE)
        end
    end
end

function ToolObj:GetServerInfo(property)
    local mode = self:GetMode()

    return GetConVarString(mode .. "_" .. property)
end

function ToolObj:BuildConVarList()
    local mode = self:GetMode()
    local convars = {}

    for k, v in pairs(self.ClientConVar) do
        convars[mode .. "_" .. k] = v
    end

    return convars
end

function ToolObj:GetClientInfo(property)
    return self:GetOwner():GetInfo(self:GetMode() .. "_" .. property)
end

function ToolObj:GetClientNumber(property, default)
    return self:GetOwner():GetInfoNum(self:GetMode() .. "_" .. property, tonumber(default) or 0)
end

function ToolObj:Allowed()
    if CLIENT then return true end

    return self.AllowedCVar:GetBool()
end

-- Now for all the ToolObj redirects
function ToolObj:Init()
end

function ToolObj:GetMode()
    return self.Mode
end

function ToolObj:GetSWEP()
    return self.SWEP
end

function ToolObj:GetOwner()
    return self:GetSWEP().Owner or self.Owner
end

function ToolObj:GetWeapon()
    return self:GetSWEP().Weapon or self.Weapon
end

function ToolObj:LeftClick()
    return false
end

function ToolObj:RightClick()
    return false
end

function ToolObj:Reload()
    self:ClearObjects()
end

function ToolObj:Deploy()
    self:ReleaseGhostEntity()

    return
end

function ToolObj:Holster()
    self:ReleaseGhostEntity()

    return
end

function ToolObj:Think()
    self:ReleaseGhostEntity()
end

--[[---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
-----------------------------------------------------------]]
function ToolObj:CheckObjects()
    for k, v in pairs(self.Objects) do
        if not v.Ent:IsWorld() and not v.Ent:IsValid() then
            self:ClearObjects()
        end
    end
end

function ToolObj:UpdateData()
    self:SetStage(self:NumObjects())
end

function ToolObj:SetStage(i)
    if SERVER then
        self:GetWeapon():SetNWInt("Stage", i, true)
    end
end

function ToolObj:GetStage()
    return self:GetWeapon():GetNWInt("Stage", 0)
end

function ToolObj:SetOperation(i)
    if SERVER then
        self:GetWeapon():SetNWInt("Op", i, true)
    end
end

function ToolObj:GetOperation()
    return self:GetWeapon():GetNWInt("Op", 0)
end

-- Clear the selected objects
function ToolObj:ClearObjects()
    self:ReleaseGhostEntity()
    self.Objects = {}
    self:SetStage(0)
    self:SetOperation(0)
end

--[[---------------------------------------------------------
	Since we're going to be expanding this a lot I've tried
	to add accessors for all of this crap to make it harder
	for us to mess everything up.
-----------------------------------------------------------]]
function ToolObj:GetEnt(i)
    if not self.Objects[i] then return NULL end

    return self.Objects[i].Ent
end

--[[---------------------------------------------------------
	Returns the world position of the numbered object hit
	We store it as a local vector then convert it to world
	That way even if the object moves it's still valid
-----------------------------------------------------------]]
function ToolObj:GetPos(i)
    if self.Objects[i].Ent:EntIndex() == 0 then
        return self.Objects[i].Pos
    else
        if IsValid(self.Objects[i].Phys) then
            return self.Objects[i].Phys:LocalToWorld(self.Objects[i].Pos)
        else
            return self.Objects[i].Ent:LocalToWorld(self.Objects[i].Pos)
        end
    end
end

-- Returns the local position of the numbered hit
function ToolObj:GetLocalPos(i)
    return self.Objects[i].Pos
end

-- Returns the physics bone number of the hit (ragdolls)
function ToolObj:GetBone(i)
    return self.Objects[i].Bone
end

function ToolObj:GetNormal(i)
    if self.Objects[i].Ent:EntIndex() == 0 then
        return self.Objects[i].Normal
    else
        local norm

        if IsValid(self.Objects[i].Phys) then
            norm = self.Objects[i].Phys:LocalToWorld(self.Objects[i].Normal)
        else
            norm = self.Objects[i].Ent:LocalToWorld(self.Objects[i].Normal)
        end

        return norm - self:GetPos(i)
    end
end

-- Returns the physics object for the numbered hit
function ToolObj:GetPhys(i)
    if self.Objects[i].Phys == nil then return self:GetEnt(i):GetPhysicsObject() end

    return self.Objects[i].Phys
end

-- Sets a selected object
function ToolObj:SetObject(i, ent, pos, phys, bone, norm)
    self.Objects[i] = {}
    self.Objects[i].Ent = ent
    self.Objects[i].Phys = phys
    self.Objects[i].Bone = bone
    self.Objects[i].Normal = norm

    -- Worldspawn is a special case
    if ent:EntIndex() == 0 then
        self.Objects[i].Phys = nil
        self.Objects[i].Pos = pos
    else
        norm = norm + pos

        -- Convert the position to a local position - so it's still valid when the object moves
        if IsValid(phys) then
            self.Objects[i].Normal = self.Objects[i].Phys:WorldToLocal(norm)
            self.Objects[i].Pos = self.Objects[i].Phys:WorldToLocal(pos)
        else
            self.Objects[i].Normal = self.Objects[i].Ent:WorldToLocal(norm)
            self.Objects[i].Pos = self.Objects[i].Ent:WorldToLocal(pos)
        end
    end

    if SERVER then end -- Todo: Make sure the client got the same info
end

-- Returns the number of objects in the list
function ToolObj:NumObjects()
    if CLIENT then return self:GetStage() end

    return #self.Objects
end

-- Returns the number of objects in the list
function ToolObj:GetHelpText()
    return "#tool." .. GetConVarString("gmod_toolmode") .. "." .. self:GetStage()
end

--[[---------------------------------------------------------
	Starts up the ghost entity
	The most important part of this is making sure it gets deleted properly
-----------------------------------------------------------]]
function ToolObj:MakeGhostEntity(model, pos, angle)
    util.PrecacheModel(model)
    -- We do ghosting serverside in single player
    -- It's done clientside in multiplayer
    if SERVER and not game.SinglePlayer() then return end
    if CLIENT and game.SinglePlayer() then return end
    -- The reason we need this is because in multiplayer, when you holster a tool serverside,
    -- either by using the spawnnmenu's Weapons tab or by simply entering a vehicle,
    -- the Think hook is called once after Holster is called on the client, recreating the ghost entity right after it was removed.
    if not IsFirstTimePredicted() then return end
    -- Release the old ghost entity
    self:ReleaseGhostEntity()
    -- Don't allow ragdolls/effects to be ghosts
    if not util.IsValidProp(model) then return end

    if CLIENT then
        self.GhostEntity = ents.CreateClientProp(model)
    else
        self.GhostEntity = ents.Create("prop_physics")
    end

    -- If there's too many entities we might not spawn..
    if not IsValid(self.GhostEntity) then
        self.GhostEntity = nil

        return
    end

    self.GhostEntity:SetModel(model)
    self.GhostEntity:SetPos(pos)
    self.GhostEntity:SetAngles(angle)
    self.GhostEntity:Spawn()
    -- We do not want physics at all
    self.GhostEntity:PhysicsDestroy()
    -- SOLID_NONE causes issues with Entity.NearestPoint used by Wheel tool
    --self.GhostEntity:SetSolid( SOLID_NONE )
    self.GhostEntity:SetMoveType(MOVETYPE_NONE)
    self.GhostEntity:SetNotSolid(true)
    self.GhostEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self.GhostEntity:SetColor(Color(255, 255, 255, 150))
end

--[[---------------------------------------------------------
	Starts up the ghost entity
	The most important part of this is making sure it gets deleted properly
-----------------------------------------------------------]]
function ToolObj:StartGhostEntity(ent)
    -- We do ghosting serverside in single player
    -- It's done clientside in multiplayer
    if SERVER and not game.SinglePlayer() then return end
    if CLIENT and game.SinglePlayer() then return end
    self:MakeGhostEntity(ent:GetModel(), ent:GetPos(), ent:GetAngles())
end

--[[---------------------------------------------------------
	Releases up the ghost entity
-----------------------------------------------------------]]
function ToolObj:ReleaseGhostEntity()
    if self.GhostEntity then
        if not IsValid(self.GhostEntity) then
            self.GhostEntity = nil

            return
        end

        self.GhostEntity:Remove()
        self.GhostEntity = nil
    end

    -- This is unused!
    if self.GhostEntities then
        for k, v in pairs(self.GhostEntities) do
            if IsValid(v) then
                v:Remove()
            end

            self.GhostEntities[k] = nil
        end

        self.GhostEntities = nil
    end

    -- This is unused!
    if self.GhostOffset then
        for k, v in pairs(self.GhostOffset) do
            self.GhostOffset[k] = nil
        end
    end
end

--[[---------------------------------------------------------
	Update the ghost entity
-----------------------------------------------------------]]
function ToolObj:UpdateGhostEntity()
    if self.GhostEntity == nil then return end

    if not IsValid(self.GhostEntity) then
        self.GhostEntity = nil

        return
    end

    local trace = self:GetOwner():GetEyeTrace()
    if not trace.Hit then return end
    local Ang1, Ang2 = self:GetNormal(1):Angle(), (trace.HitNormal * -1):Angle()
    local TargetAngle = self:GetEnt(1):AlignAngles(Ang1, Ang2)
    self.GhostEntity:SetPos(self:GetEnt(1):GetPos())
    self.GhostEntity:SetAngles(TargetAngle)
    local TranslatedPos = self.GhostEntity:LocalToWorld(self:GetLocalPos(1))
    local TargetPos = trace.HitPos + (self:GetEnt(1):GetPos() - TranslatedPos) + trace.HitNormal
    self.GhostEntity:SetPos(TargetPos)
end

if CLIENT then
    -- Tool should return true if freezing the view angles
    function ToolObj:FreezeMovement()
        return false
    end

    -- The tool's opportunity to draw to the HUD
    function ToolObj:DrawHUD()
    end
end

--[[
	Load Tool into spawnmenu
]]
if CLIENT then
    -- Keep the tool list handy
    local TOOLS_LIST = SWEP.Tool

    -- Add the STOOLS to the tool menu
    hook.Add("PopulateToolMenu", "AddSToolsToMenu", function()
        for ToolName, TOOL in pairs(TOOLS_LIST) do
            if TOOL.AddToMenu ~= false then
                spawnmenu.AddToolMenuOption(TOOL.Tab or "Main", TOOL.Category or "New Category", ToolName, TOOL.Name or "#" .. ToolName, TOOL.Command or "gmod_tool " .. ToolName, TOOL.ConfigName or ToolName, TOOL.BuildCPanel)
            end
        end
    end)

    --
    -- Search
    --
    search.AddProvider(function(str)
        local list = {}

        for k, v in pairs(TOOLS_LIST) do
            local niceName = v.Name or "#" .. k

            if niceName:StartWith("#") then
                niceName = language.GetPhrase(niceName:sub(2))
            end

            if not k:lower():find(str, nil, true) and not niceName:lower():find(str, nil, true) then continue end

            local entry = {
                text = niceName,
                icon = spawnmenu.CreateContentIcon("tool", nil, {
                    spawnname = k,
                    nicename = v.Name or "#" .. k
                }),
                words = {k}
            }

            table.insert(list, entry)
            if #list >= GetConVarNumber("sbox_search_maxresults") / 32 then break end
        end

        return list
    end)
end

--[[
	Hooks
]]
function PLUGIN:InitializedPlugins()
    for id, plugin in next, lia.plugin.list do
        self:LoadTools(id)
    end

    if CLIENT then
        RunConsoleCommand("spawnmenu_reload")
    end
end

--[[
	Methods
]]
function PLUGIN:LoadTools(pluginID)
    local plugin = lia.plugin.list[pluginID]
    local files = file.Find(plugin.path .. "/stools/*.lua", "LUA")

    for _, tool in ipairs(files) do
        local char1, char2, toolmode = string.find(tool, "([%w_]*).lua")
        TOOL = ToolObj:Create()
        TOOL.Mode = toolmode
        AddCSLuaFile(plugin.path .. "/stools/" .. tool)
        include(plugin.path .. "/stools/" .. tool)
        TOOL:CreateConVars()
        SWEP.Tool[toolmode] = TOOL
        TOOL = nil
    end
end