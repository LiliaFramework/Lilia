ITEM.name = "Generic Item"
ITEM.desc = "Generic Description"
ITEM.model = "models/props_interiors/pot01a.mdl"
ITEM.url = ""
ITEM.functions.use = {
	name = "Open",
	icon = "icon16/book_link.png",
	onRun = function( item )
		net.Start( "sendURL" )
		net.WriteString( item.url )
		net.Send( item.player )
		return false
	end,
}
