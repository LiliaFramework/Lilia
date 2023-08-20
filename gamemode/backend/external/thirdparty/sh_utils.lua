if (CLIENT) then
	function lia.util.GetInjuredColor(client)
		local health_color = color_white

		if (!IsValid(client)) then
			return health_color
		end

		local health_color = color_white
		local health, healthMax = client:Health(), client:GetMaxHealth()

		if ((health / healthMax) < .95) then
			health_color = lia.color.LerpHSV(nil, nil, healthMax, health, 0)
		end

		return health_color
	end

	function lia.util.ScreenScaleH(n, type)
		if (type) then
			if (ScrH() > 720) then return n end
			return math.ceil(n/1080*ScrH())
		end

		return n * (ScrH() / 480)
	end
	--ScreenScale = Width scale

	function Derma_NumericRequest( strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText )

		local Window = vgui.Create( "DFrame" )
		Window:SetTitle( strTitle or "Message Title (First Parameter)" )
		Window:SetDraggable( false )
		Window:ShowCloseButton( false )
		Window:SetBackgroundBlur( true )
		Window:SetDrawOnTop( true )

		local InnerPanel = vgui.Create( "DPanel", Window )
		InnerPanel:SetPaintBackground( false )

		local Text = vgui.Create( "ixDLabel", InnerPanel )
		Text:SetText( strText or "Message Text (Second Parameter)" )
		Text:SizeToContents()
		Text:SetContentAlignment( 5 )
		Text:SetTextColor( color_white )

		local TextEntry = vgui.Create( "DTextEntry", InnerPanel )
		TextEntry:SetValue( strDefaultText or "" )
		TextEntry.OnEnter = function() Window:Close() fnEnter( TextEntry:GetValue() ) end
		TextEntry:SetNumeric(true)

		local ButtonPanel = vgui.Create( "DPanel", Window )
		ButtonPanel:SetTall( 30 )
		ButtonPanel:SetPaintBackground( false )

		local Button = vgui.Create( "DButton", ButtonPanel )
		Button:SetText( strButtonText or "OK" )
		Button:SizeToContents()
		Button:SetTall( 20 )
		Button:SetWide( Button:GetWide() + 20 )
		Button:SetPos( 5, 5 )
		Button.DoClick = function() Window:Close() fnEnter( TextEntry:GetValue() ) end

		local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
		ButtonCancel:SetText( strButtonCancelText or L"derma_request_cancel" )
		ButtonCancel:SizeToContents()
		ButtonCancel:SetTall( 20 )
		ButtonCancel:SetWide( Button:GetWide() + 20 )
		ButtonCancel:SetPos( 5, 5 )
		ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
		ButtonCancel:MoveRightOf( Button, 5 )

		ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

		local w, h = Text:GetSize()
		w = math.max( w, 400 )

		Window:SetSize( w + 50, h + 25 + 75 + 10 )
		Window:Center()

		InnerPanel:StretchToParent( 5, 25, 5, 45 )

		Text:StretchToParent( 5, 5, 5, 35 )

		TextEntry:StretchToParent( 5, nil, 5, nil )
		TextEntry:AlignBottom( 5 )

		TextEntry:RequestFocus()
		TextEntry:SelectAllText( true )

		ButtonPanel:CenterHorizontal()
		ButtonPanel:AlignBottom( 8 )

		Window:MakePopup()
		Window:DoModal()

		return Window

	end

	file.CreateDir("helix/images")
	lia.util.LoadedImages = lia.util.LoadedImages or { [0] = Material("icon16/cross.png") }

	function lia.util.FetchImage(id, callback, failImg, pngParameters, imageProvider)
		local loadedImage = lia.util.LoadedImages[id]

		if (loadedImage) then
			if (callback) then callback(loadedImage) end
			return
		end

		if (file.Exists("helix/images/" .. id .. ".png", "DATA")) then
			local mat = Material("data/helix/images/"..id..".png", pngParameters or "noclamp smooth")

			if (mat) then
				lia.util.LoadedImages[id] = mat
				if (callback) then callback(mat) end
			elseif (callback) then
				callback(false)
			end
		else
			http.Fetch((imageProvider or "https://i.imgur.com/") .. id .. ".png", function (body, size, headers, code)
				if (code != 200) then
					callback(false)
					return
				end

				if (!body or body == "") then 
					callback(false)
					return 
				end

				file.Write("helix/images/" .. id .. ".png", body)
				local mat = Material("data/helix/images/" .. id .. ".png", "noclamp smooth")
				lia.util.LoadedImages[id] = mat

				if (callback) then
					callback(mat)
				end
			end, function ()
				if (callback) then callback(false) end
			end)
		end
	end
end

local function swap(array, index1, index2)
    array[index1], array[index2] = array[index2], array[index1]
end

function table.shuffle(array)
    local counter = #array
    while counter > 1 do
        local index = math.random(counter)
        swap(array, index, counter)
        counter = counter - 1
    end

	return array
end