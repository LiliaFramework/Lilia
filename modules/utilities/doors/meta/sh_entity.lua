local entityMeta = FindMetaTable( "Entity" )
function entityMeta:checkDoorAccess( client, access )
	if not self:isDoor() then return false end
	access = access or DOOR_GUEST
	local parent = self.liaParent
	if IsValid( parent ) then return parent:checkDoorAccess( client, access ) end
	if hook.Run( "CanPlayerAccessDoor", client, self, access ) then return true end
	if self.liaAccess and ( self.liaAccess[ client ] or 0 ) >= access then return true end
	return false
end

function entityMeta:keysOwn( client )
	if self:IsVehicle() then
		self:CPPISetOwner( client )
		self:setNetVar( "owner", client:getChar():getID() )
		self.ownerID = client:getChar():getID()
		self:setNetVar( "ownerName", client:getChar():getName() )
	end
end

function entityMeta:keysLock()
	if self:IsVehicle() then self:Fire( "lock" ) end
end

function entityMeta:keysUnLock()
	if self:IsVehicle() then self:Fire( "unlock" ) end
end

function entityMeta:getDoorOwner()
	if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

function entityMeta:isLocked()
	return self:getNetVar( "locked", false )
end

function entityMeta:isDoorLocked()
	return sself:GetInternalVariable( "m_bLocked" ) or self.locked or false
end

if SERVER then
	function entityMeta:removeDoorAccessData()
		if IsValid( self ) then
			for k, _ in pairs( self.liaAccess or {} ) do
				netstream.Start( k, "doorMenu" )
			end

			self.liaAccess = {}
			self:SetDTEntity( 0, nil )
		end
	end

	function entityMeta:setLocked( state )
		self:setNetVar( "locked", state )
	end

	function entityMeta:isDoor()
		if not IsValid( self ) then return end
		local class = self:GetClass():lower()
		local doorPrefixes = { "prop_door", "func_door", "func_door_rotating", "door_", }
		for _, prefix in ipairs( doorPrefixes ) do
			if class:find( prefix ) then return true end
		end
		return false
	end

	function entityMeta:getDoorPartner()
		return self.liaPartner
	end
else
	function entityMeta:isDoor()
		return self:GetClass():find( "door" )
	end

	function entityMeta:getDoorPartner()
		local owner = self:GetOwner() or self.liaDoorOwner
		if IsValid( owner ) and owner:isDoor() then return owner end
		for _, v in ipairs( ents.FindByClass( "prop_door_rotating" ) ) do
			if v:GetOwner() == self then
				self.liaDoorOwner = v
				return v
			end
		end
	end
end
