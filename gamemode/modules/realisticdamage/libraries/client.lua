local GM = GM or GAMEMODE
local healthPercent = {
    {
        threshold = 0.2,
        text = "Critical Condition",
        color = Color(192, 57, 43)
    },
    {
        threshold = 0.4,
        text = "Serious Injury",
        color = Color(231, 76, 60)
    },
    {
        threshold = 0.6,
        text = "Moderate Injury",
        color = Color(255, 152, 0)
    },
    {
        threshold = 0.8,
        text = "Minor Injury",
        color = Color(255, 193, 7)
    },
    {
        threshold = 1.0,
        text = "Healthy",
        color = Color(46, 204, 113)
    }
}

function GM:GetInjuredText(c)
    local h = c:Health()
    local mh = c:GetMaxHealth() or 100
    local p = h / mh
    for _, entry in ipairs(healthPercent) do
        if p <= entry.threshold then return {entry.text, entry.color} end
    end

    local last = healthPercent[#healthPercent]
    return {last.text, last.color}
end

function GM:DrawCharInfo(c, character, info)
    local injured = hook.Run("GetInjuredText", c)
    if injured then
        info[#info + 1] = {
            section = "Status"
        }

        info[#info + 1] = {
            label = "Condition",
            value = tostring(injured[1])
        }
    end
end