if sam and sam.command then
    for _, commandInfo in ipairs(sam.command.get_commands()) do
        local customSyntax = ""
        for _, argInfo in ipairs(commandInfo.args) do
            customSyntax = customSyntax == "" and "[" or customSyntax .. " ["
            customSyntax = customSyntax .. (argInfo.default and tostring(type(argInfo.default)) or "string") .. " "
            customSyntax = customSyntax .. argInfo.name .. "]"
        end

        local permission = "sam.command." .. commandInfo.name
        lia.command.add(
            commandInfo.name,
            {
                adminOnly = commandInfo.default_rank == "admin",
                superAdminOnly = commandInfo.default_rank == "superadmin",
                syntax = customSyntax,
                onRun = function(client, arguments)
                    if CAMI.PlayerHasAccess(client, permission) then
                        RunConsoleCommand("sam", commandInfo.name, unpack(arguments))
                    end
                end
            }
        )
    end
end

for k,v in pairs(lia.config.urls) do
	lia.command.add(k, {
		onRun = function(self, client)
			client:SendLua("gui.OpenURL('" .. v .. "')")
		end
	})
end