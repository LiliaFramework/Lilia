local translations = {}

function lia.anim.setModelClass(model, class)
    if not lia.anim[class] then
        error("'" .. tostring(class) .. "' is not a valid animation class!")
    end

    translations[model:lower()] = class
end

local stringLower = string.lower
local stringFind = string.find

function lia.anim.getModelClass(model)
    model = stringLower(model)
    local class = translations[model]
    if class then return class end

    if model:find("/player") then
        class = "player"
    elseif stringFind(model, "female") then
        class = "citizen_female"
    else
        class = "citizen_male"
    end

    lia.anim.setModelClass(model, class)

    return class
end

for model, animtype in pairs(lia.anim.DefaultTposingFixer) do
    lia.anim.setModelClass(model, animtype)
end

for model, animtype in pairs(lia.anim.PlayerModelTposingFixer) do
    lia.anim.setModelClass(model, animtype)
end