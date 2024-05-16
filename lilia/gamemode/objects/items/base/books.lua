--- Structure of Book Item Base.
-- @items Books

--- This table defines the default structure of the book item base.
-- @realm shared
-- @table Configuration
-- @field name Name of the item | **string**
-- @field desc Description of the item | **string**
-- @field model Model path of the item | **string**
-- @field width Width of the item | **number**
-- @field height Height of the item | **number**
-- @field category Category of the item | **string**
-- @field contents Contents of the book item as HTML | **table**

ITEM.name = "Book Base"
ITEM.desc = "A book."
ITEM.category = "Literature"
ITEM.model = "models/props_lab/bindergraylabel01b.mdl"
ITEM.contents = ""
ITEM.functions.Read = {
    onClick = function(item)
        local frame = vgui.Create("DFrame")
        frame:SetSize(540, 680)
        frame:SetTitle(item.name)
        frame:MakePopup()
        frame:Center()
        frame.html = frame:Add("DHTML")
        frame.html:Dock(FILL)
        frame.html:SetHTML([[<html><body style="background-color: #ECECEC; color: #282B2D; font-family: 'Book Antiqua', Palatino, 'Palatino Linotype', 'Palatino LT STD', Georgia, serif; font-size 16px; text-align: justify;">]] .. item.contents .. [[</body></html>]])
    end,
    onRun = function() return false end,
    icon = "icon16/book_open.png"
}
