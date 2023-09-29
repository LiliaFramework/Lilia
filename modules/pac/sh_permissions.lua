--------------------------------------------------------------------------------------------------------
function MODULE:isAllowedToUsePAC(client)
	if client:getChar() and flag ~= "" and client:getChar():hasFlags(lia.config.PACFlag) then return true end
	if client:IsAdmin() or client:IsSuperAdmin() then return true end

	return false
end

--------------------------------------------------------------------------------------------------------
function MODULE:CanWearParts(client, file)
	return self:isAllowedToUsePAC(client)
end

--------------------------------------------------------------------------------------------------------
function MODULE:PrePACEditorOpen(client)
	return self:isAllowedToUsePAC(client)
end

--------------------------------------------------------------------------------------------------------
function MODULE:PrePACConfigApply(client)
	return self:isAllowedToUsePAC(client)
end
--------------------------------------------------------------------------------------------------------