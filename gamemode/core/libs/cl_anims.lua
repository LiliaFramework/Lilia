net.Receive("TPoseFixerSync", function()
    for k, v in pairs(net.ReadTable()) do
        lia.anim.setModelClass(k, v)
    end
end)