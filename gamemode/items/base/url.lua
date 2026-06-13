ITEM.name = "urlName"
ITEM.desc = "urlDesc"
ITEM.model = "models/props_interiors/pot01a.mdl"
ITEM.url = ""
ITEM.functions.use = {
    name = "open",
    icon = "icon16/book_link.png",
    onClick = function(item)
        local url = item.url
        if isstring(url) and url ~= "" then gui.OpenURL(url) end
    end,
    onRun = function() return false end,
}
