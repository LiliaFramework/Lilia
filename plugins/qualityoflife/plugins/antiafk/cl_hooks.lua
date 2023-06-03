function PLUGIN:DrawCharInfo(client, character, info)
	if client:Alive() and client:getNetVar("IsAFK") then
		info[#info + 1] = {"Away from keyboard!", Color(255, 100, 100)}
	end
end