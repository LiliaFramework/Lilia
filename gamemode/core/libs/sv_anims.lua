function GM:PlayerInitialSpawn(client)
    net.Start("TPoseFixerSync")
    net.WriteTable(CachedModels)
    net.Send(client)
end

function lia.anim.setModelClass(model, class)
    if not lia.anim[class] then return end
    CachedModels[model] = class
    lia.anim.setModelClass(model, class)
end

util.AddNetworkString("TPoseFixerSync")