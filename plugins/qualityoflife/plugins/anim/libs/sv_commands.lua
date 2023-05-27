local PLUGIN = PLUGIN
lia.command.add("surrender", {
    onRun = function(client, arguments)
        if not client:GetNWBool("animationStatus") then
            PLUGIN:ToggleAnimaton(client, true, "surrender_animation_swep", 0)
        else
            PLUGIN:ToggleAnimaton(client, false)

            timer.Simple(0.5, function()
                PLUGIN:ToggleAnimaton(client, true, "surrender_animation_swep", 0)
            end)
        end
    end
})

lia.command.add("salute", {
    onRun = function(client, arguments)
        if not client:GetNWBool("animationStatus") then
            PLUGIN:ToggleAnimaton(client, true, "salute_swep", 0)
        else
            PLUGIN:ToggleAnimaton(client, false)

            timer.Simple(0.5, function()
                PLUGIN:ToggleAnimaton(client, true, "salute_swep", 0)
            end)
        end
    end
})

lia.command.add("crossarms", {
    onRun = function(client, arguments)
        if not client:GetNWBool("animationStatus") then
            PLUGIN:ToggleAnimaton(client, true, "cross_arms_swep", 0)
        else
            PLUGIN:ToggleAnimaton(client, false)

            timer.Simple(0.5, function()
                PLUGIN:ToggleAnimaton(client, true, "cross_arms_swep", 0)
            end)
        end
    end
})

lia.command.add("atease", {
    onRun = function(client, arguments)
        if not client:GetNWBool("animationStatus") then
            PLUGIN:ToggleAnimaton(client, true, "atease_swep", 0)
        else
            PLUGIN:ToggleAnimaton(client, false)

            timer.Simple(0.5, function()
                PLUGIN:ToggleAnimaton(client, true, "atease_swep", 0)
            end)
        end
    end
})

lia.command.add("attention", {
    onRun = function(client, arguments)
        if not client:GetNWBool("animationStatus") then
            PLUGIN:ToggleAnimaton(client, true, "attention_swep", 0)
        else
            PLUGIN:ToggleAnimaton(client, false)

            timer.Simple(0.5, function()
                PLUGIN:ToggleAnimaton(client, true, "attention_swep", 0)
            end)
        end
    end
})

lia.command.add("timedsalute", {
    onRun = function(client, arguments)
        if not client:GetNWBool("animationStatus") then
            PLUGIN:ToggleAnimaton(client, true, "salute_swep", 0)

            timer.Simple(3, function()
                PLUGIN:ToggleAnimaton(client, false)
            end)
        else
            PLUGIN:ToggleAnimaton(client, false)

            timer.Simple(0.5, function()
                PLUGIN:ToggleAnimaton(client, true, "salute_swep", 0)
            end)
        end
    end
})