ICON_FONT = nil
local function ScrapPage()
	local d = deferred.new()
	http.Fetch( 'https://liliaframework.github.io/liaIcons', function( resp )
		local headpos = select( 2, resp:find( '<div class="row">' ) )
		local body = resp:sub( headpos )
		local scrapped = {}
		for str in body:gmatch( '(icon-%S+);</i>' ) do
			local whitespaced = str:gsub( '">', ' ' )
			local nulled = whitespaced:gsub( '&#', '0' )
			local splitted = nulled:Split( ' ' )
			scrapped[ splitted[ 1 ] ] = splitted[ 2 ]
		end

		d:resolve( scrapped )
	end )
	return d
end

ScrapPage():next( function( scrapped )
	ICON_FONT = scrapped
	hook.Run( "EasyIconsLoaded" )
end )

function getIcon( sIcon, bIsCode )
	local iconValue = tonumber( bIsCode and sIcon or ICON_FONT[ sIcon ] )
	if iconValue then
		local char = utf8.char( iconValue )
		return char
	end
end
