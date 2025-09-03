local GM = GM or GAMEMODE
function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

function GM:GetModelGender(client, model)
    model = model and model or client:GetModel():lower()
    local isFemale = model:find("alyx") or model:find("mossman") or model:find("female")
    return isFemale and "female" or "male"
end

function GM:GetPlayerGender(client, model)
    return self:GetModelGender(client, model)
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