--------------------------------------------------------------------------------------------------------------------------
ITEM.name = "Splint"
--------------------------------------------------------------------------------------------------------------------------
ITEM.desc = "This is a splint. Used to Patch Broken Legs."
--------------------------------------------------------------------------------------------------------------------------
ITEM.category = "Medical"
--------------------------------------------------------------------------------------------------------------------------
ITEM.model = "models/Gibs/wood_gib01e.mdl"
--------------------------------------------------------------------------------------------------------------------------
ITEM.width = 1
--------------------------------------------------------------------------------------------------------------------------
ITEM.height = 1
--------------------------------------------------------------------------------------------------------------------------
ITEM.functions.use = {
    name = "Use",
    tip = "equipTip",
    icon = "icon16/tick.png",
    onRun = function(item)
        local client = item.player
        client:getChar():setData("leg_broken", false)
        client:SetWalkSpeed(lia.config.WalkSpeed)
        client:SetRunSpeed(lia.config.RunSpeed)

        return true
    end
}

--------------------------------------------------------------------------------------------------------------------------
ITEM.functions.usef = {
    name = "Use Forward",
    tip = "useTip",
    icon = "icon16/arrow_up.png",
    onRun = function(item)
        local client = item.player
        local trace = client:GetEyeTraceNoCursor() -- We don't need cursors.
        local target = trace.Entity
        if target and target:IsValid() and target:IsPlayer() and target:Alive() then
            target:getChar():setData("leg_broken", false)
            target:SetWalkSpeed(lia.config.WalkSpeed)
            target:SetRunSpeed(lia.config.RunSpeed)

            return true
        end

        return false
    end,
    onCanRun = function(item) return not IsValid(item.entity) end
}
--------------------------------------------------------------------------------------------------------------------------