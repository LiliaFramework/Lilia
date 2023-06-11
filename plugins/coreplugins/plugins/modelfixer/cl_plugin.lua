net.Receive("TPoseFixerSync", function()
    for k, v in pairs(net.ReadTable()) do
        ix.anim.SetModelClass(k, v)
    end
end)