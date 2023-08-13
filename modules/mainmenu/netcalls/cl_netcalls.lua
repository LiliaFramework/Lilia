net.Receive("liaCharList", function()
	local newCharList = {}
	local length = net.ReadUInt(32)
	for i = 1, length do
		newCharList[i] = net.ReadUInt(32)
	end

	local oldCharList = lia.characters
	lia.characters = newCharList

	if (oldCharList) then
		hook.Run("CharacterListUpdated", oldCharList, newCharList)
	else
		hook.Run("CharacterListLoaded", newCharList)
	end
end)
