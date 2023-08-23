if lia.config.CustomUIEnabled then
    function PLUGIN:LiliaLoaded()
        vgui.Create('liaNewCharacterMenu')
    end

    function PLUGIN:KickedFromCharacter(id, isCurrentChar)
        if isCurrentChar then vgui.Create('liaNewCharacterMenu') end
    end

    function PLUGIN:CreateMenuButtons(tabs)
        tabs['characters'] = function(panel)
            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
            vgui.Create('liaNewCharacterMenu')
        end
    end
else
    function PLUGIN:LiliaLoaded()
        vgui.Create("liaCharacter")
    end

    function PLUGIN:KickedFromCharacter(id, isCurrentChar)
        if isCurrentChar then vgui.Create("liaCharacter") end
    end

    function PLUGIN:CreateMenuButtons(tabs)
        tabs["characters"] = function(panel)
            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
            vgui.Create("liaCharacter")
        end
    end
end