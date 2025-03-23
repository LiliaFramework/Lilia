function MODULE:CanPlayerUseConfig( client )
	return client:hasPrivilege( "Staff Permissions - Access Configuration Menu" )
end

function MODULE:CanPlayerModifyConfig( client )
	return client:hasPrivilege( "Staff Permissions - Access Edit Configuration Menu" )
end
