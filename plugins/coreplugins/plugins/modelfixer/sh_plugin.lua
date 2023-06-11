local PLUGIN = PLUGIN
PLUGIN.name = "T-Pose Fixer"
PLUGIN.author = "DoopieWop/Leonheart"
PLUGIN.description = "Attempts to fix T-Posing for models."
PLUGIN.cached = PLUGIN.cached or {}

local translations = {
    male_shared = "citizen_male",
    female_shared = "citizen_female",
    police_animations = "metrocop",
    combine_soldier_anims = "overwatch",
    vortigaunt_anims = "vortigaunt",
    m_anm = "player",
    f_anm = "player",
}

local og = lia.anim.setModelClass

function lia.anim.setModelClass(model, class)
    if not lia.anim[class] then return end
    PLUGIN.cached[model] = class
    og(model, class)
end

local function UpdateAnimationTable(client)
    local baseTable = lia.anim[client.liaAnimModelClass] or {}
    client.liaAnimTable = baseTable[client.liaAnimHoldType]
    client.liaAnimGlide = baseTable["glide"]
end

function PLUGIN:PlayerModelChanged(ply, model)
    if not IsValid(ply) then return end

    timer.Simple(0, function()
        if not IsValid(ply) then return end

        if not self.cached[model] then
            local submodels = ply:GetSubModels()

            for k, v in pairs(submodels) do
                local class = v.name:gsub(".*/([^/]+)%.%w+$", "%1"):lower()

                if translations[class] then
                    lia.anim.setModelClass(model, translations[class])
                    break
                end
            end
        end

        ply.liaAnimModelClass = lia.anim.getModelClass(model)
        UpdateAnimationTable(ply)
    end)
end