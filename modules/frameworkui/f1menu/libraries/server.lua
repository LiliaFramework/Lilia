function MODULE:PlayerDeath( client )
	netstream.Start( client, "removeF1" )
end

util.AddNetworkString( "lia_teleport_entity" )
net.Receive( "lia_teleport_entity", function( len, ply )
	local ent = net.ReadEntity()
	if not IsValid( ent ) then return end
	if not ply:hasPrivilege( "Staff Permission — Teleport to Entity (Entity Tab)" ) then return end
	local pos = ent:GetPos() + Vector( 0, 0, 50 )
	ply:SetPos( pos )
	ply:ChatPrint( "Teleported to entity: " .. ent:GetClass() )
end )