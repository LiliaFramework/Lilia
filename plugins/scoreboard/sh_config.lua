lia.config.add("sbWidth", 0.325, "Scoreboard's width within percent of screen width.", function(oldValue, newValue)
    if CLIENT and IsValid(lia.gui.score) then
        lia.gui.score:Remove()
    end
end, {
    form = "Float",
    category = "visual",
    data = {
        min = 0.2,
        max = 1
    }
})

lia.config.add("sbHeight", 0.825, "Scoreboard's height within percent of screen height.", function(oldValue, newValue)
    if CLIENT and IsValid(lia.gui.score) then
        lia.gui.score:Remove()
    end
end, {
    form = "Float",
    category = "visual",
    data = {
        min = 0.3,
        max = 1
    }
})

lia.config.add("sbTitle", GetHostName(), "The title of the scoreboard.", function(oldValue, newValue)
    if CLIENT and IsValid(lia.gui.score) then
        lia.gui.score:Remove()
    end
end, {
    category = "visual"
})

lia.config.add("sbRecog", true, "Whether or not recognition is used in the scoreboard.", nil, {
    category = "characters"
})