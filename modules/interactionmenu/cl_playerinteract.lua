--------------------------------------------------------------------------------------------------------
function lia.playerInteract.addFunc(name, data)
    lia.playerInteract.funcs[name] = data
end
--------------------------------------------------------------------------------------------------------
function lia.playerInteract.interact(entity, time)
    lia.playerInteract.currentEnt = entity
    interactPressTime = CurTime() + (time or 1)
    cachedPitch = LocalPlayer():EyeAngles().p
    isInteracting = true
end
--------------------------------------------------------------------------------------------------------
function lia.playerInteract.clear()
    isInteracting = false
    cachedPitch = 0
    interactPressTime = 0
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
for name, vars in pairs(lia.config.PlayerInteractionOptions) do
    lia.playerInteract.addFunc(
        name,
        {
            name = name,
            Callback = vars.Callback,
            CanSee = vars.CanSee,
        }
    )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------