------------------------------------------------------------------------------------------------------------------------
function SetDrag(dragee, drager)
    if not IsValid(dragee) then return end
    dragee:setNetVar("dragged", true)
    if IsValid(Draggers[drager]) and IsValid(Dragging[Draggers[drager]]) then
        Dragging[Draggers[drager]] = nil
    end

    if drager == nil then
        if Dragging[dragee] then
            Draggers[Dragging[dragee]] = nil
        end
    else
        Draggers[drager] = dragee
    end

    Dragging[dragee] = drager
end
------------------------------------------------------------------------------------------------------------------------