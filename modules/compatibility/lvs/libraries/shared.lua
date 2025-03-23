function MODULE:CanProperty( client, property, ent )
	if property == "editentity" and ent:isSimfphysCar() then return client:hasPrivilege( "Staff Permissions - Can Edit Simfphys Cars" ) end
end
