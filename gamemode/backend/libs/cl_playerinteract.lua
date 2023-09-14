--------------------------------------------------------------------------------------------------------
lia.playerInteract = lia.playerInteract or {}
lia.playerInteract.currentEnt = lia.playerInteract.currentEnt or {}
lia.playerInteract.funcs = lia.playerInteract.funcs or {}
--------------------------------------------------------------------------------------------------------
isInteracting = false
interactPressTime = 0
cachedPitch = 0
interfaceScale = 0
selectedFunction = nil
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
--------------------------------------------------------------------------------------------------------