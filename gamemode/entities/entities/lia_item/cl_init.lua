local vectorMeta = FindMetaTable( "Vector" )
local toScreen = vectorMeta.ToScreen
function ENT:computeDescMarkup( description )
	if self.desc ~= description then
		self.desc = description
		self.markup = lia.markup.parse( "<font=liaItemDescFont>" .. description .. "</font>", ScrW() * 0.5 )
	end
	return self.markup
end

function ENT:onDrawEntityInfo( alpha )
	local itemTable = self:getItemTable()
	if not itemTable then return end
	local oldEntity = itemTable.entity
	itemTable.entity = self
	local oldData = itemTable.data
	itemTable.data = self:getNetVar( "data" ) or oldData
	local position = toScreen( self:LocalToWorld( self:OBBCenter() ) )
	local x, y = position.x, position.y
	local description = itemTable:getDesc()
	self:computeDescMarkup( description )
	lia.util.drawText( L( itemTable.getName and itemTable:getName() or itemTable.name ), x, y, ColorAlpha( lia.config.get( "Color" ), alpha ), 1, 1, nil, alpha * 0.65 )
	y = y + 12
	if self.markup then self.markup:draw( x, y, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, alpha ) end
	hook.Run( "DrawItemDescription", self, x, y, ColorAlpha( color_white, alpha ), alpha * 0.65 )
	itemTable.data = oldData
	itemTable.entity = oldEntity
end

function ENT:DrawTranslucent()
	local itemTable = self:getItemTable()
	if itemTable and itemTable.drawEntity then
		itemTable:drawEntity( self )
	else
		self:DrawModel()
	end
end
