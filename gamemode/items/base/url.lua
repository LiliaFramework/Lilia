﻿ITEM.name = "Generic Item"
ITEM.desc = "Generic Description"
ITEM.model = "models/props_interiors/pot01a.mdl"
ITEM.url = ""
ITEM.functions.use = {
    name = L("open"),
    icon = "icon16/book_link.png",
    onRun = function()
        if CLIENT then gui.OpenURL(url) end
        return false
    end,
}
