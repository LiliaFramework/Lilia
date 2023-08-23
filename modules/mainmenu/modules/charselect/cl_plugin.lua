if lia.config.CustomUIEnabled then
    function MODULE:LiliaLoaded()
        vgui.Create('liaNewCharacterMenu')
    end

    function MODULE:KickedFromCharacter(id, isCurrentChar)
        if isCurrentChar then vgui.Create('liaNewCharacterMenu') end
    end

    function MODULE:CreateMenuButtons(tabs)
        tabs['characters'] = function(panel)
            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
            vgui.Create('liaNewCharacterMenu')
        end
    end
else
    function MODULE:LiliaLoaded()
        vgui.Create("liaCharacter")
    end

    function MODULE:KickedFromCharacter(id, isCurrentChar)
        if isCurrentChar then vgui.Create("liaCharacter") end
    end

    function MODULE:CreateMenuButtons(tabs)
        tabs["characters"] = function(panel)
            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
            vgui.Create("liaCharacter")
        end
    end
end