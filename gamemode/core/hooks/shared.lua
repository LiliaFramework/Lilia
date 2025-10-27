local GM = GM or GAMEMODE
function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

function GM:GetModelGender(model)
    local isFemale = model:find("alyx") or model:find("mossman") or model:find("female")
    return isFemale and "female" or "male"
end

function GM:OnReloaded()
    print("Client reload triggered!")
    lia.reloadInProgress = true
    lia.module.initialize()
    lia.config.load()
    chat.AddText(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("gamemodeHotreloadedSuccessfully"))
    lia.faction.formatModelData()
    lia.reloadInProgress = false
end