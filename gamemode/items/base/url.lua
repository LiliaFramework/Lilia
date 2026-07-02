ITEM.name = "urlName"
ITEM.desc = "urlDesc"
ITEM.model = "models/props_interiors/pot01a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.url = ""
ITEM.frameWidth = 1100
ITEM.frameTall = 800
ITEM.functions.use = {
    name = "open",
    icon = "icon16/book_link.png",
    onClick = function(item)
        local url = item.url
        if not isstring(url) or url == "" then return end
        local frame = vgui.Create("liaFrame")
        frame:SetSize(math.min(ScrW() * 0.85, item.frameWidth or 1100), math.min(ScrH() * 0.85, item.frameTall or 800))
        frame:SetMinWidth(480)
        frame:SetMinHeight(360)
        frame:SetSizable(true)
        frame:SetTitle(item.name or L("urlName"))
        frame:Center()
        frame:MakePopup()
        local html = frame:Add("DHTML")
        html:Dock(FILL)
        html:OpenURL(url)
        frame.html = html
    end,
    onRun = function() return false end,
}
