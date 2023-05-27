--///////////////////////////////////////////////////// This was Ripped from EGM SWEPs \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
local PLUGIN = PLUGIN

function PLUGIN:GetCrossArmsAnim()
    return {
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-43.7, -107.1, 15.9),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(20.2, -57.2, -6.1),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-28.9, -59.4, 1.0),
        ["ValveBiped.Bip01_R_Thigh"] = Angle(4.7, -6.0, -0.4),
        ["ValveBiped.Bip01_L_Thigh"] = Angle(-7.6, -0.2, 0.4),
        ["ValveBiped.Bip01_L_Forearm"] = Angle(51.0, -120.4, -18.8),
        ["ValveBiped.Bip01_R_Hand"] = Angle(14.4, -33.4, -7.2),
        ["ValveBiped.Bip01_L_Hand"] = Angle(25.9, 31.5, -14.9),
    }
end

function PLUGIN:GetSaluteAnim()
    return {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(80, -95, -77.5),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(35, -125, -5),
    }
end

function PLUGIN:GetSurrenderAnim()
    return {
        ["ValveBiped.Bip01_L_Forearm"] = Angle(25, -65, 25),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-25, -65, -25),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-70, -180, 70),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(70, -180, -70),
    }
end

function PLUGIN:GetEaseAnim()
    return {
        ["ValveBiped.Bip01_Head1"] = Angle(0, 12, 0),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-6, -6, 0),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-9, 0, 0), --gauche, arriere,rotation vers droite
        ["ValveBiped.Bip01_L_Forearm"] = Angle(9, 0, 0),
        ["ValveBiped.Bip01_R_Thigh"] = Angle(-3, 0, 0),
        ["ValveBiped.Bip01_L_Thigh"] = Angle(3, 5, 0),
        ["ValveBiped.Bip01_R_Foot"] = Angle(20, 0, 0),
        ["ValveBiped.Bip01_L_Foot"] = Angle(-20, 0, 0),
        ["ValveBiped.Bip01_R_Hand"] = Angle(0, 0, 20),
        ["ValveBiped.Bip01_L_Hand"] = Angle(0, 0, -20),
    }
end

function PLUGIN:GetAttentionAnim()
    return {
        ["ValveBiped.Bip01_Head1"] = Angle(0, 12, 0),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-6, -6, 0),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-9, 0, 0),
        ["ValveBiped.Bip01_L_Forearm"] = Angle(9, 0, 0),
        ["ValveBiped.Bip01_R_Thigh"] = Angle(-3, 0, 0),
        ["ValveBiped.Bip01_L_Thigh"] = Angle(3, 5, 0),
        ["ValveBiped.Bip01_R_Foot"] = Angle(20, 0, 0),
        ["ValveBiped.Bip01_L_Foot"] = Angle(-20, 0, 0),
        ["ValveBiped.Bip01_R_Hand"] = Angle(0, 0, 20),
        ["ValveBiped.Bip01_L_Hand"] = Angle(0, 0, -20),
    }
end

PLUGIN.AnimTable = {
    [1] = {"surrender_animation_swep", PLUGIN:GetSurrenderAnim()},
    [2] = {"salute_swep", PLUGIN:GetSaluteAnim()},
    [3] = {"cross_arms_swep", PLUGIN:GetCrossArmsAnim()},
    [4] = {"atease_swep", PLUGIN:GetEaseAnim()},
    [5] = {"attention_swep", PLUGIN:GetAttentionAnim()},
}

function PLUGIN:VelocityIsHigher(ply, value)
    local x, y, z = math.abs(ply:GetVelocity().x), math.abs(ply:GetVelocity().y), math.abs(ply:GetVelocity().z)

    if x > value or y > value or z > value then
        return true
    else
        return false
    end
end

function PLUGIN:ApplyAnimation(ply, targetValue, class)
    local classassigned
    if not (IsValid(ply) or ply:getChar() or ply:Alive()) then return end

    for k, v in pairs(self.AnimTable) do
        if class == v[1] then
            classassigned = v[2]
            break
        end
    end

    if not classassigned then return end

    for boneName, angle in pairs(classassigned) do
        local bone = ply:LookupBone(boneName)

        if bone then
            if targetValue == 0 then
                ply:ManipulateBoneAngles(bone, angle * 0)
            else
                ply:ManipulateBoneAngles(bone, angle)
            end
        end
    end
end

function PLUGIN:ToggleAnimaton(ply, crossing, class, deactivateOnMove)
    if crossing then
        ply:SetNWBool("animationStatus", true)

        if class then
            ply:SetNWString("animationClass", class)
        end

        ply:SetNWInt("deactivateOnMove", deactivateOnMove)
    else
        ply:SetNWBool("animationStatus", false)
        ply:SetNWInt("deactivateOnMove", 5)
    end
end

function PLUGIN:Think()
    for _, ply in pairs(player.GetHumans()) do
        local animationClass = ply:GetNWString("animationClass")

        if ply:GetNWBool("animationStatus") then
            self:ApplyAnimation(ply, 1, animationClass)
        else
            self:ApplyAnimation(ply, 0, animationClass)
        end
    end
end

function PLUGIN:SetupMove(ply, moveData, cmd)
    if ply:GetNWBool("animationStatus") then
        local deactivateOnMove = ply:GetNWInt("deactivateOnMove", 5)

        if self:VelocityIsHigher(ply, deactivateOnMove) then
            self:ToggleAnimaton(ply, false)
        end

        if ply:KeyDown(IN_DUCK) then
            self:ToggleAnimaton(ply, false)
        end

        if ply:KeyDown(IN_USE) then
            self:ToggleAnimaton(ply, false)
        end

        if ply:KeyDown(IN_JUMP) then
            self:ToggleAnimaton(ply, false)
        end
    end
end