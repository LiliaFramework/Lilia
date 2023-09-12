----------------------------------------------------------------------------------------------
lia.config.LoadOptions = {
    ["Open Detailed Description"] = function(ply, target)
        net.Start("OpenDetailedDescriptions")
        net.WriteEntity(target)
        net.WriteString(target:getChar():getData("textDetDescData", nil) or "No detailed description found.")
        net.WriteString(target:getChar():getData("textDetDescDataURL", nil) or "No detailed description found.")
        net.Send(ply)
    end,
    ["Set Detailed Description"] = function(ply, target)
        net.Start("SetDetailedDescriptions")
        net.WriteString(target:steamName())
        net.Send(ply)
    end,
}
----------------------------------------------------------------------------------------------