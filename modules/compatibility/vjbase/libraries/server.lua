local vjThink = 0
local VJBaseConsoleCommands = {
	[ "vj_npc_processtime" ] = "1",
	[ "vj_npc_corpsefade" ] = "1",
	[ "vj_npc_corpsefadetime" ] = "5",
	[ "vj_npc_nogib" ] = "1",
	[ "vj_npc_nosnpcchat" ] = "1",
	[ "vj_npc_slowplayer" ] = "1",
	[ "vj_npc_noproppush" ] = "1",
	[ "vj_npc_nothrowgrenade" ] = "1",
	[ "vj_npc_fadegibstime" ] = "5",
	[ "vj_npc_knowenemylocation" ] = "1",
	[ "vj_npc_dropweapon" ] = "0",
	[ "vj_npc_plypickupdropwep" ] = "0",
}

function MODULE:Think()
	if vjThink <= CurTime() then
		for k, v in pairs( VJBaseConsoleCommands ) do
			RunConsoleCommand( k, v )
		end

		vjThink = CurTime() + 180
	end
end

function MODULE:OnEntityCreated( entity )
	if entity:GetClass() == "obj_vj_spawner_base" then entity:Remove() end
end

timer.Simple( 10, function()
	hook.Remove( "PlayerInitialSpawn", "VJBaseSpawn" )
	hook.Remove( "PlayerInitialSpawn", "drvrejplayerInitialSpawn" )
	concommand.Remove( "vj_cleanup" )
end )
