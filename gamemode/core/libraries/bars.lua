lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.list = {}
lia.bar.actionText = ""
lia.bar.actionStart = 0
lia.bar.actionEnd = 0
function lia.bar.get( identifier )
	for _, bar in ipairs( lia.bar.list ) do
		if bar.identifier == identifier then return bar end
	end
end

function lia.bar.add( getValue, color, priority, identifier )
	if identifier then
		local old = lia.bar.get( identifier )
		if old then table.remove( lia.bar.list, old.priority ) end
	end

	priority = priority or #lia.bar.list + 1
	lia.bar.list[ priority ] = {
		getValue = getValue,
		color = color or Color( math.random( 150, 255 ), math.random( 150, 255 ), math.random( 150, 255 ) ),
		priority = priority,
		lifeTime = 0,
		identifier = identifier
	}
	return priority
end

function lia.bar.remove( identifier )
	for i, bar in ipairs( lia.bar.list ) do
		if bar.identifier == identifier then
			table.remove( lia.bar.list, i )
			break
		end
	end
end

function lia.bar.drawBar( x, y, w, h, pos, neg, max, right, color )
	if pos > max then pos = max end
	max = max - 1
	pos = math.max( ( w - 2 ) / max * pos, 0 )
	neg = math.max( ( w - 2 ) / max * neg, 0 )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawRect( x, y, w + 6, h )
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawOutlinedRect( x, y, w + 6, h )
	surface.SetDrawColor( color.r, color.g, color.b )
	surface.DrawRect( x + 3, y + 3, pos, h - 6 )
	surface.SetDrawColor( 255, 100, 100 )
	surface.DrawRect( x + 4 + w - neg, y + 3, neg, h - 6 )
end

local mathApproach = math.Approach
function lia.bar.drawAll()
	lia.bar.drawAction()
	if hook.Run( "ShouldHideBars" ) then return end
	table.sort( lia.bar.list, function( a, b ) return a.priority > b.priority end )
	local w, h = ScrW() * 0.35, 14
	local x = 4
	local y = ScrH() - h
	local deltas = lia.bar.delta
	local update = FrameTime() * 0.6
	local now = CurTime()
	for i, bar in ipairs( lia.bar.list ) do
		local target = bar.getValue()
		local value = math.Approach( deltas[ i ] or 0, target, update )
		deltas[ i ] = value
		if value ~= target then bar.lifeTime = now + 5 end
		if bar.lifeTime >= now or bar.visible or hook.Run( "ShouldBarDraw", bar ) then
			lia.bar.drawBar( x, y, w, h, value, 0, 2, false, bar.color )
			y = y - ( h + 2 )
		end
	end
end