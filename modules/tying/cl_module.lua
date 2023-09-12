----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:DrawCharInfo(client, character, info)
    if client:IsHandcuffed() then
        info[#info + 1] = {"Handcuffed", Color(245, 215, 110)}
        if client:IsBlinded() then
            info[#info + 1] = {"Blindfolded", Color(245, 215, 110)}
        end

        if client:IsGagged() then
            info[#info + 1] = {"Gagged", Color(245, 215, 110)}
        end

        if client:IsDragged() then
            info[#info + 1] = {"Being Dragged", Color(245, 215, 110)}
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerViewInventory()
    if IsValid(LocalPlayer():getNetVar("searcher")) then return false end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:RenderScreenspaceEffects()
    local ply = LocalPlayer()
    if not (ply:IsHandcuffed() and ply:IsBlinded()) then return end
    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.DrawRect(0, 0, ScrW(), ScrH())
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------