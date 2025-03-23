local characterMeta = lia.meta.character
function characterMeta:doesRecognize( id )
	if not isnumber( id ) and id.getID then id = id:getID() end
	return hook.Run( "isCharRecognized", self, id ) ~= false
end

function characterMeta:doesFakeRecognize( id )
	if not isnumber( id ) and id.getID then id = id:getID() end
	return hook.Run( "isCharFakeRecognized", self, id ) ~= false
end

if SERVER then
	function characterMeta:recognize( character, name )
		local id
		if isnumber( character ) then
			id = character
		elseif character and character.getID then
			id = character:getID()
		end

		local recognized = self:getData( "rgn", "" )
		local nameList = self:getRecognizedAs()
		if name ~= nil then
			nameList[ id ] = name
			self:setRecognizedAs( nameList )
		else
			self:setData( "rgn", recognized .. "," .. id .. "," )
		end
		return true
	end
end
