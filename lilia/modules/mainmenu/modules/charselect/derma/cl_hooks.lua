--------------------------------------------------------------------------------------------------------
hook.Add("ShowHelp", "DisableShowHelp", function() return false end)
--------------------------------------------------------------------------------------------------------
hook.Add(
    "PlayerBindPress",
    "F1MenuPlayerBindPress",
    function(client, bind, pressed)
        if bind:lower():find("gm_showhelp") and pressed then
            if IsValid(lia.gui.menu) then
                lia.gui.menu:remove()
            elseif LocalPlayer():getChar() then
                vgui.Create("liaMenu")
            end

            return true
        end
    end
)

--------------------------------------------------------------------------------------------------------
hook.Add(
    "OnCharInfoSetup",
    "F1MenuOnCharInfoSetup",
    function(infoPanel)
        if not IsValid(infoPanel.model) then return end
        local mdl = infoPanel.model
        local ent = mdl.Entity
        local client = LocalPlayer()
        if not IsValid(client) or not client:Alive() then return end
        local weapon = client:GetActiveWeapon()
        if not IsValid(weapon) then return end
        local weapModel = ClientsideModel(weapon:GetModel(), RENDERGROUP_BOTH)
        if not IsValid(weapModel) then return end
        weapModel:SetParent(ent)
        weapModel:AddEffects(EF_BONEMERGE)
        weapModel:SetSkin(weapon:GetSkin())
        weapModel:SetColor(weapon:GetColor())
        weapModel:SetNoDraw(true)
        ent.weapon = weapModel
        local act = ACT_MP_STAND_IDLE
        local model = ent:GetModel():lower()
        local class = lia.anim.getModelClass(model)
        local tree = lia.anim[class]
        if not tree then return end
        local subClass = weapon.HoldType or weapon:GetHoldType()
        subClass = HOLDTYPE_TRANSLATOR[subClass] or subClass
        if tree[subClass] and tree[subClass][act] then
            local branch = tree[subClass][act]
            local act2 = istable(branch) and branch[1] or branch
            if isstring(act2) then
                act2 = ent:LookupSequence(act2)
            else
                act2 = ent:SelectWeightedSequence(act2)
            end

            ent:ResetSequence(act2)
        end
    end
)
--------------------------------------------------------------------------------------------------------