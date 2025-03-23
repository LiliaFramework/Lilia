local RarityColors = {
	[ "Common" ] = Color( 255, 255, 255 ),
	[ "Uncommon" ] = Color( 30, 255, 0 ),
	[ "Rare" ] = Color( 0, 112, 221 ),
	[ "Epic" ] = Color( 163, 53, 238 ),
	[ "Legendary" ] = Color( 255, 128, 0 ),
}

local VendorClick = { "buttons/button15.wav", 30, 250 }
local PANEL = {}
function PANEL:Init()
	self:SetSize( 600, 200 )
	self:Dock( TOP )
	self:SetPaintBackground( false )
	self:SetCursor( "hand" )
	self.background = self:Add( "DPanel" )
	self.background:Dock( FILL )
	self.background:DockMargin( 0, 0, 0, 10 )
	self.iconFrame = self.background:Add( "DPanel" )
	self.iconFrame:SetSize( 96, 96 )
	self.iconFrame:Dock( LEFT )
	self.iconFrame:DockMargin( 10, 10, 10, 10 )
	self.icon = self.iconFrame:Add( "liaItemIcon" )
	self.icon:SetSize( 96, 96 )
	self.icon:Dock( FILL )
	self.icon.Paint = function() end
	self.textContainer = self.background:Add( "DPanel" )
	self.textContainer:Dock( FILL )
	self.textContainer:DockMargin( 0, 10, 10, 10 )
	self.textContainer:SetPaintBackground( false )
	self.name = self.textContainer:Add( "DLabel" )
	self.name:SetFont( "VendorItemNameFont" )
	self.name:SetExpensiveShadow( 1, color_black )
	self.name:Dock( TOP )
	self.name:DockMargin( 0, 0, 0, 8 )
	self.name:SetContentAlignment( 5 )
	self.name:SetText( "" )
	self.description = self.textContainer:Add( "DLabel" )
	self.description:SetFont( "VendorItemDescFont" )
	self.description:SetTextColor( Color( 200, 200, 200 ) )
	self.description:Dock( TOP )
	self.description:DockMargin( 0, 12, 0, 0 )
	self.description:SetWrap( true )
	self.description:SetContentAlignment( 1 )
	self.description:SetAutoStretchVertical( true )
	self.description:SetText( "" )
	self.spacer = self.textContainer:Add( "DPanel" )
	self.spacer:Dock( FILL )
	self.spacer:SetPaintBackground( false )
	self.action = self.textContainer:Add( "liaSmallButton" )
	self.action:SetHeight( 40 )
	self.action:Dock( BOTTOM )
	self.action:DockMargin( 0, 10, 0, 0 )
	self.action:SetFont( "VendorItemDescFont" )
	self.action:SetTextColor( color_white )
	self.isSelling = false
	self.suffix = ""
end

local function clickEffects()
	local client = LocalPlayer()
	client:EmitSound( unpack( VendorClick ) )
end

function PANEL:sellItemToVendor()
	local item = self.item
	if not item then return end
	if IsValid( lia.gui.vendor ) then
		lia.gui.vendor:sellItemToVendor( item.uniqueID )
		clickEffects()
	end
end

function PANEL:buyItemFromVendor()
	local item = self.item
	if not item then return end
	if IsValid( lia.gui.vendor ) then
		lia.gui.vendor:buyItemFromVendor( item.uniqueID )
		clickEffects()
	end
end

function PANEL:updateAction()
	if not self.action or not self.item then return end
	local price = liaVendorEnt:getPrice( self.item.uniqueID, self.isSelling )
	local priceSuffix
	if price == 0 then
		priceSuffix = L( "vendorFree" )
	elseif price > 1 then
		priceSuffix = string.format( "%s %s", price, lia.currency.plural )
	else
		priceSuffix = string.format( "%s %s", price, lia.currency.singular )
	end

	local actionText = self.isSelling and L( "vendorSellAction", priceSuffix ) or L( "vendorBuyAction", priceSuffix )
	self.action:SetText( actionText )
	self.action.DoClick = function()
		if self.isSelling then
			self:sellItemToVendor()
		else
			self:buyItemFromVendor()
		end
	end
end

function PANEL:setQuantity( quantity )
	if not self.item then return end
	if quantity then
		if quantity <= 0 then
			self:Remove()
			return
		end

		self.suffix = tostring( quantity ) .. "x "
	else
		self.suffix = ""
	end

	self:updateLabel()
end

function PANEL:setItemType( itemType )
	local item = lia.item.list[ itemType ]
	assert( item, tostring( itemType ) .. " is not a valid item" )
	self.item = item
	self.icon:SetModel( item.model, item.skin or 0 )
	self:updateLabel()
	self:updateAction()
	local rarity = item.rarity or "Common"
	local nameColor = RarityColors[ rarity ] or color_white
	self.name:SetTextColor( nameColor )
end

function PANEL:setIsSelling( isSelling )
	self.isSelling = isSelling
	self:updateLabel()
	self:updateAction()
end

function PANEL:updateLabel()
	if not self.item then return end
	local nameText = ( self.suffix ~= "" and self.suffix or "" ) .. self.item:getName()
	self.name:SetText( nameText )
	self.description:SetText( self.item:getDesc() or L( "vendorNoDescription" ) )
	local price = liaVendorEnt:getPrice( self.item.uniqueID, self.isSelling )
	local priceSuffix
	if price == 0 then
		priceSuffix = L( "vendorFree" )
	elseif price > 1 then
		priceSuffix = string.format( "%s %s", price, lia.currency.plural )
	else
		priceSuffix = string.format( "%s %s", price, lia.currency.singular )
	end

	local actionText = self.isSelling and L( "vendorSellAction", priceSuffix ) or L( "vendorBuyAction", priceSuffix )
	self.action:SetText( actionText )
end

vgui.Register( "VendorItem", PANEL, "DPanel" )
