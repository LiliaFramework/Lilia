local GM = GM or GAMEMODE
function GM:Move(client, moveData)
    local character = client:getChar()
    if not character then return end
    local runSpeed = lia.config.get("RunSpeed", 235)
    local runSpeedNoModifier = runSpeed
    local runSpeedModifier = runSpeed / 2.5
    if client:KeyDown(IN_FORWARD) then
        moveData:SetMaxSpeed(runSpeedNoModifier)
    elseif client:KeyDown(IN_MOVELEFT) or client:KeyDown(IN_MOVERIGHT) or client:KeyDown(IN_BACK) then
        moveData:SetMaxSpeed(runSpeedModifier)
    end

    if client:GetMoveType() == MOVETYPE_WALK and moveData:KeyDown(IN_WALK) then
        local forwardMult, sideMult = 0, 0
        local speed = client:GetWalkSpeed()
        local ratio = lia.config.get("WalkRatio")
        if moveData:KeyDown(IN_FORWARD) then
            forwardMult = ratio
        elseif moveData:KeyDown(IN_BACK) then
            forwarwMult = -ratio
        end

        if moveData:KeyDown(IN_MOVELEFT) then
            sideMult = -ratio
        elseif moveData:KeyDown(IN_MOVERIGHT) then
            sideMult = ratio
        end

        moveData:SetForwardSpeed(forwardMult * speed)
        moveData:SetSideSpeed(sideMult * speed)
    end
end

function GM:SetupMove(client, cMoveData)
    local character = client:getChar()
    if not character then return end
    local maxStamina = character:getMaxStamina()
    local stamina = client:getLocalVar("stamina", maxStamina)
    local walkSpeed = lia.config.get("WalkSpeed")
    local runSpeed = lia.config.get("RunSpeed") + (character:getAttrib("stamina", 0) or 0)
    local slowState = client:getNetVar("slow", false)
    local slowThreshold = maxStamina * 0.15
    if slowState then
        cMoveData:SetMaxClientSpeed(walkSpeed * 0.5)
        return
    end

    if stamina <= 0 then
        client:setNetVar("slow", true)
        cMoveData:SetMaxClientSpeed(walkSpeed * 0.5)
    elseif stamina <= slowThreshold then
        cMoveData:SetMaxClientSpeed(walkSpeed)
    elseif client:WaterLevel() > 1 then
        cMoveData:SetMaxClientSpeed(runSpeed * 0.775)
    end
end

function GM:InitPostEntity()
    if SERVER then
        lia.faction.formatModelData()
        timer.Simple(2, function() lia.entityDataLoaded = true end)
        lia.db.waitForTablesToLoad():next(function()
            hook.Run("LoadData")
            hook.Run("PostLoadData")
        end)
    else
        lia.joinTime = RealTime() - 0.9716
        if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
    end
end

function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

function GM:GetDefaultInventoryType()
    return lia.module.list["weightinv"] and "WeightInv" or "GridInv"
end

local GamemodeFunctions = {
    server = {
        {
            name = "PlayerSpray",
            returnValue = true
        },
        {
            name = "PlayerDeathSound",
            returnValue = true
        },
        {
            name = "CanPlayerSuicide",
            returnValue = false
        },
        {
            name = "AllowPlayerPickup",
            returnValue = false
        },
        {
            name = "CharacterLoaded",
            args = {"id"},
            replacement = "CharLoaded"
        },
        {
            name = "PreCharacterDelete",
            args = {"id"},
            replacement = "PreCharDelete"
        },
        {
            name = "OnCharacterDelete",
            args = {"client", "id"},
            replacement = "OnCharDelete"
        },
        {
            name = "onCharCreated",
            args = {"client", "character", "data"},
            replacement = "OnCharCreated"
        },
        {
            name = "onTransferred",
            args = {"client"},
            replacement = "OnTransferred"
        },
        {
            name = "CharacterPreSave",
            args = {"character"},
            replacement = "CharPreSave"
        }
    },
    client = {
        {
            name = "HUDDrawTargetID",
            returnValue = false
        },
        {
            name = "HUDDrawPickupHistory",
            returnValue = false
        },
        {
            name = "HUDAmmoPickedUp",
            returnValue = false
        },
        {
            name = "DrawDeathNotice",
            returnValue = false
        },
        {
            name = "CanDisplayCharacterInfo",
            args = {"client", "id"},
            replacement = "CanDisplayCharInfo"
        },
        {
            name = "KickedFromCharacter",
            args = {"id", "isCurrentChar"},
            replacement = "KickedFromChar"
        },
        {
            name = "CharacterListLoaded",
            args = {"newCharList"},
            replacement = "CharListLoaded"
        },
        {
            name = "CharacterListUpdated",
            args = {"oldCharList", "newCharList"},
            replacement = "CharListUpdated"
        }
    },
    shared = {
        {
            name = "CharacterMaxStamina",
            args = {"character"},
            replacement = "getCharMaxStamina"
        },
        {
            name = "GetMaxPlayerCharacter",
            args = {"client"},
            replacement = "GetMaxPlayerChar"
        },
        {
            name = "LoadFonts",
            args = {"..."},
            replacement = "PostLoadFonts"
        },
        {
            name = "CanPlayerCreateCharacter",
            args = {"client"},
            replacement = "CanPlayerCreateChar"
        }
    }
}

local function registerFunctions(scope)
    for _, f in ipairs(GamemodeFunctions[scope]) do
        if f.returnValue ~= nil then
            GM[f.name] = function() return f.returnValue end
        elseif f.replacement then
            GM[f.name] = function(...)
                local args = {...}
                lia.deprecated(f.name, function() hook.Run(f.replacement, unpack(args)) end)
            end
        end
    end
end

if SERVER then registerFunctions("server") end
if CLIENT then registerFunctions("client") end
registerFunctions("shared")