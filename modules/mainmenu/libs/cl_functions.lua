function MODULE:ScreenScale(size)
    return size * (ScrH() / 900) + 10
end

function MODULE:LiliaLoaded()
    vgui.Create("liaCharacter")
end

function MODULE:KickedFromCharacter(id, isCurrentChar)
    if isCurrentChar then
        vgui.Create("liaCharacter")
    end
end

function MODULE:CreateMenuButtons(tabs)
    tabs["characters"] = function(panel)
        if IsValid(lia.gui.menu) then
            lia.gui.menu:Remove()
        end

        vgui.Create("liaCharacter")
    end
end