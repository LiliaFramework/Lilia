netstream.Hook(
    "startcmenu",
    function(client, target, IsHandcuffed)
        if CLIENT then
            local menu = DermaMenu()
            for optionName, optionData in pairs(lia.config.PlayerInteractionOptions) do
                if not optionData.CanSee(client, target) then continue end
                menu:AddOption(
                    optionName,
                    function()
                        optionData.Callback(client, target)
                    end
                )
            end

            menu:Open()
            menu:MakePopup()
            menu:Center()
        end
    end
)