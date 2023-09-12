----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
for name, vars in pairs(lia.config.PlayerInteractionOptions) do
    lia.playerInteract.addFunc(
        vars.name,
        {
            name = name,
            Callback = function(client, target) netstream.Start(vars.Identifier, client, target) end,
            CanSee = vars.CanSee,
        }
    )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------